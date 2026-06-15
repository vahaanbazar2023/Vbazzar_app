import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/design_system/molecules/custom_snackbar.dart';
import '../../../core/design_system/organisms/app_bottom_nav_bar.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/storage/storage_keys.dart';
import '../../main_shell/controllers/main_shell_controller.dart';
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
  final String title;
  final String subtitle;

  /// Source identifier used when routing through WalletPaymentScreen
  /// (e.g. 'INSPECTION', 'SUBT006').
  final String source;

  /// Optional shop ID — used by SUBT006 wallet flow to unlock shop contact.
  final String? shopId;

  /// Optional mechanic ID — used by SUBT007 wallet flow to unlock mechanic contact.
  final String? mechanicId;

  /// Called immediately after payment success (direct pay path).
  final VoidCallback onPaymentSuccess;

  const SinglePlanPaymentScreen({
    super.key,
    required this.plan,
    required this.onPaymentSuccess,
    this.title = 'Subscribe',
    this.subtitle = '',
    this.source = 'INSPECTION',
    this.shopId,
    this.mechanicId,
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
        message: 'Please login to continue',
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
        message: 'Payment failed: $message',
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

  @override
  Widget build(BuildContext context) {
    final plan = widget.plan;

    return Scaffold(
      backgroundColor: AppColors.white,
      bottomNavigationBar: Obx(() {
        final shell = Get.isRegistered<MainShellController>()
            ? Get.find<MainShellController>()
            : null;
        return AppBottomNavBar(
          currentTab: shell != null
              ? BottomNavTab.values[shell.currentIndex.value]
              : BottomNavTab.categories,
          onTabSelected: (tab) {
            shell?.changePage(tab.index);
            Get.until((route) => route.isFirst);
          },
        );
      }),
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: AppSizes.elevationNone,
        surfaceTintColor: Colors.transparent,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: const Icon(
            Icons.arrow_back,
            color: AppColors.black,
            size: AppSizes.iconMd,
          ),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Scrollable content ────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.subtitle.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 12, 12, 0),
                      child: Text(
                        widget.subtitle,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w400,
                          fontSize: 14.sp,
                          color: AppColors.grey650,
                          height: 1.4,
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),

                  // ── Plan card (matches SubscriptionScreen _PlanCard) ──────
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0F0),
                      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                      border: Border.all(color: AppColors.primaryLight),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.spaceMd,
                      vertical: 14,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Icon circle
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primaryLight.withValues(
                              alpha: 0.12,
                            ),
                            border: Border.all(
                              color: AppColors.primaryLight,
                              width: 1.8,
                            ),
                          ),
                          child: const Icon(
                            Icons.build_rounded,
                            size: 18,
                            color: AppColors.primaryLight,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Name
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                plan.name,
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16.sp,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (plan.featDescription.isNotEmpty)
                                Text(
                                  plan.featDescription,
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12.sp,
                                    color: AppColors.grey650,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                        // Price
                        Row(
                          children: [
                            const Icon(
                              Icons.currency_rupee,
                              color: AppColors.grey800,
                              size: 18,
                            ),
                            Text(
                              plan.price.toStringAsFixed(
                                plan.price % 1 == 0 ? 0 : 2,
                              ),
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w700,
                                fontSize: 18.sp,
                                color: AppColors.grey800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Fixed bottom: Proceed Payment + My Wallet ─────────────────────
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.fromLTRB(
              AppSizes.spaceMd,
              0,
              AppSizes.spaceMd,
              AppSizes.space64,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Proceed Payment button
                GestureDetector(
                  onTap: _isProcessing ? null : _onProceedPayment,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: AppSizes.buttonHeightLg,
                    decoration: BoxDecoration(
                      gradient: _isProcessing
                          ? null
                          : const LinearGradient(
                              colors: [
                                AppColors.ctaGradientStart,
                                AppColors.ctaGradientEnd,
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                      color: _isProcessing ? AppColors.grey200 : null,
                      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                    ),
                    child: Center(
                      child: _isProcessing
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Proceed Payment',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w700,
                                fontSize: 14.sp,
                                color: AppColors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.spaceSm),
                // "or pay from My wallet" link
                GestureDetector(
                  onTap: _isProcessing ? null : _onPayFromWallet,
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w400,
                        fontSize: 11.sp,
                        color: AppColors.grey650,
                      ),
                      children: [
                        const TextSpan(text: 'or pay from '),
                        TextSpan(
                          text: '"My wallet"',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: _isProcessing
                                ? AppColors.grey650
                                : AppColors.primaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
