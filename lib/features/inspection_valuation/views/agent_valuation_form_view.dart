import 'package:file_picker/file_picker.dart';
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
import '../../../core/design_system/molecules/custom_year_picker.dart';
import '../../../theme/app_fonts.dart';
import '../controllers/agent_inspection_controller.dart';
import '../controllers/inspection_valuation_controller.dart';
import '../data/models/valuation_dropdown_options.dart';
import '../widgets/valuation_summary_card.dart';

/// Agent inspection form — single scrollable form with section headers.
class AgentValuationFormView extends GetView<AgentInspectionController> {
  const AgentValuationFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: 'Agent Inspection',
      subtitle: 'Fill out the inspection details for the customer',
      showBack: true,
      body: Stack(
        children: [
          Form(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Section 1: Vehicle Information ────────────────
                  _buildSectionHeader('Vehicle Information'),
                  _buildVehicleInfoSection(),
                  SizedBox(height: 24.h),

                  // ── Section 2: Documentation & Condition ─────────
                  _buildSectionHeader('Documentation & Condition'),
                  _buildDocumentationSection(),
                  SizedBox(height: 24.h),

                  // ── Section 3: Mechanical Inspection ─────────────
                  _buildSectionHeader('Mechanical Inspection'),
                  _buildMechanicalSection(),
                  SizedBox(height: 24.h),

                  // ── Section 4: Body & Interior ───────────────────
                  _buildSectionHeader('Body & Interior'),
                  _buildBodyInteriorSection(),
                  SizedBox(height: 24.h),

                  // ── Section 5: Photo Documentation ───────────────
                  _buildSectionHeader('Photo Documentation'),
                  _buildPhotosSection(),
                  SizedBox(height: 24.h),

                  // ── Section 6: Valuation ─────────────────────────
                  _buildSectionHeader('Valuation'),
                  _buildValuationSection(),
                  SizedBox(height: 20.h),
                  // _buildSectionHeader('Inspection Summary'),
                  // ValuationSummaryCard(controller: controller),
                  SizedBox(height: 24.h),

                  // ── Submit Button ────────────────────────────────
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

  // ══════════════════════════════════════════════════════════════════
  //  SECTION 1: Vehicle Information
  // ══════════════════════════════════════════════════════════════════

  Widget _buildVehicleInfoSection() {
    final parent = Get.find<InspectionValuationController>();
    return Column(
      children: [
        _buildTextField(
          controller: controller.ownerNameController,
          label: 'Owner Name',
          hint: 'Enter owner name',
          icon: Icons.person_outline,
          required: false,
        ),
        SizedBox(height: 12.h),
        _buildTextField(
          controller: controller.vehicleRegNoController,
          label: 'Vehicle Registration Number',
          hint: 'e.g. MH-01-AB-1234',
          icon: Icons.directions_car,
          required: true,
        ),
        SizedBox(height: 12.h),
        Obx(
          () => InlineDropdownField<String>(
            value: controller.selectedVehicleType.value.isEmpty
                ? null
                : controller.selectedVehicleType.value,
            items: parent.vehicleTypes,
            placeholder: 'Select Vehicle Type',
            label: 'Vehicle Type',
            prefixIcon: Icons.local_shipping_outlined,
            itemLabel: (v) => v,
            isLoading: parent.isLoadingVehicleCategories.value,
            onChanged: (v) {
              controller.selectedVehicleType.value = v ?? '';
              if (v != null && v.isNotEmpty) {
                final cat = parent.vehicleCategories.firstWhereOrNull(
                  (c) =>
                      (c['name'] ?? c['title'] ?? c['category_name'] ?? '') ==
                      v,
                );
                if (cat != null) {
                  final code =
                      (cat['category_code'] ?? cat['code'] ?? cat['id'] ?? '')
                          .toString();
                  parent.loadVehicleBrands(code);
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
            items: parent.vehicleBrandNames,
            placeholder: 'Select Vehicle Brand',
            label: 'Vehicle Brand',
            prefixIcon: Icons.branding_watermark_outlined,
            itemLabel: (v) => v,
            isLoading: parent.isLoadingVehicleBrands.value,
            onChanged: (v) => controller.selectedVehicleBrand.value = v ?? '',
          ),
        ),
        SizedBox(height: 12.h),
        Obx(
          () => InlineDropdownField<LocationOption>(
            value: controller.selectedState.value,
            items: parent.states,
            placeholder: 'Select State',
            label: 'State',
            prefixIcon: Icons.map_outlined,
            itemLabel: (s) => s.name,
            isLoading: parent.isLoadingStates.value,
            onChanged: (v) => controller.onStateChanged(v),
          ),
        ),
        SizedBox(height: 12.h),
        Obx(
          () => InlineDropdownField<LocationOption>(
            value: controller.selectedCity.value,
            items: controller.filteredCities.toList(),
            placeholder: controller.selectedState.value == null
                ? 'Select state first'
                : 'Select City',
            label: 'City',
            prefixIcon: Icons.location_city_outlined,
            itemLabel: (c) => c.name,
            isLoading: parent.isLoadingCities.value,
            enabled: controller.selectedState.value != null,
            emptyMessage: 'No cities available for selected state',
            onChanged: (v) => controller.selectedCity.value = v,
          ),
        ),
        SizedBox(height: 12.h),
        _buildTextField(
          controller: controller.chasisNumberController,
          label: 'Chassis Number',
          hint: 'Enter chassis number',
          icon: Icons.confirmation_number_outlined,
          required: false,
        ),
        SizedBox(height: 12.h),
        Obx(
          () => CustomYearPicker(
            labelText: 'Manufacturing Year',
            hintText: 'Select year',
            selectedYear: controller.selectedManufacturingYear.value,
            startYear: 1970,
            onYearSelected: (year) {
              controller.selectedManufacturingYear.value = year.isEmpty
                  ? null
                  : year;
              controller.manufacturingYearController.text = year;
            },
          ),
        ),
        SizedBox(height: 12.h),
        _buildTextField(
          controller: controller.engineNumberController,
          label: 'Engine Number',
          hint: 'Enter engine number',
          icon: Icons.engineering_outlined,
          required: false,
        ),
        SizedBox(height: 12.h),
        _buildTextField(
          controller: controller.rtoLocationController,
          label: 'RTO Location',
          hint: 'Enter RTO location',
          icon: Icons.location_on_outlined,
          required: false,
        ),
        SizedBox(height: 12.h),
        _buildTextField(
          controller: controller.ownerNumberController,
          label: 'Owner Mobile Number',
          hint: 'Enter 10-digit mobile number',
          icon: Icons.phone_outlined,
          required: false,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════
  //  SECTION 2: Documentation & Condition
  // ══════════════════════════════════════════════════════════════════

  Widget _buildDocumentationSection() {
    final parent = Get.find<InspectionValuationController>();
    return Column(
      children: [
        _buildTextField(
          controller: controller.vehicleConditionTextController,
          label: 'Vehicle Condition (Description)',
          hint: 'Describe the overall vehicle condition',
          icon: Icons.description_outlined,
          required: false,
        ),
        SizedBox(height: 12.h),
        Obx(
          () => InlineDropdownField<DropdownItem>(
            value: controller.selectedCondition.value.isEmpty
                ? null
                : parent.conditionOptions.firstWhereOrNull(
                    (d) => d.value == controller.selectedCondition.value,
                  ),
            items: parent.conditionOptions,
            placeholder: 'Select Condition',
            label: 'Vehicle Condition (Rating)',
            prefixIcon: Icons.rate_review_outlined,
            itemLabel: (v) => v.label,
            isLoading: parent.isDropdownLoading.value,
            onChanged: (v) =>
                controller.selectedCondition.value = v?.value ?? '',
          ),
        ),
        SizedBox(height: 12.h),
        Obx(
          () => _buildDatePickerField(
            label: 'Insurance Valid Till',
            value: controller.insuranceValidTill.value,
            icon: Icons.health_and_safety_outlined,
            onClear: controller.insuranceValidTill.value.isNotEmpty
                ? () => controller.insuranceValidTill.value = ''
                : null,
            onTap: () => _selectDate(controller.insuranceValidTill),
          ),
        ),
        SizedBox(height: 12.h),
        Obx(
          () => _buildDatePickerField(
            label: 'Fitness Valid Till',
            value: controller.fitnessValidTill.value,
            icon: Icons.fitness_center_outlined,
            onClear: controller.fitnessValidTill.value.isNotEmpty
                ? () => controller.fitnessValidTill.value = ''
                : null,
            onTap: () => _selectDate(controller.fitnessValidTill),
          ),
        ),
        SizedBox(height: 12.h),
        _buildTextField(
          controller: controller.taxPendingController,
          label: 'Tax Pending',
          hint: 'Enter pending tax amount/details',
          icon: Icons.receipt_long_outlined,
          required: false,
        ),
        SizedBox(height: 12.h),
        Obx(
          () => InlineDropdownField<DropdownItem>(
            value: controller.selectedHypothecation.value.isEmpty
                ? null
                : parent.hypothecationOptions.firstWhereOrNull(
                    (d) => d.value == controller.selectedHypothecation.value,
                  ),
            items: parent.hypothecationOptions,
            placeholder: 'Select Hypothecation',
            label: 'Hypothecation',
            prefixIcon: Icons.account_balance_outlined,
            itemLabel: (v) => v.label,
            isLoading: parent.isDropdownLoading.value,
            onChanged: (v) {
              controller.selectedHypothecation.value = v?.value ?? '';
              if (v?.value != 'yes') {
                controller.hypothecatedToController.clear();
              }
            },
          ),
        ),
        Obx(
          () => controller.selectedHypothecation.value == 'yes'
              ? Padding(
                  padding: EdgeInsets.only(top: 12.h),
                  child: _buildTextField(
                    controller: controller.hypothecatedToController,
                    label: 'Hypothecated To',
                    hint: 'Enter financier name',
                    icon: Icons.business_outlined,
                    required: false,
                  ),
                )
              : const SizedBox.shrink(),
        ),
        SizedBox(height: 12.h),
        Obx(
          () => InlineDropdownField<DropdownItem>(
            value: controller.selectedCaseType.value.isEmpty
                ? null
                : parent.caseTypes.firstWhereOrNull(
                    (d) => d.value == controller.selectedCaseType.value,
                  ),
            items: parent.caseTypes,
            placeholder: 'Select Case Type',
            label: 'Case Type',
            prefixIcon: Icons.cases_outlined,
            itemLabel: (v) => v.label,
            isLoading: parent.isDropdownLoading.value,
            onChanged: (v) => controller.selectedCaseType.value = v?.value ?? '',
          ),
        ),
        SizedBox(height: 12.h),
        _buildTextField(
          controller: controller.hoursController,
          label: 'Hours (for machinery)',
          hint: 'Enter operating hours',
          icon: Icons.timer_outlined,
          required: false,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        SizedBox(height: 12.h),
        _buildTextField(
          controller: controller.odometerController,
          label: 'Odometer (KM)',
          hint: 'Enter odometer reading',
          icon: Icons.speed_outlined,
          required: false,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        SizedBox(height: 12.h),
        Obx(
          () => InlineDropdownField<DropdownItem>(
            value: controller.selectedFuel.value.isEmpty
                ? null
                : parent.fuelTypes.firstWhereOrNull(
                    (d) => d.value == controller.selectedFuel.value,
                  ),
            items: parent.fuelTypes,
            placeholder: 'Select Fuel Type',
            label: 'Fuel Type',
            prefixIcon: Icons.local_gas_station_outlined,
            itemLabel: (v) => v.label,
            isLoading: parent.isDropdownLoading.value,
            onChanged: (v) => controller.selectedFuel.value = v?.value ?? '',
          ),
        ),
        SizedBox(height: 12.h),
        Obx(
          () => InlineDropdownField<DropdownItem>(
            value: controller.selectedTransmission.value.isEmpty
                ? null
                : parent.transmissionTypes.firstWhereOrNull(
                    (d) => d.value == controller.selectedTransmission.value,
                  ),
            items: parent.transmissionTypes,
            placeholder: 'Select Transmission',
            label: 'Transmission Type',
            prefixIcon: Icons.settings_outlined,
            itemLabel: (v) => v.label,
            isLoading: parent.isDropdownLoading.value,
            onChanged: (v) =>
                controller.selectedTransmission.value = v?.value ?? '',
          ),
        ),
        SizedBox(height: 12.h),
        Obx(
          () => InlineDropdownField<DropdownItem>(
            value: controller.selectedAccidentalStatus.value.isEmpty
                ? null
                : parent.accidentalStatusOptions.firstWhereOrNull(
                    (d) =>
                        d.value == controller.selectedAccidentalStatus.value,
                  ),
            items: parent.accidentalStatusOptions,
            placeholder: 'Select Accidental Status',
            label: 'Accidental Status',
            prefixIcon: Icons.warning_amber_outlined,
            itemLabel: (v) => v.label,
            isLoading: parent.isDropdownLoading.value,
            onChanged: (v) =>
                controller.selectedAccidentalStatus.value = v?.value ?? '',
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════
  //  SECTION 3: Mechanical Inspection
  // ══════════════════════════════════════════════════════════════════

  Widget _buildMechanicalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInspectionCard(
          title: 'Engine',
          icon: Icons.engineering_outlined,
          iconColor: const Color(0xFFE65100),
          condition: controller.engineCondition,
          remarksController: controller.engineRemarksController,
        ),
        SizedBox(height: 14.h),
        _buildInspectionCard(
          title: 'Transmission',
          icon: Icons.settings_suggest_outlined,
          iconColor: const Color(0xFF1565C0),
          condition: controller.transmissionCondition,
          remarksController: controller.transmissionRemarksController,
        ),
        SizedBox(height: 14.h),
        _buildInspectionCard(
          title: 'Suspension',
          icon: Icons.directions_car_outlined,
          iconColor: const Color(0xFF2E7D32),
          condition: controller.suspensionCondition,
          remarksController: controller.suspensionRemarksController,
        ),
        SizedBox(height: 14.h),
        _buildTyresCard(),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════
  //  SECTION 4: Body & Interior
  // ══════════════════════════════════════════════════════════════════

  Widget _buildBodyInteriorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInspectionCard(
          title: 'Body',
          icon: Icons.car_crash_outlined,
          iconColor: const Color(0xFF6A1B9A),
          condition: controller.bodyCondition,
          remarksController: controller.bodyRemarksController,
        ),
        SizedBox(height: 14.h),
        _buildInspectionCard(
          title: 'Cabin / Interior',
          icon: Icons.airline_seat_recline_normal_outlined,
          iconColor: const Color(0xFF00838F),
          condition: controller.cabinInteriorCondition,
          remarksController: controller.cabinInteriorRemarksController,
        ),
        SizedBox(height: 14.h),
        _buildInspectionCard(
          title: 'Electrical',
          icon: Icons.electrical_services_outlined,
          iconColor: const Color(0xFFF9A825),
          condition: controller.electricalCondition,
          remarksController: controller.electricalRemarksController,
        ),
        SizedBox(height: 14.h),
        _buildInspectionCard(
          title: 'Chassis',
          icon: Icons.view_carousel_outlined,
          iconColor: const Color(0xFF37474F),
          condition: controller.chasisCondition,
          remarksController: controller.chasisRemarksController,
        ),
        SizedBox(height: 14.h),
        _buildOdometerCard(),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════
  //  SECTION 5: Photo Documentation
  // ══════════════════════════════════════════════════════════════════

  Widget _buildPhotosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildImageUpload('Engine', controller.engineImages),
        SizedBox(height: 16.h),
        _buildImageUpload('Transmission', controller.transmissionImages),
        SizedBox(height: 16.h),
        _buildImageUpload('Suspension', controller.suspensionImages),
        SizedBox(height: 16.h),
        _buildImageUpload('Tyres', controller.tyreImages),
        SizedBox(height: 16.h),
        _buildSectionSubHeader('Body'),
        SizedBox(height: 8.h),
        _buildImageUpload('Body - Front', controller.bodyFrontImages),
        SizedBox(height: 12.h),
        _buildImageUpload('Body - Back', controller.bodyBackImages),
        SizedBox(height: 12.h),
        _buildImageUpload('Body - Left Side', controller.bodyLeftImages),
        SizedBox(height: 12.h),
        _buildImageUpload('Body - Right Side', controller.bodyRightImages),
        SizedBox(height: 16.h),
        _buildImageUpload('Cabin / Interior', controller.cabinInteriorImages),
        SizedBox(height: 16.h),
        _buildImageUpload('Electrical', controller.electricalImages),
        SizedBox(height: 16.h),
        _buildImageUpload('Chassis', controller.chasisImages),
        SizedBox(height: 16.h),
        _buildImageUpload('Odometer', controller.odometerImages),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════
  //  SECTION 6: Valuation
  // ══════════════════════════════════════════════════════════════════

  Widget _buildValuationSection() {
    return Column(
      children: [
        _buildTextField(
          controller: controller.assetMarketValueController,
          label: 'Asset Market Value (₹)',
          hint: 'Enter estimated market value',
          icon: Icons.currency_rupee,
          required: false,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
          ],
        ),
        SizedBox(height: 12.h),
        _buildTextField(
          controller: controller.otherRemarksController,
          label: 'Other Remarks',
          hint: 'Any additional observations or remarks',
          icon: Icons.notes_outlined,
          required: false,
          maxLines: 3,
        ),
        SizedBox(height: 12.h),
        _buildTextField(
          controller: controller.webUrlController,
          label: 'Report URL',
          hint: 'External inspection report URL (if any)',
          icon: Icons.link_outlined,
          required: false,
          keyboardType: TextInputType.url,
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════
  //  SHARED WIDGETS
  // ══════════════════════════════════════════════════════════════════

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

  Widget _buildSectionSubHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Text(
        title,
        style: AppFonts.titleSmall.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool required = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    int maxLines = 1,
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

          maxLines: maxLines,
          style: AppFonts.bodyMedium.copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppFonts.bodyMedium.copyWith(
              color: AppColors.textDisabled,
            ),
            prefixIcon: maxLines == 1
                ? Icon(icon, size: 20.r, color: AppColors.grey500)
                : null,
            filled: true,
            fillColor: AppColors.white,
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

  // ── Modern inspection card for each category ───────────────────

  Widget _buildInspectionCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required RxString condition,
    required TextEditingController remarksController,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.grey200),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Card header with icon ─────────────────────────────
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(icon, color: iconColor, size: 22.r),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppFonts.titleSmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Obx(() {
                      final condVal = condition.value;
                      return Text(
                        condVal.isEmpty ? 'Not rated yet' : condVal,
                        style: AppFonts.bodySmall.copyWith(
                          color: condVal.isEmpty
                              ? AppColors.grey400
                              : _getColorForCondition(condVal),
                          fontWeight: condVal.isEmpty
                              ? FontWeight.w400
                              : FontWeight.w600,
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),
          // ── Divider ──────────────────────────────────────────
          Container(height: 1, color: AppColors.grey200),
          SizedBox(height: 16.h),

          // ── Condition rating chips ───────────────────────────
          Text(
            'Rate Condition',
            style: AppFonts.labelMedium.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 10.h),
          Obx(() {
            final options = const ['Excellent', 'Good', 'Average', 'Poor'];
            return Wrap(
              spacing: 10.w,
              runSpacing: 8.h,
              children: options.map((option) {
                final isSelected = condition.value == option;
                final color = _getColorForCondition(option);
                return GestureDetector(
                  onTap: () => condition.value = option,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 9.h,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withOpacity(0.12)
                          : AppColors.grey50,
                      borderRadius: BorderRadius.circular(22.r),
                      border: Border.all(
                        color: isSelected ? color : AppColors.grey300,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isSelected)
                          Padding(
                            padding: EdgeInsets.only(right: 5.w),
                            child: Icon(
                              Icons.check_circle,
                              size: 15.r,
                              color: color,
                            ),
                          ),
                        Text(
                          option,
                          style: AppFonts.bodySmall.copyWith(
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: isSelected ? color : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          }),

          SizedBox(height: 16.h),

          // ── Remarks field ─────────────────────────────────────
          Text(
            'Remarks',
            style: AppFonts.labelMedium.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          TextFormField(
            controller: remarksController,
            maxLines: 2,
            style: AppFonts.bodyMedium.copyWith(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Enter observations...',
              hintStyle: AppFonts.bodyMedium.copyWith(
                color: AppColors.textDisabled,
              ),
              filled: true,
              fillColor: AppColors.grey50,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14.w,
                vertical: 12.h,
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
            ),
          ),
        ],
      ),
    );
  }

  // ── Tyres card ────────────────────────────────────────────────

  Widget _buildTyresCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.grey200),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Card header ───────────────────────────────────────
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: const Color(0xFF5D4037).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.tire_repair_outlined,
                  color: const Color(0xFF5D4037),
                  size: 22.r,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'Tyres',
                style: AppFonts.titleSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Container(height: 1, color: AppColors.grey200),
          SizedBox(height: 16.h),
          Obx(
            () => _buildTyreSlider(
              label: 'Front Axle Tyres',
              value: controller.frontAxleTyresPercent.value,
              onChanged: (v) =>
                  controller.frontAxleTyresPercent.value = v.round(),
            ),
          ),
          SizedBox(height: 12.h),
          Obx(
            () => _buildTyreSlider(
              label: 'Rear Axle Tyres',
              value: controller.rearAxleTyresPercent.value,
              onChanged: (v) =>
                  controller.rearAxleTyresPercent.value = v.round(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Odometer card ─────────────────────────────────────────────

  Widget _buildOdometerCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.grey200),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: const Color(0xFF00695C).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.speed_outlined,
                  color: const Color(0xFF00695C),
                  size: 22.r,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'Odometer',
                style: AppFonts.titleSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Container(height: 1, color: AppColors.grey200),
          SizedBox(height: 16.h),
          Text(
            'Remarks',
            style: AppFonts.labelMedium.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          TextFormField(
            controller: controller.odometerRemarksController,
            maxLines: 2,
            style: AppFonts.bodyMedium.copyWith(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Enter odometer-related observations...',
              hintStyle: AppFonts.bodyMedium.copyWith(
                color: AppColors.textDisabled,
              ),
              filled: true,
              fillColor: AppColors.grey50,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14.w,
                vertical: 12.h,
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
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForCondition(String condition) {
    switch (condition.toLowerCase()) {
      case 'excellent':
        return AppColors.success;
      case 'good':
        return const Color(0xFF2196F3);
      case 'average':
        return AppColors.warning;
      case 'poor':
        return AppColors.error;
      default:
        return AppColors.grey500;
    }
  }

  Widget _buildTyreSlider({
    required String label,
    required int value,
    required ValueChanged<double> onChanged,
  }) {
    Color progressColor;
    if (value >= 75) {
      progressColor = AppColors.success;
    } else if (value >= 50) {
      progressColor = const Color(0xFF2196F3);
    } else if (value >= 25) {
      progressColor = AppColors.warning;
    } else {
      progressColor = AppColors.error;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppFonts.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: progressColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                '$value%',
                style: AppFonts.labelMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: progressColor,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: progressColor,
            inactiveTrackColor: AppColors.grey200,
            thumbColor: progressColor,
            overlayColor: progressColor.withOpacity(0.1),
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
          ),
          child: Slider(
            value: value.toDouble(),
            min: 0,
            max: 100,
            divisions: 20,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildImageUpload(String title, RxList<PlatformFile> files) {
    return Obx(() {
      // Trigger subscription by accessing reactive length
      // ignore: unnecessary_statements
      files.length;
      return CustomFileUploadField(
        title: title,
        label:
            'Choose files (max ${AgentInspectionController.maxFilesPerCategory})',
        files: files,
        onTap: () => controller.pickFiles(files),
        onRemove: (index) => controller.removeFile(files, index),
        allowMultiple: true,
      );
    });
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppFonts.labelMedium.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 6.h),
        GestureDetector(
          onTap: onTap,
          child: AbsorbPointer(
            child: TextFormField(
              controller: controller,
              style: AppFonts.bodyMedium.copyWith(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppFonts.bodyMedium.copyWith(color: AppColors.white),
                prefixIcon: Icon(icon, size: 20.r, color: AppColors.grey500),
                suffixIcon: Icon(
                  Icons.arrow_drop_down,
                  size: 24.r,
                  color: AppColors.grey500,
                ),
                filled: true,
                fillColor: AppColors.white,
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
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePickerField({
    required String label,
    required String value,
    required IconData icon,
    VoidCallback? onClear,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppFonts.labelMedium.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 6.h),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: AppColors.grey300),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20.r, color: AppColors.grey500),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    value.isEmpty ? 'Select date' : value,
                    style: AppFonts.bodyMedium.copyWith(
                      color: value.isEmpty
                          ? AppColors.textDisabled
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
                if (value.isNotEmpty && onClear != null)
                  GestureDetector(
                    onTap: onClear,
                    child: Icon(
                      Icons.close,
                      size: 18.r,
                      color: AppColors.grey500,
                    ),
                  )
                else
                  Icon(
                    Icons.calendar_month,
                    size: 18.r,
                    color: AppColors.grey400,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(RxString target) async {
    final date = await showDatePicker(
      context: Get.context!,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2040),
    );
    if (date != null) {
      target.value =
          '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
  }

  // ══════════════════════════════════════════════════════════════════
  //  SUBMIT BUTTON
  // ══════════════════════════════════════════════════════════════════

  Widget _buildSubmitButton() {
    return Obx(
      () => GradientButton.filled(
        text: 'Submit Inspection',
        onPressed: controller.isSubmitting.value
            ? null
            : () => controller.submitAgentForm(),
        width: double.infinity,
        height: 48.h,
        fontSize: 15.sp,
        isLoading: controller.isSubmitting.value,
      ),
    );
  }
}
