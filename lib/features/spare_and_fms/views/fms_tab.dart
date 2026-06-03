import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

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
                'No spare parts available',
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
                child: const Text('Retry'),
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

/// Compact e-commerce product card — image with star overlay, name, price.
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
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: AppColors.grey200, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image with star rating overlay ──
            AspectRatio(
              aspectRatio: 1.1,
              child: Stack(
                children: [
                  // Image fills the stack
                  Positioned.fill(
                    child: spare.primaryPhoto.isNotEmpty
                        ? Image.network(
                            spare.primaryPhoto,
                            fit: BoxFit.cover,
                            loadingBuilder: (ctx, child, progress) {
                              if (progress == null) return child;
                              return Container(
                                color: AppColors.grey100,
                                child: Center(
                                  child: SizedBox(
                                    width: 24.w,
                                    height: 24.w,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (_, __, ___) => Container(
                              color: AppColors.grey100,
                              child: Center(
                                child: Icon(
                                  Icons.broken_image_outlined,
                                  size: 28.w,
                                  color: AppColors.grey400,
                                ),
                              ),
                            ),
                          )
                        : Container(
                            color: AppColors.grey100,
                            child: Center(
                              child: Icon(
                                Icons.image_outlined,
                                size: 28.w,
                                color: AppColors.grey400,
                              ),
                            ),
                          ),
                  ),
                  // Rating badge — top right corner on the image
                  if (rating > 0)
                    Positioned(
                      top: 4.h,
                      right: 4.w,
                      child: _buildRatingBadge(rating),
                    ),
                ],
              ),
            ),

            // ── Info: name + price ──
            Padding(
              padding: EdgeInsets.fromLTRB(6.w, 4.h, 6.w, 6.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Text(
                    spare.spareName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      fontSize: 11.sp,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  // Price
                  Text(
                    '₹${spare.price}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.bodyMedium.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      fontSize: 14.sp,
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

  /// Star rating badge displayed on the image — shows filled stars.
  Widget _buildRatingBadge(double rating) {
    final fullStars = rating.floor();
    final hasHalf = (rating - fullStars) >= 0.5;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFA726), // Orange
        borderRadius: BorderRadius.circular(4.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(5, (i) {
          if (i < fullStars) {
            return Icon(Icons.star, size: 10.r, color: AppColors.white);
          } else if (i == fullStars && hasHalf) {
            return Icon(Icons.star_half, size: 10.r, color: AppColors.white);
          } else {
            return Icon(
              Icons.star_border,
              size: 10.r,
              color: AppColors.white.withValues(alpha: 0.6),
            );
          }
        }),
      ),
    );
  }
}
