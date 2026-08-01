import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/templates/app_layout.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_fonts.dart';
import '../controllers/approved_vehicle_controller.dart';
import '../domain/entities/approved_vehicle_category_entity.dart';

class CategorySelectionScreen extends StatelessWidget {
  const CategorySelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ApprovedVehicleController>();

    return AppLayout(
      title: 'Approved Vehicles',
      subtitle: 'Select a category to browse',
      body: Obx(() {
        if (ctrl.isLoadingCategories.value && ctrl.categories.isEmpty) {
          return _buildShimmerGrid();
        }
        if (ctrl.categoriesError.value.isNotEmpty && ctrl.categories.isEmpty) {
          return _buildErrorState(ctrl);
        }
        if (ctrl.categories.isEmpty) {
          return _buildEmptyState(ctrl);
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
              return _CategoryCard(
                category: category,
                onTap: () => Get.toNamed(
                  AppRoutes.approvedVehicleListings,
                  arguments: {'category': category},
                ),
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildShimmerGrid() {
    return GridView.builder(
      padding: EdgeInsets.all(AppSpacing.lg),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14.h,
        crossAxisSpacing: 14.w,
        childAspectRatio: 0.8,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.grey100,
            borderRadius: BorderRadius.circular(16.r),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(ApprovedVehicleController ctrl) {
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

  Widget _buildEmptyState(ApprovedVehicleController ctrl) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category_outlined, size: 48.w, color: AppColors.grey400),
            SizedBox(height: 12.h),
            Text(
              'No categories available',
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
            // Icon — direct, no background
            category.iconName.isNotEmpty
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
            Row(
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
                Text(
                  category.approvedVehAvailableCount > 0
                      ? '${category.approvedVehAvailableCount} vehicles'
                      : 'Unavailable',
                  style: AppFonts.bodySmall.copyWith(
                    fontSize: 10.sp,
                    color: category.approvedVehAvailableCount > 0
                        ? AppColors.primary
                        : AppColors.grey500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
