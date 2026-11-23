import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/molecules/gradient_button.dart';
import '../../../core/design_system/organisms/app_bottom_nav_bar.dart';
import '../../../core/design_system/templates/app_layout.dart';
import '../../../core/extensions/context_extensions.dart';
import '../controllers/subscription_confirm_controller.dart';
import '../models/subscription_plan.dart';
import 'subscription_ui.dart';

/// Confirm (or renew) a plan before paying. Uses the app's [AppLayout] (Vahaan
/// Bazar header + bottom navigation) with cards styled like My Plans.
///
/// Arguments: `plan`, `source` (type code); for a renewal also `renewal: true`,
/// `days_left` and `current_end_date` (the running plan's end, API format).
class SubscriptionConfirmScreen extends StatelessWidget {
  const SubscriptionConfirmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final plan = args['plan'] as SubscriptionPlan?;
    final source = args['source'] as String? ?? '';
    final renewal = args['renewal'] == true;
    final daysLeft = args['days_left'] as int?;
    final currentEnd = args['current_end_date'] as String?;
    final l = context.l10n;

    return AppLayout(
      title: renewal ? l.profSubRenewPlan : l.profSubConfirmSubscription,
      showBack: true,
      body: plan == null
          ? Center(
              child: Text(
                l.profSubNoPlanSelectedDot,
                style: _text(14, color: AppColors.textSecondary),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
                    children: [
                      _PlanCard(plan: plan, source: source),
                      if (renewal && currentEnd != null) ...[
                        SizedBox(height: 12.h),
                        _RenewalNote(endDate: currentEnd, daysLeft: daysLeft),
                      ],
                      SizedBox(height: 20.h),
                      _SectionTitle(l.profSubWhatsIncluded),
                      _Card(
                        child: _WhatYouGet(plan: plan, source: source),
                      ),
                      SizedBox(height: 20.h),
                      _SectionTitle(l.profSubOrderSummary),
                      _Card(
                        child: _OrderSummary(plan: plan, renewal: renewal),
                      ),
                    ],
                  ),
                ),
                const _PayBar(),
              ],
            ),
    );
  }
}

TextStyle _text(
  double size, {
  FontWeight weight = FontWeight.w400,
  Color color = AppColors.textPrimary,
  double? height,
}) => TextStyle(
  fontFamily: 'Montserrat',
  fontSize: size.sp,
  fontWeight: weight,
  color: color,
  height: height,
);

String _price(double v) => '₹${v.toStringAsFixed(v % 1 == 0 ? 0 : 2)}';

