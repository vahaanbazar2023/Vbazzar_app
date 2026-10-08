import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/atoms/custom_loader.dart';
import '../../../core/design_system/molecules/custom_file_upload_field.dart';
import '../../../core/design_system/molecules/gradient_button.dart';
import '../../../core/design_system/templates/app_layout.dart';
import '../../../theme/app_fonts.dart';
import '../controllers/agent_inspection_controller.dart';

/// Agent inspection form — simplified to match API requirements
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
                  // ── Vehicle Registration Number ──────────────────
                  _buildSectionHeader('Vehicle Registration Number'),
                  _buildTextField(
                    controller: controller.vehicleRegNoController,
                    label: 'Vehicle Registration Number',
                    hint: 'e.g. MH-01-AB-1234',
                    icon: Icons.directions_car,
                    required: true,
                  ),
                  SizedBox(height: 24.h),

                  // ── Body Photos ──────────────────────────────────
                  _buildSectionHeader('Body Photos'),
                  _buildImageUpload(
                    'Body - Front *',
                    controller.bodyFrontImages,
                  ),
                  SizedBox(height: 12.h),
                  _buildImageUpload(
                    'Body - Left Side *',
                    controller.bodyLeftImages,
                  ),
                  SizedBox(height: 12.h),
                  _buildImageUpload('Body - Back *', controller.bodyBackImages),
                  SizedBox(height: 12.h),
                  _buildImageUpload(
                    'Body - Right Side *',
                    controller.bodyRightImages,
                  ),
                  SizedBox(height: 24.h),

                  // ── Tyres ────────────────────────────────────────
                  _buildSectionHeader('Tyres'),
                  _buildTyresCard(),
                  SizedBox(height: 24.h),

                  // ── Engine ───────────────────────────────────────
                  _buildSectionHeader('Engine'),
                  _buildEngineCard(),
                  SizedBox(height: 12.h),
                  _buildImageUpload('Engine Photos *', controller.engineImages),
                  SizedBox(height: 24.h),

                  // ── Chassis ──────────────────────────────────────
                  _buildSectionHeader('Chassis'),
                  _buildImageUpload(
                    'Chassis Photos *',
                    controller.chasisImages,
                  ),
                  SizedBox(height: 24.h),

                  // ── Interior ─────────────────────────────────────
                  _buildSectionHeader('Interior'),
                  _buildImageUpload(
                    'Interior Photos *',
                    controller.cabinInteriorImages,
                  ),
                  SizedBox(height: 24.h),

                  // ── Cabin Interior ───────────────────────────────
                  _buildSectionHeader('Cabin Interior'),
                  _buildImageUpload(
                    'Cabin Interior Photos *',
                    controller.cabinInteriorImages,
                  ),
                  SizedBox(height: 24.h),

                  // ── Odometer ─────────────────────────────────────
                  _buildSectionHeader('Odometer'),
                  _buildOdometerCard(),
                  SizedBox(height: 12.h),
                  _buildImageUpload(
                    'Odometer Photos *',
                    controller.odometerImages,
                  ),
                  SizedBox(height: 24.h),

                  // ── Full Round Video (Optional) ──────────────────
                  _buildSectionHeader('Full Round Video (Optional)'),
                  Text(
                    'Upload a complete 360° video of the vehicle',
                    style: AppFonts.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  // TODO: Add video upload field here if needed
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

  // ── Engine card with condition dropdown ───────────────────────────

  Widget _buildEngineCard() {
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
                  color: const Color(0xFFE65100).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.engineering_outlined,
                  color: const Color(0xFFE65100),
                  size: 22.r,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Engine Condition',
                      style: AppFonts.titleSmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Obx(() {
                      final condVal = controller.engineCondition.value;
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
          Container(height: 1, color: AppColors.grey200),
          SizedBox(height: 16.h),

          // ── Condition rating chips ───────────────────────────
          Text(
            'Rate Condition *',
            style: AppFonts.labelMedium.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 10.h),
          Obx(() {
            final options = const ['excellent', 'good', 'average', 'poor'];
            return Wrap(
              spacing: 10.w,
              runSpacing: 8.h,
              children: options.map((option) {
                final isSelected =
                    controller.engineCondition.value.toLowerCase() == option;
                final color = _getColorForCondition(option);
                final displayLabel =
                    option[0].toUpperCase() + option.substring(1);
                return GestureDetector(
                  onTap: () => controller.engineCondition.value = option,
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
                          displayLabel,
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
        ],
      ),
    );
  }

  // ── Tyres card with sliders ────────────────────────────────────────

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
                  fontWeight: FontWeight.w600,
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
              label: 'Front Axle Tyres *',
              value: controller.frontAxleTyresPercent.value,
              onChanged: (v) =>
                  controller.frontAxleTyresPercent.value = v.round(),
            ),
          ),
          SizedBox(height: 12.h),
          Obx(
            () => _buildTyreSlider(
              label: 'Rear Axle Tyres *',
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
                'Odometer Reading',
                style: AppFonts.titleSmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Container(height: 1, color: AppColors.grey200),
          SizedBox(height: 16.h),
          _buildTextField(
            controller: controller.odometerController,
            label: 'Odometer Reading (KM)',
            hint: 'Enter odometer reading',
            icon: Icons.speed_outlined,
            required: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                  fontWeight: FontWeight.w600,
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
