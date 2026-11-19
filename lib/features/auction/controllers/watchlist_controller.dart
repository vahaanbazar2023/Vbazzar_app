import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/design_system/molecules/custom_snackbar.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/storage/storage_keys.dart';
import '../../../features/subscription/models/user_subscription.dart';
import '../../../routes/app_routes.dart';
import '../data/repositories/auction_repository_impl.dart';
import '../domain/repositories/auction_repository.dart';
import '../models/auction_pagination.dart';
import '../models/vehicle_listing.dart';
import '../services/auto_bid_service.dart';
import '../services/bid_flow.dart';
import '../services/vehicle_listing_service.dart';

/// The auction watchlist (separate from the wishlist): vehicles the user follows to bid on,
/// each with an auto-bid switch.
class WatchlistController extends GetxController {
  WatchlistController({
    VehicleListingService? listingService,
    AutoBidService? autoBidService,
    AuctionRepository? repository,
    Future<String> Function()? userId,
  }) : _readUserId = userId,
       _listing = listingService ?? Get.find<VehicleListingService>(),
       _autoBid = autoBidService ?? AutoBidService(),
       _repository = repository ?? AuctionRepositoryImpl();

  final VehicleListingService _listing;
  final AutoBidService _autoBid;
  final AuctionRepository _repository;
  final Future<String> Function()? _readUserId;

  final RxBool isLoading = true.obs;
  final RxBool isLoadingMore = false.obs;
  final Rxn<String> errorMessage = Rxn<String>();
  final RxList<VehicleListing> vehicles = <VehicleListing>[].obs;
  final Rx<AuctionPagination> pagination = AuctionPagination.empty().obs;

  /// Vehicle ids with an auto-bid / watchlist call in flight (disables their controls).
  final RxSet<String> busy = <String>{}.obs;

  late final ScrollController scrollController;
  int _currentPage = 1;

  /// Refresh the open watchlist, if any — e.g. when an auto-bid push arrives.
  static void refreshIfOpen() {
    if (Get.isRegistered<WatchlistController>()) {
      Get.find<WatchlistController>().refresh(silent: true);
    }
  }

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController()..addListener(_onScroll);
    _load();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  Future<String> _userId() async => _readUserId != null
      ? await _readUserId()
      : await SecureStorageService.to.read(StorageKeys.userId) ?? '';

