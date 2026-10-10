import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/design_system/molecules/gradient_button.dart';
import '../../../core/design_system/molecules/custom_autocomplete_field.dart';
import '../../../core/design_system/molecules/custom_file_upload_field.dart';
import '../../../core/design_system/molecules/custom_input_field.dart';
import '../../../core/models/location_models.dart';
import '../../../theme/app_fonts.dart';
import '../controllers/insurance_finance_controller.dart';

/// Finance form tab content.
///
/// Contains all form fields for submitting a vehicle finance request:
/// Vehicle Number, State, City, RC, Insurance Copy, Fleet Size,
/// Company GST, Vehicle Location, Applicant/Co-Applicant details.
class FinanceFormView extends StatelessWidget {
  const FinanceFormView({super.key});

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
                controller: controller.vehicleNoFinanceController,
                placeholder: context.l10n.insEnterVehicleNo,
                prefixIcon: Icons.local_shipping_outlined,
                errorText: controller.financeVehicleNoError.value.isNotEmpty
                    ? _getErrorMessage(
                        context,
                        controller.financeVehicleNoError.value,
                      )
                    : null,
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

            // ── State Autocomplete ──────────────────────────────
            _buildLabel(context.l10n.insStateLabel),
            SizedBox(height: 6.h),
            Obx(
              () => CustomAutocompleteField<StateModel>(
                controller: controller.stateController,
                options: controller.states.toList(),
                placeholder: context.l10n.selectState,
                prefixIcon: Icons.location_on_outlined,
                isLoading: controller.isLoadingStates.value,
                emptyMessage: context.l10n.insNoStatesAvailable,
                displayStringForOption: (state) => state.stateName,
                errorText: controller.stateError.value.isNotEmpty
                    ? _getErrorMessage(context, controller.stateError.value)
                    : null,
                onSelected: (state) {
                  if (state != null) {
                    controller.selectStateForFinance(state);
                  } else {
                    controller.clearStateForFinance();
                  }
                },
              ),
            ),
            SizedBox(height: 16.h),

            // ── City Autocomplete ───────────────────────────────
            _buildLabel(context.l10n.insCityLabel),
            SizedBox(height: 6.h),
            Obx(
              () => CustomAutocompleteField<CityModel>(
                controller: controller.cityController,
                options: controller.cities.toList(),
                placeholder: context.l10n.selectCity,
                prefixIcon: Icons.location_city_outlined,
                isLoading: controller.isLoadingCities.value,
                emptyMessage: controller.selectedFinanceState.value == null
                    ? context.l10n.insSelectStateFirst
                    : context.l10n.insNoCitiesAvailable,
                enabled: controller.selectedFinanceState.value != null,
                displayStringForOption: (city) => city.cityName,
                errorText: controller.cityError.value.isNotEmpty
                    ? _getErrorMessage(context, controller.cityError.value)
                    : null,
                onSelected: (city) {
                  if (city != null) {
                    controller.selectCityForFinance(city);
                  } else {
                    controller.clearCityForFinance();
                  }
                },
              ),
            ),
            SizedBox(height: 16.h),

            // ── RC Copy ─────────────────────────────────────────
            Obx(
              () => CustomFileUploadField(
                title: context.l10n.insRcCopyLabel,
                label: context.l10n.insFileUploadLabel,
                subtitle: context.l10n.insFileUploadSubtitle,
                icon: Icons.cloud_upload,
                onTap: () =>
                    controller.pickFiles(controller.rcCopyFinanceFiles),
                files: controller.rcCopyFinanceFiles.toList(),
                onRemove: (index) =>
                    controller.removeFile(controller.rcCopyFinanceFiles, index),
                errorText: controller.rcFinanceFileError.value.isNotEmpty
                    ? _getErrorMessage(
                        context,
                        controller.rcFinanceFileError.value,
                      )
                    : null,
              ),
            ),
            SizedBox(height: 16.h),

            // ── Insurance Copy ──────────────────────────────────
            Obx(
              () => CustomFileUploadField(
                title: context.l10n.insInsuranceCopyLabel,
                label: context.l10n.insFileUploadLabel,
                subtitle: context.l10n.insFileUploadSubtitle,
                icon: Icons.cloud_upload,
                onTap: () =>
                    controller.pickFiles(controller.insuranceCopyFiles),
                files: controller.insuranceCopyFiles.toList(),
                onRemove: (index) =>
                    controller.removeFile(controller.insuranceCopyFiles, index),
                errorText: controller.insuranceFinanceFileError.value.isNotEmpty
                    ? _getErrorMessage(
                        context,
                        controller.insuranceFinanceFileError.value,
                      )
                    : null,
              ),
            ),
            SizedBox(height: 16.h),

