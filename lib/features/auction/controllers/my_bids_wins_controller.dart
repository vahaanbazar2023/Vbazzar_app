import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/network_service.dart';
import '../../../core/network/endpoints/api_endpoints.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/storage/storage_keys.dart';
import '../../../core/design_system/molecules/custom_snackbar.dart';
import '../../../features/subscription/services/subscription_guard_service.dart';
import '../../../features/subscription/models/user_subscription.dart';
import '../../../routes/app_routes.dart';
import '../models/my_bids_wins_models.dart';
import '../models/pending_bid.dart';
import '../models/vehicle_listing.dart';
import '../domain/entities/bid_entity.dart';
import '../data/repositories/auction_repository_impl.dart';
import '../domain/repositories/auction_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// My Bids Controller
// ─────────────────────────────────────────────────────────────────────────────

class MyBidsController extends GetxController {
  final bids = <MyBidItem>[].obs;
  final isLoading = true.obs;
  final isLoadingMore = false.obs;
  final errorMessage = RxnString();
  final pagination = Rx<BidsWinsPagination>(BidsWinsPagination.empty());
  final isPlacingBid = false.obs;

  /// Holds the bid the user attempted before being redirected to SUBT002.
  /// Null means no pending bid. Cleared before any auto-submission.
  final pendingBid = Rxn<PendingBid>();

