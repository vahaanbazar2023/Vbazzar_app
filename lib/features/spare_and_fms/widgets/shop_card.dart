import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../theme/app_fonts.dart';
import '../domain/entities/shop_entity.dart' show ShopEntity;

/// Reusable shop card widget for the Spare & FMS module.
///
/// Displays shop info (name, address, distance, rating, category badge)
/// with a gradient "Contact" button and optional call action.
class ShopCard extends StatelessWidget {
  final ShopEntity shop;
  final VoidCallback? onContact;
  final VoidCallback? onCall;

  const ShopCard({super.key, required this.shop, this.onContact, this.onCall});

  // ── CTA gradient (same as GradientButton.filled) ────────────
  static const _ctaGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.ctaGradientStart, AppColors.ctaGradientEnd],
  );

  @override
  Widget build(BuildContext context) {
    final hasValidPhone =
        shop.mobileNumber.isNotEmpty &&
        shop.mobileNumber != 'null' &&
        shop.mobileNumber != '0';

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.grey200, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top: Name + Category badge + Rating ──────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Shop icon container
                Container(
                  width: 48.r,
                  height: 48.r,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary.withValues(alpha: 0.12),
                        AppColors.primaryDark.withValues(alpha: 0.06),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  child: Icon(
                    Icons.store_rounded,
                    size: 24.r,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: 12.w),

                // Name + Address
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Shop name + category badge
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              shop.shopName,
                              style: AppFonts.titleSmall.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          _buildCategoryBadge(),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        _buildAddress(),
                        style: AppFonts.bodySmall.copyWith(
                          color: AppColors.grey500,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // ── Middle: Stats row (Distance + Rating) ────────
            Row(
              children: [
                // Distance chip
                _buildStatChip(
                  icon: Icons.location_on_rounded,
                  iconColor: AppColors.info,
                  label: '${shop.distanceKm.toStringAsFixed(1)} km',
                ),
                SizedBox(width: 12.w),
                // Rating stars
                _buildStarRating(),

                const Spacer(),

                // Call button (if phone available)
                if (hasValidPhone && onCall != null)
                  GestureDetector(
                    onTap: onCall,
                    child: Container(
                      width: 36.r,
                      height: 36.r,
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.phone_rounded,
                        size: 18.r,
                        color: AppColors.success,
                      ),
                    ),
                  ),
              ],
            ),

            SizedBox(height: 14.h),

            // ── Bottom: Gradient Contact button ──────────────
            _buildContactButton(),
          ],
        ),
      ),
    );
  }

  /// Category badge (CE / CV) — theme-colored
  Widget _buildCategoryBadge() {
    final isCE = shop.category.toUpperCase() == 'CE';
    final bgColor = isCE ? AppColors.lightOrange : AppColors.warningBackground;
    final textColor = isCE ? AppColors.primaryDark : AppColors.secondaryDark;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Text(
        shop.category.toUpperCase(),
        style: AppFonts.labelSmall.copyWith(
          color: textColor,
          fontWeight: FontWeight.w800,
          fontSize: 10.sp,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  /// Small stat chip with icon + label
  Widget _buildStatChip({
    required IconData icon,
    required Color iconColor,
    required String label,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.r, color: iconColor),
          SizedBox(width: 4.w),
          Text(
            label,
            style: AppFonts.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }

  /// Gradient-filled button:
  /// • mobile_number empty → shows "Contact" → tapping triggers payment flow
  /// • mobile_number present → shows the number → tapping opens dialer
  Widget _buildContactButton() {
    final hasPhone = shop.hasValidMobileNumber;
    return GestureDetector(
      onTap: onContact,
      child: Container(
        width: double.infinity,
        height: 42.h,
        decoration: BoxDecoration(
          gradient: _ctaGradient,
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasPhone ? Icons.call_rounded : Icons.phone_in_talk_rounded,
              size: 18.r,
              color: AppColors.white,
            ),
            SizedBox(width: 8.w),
            Text(
              hasPhone ? shop.mobileNumber : 'Contact',
              style: AppFonts.titleSmall.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Star rating display — shows filled, half, and empty stars
  Widget _buildStarRating() {
    final rating = double.tryParse(shop.starRating) ?? 0;
    if (rating <= 0) {
      return _buildStatChip(
        icon: Icons.star_border_rounded,
        iconColor: AppColors.warningDark,
        label: 'N/A',
      );
    }

    final fullStars = rating.floor();
    final hasHalf = (rating - fullStars) >= 0.5;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...List.generate(5, (i) {
            if (i < fullStars) {
              return Icon(
                Icons.star_rounded,
                size: 14.r,
                color: AppColors.warningDark,
              );
            } else if (i == fullStars && hasHalf) {
              return Icon(
                Icons.star_half_rounded,
                size: 14.r,
                color: AppColors.warningDark,
              );
            } else {
              return Icon(
                Icons.star_border_rounded,
                size: 14.r,
                color: AppColors.grey300,
              );
            }
          }),
          SizedBox(width: 4.w),
          Text(
            rating.toStringAsFixed(1),
            style: AppFonts.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }

  String _buildAddress() {
    final parts = <String>[];
    if (shop.addressLine1.isNotEmpty) parts.add(shop.addressLine1);
    if (shop.addressLine2.isNotEmpty) parts.add(shop.addressLine2);
    if (shop.state.isNotEmpty) parts.add(shop.state);
    return parts.join(', ');
  }
}
