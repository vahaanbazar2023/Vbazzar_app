import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../theme/app_fonts.dart';
import '../domain/entities/shop_entity.dart';

/// Reusable card widget for displaying shop information.
/// Shows name, address, distance, rating, category badge, and action buttons.
class ShopCard extends StatelessWidget {
  final ShopEntity shop;
  final VoidCallback? onSubscribe;
  final VoidCallback? onCall;
  final bool hasMobileNumber;
  final bool showSubscribeButton;

  const ShopCard({
    super.key,
    required this.shop,
    this.onSubscribe,
    this.onCall,
    this.hasMobileNumber = false,
    this.showSubscribeButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Row: Name + Category Badge ──────────────
          Row(
            children: [
              Expanded(
                child: Text(
                  shop.shopName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.titleSmall.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.xs),
              _buildCategoryBadge(),
            ],
          ),
          SizedBox(height: AppSpacing.sm),

          // ── Address ────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on_outlined, size: 16.r, color: AppColors.grey500),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  _formatAddress(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.bodySmall.copyWith(
                    color: AppColors.grey600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),

          // ── Distance + Rating Row ──────────────────────────
          Row(
            children: [
              // Distance
              Icon(Icons.directions_walk, size: 14.r, color: AppColors.primary),
              SizedBox(width: 4.w),
              Text(
                '${shop.distanceKm.toStringAsFixed(1)} km',
                style: AppFonts.labelSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              // Rating
              Icon(Icons.star, size: 14.r, color: AppColors.warning),
              SizedBox(width: 4.w),
              Text(
                shop.ratingAsDouble.toStringAsFixed(1),
                style: AppFonts.labelSmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              // Type
              Text(
                shop.type.toUpperCase(),
                style: AppFonts.labelSmall.copyWith(
                  color: AppColors.grey500,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),

          // ── Action Buttons ─────────────────────────────────
          Row(
            children: [
              // Call button (if mobile number available)
              if (hasMobileNumber && onCall != null)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onCall,
                    icon: Icon(Icons.call, size: 16.r),
                    label: const Text('Call'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                    ),
                  ),
                ),

              if (hasMobileNumber && onCall != null && showSubscribeButton)
                SizedBox(width: AppSpacing.sm),

              // Subscribe button
              if (showSubscribeButton)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onSubscribe,
                    icon: Icon(Icons.lock_open, size: 16.r),
                    label: Text(hasMobileNumber ? 'Subscribed' : 'Subscribe'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: hasMobileNumber
                          ? AppColors.success
                          : AppColors.primary,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBadge() {
    final isCE = shop.category.toUpperCase() == 'CE';
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 8.w,
        vertical: 4.h,
      ),
      decoration: BoxDecoration(
        color: isCE
            ? AppColors.primary.withValues(alpha: 0.1)
            : AppColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Text(
        shop.category.toUpperCase(),
        style: AppFonts.labelSmall.copyWith(
          color: isCE ? AppColors.primary : AppColors.info,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String _formatAddress() {
    final parts = <String>[];
    if (shop.addressLine1.isNotEmpty) parts.add(shop.addressLine1);
    if (shop.addressLine2.isNotEmpty) parts.add(shop.addressLine2);
    if (shop.state.isNotEmpty) parts.add(shop.state);
    return parts.join(', ');
  }
}