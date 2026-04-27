import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/design_system/templates/app_layout.dart';
import '../../../features/subscription/controllers/subscription_confirm_controller.dart';
import '../models/subscription_plan.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Wallet Payment Screen — uses AppLayout + SubscriptionConfirmController
// ─────────────────────────────────────────────────────────────────────────────
class WalletPaymentScreen extends StatelessWidget {
  final SubscriptionPlan plan;
  final String source;

  const WalletPaymentScreen({
    super.key,
    required this.plan,
    required this.source,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      SubscriptionConfirmController(plan: plan, source: source),
      tag: 'wallet_$source',
    );

    return AppLayout(
      title: 'My Wallet',
      subtitle: '',
      showBack: true,
      onBack: () => Get.back(),
      body: _WalletBody(controller: controller, plan: plan),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Body content
// ─────────────────────────────────────────────────────────────────────────────
class _WalletBody extends StatefulWidget {
  final SubscriptionConfirmController controller;
  final SubscriptionPlan plan;

  const _WalletBody({required this.controller, required this.plan});

  @override
  State<_WalletBody> createState() => _WalletBodyState();
}

class _TermsBullet extends StatelessWidget {
  final String text;
  final Color color;

  const _TermsBullet({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 6),
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w400,
              fontSize: 12.5,
              color: color,
              letterSpacing: 0.25,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}

class _WalletBodyState extends State<_WalletBody> {
  bool _payFromWallet = false;

  // Gradient colors from Figma (CTA gradient)
  static const _ctaStart = Color(0xFFBB2625);
  static const _ctaEnd = Color(0xFF67100B);

  // Card background
  static const _cardBg = Color(0xFFFFF2F2);

  // Balance bar background
  static const _balanceBg = Color(0xFFECEAE9);

  // Terms text color
  static const _termsColor = Color(0xFFA40301);

  String? get _tierAsset {
    switch (widget.plan.name.toLowerCase()) {
      case 'gold':
        return AppAssets.tierGold;
      case 'silver':
        return AppAssets.tierSilver;
      case 'bronze':
        return AppAssets.tierBronze;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (widget.controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primaryLight),
        );
      }

      final eligibility = widget.controller.eligibility.value;
      final walletBalance = eligibility?.walletBalance ?? 0;
      final hasWalletBalance = walletBalance > 0;
      final hasRedeemable = eligibility?.hasRedeemableAmount ?? false;

      return Column(
        children: [
          // ── Available Wallet Balance ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
            child: Container(
              decoration: BoxDecoration(
                color: _balanceBg,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Available Wallet Balance',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: Color(0xB8000000),
                    ),
                  ),
                  Text(
                    '₹${walletBalance.toStringAsFixed(walletBalance % 1 == 0 ? 0 : 2)}',
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Subscription Plan Card ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Container(
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(width: 1.5, color: _ctaStart),
                boxShadow: [
                  BoxShadow(
                    color: _ctaStart.withOpacity(0.34),
                    offset: const Offset(2, 4),
                    blurRadius: 11.4,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Tier icon
                  SizedBox(
                    width: 37,
                    height: 36,
                    child: _tierAsset != null
                        ? Image.asset(_tierAsset!, fit: BoxFit.contain)
                        : Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primaryLight.withOpacity(0.12),
                              border: Border.all(
                                color: AppColors.primaryLight,
                                width: 1.8,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                widget.plan.name[0].toUpperCase(),
                                style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                  color: AppColors.primaryLight,
                                ),
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(width: 12),

                  // Name + validity
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.plan.name,
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontWeight: FontWeight.w600,
                            fontSize: 23,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Validity : ${widget.plan.metricLabel}',
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                            fontSize: 19,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Price — show strikethrough original + final when wallet is used
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (_payFromWallet && widget.controller.isPriceDiscounted)
                        Text(
                          '₹${widget.plan.price.toStringAsFixed(widget.plan.price % 1 == 0 ? 0 : 2)}',
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: AppColors.grey400,
                            decoration: TextDecoration.lineThrough,
                            decorationColor: AppColors.grey400,
                          ),
                        ),
                      if (_payFromWallet && widget.controller.isPriceDiscounted)
                        const SizedBox(height: 2),
                      Text(
                        _payFromWallet && widget.controller.isPriceDiscounted
                            ? widget.controller.priceDisplay
                            : '₹${widget.plan.price.toStringAsFixed(widget.plan.price % 1 == 0 ? 0 : 2)}',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w700,
                          fontSize:
                              _payFromWallet &&
                                  widget.controller.isPriceDiscounted
                              ? 20
                              : 22,
                          color:
                              _payFromWallet &&
                                  widget.controller.isPriceDiscounted
                              ? _ctaStart
                              : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Pay from wallet balance checkbox ──
          Padding(
            padding: const EdgeInsets.fromLTRB(21, 24, 16, 0),
            child: GestureDetector(
              onTap: hasWalletBalance && hasRedeemable
                  ? () {
                      setState(() => _payFromWallet = !_payFromWallet);
                      widget.controller.toggleWallet(_payFromWallet);
                    }
                  : null,
              child: Row(
                children: [
                  // Gradient border checkbox
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        width: 1.1,
                        color: hasWalletBalance && hasRedeemable
                            ? _ctaStart
                            : AppColors.grey400,
                      ),
                    ),
                    child: _payFromWallet
                        ? Container(
                            margin: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              gradient: const LinearGradient(
                                colors: [_ctaStart, _ctaEnd],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Pay from wallet balance',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: hasWalletBalance && hasRedeemable
                          ? Colors.black
                          : AppColors.grey400,
                      letterSpacing: 0.32,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Proceed Payment Button ──
          Padding(
            padding: const EdgeInsets.fromLTRB(45, 24, 45, 0),
            child: GestureDetector(
              onTap: _payFromWallet ? widget.controller.onProceedPayment : null,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(188),
                  border: Border.all(
                    width: 1,
                    color: _payFromWallet
                        ? _ctaStart
                        : _ctaStart.withOpacity(0.3),
                  ),
                  color: Colors.transparent,
                ),
                child: Center(
                  child: ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: _payFromWallet
                          ? [_ctaStart, _ctaEnd]
                          : [
                              _ctaStart.withOpacity(0.3),
                              _ctaEnd.withOpacity(0.3),
                            ],
                    ).createShader(bounds),
                    child: Text(
                      'Proceed Payment ${widget.controller.priceDisplay}',
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: Colors.white,
                        letterSpacing: 0.36,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Terms & Conditions ──
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDF5F5),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(
                    color: _termsColor.withOpacity(0.15),
                    width: 1,
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 16,
                            decoration: BoxDecoration(
                              color: _termsColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Terms & Conditions',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: _termsColor,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Bullet points
                      const _TermsBullet(
                        text:
                            'Wallet balance is non-transferable and can only be used for subscription payments within the app.',
                        color: AppColors.grey650,
                      ),
                      const SizedBox(height: 10),
                      const _TermsBullet(
                        text:
                            'Once a payment is made using wallet balance, it cannot be reversed or refunded.',
                        color: AppColors.grey650,
                      ),
                      const SizedBox(height: 10),
                      const _TermsBullet(
                        text:
                            'Wallet balance does not carry any interest and is subject to the company\'s terms of service.',
                        color: AppColors.grey650,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}
