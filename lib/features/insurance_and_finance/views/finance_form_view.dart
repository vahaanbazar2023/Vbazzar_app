import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/buttons/primary_button.dart';
import '../../../core/design_system/molecules/custom_autocomplete_field.dart';
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
            _buildLabel('Vehicle Number *'),
            SizedBox(height: 6.h),
            Obx(() => CustomInputField(
                  controller: controller.vehicleNoFinanceController,
                  placeholder: 'Enter Vehicle No',
                  prefixIcon: Icons.local_shipping_outlined,
                  errorText: controller.financeVehicleNoError.value.isNotEmpty
                      ? _getErrorMessage(
                          controller.financeVehicleNoError.value)
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
                )),
            SizedBox(height: 16.h),

            // ── State Autocomplete ──────────────────────────────
            _buildLabel('State *'),
            SizedBox(height: 6.h),
            Obx(() => CustomAutocompleteField<StateModel>(
                  controller: controller.stateController,
                  options: controller.states.toList(),
                  placeholder: 'Select State',
                  prefixIcon: Icons.location_on_outlined,
                  isLoading: controller.isLoadingStates.value,
                  emptyMessage: 'No states available',
                  displayStringForOption: (state) => state.stateName,
                  errorText: controller.stateError.value.isNotEmpty
                      ? _getErrorMessage(controller.stateError.value)
                      : null,
                  onSelected: (state) {
                    if (state != null) {
                      controller.selectStateForFinance(state);
                    } else {
                      controller.clearStateForFinance();
                    }
                  },
                )),
            SizedBox(height: 16.h),

            // ── City Autocomplete ───────────────────────────────
            _buildLabel('City *'),
            SizedBox(height: 6.h),
            Obx(() => CustomAutocompleteField<CityModel>(
                  controller: controller.cityController,
                  options: controller.cities.toList(),
                  placeholder: 'Select City',
                  prefixIcon: Icons.location_city_outlined,
                  isLoading: controller.isLoadingCities.value,
                  emptyMessage: controller.selectedFinanceState.value == null
                      ? 'Please select a state first'
                      : 'No cities available',
                  enabled: controller.selectedFinanceState.value != null,
                  displayStringForOption: (city) => city.cityName,
                  errorText: controller.cityError.value.isNotEmpty
                      ? _getErrorMessage(controller.cityError.value)
                      : null,
                  onSelected: (city) {
                    if (city != null) {
                      controller.selectCityForFinance(city);
                    } else {
                      controller.clearCityForFinance();
                    }
                  },
                )),
            SizedBox(height: 16.h),

            // ── RC Copy ─────────────────────────────────────────
            _buildLabel('RC Copy *'),
            SizedBox(height: 6.h),
            _buildFileUploadArea(
              context: context,
              controller: controller,
              files: controller.rcCopyFinanceFiles,
              errorText: controller.rcFinanceFileError.value.isNotEmpty
                  ? _getErrorMessage(
                      controller.rcFinanceFileError.value)
                  : null,
              onTap: () =>
                  controller.pickFiles(controller.rcCopyFinanceFiles),
              onRemove: (index) => controller.removeFile(
                  controller.rcCopyFinanceFiles, index),
              label: 'Upload RC Copy',
            ),
            SizedBox(height: 16.h),

            // ── Insurance Copy ──────────────────────────────────
            _buildLabel('Insurance Copy *'),
            SizedBox(height: 6.h),
            _buildFileUploadArea(
              context: context,
              controller: controller,
              files: controller.insuranceCopyFiles,
              errorText:
                  controller.insuranceFinanceFileError.value.isNotEmpty
                      ? _getErrorMessage(
                          controller.insuranceFinanceFileError.value)
                      : null,
              onTap: () =>
                  controller.pickFiles(controller.insuranceCopyFiles),
              onRemove: (index) => controller.removeFile(
                  controller.insuranceCopyFiles, index),
              label: 'Upload Insurance Copy',
            ),
            SizedBox(height: 16.h),

            // ── Fleet Size (optional) ───────────────────────────
            _buildLabel('Fleet Size'),
            SizedBox(height: 6.h),
            CustomInputField(
              controller: controller.fleetSizeController,
              placeholder: 'Enter Fleet Size',
              prefixIcon: Icons.local_shipping_outlined,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
            SizedBox(height: 16.h),

            // ── Company GST (optional) ──────────────────────────
            _buildLabel('Company GST (if Available)'),
            SizedBox(height: 6.h),
            _buildFileUploadArea(
              context: context,
              controller: controller,
              files: controller.companyGstFiles,
              errorText: null,
              onTap: () =>
                  controller.pickFiles(controller.companyGstFiles),
              onRemove: (index) => controller.removeFile(
                  controller.companyGstFiles, index),
              label: 'Upload Company GST',
            ),
            SizedBox(height: 16.h),

            // ── Vehicle Location ────────────────────────────────
            _buildLabel('Vehicle Location *'),
            SizedBox(height: 6.h),
            Obx(() => CustomInputField(
                  controller: controller.vehicleLocationController,
                  placeholder: 'Enter Vehicle Location',
                  prefixIcon: Icons.location_on_outlined,
                  errorText:
                      controller.vehicleLocationError.value.isNotEmpty
                          ? _getErrorMessage(
                              controller.vehicleLocationError.value)
                          : null,
                )),
            SizedBox(height: 24.h),

            // ── Section Header: Applicant Details ───────────────
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 8.h),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.grey200,
                    width: 1,
                  ),
                ),
              ),
              child: Text(
                'Applicant Details',
                style: AppFonts.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  fontSize: 16.sp,
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // ── Applicant Aadhar ────────────────────────────────
            _buildLabel('Aadhar Document *'),
            SizedBox(height: 6.h),
            _buildFileUploadArea(
              context: context,
              controller: controller,
              files: controller.aadharFinanceFiles,
              errorText:
                  controller.applicantAadharFileError.value.isNotEmpty
                      ? _getErrorMessage(
                          controller.applicantAadharFileError.value)
                      : null,
              onTap: () =>
                  controller.pickFiles(controller.aadharFinanceFiles),
              onRemove: (index) => controller.removeFile(
                  controller.aadharFinanceFiles, index),
              label: 'Upload Aadhar Document',
            ),
            SizedBox(height: 16.h),

            // ── Applicant PAN ───────────────────────────────────
            _buildLabel('PAN Document *'),
            SizedBox(height: 6.h),
            _buildFileUploadArea(
              context: context,
              controller: controller,
              files: controller.panFinanceFiles,
              errorText:
                  controller.applicantPanFileError.value.isNotEmpty
                      ? _getErrorMessage(
                          controller.applicantPanFileError.value)
                      : null,
              onTap: () =>
                  controller.pickFiles(controller.panFinanceFiles),
              onRemove: (index) => controller.removeFile(
                  controller.panFinanceFiles, index),
              label: 'Upload PAN Document',
            ),
            SizedBox(height: 16.h),

            // ── Applicant Mobile Number ─────────────────────────
            _buildLabel('Mobile Number *'),
            SizedBox(height: 6.h),
            Obx(() => CustomInputField(
                  controller: controller.mobileNumberController,
                  placeholder: 'Enter Mobile Number',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  errorText:
                      controller.mobileNumberError.value.isNotEmpty
                          ? _getErrorMessage(
                              controller.mobileNumberError.value)
                          : null,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                )),
            SizedBox(height: 24.h),

            // ── Co-Applicant Checkbox ───────────────────────────
            Obx(() => GestureDetector(
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
                            controller.isCoapplicant.value =
                                value ?? false;
                          },
                          activeColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Add Co-Applicant Details',
                        style: AppFonts.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )),
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
                        bottom: BorderSide(
                          color: AppColors.grey200,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Text(
                      'Co-Applicant Details',
                      style: AppFonts.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Co-Applicant Aadhar
                  _buildLabel('Aadhar Document *'),
                  SizedBox(height: 6.h),
                  _buildFileUploadArea(
                    context: context,
                    controller: controller,
                    files: controller.aadharCoApplicantFinanceFiles,
                    errorText: controller
                            .coApplicantAadharFileError.value.isNotEmpty
                        ? _getErrorMessage(
                            controller.coApplicantAadharFileError.value)
                        : null,
                    onTap: () => controller.pickFiles(
                        controller.aadharCoApplicantFinanceFiles),
                    onRemove: (index) => controller.removeFile(
                        controller.aadharCoApplicantFinanceFiles, index),
                    label: 'Upload Aadhar Document',
                  ),
                  SizedBox(height: 16.h),

                  // Co-Applicant PAN
                  _buildLabel('PAN Document *'),
                  SizedBox(height: 6.h),
                  _buildFileUploadArea(
                    context: context,
                    controller: controller,
                    files: controller.panCoApplicantFinanceFiles,
                    errorText: controller
                            .coApplicantPanFileError.value.isNotEmpty
                        ? _getErrorMessage(
                            controller.coApplicantPanFileError.value)
                        : null,
                    onTap: () => controller.pickFiles(
                        controller.panCoApplicantFinanceFiles),
                    onRemove: (index) => controller.removeFile(
                        controller.panCoApplicantFinanceFiles, index),
                    label: 'Upload PAN Document',
                  ),
                  SizedBox(height: 16.h),

                  // Co-Applicant Mobile Number
                  _buildLabel('Mobile Number *'),
                  SizedBox(height: 6.h),
                  Obx(() => CustomInputField(
                        controller:
                            controller.mobileCoApplicantNumberController,
                        placeholder: 'Enter Mobile Number',
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        errorText: controller
                                .coApplicantMobileError.value.isNotEmpty
                            ? _getErrorMessage(
                                controller.coApplicantMobileError.value)
                            : null,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                      )),
                  SizedBox(height: 24.h),
                ],
              );
            }),

            // ── Submit Button ───────────────────────────────────
            Obx(() => PrimaryButton(
                  label: controller.isSubmitting.value
                      ? 'Submitting Request...'
                      : 'Submit',
                  onPressed: controller.isSubmitting.value
                      ? null
                      : () => controller.submitFinanceRequest(),
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
      case 'stateRequired':
        return 'Please select state';
      case 'cityRequired':
        return 'Please select city';
      case 'rcFinanceFileRequired':
        return 'Please upload RC copy';
      case 'insuranceFinanceFileRequired':
        return 'Please upload insurance copy';
      case 'vehicleLocationRequired':
        return 'Please enter vehicle location';
      case 'applicantAadharFileRequired':
        return 'Please upload Aadhar document';
      case 'applicantPanFileRequired':
        return 'Please upload PAN document';
      case 'mobileNumberRequired':
        return 'Please enter mobile number';
      case 'coApplicantAadharFileRequired':
        return 'Please upload co-applicant Aadhar document';
      case 'coApplicantPanFileRequired':
        return 'Please upload co-applicant PAN document';
      case 'coApplicantMobileRequired':
        return 'Please enter co-applicant mobile number';
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