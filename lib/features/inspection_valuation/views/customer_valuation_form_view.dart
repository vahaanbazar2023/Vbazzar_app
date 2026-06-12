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

/// Customer inspection request form.
/// Collects vehicle details, optional company info, and document uploads.
class CustomerValuationFormView extends GetView<InspectionValuationController> {
  const CustomerValuationFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: 'Request Vehicle Inspection',
      subtitle:
          '',
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
                  _buildSectionHeader('Vehicle Details'),
                  _buildVehicleFields(),
                  SizedBox(height: 20.h),
                  _buildSectionHeader('Company Details (Optional)'),
                  _buildCompanyFields(),
                  SizedBox(height: 20.h),
                  _buildSectionHeader('Upload Documents'),
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
          label: 'Vehicle Registration Number',
          hint: 'e.g. MH-01-AB-1234',
          icon: Icons.directions_car,
          required: true,
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Required';
            if (v.trim().length < 5) return 'Min 5 characters';
            return null;
          },
        ),
        SizedBox(height: 12.h),
        _buildTextField(
          controller: controller.chasisNoController,
          label: 'Chassis Number',
          hint: 'Enter chassis number',
          icon: Icons.confirmation_number_outlined,
          required: true,
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Required';
            if (v.trim().length < 5) return 'Min 5 characters';
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
            placeholder: 'Select Vehicle Type',
            label: 'Vehicle Type',
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
            placeholder: 'Select Vehicle Brand',
            label: 'Vehicle Brand',
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
            placeholder: 'Select State',
            label: 'State',
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
                ? 'Select state first'
                : 'Select City',
            label: 'City',
            prefixIcon: Icons.location_city_outlined,
            errorText: controller.cityError.value,
            itemLabel: (c) => c.name,
            enabled: controller.selectedState.value != null,
            emptyMessage: 'No cities available for selected state',
            onChanged: (v) {
              controller.selectedCity.value = v;
              controller.cityError.value = '';
            },
          ),
        ),
        SizedBox(height: 12.h),
        _buildTextField(
          controller: controller.ownerNumberController,
          label: 'Owner Mobile Number',
          hint: 'Enter 10-digit mobile number',
          icon: Icons.phone_outlined,
          required: true,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Required';
            if (!RegExp(r'^[6-9]\d{9}$').hasMatch(v.trim())) {
              return 'Enter valid 10-digit number';
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
      label: 'Company Name',
      hint: 'Enter company name (optional)',
      icon: Icons.business_outlined,
      required: false,
    );
  }

  Widget _buildDocumentUploads() {
    return Column(
      children: [
        Obx(
          () => CustomFileUploadField(
            title: 'RC Document *',
            label: 'Choose a file/browse multiple files',
            onTap: () => controller.pickFiles(
              controller.rcFiles,
              allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
              allowMultiple: true,
            ),
            files: controller.rcFiles,
            allowMultiple: true,
            onRemove: (index) {
              controller.rcFiles.removeAt(index);
            },
            errorText: controller.rcFileError.value.isNotEmpty
                ? controller.rcFileError.value
                : null,
          ),
        ),
        SizedBox(height: 12.h),
        Obx(
          () => CustomFileUploadField(
            title: 'Insurance Document',
            label: 'Choose a file/browse multiple files',
            onTap: () => controller.pickFiles(
              controller.insuranceFiles,
              allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
              allowMultiple: true,
            ),
            files: controller.insuranceFiles,
            allowMultiple: true,
            onRemove: (index) {
              controller.insuranceFiles.removeAt(index);
            },
            errorText: controller.insuranceFileError.value.isNotEmpty
                ? controller.insuranceFileError.value
                : null,
          ),
        ),
        SizedBox(height: 12.h),
        Obx(
          () => CustomFileUploadField(
            title: 'Company GST',
            label: 'Choose a file/browse multiple files',
            onTap: () => controller.pickFiles(
              controller.companyGstFiles,
              allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
              allowMultiple: true,
            ),
            files: controller.companyGstFiles,
            allowMultiple: true,
            onRemove: (index) {
              controller.companyGstFiles.removeAt(index);
            },
            errorText: controller.companyGstFileError.value.isNotEmpty
                ? controller.companyGstFileError.value
                : null,
          ),
        ),
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
            Text(
              label,
              style: AppFonts.labelMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
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
        text: 'Submit Inspection Request',
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
