import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/design_system/design_system.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/services/gps_location_service.dart';
import '../../../core/services/logger_service.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../profile/models/profile_models.dart';
import '../../profile/repositories/profile_repository.dart';
import '../data/partner_data_source.dart';
import '../models/partner_models.dart';

/// Drives the "Partner with us" screen.
///
/// Name, mobile number and user id are never typed by the user — they come from
/// the logged-in user's profile. Latitude/longitude come from GPS and the
/// backend fills in address / city / state from them.
class PartnerController extends GetxController {
  final PartnerDataSource _dataSource;
  final ProfileRepository? _profileRepository;

  /// Overrides how the profile is loaded (used by tests).
  final Future<ProfileData?> Function()? _profileLoader;

  PartnerController({
    PartnerDataSource? dataSource,
    ProfileRepository? profileRepository,
    Future<ProfileData?> Function()? profileLoader,
  }) : _dataSource = dataSource ?? PartnerDataSource(),
       _profileRepository = profileRepository,
       _profileLoader = profileLoader;

  // ── State ─────────────────────────────────────────────────────
  final isLoading = true.obs;
  final loadError = Rxn<String>();

  /// The backend blocks protected endpoints (profile, dashboard…) until registration is
  /// complete. Users may browse and pay first and finish their profile afterwards, so this is
  /// an expected state, not an error: we point them to Complete Profile instead.
  final registrationIncomplete = false.obs;
  final isSubmitting = false.obs;
  final isLocating = false.obs;
  final applyingAgain = false.obs;

  final profile = Rxn<ProfileData>();
  final myRequest = Rxn<PartnerRequest>();

  // ── Form ──────────────────────────────────────────────────────
  final selectedRole = Rxn<PartnerRole>();
  final roleError = Rxn<String>();
  final businessNameError = Rxn<String>();
  final aadhaarError = Rxn<String>();
  // Read-only, filled from the profile.
  final nameCtrl = TextEditingController();
  final mobileCtrl = TextEditingController();
  final businessNameCtrl = TextEditingController();
  final aadhaarCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final latitude = Rxn<double>();
  final longitude = Rxn<double>();

  // ── Derived ───────────────────────────────────────────────────
  String get name {
    final p = profile.value;
    if (p == null) return '';
    return '${p.firstName} ${p.lastName}'.trim();
  }

  String get mobile => profile.value?.phoneNumber ?? '';
  bool get isCustomer =>
      (profile.value?.userType ?? '').toUpperCase() == 'CUSTOMER';
  bool get hasLocation => latitude.value != null && longitude.value != null;

  /// Shows the status card (instead of the form) when a request exists and the
  /// user has not chosen to re-apply after a rejection.
  bool get showStatus {
    final r = myRequest.value;
    if (r == null) return false;
    if (r.isRejected) return !applyingAgain.value;
    return true;
  }

