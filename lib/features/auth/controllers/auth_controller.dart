import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/localisation/app_localizations.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/location_service.dart';
import '../../../core/models/location_models.dart';
import '../../../core/design_system/design_system.dart';
import '../data/auth_data_source.dart';
import '../repositories/auth_repository.dart';
import '../models/otp_response.dart';
import '../models/otp_verify_models.dart';
import '../models/complete_profile_models.dart';
import '../../../routes/app_routes.dart';
import '../../language/controllers/language_controller.dart';

class AuthController extends GetxController {
  AuthRepository? _authRepository;
  AuthRepository get authRepository => _authRepository ??= AuthRepository();

  LocationService get locationService => LocationService.to;

  // ── Text controllers ──────────────────────────────────────────
  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  // Complete-profile form controllers
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();

  // ── Reactive state ────────────────────────────────────────────
  final errorText = Rxn<String>();
  final isLoading = false.obs;
  final phoneText = ''.obs;
  final otpText = ''.obs;
  final transactionId = Rxn<String>();
  final userId = Rxn<String>();

  // Complete-profile form state
  final firstNameText = ''.obs;
  final lastNameText = ''.obs;
  final emailText = ''.obs;
  final firstNameErrorText = Rxn<String>();
  final emailErrorText = Rxn<String>();
  final selectedState = Rxn<StateModel>();
  final selectedCity = Rxn<CityModel>();
  final stateErrorText = Rxn<String>();
  final cityErrorText = Rxn<String>();
  final availableStates = <StateModel>[].obs;
  final availableCities = <CityModel>[].obs;
  final isLoadingStates = false.obs;
  final isLoadingCities = false.obs;

  // OTP timer
  final otpTimer = 120.obs;
  final canResendOtp = false.obs;
  Timer? _timer;

  // ── Computed ──────────────────────────────────────────────────
  bool get isPhoneValid => phoneText.value.trim().length >= 10;

  bool get isCompleteProfileFormValid =>
      firstNameText.value.trim().length >= 3 &&
      emailText.value.trim().isNotEmpty &&
      selectedState.value != null &&
      selectedCity.value != null &&
      firstNameErrorText.value == null &&
      emailErrorText.value == null &&
      stateErrorText.value == null &&
      cityErrorText.value == null;

  String get formattedTimer {
    final m = (otpTimer.value ~/ 60).toString().padLeft(2, '0');
    final s = (otpTimer.value % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // ── Listener callbacks ────────────────────────────────────────
  void _phoneListener() {
    try {
      phoneText.value = phoneController.text;
    } catch (_) {}
  }

  void _otpListener() {
    try {
      otpText.value = otpController.text;
    } catch (_) {}
  }

  void _firstNameListener() {
    try {
      firstNameText.value = firstNameController.text;
      _validateFirstName();
    } catch (_) {}
  }

  void _emailListener() {
    try {
      emailText.value = emailController.text;
      _validateEmail();
    } catch (_) {}
  }

  @override
  void onInit() {
    super.onInit();
    phoneController.addListener(_phoneListener);
    otpController.addListener(_otpListener);
    firstNameController.addListener(_firstNameListener);
    emailController.addListener(_emailListener);
  }

  @override
  void onClose() {
    phoneController.removeListener(_phoneListener);
    otpController.removeListener(_otpListener);
    firstNameController.removeListener(_firstNameListener);
    emailController.removeListener(_emailListener);

    phoneController.dispose();
    otpController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    _timer?.cancel();
    super.onClose();
  }

  // ── Validation helpers ────────────────────────────────────────
  void _validateFirstName() {
    final v = firstNameText.value.trim();
    if (v.isEmpty) {
      firstNameErrorText.value = null;
      return;
    }
    if (v.length < 3) {
      firstNameErrorText.value = 'Min 3 characters';
      return;
    }
    firstNameErrorText.value = null;
  }

  void _validateEmail() {
    final v = emailText.value.trim();
    if (v.isEmpty) {
      emailErrorText.value = null;
      return;
    }
    final ok = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(v);
    emailErrorText.value = ok ? null : 'Enter a valid email';
  }

  String? validatePhoneNumber(BuildContext context, String? value) {
    final l10n = LanguageController.to.getLocalizations(context);
    if (value == null || value.trim().isEmpty)
      return l10n.pleaseEnterYourPhoneNumber;
    if (value.trim().length < 10) return l10n.pleaseEnterValidPhoneNumber;
    return null;
  }

  void onPhoneChanged(String value) {
    if (errorText.value != null) errorText.value = null;
  }

  // ── OTP timer ─────────────────────────────────────────────────
  void _startOtpTimer() {
    _timer?.cancel();
    otpTimer.value = 120;
    canResendOtp.value = false;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (otpTimer.value > 0) {
        otpTimer.value--;
      } else {
        canResendOtp.value = true;
        t.cancel();
      }
    });
  }

