import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/buttons/primary_button.dart';
import '../../../core/design_system/molecules/custom_dropdown_field.dart';
import '../../../core/design_system/molecules/custom_input_field.dart';
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
            _buildLabel('RC Document *'),
            SizedBox(height: 6.h),
            _buildFileUploadArea(
              context: context,
              controller: controller,
              files: controller.rcCopyFiles,
              errorText: controller.rcFileError.value.isNotEmpty
                  ? _getErrorMessage(controller.rcFileError.value)
                  : null,
              onTap: () => controller.pickFiles(controller.rcCopyFiles),
              onRemove: (index) => controller.removeFile(
                  controller.rcCopyFiles, index),
              label: 'Upload RC Document',
            ),
            SizedBox(height: 16.h),

            // ── Previous Year Policy ────────────────────────────
            _buildLabel('Previous Year Policy'),
            SizedBox(height: 6.h),
            _buildFileUploadArea(
              context: context,
              controller: controller,
              files: controller.previousPolicyFiles,
              errorText: null,
              onTap: () =>
                  controller.pickFiles(controller.previousPolicyFiles),
              onRemove: (index) => controller.removeFile(
                  controller.previousPolicyFiles, index),
              label: 'Upload Previous Policy',
            ),
            SizedBox(height: 16.h),

            // ── Insurance Type ──────────────────────────────────
            _buildLabel('Insurance Type *'),
            SizedBox(height: 6.h),
            Obx(() => CustomDropdownField<String>(
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
            _buildLabel('Claim Status *'),
            SizedBox(height: 6.h),
            Obx(() => CustomDropdownField<String>(
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
            _buildLabel('Aadhar Document'),
            SizedBox(height: 6.h),
            _buildFileUploadArea(
              context: context,
              controller: controller,
              files: controller.aadharFiles,
              errorText: null,
              onTap: () => controller.pickFiles(controller.aadharFiles),
              onRemove: (index) =>
                  controller.removeFile(controller.aadharFiles, index),
              label: 'Upload Aadhar Document',
            ),
            SizedBox(height: 16.h),

            // ── PAN Document ────────────────────────────────────
            _buildLabel('PAN Document'),
            SizedBox(height: 6.h),
            _buildFileUploadArea(
              context: context,
              controller: controller,
              files: controller.panFiles,
              errorText: null,
              onTap: () => controller.pickFiles(controller.panFiles),
              onRemove: (index) =>
                  controller.removeFile(controller.panFiles, index),
              label: 'Upload PAN Document',
            ),
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

            // ── Submit Button ───────────────────────────────────
            Obx(() => PrimaryButton(
                  label: controller.isSubmitting.value
                      ? 'Submitting Request...'
                      : 'Submit',
                  onPressed: controller.isSubmitting.value
                      ? null
                      : () => controller.submitInsuranceRequest(),
                  isLoading: controller.isSubmitting.value,
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

  Widget _buildFileUploadArea({
    required BuildContext context,
    required InsuranceFinanceController controller,
    required List files,
    required String? errorText,
    required VoidCallback onTap,
    required Function(int) onRemove,
    required String label,
  }) {
    return Obx(() {
      final hasFiles = files.isNotEmpty;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 14.h,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: errorText != null
                      ? AppColors.error
                      : AppColors.grey300,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(12.r),
                color: AppColors.grey50,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.cloud_upload_outlined,
                    color: AppColors.textSecondary,
                    size: 20.sp,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      hasFiles ? files.first.name : label,
                      style: AppFonts.bodyMedium.copyWith(
                        color: hasFiles
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                        fontSize: 13.sp,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (hasFiles)
                    GestureDetector(
                      onTap: () => onRemove(0),
                      child: Icon(
                        Icons.close,
                        color: AppColors.error,
                        size: 18.sp,
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (errorText != null)
            Padding(
              padding: EdgeInsets.only(top: 6.h, left: 4.w),
              child: Text(
                errorText,
                style: TextStyle(
                  color: AppColors.error,
                  fontSize: 12.sp,
                ),
              ),
            ),
        ],
      );
    });
  }
}