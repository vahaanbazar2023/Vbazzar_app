import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import '../../../core/services/deep_link_service.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/storage/storage_keys.dart';
import '../../../features/profile/repositories/profile_repository.dart';
import '../data/models/dashboard_model.dart';
import '../data/repositories/dashboard_repository.dart';

class HomeController extends GetxController {
  final DashboardRepository _repository = DashboardRepository();
  final ProfileRepository _profileRepository = ProfileRepository();

  final isLoading = true.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final dashboardData = Rxn<DashboardData>();
  final userName = ''.obs;
  final locationLabel = ''.obs;

  @override
  void onReady() {
    super.onReady();
    _loadUserName();
    _loadLocationLabel();
    fetchDashboard();
    // Handle any pending deep link from cold start (e.g. shared vehicle link)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<DeepLinkService>()) {
        DeepLinkService.to.resumePendingNavigation();
      }
    });
  }

  // ─── Location ────────────────────────────────────────────────

  Future<void> _loadLocationLabel() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        locationLabel.value = 'Set Location';
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
        ),
      );

      // Pure HTTP reverse geocode — no native dependency
      final dio = Dio();
      final resp = await dio.get<Map<String, dynamic>>(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'lat': pos.latitude,
          'lon': pos.longitude,
          'format': 'json',
          'zoom': 10,
        },
        options: Options(
          headers: {'User-Agent': 'VaahaanApp/1.0'},
          receiveTimeout: const Duration(seconds: 6),
        ),
      );

      final address = resp.data?['address'] as Map<String, dynamic>? ?? {};
      final city =
          (address['city'] ??
                  address['town'] ??
                  address['village'] ??
                  address['county'] ??
                  '')
              as String;
      final state = (address['state'] ?? '') as String;
      locationLabel.value = [city, state].where((s) => s.isNotEmpty).join(', ');
    } catch (_) {
      locationLabel.value = '';
    }
  }

  Future<void> refreshLocation() => _loadLocationLabel();

  // ─── User name ───────────────────────────────────────────────

  Future<void> _loadUserName() async {
    try {
      final response = await _profileRepository.fetchProfile();
      if (response.isSuccess && response.data != null) {
        final p = response.data!;
        final fullName = '${p.firstName} ${p.lastName}'.trim();
        userName.value = fullName.isNotEmpty ? fullName : p.username;
      }
    } catch (_) {
      final stored =
          await SecureStorageService.to.read(StorageKeys.userName) ?? '';
      userName.value = stored.trim();
    }
  }

  // ─── Dashboard ───────────────────────────────────────────────

  Future<void> fetchDashboard() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';
    dashboardData.value = null;
    try {
      final data = await _repository.getDashboardHome();
      if (data != null) {
        dashboardData.value = data;
      } else {
        hasError.value = true;
        errorMessage.value = 'Failed to load dashboard.';
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