  // ── Send OTP (/api/v2/auth/login) ─────────────────────────────
  Future<void> sendOtp(BuildContext context) async {
    errorText.value = null;
    isLoading.value = true;

    final phone = phoneController.text.trim();
    final validationError = validatePhoneNumber(context, phone);
    if (validationError != null) {
      errorText.value = validationError;
      isLoading.value = false;
      CustomSnackbar.show(message: validationError, type: SnackbarType.error);
      return;
    }

    try {
      final fcmToken = NotificationService.instance.fcmToken ?? '';
      LoggerService.to.info('Sending OTP to: $phone');

      final OtpResponse response = await authRepository.sendOtp(
        phone: phone,
        fcmToken: fcmToken,
      );

      if (response.isSuccess && response.data != null) {
        transactionId.value = response.data!.transactionId;
        userId.value = response.data!.userId;
        otpController.clear();
        _startOtpTimer();

        if (Get.currentRoute != AppRoutes.verifyOtp) {
          Get.toNamed(AppRoutes.verifyOtp);
        }
        CustomSnackbar.show(
          message: response.message,
          type: SnackbarType.success,
        );
      } else {
        errorText.value = response.message;
        CustomSnackbar.show(
          message: response.message,
          type: SnackbarType.error,
        );
      }
    } on NetworkException catch (e) {
      errorText.value = e.toString();
      CustomSnackbar.show(message: e.toString(), type: SnackbarType.error);
    } on ValidationException catch (e) {
      errorText.value = e.toString();
      CustomSnackbar.show(message: e.toString(), type: SnackbarType.error);
    } catch (e) {
      LoggerService.to.error('sendOtp error: $e');
      errorText.value = 'Failed to send OTP. Please try again.';
      CustomSnackbar.show(message: errorText.value!, type: SnackbarType.error);
    } finally {
      isLoading.value = false;
    }
  }

