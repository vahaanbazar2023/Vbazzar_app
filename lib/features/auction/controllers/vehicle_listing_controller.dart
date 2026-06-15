import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/design_system/molecules/custom_snackbar.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/storage/storage_keys.dart';
import '../../../features/subscription/models/user_subscription.dart';
import '../../../features/subscription/services/subscription_guard_service.dart';
import '../../../routes/app_routes.dart';
import '../data/repositories/auction_repository_impl.dart';
import '../domain/entities/bid_entity.dart';
import '../domain/repositories/auction_repository.dart';
import '../models/auction_listing.dart';
import '../models/auction_pagination.dart';
import '../models/pending_bid.dart';
import '../models/vehicle_listing.dart';
import '../services/vehicle_listing_service.dart';

class VehicleListingController extends GetxController {
  final VehicleListingService _service;
  final AuctionRepository _repository;
  final AuctionListing auction;

  VehicleListingController({
    required this.auction,
    VehicleListingService? service,
    AuctionRepository? repository,
  }) : _service = service ?? VehicleListingService(),
       _repository = repository ?? AuctionRepositoryImpl();

  final vehicles = <VehicleListing>[].obs;
  final pagination = Rx<AuctionPagination>(AuctionPagination.empty());
  final isLoading = true.obs;
  final isLoadingMore = false.obs;
  final errorMessage = ''.obs;
  final searchQuery = ''.obs;
  final currentIndex = 0.obs;
  final isPlacingBid = false.obs;

  /// Holds the bid the user attempted before being redirected to SUBT002.
  /// Null means no pending bid. Cleared before any auto-submission.
  final pendingBid = Rxn<PendingBid>();

  int _currentPage = 1;

