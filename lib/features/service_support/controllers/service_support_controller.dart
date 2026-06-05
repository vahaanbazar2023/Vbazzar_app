import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/gps_location_service.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/storage/storage_keys.dart';
import '../../../routes/app_routes.dart';
import '../data/models/mechanic_model.dart';
import '../data/services/service_support_service.dart';
import '../../subscription/services/subscription_service.dart';

class ServiceSupportController extends GetxController
    with WidgetsBindingObserver {
  // ── dependencies ──────────────────────────────────────────────────
  late final ServiceSupportService _service;
  late final SecureStorageService _storage;
  late final SubscriptionService _subscriptionService;

  // ── observable state ──────────────────────────────────────────────
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final mechanics = <Mechanic>[].obs;
  final currentPage = 1.obs;
  final hasMore = true.obs;
  final totalCount = 0.obs;
  final hasAttemptedLoad = false.obs;
  final hasSubscription = false.obs;
  final userLatitude = 0.0.obs;
  final userLongitude = 0.0.obs;
  final searchQuery = ''.obs;

  // ── private state ─────────────────────────────────────────────────
  bool _isApiCallInProgress = false;
  bool _openedLocationSettings = false;
  DateTime? _lastRefreshTime;
  Timer? _refreshDebounceTimer;
  static const int _refreshDebounceSeconds = 2;

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
    _subscriptionService = SubscriptionService();
    WidgetsBinding.instance.addObserver(this);
    checkSubscriptionStatus();
    // Auto-load: acquire GPS then fetch mechanics on list view open
    autoLoadMechanics();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _refreshDebounceTimer?.cancel();
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
  //  AUTO-LOAD ON INIT
  // ══════════════════════════════════════════════════════════════════

  /// Automatically acquires GPS and loads mechanics when the list view opens.
  Future<void> autoLoadMechanics() async {
    final location = await _getUserLocation();
    if (location == null) return;

    userLatitude.value = location['latitude']!;
    userLongitude.value = location['longitude']!;

    await loadMechanics(refresh: true);
  }

  // ══════════════════════════════════════════════════════════════════
  //  SUBSCRIPTION
  // ══════════════════════════════════════════════════════════════════

  Future<void> checkSubscriptionStatus() async {
    try {
      final userId = await _storage.read(StorageKeys.userId);
      if (userId == null || userId.isEmpty) {
        hasSubscription.value = false;
        return;
      }

      final result = await _subscriptionService.fetchMySubscriptions(
        userId: userId,
      );

      final found = result.subscriptions.any(
        (s) => s.typeCode.toUpperCase() == 'SUBT006' && s.isActive,
      );

      hasSubscription.value = found;

      // cache locally
      await _storage.write(
        'mechanic_subscription_status',
        found ? 'active' : 'inactive',
      );
    } catch (_) {
      // fallback to local cache
      final cached = await _storage.read('mechanic_subscription_status');
      hasSubscription.value = cached == 'active';
    }
  }

  // ══════════════════════════════════════════════════════════════════
  //  LOCATION
  // ══════════════════════════════════════════════════════════════════

  /// Main entry point — acquires GPS, then loads mechanics.
  Future<void> contactMechanics() async {
    if (_isApiCallInProgress) return;

    final location = await _getUserLocation();
    if (location == null) return;

    userLatitude.value = location['latitude']!;
    userLongitude.value = location['longitude']!;

    await loadMechanics(refresh: true);
  }

  Future<Map<String, double>?> _getUserLocation() async {
    final success = await _gps.getCurrentLocation();
    if (!success || !_gps.hasLocation.value || !_gps.isLocationEnabled.value) {
      mechanics.clear();
      hasAttemptedLoad.value = true;
      _showLocationPermissionDialog();
      return null;
    }

    return {
      'latitude': _gps.latitude.value,
      'longitude': _gps.longitude.value,
    };
  }

  // ── location dialog flow ──────────────────────────────────────────

  Future<void> _handleLocationEnabling() async {
    try {
      // 1 — GPS service check
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.back(); // close current dialog
        _showEnableGpsDialog();
        return;
      }

      // 2 — Permission check
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

      // 3 — All good, fetch location and auto-load
      Get.back();
      final success = await _gps.getCurrentLocation();

      if (success && _gps.hasLocation.value) {
        _showSnackBar(
          'Location Updated',
          'Location updated successfully. Loading mechanics...',
          Colors.green,
        );
        // Auto-load after location is obtained
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
        'Unable to enable location services. Please check your device settings and try again.',
      );
    }
  }

  // ── dialogs ───────────────────────────────────────────────────────

  void _showLocationPermissionDialog() {
    _showCustomDialog(
      icon: Icons.location_on_outlined,
      iconColor: AppColors.primary,
      title: 'Location Required',
      content:
          'This app needs location access to find service providers near you. We will help you enable GPS and grant location permission.',
      features: const [
        'Find nearest service providers',
        'Get accurate service estimates',
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
      content:
          'Please turn on GPS/Location Services in your device settings, then come back to the app.',
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
          'Location permission is required to find service providers. Please enable it in app settings.',
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
              // Icon
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

              // Title
              Text(
                title,
                style: Get.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Content
              Text(
                content,
                style: Get.textTheme.bodyMedium?.copyWith(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              // Feature bullets
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

              // Buttons
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

  // ══════════════════════════════════════════════════════════════════
  //  MECHANICS LIST
  // ══════════════════════════════════════════════════════════════════

  Future<void> loadMechanics({bool refresh = false}) async {
    // mutex guard
    if (_isApiCallInProgress) {
      int waitCount = 0;
      while (_isApiCallInProgress && waitCount < 20) {
        await Future.delayed(const Duration(milliseconds: 500));
        waitCount++;
      }
      if (_isApiCallInProgress) {
        _isApiCallInProgress = false;
      } else {
        return;
      }
    }

    _isApiCallInProgress = true;

    try {
      if (refresh) {
        currentPage.value = 1;
        hasMore.value = true;
        mechanics.clear();
        hasAttemptedLoad.value = false;
      }

      // Validate coordinates
      if (userLatitude.value == 0.0 && userLongitude.value == 0.0) {
        final location = await _getUserLocation();
        if (location == null) {
          _isApiCallInProgress = false;
          return;
        }
        userLatitude.value = location['latitude']!;
        userLongitude.value = location['longitude']!;
      }

      final userId = await _storage.read(StorageKeys.userId);
      if (userId == null || userId.isEmpty) {
        _showErrorSnackBar('Please log in to view service providers.');
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

      if (data.pagination.hasNext) {
        currentPage.value++;
      }
    } catch (e) {
      debugPrint('⚠️ ServiceSupport: loadMechanics error – $e');
      _showErrorSnackBar('Failed to load mechanics. Please try again.');
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

  /// Quick GPS load without the full contact dialog flow.
  Future<void> simpleLoadMechanics() async {
    final location = await _getUserLocation();
    if (location == null) return;

    userLatitude.value = location['latitude']!;
    userLongitude.value = location['longitude']!;
    await loadMechanics(refresh: true);
  }

  // ══════════════════════════════════════════════════════════════════
  //  CALL / SUBSCRIBE
  // ══════════════════════════════════════════════════════════════════

  void callMechanic(Mechanic mechanic) {
    if (!mechanic.hasValidMobile) {
      _navigateToSubscriptionPlan(mechanic);
      return;
    }

    if (hasSubscription.value) {
      _makeDirectCall(mechanic);
    } else {
      _navigateToSubscriptionPlan(mechanic);
    }
  }

  void _makeDirectCall(Mechanic mechanic) async {
    final uri = Uri.parse('tel:${mechanic.mobileNumber}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _showSnackBar(
        'Contact Available',
        'Call ${mechanic.mechanicName}: ${mechanic.mobileNumber}',
        Colors.green,
        duration: 4,
      );
    }
  }

  void _navigateToSubscriptionPlan(Mechanic mechanic) {
    _storage.write('pendingMechanicId', mechanic.mechanicId);
    _storage.write('subscriptionSource', 'SUBT006');

    Get.toNamed(
      AppRoutes.subscription,
      arguments: {
        'subscriptionSource': 'SUBT006',
        'mechanic': {
          'mechanic_id': mechanic.mechanicId,
          'garage_name': mechanic.garageName,
          'mechanic_name': mechanic.mechanicName,
          'mobile_number': mechanic.mobileNumber,
          'distance_km': mechanic.distanceKm,
          'address': mechanic.fullAddress,
        },
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════
  //  POST-PAYMENT HANDLER
  // ══════════════════════════════════════════════════════════════════

  Future<void> handleMechanicSubscriptionPaymentSuccess(
    String mechanicId,
  ) async {
    try {
      final userId = await _storage.read(StorageKeys.userId);
      if (userId == null || userId.isEmpty) return;

      await _service.createMechanicSubscription(
        userId: userId,
        mechanicId: mechanicId,
      );

      hasSubscription.value = true;
      await _storage.delete('pendingMechanicId');

      _showSnackBar(
        'Success',
        'Mechanic subscription activated successfully!',
        Colors.green,
      );

      await refreshAfterPaymentSuccess();
    } catch (e) {
      debugPrint('⚠️ ServiceSupport: subscription error – $e');
      _showErrorSnackBar('Failed to activate subscription.');
    }
  }

  Future<void> refreshAfterPaymentSuccess() async {
    final now = DateTime.now();

    // debounce
    if (_lastRefreshTime != null &&
        now.difference(_lastRefreshTime!).inSeconds <
            _refreshDebounceSeconds) {
      return;
    }
    _lastRefreshTime = now;

    await checkSubscriptionStatus();

    if (mechanics.isNotEmpty) {
      await loadMechanics(refresh: true);
    }
  }

  // ══════════════════════════════════════════════════════════════════
  //  HELPERS
  // ══════════════════════════════════════════════════════════════════

  String formatAddress(Mechanic m) => m.fullAddress;

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

  void clearLocationAndMechanicsData() {
    mechanics.clear();
    userLatitude.value = 0.0;
    userLongitude.value = 0.0;
  }

  // ── snackbars ─────────────────────────────────────────────────────

  void _showSnackBar(
    String title,
    String message,
    Color bgColor, {
    int duration = 3,
  }) {
    Get.snackbar(
      title,
      message,
      backgroundColor: bgColor,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: duration),
      margin: const EdgeInsets.all(12),
      borderRadius: 8,
    );
  }

  void showSuccessSnackBar(String title, String message) {
    _showSnackBar(title, message, AppColors.success);
  }

  void _showErrorSnackBar(String message) {
    _showSnackBar('Error', message, AppColors.error);
  }
}