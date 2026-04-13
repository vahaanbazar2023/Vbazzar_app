import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/storage/storage_keys.dart';
import '../models/auction_listing.dart';
import '../models/auction_pagination.dart';
import '../models/vehicle_listing.dart';
import '../services/vehicle_listing_service.dart';

class VehicleListingController extends GetxController {
  final VehicleListingService _service;
  final AuctionListing auction;

  VehicleListingController({
    required this.auction,
    VehicleListingService? service,
  }) : _service = service ?? VehicleListingService();

  final vehicles = <VehicleListing>[].obs;
  final pagination = Rx<AuctionPagination>(AuctionPagination.empty());
  final isLoading = true.obs;
  final isLoadingMore = false.obs;
  final errorMessage = ''.obs;
  final searchQuery = ''.obs;
  final currentIndex = 0.obs;

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
    } catch (e) {
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
}
