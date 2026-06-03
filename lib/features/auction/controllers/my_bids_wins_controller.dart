import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/network_service.dart';
import '../../../core/network/endpoints/api_endpoints.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/storage/storage_keys.dart';
import '../../../core/design_system/molecules/custom_snackbar.dart';
import '../models/my_bids_wins_models.dart';
import '../domain/entities/bid_entity.dart';

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

  /// Place a bid — called from the detail screen's "Bid Now" bottom bar.
  Future<bool> placeBid({
    required String vehicleId,
    required String auctionId,
    required int bidAmount,
  }) async {
    if (isPlacingBid.value) return false;
    isPlacingBid.value = true;
    try {
      final uid = await SecureStorageService.to.read(StorageKeys.userId) ?? '';
      final response = await NetworkService.to.post(
        ApiEndpoints.placeBid,
        data: {
          'vehicle_id': vehicleId,
          'auction_id': auctionId,
          'bid_amount': bidAmount,
          'user_id': uid,
        },
      );
      final raw = response.data as Map<String, dynamic>? ?? {};
      final status = raw['status'] as String? ?? '';
      if (status == 'error') {
        final msg =
            (raw['error'] as Map?)?['message'] as String? ??
            raw['message'] as String? ??
            'Failed to place bid';
        Get.snackbar(
          'Bid Failed',
          msg,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.shade700,
          colorText: Colors.white,
        );
        return false;
      }
      CustomSnackbar.show(
        message: 'Bid placed successfully!',
        type: SnackbarType.success,
      );
      // Refresh list so new bid amounts show
      _load();
      return true;
    } catch (e) {
      final msg = e is BidException ? e.message : 'Failed to place bid.';
      Get.snackbar(
        'Bid Failed',
        msg,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isPlacingBid.value = false;
    }
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
