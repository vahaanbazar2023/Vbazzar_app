import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/design_system/molecules/custom_autocomplete_field.dart';
import '../../../core/design_system/templates/app_layout.dart';
import '../controllers/sell_vehicle_controller.dart';
import '../data/repositories/buy_sell_repository_impl.dart';

// NOTE: image_picker is NOT in pubspec.yaml.
// File/image upload tiles show a notice snackbar when tapped.

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
    final preselectedCode = args['categoryCode'] as String? ?? '';
    final preselectedName = args['categoryName'] as String? ?? '';

    if (preselectedCode.isNotEmpty && ctrl.selectedCategoryCode.value.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ctrl.loadFormFields(preselectedCode);
      });
    }

    return AppLayout(
      title: 'Sell Vehicle',
      subtitle: preselectedName.isNotEmpty
          ? preselectedName
          : 'Post your vehicle for sale',
      body: Obx(() {
        if (ctrl.isSubmittingForm.value) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 56,
                  height: 56,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: AppSpacing.md),
                Text(
                  'Submitting your vehicle...',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
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

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            120,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Category selector (only if not pre-selected) ──────────────
              if (preselectedCode.isEmpty) ...[
                _StepCard(
                  step: 1,
                  title: 'Select Category',
                  icon: Icons.category_outlined,
                  child: _CategorySelector(ctrl: ctrl),
                ),
                SizedBox(height: AppSpacing.md),
              ],

              // ── Dynamic form (shown after category is set) ────────────────
              Obx(() {
                if (ctrl.selectedCategoryCode.value.isEmpty)
                  return const SizedBox.shrink();
                if (ctrl.isLoadingFormFields.value) return _FormLoadingState();

                final stepBase = preselectedCode.isNotEmpty ? 1 : 2;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _StepCard(
                      step: stepBase,
                      title: 'Vehicle Details',
                      icon: Icons.directions_car_outlined,
                      child: _DynamicFormFields(ctrl: ctrl),
                    ),
                    SizedBox(height: AppSpacing.xl),
                    _SubmitButton(ctrl: ctrl),
                  ],
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
// Step Card
// ─────────────────────────────────────────────────────────────────────────────

class _StepCard extends StatelessWidget {
  final int step;
  final String title;
  final IconData icon;
  final Widget child;
  const _StepCard({
    required this.step,
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.ctaGradientStart, AppColors.ctaGradientEnd],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppRadius.lg),
                topRight: Radius.circular(AppRadius.lg),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$step',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                Icon(icon, color: Colors.white, size: 18),
                SizedBox(width: AppSpacing.xs),
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Padding(padding: EdgeInsets.all(AppSpacing.md), child: child),
        ],
      ),
    );
  }
}

class _FormLoadingState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        children: [
          CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2.5),
          SizedBox(height: AppSpacing.md),
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

