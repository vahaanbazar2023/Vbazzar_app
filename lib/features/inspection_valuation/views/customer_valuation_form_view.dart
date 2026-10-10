import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/atoms/custom_loader.dart';
import '../../../core/design_system/molecules/custom_file_upload_field.dart';
import '../../../core/design_system/molecules/gradient_button.dart';
import '../../../core/design_system/molecules/inline_dropdown_field.dart';
import '../../../core/design_system/templates/app_layout.dart';
import '../../../theme/app_fonts.dart';
import '../controllers/inspection_valuation_controller.dart';
import '../data/models/valuation_dropdown_options.dart';
import '../../../core/extensions/context_extensions.dart';

/// Customer inspection request form.
/// Collects vehicle details, optional company info, and document uploads.
class CustomerValuationFormView extends GetView<InspectionValuationController> {
  const CustomerValuationFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: context.l10n.requestVehicleInspection,
      subtitle: '',
      showBack: true,
      body: Stack(
        children: [
          Form(
            key: controller.customerFormKey,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(context.l10n.inspVehicleDetailsSection),
                  _buildVehicleFields(),
                  SizedBox(height: 20.h),
                  _buildSectionHeader(context.l10n.inspCompanyDetailsOptional),
                  _buildCompanyFields(),
                  SizedBox(height: 20.h),
                  _buildSectionHeader(context.l10n.inspUploadDocuments),
                  _buildDocumentUploads(),
                  SizedBox(height: 24.h),
                  _buildSubmitButton(),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
          Obx(
            () => controller.isSubmitting.value
                ? CustomLoader.backdrop()
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Text(
        title,
        style: AppFonts.titleMedium.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildVehicleFields() {
    return Column(
      children: [
        _buildTextField(
          controller: controller.vehicleNoController,
          label: appL10n.inspVehicleRegistrationNumber,
          hint: appL10n.inspRegNumberHint,
          icon: Icons.directions_car,
          required: true,
          validator: (v) {
            if (v == null || v.trim().isEmpty) return appL10n.inspRequired;
            if (v.trim().length < 5) return appL10n.inspMin5Characters;
            return null;
          },
        ),
        SizedBox(height: 12.h),
        _buildTextField(
          controller: controller.chasisNoController,
          label: appL10n.inspChassisNumber,
          hint: appL10n.inspEnterChassisNumber,
          icon: Icons.confirmation_number_outlined,
          required: true,
          validator: (v) {
            if (v == null || v.trim().isEmpty) return appL10n.inspRequired;
            if (v.trim().length < 5) return appL10n.inspMin5Characters;
            return null;
          },
        ),
        SizedBox(height: 12.h),
        Obx(
          () => InlineDropdownField<String>(
            value: controller.selectedVehicleType.value.isEmpty
                ? null
                : controller.selectedVehicleType.value,
            items: controller.vehicleTypes,
            placeholder: appL10n.selectVehicleTypeFilter,
            label: appL10n.vehicleType,
            prefixIcon: Icons.local_shipping_outlined,
            errorText: controller.vehicleTypeError.value,
            itemLabel: (v) => v,
            isLoading: controller.isLoadingVehicleCategories.value,
            onChanged: (v) {
              controller.selectedVehicleType.value = v ?? '';
              controller.vehicleTypeError.value = '';
              // Fetch brands for selected category
              if (v != null && v.isNotEmpty) {
                final cat = controller.vehicleCategories.firstWhereOrNull(
                  (c) =>
                      (c['name'] ?? c['title'] ?? c['category_name'] ?? '') ==
                      v,
                );
                if (cat != null) {
                  final code =
                      (cat['category_code'] ?? cat['code'] ?? cat['id'] ?? '')
                          .toString();
                  controller.loadVehicleBrands(code);
                }
              }
            },
          ),
        ),
        SizedBox(height: 12.h),
        Obx(
          () => InlineDropdownField<String>(
            value: controller.selectedVehicleBrand.value.isEmpty
                ? null
                : controller.selectedVehicleBrand.value,
            items: controller.vehicleBrandNames,
            placeholder: appL10n.inspSelectVehicleBrand,
            label: appL10n.inspVehicleBrand,
            prefixIcon: Icons.branding_watermark_outlined,
            errorText: controller.vehicleBrandError.value,
            itemLabel: (v) => v,
            isLoading: controller.isLoadingVehicleBrands.value,
            onChanged: (v) {
              controller.selectedVehicleBrand.value = v ?? '';
              controller.vehicleBrandError.value = '';
            },
          ),
        ),
        SizedBox(height: 12.h),
        Obx(
          () => InlineDropdownField<LocationOption>(
            value: controller.selectedState.value,
            items: controller.states,
            placeholder: appL10n.selectState,
            label: appL10n.state,
            prefixIcon: Icons.map_outlined,
            errorText: controller.stateError.value,
            itemLabel: (s) => s.name,
            isLoading: controller.isLoadingStates.value,
            onChanged: (v) {
              if (v != null) {
                controller.loadCities(v.id);
              } else {
                controller.onStateChanged(null);
              }
              controller.stateError.value = '';
            },
          ),
        ),
        SizedBox(height: 12.h),
        Obx(
          () => InlineDropdownField<LocationOption>(
            value: controller.selectedCity.value,
            items: controller.filteredCities,
            placeholder: controller.selectedState.value == null
                ? appL10n.inspSelectStateFirst
                : appL10n.selectCity,
            label: appL10n.city,
            prefixIcon: Icons.location_city_outlined,
            errorText: controller.cityError.value,
            itemLabel: (c) => c.name,
            enabled: controller.selectedState.value != null,
            emptyMessage: appL10n.inspNoCitiesForState,
            onChanged: (v) {
              controller.selectedCity.value = v;
              controller.cityError.value = '';
            },
          ),
        ),
        SizedBox(height: 12.h),
        _buildTextField(
          controller: controller.ownerNumberController,
          label: appL10n.ownerMobileNumber,
          hint: appL10n.inspEnter10DigitMobile,
          icon: Icons.phone_outlined,
          required: true,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          validator: (v) {
            if (v == null || v.trim().isEmpty) return appL10n.inspRequired;
            if (!RegExp(r'^[6-9]\d{9}$').hasMatch(v.trim())) {
              return appL10n.inspEnterValid10DigitNumber;
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCompanyFields() {
    return _buildTextField(
      controller: controller.companyNameController,
      label: appL10n.companyName,
      hint: appL10n.inspEnterCompanyNameOptional,
      icon: Icons.business_outlined,
      required: false,
    );
  }

  Widget _buildDocumentUploads() {
    return Column(
      children: [
        Obx(() {
          // Access .length inside Obx to register reactive subscription
          final rcCount = controller.rcFiles.length;
          final rcErr = controller.rcFileError.value;
          return CustomFileUploadField(
            title: '${appL10n.rcDocument} *',
            label: rcCount > 0
                ? appL10n.inspFilesSelected(rcCount)
                : appL10n.inspChooseFiles,
            onTap: () => controller.pickFiles(
              controller.rcFiles,
              allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
              allowMultiple: true,
            ),
            files: controller.rcFiles.toList(),
            allowMultiple: true,
            onRemove: (index) {
              controller.rcFiles.removeAt(index);
            },
            errorText: rcErr.isNotEmpty ? rcErr : null,
          );
        }),
        SizedBox(height: 12.h),
        Obx(() {
          final insCount = controller.insuranceFiles.length;
          final insErr = controller.insuranceFileError.value;
          return CustomFileUploadField(
            title: appL10n.inspInsuranceDocument,
            label: insCount > 0
                ? appL10n.inspFilesSelected(insCount)
                : appL10n.inspChooseFiles,
            onTap: () => controller.pickFiles(
              controller.insuranceFiles,
              allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
              allowMultiple: true,
            ),
            files: controller.insuranceFiles.toList(),
            allowMultiple: true,
            onRemove: (index) {
              controller.insuranceFiles.removeAt(index);
            },
            errorText: insErr.isNotEmpty ? insErr : null,
          );
        }),
        SizedBox(height: 12.h),
        Obx(() {
          final gstCount = controller.companyGstFiles.length;
          final gstErr = controller.companyGstFileError.value;
          return CustomFileUploadField(
            title: appL10n.companyGst,
            label: gstCount > 0
                ? appL10n.inspFilesSelected(gstCount)
                : appL10n.inspChooseFiles,
            onTap: () => controller.pickFiles(
              controller.companyGstFiles,
              allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
              allowMultiple: true,
            ),
            files: controller.companyGstFiles.toList(),
            allowMultiple: true,
            onRemove: (index) {
              controller.companyGstFiles.removeAt(index);
            },
            errorText: gstErr.isNotEmpty ? gstErr : null,
          );
        }),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool required = true,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                label,
                style: AppFonts.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (required)
              Text(
                ' *',
                style: AppFonts.labelMedium.copyWith(color: AppColors.error),
              ),
          ],
        ),
        SizedBox(height: 6.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          style: AppFonts.bodyMedium.copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppFonts.bodyMedium.copyWith(
              color: AppColors.textDisabled,
            ),
            prefixIcon: Icon(icon, size: 20.r, color: AppColors.grey500),
            filled: true,
            fillColor: AppColors.grey50,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14.w,
              vertical: 14.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: const BorderSide(color: AppColors.grey300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: const BorderSide(color: AppColors.grey300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: const BorderSide(color: AppColors.error),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Obx(
      () => GradientButton.filled(
        text: appL10n.inspSubmitInspectionRequest,
        onPressed: controller.isSubmitting.value
            ? null
            : () => controller.submitCustomerForm(),
        width: double.infinity,
        height: 48.h,
        fontSize: 15.sp,
        isLoading: controller.isSubmitting.value,
      ),
    );
  }
}
