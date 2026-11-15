import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/molecules/custom_snackbar.dart';
import '../../../core/design_system/molecules/gradient_button.dart';
import '../../../core/design_system/templates/app_layout.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/storage/storage_keys.dart';
import '../../payment/controllers/payment_controller.dart';
import '../models/subscription_plan.dart';
import 'wallet_payment_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Single-plan payment screen — same light theme as SubscriptionScreen.
// "Proceed Payment" button + "or pay from My wallet" link below.
// No subscription-listing API call — plan is passed directly.
// ─────────────────────────────────────────────────────────────────────────────

class SinglePlanPaymentScreen extends StatefulWidget {
  final SubscriptionPlan plan;
  final String? title;
  final String subtitle;

  /// Source identifier used when routing through WalletPaymentScreen
  /// (e.g. 'INSPECTION', 'SUBT006').
  final String source;

  /// Optional shop ID — used by SUBT006 wallet flow to unlock shop contact.
  final String? shopId;

  /// Optional mechanic ID — used by SUBT007 wallet flow to unlock mechanic contact.
  final String? mechanicId;

  /// Auction mechanic inspection (plan codes AUCIxx): the Inspection_Request
  /// being paid for. Sent to /payments/initiate with the plan code.
  final String? inspectionId;

  /// Wallet portion already chosen by the caller (server caps it at 50%).
  /// [plan.price] is then the gateway amount.
  final double? fromWallet;

  /// Hide the "or pay from My wallet" link when the caller handles the wallet.
  final bool showWalletLink;

  /// Called immediately after payment success (direct pay path).
  final VoidCallback onPaymentSuccess;

  const SinglePlanPaymentScreen({
    super.key,
    required this.plan,
    required this.onPaymentSuccess,
    this.title,
    this.subtitle = '',
    this.source = 'INSPECTION',
    this.shopId,
    this.mechanicId,
    this.inspectionId,
    this.fromWallet,
    this.showWalletLink = true,
  });

  @override
  State<SinglePlanPaymentScreen> createState() =>
      _SinglePlanPaymentScreenState();
}

class _SinglePlanPaymentScreenState extends State<SinglePlanPaymentScreen> {
  bool _isProcessing = false;
  late final PaymentController _paymentCtrl;

  @override
  void initState() {
    super.initState();
    _paymentCtrl = Get.isRegistered<PaymentController>()
        ? Get.find<PaymentController>()
        : Get.put(PaymentController());
  }

  Future<void> _onProceedPayment() async {
    final userId = await SecureStorageService.to.read(StorageKeys.userId);
    if (userId == null || userId.isEmpty) {
      CustomSnackbar.show(
        message: context.l10n.pleaseLoginToContinue,
        type: SnackbarType.error,
      );
      return;
    }

    setState(() => _isProcessing = true);

    _paymentCtrl.onSuccess = (data, callback) {
      setState(() => _isProcessing = false);
      widget.onPaymentSuccess();
    };

    _paymentCtrl.onFailure = (message, callback) {
      setState(() => _isProcessing = false);
      CustomSnackbar.show(
        message: context.l10n.profSubPaymentFailedMsg(message),
        type: SnackbarType.error,
      );
    };

    _paymentCtrl.onCancelled = () {
      setState(() => _isProcessing = false);
    };

    final success = await _paymentCtrl.initiatePayment(
      userId: userId,
      planCode: widget.plan.planCode,
      forPayment: widget.plan.price,
      fromWallet: widget.fromWallet,
      inspectionId: widget.inspectionId,
    );

    if (!success && _isProcessing) {
      setState(() => _isProcessing = false);
    }
  }

  void _onPayFromWallet() {
    // Navigate to WalletPaymentScreen — same as SubscriptionScreen's wallet path.
    // WalletPaymentScreen creates its own SubscriptionConfirmController with
    // the plan and source, which handles wallet eligibility and payment.
    final extraArgs = <String, dynamic>{
      'onSuccess': widget.onPaymentSuccess,
      if (widget.shopId != null) 'shop_id': widget.shopId,
      if (widget.mechanicId != null) 'mechanic_id': widget.mechanicId,
    };
    Get.to(
      () => WalletPaymentScreen(
        plan: widget.plan,
        source: widget.source,
        extraArgs: extraArgs,
      ),
      transition: Transition.rightToLeft,
    );
  }

