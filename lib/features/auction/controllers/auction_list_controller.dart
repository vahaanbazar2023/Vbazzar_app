import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import '../../../core/network/endpoints/api_endpoints.dart';
import '../../../core/network/network_service.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/storage/storage_keys.dart';
import '../domain/entities/auction_entity.dart';
import '../models/auction_listing.dart';
import '../models/auction_pagination.dart';
import '../services/auction_service.dart';

/// Controller for the main auction list screen with filtering support.
///
/// Manages auctions across 3 tabs (Live, Closing Today, Upcoming) and
/// provides filter state for Category, Vehicle Type, Region, and State.
class AuctionListController extends GetxController
    with GetTickerProviderStateMixin {
  final AuctionService _service;

  AuctionListController({AuctionService? service})
      : _service = service ?? AuctionService();

  // ─── Tab state ────────────────────────────────────────────────

  late final TabController tabController;

  static const tabTypes = [
    'live_auctions',
    'closing_today',
    'upcoming_auctions',
  ];

  static const tabLabels = ['Live', 'Closing Today', 'Upcoming'];

  final _tabs = List.generate(3, (_) => _TabState());

  RxList<AuctionListing> auctions(int i) => _tabs[i].auctions;
  Rx<AuctionPagination> pagination(int i) => _tabs[i].pagination;
  RxBool isLoading(int i) => _tabs[i].isLoading;
  RxBool isLoadingMore(int i) => _tabs[i].isLoadingMore;
  RxString errorMessage(int i) => _tabs[i].errorMessage;

  final scrollControllers = List.generate(3, (_) => ScrollController());

  // ─── Filter state ─────────────────────────────────────────────

  final selectedCategory = RxnString();
  final selectedVehicleType = RxnString();
  final selectedRegion = Rxn<RegionEntity>();
  final selectedState = Rxn<StateByRegionEntity>();

  final regions = <RegionEntity>[].obs;
  final statesByRegion = <StateByRegionEntity>[].obs;

  final isLoadingRegions = false.obs;
  final isLoadingStatesByRegion = false.obs;

  // Backup for cancel support
  String? _backupCategory;
  String? _backupVehicleType;
  RegionEntity? _backupRegion;
  StateByRegionEntity? _backupState;

  bool get hasActiveFilters =>
      selectedCategory.value != null ||
      selectedVehicleType.value != null ||
      selectedRegion.value != null ||
      selectedState.value != null;

  // ─── Lifecycle ────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 3, vsync: this);

    _loadTab(tabController.index);
    tabController.addListener(() {
      if (!tabController.indexIsChanging) {
        _loadTab(tabController.index);
      }
    });

    for (int i = 0; i < 3; i++) {
      scrollControllers[i].addListener(() => _onScroll(i));
    }

    _fetchRegions();
  }

  @override
  void onClose() {
    tabController.dispose();
    for (final sc in scrollControllers) {
      sc.dispose();
    }
    super.onClose();
  }

  // ─── Data fetching ────────────────────────────────────────────

  Future<void> _loadTab(int tabIndex, {bool refresh = false}) async {
    final tab = _tabs[tabIndex];
    if (tab.initialized && !refresh) return;

    tab.isLoading.value = true;
    tab.errorMessage.value = '';
    tab.currentPage = 1;

    try {
      final userId =
          await SecureStorageService.to.read(StorageKeys.userId) ?? '';
      final result = await _service.fetchListings(
        userId: userId,
        auctionType: tabTypes[tabIndex],
        category: selectedCategory.value ?? '',
        vehicleType: selectedVehicleType.value ?? '',
        regionId: selectedRegion.value?.regionId ?? '',
        stateId: selectedState.value?.stateId ?? '',
        page: 1,
      );
      tab.auctions.assignAll(result.auctions);
      tab.pagination.value = result.pagination;
      tab.initialized = true;
    } catch (e) {
      tab.errorMessage.value = 'Failed to load auctions. Please try again.';
    } finally {
      tab.isLoading.value = false;
    }
  }

  Future<void> _loadMore(int tabIndex) async {
    final tab = _tabs[tabIndex];
    if (!tab.pagination.value.hasNext) return;
    tab.isLoadingMore.value = true;
    try {
      final userId =
          await SecureStorageService.to.read(StorageKeys.userId) ?? '';
      final nextPage = tab.currentPage + 1;
      final result = await _service.fetchListings(
        userId: userId,
        auctionType: tabTypes[tabIndex],
        category: selectedCategory.value ?? '',
        vehicleType: selectedVehicleType.value ?? '',
        regionId: selectedRegion.value?.regionId ?? '',
        stateId: selectedState.value?.stateId ?? '',
        page: nextPage,
      );
      tab.auctions.addAll(result.auctions);
      tab.pagination.value = result.pagination;
      tab.currentPage = nextPage;
    } catch (_) {
      // Silently ignore load-more failures
    } finally {
      tab.isLoadingMore.value = false;
    }
  }

  void _onScroll(int tabIndex) {
    final sc = scrollControllers[tabIndex];
    if (!sc.hasClients) return;
    final nearBottom =
        sc.position.pixels >= sc.position.maxScrollExtent - 200;
    if (nearBottom &&
        !_tabs[tabIndex].isLoadingMore.value &&
        _tabs[tabIndex].pagination.value.hasNext) {
      _loadMore(tabIndex);
    }
  }

  Future<void> reloadTab(int tabIndex) => _loadTab(tabIndex, refresh: true);

  Future<void> reloadCurrentTab() => _loadTab(tabController.index, refresh: true);

  // ─── Regions & States ─────────────────────────────────────────

  Future<void> _fetchRegions() async {
    isLoadingRegions.value = true;
    try {
      final NetworkService network = Get.find<NetworkService>();
      final response = await network.get(ApiEndpoints.regions);
      final data = response.data['data'];

      List<dynamic> regionsList = [];
      if (data is Map<String, dynamic>) {
        regionsList = data['regions'] as List<dynamic>? ?? [];
      } else if (data is List) {
        regionsList = data;
      }

      regions.value = regionsList
          .map((e) => RegionEntity(
                regionId: e['region_id'] as String? ?? '',
                name: e['name'] as String? ?? '',
              ))
          .toList();
    } catch (_) {
      // Silently handle
    } finally {
      isLoadingRegions.value = false;
    }
  }

  Future<void> _fetchStatesByRegion(String regionId) async {
    isLoadingStatesByRegion.value = true;
    statesByRegion.clear();
    selectedState.value = null;
    try {
      final NetworkService network = Get.find<NetworkService>();
      final endpoint = ApiEndpoints.statesByRegion(regionId);
      final response = await network.get(endpoint);
      final data = response.data['data'];

      List<dynamic> statesList = [];
      if (data is Map<String, dynamic>) {
        statesList = data['states'] as List<dynamic>? ?? [];
      } else if (data is List) {
        statesList = data;
      }

      statesByRegion.value = statesList
          .map((e) => StateByRegionEntity(
                stateId: e['state_id'] as String? ?? '',
                stateName: e['state_name'] as String? ?? '',
                regionId: e['region_id'] as String? ?? '',
              ))
          .toList();
    } catch (_) {
      // Silently handle
    } finally {
      isLoadingStatesByRegion.value = false;
    }
  }

  // ─── Filter callbacks ─────────────────────────────────────────

  void onCategoryChanged(String? value) {
    selectedCategory.value = value;
  }

  void onVehicleTypeChanged(String? value) {
    selectedVehicleType.value = value;
  }

  void onRegionChanged(RegionEntity? value) {
    selectedRegion.value = value;
    if (value != null) {
      _fetchStatesByRegion(value.regionId);
    } else {
      statesByRegion.clear();
      selectedState.value = null;
    }
  }

  void onStateChanged(StateByRegionEntity? value) {
    selectedState.value = value;
  }

  // ─── Filter actions ───────────────────────────────────────────

  void backupCurrentFilters() {
    _backupCategory = selectedCategory.value;
    _backupVehicleType = selectedVehicleType.value;
    _backupRegion = selectedRegion.value;
    _backupState = selectedState.value;
  }

  void resetFiltersWithoutReload() {
    selectedCategory.value = null;
    selectedVehicleType.value = null;
    selectedRegion.value = null;
    selectedState.value = null;
    statesByRegion.clear();
  }

  void resetFilters() {
    resetFiltersWithoutReload();
    _refreshAllTabs();
  }

  void applyFilters() {
    _refreshAllTabs();
  }

  void _refreshAllTabs() {
    for (int i = 0; i < 3; i++) {
      _tabs[i].initialized = false;
    }
    _loadTab(tabController.index, refresh: true);
  }
}

// ─── Internal tab state ─────────────────────────────────────────

class _TabState {
  final auctions = <AuctionListing>[].obs;
  final pagination = Rx<AuctionPagination>(AuctionPagination.empty());
  final isLoading = true.obs;
  final isLoadingMore = false.obs;
  final errorMessage = ''.obs;
  int currentPage = 1;
  bool initialized = false;
}