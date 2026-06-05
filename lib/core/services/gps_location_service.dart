import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

/// Thin wrapper around Geolocator that exposes observable GPS state.
/// Registered as a permanent singleton in AppBinding.
class GpsLocationService extends GetxService {
  static GpsLocationService get to {
    if (!Get.isRegistered<GpsLocationService>()) {
      Get.put<GpsLocationService>(GpsLocationService(), permanent: true);
    }
    return Get.find<GpsLocationService>();
  }

  // ── observable state ──────────────────────────────────────────────
  final latitude = 0.0.obs;
  final longitude = 0.0.obs;
  final hasLocation = false.obs;
  final isLocationEnabled = false.obs;
  final permissionDenied = false.obs;

  // ── public API ────────────────────────────────────────────────────

  /// Returns `true` when both GPS service is on **and** coordinates are
  /// successfully fetched.
  Future<bool> getCurrentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      isLocationEnabled.value = serviceEnabled;

      if (!serviceEnabled) {
        hasLocation.value = false;
        return false;
      }

      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final requested = await Geolocator.requestPermission();
        if (requested == LocationPermission.denied ||
            requested == LocationPermission.deniedForever) {
          permissionDenied.value = true;
          hasLocation.value = false;
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        permissionDenied.value = true;
        hasLocation.value = false;
        return false;
      }

      permissionDenied.value = false;

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      latitude.value = position.latitude;
      longitude.value = position.longitude;
      hasLocation.value = true;
      return true;
    } catch (e) {
      debugPrint('⚠️ GpsLocationService: getCurrentLocation error – $e');
      hasLocation.value = false;
      return false;
    }
  }

  /// Opens the device location settings (to turn GPS on).
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  /// Opens the app-level permission settings.
  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }

  /// Returns `true` when GPS service is currently enabled.
  Future<bool> checkServiceEnabled() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    isLocationEnabled.value = enabled;
    return enabled;
  }

  /// Checks whether location permission has been granted.
  Future<LocationPermission> checkPermission() async {
    return Geolocator.checkPermission();
  }

  /// Requests location permission from the user.
  Future<LocationPermission> requestPermission() async {
    return Geolocator.requestPermission();
  }
}