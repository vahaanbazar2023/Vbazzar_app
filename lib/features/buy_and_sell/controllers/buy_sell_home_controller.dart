import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../domain/entities/vehicle_category_entity.dart';
import '../domain/entities/filter_option_entity.dart';
import '../data/repositories/buy_sell_repository_impl.dart';

class BuySellHomeController extends GetxController {
  final BuySellRepositoryImpl _repo = BuySellRepositoryImpl();

  // ── Tab State ──────────────────────────────────────────────
  final currentTab = 0.obs; // 0=All, 1=My Vehicles, 2=Subscribed

  // ── Categories ─────────────────────────────────────────────
  final categories = <VehicleCategoryEntity>[].obs;
  final isLoadingCategories = true.obs;
  final selectedCategory = Rxn<VehicleCategoryEntity>();

  // ── Search ─────────────────────────────────────────────────
  final searchController = TextEditingController();
  final searchQuery = ''.obs;

  // ── Vehicles ───────────────────────────────────────────────
  final vehicles = <Map<String, dynamic>>[].obs;
  final isLoadingVehicles = false.obs;
  final hasMore = true.obs;
  final currentPage = 1;
  final _limit = 10;

  // ── Dynamic Filters ────────────────────────────────────────
  final filterConfigs = <String, FilterConfigEntity>{}.obs;
  final selectedFilters = <String, dynamic>{}.obs;
  final isLoadingFilters = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  // ── Load Categories ────────────────────────────────────────
  Future<void> loadCategories() async {
    isLoadingCategories.value = true;
    try {
      final result = await _repo.getVehicleCategories();
      categories.assignAll(result);
    } catch (e) {
      print('❌ loadCategories error: $e');
    } finally {
      isLoadingCategories.value = false;
    }
  }

  // ── Select Category ────────────────────────────────────────
  void selectCategory(VehicleCategoryEntity category) {
    selectedCategory.value = category;
    selectedFilters.clear();
    currentPage_internal = 1;
    vehicles.clear();
    hasMore.value = true;
    loadFilters(category.categoryCode);
    loadVehicles();
  }

  // ── Load Dynamic Filters ───────────────────────────────────
  Future<void> loadFilters(String categoryCode) async {
    isLoadingFilters.value = true;
    try {
      final result = await _repo.getVehicleCategoryFilters(
        categoryCode: categoryCode,
      );
      filterConfigs.assignAll(result);
    } catch (e) {
      print('❌ loadFilters error: $e');
    } finally {
      isLoadingFilters.value = false;
    }
  }

  // ── Load Vehicles ──────────────────────────────────────────
  int currentPage_internal = 1;

  Future<void> loadVehicles({bool loadMore = false}) async {
    if (selectedCategory.value == null) return;
    if (isLoadingVehicles.value) return;
    if (loadMore && !hasMore.value) return;

    if (!loadMore) {
      currentPage_internal = 1;
      vehicles.clear();
      hasMore.value = true;
    }

    isLoadingVehicles.value = true;
    try {
      final result = await _repo.getVehiclesByFilters(
        categoryCode: selectedCategory.value!.categoryCode,
        filters: selectedFilters.isNotEmpty ? Map.from(selectedFilters) : null,
        page: currentPage_internal,
        limit: _limit,
      );

      final List<dynamic> vehicleList = result['vehicles'] ?? result['data'] ?? [];
      final newVehicles = vehicleList
          .map((v) => v is Map<String, dynamic> ? v : <String, dynamic>{})
          .toList();

      if (loadMore) {
        vehicles.addAll(newVehicles);
      } else {
        vehicles.assignAll(newVehicles);
      }

      if (newVehicles.length < _limit) {
        hasMore.value = false;
      } else {
        currentPage_internal++;
      }
    } catch (e) {
      print('❌ loadVehicles error: $e');
    } finally {
      isLoadingVehicles.value = false;
    }
  }

  // ── Apply Filter ───────────────────────────────────────────
  void applyFilter(String filterName, dynamic value) {
    if (value == null || value.toString().isEmpty) {
      selectedFilters.remove(filterName);
    } else {
      selectedFilters[filterName] = value;
    }
    loadVehicles();
  }

  // ── Clear All Filters ──────────────────────────────────────
  void clearFilters() {
    selectedFilters.clear();
    if (selectedCategory.value != null) {
      loadVehicles();
    }
  }

  // ── Switch Tab ─────────────────────────────────────────────
  void switchTab(int index) {
    currentTab.value = index;
  }

  // ── Search ─────────────────────────────────────────────────
  void onSearchChanged(String query) {
    searchQuery.value = query;
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }

  // ── Get vehicle image URL ──────────────────────────────────
  String getVehicleImage(Map<String, dynamic> vehicle) {
    return vehicle['image_url']?.toString() ??
        vehicle['primary_image']?.toString() ??
        '';
  }

  // ── Get vehicle display name ───────────────────────────────
  String getVehicleName(Map<String, dynamic> vehicle) {
    final brand = vehicle['brand_name']?.toString() ?? '';
    final model = vehicle['model']?.toString() ?? vehicle['model_name']?.toString() ?? '';
    final year = vehicle['manufacturing_year']?.toString() ?? '';
    return [brand, model, year].where((s) => s.isNotEmpty).join(' ');
  }

  // ── Get category display icon ──────────────────────────────
  IconData getCategoryIcon(String code) {
    switch (code.toUpperCase()) {
      case 'CARS':
        return Icons.directions_car;
      case 'TRUCKS':
        return Icons.local_shipping;
      case 'BIKES':
      case 'MOTORCYCLES':
        return Icons.two_wheeler;
      case 'BUS':
        return Icons.directions_bus;
      case 'TRACTOR':
        return Icons.agriculture;
      case 'JCB':
      case 'CE':
        return Icons.construction;
      default:
        return Icons.directions_car;
    }
  }
}