import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_extensions.dart';
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
            _buildLabel(context.l10n.insVehicleNumberLabel),
            SizedBox(height: 6.h),
            Obx(
              () => CustomInputField(
                controller: controller.vehicleNoController,
                placeholder: context.l10n.insEnterVehicleNo,
                prefixIcon: Icons.local_shipping_outlined,
                errorText: controller.vehicleNoError.value.isNotEmpty
                    ? _getErrorMessage(context, controller.vehicleNoError.value)
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
              ),
            ),
            SizedBox(height: 16.h),

            // ── RC Document ─────────────────────────────────────
            Obx(
              () => CustomFileUploadField(
                title: context.l10n.insRcDocumentLabel,
                label: context.l10n.insFileUploadLabel,
                subtitle: context.l10n.insFileUploadSubtitle,
                icon: Icons.cloud_upload,
                onTap: () => controller.pickFiles(controller.rcCopyFiles),
                files: controller.rcCopyFiles.toList(),
                onRemove: (index) =>
                    controller.removeFile(controller.rcCopyFiles, index),
                errorText: controller.rcFileError.value.isNotEmpty
                    ? _getErrorMessage(context, controller.rcFileError.value)
                    : null,
              ),
            ),
            SizedBox(height: 16.h),

            // ── Previous Year Policy ────────────────────────────
            Obx(
              () => CustomFileUploadField(
                title: context.l10n.insPreviousYearPolicy,
                label: context.l10n.insFileUploadLabel,
                subtitle: context.l10n.insFileUploadSubtitle,
                icon: Icons.cloud_upload,
                onTap: () =>
                    controller.pickFiles(controller.previousPolicyFiles),
                files: controller.previousPolicyFiles.toList(),
                onRemove: (index) => controller.removeFile(
                  controller.previousPolicyFiles,
                  index,
                ),
                errorText: null,
              ),
            ),
            SizedBox(height: 16.h),

            // ── Insurance Type ──────────────────────────────────
            Obx(
              () => InlineDropdownField<String>(
                label: context.l10n.insInsuranceTypeLabel,
                value: controller.selectedInsuranceType.value.isNotEmpty
                    ? controller.selectedInsuranceType.value
                    : null,
                items: const ['comprehensive', 'third_party'],
                placeholder: context.l10n.selectInsuranceType,
                prefixIcon: Icons.shield_outlined,
                itemLabel: (item) => item == 'comprehensive'
                    ? context.l10n.comprehensive
                    : context.l10n.thirdParty,
                errorText: controller.insuranceTypeError.value.isNotEmpty
                    ? _getErrorMessage(
                        context,
                        controller.insuranceTypeError.value,
                      )
                    : null,
                onChanged: (value) {
                  controller.selectedInsuranceType.value = value ?? '';
                },
              ),
            ),
            SizedBox(height: 16.h),

            // ── Claim Status ────────────────────────────────────
            Obx(
              () => InlineDropdownField<String>(
                label: context.l10n.insClaimStatusLabel,
                value: controller.selectedClaim.value.isNotEmpty
                    ? controller.selectedClaim.value
                    : null,
                items: const ['yes', 'no'],
                placeholder: context.l10n.insSelectClaimStatus,
                prefixIcon: Icons.assignment_outlined,
                itemLabel: (item) =>
                    item == 'yes' ? context.l10n.yes : context.l10n.no,
                errorText: controller.claimError.value.isNotEmpty
                    ? _getErrorMessage(context, controller.claimError.value)
                    : null,
                onChanged: (value) {
                  controller.selectedClaim.value = value ?? '';
                },
              ),
            ),
            SizedBox(height: 16.h),

            // ── Aadhar Document ─────────────────────────────────
            Obx(
              () => CustomFileUploadField(
                title: context.l10n.aadharDocument,
                label: context.l10n.insFileUploadLabel,
                subtitle: context.l10n.insFileUploadSubtitle,
                icon: Icons.cloud_upload,
                onTap: () => controller.pickFiles(controller.aadharFiles),
                files: controller.aadharFiles.toList(),
                onRemove: (index) =>
                    controller.removeFile(controller.aadharFiles, index),
                errorText: null,
              ),
            ),
            SizedBox(height: 16.h),

            // ── PAN Document ────────────────────────────────────
            Obx(
              () => CustomFileUploadField(
                title: context.l10n.panDocument,
                label: context.l10n.insFileUploadLabel,
                subtitle: context.l10n.insFileUploadSubtitle,
                icon: Icons.cloud_upload,
                onTap: () => controller.pickFiles(controller.panFiles),
                files: controller.panFiles.toList(),
                onRemove: (index) =>
                    controller.removeFile(controller.panFiles, index),
                errorText: null,
              ),
            ),
            SizedBox(height: 16.h),

            // ── Terms & Conditions ──────────────────────────────
            Obx(
              () => Column(
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
                            controller.isTermsAccepted.value = value ?? false;
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
                                TextSpan(text: context.l10n.insAcceptThe),
                                TextSpan(
                                  text: context.l10n.terms,
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                                TextSpan(text: context.l10n.insAndConnector),
                                TextSpan(
                                  text: context.l10n.conditions,
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
                        _getErrorMessage(context, controller.termsError.value),
                        style: TextStyle(
                          color: AppColors.error,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // ── Submit Button (Gradient Filled) ─────────────────
            Obx(
              () => Center(
                child: GradientButton.filled(
                  text: context.l10n.submit,
                  onPressed: controller.isSubmitting.value
                      ? null
                      : () => controller.submitInsuranceRequest(),
                  width: double.infinity,
                  height: 48.h,
                ),
              ),
            ),
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

  String _getErrorMessage(BuildContext context, String errorKey) {
    switch (errorKey) {
      case 'vehicleNoRequired':
        return context.l10n.insErrVehicleNoRequired;
      case 'vehicleNoMinLength':
        return context.l10n.vehicleNumberMinLength;
      case 'rcFileRequired':
        return context.l10n.insErrRcRequired;
      case 'insuranceTypeRequired':
        return context.l10n.insErrInsuranceTypeRequired;
      case 'claimRequired':
        return context.l10n.insErrClaimRequired;
      case 'termsRequired':
        return context.l10n.termsAcceptanceRequired;
      default:
        return errorKey;
    }
  }
}