  String get _price =>
      widget.plan.price.toStringAsFixed(widget.plan.price % 1 == 0 ? 0 : 2);

  Widget _summaryRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: bold ? 14.sp : 13.sp,
              fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
              color: bold ? AppColors.textPrimary : AppColors.grey650,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: bold ? 16.sp : 13.sp,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                color: bold ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _trustItem(IconData icon, String title, String sub) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 38.r,
            height: 38.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.08),
            ),
            child: Icon(icon, size: 18.r, color: AppColors.primary),
          ),
          SizedBox(height: 6.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            sub,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 10.sp,
              color: AppColors.grey650,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final plan = widget.plan;
    final l10n = context.l10n;
    final hasValidity =
        plan.planMetric == 'days' && plan.planMetricValue.isNotEmpty;

    return AppLayout(
      title: widget.title ?? l10n.subscribe,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.subtitle.isNotEmpty) ...[
                    Text(
                      widget.subtitle,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 13.sp,
                        color: AppColors.grey650,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 14.h),
                  ],

                  // ── Hero: plan on brand gradient ─────────────────────
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 16.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.r),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.ctaGradientStart,
                          AppColors.ctaGradientEnd,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.28),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 46.r,
                              height: 46.r,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.18),
                              ),
                              child: Icon(
                                Icons.build_rounded,
                                size: 22.r,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                plan.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18.sp,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (plan.featDescription.isNotEmpty) ...[
                          SizedBox(height: 10.h),
                          Text(
                            plan.featDescription,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 12.sp,
                              height: 1.4,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                        SizedBox(height: 14.h),
                        Divider(
                          height: 1,
                          color: Colors.white.withValues(alpha: 0.22),
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '\u20B9$_price',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w700,
                                fontSize: 28.sp,
                                height: 1,
                                color: Colors.white,
                              ),
                            ),
                            const Spacer(),
                            if (hasValidity)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 5.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                child: Text(
                                  plan.metricLabel,
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // ── Order summary ────────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: const Color(0xFFEEEEEE)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.profSubOrderSummary,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                            fontSize: 14.sp,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        _summaryRow(l10n.profSubPlanLabel, plan.name),
                        if (hasValidity)
                          _summaryRow(
                            l10n.profSubValidityLabel,
                            plan.metricLabel,
                          ),
                        const Divider(height: 14, color: Color(0xFFF0F0F0)),
                        _summaryRow(
                          l10n.profSubTotalAmount,
                          '\u20B9$_price',
                          bold: true,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // ── Trust row ────────────────────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _trustItem(
                        Icons.lock_outline_rounded,
                        l10n.profSubSecureTrusted,
                        l10n.profSubHundredSafe,
                      ),
                      _trustItem(
                        Icons.verified_user_outlined,
                        'PayU',
                        l10n.coreSecurePaymentPoweredByPayU,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Sticky pay bar ───────────────────────────────────────────
          Container(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 14.h),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.profSubTotalAmount,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 11.sp,
                            color: AppColors.grey650,
                          ),
                        ),
                        Text(
                          '\u20B9$_price',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w700,
                            fontSize: 20.sp,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: GradientButton.filled(
                        text: l10n.proceedPayment,
                        onPressed: _isProcessing ? null : _onProceedPayment,
                        isLoading: _isProcessing,
                        height: 46.h,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (widget.showWalletLink) ...[
                  SizedBox(height: 10.h),
                  GestureDetector(
                    onTap: _isProcessing ? null : _onPayFromWallet,
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12.sp,
                          color: AppColors.grey650,
                        ),
                        children: [
                          TextSpan(text: l10n.orPayFromWallet),
                          TextSpan(
                            text: l10n.myWalletLink,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: _isProcessing
                                  ? AppColors.grey650
                                  : AppColors.primary,
                            ),
                          ),
                        ],
                      ),
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
