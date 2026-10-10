import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/storage/secure_storage_service.dart';
import '../../../core/storage/storage_keys.dart';
import '../models/vehicle_listing.dart';
import '../models/auction_pagination.dart';
import '../services/vehicle_listing_service.dart';
import '../../../core/extensions/context_extensions.dart';

class WishlistController extends GetxController {
  final VehicleListingService _service = Get.find<VehicleListingService>();

  final RxBool isLoading = true.obs;
  final RxBool isLoadingMore = false.obs;
  final Rxn<String> errorMessage = Rxn<String>();
  final RxList<VehicleListing> vehicles = <VehicleListing>[].obs;
  final Rx<AuctionPagination> pagination = AuctionPagination.empty().obs;

  late final ScrollController scrollController;
  int _currentPage = 1;

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController();
    scrollController.addListener(_onScroll);
    _loadWishlist();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent * 0.8 &&
        !isLoadingMore.value &&
        pagination.value.hasNext) {
      _loadMore();
    }
  }

  Future<void> _loadWishlist() async {
    isLoading.value = true;
    errorMessage.value = null;
    _currentPage = 1;

    try {
      final userId =
          await SecureStorageService.to.read(StorageKeys.userId) ?? '';

      final result = await _service.fetchWishlistedVehicles(
        userId: userId,
        page: _currentPage,
      );

      vehicles.assignAll(result.vehicles);
      pagination.value = result.pagination;
    } catch (e) {
      debugPrint('❌ [Wishlist._loadWishlist] $e');
      errorMessage.value = appL10n.aucFailedLoadWishlist;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadMore() async {
    if (!pagination.value.hasNext || isLoadingMore.value) return;

    isLoadingMore.value = true;
    _currentPage++;

    try {
      final userId =
          await SecureStorageService.to.read(StorageKeys.userId) ?? '';

      final result = await _service.fetchWishlistedVehicles(
        userId: userId,
        page: _currentPage,
      );

      vehicles.addAll(result.vehicles);
      pagination.value = result.pagination;
    } catch (e) {
      debugPrint('❌ [Wishlist._loadMore] $e');
      _currentPage--; // Rollback on error
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> refresh() async {
    await _loadWishlist();
  }
}
