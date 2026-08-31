import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/design_system/molecules/custom_snackbar.dart';
import '../../../core/network/endpoints/api_endpoints.dart';
import '../../../core/network/network_service.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/storage/storage_keys.dart';
import '../../../features/subscription/models/user_subscription.dart';
import '../../../features/subscription/services/subscription_guard_service.dart';
import '../../../routes/app_routes.dart';
import '../data/repositories/auction_repository_impl.dart';
import '../domain/entities/auction_entity.dart';
import '../domain/entities/bid_entity.dart';
import '../domain/repositories/auction_repository.dart';
import '../models/auction_pagination.dart';
import '../models/pending_bid.dart';
import '../models/vehicle_listing.dart';
import '../services/vehicle_listing_service.dart';

class VehicleListingController extends GetxController
    with GetTickerProviderStateMixin {
  final VehicleListingService _service;
  final AuctionRepository _repository;

  /// Vehicle type from the selected category, e.g. '2w', '4w', 'cv'
  final String vehicleType;

  /// Display title shown in the screen header
  final String auctionTitle;

  /// Bid increment amount for this vehicle category
  final int bidIncrementAmount;

  static const _tabTypes = [
    'live_auctions',
    'closing_today',
    'upcoming_auctions',
  ];

  VehicleListingController({
    String auctionType =
        'live_auctions', // kept for compat, ignored (tab drives it)
    required this.vehicleType,
    this.auctionTitle = '',
    this.bidIncrementAmount = 5000,
    VehicleListingService? service,
    AuctionRepository? repository,
  }) : _service = service ?? VehicleListingService(),
       _repository = repository ?? AuctionRepositoryImpl();

  // ─── Tab state ────────────────────────────────────────────────
  late final TabController tabController;

  final _tabVehicles = [
    <VehicleListing>[].obs,
    <VehicleListing>[].obs,
    <VehicleListing>[].obs,
  ];
  final _tabPagination = [
    Rx<AuctionPagination>(AuctionPagination.empty()),
    Rx<AuctionPagination>(AuctionPagination.empty()),
    Rx<AuctionPagination>(AuctionPagination.empty()),
  ];
  final _tabLoading = [true.obs, false.obs, false.obs];
  final _tabLoadingMore = [false.obs, false.obs, false.obs];
  final _tabError = [''.obs, ''.obs, ''.obs];
  final _tabPage = [1, 1, 1];
  final _tabInitialized = [false, false, false];

  final scrollControllers = List.generate(3, (_) => ScrollController());

  RxList<VehicleListing> tabVehicles(int i) => _tabVehicles[i];
  Rx<AuctionPagination> tabPagination(int i) => _tabPagination[i];
  RxBool tabLoading(int i) => _tabLoading[i];
  RxBool tabLoadingMore(int i) => _tabLoadingMore[i];
  RxString tabError(int i) => _tabError[i];

  // ─── Filter state ─────────────────────────────────────────────
  final selectedRegion = Rxn<RegionEntity>();
  final selectedState = Rxn<StateByRegionEntity>();
  final regions = <RegionEntity>[].obs;
  final statesByRegion = <StateByRegionEntity>[].obs;
  final isLoadingRegions = false.obs;
  final isLoadingStatesByRegion = false.obs;

  // backup for cancel
  RegionEntity? _backupRegion;
  StateByRegionEntity? _backupState;

  bool get hasActiveFilters =>
      selectedRegion.value != null || selectedState.value != null;

  // ─── Search ───────────────────────────────────────────────────
  final searchQuery = ''.obs;
  final TextEditingController searchController = TextEditingController();

  // ─── Bid placement ────────────────────────────────────────────
  final isPlacingBid = false.obs;
  final pendingBid = Rxn<PendingBid>();

  // Legacy fields kept for compat with detail screen
  final vehicles = <VehicleListing>[].obs;
  final pagination = Rx<AuctionPagination>(AuctionPagination.empty());
  final isLoading = true.obs;
  final isLoadingMore = false.obs;
  final errorMessage = ''.obs;
  final currentIndex = 0.obs;
  int _currentPage = 1;
  late final ScrollController scrollController;
  final currentTabIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 3, vsync: this);
    scrollController = ScrollController()..addListener(_onScrollLegacy);
    searchController.addListener(
      () => searchQuery.value = searchController.text,
    );

    for (int i = 0; i < 3; i++) {
      scrollControllers[i].addListener(() => _onScroll(i));
    }

    tabController.addListener(() {
      if (!tabController.indexIsChanging) {
        currentTabIndex.value = tabController.index;
        _loadTab(tabController.index);
      }
    });

    _loadTab(0); // load live tab immediately
    _fetchRegions();
  }

  @override
  void onClose() {
    tabController.dispose();
    scrollController.dispose();
    searchController.dispose();
    for (final sc in scrollControllers) sc.dispose();
    super.onClose();
  }

  void _onScrollLegacy() {}

  void _onScroll(int i) {
    final sc = scrollControllers[i];
    if (!sc.hasClients) return;
    final nearBottom = sc.position.pixels >= sc.position.maxScrollExtent - 200;
    if (nearBottom &&
        !_tabLoadingMore[i].value &&
        _tabPagination[i].value.hasNext) {
      _loadMoreTab(i);
    }
  }

  Future<void> _loadTab(int i, {bool refresh = false}) async {
    if (_tabInitialized[i] && !refresh) return;
    _tabLoading[i].value = true;
    _tabError[i].value = '';
    _tabPage[i] = 1;
    try {
      final userId =
          await SecureStorageService.to.read(StorageKeys.userId) ?? '';
      final result = await _service.fetchVehicles(
        userId: userId,
        auctionType: _tabTypes[i],
        vehicleType: vehicleType,
        regionId: selectedRegion.value?.regionId ?? '',
        stateId: selectedState.value?.stateId ?? '',
        page: 1,
      );
      _tabVehicles[i].assignAll(result.vehicles);
      _tabPagination[i].value = result.pagination;
      _tabInitialized[i] = true;
      // sync legacy fields for tab 0
      if (i == 0) {
        vehicles.assignAll(result.vehicles);
        pagination.value = result.pagination;
      }
    } catch (e, st) {
      debugPrint('❌ [VehicleListing._loadTab($i)] $e\n$st');
      _tabError[i].value = 'Failed to load vehicles. Please try again.';
    } finally {
      _tabLoading[i].value = false;
      isLoading.value = false;
    }
  }

  Future<void> _loadMoreTab(int i) async {
    if (!_tabPagination[i].value.hasNext) return;
    _tabLoadingMore[i].value = true;
    try {
      final userId =
          await SecureStorageService.to.read(StorageKeys.userId) ?? '';
      final nextPage = _tabPage[i] + 1;
      final result = await _service.fetchVehicles(
        userId: userId,
        auctionType: _tabTypes[i],
        vehicleType: vehicleType,
        regionId: selectedRegion.value?.regionId ?? '',
        stateId: selectedState.value?.stateId ?? '',
        page: nextPage,
      );
      _tabVehicles[i].addAll(result.vehicles);
      _tabPagination[i].value = result.pagination;
      _tabPage[i] = nextPage;
    } catch (_) {
    } finally {
      _tabLoadingMore[i].value = false;
    }
  }

  Future<void> refresh() => _reloadAll();

  Future<void> silentRefresh() => _loadTab(tabController.index, refresh: true);

  Future<void> _reloadAll() async {
    for (int i = 0; i < 3; i++) {
      _tabInitialized[i] = false;
    }
    await _loadTab(tabController.index, refresh: true);
  }

  Future<void> _silentRefresh() => silentRefresh();

  // ─── Filter helpers ───────────────────────────────────────────

  void backupCurrentFilters() {
    _backupRegion = selectedRegion.value;
    _backupState = selectedState.value;
  }

  void restoreFilters() {
    selectedRegion.value = _backupRegion;
    selectedState.value = _backupState;
  }

  void applyFilters() {
    for (int i = 0; i < 3; i++) _tabInitialized[i] = false;
    _loadTab(tabController.index, refresh: true);
  }

  void resetFiltersWithoutReload() {
    selectedRegion.value = null;
    selectedState.value = null;
    selectedState.value = null;
  }

  void resetFilters() {
    resetFiltersWithoutReload();
    for (int i = 0; i < 3; i++) _tabInitialized[i] = false;
    _loadTab(tabController.index, refresh: true);
  }

  Future<void> _fetchRegions() async {
    isLoadingRegions.value = true;
    try {
      final network = Get.find<NetworkService>();
      final response = await network.get(ApiEndpoints.regions);
      final raw = response.data;
      final data = raw is Map ? raw['data'] : null;
      List<dynamic> list = [];
      if (data is Map<String, dynamic>) {
        list =
            data['regions'] as List<dynamic>? ??
            data['data'] as List<dynamic>? ??
            [];
      } else if (data is List) {
        list = data;
      }
      regions.value = list
          .map(
            (e) => RegionEntity(
              regionId: e['region_id']?.toString() ?? '',
              name: e['name']?.toString() ?? '',
            ),
          )
          .toList();
    } catch (_) {
    } finally {
      isLoadingRegions.value = false;
    }
  }

  Future<void> loadAllStates() async {
    if (statesByRegion.isNotEmpty) return;
    isLoadingStatesByRegion.value = true;
    try {
      final network = Get.find<NetworkService>();
      final response = await network.get(ApiEndpoints.states);
      final raw = response.data;
      final data = raw is Map ? raw['data'] : null;
      List<dynamic> list = [];
      if (data is Map<String, dynamic>) {
        list = data['states'] as List<dynamic>? ?? [];
      } else if (data is List) {
        list = data;
      }
      statesByRegion.value = list
          .map(
            (e) => StateByRegionEntity(
              stateId: e['state_id']?.toString() ?? '',
              stateName: e['state_name']?.toString() ?? '',
              regionId: e['region_id']?.toString() ?? '',
            ),
          )
          .toList();
    } catch (_) {
    } finally {
      isLoadingStatesByRegion.value = false;
    }
  }

  void onRegionSelected(RegionEntity? region) {
    selectedRegion.value = region;
    selectedState.value = null;
    statesByRegion.clear();
    if (region != null) _fetchStatesByRegion(region.regionId);
  }

  Future<void> _fetchStatesByRegion(String regionId) async {
    isLoadingStatesByRegion.value = true;
    try {
      final network = Get.find<NetworkService>();
      final response = await network.get(ApiEndpoints.statesByRegion(regionId));
      final data = response.data['data'];
      List<dynamic> list = data is Map
          ? data['states'] as List<dynamic>? ?? []
          : data is List
          ? data
          : [];
      statesByRegion.value = list
          .map(
            (e) => StateByRegionEntity(
              stateId: e['state_id'] as String? ?? '',
              stateName: e['state_name'] as String? ?? '',
              regionId: e['region_id'] as String? ?? '',
            ),
          )
          .toList();
    } catch (_) {
    } finally {
      isLoadingStatesByRegion.value = false;
    }
  }

  // ─── Search / filter ─────────────────────────────────────────

  List<VehicleListing> get filteredVehicles {
    final q = searchQuery.value.trim().toLowerCase();
    final tab = tabController.index.clamp(0, 2);
    final list = _tabVehicles[tab];
    if (q.isEmpty) return list;
    return list
        .where(
          (v) =>
              v.displayTitle.toLowerCase().contains(q) ||
              v.registrationNo.toLowerCase().contains(q) ||
              v.vehicleId.toLowerCase().contains(q),
        )
        .toList();
  }

  VehicleListing? get currentVehicle {
    final list = filteredVehicles;
    if (list.isEmpty) return null;
    return list[currentIndex.value.clamp(0, list.length - 1)];
  }

  void goNext() {
    final tab = tabController.index.clamp(0, 2);
    final list = _tabVehicles[tab];
    if (currentIndex.value < list.length - 1) {
      currentIndex.value++;
    }
  }

  void goPrev() {
    if (currentIndex.value > 0) currentIndex.value--;
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
