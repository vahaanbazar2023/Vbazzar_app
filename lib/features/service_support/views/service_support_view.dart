import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_assets.dart' show AppAssets;
import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/templates/app_layout.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_fonts.dart';
import '../controllers/service_support_controller.dart';

/// Landing page for Service Support module.
/// Simple promotional page — location is handled by the list view.
class ServiceSupportView extends StatelessWidget {
  const ServiceSupportView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: 'Service & Support',
      subtitle: '24/7 roadside assistance at your fingertips',
      showBack: true,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Column(
          children: [
            SizedBox(height: AppSpacing.xxl),

            // ── Headline ─────────────────────────────────────────
            Text(
              '24/7 Breakdown\nAssistance',
              textAlign: TextAlign.center,
              style: AppFonts.headlineMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: AppSpacing.md),

            // ── Subtitle ─────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text(
                'Instant Help. Anytime, Anywhere.\nQuick response and reliable roadside assistance at your fingertips.',
                textAlign: TextAlign.center,
                style: AppFonts.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ),

            SizedBox(height: AppSpacing.lg),

            // ── Illustration ─────────────────────────────────────
            Expanded(
              child: Image.asset(
                AppAssets.serviceSupport,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Container(
                  width: 200.w,
                  height: 200.w,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.build_circle_outlined,
                    size: 80.w,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),

            SizedBox(height: AppSpacing.xxl),

            // ── CTA Button ───────────────────────────────────────
            SizedBox(
              width: 240.w,
              height: 52.h,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Delete existing controller for fresh state
                  Get.delete<ServiceSupportController>();
                  Get.toNamed(AppRoutes.serviceSupportListView);
                },
                icon: Icon(
                  Icons.phone_outlined,
                  color: AppColors.white,
                  size: 20.w,
                ),
                label: Text(
                  'Contact Mechanic',
                  style: AppFonts.labelLarge.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(90),
                  ),
                  elevation: 2,
                  shadowColor: AppColors.primary.withValues(alpha: 0.4),
                ),
              ),
            ),

            SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}
