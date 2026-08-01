import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/loaders/loading_widget.dart';
import '../../../core/design_system/templates/app_layout.dart';
import '../../../core/design_system/tokens/app_radius.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_fonts.dart';
import '../controllers/approved_vehicle_controller.dart';
import '../domain/entities/approved_vehicle_category_entity.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Vendor Buy/Sell Landing — category list with SELL + BUY buttons per card
// ─────────────────────────────────────────────────────────────────────────────

class BuySellLandingScreen extends StatefulWidget {
  const BuySellLandingScreen({super.key});

  @override
  State<BuySellLandingScreen> createState() => _BuySellLandingScreenState();
}

class _BuySellLandingScreenState extends State<BuySellLandingScreen> {
  final ctrl = Get.find<ApprovedVehicleController>();

  @override
  void initState() {
    super.initState();
    // Force-refresh categories on screen open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ctrl.fetchCategories(isRefresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: 'Approved Vehicles',
      subtitle: 'Buy & sell verified commercial vehicles',
      body: Obx(() {
        // ── Loading state ──────────────────────────────────────
        if (ctrl.isLoadingCategories.value && ctrl.categories.isEmpty) {
          return _buildShimmerList();
        }
        // ── Error state ────────────────────────────────────────
        if (ctrl.categoriesError.value.isNotEmpty && ctrl.categories.isEmpty) {
          return _buildErrorState();
        }
        // ── Empty state ────────────────────────────────────────
        if (ctrl.categories.isEmpty) {
          return _buildEmptyState();
        }
        // ── Loaded ─────────────────────────────────────────────
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => ctrl.fetchCategories(isRefresh: true),
          child: ListView.builder(
            padding: EdgeInsets.all(AppSpacing.md),
            itemCount: ctrl.categories.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.md),
                child: _VendorCategoryCard(
                  category: ctrl.categories[index],
                  onSellTap: () {
                    final cat = ctrl.categories[index];
                    Get.toNamed(
                      AppRoutes.approvedVehicleSellForm,
                      arguments: {
                        'categoryName': cat.categoryName,
                        'categoryCode': cat.categoryCode,
                      },
                    );
                  },
                  onBuyTap: () {
                    Get.toNamed(
                      AppRoutes.approvedVehicleListings,
                      arguments: {'category': ctrl.categories[index]},
                    );
                  },
                ),
              );
            },
          ),
        );
      }),
    );
  }

  // ── Shimmer list ────────────────────────────────────────────────────────
  Widget _buildShimmerList() {
    return ListView.builder(
      padding: EdgeInsets.all(AppSpacing.md),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.md),
          child: _ShimmerCategoryCard(),
        );
      },
    );
  }

  // ── Error state ─────────────────────────────────────────────────────────
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48.w,
              color: AppColors.error,
            ),
            SizedBox(height: 12.h),
            Text(
              ctrl.categoriesError.value,
              style: AppFonts.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            GestureDetector(
              onTap: () => ctrl.fetchCategories(isRefresh: true),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'Retry',
                  style: AppFonts.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Empty state ─────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 56.w,
              color: AppColors.grey400,
            ),
            SizedBox(height: 12.h),
            Text(
              'No categories found',
              style: AppFonts.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Pull down to refresh',
              style: AppFonts.bodySmall.copyWith(color: AppColors.textDisabled),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Vendor Category Card — icon + name + count + SELL & BUY buttons
// ─────────────────────────────────────────────────────────────────────────────

class _VendorCategoryCard extends StatelessWidget {
  final ApprovedVehicleCategoryEntity category;
  final VoidCallback onSellTap;
  final VoidCallback onBuyTap;

  const _VendorCategoryCard({
    required this.category,
    required this.onSellTap,
    required this.onBuyTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 12.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.borderRadiusMd,
        border: Border.all(color: AppColors.grey200),
        boxShadow: [
          BoxShadow(
            color: const Color(0x08000000),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Vehicle image ──────────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: category.iconName.isNotEmpty
                ? Image.network(
                    category.iconName,
                    width: 90.w,
                    height: 80.h,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Container(
                      width: 90.w,
                      height: 80.h,
                      color: AppColors.grey100,
                      child: Icon(
                        Icons.local_shipping_outlined,
                        size: 36.w,
                        color: AppColors.grey400,
                      ),
                    ),
                  )
                : Container(
                    width: 90.w,
                    height: 80.h,
                    color: AppColors.grey100,
                    child: Icon(
                      Icons.local_shipping_outlined,
                      size: 36.w,
                      color: AppColors.grey400,
                    ),
                  ),
          ),
          SizedBox(width: 14.w),

          // ── Name + count + buttons ─────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Category name
                Text(
                  category.categoryName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
                SizedBox(height: 4.h),
                // Available count
                Text(
                  'Available : ${category.approvedVehAvailableCount}',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 10.h),
                // Buy + Sell buttons side by side
                Row(
                  children: [
                    // BUY — filled gradient
                    Expanded(
                      child: GestureDetector(
                        onTap: onBuyTap,
                        child: Container(
                          height: 34.h,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.ctaGradientStart,
                                AppColors.ctaGradientEnd,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20.r),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.ctaGradientStart.withValues(
                                  alpha: 0.3,
                                ),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'Buy',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    // SELL — outlined
                    Expanded(
                      child: GestureDetector(
                        onTap: onSellTap,
                        child: Container(
                          height: 34.h,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            border: Border.all(
                              color: AppColors.ctaGradientStart,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Center(
                            child: Text(
                              'Sell',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ctaGradientStart,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
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
// Shimmer Skeleton for category card
// ─────────────────────────────────────────────────────────────────────────────

class _ShimmerCategoryCard extends StatelessWidget {
  const _ShimmerCategoryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.borderRadiusMd,
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        children: [
          SkeletonBox(width: 56.w, height: 56.w, radius: 14),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 120.w, height: 16.h, radius: 6),
                SizedBox(height: 6.h),
                SkeletonBox(width: 160.w, height: 12.h, radius: 6),
              ],
            ),
          ),
          Column(
            children: [
              SkeletonBox(width: 80.w, height: 34.h, radius: 8),
              SizedBox(height: 6.h),
              SkeletonBox(width: 80.w, height: 34.h, radius: 8),
            ],
          ),
        ],
      ),
    );
  }
}
