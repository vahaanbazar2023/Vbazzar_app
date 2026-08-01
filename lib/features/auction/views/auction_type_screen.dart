import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/templates/app_layout.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/storage/storage_keys.dart';
import '../../../routes/app_routes.dart';
import '../controllers/auction_controller.dart';

// App-wide CTA gradient — identical to GradientButton
const _kGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [AppColors.ctaGradientStart, AppColors.ctaGradientEnd],
);

class AuctionTypeScreen extends StatelessWidget {
  const AuctionTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: context.l10n.auctionZone,
      subtitle: context.l10n.chooseAnyOne,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Column(
          children: [
            SizedBox(height: 8.h),
            _TypeCard(
              tabIndex: 0,
              imagePath: 'assets/images/png/live_bidding.png',
              title: AuctionType.label(AuctionType.live),
              subtitle: context.l10n.liveAuctionSubtitle,
              badgeLabel: context.l10n.liveBadge,
              icon: Icons.gavel_rounded,
            ),
            SizedBox(height: 16.h),
            _TypeCard(
              tabIndex: 1,
              imagePath: 'assets/images/png/goverment_inventory.png',
              title: AuctionType.label('Approved Vehicles'),
              subtitle: context.l10n.liveAuctionSubtitle,
              badgeLabel: 'Verified',
              icon: Icons.verified_rounded,
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeCard extends StatelessWidget {
  final int tabIndex;
  final String imagePath;
  final String title;
  final String subtitle;
  final String badgeLabel;
  final IconData icon;

  const _TypeCard({
    required this.tabIndex,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.badgeLabel,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (tabIndex == 1) {
          final userType =
              await SecureStorageService.to.read(StorageKeys.userType) ?? '';
          final normalized = userType.toUpperCase().trim();
          if (normalized == 'VENDOR') {
            Get.toNamed(AppRoutes.approvedVehicleBuySell);
          } else {
            Get.toNamed(AppRoutes.approvedVehicleCategory);
          }
        } else {
          Get.toNamed(AppRoutes.auctionCategory);
        }
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppColors.grey200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image banner ────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
              child: Stack(
                children: [
                  Image.asset(
                    imagePath,
                    width: double.infinity,
                    height: 160.h,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: double.infinity,
                      height: 160.h,
                      color: AppColors.grey100,
                      child: Icon(icon, size: 48.r, color: AppColors.grey400),
                    ),
                  ),
                  // Badge — theme gradient
                  Positioned(
                    top: 12.h,
                    left: 12.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 5.h,
                      ),
                      decoration: BoxDecoration(
                        gradient: _kGradient,
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.ctaGradientStart.withValues(
                              alpha: 0.4,
                            ),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon, color: Colors.white, size: 12.r),
                          SizedBox(width: 4.w),
                          Text(
                            badgeLabel.toUpperCase(),
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w700,
                              fontSize: 10.sp,
                              color: Colors.white,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Text content ────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 16.h),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w700,
                            fontSize: 16.sp,
                            color: AppColors.textPrimary,
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontWeight: FontWeight.w400,
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12.w),
                  // Chevron circle — theme gradient
                  Container(
                    width: 40.r,
                    height: 40.r,
                    decoration: BoxDecoration(
                      gradient: _kGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.ctaGradientStart.withValues(
                            alpha: 0.35,
                          ),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white,
                      size: 22.r,
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