  // ── Lifecycle ─────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map && args['role'] != null) {
      selectedRole.value = PartnerRole.fromApi(args['role'] as String?);
    }
    load();
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    mobileCtrl.dispose();
    businessNameCtrl.dispose();
    aadhaarCtrl.dispose();
    addressCtrl.dispose();
    super.onClose();
  }

  Future<void> load() async {
    isLoading.value = true;
    loadError.value = null;
    registrationIncomplete.value = false;
    try {
      profile.value = await _loadProfile();
      if (profile.value == null) {
        loadError.value = appL10n.partnerProfileLoadFailed;
        return;
      }
      nameCtrl.text = name;
      mobileCtrl.text = mobile;
      myRequest.value = await _dataSource.fetchMyRequest();
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      if (_isRegistrationIncomplete(message)) {
        registrationIncomplete.value = true;
      } else {
        LoggerService.to.error('PartnerController.load error: $e');
        loadError.value = message;
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Backend answers 403 "Registration is incomplete" until the profile is completed.
  static bool _isRegistrationIncomplete(String message) =>
      message.toLowerCase().contains('registration is incomplete');

  /// Reuses the already-loaded profile when the profile tab was opened before.
  Future<ProfileData?> _loadProfile() async {
    if (_profileLoader != null) return _profileLoader();
    if (Get.isRegistered<ProfileController>()) {
      final cached = Get.find<ProfileController>().profileData.value;
      if (cached != null) return cached;
    }
    final res = await (_profileRepository ?? ProfileRepository())
        .fetchProfile();
    return res.data;
  }

  // ── Actions ───────────────────────────────────────────────────
  void selectRole(PartnerRole? role) {
    selectedRole.value = role;
    roleError.value = null;
  }

  void applyAgain() => applyingAgain.value = true;

  Future<void> captureLocation() async {
    if (isLocating.value) return;
    isLocating.value = true;
    try {
      final gps = GpsLocationService.to;
      final ok = await gps.getCurrentLocation();
      if (ok) {
        latitude.value = gps.latitude.value;
        longitude.value = gps.longitude.value;
      } else {
        CustomSnackbar.show(
          message: appL10n.partnerLocationFailed,
          type: SnackbarType.error,
        );
        if (gps.permissionDenied.value) await gps.openAppSettings();
      }
    } finally {
      isLocating.value = false;
    }
  }

  void clearLocation() {
    latitude.value = null;
    longitude.value = null;
  }

  /// Validates every field and publishes the per-field error messages.
  bool _validate() {
    roleError.value = selectedRole.value == null
        ? appL10n.partnerSelectRole
        : null;
    businessNameError.value = businessNameCtrl.text.trim().length < 2
        ? appL10n.partnerEnterBusinessName
        : null;
    final aadhaar = aadhaarCtrl.text.replaceAll(RegExp(r'\s'), '');
    // Optional, but when given it must be a valid 12-digit number (cannot start with 0/1).
    aadhaarError.value =
        aadhaar.isNotEmpty && !RegExp(r'^[2-9]\d{11}$').hasMatch(aadhaar)
        ? appL10n.partnerInvalidAadhaar
        : null;
    return roleError.value == null &&
        businessNameError.value == null &&
        aadhaarError.value == null;
  }

  Future<void> submit() async {
    if (isSubmitting.value) return;
    if (!_validate()) return;

    final p = profile.value;
    if (p == null) return;

    // Without GPS, fall back to the city/state already on the profile so the
    // request still carries a location.
    final noGps = !hasLocation;
    final payload = PartnerRequestPayload(
      userId: p.userId,
      role: selectedRole.value!.apiValue,
      name: name,
      mobileNumber: mobile,
      businessName: businessNameCtrl.text.trim(),
      aadhaarNumber: aadhaarCtrl.text.replaceAll(RegExp(r'\s'), ''),
      latitude: latitude.value,
      longitude: longitude.value,
      location: addressCtrl.text.trim(),
      city: noGps ? p.city : null,
      state: noGps ? p.state : null,
    );

    isSubmitting.value = true;
    try {
      final result = await _dataSource.submit(payload);
      if (result.success && result.data != null) {
        myRequest.value = result.data;
        applyingAgain.value = false;
        CustomSnackbar.show(
          message: appL10n.partnerSubmittedTitle,
          type: SnackbarType.success,
        );
      } else if (result.errorCode == 'PARTNER_REQUEST_EXISTS') {
        // Already applied (e.g. from another device) — show its status instead.
        myRequest.value = await _dataSource.fetchMyRequest();
        applyingAgain.value = false;
      } else {
        CustomSnackbar.show(
          message: result.message.isNotEmpty
              ? result.message
              : appL10n.partnerSubmitFailed,
          type: SnackbarType.error,
        );
      }
    } catch (e) {
      LoggerService.to.error('PartnerController.submit error: $e');
      CustomSnackbar.show(
        message: e.toString().replaceFirst('Exception: ', ''),
        type: SnackbarType.error,
      );
    } finally {
      isSubmitting.value = false;
    }
  }
}
