import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/molecules/gradient_button.dart';
import '../../../core/design_system/molecules/custom_file_upload_field.dart';
import '../../../core/design_system/molecules/custom_input_field.dart';
import '../../../core/design_system/molecules/inline_dropdown_field.dart';
import '../../../theme/app_fonts.dart';
import '../controllers/insurance_finance_controller.dart';

/// Insurance form tab content.
///
/// Contains all form fields for submitting a vehicle insurance request:
/// Vehicle Number, RC Document, Previous Year Policy, Insurance Type,
/// Claim Status, Aadhar, PAN, and Terms & Conditions.
class InsuranceFormView extends StatelessWidget {
  const InsuranceFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<InsuranceFinanceController>();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Vehicle Number ──────────────────────────────────
            _buildLabel('Vehicle Number *'),
            SizedBox(height: 6.h),
            Obx(() => CustomInputField(
                  controller: controller.vehicleNoController,
                  placeholder: 'Enter Vehicle No',
                  prefixIcon: Icons.local_shipping_outlined,
                  errorText: controller.vehicleNoError.value.isNotEmpty
                      ? _getErrorMessage(controller.vehicleNoError.value)
                      : null,
                  onChanged: (value) => controller.validateVehicleNo(value),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      return newValue.copyWith(
                        text: newValue.text.toUpperCase(),
                        selection: newValue.selection,
                      );
                    }),
                  ],
                )),
            SizedBox(height: 16.h),

            // ── RC Document ─────────────────────────────────────
            Obx(() => CustomFileUploadField(
                  title: 'RC Document *',
                  label: 'Choose a file/browse multiple files',
                  subtitle: 'JPEG, PNG & PDF (up to 12 MB)',
                  icon: Icons.cloud_upload,
                  onTap: () => controller.pickFiles(controller.rcCopyFiles),
                  files: controller.rcCopyFiles.toList(),
                  onRemove: (index) => controller.removeFile(
                      controller.rcCopyFiles, index),
                  errorText: controller.rcFileError.value.isNotEmpty
                      ? _getErrorMessage(controller.rcFileError.value)
                      : null,
                )),
            SizedBox(height: 16.h),

            // ── Previous Year Policy ────────────────────────────
            Obx(() => CustomFileUploadField(
                  title: 'Previous Year Policy',
                  label: 'Choose a file/browse multiple files',
                  subtitle: 'JPEG, PNG & PDF (up to 12 MB)',
                  icon: Icons.cloud_upload,
                  onTap: () =>
                      controller.pickFiles(controller.previousPolicyFiles),
                  files: controller.previousPolicyFiles.toList(),
                  onRemove: (index) => controller.removeFile(
                      controller.previousPolicyFiles, index),
                  errorText: null,
                )),
            SizedBox(height: 16.h),

            // ── Insurance Type ──────────────────────────────────
            Obx(() => InlineDropdownField<String>(
                  label: 'Insurance Type *',
                  value: controller.selectedInsuranceType.value.isNotEmpty
                      ? controller.selectedInsuranceType.value
                      : null,
                  items: const ['comprehensive', 'third_party'],
                  placeholder: 'Select Insurance Type',
                  prefixIcon: Icons.shield_outlined,
                  itemLabel: (item) =>
                      item == 'comprehensive' ? 'Comprehensive' : 'Third Party',
                  errorText:
                      controller.insuranceTypeError.value.isNotEmpty
                          ? _getErrorMessage(
                              controller.insuranceTypeError.value)
                          : null,
                  onChanged: (value) {
                    controller.selectedInsuranceType.value = value ?? '';
                  },
                )),
            SizedBox(height: 16.h),

            // ── Claim Status ────────────────────────────────────
            Obx(() => InlineDropdownField<String>(
                  label: 'Claim Status *',
                  value: controller.selectedClaim.value.isNotEmpty
                      ? controller.selectedClaim.value
                      : null,
                  items: const ['yes', 'no'],
                  placeholder: 'Select Claim Status',
                  prefixIcon: Icons.assignment_outlined,
                  itemLabel: (item) =>
                      item == 'yes' ? 'Yes' : 'No',
                  errorText: controller.claimError.value.isNotEmpty
                      ? _getErrorMessage(controller.claimError.value)
                      : null,
                  onChanged: (value) {
                    controller.selectedClaim.value = value ?? '';
                  },
                )),
            SizedBox(height: 16.h),

            // ── Aadhar Document ─────────────────────────────────
            Obx(() => CustomFileUploadField(
                  title: 'Aadhar Document',
                  label: 'Choose a file/browse multiple files',
                  subtitle: 'JPEG, PNG & PDF (up to 12 MB)',
                  icon: Icons.cloud_upload,
                  onTap: () => controller.pickFiles(controller.aadharFiles),
                  files: controller.aadharFiles.toList(),
                  onRemove: (index) =>
                      controller.removeFile(controller.aadharFiles, index),
                  errorText: null,
                )),
            SizedBox(height: 16.h),

            // ── PAN Document ────────────────────────────────────
            Obx(() => CustomFileUploadField(
                  title: 'PAN Document',
                  label: 'Choose a file/browse multiple files',
                  subtitle: 'JPEG, PNG & PDF (up to 12 MB)',
                  icon: Icons.cloud_upload,
                  onTap: () => controller.pickFiles(controller.panFiles),
                  files: controller.panFiles.toList(),
                  onRemove: (index) =>
                      controller.removeFile(controller.panFiles, index),
                  errorText: null,
                )),
            SizedBox(height: 16.h),

            // ── Terms & Conditions ──────────────────────────────
            Obx(() => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 24.w,
                          height: 24.w,
                          child: Checkbox(
                            value: controller.isTermsAccepted.value,
                            onChanged: (value) {
                              controller.isTermsAccepted.value =
                                  value ?? false;
                            },
                            activeColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              controller.isTermsAccepted.value =
                                  !controller.isTermsAccepted.value;
                            },
                            child: RichText(
                              text: TextSpan(
                                style: AppFonts.bodyMedium.copyWith(
                                  color: AppColors.textPrimary,
                                  fontSize: 13.sp,
                                ),
                                children: [
                                  const TextSpan(text: 'I Accept the '),
                                  TextSpan(
                                    text: 'Terms',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                  const TextSpan(text: ' and '),
                                  TextSpan(
                                    text: 'Conditions',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (controller.termsError.value.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 6.h, left: 32.w),
                        child: Text(
                          _getErrorMessage(controller.termsError.value),
                          style: TextStyle(
                            color: AppColors.error,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                  ],
                )),
            SizedBox(height: 24.h),

            // ── Submit Button (Gradient Filled) ─────────────────
            Obx(() => Center(
                  child: GradientButton.filled(
                    text: 'Submit',
                    onPressed: controller.isSubmitting.value
                        ? null
                        : () => controller.submitInsuranceRequest(),
                    width: double.infinity,
                    height: 48.h,
                  ),
                )),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  // ── Helper widgets ──────────────────────────────────────────────

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: AppFonts.labelLarge.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        fontSize: 14.sp,
      ),
    );
  }

  String _getErrorMessage(String errorKey) {
    switch (errorKey) {
      case 'vehicleNoRequired':
        return 'Please enter vehicle registration number';
      case 'vehicleNoMinLength':
        return 'Vehicle number must be at least 6 characters';
      case 'rcFileRequired':
        return 'Please upload RC document';
      case 'insuranceTypeRequired':
        return 'Please select insurance type';
      case 'claimRequired':
        return 'Please select claim status';
      case 'termsRequired':
        return 'Please accept terms and conditions';
      default:
        return errorKey;
    }
  }
}