class _CategorySelector extends StatelessWidget {
  final SellVehicleController ctrl;
  const _CategorySelector({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = ctrl.selectedCategoryCode.value.isEmpty
          ? null
          : ctrl.categories.firstWhereOrNull(
              (c) => c.categoryCode == ctrl.selectedCategoryCode.value,
            );
      return CustomDropdownField<dynamic>(
        value: selected,
        items: ctrl.categories,
        placeholder: 'Select vehicle category',
        prefixIcon: Icons.category_outlined,
        isLoading: ctrl.isLoadingCategories.value,
        searchable: true,
        searchHint: 'Search category...',
        itemLabel: (cat) => cat.categoryName as String,
        onChanged: (cat) {
          if (cat != null) ctrl.loadFormFields(cat.categoryCode as String);
        },
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Fully Dynamic Form Fields
// Renders every field returned by /vehicle-category-form-fields API
// Field types: text, dropdown (source:master or options), yes_no, file, date, year
// ─────────────────────────────────────────────────────────────────────────────

class _DynamicFormFields extends StatelessWidget {
  final SellVehicleController ctrl;
  const _DynamicFormFields({required this.ctrl});

  // Fields that are file uploads
  static const _fileFields = {
    'Vehicle Images',
    'Upload Vehicle RC',
    'Insurance Upload',
  };

  // Fields that are yes/no toggles
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
            'No form fields available for this category.',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 13.sp,
              color: AppColors.grey500,
            ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: fields.map((field) {
          return Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.sm),
            child: _buildField(field),
          );
        }).toList(),
      );
    });
  }

  Widget _buildField(dynamic field) {
    final name = field.fieldName as String;
    final type = field.fieldType as String;
    final isRequired = field.required as bool;
    final options = field.options as List<String>?;
    final label = '$name${isRequired ? ' *' : ''}';

    // ── File upload fields ──────────────────────────────────────────────────
    if (type == 'file' || _fileFields.contains(name)) {
      return _FileUploadField(
        label: label,
        fieldName: name,
        isRequired: isRequired,
      );
    }

    // ── Yes/No toggle fields ────────────────────────────────────────────────
    if (type == 'yes_no' || _yesNoFields.contains(name)) {
      return _YesNoField(label: label, fieldName: name, ctrl: ctrl);
    }

    // ── Date field ──────────────────────────────────────────────────────────
    if (type == 'date') {
      return _DateField(label: label, fieldName: name, ctrl: ctrl);
    }

    // ── Year field ──────────────────────────────────────────────────────────
    if (type == 'year') {
      return _LabeledField(
        label: label,
        child: CustomInputField(
          controller: TextEditingController(
            text: ctrl.formValues[name]?.toString(),
          ),
          placeholder: 'e.g. 2021',
          prefixIcon: Icons.calendar_today_outlined,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(4),
          ],
          onChanged: (v) => ctrl.updateFormValue(name, v),
        ),
      );
    }

    // ── Master source: Brand ────────────────────────────────────────────────
    if (name == 'Brand') {
      return _LabeledField(
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
    }

    // ── Master source: State ────────────────────────────────────────────────
    if (name == 'State') {
      return _LabeledField(
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
            onSelected: (s) {
              if (s != null) ctrl.fetchCities(s['state_id']!);
            },
          );
        }),
      );
    }

    // ── Master source: City ─────────────────────────────────────────────────
    if (name == 'City') {
      return _LabeledField(
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
            onSelected: (c) {
              if (c != null) ctrl.selectCity(c['city_id']!);
            },
          );
        }),
      );
    }

    // ── Dropdown with options ───────────────────────────────────────────────
    if (type == 'dropdown' && options != null && options.isNotEmpty) {
      return _LabeledField(
        label: label,
        child: Obx(
          () => CustomDropdownField<String>(
            value: ctrl.formValues[name]?.toString(),
            items: options,
            placeholder: 'Select $name',
            searchable: options.length > 5,
            itemLabel: (o) => o,
            onChanged: (v) => ctrl.updateFormValue(name, v),
          ),
        ),
      );
    }

    // ── Price field ─────────────────────────────────────────────────────────
    if (name == 'Price') {
      return _LabeledField(
        label: label,
        child: CustomInputField(
          controller: TextEditingController(
            text: ctrl.formValues[name]?.toString(),
          ),
          placeholder: 'e.g. 2500000',
          prefixWidget: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '₹',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (v) => ctrl.updateFormValue(name, v),
        ),
      );
    }

    // ── Phone field ─────────────────────────────────────────────────────────
    if (name == 'Owner Mobile Number') {
      return _LabeledField(
        label: label,
        child: CustomInputField(
          controller: TextEditingController(
            text: ctrl.formValues[name]?.toString(),
          ),
          placeholder: '10-digit mobile number',
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          onChanged: (v) => ctrl.updateFormValue(name, v),
        ),
      );
    }

    // ── Registration Number ─────────────────────────────────────────────────
    if (name == 'Registration Number') {
      return _LabeledField(
        label: label,
        child: CustomInputField(
          controller: TextEditingController(
            text: ctrl.formValues[name]?.toString(),
          ),
          placeholder: 'e.g. MH12AB1234',
          prefixIcon: Icons.badge_outlined,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
          ],
          onChanged: (v) => ctrl.updateFormValue(name, v.toUpperCase()),
        ),
      );
    }

    // ── Odometer ────────────────────────────────────────────────────────────
    if (name == 'Odometer') {
      return _LabeledField(
        label: label,
        child: CustomInputField(
          controller: TextEditingController(
            text: ctrl.formValues[name]?.toString(),
          ),
          placeholder: 'e.g. 50000',
          prefixIcon: Icons.speed_outlined,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (v) => ctrl.updateFormValue(name, v),
        ),
      );
    }

    // ── Default: text field ─────────────────────────────────────────────────
    return _LabeledField(
      label: label,
      child: CustomInputField(
        controller: TextEditingController(
          text: ctrl.formValues[name]?.toString(),
        ),
        placeholder: 'Enter $name',
        onChanged: (v) => ctrl.updateFormValue(name, v),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Field sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;
  const _LabeledField({required this.label, required this.child});

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
        const SizedBox(height: 4),
        child,
      ],
    );
  }
}

