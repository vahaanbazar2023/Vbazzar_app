import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../controllers/subscription_controller.dart';
import '../models/user_subscription.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Tab 1 — My Plans
// ─────────────────────────────────────────────────────────────────────────────

class MyPlansTab extends StatelessWidget {
  final MySubscriptionController ctrl;
  final VoidCallback onGoExplore;
  const MyPlansTab({super.key, required this.ctrl, required this.onGoExplore});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (ctrl.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        );
      }
      if (ctrl.errorMessage.value != null) {
        return _ErrorWidget(
          message: ctrl.errorMessage.value!,
          onRetry: ctrl.retry,
        );
      }
      if (ctrl.mySubscriptions.isEmpty) {
        return EmptyPlans(onExplore: onGoExplore);
      }
      return RefreshIndicator(
        color: AppColors.primary,
        onRefresh: ctrl.fetchMySubscriptions,
        child: ListView.builder(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
          itemCount: ctrl.mySubscriptions.length + 1,
          itemBuilder: (_, i) {
            if (i == ctrl.mySubscriptions.length) {
              return ExploreBanner(onTap: onGoExplore);
            }
            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: MyPlanCard(sub: ctrl.mySubscriptions[i]),
            );
          },
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// My Plan Card
// ─────────────────────────────────────────────────────────────────────────────

class MyPlanCard extends StatelessWidget {
  final UserSubscription sub;
  const MyPlanCard({super.key, required this.sub});

  IconData get _icon {
    switch (sub.typeCode) {
      case 'SUBT001':
        return Icons.gavel_rounded;
      case 'SUBT002':
        return Icons.bar_chart_rounded;
      case 'SUBT003':
        return Icons.handshake_rounded;
      case 'SUBT004':
        return Icons.shield_rounded;
      case 'SUBT005':
        return Icons.search_rounded;
      case 'SUBT006':
        return Icons.build_rounded;
      default:
        return Icons.workspace_premium_rounded;
    }
  }

  String _fmtDate(String? raw) {
    if (raw == null || raw.isEmpty) return '—';
    final dt = UserSubscription.parseApiDate(raw);
    if (dt == null) return raw;
    const m = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${dt.day.toString().padLeft(2, '0')} ${m[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final active = sub.isActive;
    return Container(
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
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top: icon + name/desc + badge + chevron ─────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rounded square icon
              Container(
                width: 52.r,
                height: 52.r,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F0),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(_icon, color: AppColors.primary, size: 26.r),
              ),
              SizedBox(width: 14.w),
              // Name + description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sub.planName,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w700,
                        fontSize: 15.sp,
                        color: AppColors.black,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      sub.subscriptionType,
                      maxLines: 2,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 12.sp,
                        color: AppColors.grey500,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              // Badge + chevron stacked vertically
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 5.h,
                    ),
                    decoration: BoxDecoration(
                      color: active
                          ? const Color(0xFFE8F5E9)
                          : const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      active ? 'Active' : 'Inactive',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: active
                            ? const Color(0xFF2E7D32)
                            : AppColors.grey500,
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                ],
              ),
            ],
          ),
          SizedBox(height: 14.h),
          const Divider(height: 1, color:AppColors.grey300),
          SizedBox(height: 12.h),
          // ── Valid Until row ─────────────────────────────────
          Row(
            children: [
              Container(
                width: 36.r,
                height: 36.r,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFFF0F0),
                ),
                child: Icon(
                  Icons.calendar_month_rounded,
                  size: 18.r,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Valid Until',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 11.sp,
                      color: AppColors.grey500,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    _fmtDate(sub.endDate),
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w700,
                      fontSize: 13.sp,
                      color: AppColors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// "Need more benefits?" explore banner
// ─────────────────────────────────────────────────────────────────────────────

class ExploreBanner extends StatelessWidget {
  final VoidCallback onTap;
  const ExploreBanner({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(top: 4.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: const Color(0xFFEEEEEE)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40.r,
              height: 40.r,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFFF0F0),
              ),
              child: Icon(
                Icons.add_circle_outline_rounded,
                color: AppColors.primary,
                size: 20.r,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Need more benefits?',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w700,
                      fontSize: 13.sp,
                      color: AppColors.black,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Explore our other plans and choose the one that fits your needs.',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 11.sp,
                      color: AppColors.grey500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20.r,
              color: AppColors.grey400,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────────────────────────────────────

class EmptyPlans extends StatelessWidget {
  final VoidCallback onExplore;
  const EmptyPlans({super.key, required this.onExplore});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.workspace_premium_outlined,
              size: 56.r,
              color: AppColors.grey300,
            ),
            SizedBox(height: 16.h),
            Text(
              'No Active Plans',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w700,
                fontSize: 16.sp,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              "You don't have any active subscriptions yet.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 13.sp,
                color: AppColors.grey500,
              ),
            ),
            SizedBox(height: 20.h),
            GestureDetector(
              onTap: onExplore,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.ctaGradientStart,
                      AppColors.ctaGradientEnd,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: Text(
                  'Explore Plans',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w700,
                    fontSize: 13.sp,
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

// ─────────────────────────────────────────────────────────────────────────────
// Shared error widget (used across tabs)
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorWidget({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: 48.r, color: AppColors.grey300),
            SizedBox(height: 16.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 13.sp,
                color: AppColors.grey500,
                height: 1.5,
              ),
            ),
            SizedBox(height: 16.h),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'Retry',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w700,
                    fontSize: 13.sp,
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
