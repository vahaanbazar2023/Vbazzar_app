import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
      Get.back(); // close the bid sheet first
      await Future.delayed(const Duration(milliseconds: 300));
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
      Get.back(); // close the bid sheet first
      await Future.delayed(const Duration(milliseconds: 300));
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
      // Success — refresh vehicles list
      _load();
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
}