// ── Yes/No Toggle ─────────────────────────────────────────────────────────────

class _YesNoField extends StatelessWidget {
  final String label;
  final String fieldName;
  final SellVehicleController ctrl;
  const _YesNoField({
    required this.label,
    required this.fieldName,
    required this.ctrl,
  });

  static const _colors = {
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
    final color = _colors[fieldName] ?? AppColors.primary;
    final icon = _icons[fieldName] ?? Icons.check_circle_outline;

    return Obx(() {
      final val = ctrl.formValues[fieldName] == true;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: val ? color.withValues(alpha: 0.06) : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: val ? color.withValues(alpha: 0.3) : AppColors.grey200,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: val ? color.withValues(alpha: 0.15) : AppColors.grey100,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(
                icon,
                size: 18,
                color: val ? color : AppColors.grey500,
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14.sp,
                  fontWeight: val ? FontWeight.w600 : FontWeight.w500,
                  color: val ? AppColors.textPrimary : AppColors.grey600,
                ),
              ),
            ),
            Switch(
              value: val,
              onChanged: (v) => ctrl.updateFormValue(fieldName, v),
              activeThumbColor: Colors.white,
              activeTrackColor: color,
              inactiveThumbColor: AppColors.grey400,
              inactiveTrackColor: AppColors.grey200,
            ),
          ],
        ),
      );
    });
  }
}

// ── Date Field ────────────────────────────────────────────────────────────────

class _DateField extends StatelessWidget {
  final String label;
  final String fieldName;
  final SellVehicleController ctrl;
  const _DateField({
    required this.label,
    required this.fieldName,
    required this.ctrl,
  });

  @override
  Widget build(BuildContext context) {
    return _LabeledField(
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
            height: 46.h,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.border),
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
                Icon(
                  Icons.calendar_month_outlined,
                  size: 20,
                  color: AppColors.grey500,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    val.isEmpty ? 'Select date' : val,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14.sp,
                      color: val.isEmpty
                          ? AppColors.grey500
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 20,
                  color: AppColors.grey500,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

// ── File Upload Field ─────────────────────────────────────────────────────────

class _FileUploadField extends StatelessWidget {
  final String label;
  final String fieldName;
  final bool isRequired;
  const _FileUploadField({
    required this.label,
    required this.fieldName,
    required this.isRequired,
  });

  void _notice() => Get.snackbar(
    'Upload Feature',
    'Add image_picker to pubspec.yaml to enable file uploads',
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: AppColors.grey900,
    colorText: Colors.white,
    margin: const EdgeInsets.all(16),
    borderRadius: 12,
    icon: const Icon(Icons.info_outline, color: Colors.white),
  );

  bool get _isImageField => fieldName == 'Vehicle Images';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              _isImageField
                  ? Icons.photo_library_outlined
                  : Icons.folder_outlined,
              size: 15,
              color: AppColors.grey600,
            ),
            SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.grey700,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.xs),
        GestureDetector(
          onTap: _notice,
          child: Container(
            width: double.infinity,
            height: _isImageField ? 90 : 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.25),
              ),
            ),
            child: _isImageField
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        color: AppColors.primary,
                        size: 28,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Tap to add photos',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12.sp,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Up to 10 • JPG, PNG',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 10.sp,
                          color: AppColors.grey500,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.upload_file_outlined,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      SizedBox(width: AppSpacing.xs),
                      Text(
                        'Tap to upload',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 13.sp,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
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
      height: 54,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.ctaGradientStart, AppColors.ctaGradientEnd],
        ),
        borderRadius: BorderRadius.circular(27),
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
          borderRadius: BorderRadius.circular(27),
          onTap: () async {
            final success = await ctrl.submitSellForm();
            if (success) Get.back();
          },
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                SizedBox(width: AppSpacing.sm),
                Text(
                  'Submit for Approval',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 16.sp,
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
