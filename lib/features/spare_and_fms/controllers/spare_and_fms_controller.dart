import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/molecules/custom_snackbar.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/storage/storage_keys.dart';
import '../../../routes/app_routes.dart';
import '../../buy_and_sell/domain/entities/paginated_buy_vehicles_response.dart';
import '../../subscription/models/subscription_plan.dart';
import '../../subscription/services/subscription_service.dart';
import '../../subscription/views/single_plan_payment_screen.dart';
import '../domain/entities/shop_entity.dart';
import '../domain/entities/spare_order_entity.dart';
import '../domain/entities/spare_part_entity.dart';
import '../domain/repositories/spare_fms_repository.dart';

/// Main controller for the Spare & FMS module.
///
/// Manages 3 tabs (Spare, FMS, Spare Support), shop listing by
/// category with GPS, spare parts browsing with pagination, user
/// spare orders (My Bookings), and shop subscription flows.
class SpareAndFmsController extends GetxController
    with GetSingleTickerProviderStateMixin, WidgetsBindingObserver {
  final SpareFmsRepository _repository;

  SpareAndFmsController({required SpareFmsRepository repository})
    : _repository = repository;

  // ─── Tab state ──────────────────────────────────────────────

  late TabController tabController;
  final currentTabIndex = 0.obs;
  static const tabs = ['FMS', 'Spare'];

  // ─── User ───────────────────────────────────────────────────

  String? _currentUserId;

  // ─── SUBT006 plan (fetched once on init) ────────────────────

  SubscriptionPlan? _subt006Plan;
  final isSUBT006Loading = false.obs;

  // ─── FMS spare parts (Tab 0) ────────────────────────────────

  final fmsList = <SparePartEntity>[].obs;
  final isFmsLoading = false.obs;
  final hasFmsInitiallyLoaded = false.obs;
  final isRecordingInterest = false.obs;

  // FMS pagination
  final fmsCurrentPage = 1.obs;
  final fmsTotalPages = 1.obs;
  final hasMoreFmsData = false.obs;
  final isLoadingMoreFms = false.obs;

  // ─── Shops (Tab 1 — Spare Support) ─────────────────────────

  final shopsListData = <ShopEntity>[].obs;
  final shopFeedAds = <ListingAd>[].obs;
  final isShopsLoading = false.obs;
  final hasShopsInitiallyLoaded = false.obs;
  final currentShopCategory = ''.obs;

  // ─── Spare orders (My Bookings) ─────────────────────────────

  final spareOrdersList = <SpareOrderEntity>[].obs;
  final isSpareOrdersLoading = false.obs;
  final spareOrdersCurrentPage = 1.obs;
  final spareOrdersTotalPages = 1.obs;
  final hasMoreSpareOrders = false.obs;
  final isLoadingMoreSpareOrders = false.obs;

  // ─── Location ───────────────────────────────────────────────

  double? _userLatitude;
  double? _userLongitude;
  bool _openedLocationSettings = false;

  // ─── Lifecycle ──────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);

    tabController = TabController(length: tabs.length, vsync: this);
    tabController.addListener(_onTabChanged);

    _initializeData();
  }

  @override
  void onClose() {
    tabController.removeListener(_onTabChanged);
    tabController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _openedLocationSettings) {
      Future.delayed(const Duration(milliseconds: 300), () {
        _showRetryAfterSettingsDialog();
        _openedLocationSettings = false;
      });
    }
  }

  // ─── Initialization ─────────────────────────────────────────

  Future<void> _initializeData() async {
    _currentUserId = await SecureStorageService.instance.read(
      StorageKeys.userId,
    );
    _initializeLocationInBackground();
    _fetchSUBT006Plan(); // fetch in background, don't block
    _loadTabData(0);
  }

  /// Fetches the SUBT006 plan from subscription listing API once on init.
  /// Cached in [_subt006Plan] for use in [contactShop].
  Future<void> _fetchSUBT006Plan() async {
    if (_currentUserId == null || _currentUserId!.isEmpty) return;
    isSUBT006Loading.value = true;
    try {
      final service = SubscriptionService();
      final result = await service.fetchPlans(
        userId: _currentUserId!,
        subscriptionSource: 'SUBT006',
      );
      if (result.plans.isNotEmpty) {
        _subt006Plan = result.plans.first;
      }
    } catch (e) {
      // Silently fail — will retry on contactShop tap if null
    } finally {
      isSUBT006Loading.value = false;
    }
  }

  Future<void> _initializeLocationInBackground() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _userLatitude = position.latitude;
      _userLongitude = position.longitude;
    } catch (_) {
      // Silently fail — location will be requested when needed
    }
  }

  // ─── Tab management ─────────────────────────────────────────

  void _onTabChanged() {
    if (!tabController.indexIsChanging) return;
    final index = tabController.index;
    currentTabIndex.value = index;
    _loadTabData(index);
  }

  void switchToTab(int index) {
    tabController.animateTo(index);
  }

  void _loadTabData(int tabIndex) {
    switch (tabIndex) {
      case 0:
        if (!hasFmsInitiallyLoaded.value) _loadFmsData();
        break;
      case 1:
        // Spare Support — navigate to sub-views
        break;
    }
  }

  // ─── Spare Parts ────────────────────────────────────────────

  Future<void> recordSpareInterest(SparePartEntity spare) async {
    if (_currentUserId == null) {
      Get.snackbar(
        'Login Required',
        'Please login to show interest',
        backgroundColor: AppColors.warning,
        colorText: AppColors.black,
      );
      return;
    }

    if (isRecordingInterest.value) return;
    isRecordingInterest.value = true;

    try {
      await _repository.recordSpareInterest(
        spareId: spare.sparePartId,
        userId: _currentUserId!,
      );

      _showSuccessDialog(
        title: 'Interest Recorded',
        message:
            'Your interest in "${spare.spareName}" has been recorded successfully.',
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to record interest. Please try again.',
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
      );
    } finally {
      isRecordingInterest.value = false;
    }
  }

  // ─── FMS Tab (Tab 1) ───────────────────────────────────────

  Future<void> _loadFmsData({bool isRefresh = false}) async {
    if (isRefresh) {
      fmsCurrentPage.value = 1;
      fmsList.clear();
    }

    isFmsLoading.value = true;

    try {
      final result = await _repository.getSparesList(
        page: fmsCurrentPage.value,
        limit: 10,
        userId: _currentUserId,
      );

      if (isRefresh || fmsCurrentPage.value == 1) {
        fmsList.assignAll(result.spares);
      } else {
        fmsList.addAll(result.spares);
      }

      fmsTotalPages.value = result.pagination.totalPages;
      hasMoreFmsData.value = result.pagination.hasNext;
      hasFmsInitiallyLoaded.value = true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load spare parts',
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
      );
    } finally {
      isFmsLoading.value = false;
    }
  }

  Future<void> loadMoreFmsItems() async {
    if (isLoadingMoreFms.value || !hasMoreFmsData.value) return;

    isLoadingMoreFms.value = true;
    fmsCurrentPage.value++;

    try {
      final result = await _repository.getSparesList(
        page: fmsCurrentPage.value,
        limit: 20,
        userId: _currentUserId,
      );

      fmsList.addAll(result.spares);
      hasMoreFmsData.value = result.pagination.hasNext;
      fmsTotalPages.value = result.pagination.totalPages;
    } catch (e) {
      fmsCurrentPage.value--; // Revert on error
    } finally {
      isLoadingMoreFms.value = false;
    }
  }

  Future<void> refreshFmsData() => _loadFmsData(isRefresh: true);

  // ─── FMS Detail Navigation ──────────────────────────────────

  void navigateToFmsDetail(SparePartEntity sparePart) {
    Get.toNamed(
      AppRoutes.spareDetail,
      arguments: {'sparePart': sparePart, 'isFromOrders': false},
    );
  }

  void navigateToSpareOrderDetail(SpareOrderEntity spareOrder) {
    Get.toNamed(
      AppRoutes.spareDetail,
      arguments: {
        'sparePart': spareOrder.toSparePartEntity(),
        'isFromOrders': true,
        'orderStatus': spareOrder.orderStatus,
        'orderId': spareOrder.spareOrderId,
      },
    );
  }

  // ─── Shops (Tab 2 — by category) ───────────────────────────

  Future<void> loadShopsByCategory(String categoryType) async {
    currentShopCategory.value = categoryType;
    isShopsLoading.value = true;
    shopsListData.clear();

    // Ensure userId is loaded before proceeding — _initializeData is async
    // and may not have completed when this is called right after onInit.
    if (_currentUserId == null || _currentUserId!.isEmpty) {
      _currentUserId = await SecureStorageService.instance.read(
        StorageKeys.userId,
      );
    }

    final location = await _getUserLocation();
    if (location == null) {
      isShopsLoading.value = false;
      hasShopsInitiallyLoaded.value = true;
      return;
    }

    try {
      final result = await _repository.getShopsListByCategory(
        latitude: location.latitude,
        longitude: location.longitude,
        shopCategoryType: categoryType,
        userId: _currentUserId ?? '',
        page: 1,
        limit: 20,
      );

      shopsListData.assignAll(result.shops);
      shopFeedAds.assignAll(result.ads);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load shops',
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
      );
    } finally {
      isShopsLoading.value = false;
      hasShopsInitiallyLoaded.value = true;
    }
  }

  Future<void> refreshShopsData() async {
    if (currentShopCategory.value.isNotEmpty) {
      await loadShopsByCategory(currentShopCategory.value);
    }
  }

  /// Silently refreshes the shops list without showing the loading spinner.
  /// Used after payment to reveal the phone number in-place.
  Future<void> _silentRefreshShops() async {
    if (currentShopCategory.value.isEmpty) return;

    final location = await _getUserLocation();
    if (location == null) return;

    try {
      final result = await _repository.getShopsListByCategory(
        latitude: location.latitude,
        longitude: location.longitude,
        shopCategoryType: currentShopCategory.value,
        userId: _currentUserId ?? '',
        page: 1,
        limit: 20,
      );
      shopsListData.assignAll(result.shops);
      shopFeedAds.assignAll(result.ads);
    } catch (_) {
      // Silently fail — user still sees old data
    }
  }

  // ─── Shop Contact (SUBT006) ─────────────────────────────────

  /// Called when user taps "Contact" on a shop card.
  ///
  /// If mobile_number is already populated (returned by API) → open dialer.
  /// If mobile_number is empty → fetch SUBT006 plan (if not yet cached) →
  /// show SinglePlanPaymentScreen → after payment → POST user-shop-subscription
  /// → refresh shops → dial.
  Future<void> contactShop(ShopEntity shop) async {
    // Number already revealed by the API — dial directly
    if (shop.hasValidMobileNumber) {
      _launchDialer(shop.mobileNumber);
      return;
    }

    // Ensure we have the SUBT006 plan
    if (_subt006Plan == null) {
      // Try fetching it now (may not have loaded yet on init)
      if (_currentUserId != null && !isSUBT006Loading.value) {
        await _fetchSUBT006Plan();
      }
    }

    final plan = _subt006Plan;

    if (plan == null) {
      // Couldn't load plan — show error
      CustomSnackbar.show(
        message: 'Unable to load subscription plan. Please try again.',
        type: SnackbarType.error,
      );
      return;
    }

    // Show single plan payment screen — no subscription listing API needed
    Get.to(
      () => SinglePlanPaymentScreen(
        plan: plan,
        source: 'SUBT006',
        shopId: shop.shopId,
        title: 'Connect with Shop',
        subtitle: 'Pay to get the direct contact number for ${shop.shopName}.',
        onPaymentSuccess: () {
          Get.back(); // pop payment screen
          _unlockShopContact(shop);
        },
      ),
      transition: Transition.rightToLeft,
    );
  }

  /// Public entry point called from [SubscriptionConfirmController] wallet flow.
  /// Looks up the shop by ID from [shopsListData] and unlocks contact.
  Future<void> unlockShopContactById(String shopId) async {
    final shop = shopsListData.firstWhereOrNull((s) => s.shopId == shopId);
    if (shop != null) {
      await _unlockShopContact(shop);
    } else {
      // Shop not in current list — just POST the unlock and refresh
      if (_currentUserId == null) return;
      try {
        final success = await _repository.createShopSubscription(
          shopId: shopId,
          userId: _currentUserId!,
        );
        if (success) {
          CustomSnackbar.show(
            message: 'Contact unlocked! You can now call the shop.',
            type: SnackbarType.success,
          );
          _silentRefreshShops();
        }
      } catch (_) {
        CustomSnackbar.show(
          message: 'Something went wrong. Please try again.',
          type: SnackbarType.error,
        );
      }
    }
  }

  /// After payment: call the API with number_access_subscription: yes,
  /// then refresh shops so the card updates to show the phone number.
  /// Does NOT auto-dial — the user taps the contact button themselves.
  Future<void> _unlockShopContact(ShopEntity shop) async {
    if (_currentUserId == null) return;
    try {
      final success = await _repository.createShopSubscription(
        shopId: shop.shopId,
        userId: _currentUserId!,
      );
      if (success) {
        CustomSnackbar.show(
          message: 'Contact unlocked! You can now call the shop.',
          type: SnackbarType.success,
        );
        // Silent refresh — updates card in-place without showing spinner.
        _silentRefreshShops();
      } else {
        CustomSnackbar.show(
          message: 'Could not unlock contact. Please try again.',
          type: SnackbarType.error,
        );
      }
    } catch (_) {
      CustomSnackbar.show(
        message: 'Something went wrong. Please try again.',
        type: SnackbarType.error,
      );
    }
  }

  void _launchDialer(String phone) {
    final uri = Uri(scheme: 'tel', path: phone);
    launchUrl(uri).catchError((_) {
      Get.snackbar(
        'Phone',
        'Contact: $phone',
        snackPosition: SnackPosition.TOP,
      );
      return false;
    });
  }

  bool hasShopMobileNumber(ShopEntity shop) {
    return shop.mobileNumber.isNotEmpty &&
        shop.mobileNumber != 'null' &&
        shop.mobileNumber != '0';
  }

  // ─── Spare Orders (My Bookings) ─────────────────────────────

  Future<void> loadUserSpareOrders({bool isRefresh = false}) async {
    if (_currentUserId == null) return;

    if (isRefresh) {
      spareOrdersCurrentPage.value = 1;
      spareOrdersList.clear();
    }

    isSpareOrdersLoading.value = true;

    try {
      final result = await _repository.getUserSparesOrders(
        userId: _currentUserId!,
        page: spareOrdersCurrentPage.value,
        limit: 20,
      );

      if (isRefresh || spareOrdersCurrentPage.value == 1) {
        spareOrdersList.assignAll(result.orders);
      } else {
        spareOrdersList.addAll(result.orders);
      }

      spareOrdersTotalPages.value = result.pagination.totalPages;
      hasMoreSpareOrders.value = result.pagination.hasNext;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load orders',
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
      );
    } finally {
      isSpareOrdersLoading.value = false;
    }
  }

  Future<void> loadMoreSpareOrders() async {
    if (_currentUserId == null) return;
    if (isLoadingMoreSpareOrders.value || !hasMoreSpareOrders.value) return;

    isLoadingMoreSpareOrders.value = true;
    spareOrdersCurrentPage.value++;

    try {
      final result = await _repository.getUserSparesOrders(
        userId: _currentUserId!,
        page: spareOrdersCurrentPage.value,
        limit: 20,
      );

      spareOrdersList.addAll(result.orders);
      hasMoreSpareOrders.value = result.pagination.hasNext;
      spareOrdersTotalPages.value = result.pagination.totalPages;
    } catch (e) {
      spareOrdersCurrentPage.value--;
    } finally {
      isLoadingMoreSpareOrders.value = false;
    }
  }

  // ─── Location Helpers ───────────────────────────────────────

  Future<({double latitude, double longitude})?> _getUserLocation() async {
    if (_userLatitude != null && _userLongitude != null) {
      return (latitude: _userLatitude!, longitude: _userLongitude!);
    }

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showEnableGpsDialog();
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      // Request permission if not yet granted
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showOpenSettingsDialog();
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _userLatitude = position.latitude;
      _userLongitude = position.longitude;
      return (latitude: position.latitude, longitude: position.longitude);
    } catch (e) {
      debugPrint('❌ [location] error: $e');
      return null;
    }
  }

  void enableLocationFromUI() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showEnableGpsDialog();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      if (permission == LocationPermission.deniedForever) {
        _showOpenSettingsDialog();
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _userLatitude = position.latitude;
      _userLongitude = position.longitude;

      if (currentShopCategory.value.isNotEmpty) {
        loadShopsByCategory(currentShopCategory.value);
      }
    } catch (e) {
      Get.snackbar(
        'Location Error',
        'Unable to access location. Please restart the app and try again.',
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
        duration: const Duration(seconds: 4),
      );
    }
  }

  void refreshLocationAndReloadShops() {
    _userLatitude = null;
    _userLongitude = null;
    shopsListData.clear();
    hasShopsInitiallyLoaded.value = false;

    if (currentShopCategory.value.isNotEmpty) {
      loadShopsByCategory(currentShopCategory.value);
    }
  }

  // ─── Location Dialogs ───────────────────────────────────────

  void _showLocationPermissionDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Location Permission'),
        content: const Text(
          'We need your location to find nearby shops. '
          'Please grant location permission.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              final permission = await Geolocator.requestPermission();
              if (permission == LocationPermission.whileInUse ||
                  permission == LocationPermission.always) {
                final position = await Geolocator.getCurrentPosition(
                  desiredAccuracy: LocationAccuracy.high,
                );
                _userLatitude = position.latitude;
                _userLongitude = position.longitude;
                if (currentShopCategory.value.isNotEmpty) {
                  loadShopsByCategory(currentShopCategory.value);
                }
              } else if (permission == LocationPermission.deniedForever) {
                _showOpenSettingsDialog();
              }
            },
            child: const Text('Allow'),
          ),
        ],
      ),
    );
  }

  void _showEnableGpsDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Enable GPS'),
        content: const Text(
          'GPS is disabled. Please enable location services to find nearby shops.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _openedLocationSettings = true;
              Geolocator.openLocationSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _showOpenSettingsDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Location Permission Required'),
        content: const Text(
          'Location permission has been permanently denied. '
          'Please enable it from app settings.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _openedLocationSettings = true;
              Geolocator.openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _showRetryAfterSettingsDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Location Updated?'),
        content: const Text('Would you like to retry loading shops now?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Not Now')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              refreshLocationAndReloadShops();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // ─── Success Dialog ─────────────────────────────────────────

  void _showSuccessDialog({required String title, required String message}) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: AppColors.success, size: 64),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('OK'),
            ),
          ),
        ],
      ),
    );
  }
}
