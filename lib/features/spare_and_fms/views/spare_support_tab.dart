import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_fonts.dart';
import '../controllers/spare_and_fms_controller.dart';

/// Tab: Spare Support — Entry point for shop browsing by category (CE/CV)
/// Tapping a category navigates to [ShopListView] for that category.
class SpareSupportTab extends GetView<SpareAndFmsController> {
  const SpareSupportTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────
          Text(
            'Spare',
            style: AppFonts.titleLarge.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Find trusted spare part shops near your location',
            style: AppFonts.bodySmall.copyWith(color: AppColors.grey500),
          ),
          SizedBox(height: 24.h),

          // ── Category Cards ────────────────────────────────────
          _CategoryCard(
            title: 'CE',
            fullTitle: 'Construction Equipment',
            description:
                'Browse shops selling parts for JCBs, excavators, loaders & more',
            icon: Icons.construction_rounded,
            gradientColors: const [AppColors.primary, AppColors.primaryDark],
            badgeColor: AppColors.lightOrange,
            badgeTextColor: AppColors.primaryDark,
            onTap: () => _navigateToShopList('CE'),
          ),
          SizedBox(height: 14.h),
          _CategoryCard(
            title: 'CV',
            fullTitle: 'Commercial Vehicle',
            description:
                'Browse shops selling parts for trucks, buses, tempos & trailers',
            icon: Icons.local_shipping_rounded,
            gradientColors: const [
              AppColors.secondary,
              AppColors.secondaryDark,
            ],
            badgeColor: AppColors.warningBackground,
            badgeTextColor: AppColors.secondaryDark,
            onTap: () => _navigateToShopList('CV'),
          ),

          SizedBox(height: 8.h),
        ],
      ),
    );
  }

  void _navigateToShopList(String categoryType) {
    controller.currentShopCategory.value = categoryType;
    Get.toNamed(AppRoutes.shopList, arguments: {'category': categoryType});
  }
}

// ─── Category Card ───────────────────────────────────────────────

class _CategoryCard extends StatelessWidget {
  final String title;
  final String fullTitle;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;
  final Color badgeColor;
  final Color badgeTextColor;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.title,
    required this.fullTitle,
    required this.description,
    required this.icon,
    required this.gradientColors,
    required this.badgeColor,
    required this.badgeTextColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              gradientColors[0].withValues(alpha: 0.12),
              gradientColors[1].withValues(alpha: 0.06),
            ],
          ),
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(
            color: gradientColors[0].withValues(alpha: 0.25),
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            // Left: Icon container
            Container(
              width: 64.r,
              height: 64.r,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradientColors,
                ),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                boxShadow: [
                  BoxShadow(
                    color: gradientColors[0].withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, size: 32.r, color: AppColors.white),
            ),
            SizedBox(width: 16.w),

            // Center: Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge + Title row
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: badgeColor,
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusFull,
                          ),
                        ),
                        child: Text(
                          title,
                          style: AppFonts.labelSmall.copyWith(
                            color: badgeTextColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 10.sp,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          fullTitle,
                          style: AppFonts.titleSmall.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    description,
                    style: AppFonts.bodySmall.copyWith(
                      color: AppColors.grey500,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),

            // Right: Arrow
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: gradientColors[0].withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16.r,
                color: gradientColors[1],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
