import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/storage/storage_keys.dart';
import '../models/auction_listing.dart';
import '../models/auction_pagination.dart';
import '../services/auction_service.dart';

/// Auction type identifiers matching the API.
class AuctionType {
  static const live = 'live_auctions';
  static const closingToday = 'closing_today';
  static const upcoming = 'upcoming_auctions';

  static const all = [live, closingToday, upcoming];

  static String label(String type) {
    switch (type) {
      case live:
        return 'Live Bidding';
      case closingToday:
        return 'Closing Today';
      case upcoming:
        return 'Upcoming';
      default:
        return type;
    }
  }
}

/// Per-tab state.
class _TabState {
  final auctions = <AuctionListing>[].obs;
  final pagination = Rx<AuctionPagination>(AuctionPagination.empty());
  final isLoading = true.obs;
  final isLoadingMore = false.obs;
  final errorMessage = ''.obs;
  int currentPage = 1;
  bool initialized = false;
}

class AuctionController extends GetxController
    with GetTickerProviderStateMixin {
  final AuctionService _service;

  /// Index of the initially selected tab (passed when navigating).
  final int initialTabIndex;

  AuctionController({required this.initialTabIndex, AuctionService? service})
    : _service = service ?? AuctionService();

  late final TabController tabController;

  final _tabs = List.generate(3, (_) => _TabState());

  // Expose per-tab observables by index
  RxList<AuctionListing> auctions(int i) => _tabs[i].auctions;
  Rx<AuctionPagination> pagination(int i) => _tabs[i].pagination;
  RxBool isLoading(int i) => _tabs[i].isLoading;
  RxBool isLoadingMore(int i) => _tabs[i].isLoadingMore;
  RxString errorMessage(int i) => _tabs[i].errorMessage;

  final  TextEditingController searchController = TextEditingController();

  final scrollControllers = List.generate(3, (_) => ScrollController());

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: initialTabIndex.clamp(0, 2),
    );

    // Load the initial tab immediately
    _loadTab(tabController.index);

    tabController.addListener(() {
      if (!tabController.indexIsChanging) {
        _loadTab(tabController.index);
      }
    });

    // Set up infinite scroll for each tab
    for (int i = 0; i < 3; i++) {
      scrollControllers[i].addListener(() => _onScroll(i));
    }
  }

  @override
  void onClose() {
    tabController.dispose();
    for (final sc in scrollControllers) {
      sc.dispose();
    }
    super.onClose();
  }

  void _onScroll(int tabIndex) {
    final sc = scrollControllers[tabIndex];
    if (!sc.hasClients) return;
    final nearBottom = sc.position.pixels >= sc.position.maxScrollExtent - 200;
    if (nearBottom &&
        !_tabs[tabIndex].isLoadingMore.value &&
        _tabs[tabIndex].pagination.value.hasNext) {
      _loadMore(tabIndex);
    }
  }

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
        auctionType: AuctionType.all[tabIndex],
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
        auctionType: AuctionType.all[tabIndex],
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

  Future<void> reloadTab(int tabIndex) => _loadTab(tabIndex, refresh: true);
}
