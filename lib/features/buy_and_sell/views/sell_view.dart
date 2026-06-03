import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/design_system/molecules/custom_autocomplete_field.dart';
import '../../../core/design_system/molecules/gradient_button.dart';
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
// Form Loading Shimmer
// ─────────────────────────────────────────────────────────────────────────────

class _FormLoadingState extends StatefulWidget {
  @override
  State<_FormLoadingState> createState() => _FormLoadingStateState();
}

class _FormLoadingStateState extends State<_FormLoadingState>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _animation = Tween<double>(begin: -1.5, end: 2.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header shimmer
            _ShimmerBar(width: 160.w, height: 18.h, animation: _animation),
            SizedBox(height: 12.h),
            // Form card shimmer
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: AppColors.grey100),
              ),
              child: Column(
                children: List.generate(
                  7,
                  (i) => Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ShimmerBar(
                          width: 100.w + (i % 3) * 30.w,
                          height: 11.h,
                          animation: _animation,
                        ),
                        SizedBox(height: 6.h),
                        _ShimmerBar(
                          width: double.infinity,
                          height: _kFieldH.h,
                          animation: _animation,
                          radius: 8.r,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            // Toggle section shimmer
            _ShimmerBar(width: 140.w, height: 18.h, animation: _animation),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: AppColors.grey100),
              ),
              child: Column(
                children: List.generate(
                  3,
                  (i) => Padding(
                    padding: EdgeInsets.only(bottom: i < 2 ? 12.h : 0),
                    child: Row(
                      children: [
                        _ShimmerBar(
                          width: 40.w,
                          height: 40.w,
                          animation: _animation,
                          radius: 10.r,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _ShimmerBar(
                            width: double.infinity,
                            height: 14.h,
                            animation: _animation,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        _ShimmerBar(
                          width: 48.w,
                          height: 28.h,
                          animation: _animation,
                          radius: 14.r,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 28.h),
            // Submit button shimmer
            _ShimmerBar(
              width: double.infinity,
              height: 52.h,
              animation: _animation,
              radius: 26.r,
            ),
          ],
        );
      },
    );
  }
}

class _ShimmerBar extends StatelessWidget {
  final double width;
  final double height;
  final Animation<double> animation;
  final double radius;

  const _ShimmerBar({
    required this.width,
    required this.height,
    required this.animation,
    this.radius = 6.0,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: width,
        height: height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [
                Color(0xFFEEEEEE),
                Color(0xFFF8F8F8),
                Color(0xFFEEEEEE),
              ],
              stops: [
                (animation.value - 1).clamp(0.0, 1.0),
                animation.value.clamp(0.0, 1.0),
                (animation.value + 1).clamp(0.0, 1.0),
              ],
            ),
          ),
        ),
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

      // Pull Category to the top
      final categoryField = regular.firstWhereOrNull(
        (f) => f.fieldName == 'Category',
      );
      final regularWithoutCategory = regular
          .where((f) => f.fieldName != 'Category')
          .toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Category (always first) ───────────────────────────────────────
          if (categoryField != null) ...[
            _FieldBuilder(
              field: categoryField,
              ctrl: ctrl,
              preCode: preCode,
              preName: preName,
            ),
            SizedBox(height: 16.h),
          ],

          // ── Regular fields ────────────────────────────────────────────────
          if (regularWithoutCategory.isNotEmpty) ...[
            _SectionHeader(
              label: 'Vehicle Details',
              icon: Icons.directions_car_outlined,
            ),
            SizedBox(height: 10.h),
            _FormCard(
              children: regularWithoutCategory
                  .map(
                    (f) => _FieldBuilder(
                      field: f,
                      ctrl: ctrl,
                      preCode: preCode,
                      preName: preName,
                    ),
                  )
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
  final String preCode;
  final String preName;
  const _FieldBuilder({
    required this.field,
    required this.ctrl,
    this.preCode = '',
    this.preName = '',
  });

  @override
  Widget build(BuildContext context) {
    final name = field.fieldName as String;
    final type = field.fieldType as String;
    final required = field.required as bool;
    final options = field.options as List<String>?;
    final label = '$name${required ? ' *' : ''}';

    // ── Category field — pre-fill with selected category (read-only) ────────
    if (name == 'Category') {
      final displayName = preName.isNotEmpty
          ? preName
          : ctrl.categories
                    .firstWhereOrNull(
                      (c) => c.categoryCode == ctrl.selectedCategoryCode.value,
                    )
                    ?.categoryName ??
                '';
      return _SellField(
        label: label,
        child: Container(
          height: _kFieldH.h,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            children: [
              SizedBox(width: 12.w),
              Icon(
                Icons.category_outlined,
                size: 20.sp,
                color: AppColors.primary,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  displayName,
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
                  'Auto-filled',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 10.sp,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

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
        child: _StateField(ctrl: ctrl),
      );

    // City autocomplete
    if (name == 'City')
      return _SellField(
        label: label,
        child: _CityField(ctrl: ctrl),
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
// State Field — StatefulWidget so the controller is stable across rebuilds
// ─────────────────────────────────────────────────────────────────────────────

class _StateField extends StatefulWidget {
  final SellVehicleController ctrl;
  const _StateField({required this.ctrl});
  @override
  State<_StateField> createState() => _StateFieldState();
}

class _StateFieldState extends State<_StateField> {
  late final TextEditingController _textCtrl;

  @override
  void initState() {
    super.initState();
    // Pre-fill if a state is already selected (edit mode)
    final existingName =
        widget.ctrl.states.firstWhereOrNull(
          (s) => s['state_id'] == widget.ctrl.selectedStateId.value,
        )?['state_name'] ??
        '';
    _textCtrl = TextEditingController(text: existingName);
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => CustomAutocompleteField<Map<String, String>>(
        controller: _textCtrl,
        options: widget.ctrl.states,
        placeholder: 'Search state',
        prefixIcon: Icons.location_on_outlined,
        isLoading: widget.ctrl.isLoadingStates.value,
        displayStringForOption: (s) => s['state_name'] ?? '',
        forceSelection: true,
        maxDropdownHeight: 250,
        height: _kFieldH.h,
        onSelected: (s) {
          if (s != null) widget.ctrl.fetchCities(s['state_id']!);
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// City Field — StatefulWidget so the controller is stable across rebuilds
// ─────────────────────────────────────────────────────────────────────────────

class _CityField extends StatefulWidget {
  final SellVehicleController ctrl;
  const _CityField({required this.ctrl});
  @override
  State<_CityField> createState() => _CityFieldState();
}

class _CityFieldState extends State<_CityField> {
  late final TextEditingController _textCtrl;

  @override
  void initState() {
    super.initState();
    _textCtrl = TextEditingController();
    // When a new state is selected, cities list changes → clear the text
    ever(widget.ctrl.cities, (_) {
      if (mounted) _textCtrl.clear();
    });
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final stateSelected = widget.ctrl.selectedStateId.value.isNotEmpty;
      return CustomAutocompleteField<Map<String, String>>(
        controller: _textCtrl,
        options: widget.ctrl.cities,
        placeholder: stateSelected ? 'Search city' : 'Select state first',
        prefixIcon: Icons.location_city_outlined,
        isLoading: widget.ctrl.isLoadingCities.value,
        enabled: stateSelected,
        displayStringForOption: (c) => c['city_name'] ?? '',
        forceSelection: true,
        maxDropdownHeight: 220,
        height: _kFieldH.h,
        onSelected: (c) {
          if (c != null) widget.ctrl.selectCity(c['city_id']!);
        },
      );
    });
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
                        ? AppColors.primary.withValues(alpha: 0.05)
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
                              ? AppColors.primary.withValues(alpha: 0.12)
                              : AppColors.grey100,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(
                          icon,
                          size: 19.sp,
                          color: on ? AppColors.primary : AppColors.grey400,
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
                                  color: AppColors.primary,
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
                        activeTrackColor: AppColors.primary,
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
        // Multiple docs allowed, each max 12 MB
        final picked = await picker.pickMultiImage(imageQuality: 100);
        if (picked.isNotEmpty) {
          final files = picked.map((x) => File(x.path)).toList();
          if (fieldName == 'Upload Vehicle RC')
            ctrl.addRcDocuments(files);
          else
            ctrl.addInsuranceDocuments(files);
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not open picker: $e',
        snackPosition: SnackPosition.TOP,
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
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Upload zone ───────────────────────────────────────────
                GestureDetector(
                  onTap: imgs.length < 10 ? _pick : null,
                  child: Container(
                    width: double.infinity,
                    height: 110.h,
                    decoration: BoxDecoration(
                      color: imgs.isEmpty
                          ? AppColors.primary.withValues(alpha: 0.04)
                          : AppColors.primary.withValues(alpha: 0.02),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: imgs.isEmpty
                            ? AppColors.primary.withValues(alpha: 0.35)
                            : AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 42.w,
                          height: 42.w,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.add_photo_alternate_outlined,
                            color: AppColors.primary,
                            size: 22.sp,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          imgs.isEmpty
                              ? 'Tap to add vehicle photos'
                              : 'Tap to add more',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Up to 10 photos  •  JPG, PNG',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 10.sp,
                            color: AppColors.grey400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Uploaded thumbnails (horizontal scroll) ───────────────
                if (imgs.isNotEmpty) ...[
                  SizedBox(height: 10.h),
                  SizedBox(
                    height: 80.h,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: imgs.length,
                      separatorBuilder: (_, __) => SizedBox(width: 8.w),
                      itemBuilder: (_, i) => _ImageThumb(
                        file: imgs[i],
                        onRemove: () => ctrl.removeImage(i),
                      ),
                    ),
                  ),
                ],
              ],
            );
          })
        else
          Obx(() {
            final docs = fieldName == 'Upload Vehicle RC'
                ? ctrl.rcDocuments
                : ctrl.insuranceDocuments;
            final hasDocs = docs.isNotEmpty;

            void removeDoc(int i) {
              if (fieldName == 'Upload Vehicle RC')
                ctrl.removeRcDocument(i);
              else
                ctrl.removeInsuranceDocument(i);
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Upload zone ──────────────────────────────────────────
                GestureDetector(
                  onTap: _pick,
                  child: Container(
                    width: double.infinity,
                    height: 100.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: hasDocs ? AppColors.primary : AppColors.grey300,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.folder_open_outlined,
                          size: 36.sp,
                          color: hasDocs
                              ? AppColors.primary
                              : AppColors.grey400,
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          'Tap to upload',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: hasDocs
                                ? AppColors.primary
                                : AppColors.grey500,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Multiple files allowed  •  Max 12 MB each  •  JPG, PNG',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 10.sp,
                            color: AppColors.grey400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Uploaded files list ──────────────────────────────────
                if (hasDocs) ...[
                  SizedBox(height: 8.h),
                  ...docs.asMap().entries.map(
                    (e) => Padding(
                      padding: EdgeInsets.only(bottom: 6.h),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 10.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.insert_drive_file_outlined,
                              size: 18.sp,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    e.value.path.split('/').last,
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primaryDark,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    _fileSizeLabel(e.value),
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 10.sp,
                                      color: AppColors.primary.withValues(
                                        alpha: 0.7,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () => removeDoc(e.key),
                              child: Container(
                                width: 22.w,
                                height: 22.w,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.15,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 13.sp,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            );
          }),
      ],
    );
  }
}

String _fileSizeLabel(File file) {
  final bytes = file.lengthSync();
  if (bytes >= 1024 * 1024)
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  return '${(bytes / 1024).toStringAsFixed(0)} KB';
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
          child: Image.file(file, width: 76.w, height: 76.w, fit: BoxFit.cover),
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

// ─────────────────────────────────────────────────────────────────────────────
// Submit Button
// ─────────────────────────────────────────────────────────────────────────────

class _SubmitButton extends StatelessWidget {
  final SellVehicleController ctrl;
  const _SubmitButton({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GradientButton.filled(
        text: ctrl.isEditMode.value ? 'Update Vehicle' : 'Submit',
        width: double.infinity,
        height: 52.h,
        fontSize: 15.sp,
        fontWeight: FontWeight.w700,
        isLoading: ctrl.isSubmittingForm.value,
        onPressed: () async {
          if (ctrl.isSubmittingForm.value) return; // guard double-tap
          debugPrint(
            '🖱️ [SubmitButton] tapped, isEditMode=${ctrl.isEditMode.value}',
          );
          final success = ctrl.isEditMode.value
              ? await ctrl.updateVehicle()
              : await ctrl.submitSellForm();
          if (success) Get.back();
        },
      ),
    );
  }
}
