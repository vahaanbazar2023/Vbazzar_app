import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/tokens/app_radius.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../controllers/subscription_controller.dart';
import '../models/user_subscription.dart';

class MySubscriptionScreen extends StatelessWidget {
  const MySubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<MySubscriptionController>()
        ? Get.find<MySubscriptionController>()
        : Get.put(MySubscriptionController());

    final topPad = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        // Body color as scaffold bg — prevents red bleed behind bottom nav
        backgroundColor: AppColors.grey100,
        body: Column(
          children: [
            // ── Header — exact AppLayout spec ─────────────────────────────
            Container(
              width: double.infinity,
              height: 120.h + topPad,
              padding: EdgeInsets.only(
                left: AppSpacing.xl,
                right: AppSpacing.xl,
                bottom: AppSpacing.lg,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.authHeaderGradientStart,
                    AppColors.authHeaderGradientEnd,
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox.shrink(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'My Subscriptions',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Padding(
                        padding: EdgeInsets.only(left: AppSpacing.lg),
                        child: Text(
                          'Your active plans',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: AppSpacing.md),
                    ],
                  ),
                ],
              ),
            ),

            // ── White rounded body overlapping header ─────────────────────
            Expanded(
              child: Transform.translate(
                offset: Offset(0, -AppRadius.xxl),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.grey100,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(AppRadius.xxl),
                      topRight: Radius.circular(AppRadius.xxl),
                    ),
                  ),
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    }
                    if (controller.errorMessage.value != null) {
                      return _ErrorState(
                        message: controller.errorMessage.value!,
                        onRetry: controller.retry,
                      );
                    }
                    if (controller.mySubscriptions.isEmpty) {
                      return const _EmptyState();
                    }
                    return RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: controller.fetchMySubscriptions,
                      child: ListView.builder(
                        padding: EdgeInsets.fromLTRB(16, 20, 16, 32),
                        itemCount: controller.mySubscriptions.length + 1,
                        itemBuilder: (_, i) {
                          if (i == 0) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: 16.h),
                              child: _PlanCountStrip(
                                count: controller.totalCount.value,
                              ),
                            );
                          }
                          return Padding(
                            padding: EdgeInsets.only(bottom: 12.h),
                            child: _SubscriptionCard(
                              subscription: controller.mySubscriptions[i - 1],
                            ),
                          );
                        },
                      ),
                    );
                  }),
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
// Plan count strip — full width, no dot, no extra icon
// ─────────────────────────────────────────────────────────────────────────────

class _PlanCountStrip extends StatelessWidget {
  final int count;
  const _PlanCountStrip({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$count Active Plan${count == 1 ? '' : 's'}',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w700,
              fontSize: 15.sp,
              color: AppColors.black,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'Your current subscriptions',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 11.sp,
              color: AppColors.grey500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Subscription card — light rose gradient, same for all plans
// ─────────────────────────────────────────────────────────────────────────────

class _SubscriptionCard extends StatelessWidget {
  final UserSubscription subscription;
  const _SubscriptionCard({required this.subscription});

  String get _planInitial {
    final n = subscription.planName.trim();
    return n.isNotEmpty ? n[0].toUpperCase() : 'S';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF5F5), Color(0xFFFFE8E8)],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFFFCECE)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.07),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row ─────────────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Plan initial
                Container(
                  width: 44.r,
                  height: 44.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
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
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _planInitial,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w800,
                        fontSize: 18.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subscription.planName,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w700,
                          fontSize: 15.sp,
                          color: AppColors.black,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        subscription.subscriptionType,
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 11.sp,
                          color: AppColors.grey600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                // Status badge — red/grey tones only
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: subscription.isActive
                        ? AppColors.primary.withValues(alpha: 0.08)
                        : AppColors.grey100,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: subscription.isActive
                          ? AppColors.primary.withValues(alpha: 0.3)
                          : AppColors.grey300,
                    ),
                  ),
                  child: Text(
                    subscription.status.toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w700,
                      fontSize: 9.sp,
                      letterSpacing: 0.6,
                      color: subscription.isActive
                          ? AppColors.primary
                          : AppColors.grey500,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),
            const Divider(height: 1, color: Color(0xFFFFCECE)),
            SizedBox(height: 10.h),

            // ── Date row ───────────────────────────────────────────────────
            if (subscription.startDate != null || subscription.endDate != null)
              Row(
                children: [
                  if (subscription.startDate != null)
                    Expanded(
                      child: _DateCell(
                        label: 'Start',
                        value: _fmtDate(subscription.startDate!),
                        icon: Icons.calendar_today_outlined,
                      ),
                    ),
                  if (subscription.startDate != null &&
                      subscription.endDate != null)
                    SizedBox(width: 8.w),
                  if (subscription.endDate != null)
                    Expanded(
                      child: _DateCell(
                        label: 'Expires',
                        value: _fmtDate(subscription.endDate!),
                        icon: Icons.event_outlined,
                        isExpiry: true,
                      ),
                    ),
                ],
              )
            else
              Row(
                children: [
                  Icon(
                    Icons.all_inclusive,
                    color: AppColors.grey400,
                    size: 14.r,
                  ),
                  SizedBox(width: 5.w),
                  Text(
                    'No expiry date',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 12.sp,
                      color: AppColors.grey500,
                    ),
                  ),
                ],
              ),

            SizedBox(height: 8.h),

            // ── Sub code ───────────────────────────────────────────────────
            Row(
              children: [
                Icon(Icons.tag_rounded, color: AppColors.grey400, size: 12.r),
                SizedBox(width: 3.w),
                Text(
                  subscription.userSubCode,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 10.sp,
                    color: AppColors.grey500,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _fmtDate(String raw) {
    try {
      final dt = DateTime.parse(raw);
      return '${dt.day.toString().padLeft(2, '0')}/'
          '${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return raw;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Date cell
// ─────────────────────────────────────────────────────────────────────────────

class _DateCell extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isExpiry;

  const _DateCell({
    required this.label,
    required this.value,
    required this.icon,
    this.isExpiry = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFFFCECE)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.grey500, size: 12.r),
          SizedBox(width: 5.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 9.sp,
                    color: AppColors.grey400,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                    fontSize: 11.sp,
                    color: isExpiry ? AppColors.primary : AppColors.grey800,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80.r,
              height: 80.r,
              decoration: BoxDecoration(
                color: AppColors.grey50,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.grey200),
              ),
              child: Icon(
                Icons.card_membership_outlined,
                color: AppColors.grey400,
                size: 36.r,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'No Active Subscriptions',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w700,
                fontSize: 16.sp,
                color: AppColors.black,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'You have not subscribed to any plan yet.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 13.sp,
                color: AppColors.grey500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Error state
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: AppColors.primary, size: 48.r),
            SizedBox(height: 12.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 13.sp,
                color: AppColors.grey500,
              ),
            ),
            SizedBox(height: 16.h),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.ctaGradientStart,
                      AppColors.ctaGradientEnd,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: Text(
                  'Retry',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w700,
                    fontSize: 14.sp,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