  void _onScroll() {
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent * 0.8 &&
        !isLoadingMore.value &&
        pagination.value.hasNext) {
      _loadMore();
    }
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent) isLoading.value = true;
    errorMessage.value = null;
    _currentPage = 1;
    try {
      final result = await _listing.fetchWatchlistedVehicles(
        userId: await _userId(),
        page: _currentPage,
      );
      vehicles.assignAll(result.vehicles);
      pagination.value = result.pagination;
    } catch (e) {
      debugPrint('❌ [Watchlist._load] $e');
      if (!silent || vehicles.isEmpty) {
        errorMessage.value = appL10n.aucFailedLoadWatchlist;
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadMore() async {
    if (!pagination.value.hasNext || isLoadingMore.value) return;
    isLoadingMore.value = true;
    _currentPage++;
    try {
      final result = await _listing.fetchWatchlistedVehicles(
        userId: await _userId(),
        page: _currentPage,
      );
      vehicles.addAll(result.vehicles);
      pagination.value = result.pagination;
    } catch (e) {
      debugPrint('❌ [Watchlist._loadMore] $e');
      _currentPage--;
    } finally {
      isLoadingMore.value = false;
    }
  }

  @override
  Future<void> refresh({bool silent = false}) => _load(silent: silent);

  void _replace(String vehicleId, VehicleListing Function(VehicleListing) f) {
    final i = vehicles.indexWhere((v) => v.vehicleId == vehicleId);
    if (i != -1) vehicles[i] = f(vehicles[i]);
  }

  /// Manual bid from a watchlist card. Auto-bidders may answer at once, so the list is refreshed after.
  Future<String?> placeBid({
    required VehicleListing vehicle,
    required int bidAmount,
  }) async {
    final error = await BidFlow.placeBid(
      vehicle: vehicle,
      bidAmount: bidAmount,
      repository: _repository,
    );
    if (error == null) refresh(silent: true);
    return error;
  }

  /// Switch auto-bid on/off for [vehicle], or (on, while already on) change its limit.
  /// [maxAmount] = most auto-bid may bid on this vehicle; null = whole buying limit.
  /// Returns true when the server accepted it.
  Future<bool> setAutoBid(
    VehicleListing vehicle,
    bool enabled, {
    int? maxAmount,
  }) async {
    if (busy.contains(vehicle.vehicleId)) return false;
    busy.add(vehicle.vehicleId);
    final wasOn = vehicle.isAutoBidEnabled;
    _replace(
      vehicle.vehicleId,
      (v) => v.copyWith(isAutoBidEnabled: enabled),
    ); // optimistic
    try {
      final state = await _autoBid.setAutoBid(
        userId: await _userId(),
        vehicleId: vehicle.vehicleId,
        enabled: enabled,
        maxAmount: maxAmount,
      );
      _replace(
        vehicle.vehicleId,
        (v) => v.copyWith(
          isAutoBidEnabled: state.isEnabled,
          isWatchlisted: true,
          yourBid: state.yourBid,
          userVehicleBidCount: state.bidCount,
          currentHighestBid: state.currentHighestBid,
          availableBalance: state.remainingBidLimit,
          autoBidMaxAmount: state.isEnabled ? state.maxAmount : null,
        ),
      );
      CustomSnackbar.show(
        message: autoBidMessage(state, requested: enabled, wasOn: wasOn),
        type: state.isEnabled == enabled
            ? SnackbarType.success
            : SnackbarType.error,
      );
      if (state.bidsPlaced > 0) refresh(silent: true);
      return state.isEnabled == enabled;
    } on AutoBidException catch (e) {
      _replace(vehicle.vehicleId, (v) => v.copyWith(isAutoBidEnabled: wasOn));
      _showAutoBidError(e);
      return false;
    } catch (e) {
      debugPrint('❌ [Watchlist.setAutoBid] $e');
      _replace(vehicle.vehicleId, (v) => v.copyWith(isAutoBidEnabled: wasOn));
      CustomSnackbar.show(
        message: appL10n.aucAutoBidFailed,
        type: SnackbarType.error,
      );
      return false;
    } finally {
      busy.remove(vehicle.vehicleId);
    }
  }

  /// Remove [vehicle] from the watchlist (also switches its auto-bid off on the server).
  Future<void> removeFromWatchlist(VehicleListing vehicle) async {
    if (busy.contains(vehicle.vehicleId)) return;
    busy.add(vehicle.vehicleId);
    try {
      final r = await _autoBid.toggleWatchlist(
        userId: await _userId(),
        vehicleId: vehicle.vehicleId,
      );
      if (!r.isWatchlisted) {
        vehicles.removeWhere((v) => v.vehicleId == vehicle.vehicleId);
        CustomSnackbar.show(
          message: appL10n.aucRemovedFromWatchlist,
          type: SnackbarType.success,
        );
      } else {
        refresh(
          silent: true,
        ); // it was already removed elsewhere and the toggle re-added it
      }
    } catch (e) {
      debugPrint('❌ [Watchlist.remove] $e');
      CustomSnackbar.show(
        message: appL10n.aucFailedUpdateWatchlist,
        type: SnackbarType.error,
      );
    } finally {
      busy.remove(vehicle.vehicleId);
    }
  }

  /// Snackbar text after a successful auto-bid call.
  static String autoBidMessage(
    AutoBidState s, {
    required bool requested,
    bool wasOn = false,
  }) {
    if (!requested) return appL10n.aucAutoBidSwitchedOff;
    if (!s.isEnabled) {
      switch (s.stopReason) {
        case 'max_bids':
          return appL10n.aucAutoBidStoppedMaxBids('${s.maxBids}');
        case 'max_amount':
          return appL10n.aucAutoBidStoppedMaxAmount;
        default:
          return appL10n.aucAutoBidStoppedLimit;
      }
    }
    if (s.bidsPlaced > 0 && s.yourBid != null) {
      return appL10n.aucAutoBidPlacedNow(formatAmount(s.yourBid!));
    }
    return wasOn
        ? appL10n.aucAutoBidLimitUpdated
        : appL10n.aucAutoBidSwitchedOn;
  }

  static void _showAutoBidError(AutoBidException e) {
    CustomSnackbar.show(
      message: e.message.isNotEmpty ? e.message : appL10n.aucAutoBidFailed,
      type: SnackbarType.error,
    );
    if (e.needsBidLimit) {
      Get.toNamed(
        AppRoutes.subscription,
        arguments: {
          'subscription_source': SubscriptionTypeCode.auctionBidLimit,
          'title': appL10n.aucBidLimitPlanRequired,
          'subtitle': appL10n.aucBidLimitPlanRequiredSubtitle,
        },
      );
    }
  }

  static String formatAmount(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}
