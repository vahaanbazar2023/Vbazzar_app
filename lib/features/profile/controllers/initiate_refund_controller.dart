import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/design_system/organisms/app_bottom_nav_bar.dart';
import '../../../routes/app_routes.dart';
import '../../home/views/main_shell_screen.dart';
import '../repositories/profile_repository.dart';

class InitiateRefundController extends GetxController {
  final ProfileRepository _repository;

  InitiateRefundController({ProfileRepository? repository})
    : _repository = repository ?? ProfileRepository();

  // ── Form controllers ────────────────────────────────────────
  final accHolderNameController = TextEditingController();
  final accountNumberController = TextEditingController();
  final bankNameController = TextEditingController();
  final branchNameController = TextEditingController();
  final ifscCodeController = TextEditingController();
  final refundTypeController = TextEditingController();

  // ── User ID (auto-filled) ──────────────────────────────────
  final userId = ''.obs;

  // ── Observable state ────────────────────────────────────────
  final isSubmitting = false.obs;
  final _isFormValid = false.obs;

  bool get isFormValid => _isFormValid.value;

  void _updateFormValidity() {
    _isFormValid.value =
        accHolderNameController.text.trim().isNotEmpty &&
        accountNumberController.text.trim().isNotEmpty &&
        bankNameController.text.trim().isNotEmpty &&
        branchNameController.text.trim().isNotEmpty &&
        ifscCodeController.text.trim().isNotEmpty &&
        refundTypeController.text.trim().isNotEmpty &&
        userId.value.isNotEmpty;
  }

  // ── Lifecycle ───────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    accHolderNameController.addListener(_updateFormValidity);
    accountNumberController.addListener(_updateFormValidity);
    bankNameController.addListener(_updateFormValidity);
    branchNameController.addListener(_updateFormValidity);
    ifscCodeController.addListener(_updateFormValidity);
    refundTypeController.addListener(_updateFormValidity);
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    userId.value = await _repository.getUserId();
    _updateFormValidity();
  }

  @override
  void onClose() {
    accHolderNameController.dispose();
    accountNumberController.dispose();
    bankNameController.dispose();
    branchNameController.dispose();
    ifscCodeController.dispose();
    refundTypeController.dispose();
    super.onClose();
  }

  // ── Submit ──────────────────────────────────────────────────
  Future<void> submitRefund() async {
    if (!isFormValid) {
      CustomSnackbar.show(
        message: 'Please fill in all required fields',
        type: SnackbarType.error,
      );
      return;
    }

    isSubmitting.value = true;
    try {
      final response = await _repository.initiateRefund(
        accHolderName: accHolderNameController.text.trim(),
        accountNumber: accountNumberController.text.trim(),
        bankName: bankNameController.text.trim(),
        branchName: branchNameController.text.trim(),
        ifscCode: ifscCodeController.text.trim(),
        refundType: refundTypeController.text.trim(),
      );

      final success = response['success'] as bool? ?? false;
      final message = response['message'] as String? ?? 'Refund request submitted';

      if (success) {
        CustomSnackbar.show(
          message: message,
          type: SnackbarType.success,
        );
        // Navigate to home and switch to categories tab
        Get.offAllNamed(AppRoutes.home);
        Future.delayed(const Duration(milliseconds: 100), () {
          final shell = Get.find<MainShellController>();
          shell.switchTab(BottomNavTab.categories);
        });
      } else {
        CustomSnackbar.show(
          message: message,
          type: SnackbarType.error,
        );
      }
    } catch (e) {
      LoggerService.to.error('submitRefund error: $e');
      CustomSnackbar.show(
        message: 'Failed to initiate refund. Please try again.',
        type: SnackbarType.error,
      );
    } finally {
      isSubmitting.value = false;
    }
  }
}