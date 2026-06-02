import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/network_service.dart';
import '../../../core/network/endpoints/api_endpoints.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/storage/storage_keys.dart';
import '../domain/entities/buy_vehicle_entity.dart';
import '../domain/entities/subscribed_vehicle_entity.dart';
import '../domain/entities/vehicle_brand_entity.dart';
import '../domain/entities/vehicle_category_entity.dart';
import '../domain/entities/vehicle_tire_entity.dart';
import '../domain/repositories/buy_sell_repository.dart';

/// Controller managing the Buy tab: category-driven vehicle listing,
/// dynamic filters, search, pagination, and subscribed vehicles.
class BuyVehicleController extends GetxController {
  final BuySellRepository repository;

  BuyVehicleController({required this.repository});

  // ─── User ID ─────────────────────────────────────────────────

  Future<String> get _userId async =>
      await SecureStorageService.to.read(StorageKeys.userId) ?? '';

  // ─── Category State (Landing Page) ───────────────────────────

  final categories = <VehicleCategoryEntity>[].obs;
  final isLoadingCategories = false.obs;
  final hasErrorCategories = false.obs;
  final errorMessageCategories = ''.obs;
  final selectedCategory = Rxn<VehicleCategoryEntity>();

  // ─── Dynamic Filters (from vehicle-category-filters API) ─────

  final dynamicFilterOptions = <String, dynamic>{}.obs;
  final isLoadingFilters = false.obs;

  // Currently applied filter values
  final appliedFilters = <String, dynamic>{}.obs;

  // ─── Buy Vehicle List (from vehicle-category-list-by-filters) ─

  final buyVehicles = <BuyVehicleEntity>[].obs;
  final isLoadingBuyVehicles = false.obs;
  final isLoadingMoreBuyVehicles = false.obs;
  final hasErrorBuyVehicles = false.obs;
  final errorMessageBuyVehicles = ''.obs;
  final buyPage = 1.obs;
  final buyTotalPages = 1.obs;
  final buyTotalCount = 0.obs;
  final hasMoreBuyVehicles = true.obs;

  // ─── Subscribed Vehicles ─────────────────────────────────────

  final subscribedVehicles = <SubscribedVehicleEntity>[].obs;
  final isLoadingSubscribed = false.obs;
  final isLoadingMoreSubscribed = false.obs;
  final hasErrorSubscribed = false.obs;
  final errorMessageSubscribed = ''.obs;
  final subscribedPage = 1.obs;
  final subscribedTotalPages = 1.obs;
  final hasMoreSubscribed = true.obs;

  // ─── My Vehicles (Sell vehicles by user) ─────────────────────

  final myVehicles = <dynamic>[].obs;
  final isLoadingMyVehicles = false.obs;
  final hasErrorMyVehicles = false.obs;
  final errorMessageMyVehicles = ''.obs;

  // ─── Search ──────────────────────────────────────────────────

  final searchQuery = ''.obs;
  final searchController = TextEditingController();

  // ─── Tab State ───────────────────────────────────────────────

  final selectedTabIndex = 0.obs; // 0=All, 1=My Vehicles, 2=Subscribed

  // ─── Supporting Data ─────────────────────────────────────────

  final brands = <VehicleBrandEntity>[].obs;
  final tyres = <VehicleTireEntity>[].obs;
  final filterStates = <Map<String, String>>[].obs; // [{state_id, state_name}]
  final isLoadingFilterStates = false.obs;

  // ─── Scroll Controller ──────────────────────────────────────

  final scrollController = ScrollController();

  // ─── Debounce Timer ──────────────────────────────────────────

  Timer? _searchDebounce;

  // ─── Constants ───────────────────────────────────────────────

  static const int _limit = 10;

