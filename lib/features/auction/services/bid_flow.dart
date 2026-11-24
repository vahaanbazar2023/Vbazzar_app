import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../core/design_system/molecules/custom_snackbar.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/storage/storage_keys.dart';
import '../../../features/subscription/models/user_subscription.dart';
import '../../../features/subscription/services/subscription_guard_service.dart';
import '../../../routes/app_routes.dart';
import '../domain/entities/bid_entity.dart';
import '../domain/repositories/auction_repository.dart';
import '../models/pending_bid.dart';
import '../models/vehicle_listing.dart';
import '../widgets/bid_confirm_dialog.dart';

/// The manual bid flow shared by the auction listing and the watchlist:
/// minimum / highest checks → SUBT002 plan check → bid-limit check → API.
/// Moved unchanged out of VehicleListingController.placeBid.
class BidFlow {
  BidFlow._();

  /// Returned when the user backs out of the confirm dialog. Callers stay quiet.
  static const String cancelled = '__cancelled__';

  /// Returns an error message, `'__navigated__'` when the user was sent to buy a plan,
  /// [cancelled] when the user did not confirm, or null on success.
  /// [confirm] asks the user to confirm the amount; defaults to [showBidConfirmDialog].
  static Future<String?> placeBid({
    required VehicleListing vehicle,
    required int bidAmount,
    required AuctionRepository repository,
    void Function(PendingBid bid)? onPendingBid,
    RxBool? isPlacing,
    Future<bool> Function(int amount)? confirm,
  }) async {
    debugPrint(
      '🔵 [placeBid] START amount=$bidAmount minPrice=${vehicle.minimumPrice} availableBalance=${vehicle.availableBalance}',
    );
    // 1. Validate >= minimum price
    if (bidAmount < vehicle.minimumPrice) {
      return appL10n.aucMinimumBid(_fmt(vehicle.minimumPrice));
    }
    // 2. Validate > current highest bid
    final highest = vehicle.currentHighestBid ?? vehicle.yourBid;
    if (highest > 0 && bidAmount <= highest) {
      return appL10n.aucMustBeHigherThanCurrentBid;
    }

    // 2b. Ask the user to confirm the amount (figures + words)
    if (!await (confirm ?? showBidConfirmDialog)(bidAmount)) return cancelled;

    // 3. Check SUBT002 (bid limit subscription)
    final guard = SubscriptionGuardService.to;
    debugPrint('🔵 [placeBid] Step 3: checking SUBT002...');
    await guard.ensureLoaded();
    final hasBidLimit = guard.hasActiveSubscription(
      SubscriptionTypeCode.auctionBidLimit,
    );
    debugPrint('🔵 [placeBid] Step 3: hasBidLimit=$hasBidLimit');
    if (!hasBidLimit) {
      debugPrint('🔵 [placeBid] Navigating to SUBT002 subscription (no plan)');
      onPendingBid?.call(
        PendingBid(
          vehicleId: vehicle.vehicleId,
          auctionId: vehicle.auctionId,
          bidAmount: bidAmount,
        ),
      );
      Get.back(); // close the bid sheet first
      await Future.delayed(const Duration(milliseconds: 300));
      CustomSnackbar.show(
        message: appL10n.aucBidLimitSubscriptionRequired,
        type: SnackbarType.error,
      );
      Get.toNamed(
        AppRoutes.subscription,
        arguments: {
          'subscription_source': SubscriptionTypeCode.auctionBidLimit,
          'title': appL10n.aucBidLimitPlanRequired,
          'subtitle': appL10n.aucBidLimitPlanRequiredSubtitle,
        },
      );
      return '__navigated__';
    }

    // 4. Check available balance (bid limit from subscription)
    debugPrint(
      '🔵 [placeBid] Step 4: availableBalance=${vehicle.availableBalance}',
    );
    if (vehicle.availableBalance <= 0 || bidAmount > vehicle.availableBalance) {
      debugPrint(
        '🔵 [placeBid] Navigating to SUBT002 subscription (limit exceeded/zero)',
      );
      onPendingBid?.call(
        PendingBid(
          vehicleId: vehicle.vehicleId,
          auctionId: vehicle.auctionId,
          bidAmount: bidAmount,
        ),
      );
      Get.back(); // close the bid sheet first
      await Future.delayed(const Duration(milliseconds: 300));
      CustomSnackbar.show(
        message: vehicle.availableBalance <= 0
            ? appL10n.aucBuyingLimitZeroUpgrade
            : appL10n.aucBidExceedsLimitUpgradeHigher(
                _fmt(bidAmount),
                _fmt(vehicle.availableBalance),
              ),
        type: SnackbarType.error,
      );
      Get.toNamed(
        AppRoutes.subscription,
        arguments: {
          'subscription_source': SubscriptionTypeCode.auctionBidLimit,
          'title': appL10n.aucBidLimitExceeded,
          'subtitle': vehicle.availableBalance <= 0
              ? appL10n.aucNoBuyingLimitUpgrade
              : appL10n.aucBuyingLimitUpgradeHigher(
                  _fmt(vehicle.availableBalance),
                ),
        },
      );
      return '__navigated__';
    }

    // 5. Place bid via repository
    isPlacing?.value = true;
    debugPrint(
      '🔵 [placeBid] Calling API: vehicleId=${vehicle.vehicleId} auctionId=${vehicle.auctionId} amount=$bidAmount',
    );
    try {
      final uid = await SecureStorageService.to.read(StorageKeys.userId) ?? '';
      debugPrint('🔵 [placeBid] userId=$uid');
      await repository.placeBid(
        userId: uid,
        vehicleId: vehicle.vehicleId,
        auctionId: vehicle.auctionId,
        bidAmount: bidAmount,
      );
      debugPrint('✅ [placeBid] Success');
      return null;
    } on BidException catch (e) {
      debugPrint('❌ [placeBid] BidException: ${e.message} (${e.code})');
      if (e.message.toLowerCase().contains('higher') ||
          e.code == 'BID_TOO_LOW') {
        return appL10n.aucBidMustBeHigherThanHighest;
      }
      return e.message;
    } catch (e) {
      debugPrint('❌ [placeBid] Error: $e');
      return appL10n.somethingWentWrong;
    } finally {
      isPlacing?.value = false;
    }
  }

  static String _fmt(int n) {
    if (n == 0) return '0';
    final s = n.toString();
    final buf = StringBuffer();
    int c = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      if (c > 0 && c % 3 == 0) buf.write(',');
      buf.write(s[i]);
      c++;
    }
    return buf.toString().split('').reversed.join();
  }
}
