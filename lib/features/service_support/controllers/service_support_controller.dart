import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/molecules/custom_snackbar.dart';
import '../../../core/services/gps_location_service.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/storage/storage_keys.dart';
import '../data/models/mechanic_model.dart';
import '../data/services/service_support_service.dart';
import '../../subscription/models/subscription_plan.dart';
import '../../subscription/services/subscription_service.dart';
import '../../subscription/views/single_plan_payment_screen.dart';

class ServiceSupportController extends GetxController
    with WidgetsBindingObserver {
  // ── dependencies ──────────────────────────────────────────────────
  late final ServiceSupportService _service;
  late final SecureStorageService _storage;

  // ── observable state ──────────────────────────────────────────────
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final mechanics = <Mechanic>[].obs;
  final currentPage = 1.obs;
  final hasMore = true.obs;
  final totalCount = 0.obs;
  final hasAttemptedLoad = false.obs;
  final userLatitude = 0.0.obs;
  final userLongitude = 0.0.obs;
  final searchQuery = ''.obs;

  // ── SUBT007 plan (fetched once on init) ───────────────────────────
  SubscriptionPlan? _subt007Plan;
  final isSUBT007Loading = false.obs;

  // ── private state ─────────────────────────────────────────────────
  bool _isApiCallInProgress = false;
  bool _openedLocationSettings = false;
  String? _currentUserId;

  // ── computed ──────────────────────────────────────────────────────
  bool get isGpsLocationAvailable =>
      _gps.isLocationEnabled.value && _gps.hasLocation.value;

  GpsLocationService get _gps => GpsLocationService.to;

  // ── lifecycle ─────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _service = ServiceSupportService();
    _storage = SecureStorageService.to;
    WidgetsBinding.instance.addObserver(this);
    _initializeData();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _openedLocationSettings) {
      _openedLocationSettings = false;
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!isClosed) _showCheckAgainDialog();
      });
    }
  }

  // ══════════════════════════════════════════════════════════════════
  //  INIT
  // ══════════════════════════════════════════════════════════════════

  Future<void> _initializeData() async {
    _currentUserId = await _storage.read(StorageKeys.userId);
    _fetchSUBT007Plan(); // background — don't block
    autoLoadMechanics();
  }

  /// Fetches the SUBT007 plan once from subscription listing API.
  Future<void> _fetchSUBT007Plan() async {
    if (_currentUserId == null || _currentUserId!.isEmpty) return;
    isSUBT007Loading.value = true;
    try {
      final result = await SubscriptionService().fetchPlans(
        userId: _currentUserId!,
        subscriptionSource: 'SUBT007',
      );
      if (result.plans.isNotEmpty) {
        _subt007Plan = result.plans.first;
      }
    } catch (_) {
      // Silently fail — will retry on contactMechanic tap if null
    } finally {
      isSUBT007Loading.value = false;
    }
  }

  // ══════════════════════════════════════════════════════════════════
  //  AUTO-LOAD ON INIT
  // ══════════════════════════════════════════════════════════════════

  Future<void> autoLoadMechanics() async {
    final location = await _getUserLocation();
    if (location == null) return;
    userLatitude.value = location['latitude']!;
    userLongitude.value = location['longitude']!;
    await loadMechanics(refresh: true);
  }

  // ══════════════════════════════════════════════════════════════════
  //  LOCATION
  // ══════════════════════════════════════════════════════════════════

  Future<Map<String, double>?> _getUserLocation() async {
    final success = await _gps.getCurrentLocation();
    if (!success || !_gps.hasLocation.value || !_gps.isLocationEnabled.value) {
      mechanics.clear();
      hasAttemptedLoad.value = true;
      _showLocationPermissionDialog();
      return null;
    }
    return {'latitude': _gps.latitude.value, 'longitude': _gps.longitude.value};
  }

  Future<void> _handleLocationEnabling() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.back();
        _showEnableGpsDialog();
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        Get.back();
        _showPermissionRequiredDialog();
        return;
      }

      Get.back();
      final success = await _gps.getCurrentLocation();
      if (success && _gps.hasLocation.value) {
        userLatitude.value = _gps.latitude.value;
        userLongitude.value = _gps.longitude.value;
        await loadMechanics(refresh: true);
      } else {
        _showErrorDialog(
          'Location Error',
          'Unable to get your location. Please try again.',
        );
      }
    } catch (e) {
      Get.back();
      _showErrorDialog(
        'Location Error',
        'Unable to enable location services. Please check settings.',
      );
    }
  }

  // ══════════════════════════════════════════════════════════════════
  //  MECHANICS LIST
  // ══════════════════════════════════════════════════════════════════

  Future<void> loadMechanics({bool refresh = false}) async {
    if (_isApiCallInProgress) {
      int waitCount = 0;
      while (_isApiCallInProgress && waitCount < 20) {
        await Future.delayed(const Duration(milliseconds: 500));
        waitCount++;
      }
      if (_isApiCallInProgress)
        _isApiCallInProgress = false;
      else
        return;
    }

    _isApiCallInProgress = true;

    try {
      if (refresh) {
        currentPage.value = 1;
        hasMore.value = true;
        mechanics.clear();
        hasAttemptedLoad.value = false;
      }

      if (userLatitude.value == 0.0 && userLongitude.value == 0.0) {
        final location = await _getUserLocation();
        if (location == null) {
          _isApiCallInProgress = false;
          return;
        }
        userLatitude.value = location['latitude']!;
        userLongitude.value = location['longitude']!;
      }

      final userId = _currentUserId;
      if (userId == null || userId.isEmpty) {
        _isApiCallInProgress = false;
        return;
      }

      if (currentPage.value > 1) {
        isLoadingMore.value = true;
      } else {
        isLoading.value = true;
      }

      final data = await _service.listMechanics(
        userId: userId,
        latitude: userLatitude.value,
        longitude: userLongitude.value,
        page: currentPage.value,
      );

      totalCount.value = data.count;
      if (refresh) {
        mechanics.assignAll(data.mechanics);
      } else {
        mechanics.addAll(data.mechanics);
      }

      hasMore.value = data.pagination.hasNext;
      hasAttemptedLoad.value = true;
      if (data.pagination.hasNext) currentPage.value++;
    } catch (e) {
      debugPrint('⚠️ ServiceSupport: loadMechanics error – $e');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
      _isApiCallInProgress = false;
    }
  }

  Future<void> refreshMechanics() async {
    userLatitude.value = 0.0;
    userLongitude.value = 0.0;
    mechanics.clear();
    await loadMechanics(refresh: true);
  }

  Future<void> loadMoreMechanics() async {
    if (isLoadingMore.value || !hasMore.value) return;
    await loadMechanics();
  }

  /// Silent refresh — updates list without showing the loading spinner.
  Future<void> _silentRefreshMechanics() async {
    final userId = _currentUserId;
    if (userId == null || userId.isEmpty) return;
    if (userLatitude.value == 0.0 && userLongitude.value == 0.0) return;

    try {
      final data = await _service.listMechanics(
        userId: userId,
        latitude: userLatitude.value,
        longitude: userLongitude.value,
        page: 1,
      );
      mechanics.assignAll(data.mechanics);
    } catch (_) {
      // Silently fail — user still sees stale data
    }
  }

  // ══════════════════════════════════════════════════════════════════
  //  CONTACT / SUBSCRIBE
  // ══════════════════════════════════════════════════════════════════

  /// Called when user taps the contact button on a mechanic card.
  ///
  /// - mobile_number non-empty → open dialer directly.
  /// - mobile_number empty → show SinglePlanPaymentScreen (SUBT007).
  Future<void> contactMechanic(Mechanic mechanic) async {
    if (mechanic.hasValidMobile) {
      _launchDialer(mechanic.mobileNumber);
      return;
    }

    // Ensure SUBT007 plan is loaded
    if (_subt007Plan == null && !isSUBT007Loading.value) {
      await _fetchSUBT007Plan();
    }

    final plan = _subt007Plan;
    if (plan == null) {
      CustomSnackbar.show(
        message: 'Unable to load subscription plan. Please try again.',
        type: SnackbarType.error,
      );
      return;
    }

    Get.to(
      () => SinglePlanPaymentScreen(
        plan: plan,
        source: 'SUBT007',
        mechanicId: mechanic.mechanicId,
        title: 'Connect with Mechanic',
        subtitle:
            'Pay to get the direct contact number for ${mechanic.mechanicName} at ${mechanic.garageName}.',
        onPaymentSuccess: () {
          Get.back(); // pop payment screen
          _unlockMechanicContact(mechanic);
        },
      ),
      transition: Transition.rightToLeft,
    );
  }

  /// After payment: POST user-mechanic-subscription → silent refresh → card updates.
  Future<void> _unlockMechanicContact(Mechanic mechanic) async {
    final userId = _currentUserId;
    if (userId == null) return;
    try {
      await _service.createMechanicSubscription(
        userId: userId,
        mechanicId: mechanic.mechanicId,
      );
      CustomSnackbar.show(
        message: 'Contact unlocked! You can now call the mechanic.',
        type: SnackbarType.success,
      );
      _silentRefreshMechanics();
    } catch (_) {
      CustomSnackbar.show(
        message: 'Something went wrong. Please try again.',
        type: SnackbarType.error,
      );
    }
  }

  /// Public entry point for wallet flow (called from SubscriptionConfirmController).
  Future<void> unlockMechanicContactById(String mechanicId) async {
    final mechanic = mechanics.firstWhereOrNull(
      (m) => m.mechanicId == mechanicId,
    );
    if (mechanic != null) {
      await _unlockMechanicContact(mechanic);
    } else {
      final userId = _currentUserId;
      if (userId == null) return;
      try {
        await _service.createMechanicSubscription(
          userId: userId,
          mechanicId: mechanicId,
        );
        CustomSnackbar.show(
          message: 'Contact unlocked! You can now call the mechanic.',
          type: SnackbarType.success,
        );
        _silentRefreshMechanics();
      } catch (_) {
        CustomSnackbar.show(
          message: 'Something went wrong. Please try again.',
          type: SnackbarType.error,
        );
      }
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

  // ══════════════════════════════════════════════════════════════════
  //  HELPERS
  // ══════════════════════════════════════════════════════════════════

  void forceResetStates() {
    isLoading.value = false;
    isLoadingMore.value = false;
    _isApiCallInProgress = false;
    mechanics.clear();
    currentPage.value = 1;
    hasMore.value = true;
    totalCount.value = 0;
    hasAttemptedLoad.value = false;
  }

  void resetForFreshStart() {
    forceResetStates();
    userLatitude.value = 0.0;
    userLongitude.value = 0.0;
  }

  // ── location dialogs ───────────────────────────────────────────────

  void _showLocationPermissionDialog() {
    _showCustomDialog(
      icon: Icons.location_on_outlined,
      iconColor: AppColors.primary,
      title: 'Location Required',
      content:
          'This app needs location access to find service providers near you.',
      features: const [
        'Find nearest service providers',
        'Get accurate distance estimates',
        'Personalized recommendations',
      ],
      cancelText: 'Cancel',
      actionText: 'Enable',
      actionColor: AppColors.primary,
      onAction: () {
        Get.back();
        _handleLocationEnabling();
      },
    );
  }

  void _showEnableGpsDialog() {
    _showCustomDialog(
      icon: Icons.warning_amber_rounded,
      iconColor: AppColors.warning,
      title: 'Enable GPS',
      content: 'Please turn on GPS in your device settings, then come back.',
      cancelText: 'Cancel',
      actionText: 'Settings',
      actionColor: AppColors.warning,
      onAction: () {
        _openedLocationSettings = true;
        _gps.openLocationSettings();
        Get.back();
      },
    );
  }

  void _showPermissionRequiredDialog() {
    _showCustomDialog(
      icon: Icons.settings_outlined,
      iconColor: AppColors.warning,
      title: 'Permission Required',
      content:
          'Location permission is required. Please enable it in app settings.',
      cancelText: 'Cancel',
      actionText: 'Settings',
      actionColor: AppColors.warning,
      onAction: () {
        _openedLocationSettings = true;
        Geolocator.openAppSettings();
        Get.back();
      },
    );
  }

  void _showCheckAgainDialog() {
    _showCustomDialog(
      icon: Icons.info_outline,
      iconColor: AppColors.info,
      title: 'Settings Updated?',
      content:
          'Did you enable location permission? Tap "Retry" to find service providers.',
      cancelText: 'Cancel',
      actionText: 'Retry',
      actionColor: AppColors.info,
      onAction: () {
        Get.back();
        _handleLocationEnabling();
      },
    );
  }

  void _showErrorDialog(String title, String message) {
    Get.defaultDialog(
      title: title,
      middleText: message,
      textConfirm: 'OK',
      confirmTextColor: Colors.white,
      onConfirm: () => Get.back(),
    );
  }

  void _showCustomDialog({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
    List<String> features = const [],
    required String cancelText,
    required String actionText,
    required Color actionColor,
    required VoidCallback onAction,
  }) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: iconColor.withValues(alpha: 0.1),
                ),
                child: Icon(icon, size: 32, color: iconColor),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: Get.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                content,
                style: Get.textTheme.bodyMedium?.copyWith(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              if (features.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: features
                        .map(
                          (f) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  size: 18,
                                  color: AppColors.success,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    f,
                                    style: Get.textTheme.bodyMedium?.copyWith(
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(
                            color: AppColors.textSecondary.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                        child: Text(
                          cancelText,
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: onAction,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: actionColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(actionText),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}