            // ── Fleet Size (optional) ───────────────────────────
            _buildLabel(context.l10n.insFleetSize),
            SizedBox(height: 6.h),
            CustomInputField(
              controller: controller.fleetSizeController,
              placeholder: context.l10n.insEnterFleetSize,
              prefixIcon: Icons.local_shipping_outlined,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            SizedBox(height: 16.h),

            // ── Company GST (optional) ──────────────────────────
            Obx(
              () => CustomFileUploadField(
                title: context.l10n.insCompanyGstIfAvailable,
                label: context.l10n.insFileUploadLabel,
                subtitle: context.l10n.insFileUploadSubtitle,
                icon: Icons.cloud_upload,
                onTap: () => controller.pickFiles(controller.companyGstFiles),
                files: controller.companyGstFiles.toList(),
                onRemove: (index) =>
                    controller.removeFile(controller.companyGstFiles, index),
                errorText: null,
              ),
            ),
            SizedBox(height: 16.h),

            // ── Vehicle Location ────────────────────────────────
            _buildLabel(context.l10n.insVehicleLocationLabel),
            SizedBox(height: 6.h),
            Obx(
              () => CustomInputField(
                controller: controller.vehicleLocationController,
                placeholder: context.l10n.enterVehicleLocation,
                prefixIcon: Icons.location_on_outlined,
                errorText: controller.vehicleLocationError.value.isNotEmpty
                    ? _getErrorMessage(
                        context,
                        controller.vehicleLocationError.value,
                      )
                    : null,
              ),
            ),
            SizedBox(height: 24.h),

            // ── Section Header: Applicant Details ───────────────
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 8.h),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.grey200, width: 1),
                ),
              ),
              child: Text(
                context.l10n.insApplicantDetails,
                style: AppFonts.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  fontSize: 16.sp,
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // ── Applicant Aadhar ────────────────────────────────
            Obx(
              () => CustomFileUploadField(
                title: context.l10n.insAadharDocumentLabel,
                label: context.l10n.insFileUploadLabel,
                subtitle: context.l10n.insFileUploadSubtitle,
                icon: Icons.cloud_upload,
                onTap: () =>
                    controller.pickFiles(controller.aadharFinanceFiles),
                files: controller.aadharFinanceFiles.toList(),
                onRemove: (index) =>
                    controller.removeFile(controller.aadharFinanceFiles, index),
                errorText: controller.applicantAadharFileError.value.isNotEmpty
                    ? _getErrorMessage(
                        context,
                        controller.applicantAadharFileError.value,
                      )
                    : null,
              ),
            ),
            SizedBox(height: 16.h),

            // ── Applicant PAN ───────────────────────────────────
            Obx(
              () => CustomFileUploadField(
                title: context.l10n.insPanDocumentLabel,
                label: context.l10n.insFileUploadLabel,
                subtitle: context.l10n.insFileUploadSubtitle,
                icon: Icons.cloud_upload,
                onTap: () => controller.pickFiles(controller.panFinanceFiles),
                files: controller.panFinanceFiles.toList(),
                onRemove: (index) =>
                    controller.removeFile(controller.panFinanceFiles, index),
                errorText: controller.applicantPanFileError.value.isNotEmpty
                    ? _getErrorMessage(
                        context,
                        controller.applicantPanFileError.value,
                      )
                    : null,
              ),
            ),
            SizedBox(height: 16.h),

            // ── Applicant Mobile Number ─────────────────────────
            _buildLabel(context.l10n.insMobileNumberLabel),
            SizedBox(height: 6.h),
            Obx(
              () => CustomInputField(
                controller: controller.mobileNumberController,
                placeholder: context.l10n.insEnterMobileNumber,
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                errorText: controller.mobileNumberError.value.isNotEmpty
                    ? _getErrorMessage(
                        context,
                        controller.mobileNumberError.value,
                      )
                    : null,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // ── Co-Applicant Checkbox ───────────────────────────
            Obx(
              () => GestureDetector(
                onTap: () {
                  controller.isCoapplicant.value =
                      !controller.isCoapplicant.value;
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 24.w,
                      height: 24.w,
                      child: Checkbox(
                        value: controller.isCoapplicant.value,
                        onChanged: (value) {
                          controller.isCoapplicant.value = value ?? false;
                        },
                        activeColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        context.l10n.insAddCoApplicantDetails,
                        style: AppFonts.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // ── Co-Applicant Section (conditional) ──────────────
            Obx(() {
              if (!controller.isCoapplicant.value) {
                return const SizedBox.shrink();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section header
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: AppColors.grey200, width: 1),
                      ),
                    ),
                    child: Text(
                      context.l10n.insCoApplicantDetails,
                      style: AppFonts.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Co-Applicant Aadhar
                  Obx(
                    () => CustomFileUploadField(
                      title: context.l10n.insAadharDocumentLabel,
                      label: context.l10n.insFileUploadLabel,
                      subtitle: context.l10n.insFileUploadSubtitle,
                      icon: Icons.cloud_upload,
                      onTap: () => controller.pickFiles(
                        controller.aadharCoApplicantFinanceFiles,
                      ),
                      files: controller.aadharCoApplicantFinanceFiles.toList(),
                      onRemove: (index) => controller.removeFile(
                        controller.aadharCoApplicantFinanceFiles,
                        index,
                      ),
                      errorText:
                          controller.coApplicantAadharFileError.value.isNotEmpty
                          ? _getErrorMessage(
                              context,
                              controller.coApplicantAadharFileError.value,
                            )
                          : null,
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Co-Applicant PAN
                  Obx(
                    () => CustomFileUploadField(
                      title: context.l10n.insPanDocumentLabel,
                      label: context.l10n.insFileUploadLabel,
                      subtitle: context.l10n.insFileUploadSubtitle,
                      icon: Icons.cloud_upload,
                      onTap: () => controller.pickFiles(
                        controller.panCoApplicantFinanceFiles,
                      ),
                      files: controller.panCoApplicantFinanceFiles.toList(),
                      onRemove: (index) => controller.removeFile(
                        controller.panCoApplicantFinanceFiles,
                        index,
                      ),
                      errorText:
                          controller.coApplicantPanFileError.value.isNotEmpty
                          ? _getErrorMessage(
                              context,
                              controller.coApplicantPanFileError.value,
                            )
                          : null,
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Co-Applicant Mobile Number
                  _buildLabel(context.l10n.insMobileNumberLabel),
                  SizedBox(height: 6.h),
                  Obx(
                    () => CustomInputField(
                      controller: controller.mobileCoApplicantNumberController,
                      placeholder: context.l10n.insEnterMobileNumber,
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      errorText:
                          controller.coApplicantMobileError.value.isNotEmpty
                          ? _getErrorMessage(
                              context,
                              controller.coApplicantMobileError.value,
                            )
                          : null,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),
                ],
              );
            }),

            // ── Submit Button (Gradient Filled) ─────────────────
            Obx(
              () => Center(
                child: GradientButton.filled(
                  text: context.l10n.submit,
                  onPressed: controller.isSubmitting.value
                      ? null
                      : () => controller.submitFinanceRequest(),
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
      case 'stateRequired':
        return context.l10n.insErrSelectState;
      case 'cityRequired':
        return context.l10n.insErrSelectCity;
      case 'rcFinanceFileRequired':
        return context.l10n.insErrUploadRcCopy;
      case 'insuranceFinanceFileRequired':
        return context.l10n.insErrUploadInsuranceCopy;
      case 'vehicleLocationRequired':
        return context.l10n.insErrEnterVehicleLocation;
      case 'applicantAadharFileRequired':
        return context.l10n.insErrUploadAadhar;
      case 'applicantPanFileRequired':
        return context.l10n.insErrUploadPan;
      case 'mobileNumberRequired':
        return context.l10n.insErrEnterMobile;
      case 'coApplicantAadharFileRequired':
        return context.l10n.insErrUploadCoAadhar;
      case 'coApplicantPanFileRequired':
        return context.l10n.insErrUploadCoPan;
      case 'coApplicantMobileRequired':
        return context.l10n.insErrEnterCoMobile;
      default:
        return errorKey;
    }
  }
}