  // ── Resend OTP ────────────────────────────────────────────────
  Future<void> resendOtp() async {
    try {
      isLoading.value = true;
      final phone = phoneController.text.trim();
      if (phone.isEmpty) {
        CustomSnackbar.show(
          message: 'Phone number not found. Please go back and try again.',
          type: SnackbarType.error,
        );
        return;
      }
      final fcmToken = NotificationService.instance.fcmToken ?? '';
      final OtpResponse response = await authRepository.sendOtp(
        phone: phone,
        fcmToken: fcmToken,
      );
      if (response.isSuccess && response.data != null) {
        transactionId.value = response.data!.transactionId;
        userId.value = response.data!.userId;
        otpController.clear();
        _startOtpTimer();
        CustomSnackbar.show(
          message: response.message.isNotEmpty
              ? response.message
              : 'OTP resent successfully',
          type: SnackbarType.success,
        );
      } else {
        CustomSnackbar.show(
          message: response.message.isNotEmpty
              ? response.message
              : 'Failed to resend OTP.',
          type: SnackbarType.error,
        );
      }
    } on NetworkException catch (e) {
      CustomSnackbar.show(message: e.toString(), type: SnackbarType.error);
    } catch (e) {
      LoggerService.to.error('resendOtp error: $e');
      CustomSnackbar.show(
        message: 'Failed to resend OTP. Please try again.',
        type: SnackbarType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ── Verify OTP (/api/v2/auth/verify-otp) ─────────────────────
  Future<void> verifyOtp(BuildContext context, String otp) async {
    final l10n = AppLocalizations.of(context)!;
    errorText.value = null;
    isLoading.value = true;

    try {
      if (!_isValidOtp(otp))
        throw ValidationException(l10n.otpVerificationFailed);
      if (transactionId.value == null || transactionId.value!.isEmpty) {
        throw ValidationException(l10n.transactionIdNotFound);
      }

      final phone = phoneController.text.trim();
      if (phone.isEmpty)
        throw ValidationException(l10n.pleaseEnterYourPhoneNumber);

      final uid = userId.value;
      if (uid == null || uid.isEmpty) {
        throw ValidationException('Session expired. Please go back and retry.');
      }

      final fcmToken = NotificationService.instance.fcmToken;
      LoggerService.to.info(
        'Verifying OTP for transaction: ${transactionId.value}',
      );

      final OtpVerifyResponse response = await authRepository.verifyOtp(
        userId: uid,
        phone: phone,
        otpCode: otp,
        transactionId: transactionId.value!,
        fcmToken: fcmToken,
      );

      if (response.isSuccess && response.data != null) {
        final data = response.data!;
        LoggerService.to.info(
          'OTP verified. profileCompleted=${data.profileCompleted}',
        );
        _clearTransactionData();

        CustomSnackbar.show(
          message: response.message.isNotEmpty
              ? response.message
              : l10n.otpVerifiedSuccessfully,
          type: SnackbarType.success,
        );

        if (data.profileCompleted) {
          Get.offAllNamed(AppRoutes.home);
        } else {
          Get.offAllNamed(AppRoutes.completeProfile);
        }
      } else {
        errorText.value = response.message.isNotEmpty
            ? response.message
            : l10n.otpVerificationFailed;
        CustomSnackbar.show(
          message: errorText.value!,
          type: SnackbarType.error,
        );
      }
    } on ValidationException catch (e) {
      errorText.value = e.message;
      CustomSnackbar.show(message: e.message, type: SnackbarType.error);
    } on AuthException catch (e) {
      errorText.value = e.message;
      CustomSnackbar.show(message: e.message, type: SnackbarType.error);
    } on NetworkException catch (e) {
      errorText.value = e.message;
      CustomSnackbar.show(message: l10n.networkError, type: SnackbarType.error);
    } catch (e, stack) {
      LoggerService.to.error('verifyOtp error', e, stack);
      errorText.value = l10n.otpVerificationFailed;
      CustomSnackbar.show(
        message: l10n.otpVerificationFailed,
        type: SnackbarType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ── Complete Profile (/api/v2/auth/complete-profile) ──────────
  Future<void> completeProfile(BuildContext context) async {
    _validateFirstName();
    _validateEmail();
    validateState();
    validateCity();

    if (firstNameText.value.trim().length < 3) {
      firstNameErrorText.value = 'Min 3 characters';
    }
    if (emailText.value.trim().isEmpty) {
      emailErrorText.value = 'Email is required';
    }

    if (!isCompleteProfileFormValid) {
      CustomSnackbar.show(
        message: 'Please fill in all required fields correctly',
        type: SnackbarType.error,
      );
      return;
    }

    isLoading.value = true;
    try {
      // Prefer in-memory value; fall back to secure storage (survives hot reload / controller recreation)
      String uid = userId.value ?? '';
      if (uid.isEmpty) {
        uid = await authRepository.getUserId() ?? '';
      }
      if (uid.isEmpty)
        throw Exception('User session expired. Please login again.');

      final request = CompleteProfileRequest(
        userId: uid,
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        email: emailController.text.trim(),
        state: selectedState.value!.stateName,
        city: selectedCity.value!.cityName,
      );

      final response = await authRepository.completeProfile(request);

      if (response.isSuccess) {
        await authRepository.markProfileCompleted();
        LoggerService.to.info('Profile completed for user: $uid');
        CustomSnackbar.show(
          message: response.message.isNotEmpty
              ? response.message
              : 'Profile completed!',
          type: SnackbarType.success,
        );
        Get.offAllNamed(AppRoutes.home);
      } else {
        CustomSnackbar.show(
          message: response.message.isNotEmpty
              ? response.message
              : 'Failed to save profile.',
          type: SnackbarType.error,
        );
      }
    } on NetworkException catch (e) {
      CustomSnackbar.show(message: e.toString(), type: SnackbarType.error);
    } on ValidationException catch (e) {
      CustomSnackbar.show(message: e.toString(), type: SnackbarType.error);
    } catch (e) {
      LoggerService.to.error('completeProfile error: $e');
      CustomSnackbar.show(
        message: 'Failed to save profile. Please try again.',
        type: SnackbarType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ── Location helpers ──────────────────────────────────────────
  Future<void> fetchStates() async {
    try {
      isLoadingStates.value = true;
      stateErrorText.value = null;
      final states = await locationService.fetchStates();
      availableStates.value = states;
    } catch (e) {
      stateErrorText.value = 'Failed to load states';
      CustomSnackbar.show(
        message: 'Failed to load states. Please try again.',
        type: SnackbarType.error,
      );
    } finally {
      isLoadingStates.value = false;
    }
  }

  void onStateSelected(StateModel? state) {
    selectedState.value = state;
    stateErrorText.value = null;
    selectedCity.value = null;
    availableCities.clear();
    cityErrorText.value = null;
    if (state != null) fetchCitiesForState(state.stateId);
  }

  Future<void> fetchCitiesForState(String stateId) async {
    try {
      isLoadingCities.value = true;
      cityErrorText.value = null;
      final cities = await locationService.fetchCities(stateId);
      availableCities.value = cities;
    } catch (e) {
      cityErrorText.value = 'Failed to load cities';
      CustomSnackbar.show(
        message: 'Failed to load cities. Please try again.',
        type: SnackbarType.error,
      );
    } finally {
      isLoadingCities.value = false;
    }
  }

  void onCitySelected(CityModel? city) {
    selectedCity.value = city;
    cityErrorText.value = null;
  }

  bool validateState() {
    if (selectedState.value == null) {
      stateErrorText.value = 'Please select a state';
      return false;
    }
    stateErrorText.value = null;
    return true;
  }

  bool validateCity() {
    if (selectedCity.value == null) {
      cityErrorText.value = 'Please select a city';
      return false;
    }
    cityErrorText.value = null;
    return true;
  }

  // ── Internal helpers ──────────────────────────────────────────
  bool _isValidOtp(String otp) {
    final clean = otp.trim();
    return clean.isNotEmpty &&
        RegExp(r'^\d+$').hasMatch(clean) &&
        clean.length >= 4 &&
        clean.length <= 8;
  }

  void _clearTransactionData() {
    transactionId.value = null;
    otpController.clear();
  }
}
