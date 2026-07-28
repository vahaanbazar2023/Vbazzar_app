import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/molecules/custom_autocomplete_field.dart';
import '../../../core/design_system/molecules/gradient_button.dart';
import '../../../core/design_system/templates/app_layout.dart';
import '../controllers/approved_vehicle_controller.dart';

// ─── All inputs share this height to stay visually consistent with Buy & Sell ─
const double _kFieldH = 46.0;

class SellVehicleFormScreen extends StatefulWidget {
  const SellVehicleFormScreen({super.key});

  @override
  State<SellVehicleFormScreen> createState() => _SellVehicleFormScreenState();
}

class _SellVehicleFormScreenState extends State<SellVehicleFormScreen> {
  final _ctrl = Get.find<ApprovedVehicleController>();

  // Local text controllers for simple fields
  final _regNoController = TextEditingController();
  final _chassisController = TextEditingController();
  final _yearController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _ownerMobileController = TextEditingController();
  final _insuranceDateController = TextEditingController();

  bool _fitnessAvailable = false;
  bool _invoiceAvailable = false;
  bool _gstApplicable = false;

  final List<String> _images = [];
  final List<String> _rcDocuments = [];
  final List<String> _insuranceDocs = [];

  String _categoryName = '';
  String _categoryCode = '';

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    _categoryName = args['categoryName'] as String? ?? '';
    _categoryCode = args['categoryCode'] as String? ?? '';
    // Category is auto-selected from the category page — never editable here.
    _ctrl.initSellForm(_categoryName, _categoryCode);
  }

  @override
  void dispose() {
    _regNoController.dispose();
    _chassisController.dispose();
    _yearController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _ownerMobileController.dispose();
    _insuranceDateController.dispose();
    super.dispose();
  }

  Future<void> _pickFiles(List<String> target) async {
    // TODO: Wire up file_picker/image_picker for real uploads.
    setState(() {
      target.add('sample_file_${target.length + 1}.jpg');
    });
    Get.snackbar(
      'Info',
      'File picker integration pending. Add file_picker package to enable uploads.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.grey100,
      colorText: AppColors.black,
    );
  }

  void _submit() {
    _ctrl.sellCategoryNameC.text = _categoryName;
    _ctrl.sellCategoryCodeC.text = _categoryCode;
    _ctrl.sellRegNumberC.text = _regNoController.text.trim();
    _ctrl.sellChassisC.text = _chassisController.text.trim();
    _ctrl.sellAssetDescC.text = _descriptionController.text.trim();
    _ctrl.sellPriceC.text = _priceController.text.trim();
    _ctrl.sellOwnerMobileC.text = _ownerMobileController.text.trim();
    _ctrl.sellMfgYear.value = _yearController.text.trim();
    _ctrl.sellFitness.value = _fitnessAvailable ? 'Yes' : 'No';
    _ctrl.sellOriginalInvoice.value = _invoiceAvailable ? 'Yes' : 'No';
    _ctrl.sellGSTApplicability.value = _gstApplicable ? 'Yes' : 'No';
    _ctrl.sellVehicleImages.assignAll(_images);
    _ctrl.sellRCFiles.assignAll(_rcDocuments);
    _ctrl.sellInsuranceFiles.assignAll(_insuranceDocs);

    _ctrl.submitSellFormData();
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: 'Sell Your Vehicle',
      subtitle: _categoryName.isNotEmpty
          ? _categoryName
          : 'Submit your vehicle for approval',
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Category — auto-selected, locked ────────────────────────
            _CategoryLockedField(categoryName: _categoryName),
            SizedBox(height: 16.h),

            // ── Vehicle Details ──────────────────────────────────────────
            _SectionHeader(
              label: 'Vehicle Details',
              icon: Icons.directions_car_outlined,
            ),
            SizedBox(height: 10.h),
            _FormCard(
              children: [
                _SellField(
                  label: 'Registration Number *',
                  child: _UniformInput(
                    controller: _regNoController,
                    hint: 'e.g. MH12AB1234',
                    icon: Icons.badge_outlined,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                    ],
                    onChanged: (v) => _regNoController.value = _regNoController
                        .value
                        .copyWith(text: v.toUpperCase()),
                  ),
                ),
                _SellField(
                  label: 'Chassis Number',
                  child: _UniformInput(
                    controller: _chassisController,
                    hint: 'Enter chassis number',
                    icon: Icons.pin_outlined,
                  ),
                ),
                _SellField(
                  label: 'Brand *',
                  child: _BrandField(ctrl: _ctrl),
                ),
                _SellField(
                  label: 'Year of Manufacturing *',
                  child: _UniformInput(
                    controller: _yearController,
                    hint: 'e.g. 2021',
                    icon: Icons.calendar_today_outlined,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                  ),
                ),
                _SellField(
                  label: 'Expected Price (₹) *',
                  child: _UniformInput(
                    controller: _priceController,
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
                  ),
                ),
                _SellField(
                  label: 'Owner Mobile Number *',
                  child: _UniformInput(
                    controller: _ownerMobileController,
                    hint: '10-digit mobile number',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                  ),
                ),
                _SellField(
                  label: 'Asset Description',
                  child: _UniformInput(
                    controller: _descriptionController,
                    hint: 'e.g. Tata Signa 2823.T 6x4',
                    maxLines: 2,
                  ),
                ),
              ],
            ),

            // ── Location ──────────────────────────────────────────────────
            SizedBox(height: 20.h),
            _SectionHeader(label: 'Location', icon: Icons.location_on_outlined),
            SizedBox(height: 10.h),
            _FormCard(
              children: [
                _SellField(
                  label: 'State *',
                  child: _StateField(ctrl: _ctrl),
                ),
                _SellField(
                  label: 'City *',
                  child: _CityField(ctrl: _ctrl),
                ),
              ],
            ),

            // ── Vehicle Condition ────────────────────────────────────────
            SizedBox(height: 20.h),
            _SectionHeader(
              label: 'Vehicle Condition',
              icon: Icons.verified_outlined,
            ),
            SizedBox(height: 10.h),
            _ToggleCard(
              items: [
                _ToggleItem(
                  label: 'Fitness Certificate Available',
                  icon: Icons.verified_outlined,
                  value: _fitnessAvailable,
                  onChanged: (v) => setState(() => _fitnessAvailable = v),
                ),
                _ToggleItem(
                  label: 'Original Invoice Available',
                  icon: Icons.receipt_long_outlined,
                  value: _invoiceAvailable,
                  onChanged: (v) => setState(() => _invoiceAvailable = v),
                ),
                _ToggleItem(
                  label: 'GST Applicable',
                  icon: Icons.percent_outlined,
                  value: _gstApplicable,
                  onChanged: (v) => setState(() => _gstApplicable = v),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            _SellField(
              label: 'Insurance Valid Until',
              child: _DatePickerField(
                controller: _insuranceDateController,
                onPick: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 365)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 3650)),
                    builder: (ctx, child) => Theme(
                      data: Theme.of(ctx).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: AppColors.primary,
                        ),
                      ),
                      child: child!,
                    ),
                  );
                  if (date != null) {
                    setState(() {
                      _insuranceDateController.text =
                          '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
                    });
                  }
                },
              ),
            ),

            // ── Photos & Documents ───────────────────────────────────────
            SizedBox(height: 20.h),
            _SectionHeader(
              label: 'Photos & Documents',
              icon: Icons.photo_library_outlined,
            ),
            SizedBox(height: 10.h),
            _FileField(
              label: 'Vehicle Photos *',
              files: _images,
              onPick: () => _pickFiles(_images),
              onRemove: (i) => setState(() => _images.removeAt(i)),
            ),
            SizedBox(height: 10.h),
            _FileField(
              label: 'RC Documents',
              files: _rcDocuments,
              onPick: () => _pickFiles(_rcDocuments),
              onRemove: (i) => setState(() => _rcDocuments.removeAt(i)),
            ),
            SizedBox(height: 10.h),
            _FileField(
              label: 'Insurance Documents',
              files: _insuranceDocs,
              onPick: () => _pickFiles(_insuranceDocs),
              onRemove: (i) => setState(() => _insuranceDocs.removeAt(i)),
            ),

            SizedBox(height: 28.h),
            Obx(
              () => GradientButton.filled(
                text: 'Submit Vehicle',
                width: double.infinity,
                height: 52.h,
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                isLoading: _ctrl.isSubmittingSellForm.value,
                onPressed: _ctrl.isSubmittingSellForm.value ? null : _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Category — locked/auto-filled field (matches Buy & Sell's Category display)
// ─────────────────────────────────────────────────────────────────────────────

class _CategoryLockedField extends StatelessWidget {
  final String categoryName;
  const _CategoryLockedField({required this.categoryName});

  @override
  Widget build(BuildContext context) {
    return _SellField(
      label: 'Vehicle Category *',
      child: Container(
        height: _kFieldH.h,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
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
                categoryName.isNotEmpty ? categoryName : 'Category',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
// _UniformInput — identical look to Buy & Sell's CustomAutocompleteField
// white bg · shadow · no border · 46.h · 20.sp icon · textSecondary
// ─────────────────────────────────────────────────────────────────────────────

class _UniformInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData? icon;
  final Widget? prefixWidget;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final ValueChanged<String>? onChanged;

  const _UniformInput({
    required this.controller,
    required this.hint,
    this.icon,
    this.prefixWidget,
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: maxLines > 1 ? null : _kFieldH.h,
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
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        maxLines: maxLines,
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
            borderRadius: const BorderRadius.all(Radius.circular(12)),
          ),
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
// Brand Field — searchable dropdown, sourced from category-specific brand list
// ─────────────────────────────────────────────────────────────────────────────

class _BrandField extends StatefulWidget {
  final ApprovedVehicleController ctrl;
  const _BrandField({required this.ctrl});
  @override
  State<_BrandField> createState() => _BrandFieldState();
}

class _BrandFieldState extends State<_BrandField> {
  final _textCtrl = TextEditingController();

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
        options: widget.ctrl.sellBrands,
        placeholder: widget.ctrl.isLoadingSellBrands.value
            ? 'Loading brands...'
            : 'Select brand',
        prefixIcon: Icons.branding_watermark_outlined,
        isLoading: widget.ctrl.isLoadingSellBrands.value,
        displayStringForOption: (b) => b['brand_name'] ?? '',
        forceSelection: true,
        maxDropdownHeight: 220,
        height: _kFieldH.h,
        onSelected: (b) {
          if (b != null) {
            widget.ctrl.sellBrandC.text = b['brand_name'] ?? '';
          }
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// State Field — searchable dropdown
// ─────────────────────────────────────────────────────────────────────────────

class _StateField extends StatefulWidget {
  final ApprovedVehicleController ctrl;
  const _StateField({required this.ctrl});
  @override
  State<_StateField> createState() => _StateFieldState();
}

class _StateFieldState extends State<_StateField> {
  final _textCtrl = TextEditingController();

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
        options: widget.ctrl.sellStates,
        placeholder: 'Select state',
        prefixIcon: Icons.location_on_outlined,
        isLoading: widget.ctrl.isLoadingSellStates.value,
        displayStringForOption: (s) => s['state_name'] ?? '',
        forceSelection: true,
        maxDropdownHeight: 250,
        height: _kFieldH.h,
        onSelected: (s) {
          if (s != null) {
            widget.ctrl.sellStateC.text = s['state_name'] ?? '';
            widget.ctrl.fetchSellCities(s['state_id']!);
          }
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// City Field — searchable dropdown, enabled only once a state is selected
// ─────────────────────────────────────────────────────────────────────────────

class _CityField extends StatefulWidget {
  final ApprovedVehicleController ctrl;
  const _CityField({required this.ctrl});
  @override
  State<_CityField> createState() => _CityFieldState();
}

class _CityFieldState extends State<_CityField> {
  final _textCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    ever(widget.ctrl.sellCities, (_) {
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
      final stateSelected = widget.ctrl.selectedSellStateId.value.isNotEmpty;
      return CustomAutocompleteField<Map<String, String>>(
        controller: _textCtrl,
        options: widget.ctrl.sellCities,
        placeholder: stateSelected ? 'Select city' : 'Select state first',
        prefixIcon: Icons.location_city_outlined,
        isLoading: widget.ctrl.isLoadingSellCities.value,
        enabled: stateSelected,
        displayStringForOption: (c) => c['city_name'] ?? '',
        forceSelection: true,
        maxDropdownHeight: 220,
        height: _kFieldH.h,
        onSelected: (c) {
          if (c != null) {
            widget.ctrl.sellCityC.text = c['city_name'] ?? '';
            widget.ctrl.selectSellCity(c['city_id']!);
          }
        },
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Date Picker Field
// ─────────────────────────────────────────────────────────────────────────────

class _DatePickerField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onPick;
  const _DatePickerField({required this.controller, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPick,
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
                controller.text.isEmpty ? 'Select date' : controller.text,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: controller.text.isEmpty
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
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Toggle Card
// ─────────────────────────────────────────────────────────────────────────────

class _ToggleItem {
  final String label;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;
  _ToggleItem({
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
  });
}

class _ToggleCard extends StatelessWidget {
  final List<_ToggleItem> items;
  const _ToggleCard({required this.items});

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
        children: items.asMap().entries.map((e) {
          final i = e.key;
          final item = e.value;
          final isFirst = i == 0;
          final isLast = i == items.length - 1;
          final on = item.value;

          return Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
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
                        item.icon,
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
                            item.label,
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
                      onChanged: item.onChanged,
                      activeThumbColor: Colors.white,
                      activeTrackColor: AppColors.primary,
                      inactiveThumbColor: AppColors.grey300,
                      inactiveTrackColor: AppColors.grey100,
                    ),
                  ],
                ),
              ),
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
// File Field — placeholder upload zone matching Buy & Sell visuals
// ─────────────────────────────────────────────────────────────────────────────

class _FileField extends StatelessWidget {
  final String label;
  final List<String> files;
  final VoidCallback onPick;
  final ValueChanged<int> onRemove;

  const _FileField({
    required this.label,
    required this.files,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final hasFiles = files.isNotEmpty;
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
        GestureDetector(
          onTap: onPick,
          child: Container(
            width: double.infinity,
            height: 100.h,
            decoration: BoxDecoration(
              color: hasFiles
                  ? AppColors.primary.withValues(alpha: 0.02)
                  : AppColors.primary.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: hasFiles
                    ? AppColors.primary
                    : AppColors.primary.withValues(alpha: 0.35),
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_upload_outlined,
                  size: 30.sp,
                  color: AppColors.primary,
                ),
                SizedBox(height: 6.h),
                Text(
                  hasFiles ? 'Tap to add more' : 'Tap to upload',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (hasFiles) ...[
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: files.asMap().entries.map((entry) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.attach_file,
                      size: 14.w,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 4.w),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 120.w),
                      child: Text(
                        entry.value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 11.sp,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    GestureDetector(
                      onTap: () => onRemove(entry.key),
                      child: Icon(
                        Icons.close,
                        size: 14.w,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
