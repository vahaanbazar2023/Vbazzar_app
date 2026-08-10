import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/templates/app_layout.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/extensions/context_extensions.dart';
import '../controllers/auction_category_controller.dart';

class AuctionCategoryScreen extends StatelessWidget {
  const AuctionCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AuctionCategoryController>();

    return AppLayout(
      title: context.l10n.auctionZone,
      subtitle: context.l10n.chooseAnyOne,
      bodyColor: const Color(0xFFF5F5F5),
      body: Obx(() {
        if (ctrl.isLoadingCategories.value && ctrl.categories.isEmpty) {
          return _ShimmerList();
        }
        if (ctrl.categoriesError.value.isNotEmpty && ctrl.categories.isEmpty) {
          return _ErrorState(
            message: ctrl.categoriesError.value,
            onRetry: () => ctrl.fetchCategories(isRefresh: true),
          );
        }
        if (ctrl.categories.isEmpty) {
          return _EmptyState(
            onRetry: () => ctrl.fetchCategories(isRefresh: true),
          );
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
            separatorBuilder: (_, __) => SizedBox(height: 14.h),
            itemBuilder: (context, index) {
              final category = ctrl.categories[index];
              final imageOnLeft = index % 2 == 0;
              return _CategoryCard(
                category: category,
                imageOnLeft: imageOnLeft,
                onTap: () => ctrl.onCategoryTapped(category),
              );
            },
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Category Card — white card, alternating image side
// ─────────────────────────────────────────────────────────────────────────────

class _CategoryCard extends StatelessWidget {
  final AuctionLiveCategory category;
  final bool imageOnLeft;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.imageOnLeft,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final image = _VehicleImage(iconUrl: category.iconUrl);
    final info = _CardInfo(
      category: category,
      onTap: onTap,
      imageOnLeft: imageOnLeft,
    );

    return GestureDetector(
      onTap: category.isLive ? onTap : null,
      child: Container(
        height: 110.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: imageOnLeft
              ? [image, Expanded(child: info)]
              : [Expanded(child: info), image],
        ),
      ),
    );
  }
}

// ─── Vehicle image panel ─────────────────────────────────────────────────────

class _VehicleImage extends StatelessWidget {
  final String? iconUrl;
  const _VehicleImage({required this.iconUrl});

  @override
  Widget build(BuildContext context) {
    final url = iconUrl;
    return SizedBox(
      width: 130.w,
      child: (url != null && url.isNotEmpty)
          ? Image.network(
              url,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => _placeholder(),
              loadingBuilder: (_, child, progress) =>
                  progress == null ? child : _placeholder(),
            )
          : _placeholder(),
    );
  }

  Widget _placeholder() => Center(
    child: Icon(
      Icons.directions_car_outlined,
      size: 48.r,
      color: AppColors.grey300,
    ),
  );
}

// ─── Text / info panel ───────────────────────────────────────────────────────

class _CardInfo extends StatelessWidget {
  final AuctionLiveCategory category;
  final VoidCallback onTap;
  // When image is on the left, text aligns to the right edge (and vice-versa)
  final bool imageOnLeft;

  const _CardInfo({
    required this.category,
    required this.onTap,
    required this.imageOnLeft,
  });

  @override
  Widget build(BuildContext context) {
    // When image is left → text block hugs the right: crossAxis end, badge row reversed
    // When image is right → text block hugs the left: crossAxis start, badge row normal
    final crossAxis = imageOnLeft
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;
    final textAlign = imageOnLeft ? TextAlign.right : TextAlign.left;
    final badgeRow = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StatusBadge(isLive: category.isLive),
        if (category.isLive) ...[
          SizedBox(width: 10.w),
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: 28.r,
              height: 28.r,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.ctaGradientStart,
                    AppColors.ctaGradientEnd,
                  ],
                ),
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white,
                size: 14.r,
              ),
            ),
          ),
        ],
      ],
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: crossAxis,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            category.displayName,
            textAlign: textAlign,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
          SizedBox(height: 10.h),
          badgeRow,
        ],
      ),
    );
  }
}

// ─── Status badge ─────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final bool isLive;
  const _StatusBadge({required this.isLive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: isLive
            ? const Color(0xFFE8F5E9) // light green
            : const Color(0xFFF5F0E0), // light beige
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isLive ? const Color(0xFF4CAF50) : const Color(0xFFB8A060),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7.r,
            height: 7.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isLive ? const Color(0xFF4CAF50) : const Color(0xFFB8A060),
            ),
          ),
          SizedBox(width: 5.w),
          Text(
            isLive ? 'Live' : 'Coming Soon',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: isLive ? const Color(0xFF2E7D32) : const Color(0xFF7A6030),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shimmer skeleton
// ─────────────────────────────────────────────────────────────────────────────

class _ShimmerList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      separatorBuilder: (_, __) => SizedBox(height: 14.h),
      itemBuilder: (_, __) => Container(
        height: 110.h,
        decoration: BoxDecoration(
          color: AppColors.grey100,
          borderRadius: BorderRadius.circular(16.r),
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
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48.r,
              color: AppColors.error,
            ),
            SizedBox(height: 12.h),
            Text(
              message,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  context.l10n.retry,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
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
// Empty state
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onRetry;
  const _EmptyState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category_outlined, size: 48.r, color: AppColors.grey400),
            SizedBox(height: 12.h),
            Text(
              context.l10n.noCategoriesAvailable,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              context.l10n.pullDownToRefresh,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 12.sp,
                color: AppColors.textDisabled,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
