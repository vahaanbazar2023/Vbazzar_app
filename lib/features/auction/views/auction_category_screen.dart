import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/templates/app_layout.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../theme/app_fonts.dart';
import '../controllers/auction_category_controller.dart';

class AuctionCategoryScreen extends StatelessWidget {
  const AuctionCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AuctionCategoryController>();

    return AppLayout(
      title: context.l10n.auctionZone,
      subtitle: context.l10n.chooseAnyOne,
      body: Obx(() {
        if (ctrl.isLoadingCategories.value && ctrl.categories.isEmpty) {
          return _buildShimmerList();
        }
        if (ctrl.categoriesError.value.isNotEmpty && ctrl.categories.isEmpty) {
          return _buildErrorState(context, ctrl);
        }
        if (ctrl.categories.isEmpty) {
          return _buildEmptyState(context, ctrl);
        }
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => ctrl.fetchCategories(isRefresh: true),
          child: ListView.separated(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.lg,
            ),
            itemCount: ctrl.categories.length,
            separatorBuilder: (_, __) => SizedBox(height: 16.h),
            itemBuilder: (context, index) {
              final category = ctrl.categories[index];
              return _CategoryCard(
                category: category,
                onTap: () => ctrl.onCategoryTapped(category),
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildShimmerList() {
    return ListView.separated(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      separatorBuilder: (_, __) => SizedBox(height: 16.h),
      itemBuilder: (_, __) => Container(
        height: 80.h,
        decoration: BoxDecoration(
          color: AppColors.grey100,
          borderRadius: BorderRadius.circular(16.r),
        ),
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    AuctionCategoryController ctrl,
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
    AuctionCategoryController ctrl,
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

// ─────────────────────────────────────────────────────────────────────────────
// Category Card
// ─────────────────────────────────────────────────────────────────────────────

const List<Color> _cardGradient = [Color(0xFFBB2625), Color(0xFF67100B)];

/// Icon asset path derived from category code.
String _iconForCode(String code) {
  switch (code.toUpperCase()) {
    case '2W':
      return 'assets/images/png/auction.png';
    case '3W':
      return 'assets/images/png/auction.png';
    case '4W':
      return 'assets/images/png/auction.png';
    case 'CV':
      return 'assets/images/png/auction.png';
    case 'CE':
      return 'assets/images/png/auction.png';
    case 'FE':
      return 'assets/images/png/auction.png';
    default:
      return 'assets/images/png/auction.png';
  }
}

class _CategoryCard extends StatelessWidget {
  final AuctionLiveCategory category;
  final VoidCallback onTap;

  const _CategoryCard({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: _cardGradient,
          ),
          boxShadow: [
            BoxShadow(
              color: _cardGradient[0].withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 52.w,
              height: 52.w,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Center(
                child: Text(
                  _badge(category.categoryCode),
                  style: TextStyle(fontSize: 20.sp),
                ),
              ),
            ),
            SizedBox(width: 14.w),
            // Name + count
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    category.displayName,
                    style: AppFonts.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15.sp,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Container(
                        width: 6.w,
                        height: 6.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: category.count > 0
                              ? AppColors.success
                              : Colors.white.withValues(alpha: 0.4),
                        ),
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        category.count > 0
                            ? '${category.count} live auction${category.count == 1 ? '' : 's'}'
                            : 'No live auctions',
                        style: AppFonts.bodySmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Arrow
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white.withValues(alpha: 0.7),
              size: 16.w,
            ),
          ],
        ),
      ),
    );
  }

  String _badge(String code) {
    switch (code.toUpperCase()) {
      case '2W':
        return '🏍';
      case '3W':
        return '🛺';
      case '4W':
        return '🚗';
      case 'CV':
        return '🚚';
      case 'CE':
        return '🏗';
      case 'FE':
        return '🚜';
      default:
        return '🚘';
    }
  }
}