  // ─── Lifecycle ───────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(_onSearchChanged);
    fetchCategories();
    fetchSubscribedVehicles();
  }

  @override
  void onClose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    scrollController.dispose();
    _searchDebounce?.cancel();
    super.onClose();
  }

  // ─── Search Listener ─────────────────────────────────────────

  void _onSearchChanged() {
    searchQuery.value = searchController.text.trim();
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      if (selectedCategory.value != null) {
        fetchVehiclesByCategoryFilters(isRefresh: true);
      }
    });
  }

  // ─── Categories (Landing Page) ────────────────────────────────

  Future<void> fetchCategories() async {
    isLoadingCategories.value = true;
    hasErrorCategories.value = false;
    errorMessageCategories.value = '';
    try {
      final result = await repository.getVehicleCategories();
      print('🔵 [FETCH CATEGORIES] Fetched ${result.length} categories');
      print(
        '🔵 [FETCH CATEGORIES] Categories: ${result.map((c) => c.categoryName).join(', ')}',
      );
      categories.assignAll(result);
      if (result.isEmpty) {
        hasErrorCategories.value = true;
        errorMessageCategories.value = 'No categories found';
      }
    } catch (e) {
      debugPrint('🔴 [CATEGORIES ERROR] $e');
      hasErrorCategories.value = true;
      errorMessageCategories.value = 'Failed to load categories';
    } finally {
      isLoadingCategories.value = false;
    }
  }

  // ─── Select Category → Load Dynamic Filters ──────────────────

  Future<void> selectCategory(VehicleCategoryEntity category) async {
    selectedCategory.value = category;
    appliedFilters.clear();
    searchController.clear();
    searchQuery.value = '';
    buyPage.value = 1;
    hasMoreBuyVehicles.value = true;
    buyVehicles.clear();

    await Future.wait([
      fetchDynamicFilters(category.categoryCode),
      fetchVehiclesByCategoryFilters(isRefresh: true),
    ]);
  }

  void clearCategorySelection() {
    selectedCategory.value = null;
    dynamicFilterOptions.clear();
    appliedFilters.clear();
    searchController.clear();
    searchQuery.value = '';
    buyVehicles.clear();
  }

  // ─── Dynamic Filters (vehicle-category-filters API) ──────────

  Future<void> fetchDynamicFilters(String categoryCode) async {
    isLoadingFilters.value = true;
    try {
      final uid = await _userId;
      final data = await repository.getCategoryFilters(
        categoryCode: categoryCode,
        userId: uid,
      );

      final filterOptions = data['filter_options'];
      if (filterOptions is Map<String, dynamic>) {
        dynamicFilterOptions.assignAll(filterOptions);

        // Load master data for master-source filters in parallel
        final futures = <Future>[];
        if (filterOptions.containsKey('Brand')) {
          futures.add(_loadFilterBrands(categoryCode));
        }
        if (filterOptions.containsKey('State')) {
          futures.add(_loadFilterStates());
        }
        if (futures.isNotEmpty) await Future.wait(futures);
      } else {
        dynamicFilterOptions.clear();
      }
    } catch (e) {
      debugPrint('🔴 [DYNAMIC FILTERS ERROR] $e');
      dynamicFilterOptions.clear();
    } finally {
      isLoadingFilters.value = false;
    }
  }

  Future<void> _loadFilterBrands(String categoryCode) async {
    try {
      final result = await repository.getVehicleBrands(
        categoryCode: categoryCode,
      );
      brands.assignAll(result);
    } catch (e) {
      debugPrint('🔴 [FILTER BRANDS ERROR] $e');
    }
  }

  Future<void> _loadFilterStates() async {
    isLoadingFilterStates.value = true;
    try {
      final response = await NetworkService.to.get(ApiEndpoints.states);
      if (response.statusCode == 200) {
        final raw = response.data;
        final List<dynamic> list = (raw is Map)
            ? ((raw['data']?['states'] ?? raw['data'] ?? []) as List)
            : (raw is List ? raw : []);
        filterStates.assignAll(
          list
              .map(
                (e) => {
                  'state_id': e['state_id']?.toString() ?? '',
                  'state_name': e['state_name']?.toString() ?? '',
                },
              )
              .toList(),
        );
      }
    } catch (e) {
      debugPrint('🔴 [FILTER STATES ERROR] $e');
    } finally {
      isLoadingFilterStates.value = false;
    }
  }

  // ─── Apply / Clear Filters ───────────────────────────────────

  void applyFilter(String key, dynamic value) {
    if (value == null || value.toString().isEmpty) {
      appliedFilters.remove(key);
    } else {
      appliedFilters[key] = value;
    }
  }

  void applyFiltersAndFetch() {
    buyPage.value = 1;
    hasMoreBuyVehicles.value = true;
    buyVehicles.clear();
    fetchVehiclesByCategoryFilters(isRefresh: true);
  }

  void clearAllFilters() {
    appliedFilters.clear();
    searchController.clear();
    searchQuery.value = '';
    buyPage.value = 1;
    hasMoreBuyVehicles.value = true;
    buyVehicles.clear();
    fetchVehiclesByCategoryFilters(isRefresh: true);
  }

  bool get hasActiveFilters =>
      appliedFilters.isNotEmpty || searchQuery.value.isNotEmpty;

  int get activeFilterCount {
    int count = appliedFilters.length;
    if (searchQuery.value.isNotEmpty) count++;
    return count;
  }

  // ─── Vehicle Listing (vehicle-category-list-by-filters API) ──

  Future<void> fetchVehiclesByCategoryFilters({bool isRefresh = false}) async {
    if (selectedCategory.value == null) return;

    if (isLoadingBuyVehicles.value || isLoadingMoreBuyVehicles.value) return;

    if (isRefresh) {
      buyPage.value = 1;
      hasMoreBuyVehicles.value = true;
      buyVehicles.clear();
    }

    if (!hasMoreBuyVehicles.value && !isRefresh) return;

    final isFirstPage = buyPage.value == 1;

    if (isFirstPage) {
      isLoadingBuyVehicles.value = true;
      hasErrorBuyVehicles.value = false;
      errorMessageBuyVehicles.value = '';
    } else {
      isLoadingMoreBuyVehicles.value = true;
    }

    try {
      final uid = await _userId;

      // Build filter map including search
      final filters = <String, dynamic>{...appliedFilters};

      final result = await repository.listVehiclesByCategoryFilters(
        userId: uid,
        categoryCode: selectedCategory.value!.categoryCode,
        limit: _limit,
        page: buyPage.value,
        filters: filters.isNotEmpty ? filters : null,
      );

      if (isFirstPage) {
        buyVehicles.assignAll(result.vehicles);
      } else {
        buyVehicles.addAll(result.vehicles);
      }

      buyTotalPages.value = result.totalPages;
      buyTotalCount.value = result.totalCount;
      hasMoreBuyVehicles.value = result.hasMore;
      buyPage.value = result.currentPage + 1;
    } catch (e) {
      hasErrorBuyVehicles.value = true;
      errorMessageBuyVehicles.value = 'Failed to load vehicles';
      debugPrint('🔴 [BUY VEHICLES ERROR] $e');
    } finally {
      isLoadingBuyVehicles.value = false;
      isLoadingMoreBuyVehicles.value = false;
    }
  }

  Future<void> loadMoreBuyVehicles() async {
    await fetchVehiclesByCategoryFilters();
  }

  Future<void> refreshBuyVehiclesList() async {
    await fetchVehiclesByCategoryFilters(isRefresh: true);
  }

  // ─── Subscribed Vehicles ─────────────────────────────────────

  Future<void> fetchSubscribedVehicles({bool isRefresh = false}) async {
    if (isLoadingSubscribed.value || isLoadingMoreSubscribed.value) return;

    if (isRefresh) {
      subscribedPage.value = 1;
      hasMoreSubscribed.value = true;
      subscribedVehicles.clear();
    }

    if (!hasMoreSubscribed.value && !isRefresh) return;

    final isFirstPage = subscribedPage.value == 1;

    if (isFirstPage) {
      isLoadingSubscribed.value = true;
      hasErrorSubscribed.value = false;
      errorMessageSubscribed.value = '';
    } else {
      isLoadingMoreSubscribed.value = true;
    }

    try {
      final uid = await _userId;
      final result = await repository.listSubscribedVehicles(
        userId: uid,
        limit: _limit,
        page: subscribedPage.value,
      );

      if (isFirstPage) {
        subscribedVehicles.assignAll(result.vehicles);
      } else {
        subscribedVehicles.addAll(result.vehicles);
      }

      subscribedTotalPages.value = result.totalPages;
      hasMoreSubscribed.value = subscribedPage.value < result.totalPages;
      subscribedPage.value += 1;
    } catch (e) {
      hasErrorSubscribed.value = true;
      errorMessageSubscribed.value = 'Failed to load subscribed vehicles';
      debugPrint('🔴 [SUBSCRIBED VEHICLES ERROR] $e');
    } finally {
      isLoadingSubscribed.value = false;
      isLoadingMoreSubscribed.value = false;
    }
  }

  Future<void> loadMoreSubscribedVehicles() async {
    await fetchSubscribedVehicles();
  }

  Future<void> refreshSubscribedVehicles() async {
    await fetchSubscribedVehicles(isRefresh: true);
  }

  // ─── Tab Change ──────────────────────────────────────────────

  void changeTab(int index) {
    selectedTabIndex.value = index;
    if (index == 2 && subscribedVehicles.isEmpty) {
      fetchSubscribedVehicles(isRefresh: true);
    }
  }

  // ─── Helpers ─────────────────────────────────────────────────

  BuyVehicleEntity? getBuyVehicleById(String id) {
    try {
      return buyVehicles.firstWhere((v) => v.sbVehicleId == id);
    } catch (_) {
      return null;
    }
  }

  SubscribedVehicleEntity? getSubscribedVehicleById(String id) {
    try {
      return subscribedVehicles.firstWhere((v) => v.sbVehicleId == id);
    } catch (_) {
      return null;
    }
  }

  /// Get display label for a filter key
  String getFilterDisplayLabel(String key, dynamic value) {
    final filterDef = dynamicFilterOptions[key];
    if (filterDef is Map<String, dynamic>) {
      final options = filterDef['options'] as List<dynamic>?;
      if (options != null) {
        for (final opt in options) {
          if (opt is Map<String, dynamic> && opt['value'] == value) {
            return opt['label']?.toString() ?? value.toString();
          }
        }
      }
    }
    return value.toString();
  }
}