  final scrollController = ScrollController();
  static const _limit = 20;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    _load();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    final near =
        scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200;
    if (near && !isLoadingMore.value && pagination.value.hasNext) {
      _loadMore();
    }
  }

  Future<void> _load({bool refresh = false}) async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final uid = await SecureStorageService.to.read(StorageKeys.userId) ?? '';
      final response = await NetworkService.to.post(
        ApiEndpoints.myBidsPaginated,
        data: {'user_id': uid, 'page': 1, 'limit': _limit},
      );
      _parse(response.data, replace: true);
    } catch (e) {
      errorMessage.value = 'Failed to load bids. Please try again.';
      debugPrint('❌ MyBidsController: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadMore() async {
    if (!pagination.value.hasNext) return;
    isLoadingMore.value = true;
    try {
      final uid = await SecureStorageService.to.read(StorageKeys.userId) ?? '';
      final nextPage = pagination.value.currentPage + 1;
      final response = await NetworkService.to.post(
        ApiEndpoints.myBidsPaginated,
        data: {'user_id': uid, 'page': nextPage, 'limit': _limit},
      );
      _parse(response.data, replace: false);
    } catch (_) {
      // silent
    } finally {
      isLoadingMore.value = false;
    }
  }

  void _parse(dynamic raw, {required bool replace}) {
    if (raw is! Map<String, dynamic>) return;
    final data = raw['data'] as Map<String, dynamic>? ?? {};
    final rawBids = data['bids'] as List<dynamic>? ?? [];
    final pg = data['pagination'] as Map<String, dynamic>?;
    final items = rawBids
        .map((e) => MyBidItem.fromJson(e as Map<String, dynamic>))
        .toList();
    if (replace) {
      bids.assignAll(items);
    } else {
      bids.addAll(items);
    }
    if (pg != null) pagination.value = BidsWinsPagination.fromJson(pg);
  }

  Future<void> refresh() => _load(refresh: true);

  /// Full bid flow with all validations.
  /// Returns '__navigated__' if navigated to subscription screen.
  /// Returns null on success, error string on failure.
  Future<String?> placeBid({
    required MyBidItem bidItem,
    required int bidAmount,
  }) async {
    debugPrint(
      '🔵 [MyBidsController.placeBid] START amount=$bidAmount '
      'minPrice=${bidItem.minimumPrice} highestBid=${bidItem.currentHighestBid}',
    );

    // 1. Validate >= minimum price
    if (bidAmount < bidItem.minimumPrice) {
      return 'Minimum bid is ₹${_fmt(bidItem.minimumPrice)}';
    }

    // 2. Validate > current highest bid
    final highest = bidItem.currentHighestBid ?? bidItem.yourBid;
    if (highest > 0 && bidAmount <= highest) {
      return 'Must be higher than current bid';
    }

    // 3. Check SUBT002 (bid limit subscription)
    final guard = SubscriptionGuardService.to;
    debugPrint('🔵 [MyBidsController.placeBid] Step 3: checking SUBT002...');
    await guard.ensureLoaded();
    final hasBidLimit = guard.hasActiveSubscription(
      SubscriptionTypeCode.auctionBidLimit,
    );
    debugPrint(
      '🔵 [MyBidsController.placeBid] Step 3: hasBidLimit=$hasBidLimit',
    );
    if (!hasBidLimit) {
      debugPrint(
        '🔵 [MyBidsController.placeBid] Navigating to SUBT002 (no plan)',
      );
      pendingBid.value = PendingBid(
        vehicleId: bidItem.vehicleId,
        auctionId: bidItem.auctionId,
        bidAmount: bidAmount,
      );
      CustomSnackbar.show(
        message:
            'You need a Bid Limit subscription to place bids. '
            'Please subscribe to continue.',
        type: SnackbarType.error,
      );
      Get.toNamed(
        AppRoutes.subscription,
        arguments: {
          'subscription_source': SubscriptionTypeCode.auctionBidLimit,
          'title': 'Bid Limit Plan Required',
          'subtitle':
              'Subscribe to a bid limit plan to place bids in auctions.',
        },
      );
      return '__navigated__';
    }

    // 4. Check available balance (bid limit from subscription)
    final activeSubs = guard.allActiveSubscriptions(
      SubscriptionTypeCode.auctionBidLimit,
    );
    final availableBalance = activeSubs
        .fold<double>(0, (sum, s) => sum + (s.planAvailableBidAmount ?? 0))
        .toInt();

    debugPrint(
      '🔵 [MyBidsController.placeBid] Step 4: availableBalance=$availableBalance',
    );
    if (availableBalance <= 0 || bidAmount > availableBalance) {
      debugPrint(
        '🔵 [MyBidsController.placeBid] Navigating to SUBT002 (limit exceeded)',
      );
      pendingBid.value = PendingBid(
        vehicleId: bidItem.vehicleId,
        auctionId: bidItem.auctionId,
        bidAmount: bidAmount,
      );
      CustomSnackbar.show(
        message: availableBalance <= 0
            ? 'Your available buying limit is ₹0. '
                  'Please upgrade your bid limit plan to continue.'
            : 'Your bid of ₹${_fmt(bidAmount)} exceeds your available buying '
                  'limit of ₹${_fmt(availableBalance)}. '
                  'Please upgrade your plan to place higher bids.',
        type: SnackbarType.error,
      );
      Get.toNamed(
        AppRoutes.subscription,
        arguments: {
          'subscription_source': SubscriptionTypeCode.auctionBidLimit,
          'title': 'Bid Limit Exceeded',
          'subtitle': availableBalance <= 0
              ? 'You have no available buying limit. Upgrade your bid limit plan to continue.'
              : 'Your available buying limit is ₹${_fmt(availableBalance)}. '
                    'Upgrade your plan to place higher bids.',
        },
      );
      return '__navigated__';
    }

    // 5. Place bid via repository
    isPlacingBid.value = true;
    debugPrint(
      '🔵 [MyBidsController.placeBid] Calling API: '
      'vehicleId=${bidItem.vehicleId} auctionId=${bidItem.auctionId} amount=$bidAmount',
    );
    try {
      final uid = await SecureStorageService.to.read(StorageKeys.userId) ?? '';
      final repo = AuctionRepositoryImpl();
      await repo.placeBid(
        userId: uid,
        vehicleId: bidItem.vehicleId,
        auctionId: bidItem.auctionId,
        bidAmount: bidAmount,
      );
      debugPrint('✅ [MyBidsController.placeBid] Success');
      CustomSnackbar.show(
        message: 'Bid placed successfully!',
        type: SnackbarType.success,
      );
      // Refresh list so new bid amounts show
      _load();
      return null;
    } on BidException catch (e) {
      debugPrint('❌ [MyBidsController.placeBid] BidException: ${e.message}');
      if (e.message.toLowerCase().contains('higher') ||
          e.code == 'BID_TOO_LOW') {
        return 'Bid must be higher than the current highest bid';
      }
      return e.message;
    } catch (e) {
      debugPrint('❌ [MyBidsController.placeBid] Error: $e');
      return 'Something went wrong. Please try again.';
    } finally {
      isPlacingBid.value = false;
    }
  }

  // ─── Post-subscription bid revalidation ──────────────────────────────────

  /// Called by [SubscriptionConfirmController] after a successful SUBT002
  /// payment and guard cache refresh.
  ///
  /// Reads the updated Available Buying Limit from [SubscriptionGuardService],
  /// then either auto-submits the pending bid (Case A) or shows an error
  /// and clears the pending bid (Case B).
  Future<void> revalidatePendingBid() async {
    final bid = pendingBid.value;
    if (bid == null) {
      debugPrint(
        '🔵 [MyBidsController.revalidatePendingBid] No pending bid — no-op',
      );
      return;
    }
    if (isPlacingBid.value) {
      debugPrint(
        '🔵 [MyBidsController.revalidatePendingBid] Already placing bid — skipping',
      );
      return;
    }

    // Get the refreshed limit from the already-reloaded guard cache.
    final guard = SubscriptionGuardService.to;
    final activeSubs = guard.allActiveSubscriptions(
      SubscriptionTypeCode.auctionBidLimit,
    );
    final newLimit = activeSubs
        .fold<double>(0, (sum, s) => sum + (s.planAvailableBidAmount ?? 0))
        .toInt();

    debugPrint(
      '🔵 [MyBidsController.revalidatePendingBid] bidAmount=${bid.bidAmount} newLimit=$newLimit',
    );

    if (bid.bidAmount <= newLimit) {
      // ── Case A: limit now sufficient — auto-submit ──────────────────────
      pendingBid.value = null; // clear BEFORE API call (prevents double-submit)
      isPlacingBid.value = true;
      try {
        final uid =
            await SecureStorageService.to.read(StorageKeys.userId) ?? '';

        // Find the bid item in our list
        final bidItem = bids.firstWhereOrNull(
          (b) => b.vehicleId == bid.vehicleId,
        );

        if (bidItem == null) {
          debugPrint(
            '❌ [MyBidsController.revalidatePendingBid] Bid item not found in list',
          );
          CustomSnackbar.show(
            message: 'Vehicle not found. Please refresh and try again.',
            type: SnackbarType.error,
          );
          return;
        }

        debugPrint(
          '🔵 [MyBidsController.revalidatePendingBid] Case A — placing bid: '
          'vehicleId=${bid.vehicleId} auctionId=${bid.auctionId} amount=${bid.bidAmount}',
        );

        final repo = AuctionRepositoryImpl();
        await repo.placeBid(
          userId: uid,
          vehicleId: bid.vehicleId,
          auctionId: bid.auctionId,
          bidAmount: bid.bidAmount,
        );

        debugPrint(
          '✅ [MyBidsController.revalidatePendingBid] Bid placed successfully',
        );

        // Clean up the navigation stack
        Get.until(
          (route) =>
              route.settings.name != AppRoutes.subscription &&
              route.settings.name != AppRoutes.subscriptionConfirm &&
              route.settings.name != AppRoutes.walletPayment,
        );

        CustomSnackbar.show(
          message: 'Bid placed successfully!',
          type: SnackbarType.success,
        );

        // Refresh the bids list
        _load();
      } on BidException catch (e) {
        debugPrint(
          '❌ [MyBidsController.revalidatePendingBid] BidException: ${e.message}',
        );
        CustomSnackbar.show(
          message: e.message.isNotEmpty
              ? e.message
              : 'Bid could not be placed.',
          type: SnackbarType.error,
        );
      } catch (e) {
        debugPrint('❌ [MyBidsController.revalidatePendingBid] Error: $e');
        CustomSnackbar.show(
          message: 'Something went wrong. Please try again.',
          type: SnackbarType.error,
        );
      } finally {
        isPlacingBid.value = false;
      }
    } else {
      // ── Case B: still exceeds limit ─────────────────────────────────────
      debugPrint(
        '🔵 [MyBidsController.revalidatePendingBid] Case B — bid still exceeds limit '
        '(bid=${bid.bidAmount}, limit=$newLimit)',
      );
      CustomSnackbar.show(
        message:
            'Your bid of ₹${_fmt(bid.bidAmount)} exceeds your available '
            'buying limit of ₹${_fmt(newLimit)}. '
            'Please upgrade your plan to continue.',
        type: SnackbarType.error,
      );
      // Keep pendingBid alive for next attempt
      Get.back();
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

// ─────────────────────────────────────────────────────────────────────────────
// My Wins Controller
// ─────────────────────────────────────────────────────────────────────────────

class MyWinsController extends GetxController {
  final wins = <MyWinItem>[].obs;
  final isLoading = true.obs;
  final isLoadingMore = false.obs;
  final errorMessage = RxnString();
  final pagination = Rx<BidsWinsPagination>(BidsWinsPagination.empty());

  final scrollController = ScrollController();
  static const _limit = 20;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    _load();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    final near =
        scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200;
    if (near && !isLoadingMore.value && pagination.value.hasNext) {
      _loadMore();
    }
  }

  Future<void> _load({bool refresh = false}) async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final uid = await SecureStorageService.to.read(StorageKeys.userId) ?? '';
      final response = await NetworkService.to.post(
        ApiEndpoints.myWinsPaginated,
        data: {'user_id': uid, 'page': 1, 'limit': _limit},
      );
      _parse(response.data, replace: true);
    } catch (e) {
      errorMessage.value = 'Failed to load wins. Please try again.';
      debugPrint('❌ MyWinsController: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadMore() async {
    if (!pagination.value.hasNext) return;
    isLoadingMore.value = true;
    try {
      final uid = await SecureStorageService.to.read(StorageKeys.userId) ?? '';
      final nextPage = pagination.value.currentPage + 1;
      final response = await NetworkService.to.post(
        ApiEndpoints.myWinsPaginated,
        data: {'user_id': uid, 'page': nextPage, 'limit': _limit},
      );
      _parse(response.data, replace: false);
    } catch (_) {
      // silent
    } finally {
      isLoadingMore.value = false;
    }
  }

  void _parse(dynamic raw, {required bool replace}) {
    if (raw is! Map<String, dynamic>) return;
    final data = raw['data'] as Map<String, dynamic>? ?? {};
    final rawWins = data['wins'] as List<dynamic>? ?? [];
    final pg = data['pagination'] as Map<String, dynamic>?;
    final items = rawWins
        .map((e) => MyWinItem.fromJson(e as Map<String, dynamic>))
        .toList();
    if (replace) {
      wins.assignAll(items);
    } else {
      wins.addAll(items);
    }
    if (pg != null) pagination.value = BidsWinsPagination.fromJson(pg);
  }

  Future<void> refresh() => _load(refresh: true);
}
