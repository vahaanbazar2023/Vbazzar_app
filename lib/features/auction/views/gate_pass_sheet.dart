import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/molecules/custom_snackbar.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/storage/storage_keys.dart';
import '../../subscription/models/subscription_plan.dart';
import '../../subscription/views/single_plan_payment_screen.dart';
import '../models/vehicle_listing.dart';
import '../services/gate_pass_service.dart';
import 'gate_pass_widgets.dart';

/// Small "Gate Pass" button for the vehicle detail screen. Opens [GatePassSheet].
class GatePassButton extends StatelessWidget {
  final VehicleListing vehicle;
  const GatePassButton({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Gate pass',
      child: Material(
        color: const Color(0xFFFFF4F4),
        shape: StadiumBorder(
          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: () {
            HapticFeedback.selectionClick();
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              useSafeArea: true,
              backgroundColor: Colors.transparent,
              builder: (_) => GatePassSheet(vehicle: vehicle),
            );
          },
          child: Container(
            constraints: BoxConstraints(minHeight: 36.h),
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.qr_code_2_rounded, size: 16.r, color: AppColors.primary),
                SizedBox(width: 6.w),
                Text(
                  'Gate Pass',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
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

enum _Mode { self, authorized, mechanic }

class GatePassSheet extends StatefulWidget {
  final VehicleListing vehicle;
  const GatePassSheet({super.key, required this.vehicle});

  @override
  State<GatePassSheet> createState() => _GatePassSheetState();
}

class _GatePassSheetState extends State<GatePassSheet> {
  final _service = GatePassService();
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _mobile = TextEditingController();
  final _aadhaar = TextEditingController();

  bool _loading = true;
  bool _submitting = false;
  String? _error;
  InspectionRequestSummary? _request;
  GatePassInfo? _gatePass;
  String? _estimate;
  double _estMaxWallet = 0;
  String? _category;
  InspectionPaymentOptions? _payOptions;
  String? _payError; // why the pay screen couldn't be shown
  bool _useWallet = false;

  _Mode _mode = _Mode.self;
  XFile? _idProof;
  XFile? _photo;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _name.dispose();
    _mobile.dispose();
    _aadhaar.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final req = await _service.findRequestForVehicle(widget.vehicle.vehicleId);
      GatePassInfo? gp;
      String? estimate;
      String? category;
      double estMaxWallet = 0;
      InspectionPaymentOptions? options;
      String? payError;
      if (req == null) {
        final e = await _service.fetchChargeEstimate(widget.vehicle.auctionId);
        estimate = e.amount == null
            ? null
            : e.amount!.toStringAsFixed(e.amount! % 1 == 0 ? 0 : 2);
        category = e.category;
        estMaxWallet = e.maxWallet;
      } else {
        if (_gatePassPossible(req.status)) {
          gp = await _service.fetchGatePass(req.inspectionId);
        }
        if (req.inspectionType == GatePassService.mechanicType &&
            (req.status == 'SALES_TEAM_CONTACT_PENDING' ||
                req.status == 'PAYMENT_PENDING')) {
          try {
            options = await _service.fetchPaymentOptions(req.inspectionId);
          } on GatePassException catch (e) {
            payError = e.message; // keep the request visible, explain why
          }
        }
      }
      if (!mounted) return;
      setState(() {
        _request = req;
        _gatePass = gp;
        _estimate = estimate;
        _estMaxWallet = estMaxWallet;
        _category = category;
        _payOptions = options;
        _payError = payError;
        _useWallet = false;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  bool _gatePassPossible(String status) => const {
    'APPROVED',
    'MECHANIC_ASSIGNED',
    'INSPECTION_COMPLETED',
  }.contains(status);

  Future<void> _pick(bool isPhoto) async {
    final f = await ImagePicker().pickImage(
      source: isPhoto ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 80,
    );
    if (f != null) setState(() => isPhoto ? _photo = f : _idProof = f);
  }

  Future<void> _submit() async {
    if (_mode == _Mode.authorized) {
      if (!_formKey.currentState!.validate()) return;
      if (_idProof == null || _photo == null) {
        CustomSnackbar.show(
          message: 'Please add ID proof and photograph',
          type: SnackbarType.warning,
        );
        return;
      }
    }
    if (_mode == _Mode.mechanic && !await _confirmCharge()) return;
    setState(() => _submitting = true);
    try {
      final userId =
          await SecureStorageService.to.read(StorageKeys.userId) ?? '';
      AuthorizedPersonInput? person;
      if (_mode == _Mode.authorized) {
        final urls = await _service.uploadDocuments(
          idProofPath: _idProof!.path,
          photographPath: _photo!.path,
        );
        person = AuthorizedPersonInput(
          name: _name.text.trim(),
          mobileNumber: _mobile.text.trim(),
          aadhaarNumber: _aadhaar.text.trim(),
          idProofUrl: urls.idProofUrl,
          photographUrl: urls.photographUrl,
        );
      }
      final req = await _service.createRequest(
        userId: userId,
        vehicleId: widget.vehicle.vehicleId,
        auctionId: widget.vehicle.auctionId,
        inspectionType: _mode == _Mode.mechanic
            ? GatePassService.mechanicType
            : GatePassService.userType,
        inspectorMode: switch (_mode) {
          _Mode.self => 'SELF',
          _Mode.authorized => 'AUTHORIZED_PERSON',
          _Mode.mechanic => null,
        },
        authorizedPerson: person,
      );
      if (!mounted) return;
      setState(() {
        _request = req;
        _submitting = false;
      });
      if (req.inspectionType == GatePassService.mechanicType) {
        await _startPaymentFor(req);
      } else {
        CustomSnackbar.show(
          message: 'Inspection request submitted',
          type: SnackbarType.success,
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      CustomSnackbar.show(message: e.toString(), type: SnackbarType.error);
    }
  }

  /// Popup shown before a mechanic request: states the category charge so the
  /// user knows a payment applies. Returns true when the user continues.
  Future<bool> _confirmCharge() async {
    final category = (_category ?? '').toUpperCase();
    var wallet = false;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setD) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.r),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 18.h),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [kGpInk, kGpInkSoft],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.engineering_rounded,
                            color: Colors.white70, size: 18.r),
                        SizedBox(width: 8.w),
                        Text(
                          'MECHANIC INSPECTION',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 11.sp,
                            letterSpacing: 1.4,
                            fontWeight: FontWeight.w700,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      _estimate == null ? 'Charge applies' : '₹ $_estimate',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 30.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    if (category.isNotEmpty)
                      Text(
                        'for $category vehicles',
                        style: TextStyle(fontSize: 12.sp, color: Colors.white70),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _point(Icons.sell_rounded,
                        'Inspection is charged per vehicle category.'),
                    _point(
                      Icons.account_balance_wallet_rounded,
                      'You pay online right after requesting. You can use your wallet for up to 50% of the charge.',
                    ),
                    _point(Icons.verified_rounded,
                        'Your gate pass is issued after payment and approval.'),
                    if (_estMaxWallet > 0)
                      Container(
                        margin: EdgeInsets.only(top: 4.h),
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF4F4),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.account_balance_wallet_rounded,
                                size: 20.r, color: AppColors.primary),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Text(
                                'Use wallet ₹${_estMaxWallet.toStringAsFixed(_estMaxWallet % 1 == 0 ? 0 : 2)}',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Switch(
                              value: wallet,
                              activeColor: AppColors.primary,
                              onChanged: (v) => setD(() => wallet = v),
                            ),
                          ],
                        ),
                      ),
                    SizedBox(height: 16.h),
                    GpGradientButton(
                      label: _estimate == null ? 'Continue' : 'Continue to payment',
                      icon: Icons.arrow_forward_rounded,
                      onTap: () => Navigator.of(ctx).pop(true),
                    ),
                    SizedBox(height: 4.h),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: const Text('Cancel'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ));
    _useWallet = wallet;
    return ok ?? false;
  }

  Widget _point(IconData icon, String text) => Padding(
    padding: EdgeInsets.only(bottom: 10.h),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18.r, color: AppColors.primary),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 12.5.sp, height: 1.4, color: AppColors.grey800),
          ),
        ),
      ],
    ),
  );

  bool _downloading = false;

  /// Mechanic request just created: load the payable amounts and open the
  /// payment screen straight away (no second tap / refresh needed).
  Future<void> _startPaymentFor(InspectionRequestSummary req) async {
    try {
      final opts = await _service.fetchPaymentOptions(req.inspectionId);
      if (!mounted) return;
      setState(() {
        _payOptions = opts;
        _payError = null;
      });
      _payNow();
    } on GatePassException catch (e) {
      if (!mounted) return;
      setState(() => _payError = e.message); // status view explains why
    }
  }

  /// Opens the same payment screen buy/sell uses (Proceed Payment -> PayU) for
  /// the category's plan code (AUCIxx). The wallet portion chosen on the pay
  /// card (<= 50%, enforced by the server) is deducted; the rest goes to PayU.
  void _payNow() {
    final opts = _payOptions;
    final req = _request;
    if (opts == null || req == null) return;
    final wallet = _useWallet && opts.maxWallet > 0 ? opts.maxWallet : 0.0;
    final payable = opts.charge - wallet;
    String money(double v) => v.toStringAsFixed(v == v.roundToDouble() ? 0 : 2);

    final plan = SubscriptionPlan(
      typeCode: 'AUC_INSP',
      planCode: opts.planCode,
      name: 'Mechanic Inspection',
      price: payable,
      displayOrder: 1,
      status: 'active',
      featDescription: wallet > 0
          ? '₹${money(opts.charge)} − ₹${money(wallet)} from wallet'
          : 'Vahaan Bazar mechanic inspection',
      planMetric: 'days',
      planMetricValue: '0',
    );

    Get.to(
      () => SinglePlanPaymentScreen(
        plan: plan,
        title: 'Inspection Payment',
        subtitle:
            'Pay the inspection charge to confirm your mechanic inspection request.',
        source: 'AUC_INSP',
        inspectionId: req.inspectionId,
        fromWallet: wallet > 0 ? wallet : null,
        showWalletLink: false,
        onPaymentSuccess: () {
          Get.back(); // close the payment screen, back to the sheet
          CustomSnackbar.show(
            message: 'Payment successful. Your request is now with our team.',
            type: SnackbarType.success,
          );
          if (mounted) _load();
        },
      ),
      transition: Transition.rightToLeft,
    );
  }

  Future<void> _download(GatePassInfo gp) async {
    setState(() => _downloading = true);
    try {
      await _service.downloadAndOpen(
        inspectionId: _request!.inspectionId,
        gatePassId: gp.gatePassId,
      );
    } catch (e) {
      CustomSnackbar.show(message: e.toString(), type: SnackbarType.error);
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.82,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scroll) => Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          children: [
            SizedBox(height: 10.h),
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            _header(),
            Expanded(
              child: ListView(
                controller: scroll,
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  4.h,
                  AppSpacing.md,
                  MediaQuery.of(context).viewInsets.bottom +
                      MediaQuery.of(context).viewPadding.bottom +
                      AppSpacing.md,
                ),
                children: [
                  if (_loading)
                    ...[
                      GpSkeleton(height: 120.h),
                      SizedBox(height: 12.h),
                      GpSkeleton(height: 180.h),
                    ]
                  else if (_error != null)
                    _errorView()
                  else if (_request == null)
                    _requestForm()
                  else
                    _statusView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: EdgeInsets.fromLTRB(AppSpacing.md, 12.h, 8.w, 8.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.ctaGradientStart, AppColors.ctaGradientEnd],
              ),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.qr_code_2_rounded, size: 22.r, color: Colors.white),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gate Pass',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
                Text(
                  '${widget.vehicle.make} | ${widget.vehicle.model}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 12.sp,
                    color: AppColors.grey600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Close',
            constraints: BoxConstraints(minWidth: 44.r, minHeight: 44.r),
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    );
  }

  Widget _errorView() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4F4),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFFFD0D0)),
      ),
      child: Column(
        children: [
          Icon(Icons.wifi_off_rounded, color: AppColors.error, size: 28.r),
          SizedBox(height: 8.h),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.sp, color: AppColors.grey800),
          ),
          SizedBox(height: 12.h),
          GpGradientButton(label: 'Try again', icon: Icons.refresh, onTap: _load),
        ],
      ),
    );
  }

  // ── No request yet ─────────────────────────────────────────
  Widget _requestForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Who will inspect the vehicle?'),
          SizedBox(height: 10.h),
          _optionCard(
            mode: _Mode.self,
            icon: Icons.person_rounded,
            title: 'I will inspect',
            subtitle: 'Visit the yard yourself with your pass',
          ),
          _optionCard(
            mode: _Mode.authorized,
            icon: Icons.badge_rounded,
            title: 'Authorized person',
            subtitle: 'Send someone you trust (ID proof needed)',
          ),
          _optionCard(
            mode: _Mode.mechanic,
            icon: Icons.engineering_rounded,
            title: 'Vahaan Bazar mechanic',
            subtitle: 'Expert inspection by our mechanic',
            tag: _estimate == null ? 'Chargeable' : 'From ₹$_estimate',
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: _mode == _Mode.authorized
                ? _authorizedFields()
                : const SizedBox(width: double.infinity),
          ),
          SizedBox(height: AppSpacing.md),
          GpGradientButton(
            label: _mode == _Mode.mechanic
                ? 'Request mechanic inspection'
                : 'Request gate pass',
            icon: Icons.arrow_forward_rounded,
            loading: _submitting,
            onTap: _submit,
          ),
          SizedBox(height: 8.h),
          Center(
            child: Text(
              'You will get your pass here once the request is approved.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11.sp, color: AppColors.grey600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String t) => Text(
    t,
    style: TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 14.sp,
      fontWeight: FontWeight.w700,
      color: AppColors.black,
    ),
  );

  Widget _optionCard({
    required _Mode mode,
    required IconData icon,
    required String title,
    required String subtitle,
    String? tag,
  }) {
    final selected = _mode == mode;
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Semantics(
        button: true,
        selected: selected,
        label: title,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _mode = mode);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            constraints: BoxConstraints(minHeight: 64.h),
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFFFF4F4) : AppColors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.grey200,
                width: selected ? 1.6 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40.r,
                  height: 40.r,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : AppColors.grey100,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    icon,
                    size: 20.r,
                    color: selected ? Colors.white : AppColors.grey700,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 11.sp,
                          color: AppColors.grey600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (tag != null)
                  Container(
                    margin: EdgeInsets.only(left: 6.w),
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEFC2),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF9A5B00),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _dec(String label, {IconData? icon}) => InputDecoration(
    labelText: label,
    counterText: '',
    prefixIcon: icon == null ? null : Icon(icon, size: 18.r),
    filled: true,
    fillColor: AppColors.grey50,
    contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: const BorderSide(color: AppColors.grey200),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: const BorderSide(color: AppColors.grey200),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
    ),
  );

  Widget _authorizedFields() {
    return Padding(
      padding: EdgeInsets.only(top: 6.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Authorized person details'),
          SizedBox(height: 10.h),
          TextFormField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
            decoration: _dec('Full name', icon: Icons.person_outline),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Enter the full name' : null,
          ),
          SizedBox(height: 10.h),
          TextFormField(
            controller: _mobile,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: _dec('Mobile number', icon: Icons.phone_outlined),
            validator: (v) =>
                (v ?? '').length == 10 ? null : 'Enter a 10-digit number',
          ),
          SizedBox(height: 10.h),
          TextFormField(
            controller: _aadhaar,
            keyboardType: TextInputType.number,
            maxLength: 12,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: _dec('Aadhaar number', icon: Icons.credit_card_outlined),
            validator: (v) =>
                (v ?? '').length == 12 ? null : 'Enter a 12-digit Aadhaar',
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: _uploadTile(
                  label: 'ID proof',
                  icon: Icons.upload_file_rounded,
                  file: _idProof,
                  onTap: () => _pick(false),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _uploadTile(
                  label: 'Photograph',
                  icon: Icons.camera_alt_rounded,
                  file: _photo,
                  onTap: () => _pick(true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _uploadTile({
    required String label,
    required IconData icon,
    required XFile? file,
    required VoidCallback onTap,
  }) {
    final added = file != null;
    return Semantics(
      button: true,
      label: added ? '$label added. Tap to replace' : 'Add $label',
      child: InkWell(
        borderRadius: BorderRadius.circular(14.r),
        onTap: onTap,
        child: Container(
          height: 92.h,
          decoration: BoxDecoration(
            color: added ? const Color(0xFFF0FFF4) : AppColors.grey50,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: added ? AppColors.success : AppColors.grey300,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                added ? Icons.check_circle_rounded : icon,
                size: 26.r,
                color: added ? AppColors.success : AppColors.primary,
              ),
              SizedBox(height: 6.h),
              Text(
                added ? '$label added' : label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey800,
                ),
              ),
              if (added)
                Text(
                  'Tap to replace',
                  style: TextStyle(fontSize: 10.sp, color: AppColors.grey600),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Request exists ─────────────────────────────────────────
  Widget _statusView() {
    final r = _request!;
    final gp = _gatePass;
    final pill = gpRequestStatus(r.status);
    final journey = gpJourney(r.inspectionType, r.status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Request ${r.inspectionId}',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey700,
                ),
              ),
            ),
            GpStatusPill(label: pill.label, tone: pill.tone),
          ],
        ),
        SizedBox(height: 12.h),
        if (_payOptions != null)
          _paymentCard()
        else if (gp != null)
          GatePassTicket(
            vehicleTitle: '${widget.vehicle.make} ${widget.vehicle.model}'.trim(),
            registrationNo: widget.vehicle.registrationNo,
            gatePassId: gp.gatePassId,
            auctionId: widget.vehicle.auctionId,
            verificationCode: gp.verificationCode,
            active: gp.isActive,
            expired: gp.isExpired,
            expiresAt: gp.expiresAt,
            onDownload: () => _download(gp),
            downloading: _downloading,
          )
        else
          _hintCard(_pendingHint(r.status), failed: journey.failed),
        SizedBox(height: AppSpacing.md),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.grey50,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.grey200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('Request progress'),
              SizedBox(height: 12.h),
              GpTimeline(
                steps: journey.steps,
                current: journey.current,
                failed: journey.failed,
              ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        Center(
          child: TextButton.icon(
            onPressed: _load,
            icon: Icon(Icons.refresh_rounded, size: 18.r),
            label: const Text('Refresh status'),
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
          ),
        ),
      ],
    );
  }

  Widget _paymentCard() {
    final o = _payOptions!;
    final walletPart = _useWallet ? o.maxWallet : 0.0;
    final payable = o.charge - walletPart;
    String money(double v) => v.toStringAsFixed(v == v.roundToDouble() ? 0 : 2);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kGpInk, kGpInkSoft],
        ),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MECHANIC INSPECTION CHARGE',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 11.sp,
              letterSpacing: 1.4,
              fontWeight: FontWeight.w700,
              color: Colors.white70,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            '₹ ${money(o.charge)}',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 30.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 12.h),
          if (o.maxWallet > 0)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.account_balance_wallet_rounded,
                      color: Colors.white70, size: 20.r),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Use wallet ₹${money(o.maxWallet)}',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Up to 50% of the charge · balance ₹${money(o.walletBalance)}',
                          style: TextStyle(fontSize: 11.sp, color: Colors.white60),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _useWallet,
                    activeColor: AppColors.primaryLight,
                    onChanged: (v) {
                      HapticFeedback.selectionClick();
                      setState(() => _useWallet = v);
                    },
                  ),
                ],
              ),
            ),
          SizedBox(height: 12.h),
          if (walletPart > 0)
            Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('From wallet',
                      style: TextStyle(fontSize: 12.sp, color: Colors.white70)),
                  Text('− ₹${money(walletPart)}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      )),
                ],
              ),
            ),
          GpGradientButton(
            label: 'Pay ₹${money(payable)}',
            icon: Icons.lock_rounded,
            onTap: _payNow,
          ),
        ],
      ),
    );
  }

  Widget _hintCard(String text, {bool failed = false}) {
    final color = failed ? AppColors.error : const Color(0xFF9A5B00);
    final bg = failed ? const Color(0xFFFFF4F4) : const Color(0xFFFFF8E6);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            failed ? Icons.error_outline_rounded : Icons.hourglass_top_rounded,
            color: color,
            size: 22.r,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12.5.sp,
                height: 1.4,
                color: AppColors.grey800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _pendingHint(String status) {
    switch (status) {
      case 'PENDING_ADMIN_APPROVAL':
        return 'Waiting for admin approval. Your Gate Pass will appear here once approved.';
      case 'REJECTED':
      case 'CANCELLED':
        return 'This request is closed. No Gate Pass is available.';
      case 'SALES_TEAM_CONTACT_PENDING':
      case 'CHARGES_FINALIZED':
      case 'PAYMENT_PENDING':
        return _payError ??
            'Payment details could not be loaded. Tap Refresh to try again.';
      case 'PAYMENT_RECEIVED':
        return 'Payment received. Your request is waiting for admin approval.';
      default:
        return 'Gate Pass is not available yet.';
    }
  }
}
