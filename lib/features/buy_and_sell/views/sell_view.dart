import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/design_system/molecules/custom_autocomplete_field.dart';
import '../../../core/design_system/templates/app_layout.dart';
import '../controllers/sell_vehicle_controller.dart';
import '../data/repositories/buy_sell_repository_impl.dart';

// ─── All inputs share this height to stay visually consistent ────────────────
const double _kFieldH = 46.0;

class SellVehicleView extends StatelessWidget {
  const SellVehicleView({super.key});

  SellVehicleController get _ctrl {
    if (!Get.isRegistered<SellVehicleController>()) {
      Get.put(SellVehicleController(repository: BuySellRepositoryImpl()));
    }
    return Get.find<SellVehicleController>();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = _ctrl;
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final preCode = args['categoryCode'] as String? ?? '';
    final preName = args['categoryName'] as String? ?? '';

    // Auto-load form when arriving from category card
    if (preCode.isNotEmpty && ctrl.selectedCategoryCode.value.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ctrl.loadFormFields(preCode);
      });
    }

    return AppLayout(
      title: 'Sell Vehicle',
      subtitle: preName.isNotEmpty ? preName : 'Post your vehicle for sale',
      body: Obx(() {
        if (ctrl.isSubmittingForm.value) return _SubmittingOverlay();

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 120.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Category picker (only when NOT pre-selected) ──────────────
              if (preCode.isEmpty) ...[
                _SellField(
                  label: 'Vehicle Category *',
                  child: Obx(
                    () => SizedBox(
                      height: _kFieldH.h,
                      child: CustomDropdownField<dynamic>(
                        value: ctrl.selectedCategoryCode.value.isEmpty
                            ? null
                            : ctrl.categories.firstWhereOrNull(
                                (c) =>
                                    c.categoryCode ==
                                    ctrl.selectedCategoryCode.value,
                              ),
                        items: ctrl.categories,
                        placeholder: 'Select category',
                        prefixIcon: Icons.category_outlined,
                        isLoading: ctrl.isLoadingCategories.value,
                        searchable: true,
                        searchHint: 'Search category...',
                        itemLabel: (cat) => cat.categoryName as String,
                        height: _kFieldH.h,
                        onChanged: (cat) {
                          if (cat != null)
                            ctrl.loadFormFields(cat.categoryCode as String);
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
              ],

              // ── Dynamic form ──────────────────────────────────────────────
              Obx(() {
                if (ctrl.selectedCategoryCode.value.isEmpty)
                  return const SizedBox.shrink();
                if (ctrl.isLoadingFormFields.value) return _FormLoadingState();
                return _DynamicFormBody(
                  ctrl: ctrl,
                  preCode: preCode,
                  preName: preName,
                );
              }),
            ],
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Submitting overlay
// ─────────────────────────────────────────────────────────────────────────────

class _SubmittingOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72.w,
            height: 72.w,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.ctaGradientStart, AppColors.ctaGradientEnd],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'Submitting your vehicle...',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Please wait while we process your listing',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 13.sp,
              color: AppColors.grey500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Form Loading State
// ─────────────────────────────────────────────────────────────────────────────

class _FormLoadingState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(32.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 2.5,
          ),
          SizedBox(height: 12.h),
          Text(
            'Loading form fields...',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 14.sp,
              color: AppColors.grey500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dynamic Form Body
// ─────────────────────────────────────────────────────────────────────────────

class _DynamicFormBody extends StatelessWidget {
  final SellVehicleController ctrl;
  final String preCode;
  final String preName;
  const _DynamicFormBody({
    required this.ctrl,
    required this.preCode,
    required this.preName,
  });

  static const _fileFields = {
    'Vehicle Images',
    'Upload Vehicle RC',
    'Insurance Upload',
  };
  static const _yesNoFields = {
    'Fitness',
    'Original Invoice',
    'GST Applicability',
  };

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final fields = ctrl.dynamicFormFields;
      if (fields.isEmpty) {
        return Center(
          child: Text(
            'No form fields available.',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 13.sp,
              color: AppColors.grey500,
            ),
          ),
        );
      }

      final regular = fields
          .where(
            (f) =>
                f.fieldType != 'file' &&
                !_fileFields.contains(f.fieldName) &&
                f.fieldType != 'yes_no' &&
                !_yesNoFields.contains(f.fieldName),
          )
          .toList();
      final toggles = fields
          .where(
            (f) =>
                f.fieldType == 'yes_no' || _yesNoFields.contains(f.fieldName),
          )
          .toList();
      final files = fields
          .where(
            (f) => f.fieldType == 'file' || _fileFields.contains(f.fieldName),
          )
          .toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Category pre-filled read-only chip ────────────────────────────
          if (preCode.isNotEmpty) ...[
            _SellField(
              label: 'Vehicle Category',
              child: _ReadOnlyField(
                value: preName,
                icon: Icons.category_outlined,
              ),
            ),
            SizedBox(height: 16.h),
          ],

          // ── Regular fields ────────────────────────────────────────────────
          if (regular.isNotEmpty) ...[
            _SectionHeader(
              label: 'Vehicle Details',
              icon: Icons.directions_car_outlined,
            ),
            SizedBox(height: 10.h),
            _FormCard(
              children: regular
                  .map((f) => _FieldBuilder(field: f, ctrl: ctrl))
                  .toList(),
            ),
          ],

          // ── Condition toggles ─────────────────────────────────────────────
          if (toggles.isNotEmpty) ...[
            SizedBox(height: 20.h),
            _SectionHeader(
              label: 'Vehicle Condition',
              icon: Icons.verified_outlined,
            ),
            SizedBox(height: 10.h),
            _ToggleCard(fields: toggles, ctrl: ctrl),
          ],

          // ── Photos & Documents ────────────────────────────────────────────
          if (files.isNotEmpty) ...[
            SizedBox(height: 20.h),
            _SectionHeader(
              label: 'Photos & Documents',
              icon: Icons.photo_library_outlined,
            ),
            SizedBox(height: 10.h),
            ...files.map(
              (f) => Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: _FileField(
                  fieldName: f.fieldName,
                  isRequired: f.required,
                  ctrl: ctrl,
                ),
              ),
            ),
          ],

          SizedBox(height: 28.h),
          _SubmitButton(ctrl: ctrl),
        ],
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Read-only pre-filled field (for Category when pre-selected)
// ─────────────────────────────────────────────────────────────────────────────

class _ReadOnlyField extends StatelessWidget {
  final String value;
  final IconData icon;
  const _ReadOnlyField({required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _kFieldH.h,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          SizedBox(width: 12.w),
          Icon(icon, size: 20.sp, color: AppColors.primary),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(right: 10.w),
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              'Selected',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 10.sp,
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section Header
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  final IconData icon;
  const _SectionHeader({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30.w,
          height: 30.w,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.ctaGradientStart, AppColors.ctaGradientEnd],
            ),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, color: Colors.white, size: 15.sp),
        ),
        SizedBox(width: 10.w),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(child: Container(height: 1, color: AppColors.grey200)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Form Card
// ─────────────────────────────────────────────────────────────────────────────

class _FormCard extends StatelessWidget {
  final List<Widget> children;
  const _FormCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 4.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.grey200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children
            .map(
              (w) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: w,
              ),
            )
            .toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SellField — label + child
// ─────────────────────────────────────────────────────────────────────────────

class _SellField extends StatelessWidget {
  final String label;
  final Widget child;
  const _SellField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.grey700,
          ),
        ),
        SizedBox(height: 5.h),
        child,
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _UniformInput — identical look to CustomAutocompleteField
// white bg · shadow · no border · 46.h · 20.sp icon · textSecondary
// ─────────────────────────────────────────────────────────────────────────────

class _UniformInput extends StatelessWidget {
  final String hint;
  final IconData? icon;
  final Widget? prefixWidget;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? initialValue;
  final ValueChanged<String> onChanged;

  const _UniformInput({
    required this.hint,
    this.icon,
    this.prefixWidget,
    this.keyboardType,
    this.inputFormatters,
    this.initialValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _kFieldH.h,
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE4E5E7).withValues(alpha: 0.24),
            offset: const Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: TextField(
        controller: initialValue != null
            ? TextEditingController(text: initialValue)
            : null,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        onChanged: onChanged,
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 14.sp,
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14.sp,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w400,
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(width: 1, color: AppColors.ctaGradientStart),
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          // Prefix: icon OR custom widget, both at 20.sp, left-padded 12.w
          prefixIcon: prefixWidget != null
              ? Padding(
                  padding: EdgeInsets.only(left: 12.w, right: 8.w),
                  child: prefixWidget,
                )
              : icon != null
              ? Padding(
                  padding: EdgeInsets.only(left: 12.w, right: 8.w),
                  child: Icon(
                    icon,
                    size: 20.sp,
                    color: AppColors.textSecondary,
                  ),
                )
              : null,
          prefixIconConstraints: const BoxConstraints(
            minWidth: 0,
            minHeight: 0,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 12.w,
            vertical: 12.h,
          ),
          isCollapsed: true,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Field Builder — routes each API field to the right widget
// ─────────────────────────────────────────────────────────────────────────────

class _FieldBuilder extends StatelessWidget {
  final dynamic field;
  final SellVehicleController ctrl;
  const _FieldBuilder({required this.field, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final name = field.fieldName as String;
    final type = field.fieldType as String;
    final required = field.required as bool;
    final options = field.options as List<String>?;
    final label = '$name${required ? ' *' : ''}';

    // Date picker
    if (type == 'date')
      return _DatePickerField(label: label, fieldName: name, ctrl: ctrl);

    // Year
    if (type == 'year')
      return _SellField(
        label: label,
        child: _UniformInput(
          hint: 'e.g. 2021',
          icon: Icons.calendar_today_outlined,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(4),
          ],
          initialValue: ctrl.formValues[name]?.toString(),
          onChanged: (v) => ctrl.updateFormValue(name, v),
        ),
      );

    // Brand autocomplete
    if (name == 'Brand')
      return _SellField(
        label: label,
        child: Obx(
          () => CustomAutocompleteField<Map<String, String>>(
            controller: TextEditingController(
              text: ctrl.formValues['brand_name']?.toString() ?? '',
            ),
            options: ctrl.brands,
            placeholder: ctrl.isLoadingBrands.value
                ? 'Loading brands...'
                : 'Search brand',
            prefixIcon: Icons.branding_watermark_outlined,
            isLoading: ctrl.isLoadingBrands.value,
            displayStringForOption: (b) => b['brand_name'] ?? '',
            forceSelection: false,
            maxDropdownHeight: 220,
            height: _kFieldH.h,
            onSelected: (b) {
              if (b != null) {
                ctrl.updateFormValue('brand_code', b['brand_code']);
                ctrl.updateFormValue('brand_name', b['brand_name']);
              }
            },
            onChanged: (v) => ctrl.updateFormValue('brand_name', v),
          ),
        ),
      );

    // State autocomplete
    if (name == 'State')
      return _SellField(
        label: label,
        child: Obx(() {
          final stateCtrl = TextEditingController(
            text:
                ctrl.states.firstWhereOrNull(
                  (s) => s['state_id'] == ctrl.selectedStateId.value,
                )?['state_name'] ??
                '',
          );
          return CustomAutocompleteField<Map<String, String>>(
            controller: stateCtrl,
            options: ctrl.states,
            placeholder: 'Search state',
            prefixIcon: Icons.location_on_outlined,
            isLoading: ctrl.isLoadingStates.value,
            displayStringForOption: (s) => s['state_name'] ?? '',
            forceSelection: true,
            maxDropdownHeight: 250,
            height: _kFieldH.h,
            onSelected: (s) {
              if (s != null) ctrl.fetchCities(s['state_id']!);
            },
          );
        }),
      );

    // City autocomplete
    if (name == 'City')
      return _SellField(
        label: label,
        child: Obx(() {
          final stateSelected = ctrl.selectedStateId.value.isNotEmpty;
          final cityCtrl = TextEditingController(
            text:
                ctrl.cities.firstWhereOrNull(
                  (c) => c['city_id'] == ctrl.selectedCityId.value,
                )?['city_name'] ??
                '',
          );
          return CustomAutocompleteField<Map<String, String>>(
            controller: cityCtrl,
            options: ctrl.cities,
            placeholder: stateSelected ? 'Search city' : 'Select state first',
            prefixIcon: Icons.location_city_outlined,
            isLoading: ctrl.isLoadingCities.value,
            enabled: stateSelected,
            displayStringForOption: (c) => c['city_name'] ?? '',
            forceSelection: true,
            maxDropdownHeight: 220,
            height: _kFieldH.h,
            onSelected: (c) {
              if (c != null) ctrl.selectCity(c['city_id']!);
            },
          );
        }),
      );

    // Dropdown with options
    if (type == 'dropdown' && options != null && options.isNotEmpty) {
      return _SellField(
        label: label,
        child: Obx(
          () => SizedBox(
            height: _kFieldH.h,
            child: CustomDropdownField<String>(
              value: ctrl.formValues[name]?.toString(),
              items: options,
              placeholder: 'Select $name',
              searchable: options.length > 5,
              itemLabel: (o) => o,
              height: _kFieldH.h,
              onChanged: (v) => ctrl.updateFormValue(name, v),
            ),
          ),
        ),
      );
    }

    // Price
    if (name == 'Price')
      return _SellField(
        label: label,
        child: _UniformInput(
          hint: 'e.g. 2500000',
          prefixWidget: Text(
            '₹',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          initialValue: ctrl.formValues[name]?.toString(),
          onChanged: (v) => ctrl.updateFormValue(name, v),
        ),
      );

    // Phone
    if (name == 'Owner Mobile Number')
      return _SellField(
        label: label,
        child: _UniformInput(
          hint: '10-digit mobile number',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          initialValue: ctrl.formValues[name]?.toString(),
          onChanged: (v) => ctrl.updateFormValue(name, v),
        ),
      );

    // Registration
    if (name == 'Registration Number')
      return _SellField(
        label: label,
        child: _UniformInput(
          hint: 'e.g. MH12AB1234',
          icon: Icons.badge_outlined,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
          ],
          initialValue: ctrl.formValues[name]?.toString(),
          onChanged: (v) => ctrl.updateFormValue(name, v.toUpperCase()),
        ),
      );

    // Odometer
    if (name == 'Odometer')
      return _SellField(
        label: label,
        child: _UniformInput(
          hint: 'e.g. 50000',
          icon: Icons.speed_outlined,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          initialValue: ctrl.formValues[name]?.toString(),
          onChanged: (v) => ctrl.updateFormValue(name, v),
        ),
      );

    // Default text
    return _SellField(
      label: label,
      child: _UniformInput(
        hint: 'Enter $name',
        initialValue: ctrl.formValues[name]?.toString(),
        onChanged: (v) => ctrl.updateFormValue(name, v),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Date Picker Field
// ─────────────────────────────────────────────────────────────────────────────

class _DatePickerField extends StatelessWidget {
  final String label;
  final String fieldName;
  final SellVehicleController ctrl;
  const _DatePickerField({
    required this.label,
    required this.fieldName,
    required this.ctrl,
  });

  @override
  Widget build(BuildContext context) {
    return _SellField(
      label: label,
      child: Obx(() {
        final val = ctrl.formValues[fieldName]?.toString() ?? '';
        return GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime.tryParse(val) ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2030),
              builder: (ctx, child) => Theme(
                data: Theme.of(ctx).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: AppColors.primary,
                  ),
                ),
                child: child!,
              ),
            );
            if (picked != null) {
              ctrl.updateFormValue(
                fieldName,
                '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}',
              );
            }
          },
          child: Container(
            height: _kFieldH.h,
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE4E5E7).withValues(alpha: 0.24),
                  offset: const Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
            child: Row(
              children: [
                SizedBox(width: 12.w),
                Icon(
                  Icons.calendar_month_outlined,
                  size: 20.sp,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    val.isEmpty ? 'Select date' : val,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: val.isEmpty
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 20.sp,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: 12.w),
              ],
            ),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Toggle Card
// ─────────────────────────────────────────────────────────────────────────────

class _ToggleCard extends StatelessWidget {
  final List<dynamic> fields;
  final SellVehicleController ctrl;
  const _ToggleCard({required this.fields, required this.ctrl});

  static const _palette = {
    'Fitness': Color(0xFF10B981),
    'Original Invoice': Color(0xFFF59E0B),
    'GST Applicability': Color(0xFF8B5CF6),
    'Vehicle Insurance': Color(0xFF3B82F6),
  };
  static const _icons = {
    'Fitness': Icons.verified_outlined,
    'Original Invoice': Icons.receipt_long_outlined,
    'GST Applicability': Icons.percent_outlined,
    'Vehicle Insurance': Icons.security_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.grey200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: fields.asMap().entries.map((e) {
          final i = e.key;
          final name = e.value.fieldName as String;
          final color = _palette[name] ?? AppColors.primary;
          final icon = _icons[name] ?? Icons.check_circle_outline;
          final isFirst = i == 0;
          final isLast = i == fields.length - 1;

          return Column(
            children: [
              Obx(() {
                final on = ctrl.formValues[name] == true;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: on
                        ? color.withValues(alpha: 0.05)
                        : Colors.transparent,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(isFirst ? 14.r : 0),
                      topRight: Radius.circular(isFirst ? 14.r : 0),
                      bottomLeft: Radius.circular(isLast ? 14.r : 0),
                      bottomRight: Radius.circular(isLast ? 14.r : 0),
                    ),
                  ),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 38.w,
                        height: 38.w,
                        decoration: BoxDecoration(
                          color: on
                              ? color.withValues(alpha: 0.15)
                              : AppColors.grey100,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(
                          icon,
                          size: 19.sp,
                          color: on ? color : AppColors.grey400,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 14.sp,
                                fontWeight: on
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: on
                                    ? AppColors.textPrimary
                                    : AppColors.grey600,
                              ),
                            ),
                            if (on)
                              Text(
                                'Confirmed ✓',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 11.sp,
                                  color: color,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Switch(
                        value: on,
                        onChanged: (v) => ctrl.updateFormValue(name, v),
                        activeThumbColor: Colors.white,
                        activeTrackColor: color,
                        inactiveThumbColor: AppColors.grey300,
                        inactiveTrackColor: AppColors.grey100,
                      ),
                    ],
                  ),
                );
              }),
              if (!isLast)
                Divider(
                  height: 1,
                  color: AppColors.grey100,
                  indent: 14.w,
                  endIndent: 14.w,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// File Field — real image_picker
// ─────────────────────────────────────────────────────────────────────────────

class _FileField extends StatelessWidget {
  final String fieldName;
  final bool isRequired;
  final SellVehicleController ctrl;
  const _FileField({
    required this.fieldName,
    required this.isRequired,
    required this.ctrl,
  });

  bool get _isImages => fieldName == 'Vehicle Images';

  Future<void> _pick() async {
    try {
      final picker = ImagePicker();
      if (_isImages) {
        final picked = await picker.pickMultiImage(imageQuality: 80);
        if (picked.isNotEmpty)
          ctrl.addImages(picked.map((x) => File(x.path)).toList());
      } else {
        final picked = await picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 90,
        );
        if (picked != null) {
          final file = File(picked.path);
          if (fieldName == 'Upload Vehicle RC')
            ctrl.setRcDocument(file);
          else
            ctrl.setInsuranceDocument(file);
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not open picker: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.grey900,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '$fieldName${isRequired ? ' *' : ''}',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.grey700,
              ),
            ),
            if (_isImages) ...[
              SizedBox(width: 6.w),
              Obx(
                () => Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    '${ctrl.vehicleImages.length}/10',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 10.sp,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: 5.h),

        if (_isImages)
          Obx(() {
            final imgs = ctrl.vehicleImages;
            return Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                ...imgs.asMap().entries.map(
                  (e) => _ImageThumb(
                    file: e.value,
                    onRemove: () => ctrl.removeImage(e.key),
                  ),
                ),
                if (imgs.length < 10) _AddImageButton(onTap: _pick),
              ],
            );
          })
        else
          Obx(() {
            final file = fieldName == 'Upload Vehicle RC'
                ? ctrl.rcDocument.value
                : ctrl.insuranceDocument.value;
            final hasFile = file != null;
            return GestureDetector(
              onTap: _pick,
              child: Container(
                height: _kFieldH.h,
                decoration: BoxDecoration(
                  color: hasFile
                      ? AppColors.successBackground
                      : AppColors.white,
                  boxShadow: [
                    BoxShadow(
                      color: hasFile
                          ? AppColors.success.withValues(alpha: 0.15)
                          : const Color(0xFFE4E5E7).withValues(alpha: 0.24),
                      offset: const Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    SizedBox(width: 12.w),
                    Icon(
                      hasFile
                          ? Icons.check_circle_outline
                          : Icons.upload_file_outlined,
                      size: 20.sp,
                      color: hasFile
                          ? AppColors.success
                          : AppColors.textSecondary,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        hasFile ? file.path.split('/').last : 'Tap to upload',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 14.sp,
                          color: hasFile
                              ? AppColors.successDark
                              : AppColors.textSecondary,
                          fontWeight: hasFile
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (hasFile)
                      GestureDetector(
                        onTap: () {
                          if (fieldName == 'Upload Vehicle RC')
                            ctrl.removeRcDocument();
                          else
                            ctrl.removeInsuranceDocument();
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          child: Icon(
                            Icons.close_rounded,
                            size: 20.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                    else
                      Container(
                        margin: EdgeInsets.only(right: 10.w),
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          'Browse',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 11.sp,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
}

class _ImageThumb extends StatelessWidget {
  final File file;
  final VoidCallback onRemove;
  const _ImageThumb({required this.file, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10.r),
          child: Image.file(file, width: 72.w, height: 72.w, fit: BoxFit.cover),
        ),
        Positioned(
          top: 3,
          right: 3,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 20.w,
              height: 20.w,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, size: 11.sp, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _AddImageButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddImageButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72.w,
        height: 72.w,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              color: AppColors.primary,
              size: 22.sp,
            ),
            SizedBox(height: 3.h),
            Text(
              'Add',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 10.sp,
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Submit Button
// ─────────────────────────────────────────────────────────────────────────────

class _SubmitButton extends StatelessWidget {
  final SellVehicleController ctrl;
  const _SubmitButton({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 52.h,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.ctaGradientStart, AppColors.ctaGradientEnd],
        ),
        borderRadius: BorderRadius.circular(26.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(26.r),
          onTap: () async {
            final success = await ctrl.submitSellForm();
            if (success) Get.back();
          },
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: Colors.white,
                  size: 20.sp,
                ),
                SizedBox(width: 10.w),
                Text(
                  'Submit for Approval',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
