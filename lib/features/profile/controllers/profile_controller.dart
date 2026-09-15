import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/services/location_service.dart';
import '../../../core/models/location_models.dart';
import '../../../core/design_system/design_system.dart';
import '../../../routes/app_routes.dart';
import '../models/profile_models.dart';
import '../models/wallet_models.dart';
import '../repositories/profile_repository.dart';

class ProfileController extends GetxController {
  final ProfileRepository _repository;

  ProfileController({ProfileRepository? repository})
    : _repository = repository ?? ProfileRepository();

  // ── Profile data ──────────────────────────────────────────────
  final profileData = Rxn<ProfileData>();
  final isLoading = false.obs;
  final isRefreshing = false.obs;

  // ── Wallet data ──────────────────────────────────────────────
  final walletData = Rxn<WalletDashboardData>();
  final isLoadingWallet = false.obs;

  // ── Manage Profile form ───────────────────────────────────────
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController stateTextController = TextEditingController();
  TextEditingController cityTextController = TextEditingController();

  final firstNameText = ''.obs;
  final lastNameText = ''.obs;
  final emailText = ''.obs;
  final phoneNumberText = ''.obs;

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
  final isUpdatingProfile = false.obs;

  LocationService get locationService => LocationService.to;

  bool get isManageProfileFormValid =>
      firstNameText.value.trim().length >= 3 &&
      emailText.value.trim().isNotEmpty &&
      selectedState.value != null &&
      selectedCity.value != null &&
      firstNameErrorText.value == null &&
      emailErrorText.value == null &&
      stateErrorText.value == null &&
      cityErrorText.value == null;

