import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../theme/app_fonts.dart';
import '../controllers/spare_and_fms_controller.dart';

/// Tab 0: Spare — Browse spare parts catalog with "Show Interest" CTA.
/// Grid layout with image, name, price, rating.
class SparePartsTab extends GetView<SpareAndFmsController> {
  const SparePartsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isFmsLoading.value && controller.fmsList.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.fmsList.isEmpty) {
        return _buildEmptyState();
      }

      return RefreshIndicator(
        onRefresh: () async {
          // Spare tab currently loads on demand
        },
        child: GridView.builder(
          padding: EdgeInsets.all(AppSpacing.md),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: AppSpacing.sm,
            mainAxisSpacing: AppSpacing.sm,
          ),
          itemCount: controller.fmsList.length,
          itemBuilder: (context, index) {
            final spare = controller.fmsList[index];
            return _SpareCard(
              spare: spare,
              onShowInterest: () => controller.recordSpareInterest(spare),
              onTap: () => controller.navigateToFmsDetail(spare),
              isRecordingInterest: controller.isRecordingInterest.value,
            );
          },
        ),
      );
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.build_outlined, size: 64.r, color: AppColors.grey400),
          SizedBox(height: AppSpacing.md),
          Text(
            'No spare parts available',
            style: AppFonts.titleMedium.copyWith(color: AppColors.grey600),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            'Check back later for new listings',
            style: AppFonts.bodySmall.copyWith(color: AppColors.grey500),
          ),
        ],
      ),
    );
  }
}

class _SpareCard extends StatelessWidget {
  final dynamic spare;
  final VoidCallback onShowInterest;
  final VoidCallback onTap;
  final bool isRecordingInterest;

  const _SpareCard({
    required this.spare,
    required this.onShowInterest,
    required this.onTap,
    required this.isRecordingInterest,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            AspectRatio(
              aspectRatio: 1.2,
              child: spare.photos.isNotEmpty
                  ? Image.network(
                      spare.photos.first,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholderImage(),
                    )
                  : _placeholderImage(),
            ),
            // Info
            Padding(
              padding: EdgeInsets.all(AppSpacing.xs),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    spare.spareName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.labelMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  if (spare.suitsFor.isNotEmpty)
                    Text(
                      'Suits: ${spare.suitsFor}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.labelSmall.copyWith(
                        color: AppColors.grey500,
                      ),
                    ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Text(
                        '₹${spare.price}',
                        style: AppFonts.titleSmall.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.star, size: 14.r, color: AppColors.warning),
                      SizedBox(width: 2.w),
                      Text(
                        spare.starRating,
                        style: AppFonts.labelSmall.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isRecordingInterest ? null : onShowInterest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        padding: EdgeInsets.symmetric(vertical: 6.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        textStyle: AppFonts.labelSmall.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child: const Text('Show Interest'),
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

  Widget _placeholderImage() {
    return Container(
      color: AppColors.grey100,
      child: Center(
        child: Icon(Icons.build_outlined, size: 32.r, color: AppColors.grey400),
      ),
    );
  }
}