// ─────────────────────────────────────────────────────────────────────────────
// Building blocks
// ─────────────────────────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.grey300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 2.w, bottom: 10.h),
      child: Text(text, style: _text(15, weight: FontWeight.w600)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Plan card — icon, name, validity pill, description
// ─────────────────────────────────────────────────────────────────────────────

class _PlanCard extends StatelessWidget {
  final SubscriptionPlan plan;
  final String source;
  const _PlanCard({required this.plan, required this.source});

  @override
  Widget build(BuildContext context) {
    final desc = plan.featDescription.trim();
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56.r,
                height: 56.r,
                padding: EdgeInsets.all(11.r),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F0),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Image.asset(
                  subscriptionIconAsset(
                    source.isNotEmpty ? source : plan.typeCode,
                  ),
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.workspace_premium_rounded,
                    color: AppColors.primary,
                    size: 28.r,
                  ),
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.profSubPlanName(plan.name),
                      style: _text(17, weight: FontWeight.w700),
                    ),
                    SizedBox(height: 6.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF0F0),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            plan.planMetric == 'days'
                                ? Icons.calendar_month_rounded
                                : Icons.account_balance_wallet_outlined,
                            size: 13.r,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 5.w),
                          Flexible(
                            child: Text(
                              plan.metricLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: _text(
                                12,
                                weight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (desc.isNotEmpty) ...[
            SizedBox(height: 14.h),
            const Divider(height: 1, color: AppColors.grey200),
            SizedBox(height: 12.h),
            Text(
              desc,
              style: _text(13, color: AppColors.textSecondary, height: 1.5),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Renewal note — when the new period starts, days kept
// ─────────────────────────────────────────────────────────────────────────────

class _RenewalNote extends StatelessWidget {
  final String endDate;
  final int? daysLeft;
  const _RenewalNote({required this.endDate, this.daysLeft});

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF2E7D32);
    final l = context.l10n;
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFC8E6C9)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.event_repeat_rounded, size: 20.r, color: green),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.profSubRenewStartsAfter(formatPlanDate(context, endDate)),
                  style: _text(
                    13,
                    weight: FontWeight.w600,
                    color: green,
                    height: 1.4,
                  ),
                ),
                if ((daysLeft ?? 0) > 0) ...[
                  SizedBox(height: 4.h),
                  Text(
                    l.profSubDaysLeftKept(daysLeft!),
                    style: _text(12, color: green, height: 1.4),
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
// What's included
// ─────────────────────────────────────────────────────────────────────────────

class _WhatYouGet extends StatelessWidget {
  final SubscriptionPlan plan;
  final String source;
  const _WhatYouGet({required this.plan, required this.source});

  List<String> _features(BuildContext context) {
    final l = context.l10n;
    switch (source) {
      case 'SUBT001':
        return [
          l.profSubFeatAuction1,
          l.profSubFeatAuction2,
          l.profSubFeatAuction3,
          l.profSubFeatUninterrupted(plan.metricLabel),
        ];
      case 'SUBT002':
        return [
          l.profSubFeatBidUpTo(plan.metricLabel),
          l.profSubFeatBid2,
          l.profSubFeatBid3,
          l.profSubFeatBid4,
        ];
      case 'SUBT003':
        return [
          l.profSubFeatOwner1,
          l.profSubFeatOwner2,
          l.profSubFeatOwner3,
          l.profSubFeatOwner4,
        ];
      case 'SUBT004':
        return [
          l.profSubFeatVeh1,
          l.profSubFeatVeh2,
          l.profSubFeatVeh3,
          l.profSubFeatVeh4,
          l.profSubFeatVeh5,
          l.profSubFeatVeh6,
        ];
      case 'SUBT005':
        return [
          l.profSubFeatInsp1,
          l.profSubFeatInsp2,
          l.profSubFeatInsp3,
          l.profSubFeatInsp4,
          l.profSubFeatInsp5,
          l.profSubFeatInsp6,
        ];
      default:
        return [
          l.profSubFeatDefault1,
          l.profSubFeatValidity(plan.metricLabel),
          l.profSubFeatDefault3,
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final features = _features(context);
    return Column(
      children: [
        for (var i = 0; i < features.length; i++)
          Padding(
            padding: EdgeInsets.only(
              bottom: i == features.length - 1 ? 0 : 12.h,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 22.r,
                  height: 22.r,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFFFF0F0),
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    size: 14.r,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 2.h),
                    child: Text(features[i], style: _text(13, height: 1.4)),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Order summary
// ─────────────────────────────────────────────────────────────────────────────

class _OrderSummary extends StatelessWidget {
  final SubscriptionPlan plan;

  /// Renewing the plan the user already has: the plan code means nothing to
  /// them, so it is left out.
  final bool renewal;
  const _OrderSummary({required this.plan, this.renewal = false});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Column(
      children: [
        _SummaryRow(
          label: l.profSubPlanLabel,
          value: l.profSubPlanName(plan.name),
        ),
        SizedBox(height: 12.h),
        _SummaryRow(label: l.profSubValidityLabel, value: plan.metricLabel),
        if (!renewal) ...[
          SizedBox(height: 12.h),
          _SummaryRow(label: l.profSubPlanCode, value: plan.planCode),
        ],
        Padding(
          padding: EdgeInsets.symmetric(vertical: 14.h),
          child: const Divider(height: 1, color: AppColors.grey200),
        ),
        _SummaryRow(
          label: l.profSubTotalAmount,
          value: _price(plan.price),
          highlight: true,
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;
  const _SummaryRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: highlight
                ? _text(14, weight: FontWeight.w600)
                : _text(13, color: AppColors.textSecondary),
          ),
        ),
        SizedBox(width: 8.w),
        Flexible(
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: highlight
                  ? _text(18, weight: FontWeight.w700, color: AppColors.primary)
                  : _text(13, weight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pay bar — pinned at the bottom
// ─────────────────────────────────────────────────────────────────────────────

class _PayBar extends StatelessWidget {
  const _PayBar();

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SubscriptionConfirmController>();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: AppColors.grey200)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      // Bottom: clear the bottom nav's raised wave.
      padding: EdgeInsets.fromLTRB(
        16.w,
        12.h,
        16.w,
        8.h + kBottomNavWaveHeight,
      ),
      child: Obx(() {
        final inProgress = ctrl.isPaymentInProgress.value;
        final price = ctrl.priceDisplay.value;
        // The app's standard rounded gradient CTA.
        // Compact and centred; 44 keeps a comfortable tap height.
        return Center(
          child: GradientButton.filled(
            text: context.l10n.profSubPay(price),
            onPressed: ctrl.onProceedPayment,
            isLoading: inProgress,
            width: 240.w,
            height: 44.h,
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
          ),
        );
      }),
    );
  }
}
