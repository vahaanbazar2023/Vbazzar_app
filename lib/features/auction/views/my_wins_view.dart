import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/design_system/templates/app_layout.dart';
import '../../../core/design_system/tokens/app_radius.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../controllers/my_bids_wins_controller.dart';
import '../models/my_bids_wins_models.dart';
import 'my_win_detail_view.dart';

class MyWinsView extends GetView<MyWinsController> {
  const MyWinsView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: 'My Wins',
      subtitle: 'Your won auctions',
      showBack: true,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        if (controller.errorMessage.value != null) {
          return _ErrorState(
            message: controller.errorMessage.value!,
            onRetry: controller.refresh,
          );
        }
        if (controller.wins.isEmpty) {
          return const _EmptyState(
            icon: Icons.emoji_events_outlined,
            message: 'No wins yet.\nStart bidding to win auctions!',
          );
        }
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: controller.refresh,
          child: ListView.builder(
            controller: controller.scrollController,
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
            ),
            itemCount:
                controller.wins.length +
                (controller.isLoadingMore.value ? 1 : 0),
            itemBuilder: (_, i) {
              if (i >= controller.wins.length) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                );
              }
              return Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.md),
                child: _WinCard(item: controller.wins[i]),
              );
            },
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Win card — same vehicle listing card structure
// ─────────────────────────────────────────────────────────────────────────────

class _WinCard extends StatelessWidget {
  final MyWinItem item;
  const _WinCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final v = item.vehicleDetails;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.borderRadiusMd,
        border: Border.all(color: AppColors.grey200),
        boxShadow: [
          BoxShadow(
            color: const Color(0x0A000000),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image carousel ────────────────────────────────────────────────
          Stack(
            children: [
              NetworkImageCarousel(imageUrls: v.images, height: 200.h),
              // Win badge
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.ctaGradientStart,
                        AppColors.ctaGradientEnd,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.emoji_events_rounded,
                        color: Colors.white,
                        size: 11.r,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'WON',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Content ───────────────────────────────────────────────────────
          Container(
            color: AppColors.lightOrangeBackground.withValues(alpha: 0.5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.sm,
                    AppSpacing.md,
                    0,
                  ),
                  child: Text(
                    '${v.make} ${v.model}'.trim().isEmpty
                        ? item.auctionTitle
                        : '${v.make} ${v.model} - ${v.registrationNo}',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  ),
                ),

                // Bid/payment info
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.sm,
                    AppSpacing.md,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _InfoChip(
                            label: 'Payment',
                            value: item.userAuctionStatus,
                            color: item.isPaid
                                ? AppColors.success
                                : AppColors.warning,
                          ),
                          SizedBox(width: AppSpacing.lg),
                          _InfoChip(
                            label: 'Letter',
                            value: item.winningLetterStatus == 'sent'
                                ? 'Sent'
                                : 'Pending',
                            color: item.winningLetterStatus == 'sent'
                                ? AppColors.success
                                : AppColors.grey600,
                          ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          Text(
                            'Winning Bid:',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 14.sp,
                              color: AppColors.lightOrangeDark,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: AppSpacing.sm),
                          GradientText(
                            '₹ ${_fmt(item.winningBidAmount)}',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.black,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: AppSpacing.sm),

                // Buttons
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    0,
                    AppSpacing.md,
                    AppSpacing.md,
                  ),
                  child: Column(
                    children: [
                      GradientButton.filled(
                        text: 'View Details',
                        width: double.infinity,
                        onPressed: () =>
                            Get.to(() => MyWinDetailView(item: item)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _fmt(int n) {
    if (n == 0) return '0';
    final s = n.toString();
    final buf = StringBuffer();
    int c = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      if (c > 0 && c % 3 == 0) buf.write(',');
      buf.write(s[i]);
      c++;
    }
    return buf.toString().split('').reversed.join();
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _InfoChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label : ',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 13.sp,
            color: AppColors.lightOrangeDark,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty / Error states
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80.r,
              height: 80.r,
              decoration: BoxDecoration(
                color: AppColors.grey50,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.grey200),
              ),
              child: Icon(icon, color: AppColors.grey400, size: 38.r),
            ),
            SizedBox(height: 16.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 13.sp,
                color: AppColors.grey500,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: AppColors.primary, size: 48.r),
            SizedBox(height: 12.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 13.sp,
                color: AppColors.grey500,
              ),
            ),
            SizedBox(height: 16.h),
            GradientButton.filled(text: 'Retry', onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}
