import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/molecules/custom_autocomplete_field.dart';
import '../../../core/design_system/molecules/custom_snackbar.dart';
import '../../../core/design_system/molecules/floating_label_box.dart';
import '../../../core/design_system/molecules/gradient_button.dart';
import '../../../core/design_system/templates/app_layout.dart';
import '../controllers/approved_vehicle_controller.dart';
import '../utils/sell_form_inputs.dart';
import '../domain/entities/auction_vehicle_match.dart';
import '../../../core/extensions/context_extensions.dart';

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
  final _yardNameController = TextEditingController();
  final _yardLocationController = TextEditingController();

  final List<String> _images = [];

  // Brand box text (owned here so an auction match can fill it in).
  final _brandTextController = TextEditingController();

  // ── Auction lookup: the registration number is checked against our
  // auction listings; a match fills in the details and photos. ──────────
  final _regFocus = FocusNode();
  _LookupState _lookup = _LookupState.idle;
  String _lookedUpReg = '';
  bool _addingPhotos = false;
  int _lookupSeq = 0;

  /// Auction photos that couldn't be added (download failed / wrong format).
  int _photosMissing = 0;

  /// The auction make waiting for the brand list to load, to fill Brand then.
  String? _pendingMake;
  Worker? _brandsWorker;

  /// Photos that came from the auction listing (replaced on a new match).
  final Set<String> _auctionPhotos = {};

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
    _regFocus.addListener(() {
      if (!_regFocus.hasFocus) _checkAuction();
    });
    // The brand list can arrive after the auction match: fill Brand then.
    _brandsWorker = ever<List<Map<String, String>>>(_ctrl.sellBrands, (_) {
      final make = _pendingMake;
      if (make == null || !mounted || _brandTextController.text.isNotEmpty) {
        return;
      }
      _fillBrand(AuctionVehicleMatch(vehicleId: '', make: make));
    });
  }

  @override
  void dispose() {
    _regNoController.dispose();
    _chassisController.dispose();
    _yearController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _yardNameController.dispose();
    _yardLocationController.dispose();
    _brandTextController.dispose();
    _regFocus.dispose();
    _brandsWorker?.dispose();
    super.dispose();
  }

  static const _maxPhotos = 20; // what appr-veh-submit accepts

  /// Opens the device picker and adds the chosen photos' paths to [_images]
  /// (the controller uploads them with `MultipartFile.fromFile`). JPG/PNG/GIF
  /// only, up to 20: anything else makes `appr-veh-submit` reject the form.
  Future<void> _pickPhotos() async {
    final failed = context.l10n.insFailedPickFile;
    if (_images.length >= _maxPhotos) return;
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['jpg', 'jpeg', 'png', 'gif'],
        allowMultiple: true,
      );
      if (result == null || !mounted) return; // cancelled
      final paths = result.files
          .map((f) => f.path)
          .whereType<String>()
          .where((p) => !_images.contains(p))
          .take(_maxPhotos - _images.length);
      setState(() => _images.addAll(paths));
    } catch (_) {
      CustomSnackbar.show(message: failed, type: SnackbarType.error);
    }
  }

  /// Checks the registration number against our auction listings (on
  /// "Check", keyboard done, or leaving the field). A match fills in brand,
  /// year, chassis, description and photos (all still editable); otherwise
  /// the seller enters the details by hand.
  Future<void> _checkAuction() async {
    final reg = _regNoController.text.trim();
    if (reg.length < 4 || reg == _lookedUpReg) return;
    _lookedUpReg = reg;
    final seq = ++_lookupSeq;
    setState(() => _lookup = _LookupState.checking);
    AuctionVehicleMatch? match;
    var failed = false;
    try {
      match = await _ctrl.findAuctionVehicle(reg);
    } catch (_) {
      failed = true;
    }
    if (!mounted || seq != _lookupSeq) return; // the number changed meanwhile
    if (match == null) {
      setState(() {
        _lookup = failed ? _LookupState.failed : _LookupState.notFound;
        if (failed) _lookedUpReg = ''; // allow trying again
      });
      return;
    }
    _fillFrom(match);
    await _addAuctionPhotos(match.images, seq);
  }

  void _fillFrom(AuctionVehicleMatch m) {
    setState(() {
      _lookup = _LookupState.found;
      if (m.chassisNumber != null) _chassisController.text = m.chassisNumber!;
      if (m.year != null) _yearController.text = '${m.year}';
      if (m.description != null) _descriptionController.text = m.description!;
      if (m.yardName != null) _yardNameController.text = m.yardName!;
      if (m.yardLocation != null) {
        _yardLocationController.text = m.yardLocation!;
      }
      _fillBrand(m);
    });
  }

  /// Brand from the auction make: our matching brand when the list has one;
  /// the make as typed when there is no brand list for this category; while
  /// the list is still loading, wait for it ([_brandsWorker]).
  void _fillBrand(AuctionVehicleMatch m) {
    _pendingMake = null;
    if (m.make == null) return;
    if (_ctrl.isLoadingSellBrands.value && _ctrl.sellBrands.isEmpty) {
      _pendingMake = m.make;
      return;
    }
    final name = _ctrl.sellBrands.isEmpty
        ? m.make
        : m.matchBrand(_ctrl.sellBrands)?['brand_name'];
    if (name == null) return;
    _brandTextController.text = name;
    _ctrl.sellBrandC.text = name;
    if (mounted) setState(() {});
  }

  Future<void> _addAuctionPhotos(List<String> urls, int seq) async {
    setState(() {
      _images.removeWhere(_auctionPhotos.contains);
      _auctionPhotos.clear();
      _addingPhotos = urls.isNotEmpty;
      _photosMissing = 0;
    });
    if (urls.isEmpty) return;
    final room = _maxPhotos - _images.length;
    final paths = room <= 0
        ? const <String>[]
        : await _ctrl.downloadAuctionPhotos(urls.take(room).toList());
    if (!mounted || seq != _lookupSeq) return;
    setState(() {
      _addingPhotos = false;
      _images.insertAll(0, paths);
      _auctionPhotos.addAll(paths);
      _photosMissing = (room <= 0 ? 0 : urls.take(room).length) - paths.length;
    });
  }

  void _onRegChanged(String v) {
    _regNoController.value = _regNoController.value.copyWith(
      text: v.toUpperCase(),
    );
    if (_lookup != _LookupState.idle &&
        _regNoController.text.trim() != _lookedUpReg) {
      _lookupSeq++; // ignore an answer for the old number
      setState(() {
        _lookup = _LookupState.idle;
        _lookedUpReg = '';
        _addingPhotos = false;
        _photosMissing = 0;
        _pendingMake = null;
      });
    }
  }

  void _submit() {
    _ctrl.sellCategoryNameC.text = _categoryName;
    _ctrl.sellCategoryCodeC.text = _categoryCode;
    _ctrl.sellRegNumberC.text = _regNoController.text.trim();
    _ctrl.sellChassisC.text = _chassisController.text.trim();
    _ctrl.sellAssetDescC.text = _descriptionController.text.trim();
    _ctrl.sellPriceC.text = _priceController.text.trim();
    _ctrl.sellMfgYear.value = _yearController.text.trim();
    _ctrl.sellYardNameC.text = _yardNameController.text.trim();
    _ctrl.sellYardLocationC.text = _yardLocationController.text.trim();
    _ctrl.sellVehicleImages.assignAll(_images);
    // RC / insurance uploads were removed from the form.
    _ctrl.sellRCFiles.clear();
    _ctrl.sellInsuranceFiles.clear();

    _ctrl.submitSellFormData();
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: context.l10n.apprSellYourVehicle,
      subtitle: _categoryName.isNotEmpty
          ? _categoryName
          : context.l10n.apprSubmitVehicleForApproval,
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
              label: context.l10n.vehicleDetailsTitle,
              icon: Icons.directions_car_outlined,
            ),
            SizedBox(height: 10.h),
            _FormCard(
              children: [
                _UniformInput(
                  label: '${context.l10n.registrationNumber} *',
                  controller: _regNoController,
                  hint: context.l10n.apprRegNoHint,
                  icon: Icons.badge_outlined,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                  ],
                  autocorrect: false,
                  textCapitalization: TextCapitalization.characters,
                  focusNode: _regFocus,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _checkAuction(),
                  onChanged: _onRegChanged,
                  suffix: _lookup == _LookupState.checking
                      ? Padding(
                          padding: EdgeInsets.all(14.r),
                          child: SizedBox(
                            width: 16.r,
                            height: 16.r,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          ),
                        )
                      : TextButton(
                          onPressed: () {
                            _lookedUpReg = ''; // "Check" always asks again
                            FocusScope.of(context).unfocus();
                            _checkAuction();
                          },
                          child: Text(
                            context.l10n.apprAuctionCheck,
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                ),
                if (_lookup != _LookupState.idle)
                  _AuctionLookupNote(
                    state: _lookup,
                    addingPhotos: _addingPhotos,
                    photosMissing: _photosMissing,
                  ),
                _UniformInput(
                  label: context.l10n.apprChassisNumber,
                  controller: _chassisController,
                  hint: context.l10n.apprEnterChassisNumber,
                  icon: Icons.pin_outlined,
                  autocorrect: false,
                  textCapitalization: TextCapitalization.characters,
                ),
                _BrandField(
                  ctrl: _ctrl,
                  label: '${context.l10n.brand} *',
                  textController: _brandTextController,
                ),
                _UniformInput(
                  label: '${context.l10n.apprYearOfManufacturing} *',
                  controller: _yearController,
                  hint: context.l10n.apprYearHint,
                  icon: Icons.calendar_today_outlined,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                ),
                _UniformInput(
                  label: '${context.l10n.apprExpectedPrice} *',
                  controller: _priceController,
                  hint: context.l10n.apprPriceHint,
                  prefixWidget: Text(
                    '₹',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [PriceInputFormatter()],
                ),
                _UniformInput(
                  label: '${context.l10n.apprAssetDescription} *',
                  controller: _descriptionController,
                  hint: context.l10n.apprAssetDescriptionHint,
                  maxLines: 2,
                ),
              ],
            ),

            // ── Location ──────────────────────────────────────────────────
            SizedBox(height: 20.h),
            _SectionHeader(
              label: context.l10n.location,
              icon: Icons.location_on_outlined,
            ),
            SizedBox(height: 10.h),
            _FormCard(
              children: [
                _StateField(ctrl: _ctrl, label: '${context.l10n.state} *'),
                _CityField(ctrl: _ctrl, label: '${context.l10n.city} *'),
                _UniformInput(
                  label: context.l10n.apprYardName,
                  controller: _yardNameController,
                  hint: context.l10n.apprYardNameHint,
                  icon: Icons.warehouse_outlined,
                ),
                _UniformInput(
                  label: context.l10n.apprYardLocation,
                  controller: _yardLocationController,
                  hint: context.l10n.apprYardLocationHint,
                  icon: Icons.place_outlined,
                  maxLines: 2,
                ),
              ],
            ),

            // ── Photos & Documents ───────────────────────────────────────
            SizedBox(height: 20.h),
            _SectionHeader(
              label: context.l10n.apprPhotosAndDocuments,
              icon: Icons.photo_library_outlined,
            ),
            SizedBox(height: 10.h),
            _FileField(
              label: '${context.l10n.apprVehiclePhotos} *',
              files: _images,
              onPick: _pickPhotos,
              onRemove: (i) => setState(() {
                _auctionPhotos.remove(_images[i]);
                _images.removeAt(i);
              }),
            ),

            SizedBox(height: 28.h),
            Obx(
              () => Center(
                child: GradientButton.filled(
                  text: context.l10n.apprSubmitVehicle,
                  width: 140.w,
                  height: 36.h,
                  isLoading: _ctrl.isSubmittingSellForm.value,
                  onPressed: _ctrl.isSubmittingSellForm.value ? null : _submit,
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
// Category — locked/auto-filled field (matches Buy & Sell's Category display)
// ─────────────────────────────────────────────────────────────────────────────

class _CategoryLockedField extends StatelessWidget {
  final String categoryName;
  const _CategoryLockedField({required this.categoryName});

  @override
  Widget build(BuildContext context) {
    // Locked, so the label always sits on the border (hasValue).
    return FloatingLabelBox(
      label: '${context.l10n.apprVehicleCategory} *',
      hasValue: true,
      height: _kFieldH.h,
      fillColor: AppColors.primary.withValues(alpha: 0.06),
      child: SizedBox(
        height: _kFieldH.h,
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
                categoryName.isNotEmpty ? categoryName : context.l10n.category,
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
                context.l10n.apprAutoFilled,
                maxLines: 1,
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
        Flexible(
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
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
// _UniformInput — identical look to Buy & Sell's CustomAutocompleteField
// white bg · shadow · no border · 46.h · 20.sp icon · textSecondary
// ─────────────────────────────────────────────────────────────────────────────

class _UniformInput extends StatelessWidget {
  final TextEditingController controller;

  /// Floating label: sits inside while empty, floats onto the border.
  final String label;

  /// Shown once the label has floated and the box is still empty.
  final String hint;
  final IconData? icon;
  final Widget? prefixWidget;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final Widget? suffix;

  /// Off for codes (registration, chassis): iOS autocorrect otherwise
  /// rewrites e.g. "ts" to "ya".
  final bool autocorrect;
  final TextCapitalization textCapitalization;

  const _UniformInput({
    required this.controller,
    required this.label,
    required this.hint,
    this.icon,
    this.prefixWidget,
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.textInputAction,
    this.suffix,
    this.autocorrect = true,
    this.textCapitalization = TextCapitalization.none,
  });

  static OutlineInputBorder _outline(Color color, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide(color: color, width: width),
      );

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
        onSubmitted: onSubmitted,
        focusNode: focusNode,
        textInputAction: textInputAction,
        autocorrect: autocorrect,
        enableSuggestions: autocorrect,
        textCapitalization: textCapitalization,
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 14.sp,
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14.sp,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w400,
          ),
          floatingLabelStyle: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 12.sp,
            color: AppColors.grey650,
            fontWeight: FontWeight.w600,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          hintText: hint,
          hintStyle: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14.sp,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w400,
          ),
          border: _outline(AppColors.grey300),
          enabledBorder: _outline(AppColors.grey300),
          focusedBorder: _outline(AppColors.primary, width: 1.5),
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
          suffixIcon: suffix,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 12.w,
            vertical: 12.h,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Auction lookup note — under the registration number
// ─────────────────────────────────────────────────────────────────────────────

enum _LookupState { idle, checking, found, notFound, failed }

class _AuctionLookupNote extends StatelessWidget {
  final _LookupState state;
  final bool addingPhotos;
  final int photosMissing;
  const _AuctionLookupNote({
    required this.state,
    required this.addingPhotos,
    this.photosMissing = 0,
  });

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final found = state == _LookupState.found;
    final (IconData icon, Color color, String text) = switch (state) {
      _LookupState.found => (
        Icons.check_circle_rounded,
        AppColors.successDark,
        l.apprAuctionFound,
      ),
      _LookupState.notFound => (
        Icons.info_outline_rounded,
        AppColors.textSecondary,
        l.apprAuctionNotFound,
      ),
      _LookupState.failed => (
        Icons.error_outline_rounded,
        AppColors.warningDark,
        l.apprAuctionCheckFailed,
      ),
      _ => (
        Icons.search_rounded,
        AppColors.textSecondary,
        l.apprAuctionChecking,
      ),
    };
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: found ? const Color(0xFFE8F5E9) : AppColors.grey100,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18.r, color: color),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12.sp,
                    fontWeight: found ? FontWeight.w600 : FontWeight.w500,
                    color: color,
                    height: 1.4,
                  ),
                ),
                if (found && addingPhotos) ...[
                  SizedBox(height: 4.h),
                  Text(
                    l.apprAuctionPhotosAdding,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 11.sp,
                      color: color,
                    ),
                  ),
                ],
                if (found && !addingPhotos && photosMissing > 0) ...[
                  SizedBox(height: 4.h),
                  Text(
                    l.apprAuctionPhotosMissing(photosMissing),
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.warningDark,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Brand Field — searchable dropdown, sourced from category-specific brand list
// ─────────────────────────────────────────────────────────────────────────────

class _BrandField extends StatefulWidget {
  final ApprovedVehicleController ctrl;
  final String label;

  /// Owned by the form, so an auction match can fill the brand in.
  final TextEditingController textController;
  const _BrandField({
    required this.ctrl,
    required this.label,
    required this.textController,
  });
  @override
  State<_BrandField> createState() => _BrandFieldState();
}

class _BrandFieldState extends State<_BrandField> {
  @override
  Widget build(BuildContext context) {
    // No brand list came back (e.g. the backend's 2W/3W brands are not
    // deployed yet): let the seller type the brand instead of blocking them.
    return Obx(() {
      final typed =
          !widget.ctrl.isLoadingSellBrands.value &&
          widget.ctrl.sellBrands.isEmpty;
      return CustomAutocompleteField<Map<String, String>>(
        controller: widget.textController,
        options: widget.ctrl.sellBrands.toList(),
        label: widget.label,
        placeholder: widget.ctrl.isLoadingSellBrands.value
            ? context.l10n.loadingBrands
            : (typed
                  ? context.l10n.enterVehicleBrand
                  : context.l10n.selectBrand),
        prefixIcon: Icons.branding_watermark_outlined,
        isLoading: widget.ctrl.isLoadingSellBrands.value,
        displayStringForOption: (b) => b['brand_name'] ?? '',
        forceSelection: !typed,
        maxDropdownHeight: 220,
        height: _kFieldH.h,
        onChanged: typed ? (v) => widget.ctrl.sellBrandC.text = v.trim() : null,
        onSelected: (b) {
          widget.ctrl.sellBrandC.text = b?['brand_name'] ?? '';
        },
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// State Field — searchable dropdown
// ─────────────────────────────────────────────────────────────────────────────

class _StateField extends StatefulWidget {
  final ApprovedVehicleController ctrl;
  final String label;
  const _StateField({required this.ctrl, required this.label});
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
        label: widget.label,
        placeholder: context.l10n.selectState,
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
  final String label;
  const _CityField({required this.ctrl, required this.label});
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
        label: widget.label,
        placeholder: stateSelected
            ? context.l10n.selectCity
            : context.l10n.apprSelectStateFirst,
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
            constraints: BoxConstraints(minHeight: 100.h),
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
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: Text(
                    hasFiles
                        ? context.l10n.apprTapToAddMore
                        : context.l10n.apprTapToUpload,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.center,
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
                        // Just the file name, not the full device path.
                        entry.value.split(RegExp(r'[/\\]')).last,
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
