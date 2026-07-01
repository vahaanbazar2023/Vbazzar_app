import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/design_system/templates/app_layout.dart';
import '../../../core/design_system/tokens/app_radius.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/extensions/context_extensions.dart';
import '../controllers/my_bids_wins_controller.dart';
import '../models/my_bids_wins_models.dart';
import 'my_bid_detail_view.dart';

class MyBidsView extends GetView<MyBidsController> {
  const MyBidsView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: context.l10n.myBids,
      subtitle: context.l10n.yourAuctionBids,
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
        if (controller.bids.isEmpty) {
          return _EmptyState(
            icon: Icons.gavel_outlined,
            message: context.l10n.noBidsYet,
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
                controller.bids.length +
                (controller.isLoadingMore.value ? 1 : 0),
            itemBuilder: (_, i) {
              if (i >= controller.bids.length) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                );
              }
              return Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.md),
                child: _BidCard(item: controller.bids[i]),
              );
            },
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bid card — same structure as auction vehicle listing card
// ─────────────────────────────────────────────────────────────────────────────

class _BidCard extends StatelessWidget {
  final MyBidItem item;
  const _BidCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final v = item.vehicleDetails;
    final isClosed = !item.isAuctionActive;
    final isWinning = item.isWinning;

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
              // Auction closed badge
              if (isClosed)
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.grey800.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      context.l10n.closedBadge,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // ── Content — lightOrangeBackground tint like auction card ────────
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

                // Bid info rows
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.sm,
                    AppSpacing.md,
                    0,
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Your bid — expands to fill available space
                          Expanded(
                            child: _BidInfoChip(
                              label: context.l10n.your_bid,
                              value: '₹ ${_fmt(item.userBidAmount)}',
                              highlight: isWinning,
                            ),
                          ),
                          SizedBox(width: AppSpacing.sm),
                          // Status badge — fixed size, no label
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: _statusColor(
                                item.bidStatus,
                              ).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              _statusLabel(item.bidStatus),
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                color: _statusColor(item.bidStatus),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              context.l10n.highestBid,
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 14.sp,
                                color: AppColors.lightOrangeDark,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          SizedBox(width: AppSpacing.sm),
                          Flexible(
                            child: GradientText(
                              '₹ ${_fmt(item.currentHighestBid)}',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: AppSpacing.sm),

                // Bottom buttons
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    0,
                    AppSpacing.md,
                    AppSpacing.md,
                  ),
                  child: isClosed
                      ? Container(
                          width: double.infinity,
                          height: 44.h,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.grey200,
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          child: Text(
                            context.l10n.auctionClosedButton,
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
                              fontSize: 14.sp,
                              color: AppColors.grey600,
                            ),
                          ),
                        )
                      : Column(
                          children: [
                            GradientButton.filled(
                              text: context.l10n.bid_now,
                              width: double.infinity,
                              onPressed: () =>
                                  Get.to(() => MyBidDetailView(item: item)),
                            ),
                            SizedBox(height: AppSpacing.sm),
                            GradientButton.outlined(
                              text: context.l10n.viewDetails,
                              backgroundColor: Colors.transparent,
                              width: double.infinity,
                              onPressed: () =>
                                  Get.to(() => MyBidDetailView(item: item)),
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

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return AppColors.success;
      case 'rejected':
        return AppColors.primary;
      case 'pending':
        return AppColors.warning;
      default:
        return AppColors.grey700;
    }
  }

  /// Maps raw API bid status to plain readable text.
  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return 'Winning';
      case 'rejected':
        return 'Outbid';
      case 'pending':
        return 'Pending';
      case 'won':
        return 'Won';
      case 'lost':
        return 'Lost';
      default:
        return status.isEmpty ? '—' : _capitalize(status);
    }
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

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

// ─────────────────────────────────────────────────────────────────────────────
// Bid info chip (label + value inline)
// ─────────────────────────────────────────────────────────────────────────────

class _BidInfoChip extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;
  final Color? statusColor;

  const _BidInfoChip({
    required this.label,
    required this.value,
    this.highlight = false,
    this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3.h),
      child: Row(
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
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color:
                    statusColor ??
                    (highlight ? AppColors.success : AppColors.black),
              ),
            ),
          ),
        ],
      ),
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
            GradientButton.filled(text: context.l10n.retry, onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}