  late final ScrollController scrollController;
  final TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController()..addListener(_onScroll);
    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });
    _load();
  }

  @override
  void onClose() {
    scrollController.dispose();
    searchController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    final nearBottom =
        scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200;
    if (nearBottom && !isLoadingMore.value && pagination.value.hasNext) {
      _loadMore();
    }
  }

  Future<void> _load({bool refresh = false}) async {
    isLoading.value = true;
    errorMessage.value = '';
    _currentPage = 1;
    try {
      final userId =
          await SecureStorageService.to.read(StorageKeys.userId) ?? '';
      final result = await _service.fetchVehicles(
        userId: userId,
        auctionId: auction.auctionId,
        page: 1,
      );
      vehicles.assignAll(result.vehicles);
      pagination.value = result.pagination;
      currentIndex.value = 0;
    } catch (e, st) {
      debugPrint('❌ [VehicleListingController._load] error: $e\n$st');
      errorMessage.value = 'Failed to load vehicles. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadMore() async {
    if (!pagination.value.hasNext) return;
    isLoadingMore.value = true;
    try {
      final userId =
          await SecureStorageService.to.read(StorageKeys.userId) ?? '';
      final nextPage = _currentPage + 1;
      final result = await _service.fetchVehicles(
        userId: userId,
        auctionId: auction.auctionId,
        page: nextPage,
      );
      vehicles.addAll(result.vehicles);
      pagination.value = result.pagination;
      _currentPage = nextPage;
    } catch (_) {
      // Silently ignore load-more failures
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> refresh() => _load(refresh: true);

  /// Refreshes the vehicle list silently — no loading spinner, existing
  /// vehicles stay visible until the new data arrives.
  /// Public so external callers (e.g. after subscription purchase) can
  /// trigger a refresh to update availableBalance.
  Future<void> silentRefresh() => _silentRefresh();

  Future<void> _silentRefresh() async {
    try {
      final userId =
          await SecureStorageService.to.read(StorageKeys.userId) ?? '';
      final result = await _service.fetchVehicles(
        userId: userId,
        auctionId: auction.auctionId,
        page: 1,
      );
      vehicles.assignAll(result.vehicles);
      pagination.value = result.pagination;
      _currentPage = 1;
    } catch (e, st) {
      debugPrint('⚠️ [VehicleListingController._silentRefresh] error: $e\n$st');
      // Silent — don't show an error; the stale list remains visible.
    }
  }

  void goNext() {
    final list = filteredVehicles;
    if (currentIndex.value < list.length - 1) {
      currentIndex.value++;
    } else if (pagination.value.hasNext && !isLoadingMore.value) {
      _loadMore().then((_) {
        if (currentIndex.value < filteredVehicles.length - 1) {
          currentIndex.value++;
        }
      });
    }
  }

  void goPrev() {
    if (currentIndex.value > 0) currentIndex.value--;
  }

  VehicleListing? get currentVehicle {
    final list = filteredVehicles;
    if (list.isEmpty) return null;
    final idx = currentIndex.value.clamp(0, list.length - 1);
    return list[idx];
  }

  List<VehicleListing> get filteredVehicles {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return vehicles;
    return vehicles
        .where(
          (v) =>
              v.displayTitle.toLowerCase().contains(q) ||
              v.registrationNo.toLowerCase().contains(q) ||
              v.vehicleId.toLowerCase().contains(q),
        )
        .toList();
  }

  // ─── Bid placement ────────────────────────────────────────────

  /// Full bid flow with all validations.
  /// Returns an error string on failure, null on success.
  Future<String?> placeBid({
    required VehicleListing vehicle,
    required int bidAmount,
  }) async {
    debugPrint(
      '🔵 [placeBid] START amount=$bidAmount minPrice=${vehicle.minimumPrice} availableBalance=${vehicle.availableBalance}',
    );
    // 1. Validate >= minimum price
    if (bidAmount < vehicle.minimumPrice) {
      return 'Minimum bid is ₹${_fmt(vehicle.minimumPrice)}';
    }
    // 2. Validate > current highest bid
    final highest = vehicle.currentHighestBid ?? vehicle.yourBid;
    if (highest > 0 && bidAmount <= highest) {
      return 'Must be higher than current bid ';
    }

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
      pendingBid.value = PendingBid(
        vehicleId: vehicle.vehicleId,
        auctionId: vehicle.auctionId,
        bidAmount: bidAmount,
      );
      Get.back(); // close the bid sheet first
      await Future.delayed(const Duration(milliseconds: 300));
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
    debugPrint(
      '🔵 [placeBid] Step 4: availableBalance=${vehicle.availableBalance}',
    );
    if (vehicle.availableBalance <= 0 || bidAmount > vehicle.availableBalance) {
      debugPrint(
        '🔵 [placeBid] Navigating to SUBT002 subscription (limit exceeded/zero)',
      );
      pendingBid.value = PendingBid(
        vehicleId: vehicle.vehicleId,
        auctionId: vehicle.auctionId,
        bidAmount: bidAmount,
      );
      Get.back(); // close the bid sheet first
      await Future.delayed(const Duration(milliseconds: 300));
      CustomSnackbar.show(
        message: vehicle.availableBalance <= 0
            ? 'Your available buying limit is ₹0. '
                  'Please upgrade your bid limit plan to continue.'
            : 'Your bid of ₹${_fmt(bidAmount)} exceeds your available buying '
                  'limit of ₹${_fmt(vehicle.availableBalance)}. '
                  'Please upgrade your plan to place higher bids.',
        type: SnackbarType.error,
      );
      Get.toNamed(
        AppRoutes.subscription,
        arguments: {
          'subscription_source': SubscriptionTypeCode.auctionBidLimit,
          'title': 'Bid Limit Exceeded',
          'subtitle': vehicle.availableBalance <= 0
              ? 'You have no available buying limit. Upgrade your bid limit plan to continue.'
              : 'Your available buying limit is ₹${_fmt(vehicle.availableBalance)}. '
                    'Upgrade your plan to place higher bids.',
        },
      );
      return '__navigated__';
    }

    // 5. Place bid via repository
    isPlacingBid.value = true;
    debugPrint(
      '🔵 [placeBid] Calling API: vehicleId=${vehicle.vehicleId} auctionId=${vehicle.auctionId} amount=$bidAmount',
    );
    try {
      final uid = await SecureStorageService.to.read(StorageKeys.userId) ?? '';
      debugPrint('🔵 [placeBid] userId=$uid');
      await _repository.placeBid(
        userId: uid,
        vehicleId: vehicle.vehicleId,
        auctionId: vehicle.auctionId,
        bidAmount: bidAmount,
      );
      debugPrint('✅ [placeBid] Success');
      // Silent background refresh — keeps the current list visible while
      // fetching fresh values (bids_left, bids_received, available_balance).
      _silentRefresh();
      return null;
    } on BidException catch (e) {
      debugPrint('❌ [placeBid] BidException: ${e.message} (${e.code})');
      if (e.message.toLowerCase().contains('higher') ||
          e.code == 'BID_TOO_LOW') {
        return 'Bid must be higher than the current highest bid';
      }
      return e.message;
    } catch (e) {
      debugPrint('❌ [placeBid] Error: $e');
      return 'Something went wrong. Please try again.';
    } finally {
      isPlacingBid.value = false;
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
      debugPrint('🔵 [revalidatePendingBid] No pending bid — no-op');
      return;
    }
    if (isPlacingBid.value) {
      debugPrint('🔵 [revalidatePendingBid] Already placing bid — skipping');
      return;
    }

    // Get the refreshed limit from the already-reloaded guard cache.
    // Sum all active SUBT002 subscriptions' available balance since a user
    // may have multiple plans active simultaneously.
    final guard = SubscriptionGuardService.to;
    final activeSubs = guard.allActiveSubscriptions(
      SubscriptionTypeCode.auctionBidLimit,
    );
    final newLimit = activeSubs
        .fold<double>(0, (sum, s) => sum + (s.planAvailableBidAmount ?? 0))
        .toInt();

    debugPrint(
      '🔵 [revalidatePendingBid] bidAmount=${bid.bidAmount} newLimit=$newLimit',
    );

    if (bid.bidAmount <= newLimit) {
      // ── Case A: limit now sufficient — auto-submit ──────────────────────
      pendingBid.value = null; // clear BEFORE API call (prevents double-submit)
      isPlacingBid.value = true;
      try {
        final uid =
            await SecureStorageService.to.read(StorageKeys.userId) ?? '';

        // Prefer the live VehicleListing from the loaded list; fall back to
        // the stored auctionId so we can still place the bid even if the list
        // was refreshed and the vehicle is not at the same index.
        final vehicle = vehicles.firstWhereOrNull(
          (v) => v.vehicleId == bid.vehicleId,
        );

        if (vehicle == null) {
          debugPrint('❌ [revalidatePendingBid] Vehicle not found in list');
          CustomSnackbar.show(
            message: 'Vehicle not found. Please refresh and try again.',
            type: SnackbarType.error,
          );
          return;
        }

        debugPrint(
          '🔵 [revalidatePendingBid] Case A — placing bid: '
          'vehicleId=${bid.vehicleId} auctionId=${bid.auctionId} amount=${bid.bidAmount}',
        );

        await _repository.placeBid(
          userId: uid,
          vehicleId: vehicle.vehicleId,
          auctionId: vehicle.auctionId,
          bidAmount: bid.bidAmount,
        );

        debugPrint('✅ [revalidatePendingBid] Bid placed successfully');

        // Clean up the navigation stack — remove all subscription screens
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

        // Refresh the vehicle listing. After Get.until() the listing screen
        // is on top and its controller is the registered instance — refresh it.
        // Use a post-frame delay so the route transition has settled first.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (Get.isRegistered<VehicleListingController>()) {
            Get.find<VehicleListingController>().refresh();
          }
        });
      } on BidException catch (e) {
        debugPrint('❌ [revalidatePendingBid] BidException: ${e.message}');
        CustomSnackbar.show(
          message: e.message.isNotEmpty
              ? e.message
              : 'Bid could not be placed.',
          type: SnackbarType.error,
        );
      } catch (e) {
        debugPrint('❌ [revalidatePendingBid] Error: $e');
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
        '🔵 [revalidatePendingBid] Case B — bid still exceeds limit '
        '(bid=${bid.bidAmount}, limit=$newLimit)',
      );
      CustomSnackbar.show(
        message:
            'Your bid of ₹${_fmt(bid.bidAmount)} exceeds your available '
            'buying limit of ₹${_fmt(newLimit)}. '
            'Please upgrade your plan to continue.',
        type: SnackbarType.error,
      );
      // Keep pendingBid alive — the user will pick a higher-tier plan and
      // the next payment success will re-run revalidatePendingBid() with
      // the updated limit. It is cleared when the subscription screen
      // disposes (user backs out entirely without purchasing).
      Get.back(); // pop subscriptionConfirm, return to subscription screen
    }
  }
}
