import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/loaders/app_shimmer.dart';
import '../../../core/design_system/templates/app_layout.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_fonts.dart';
import '../controllers/approved_vehicle_controller.dart';
import '../domain/entities/approved_vehicle_category_entity.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../app_tour/screen_tour.dart';

class CategorySelectionScreen extends StatelessWidget {
  const CategorySelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ApprovedVehicleController>();

    return TourScope(
      tourId: 'approved_category',
      spots: (context) => [
        TourSpot(
          'appr_category_card',
          context.l10n.tourApprCategoryCardTitle,
          context.l10n.tourApprCategoryCardBody,
        ),
        TourSpot(
          'appr_category_count',
          context.l10n.tourApprCategoryCountTitle,
          context.l10n.tourApprCategoryCountBody,
          padding: 4,
        ),
      ],
      child: AppLayout(
        title: context.l10n.approvedVehicles,
        subtitle: context.l10n.apprSelectCategoryToBrowse,
        body: Obx(() {
          if (ctrl.isLoadingCategories.value && ctrl.categories.isEmpty) {
            return _buildShimmerGrid();
          }
          if (ctrl.categoriesError.value.isNotEmpty &&
              ctrl.categories.isEmpty) {
            return _buildErrorState(context, ctrl);
          }
          if (ctrl.categories.isEmpty) {
            return _buildEmptyState(context, ctrl);
          }
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => ctrl.fetchCategories(isRefresh: true),
            child: GridView.builder(
              padding: EdgeInsets.all(AppSpacing.lg),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16.h,
                crossAxisSpacing: 16.w,
                childAspectRatio: 1,
              ),
              itemCount: ctrl.categories.length,
              itemBuilder: (context, index) {
                final category = ctrl.categories[index];
                return TourAnchor(
                  id: 'appr_category_card',
                  child: _CategoryCard(
                    category: category,
                    onTap: () => Get.toNamed(
                      AppRoutes.approvedVehicleListings,
                      arguments: {'category': category},
                    ),
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }

  Widget _buildShimmerGrid() {
    return GridView.builder(
      padding: EdgeInsets.all(AppSpacing.lg),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16.h,
        crossAxisSpacing: 16.w,
        childAspectRatio: 1,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => const _CategoryCardSkeleton(),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    ApprovedVehicleController ctrl,
  ) {
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
                  context.l10n.retry,
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

  Widget _buildEmptyState(
    BuildContext context,
    ApprovedVehicleController ctrl,
  ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category_outlined, size: 48.w, color: AppColors.grey400),
            SizedBox(height: 12.h),
            Text(
              context.l10n.noCategoriesAvailable,
              style: AppFonts.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              context.l10n.pullDownToRefresh,
              style: AppFonts.bodySmall.copyWith(color: AppColors.textDisabled),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mirrors [_CategoryCard]: centred icon, category name and the
/// "• N vehicles" count line.
class _CategoryCardSkeleton extends StatelessWidget {
  const _CategoryCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.blackTransparent,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: AppShimmer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SkeletonBox(width: 64.w, height: 48.h, radius: 8),
            SizedBox(height: 12.h),
            SkeletonBox(width: 90.w, height: 14.h),
            SizedBox(height: 6.h),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SkeletonBox.circle(size: 6.w),
                SizedBox(width: 5.w),
                SkeletonBox(width: 60.w, height: 10.h, radius: 4),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final ApprovedVehicleCategoryEntity category;
  final VoidCallback onTap;

  const _CategoryCard({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.blackTransparent,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon — direct, no background. Boxed to the skeleton's size so a
            // large source image can't push the name and count out of the
            // fixed-size card; Flexible lets it shrink on small screens.
            Flexible(
              child: SizedBox(
                width: 64.w,
                height: 48.h,
                child: category.iconName.isNotEmpty
                    ? Image.network(
                        category.iconName,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.local_shipping_outlined,
                          size: 36.w,
                          color: AppColors.primary,
                        ),
                      )
                    : Icon(
                        Icons.local_shipping_outlined,
                        size: 36.w,
                        color: AppColors.primary,
                      ),
              ),
            ),
            SizedBox(height: 12.h),
            // Category name
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Text(
                category.categoryName,
                style: AppFonts.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: 6.h),
            // Vehicle count — dot + number
            TourAnchor(
              id: 'appr_category_count',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 6.w,
                    height: 6.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: category.approvedVehAvailableCount > 0
                          ? AppColors.primary
                          : AppColors.grey400,
                    ),
                  ),
                  SizedBox(width: 5.w),
                  Flexible(
                    child: Text(
                      category.approvedVehAvailableCount > 0
                          ? context.l10n.apprVehiclesCount(
                              category.approvedVehAvailableCount,
                            )
                          : context.l10n.apprUnavailable,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.bodySmall.copyWith(
                        fontSize: 10.sp,
                        color: category.approvedVehAvailableCount > 0
                            ? AppColors.primary
                            : AppColors.grey500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