  // ── Lifecycle ─────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    firstNameController.addListener(_firstNameListener);
    emailController.addListener(_emailListener);
    fetchProfile();
  }

  @override
  void onClose() {
    firstNameController.removeListener(_firstNameListener);
    emailController.removeListener(_emailListener);
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    stateTextController.dispose();
    cityTextController.dispose();
    super.onClose();
  }

  // ── Listeners ─────────────────────────────────────────────────
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

  // ── Validation ────────────────────────────────────────────────
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

  // ── Fetch profile ─────────────────────────────────────────────
  Future<void> fetchProfile() async {
    isLoading.value = true;
    try {
      final response = await _repository.fetchProfile();
      if (response.isSuccess && response.data != null) {
        profileData.value = response.data;
      }
    } catch (e) {
      LoggerService.to.error('fetchProfile error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshProfile() async {
    isRefreshing.value = true;
    try {
      final response = await _repository.fetchProfile();
      if (response.isSuccess && response.data != null) {
        profileData.value = response.data;
      }
    } catch (e) {
      LoggerService.to.error('refreshProfile error: $e');
    } finally {
      isRefreshing.value = false;
    }
  }

  // ── Navigate to Manage Profile ────────────────────────────────
  Future<void> openManageProfile() async {
    Get.toNamed(AppRoutes.manageProfile);
  }

  // ── Initialize manage profile form ────────────────────────────

  /// Synchronously recreates all form TextEditingControllers.
  /// Call this BEFORE building the form widget tree (e.g. in initState)
  /// so widgets never receive a disposed controller instance.
  void recreateFormControllers() {
    try {
      firstNameController.removeListener(_firstNameListener);
      emailController.removeListener(_emailListener);
      firstNameController.dispose();
      lastNameController.dispose();
      emailController.dispose();
      phoneNumberController.dispose();
      stateTextController.dispose();
      cityTextController.dispose();
    } catch (_) {}
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    emailController = TextEditingController();
    phoneNumberController = TextEditingController();
    stateTextController = TextEditingController();
    cityTextController = TextEditingController();
    firstNameController.addListener(_firstNameListener);
    emailController.addListener(_emailListener);
  }

  Future<void> initManageProfileForm() async {
    // Fetch states first
    await fetchStates();

    // Pre-fill form from profile data
    final p = profileData.value;
    if (p != null) {
      firstNameController.text = p.firstName;
      lastNameController.text = p.lastName;
      emailController.text = p.email;
      phoneNumberController.text = p.phoneNumber;
      firstNameText.value = p.firstName;
      lastNameText.value = p.lastName;
      emailText.value = p.email;
      phoneNumberText.value = p.phoneNumber;

      // Try to match state
      if (p.state.isNotEmpty) {
        final match = availableStates.firstWhereOrNull(
          (s) => s.stateName.toLowerCase() == p.state.toLowerCase(),
        );
        if (match != null) {
          selectedState.value = match;
          stateTextController.text = match.stateName;
          await fetchCitiesForState(match.stateId);
          // Try to match city
          if (p.city.isNotEmpty) {
            final cityMatch = availableCities.firstWhereOrNull(
              (c) => c.cityName.toLowerCase() == p.city.toLowerCase(),
            );
            if (cityMatch != null) {
              selectedCity.value = cityMatch;
              cityTextController.text = cityMatch.cityName;
            }
          }
        }
      }
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
    cityTextController.clear();
    availableCities.clear();
    cityErrorText.value = null;
    if (state != null) {
      stateTextController.text = state.stateName;
      fetchCitiesForState(state.stateId);
    } else {
      stateTextController.clear();
    }
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
    if (city != null) {
      cityTextController.text = city.cityName;
    } else {
      cityTextController.clear();
    }
  }

  // ── Update profile ────────────────────────────────────────────
  Future<void> updateProfile() async {
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

    if (!isManageProfileFormValid) {
      CustomSnackbar.show(
        message: 'Please fill in all required fields correctly',
        type: SnackbarType.error,
      );
      return;
    }

    isUpdatingProfile.value = true;
    try {
      final response = await _repository.updateProfile(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        email: emailController.text.trim(),
        state: selectedState.value?.stateName ?? '',
        city: selectedCity.value?.cityName ?? '',
      );

      if (response.isSuccess) {
        // Update local profile data
        if (response.data != null) {
          profileData.value = response.data;
        } else {
          // Refresh from API if response doesn't include updated data
          await refreshProfile();
        }
        CustomSnackbar.show(
          message: response.message.isNotEmpty
              ? response.message
              : 'Profile updated successfully!',
          type: SnackbarType.success,
        );
        Get.offAllNamed(AppRoutes.home);
      } else {
        CustomSnackbar.show(
          message: response.message.isNotEmpty
              ? response.message
              : 'Failed to update profile.',
          type: SnackbarType.error,
        );
      }
    } catch (e) {
      LoggerService.to.error('updateProfile error: $e');
      CustomSnackbar.show(
        message: 'Failed to update profile. Please try again.',
        type: SnackbarType.error,
      );
    } finally {
      isUpdatingProfile.value = false;
    }
  }

  // ── Fetch wallet dashboard ───────────────────────────────────
  Future<void> fetchWalletDashboard() async {
    isLoadingWallet.value = true;
    try {
      final response = await _repository.fetchWalletDashboard();
      if (response.isSuccess && response.data != null) {
        walletData.value = response.data;
      }
    } catch (e) {
      LoggerService.to.error('fetchWalletDashboard error: $e');
    } finally {
      isLoadingWallet.value = false;
    }
  }

  // ── Cash-Out ──────────────────────────────────────────────────
  final cashOutEligibility = Rxn<CashOutEligibility>();
  final isLoadingCashOutEligibility = false.obs;
  final cashOutHistory = <CashOutHistoryEntry>[].obs;
  final isLoadingCashOutHistory = false.obs;
  final isSubmittingCashOut = false.obs;

  // ── Coin Conversion ───────────────────────────────────────────
  final coinConversionEligibility = Rxn<CoinConversionEligibility>();
  final isLoadingCoinEligibility = false.obs;
  final isConvertingCoins = false.obs;

  Future<void> fetchCashOutEligibility() async {
    isLoadingCashOutEligibility.value = true;
    try {
      cashOutEligibility.value = await _repository.fetchCashOutEligibility();
    } catch (e) {
      LoggerService.to.error('fetchCashOutEligibility error: $e');
    } finally {
      isLoadingCashOutEligibility.value = false;
    }
  }

  Future<bool> requestCashOut(CashOutRequest request) async {
    isSubmittingCashOut.value = true;
    try {
      final result = await _repository.requestCashOut(request);
      final status = result['status'] as String? ?? '';
      final isSuccess =
          status == 'success' ||
          (result['code'] as int? ?? 0) == 200 ||
          (result['code'] as int? ?? 0) == 201;
      if (isSuccess) {
        // Refresh wallet and history after successful cash-out
        await Future.wait([fetchWalletDashboard(), fetchCashOutHistory()]);
        CustomSnackbar.show(
          message: result['message'] as String? ?? 'Cash-out request placed!',
          type: SnackbarType.success,
        );
        return true;
      } else {
        CustomSnackbar.show(
          message: result['message'] as String? ?? 'Cash-out request failed.',
          type: SnackbarType.error,
        );
        return false;
      }
    } catch (e) {
      LoggerService.to.error('requestCashOut error: $e');
      CustomSnackbar.show(
        message: e.toString().replaceFirst('Exception: ', ''),
        type: SnackbarType.error,
      );
      return false;
    } finally {
      isSubmittingCashOut.value = false;
    }
  }

  Future<void> fetchCashOutHistory() async {
    isLoadingCashOutHistory.value = true;
    try {
      cashOutHistory.value = await _repository.fetchCashOutHistory();
    } catch (e) {
      LoggerService.to.error('fetchCashOutHistory error: $e');
    } finally {
      isLoadingCashOutHistory.value = false;
    }
  }

  Future<void> fetchCoinConversionEligibility() async {
    isLoadingCoinEligibility.value = true;
    try {
      coinConversionEligibility.value = await _repository
          .fetchCoinConversionEligibility();
    } catch (e) {
      LoggerService.to.error('fetchCoinConversionEligibility error: $e');
    } finally {
      isLoadingCoinEligibility.value = false;
    }
  }

  Future<bool> convertCoins(int coinAmount) async {
    isConvertingCoins.value = true;
    try {
      final result = await _repository.convertCoinsToWallet(coinAmount);
      final status = result['status'] as String? ?? '';
      final isSuccess =
          status == 'success' || (result['code'] as int? ?? 0) == 200;
      final message =
          result['message'] as String? ?? result['error'] as String? ?? '';
      if (isSuccess) {
        await fetchWalletDashboard();
        CustomSnackbar.show(
          message: message.isNotEmpty ? message : 'Coins converted!',
          type: SnackbarType.success,
        );
        return true;
      } else {
        CustomSnackbar.show(
          message: message.isNotEmpty ? message : 'Conversion failed.',
          type: SnackbarType.error,
        );
        return false;
      }
    } catch (e) {
      LoggerService.to.error('convertCoins error: $e');
      CustomSnackbar.show(
        message: e.toString().replaceFirst('Exception: ', ''),
        type: SnackbarType.error,
      );
      return false;
    } finally {
      isConvertingCoins.value = false;
    }
  }

  // ── Logout ────────────────────────────────────────────────────
  /// Called directly after user confirms logout in the UI.
  /// No dialog here — the caller (_LogoutButton) handles confirmation.
  Future<void> logout() async {
    _repository.logout().catchError((Object e) {
      LoggerService.to.error('logout error: $e');
      return LogoutResponse(status: 'error', code: 0, message: e.toString());
    }).ignore();
    Get.offAllNamed(AppRoutes.login);
  }
}
