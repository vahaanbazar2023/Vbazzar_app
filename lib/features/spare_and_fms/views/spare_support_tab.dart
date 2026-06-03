import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../theme/app_fonts.dart';
import '../controllers/spare_and_fms_controller.dart';

/// Tab 2: Spare Support — Entry point for shop browsing by category (CE/CV)
/// and My Bookings access.
class SpareSupportTab extends GetView<SpareAndFmsController> {
  const SpareSupportTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Shop Categories ─────────────────────────────────
          Text(
            'Find Shops Near You',
            style: AppFonts.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            'Browse shops by vehicle category',
            style: AppFonts.bodySmall.copyWith(
              color: AppColors.grey500,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _CategoryCard(
                  title: 'CE',
                  subtitle: 'Construction Equipment',
                  icon: Icons.construction,
                  color: AppColors.primary,
                  onTap: () => _navigateToShopList('CE'),
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _CategoryCard(
                  title: 'CV',
                  subtitle: 'Commercial Vehicle',
                  icon: Icons.local_shipping,
                  color: AppColors.info,
                  onTap: () => _navigateToShopList('CV'),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xl),

          // ── My Bookings ────────────────────────────────────
          Text(
            'My Activity',
            style: AppFonts.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          _MyBookingsCard(
            onTap: () => Get.toNamed('/spare-fms/orders'),
          ),
        ],
      ),
    );
  }

  void _navigateToShopList(String categoryType) {
    controller.loadShopsByCategory(categoryType);
    Get.toNamed('/spare-fms/shops', arguments: {'category': categoryType});
  }
}

class _CategoryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: color.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32.r, color: color),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              title,
              style: AppFonts.titleLarge.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppFonts.labelSmall.copyWith(
                color: AppColors.grey500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MyBookingsCard extends StatelessWidget {
  final VoidCallback onTap;

  const _MyBookingsCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              ),
              child: Icon(Icons.receipt_long, size: 28.r, color: AppColors.primary),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Bookings',
                    style: AppFonts.titleSmall.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'View your spare parts orders',
                    style: AppFonts.bodySmall.copyWith(
                      color: AppColors.grey500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16.r,
              color: AppColors.grey400,
            ),
          ],
        ),
      ),
    );
  }
}