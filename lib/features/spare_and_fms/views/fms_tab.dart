import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/constants/app_colors.dart';
import '../../../theme/app_fonts.dart';
import '../controllers/spare_and_fms_controller.dart';
import '../domain/entities/spare_part_entity.dart';

/// FMS tab — Displays spare parts in a compact 2-column e-commerce grid.
///
/// Each card shows: image with star rating overlay, name, and price.
class FmsTab extends StatefulWidget {
  const FmsTab({super.key});

  @override
  State<FmsTab> createState() => _FmsTabState();
}

class _FmsTabState extends State<FmsTab> with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      Get.find<SpareAndFmsController>().loadMoreFmsItems();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final controller = Get.find<SpareAndFmsController>();

    return Obx(() {
      if (controller.isFmsLoading.value && controller.fmsList.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.fmsList.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 64.w,
                color: AppColors.grey400,
              ),
              SizedBox(height: 16.h),
              Text(
                context.l10n.spareNoSparePartsAvailable,
                style: AppFonts.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: controller.refreshFmsData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(context.l10n.retry),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        color: AppColors.primary,
        onRefresh: controller.refreshFmsData,
        child: GridView.builder(
          controller: _scrollController,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          physics: const AlwaysScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10.w,
            mainAxisSpacing: 10.h,
            childAspectRatio: 0.8,
          ),
          itemCount:
              controller.fmsList.length +
              (controller.hasMoreFmsData.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= controller.fmsList.length) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: const CircularProgressIndicator(),
                ),
              );
            }

            final spare = controller.fmsList[index];
            return _SpareGridCard(
              spare: spare,
              onTap: () => controller.navigateToFmsDetail(spare),
            );
          },
        ),
      );
    });
  }
}

/// FMS product card — inset photo with a glass rating pill and a brand-red
/// price tag, name underneath and a round "open" affordance.
class _SpareGridCard extends StatelessWidget {
  final SparePartEntity spare;
  final VoidCallback onTap;

  const _SpareGridCard({required this.spare, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final rating = double.tryParse(spare.starRating) ?? 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(6.r),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(22.r),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.08),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.10),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Inset photo ─────────────────────────────────
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(17.r),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _photo(),
                    // Soft scrim so the chips stay readable on any photo
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.18),
                              Colors.transparent,
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.28),
                            ],
                            stops: const [0, 0.3, 0.65, 1],
                          ),
                        ),
                      ),
                    ),
                    if (rating > 0)
                      Positioned(
                        top: 8.h,
                        left: 8.w,
                        child: _RatingPill(rating: rating),
                      ),
                    Positioned(
                      left: 8.w,
                      bottom: 8.h,
                      child: _PriceTag(text: spare.formattedPrice),
                    ),
                  ],
                ),
              ),
            ),

            // ── Name + open affordance ──────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(6.w, 8.h, 2.w, 4.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      spare.spareName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.bodySmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        fontSize: 12.sp,
                        height: 1.25,
                      ),
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Container(
                    width: 28.r,
                    height: 28.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.ctaGradientStart,
                          AppColors.ctaGradientEnd,
                        ],
                      ),
                    ),
                    child: Icon(
                      Icons.arrow_outward_rounded,
                      size: 15.r,
                      color: Colors.white,
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

  Widget _photo() {
    Widget placeholder(IconData icon) => Container(
      color: const Color(0xFFF4ECEB),
      child: Center(
        child: Icon(
          icon,
          size: 30.r,
          color: AppColors.primary.withValues(alpha: 0.35),
        ),
      ),
    );

    if (spare.primaryPhoto.isEmpty)
      return placeholder(Icons.build_circle_outlined);

    return Image.network(
      spare.primaryPhoto,
      fit: BoxFit.cover,
      loadingBuilder: (ctx, child, progress) {
        if (progress == null) return child;
        return Container(
          color: const Color(0xFFF4ECEB),
          child: Center(
            child: SizedBox(
              width: 22.r,
              height: 22.r,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
          ),
        );
      },
      errorBuilder: (_, __, ___) => placeholder(Icons.broken_image_outlined),
    );
  }
}

/// Translucent dark pill: star + numeric rating.
class _RatingPill extends StatelessWidget {
  final double rating;

  const _RatingPill({required this.rating});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
          color: Colors.black.withValues(alpha: 0.38),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.star_rounded,
                size: 12.r,
                color: const Color(0xFFFFC043),
              ),
              SizedBox(width: 3.w),
              Text(
                rating.toStringAsFixed(1),
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 10.5.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Brand-gradient price tag that sits on the photo.
class _PriceTag extends StatelessWidget {
  final String text;

  const _PriceTag({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: 120.w),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.ctaGradientStart, AppColors.ctaGradientEnd],
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          text,
          maxLines: 1,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 13.sp,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
