import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/design_system/molecules/timer_badge.dart';
import '../../../core/design_system/templates/app_layout.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../routes/app_routes.dart';
import '../controllers/auction_controller.dart';
import '../models/auction_listing.dart';
import 'auction_filter_bottom_sheet.dart';

class AuctionTab extends GetView<AuctionController> {
  const AuctionTab({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: context.l10n.auction,
      subtitle: context.l10n.auctionKnowCondition,
      body: Column(
        children: [
          SizedBox(height: 8.h),
          // ── Tab bar + filter icon in same row ─────────────────
          Row(
            children: [
              Expanded(
                child: TabBar(
                  controller: controller.tabController,
                  isScrollable: false,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.grey600,
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 2,
                  dividerColor: AppColors.grey200,
                  labelPadding: EdgeInsets.symmetric(horizontal: 4.w),
                  labelStyle: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  tabAlignment: TabAlignment.fill,
                  tabs: [
                    Tab(text: context.l10n.liveTab),
                    Tab(text: context.l10n.closingTodayTab),
                    Tab(text: context.l10n.upcomingTab),
                  ],
                ),
              ),
              // Filter icon — right of tabs, same row
              GestureDetector(
                onTap: () => AuctionFilterBottomSheet.show(context),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                  child: Image.asset(
                    AppAssets.filterPng,
                    width: 22.r,
                    height: 22.r,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          // ── Tab content ──────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: controller.tabController,
              children: List.generate(3, (i) => _TabContent(tabIndex: i)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab content
// ─────────────────────────────────────────────────────────────────────────────

class _TabContent extends StatelessWidget {
  final int tabIndex;
  const _TabContent({required this.tabIndex});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AuctionController>();
    return Obx(() {
      if (ctrl.isLoading(tabIndex).value) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        );
      }
      final error = ctrl.errorMessage(tabIndex).value;
      if (error.isNotEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.xl),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14.sp,
                color: AppColors.grey600,
              ),
            ),
          ),
        );
      }
      final auctions = ctrl.auctions(tabIndex);
      if (auctions.isEmpty) {
        return Center(
          child: Text(
            context.l10n.noAuctionsAvailable,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 14.sp,
              color: AppColors.grey500,
            ),
          ),
        );
      }
      final loadingMore = ctrl.isLoadingMore(tabIndex).value;
      return ListView.builder(
        controller: ctrl.scrollControllers[tabIndex],
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
        itemCount: auctions.length + (loadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == auctions.length) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: const CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              ),
            );
          }
          return _AuctionCard(listing: auctions[index], tabIndex: tabIndex);
        },
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Auction Card — redesigned per screenshot
// ─────────────────────────────────────────────────────────────────────────────

class _AuctionCard extends StatelessWidget {
  final AuctionListing listing;
  final int tabIndex;
  const _AuctionCard({required this.listing, required this.tabIndex});

  bool get _isUpcoming => tabIndex == 2;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isUpcoming
          ? null
          : () => Get.toNamed(
              AppRoutes.vehicleListings,
              arguments: {'auction': listing},
            ),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFFE0E0E0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top banner: timer + CTA ──────────────────────────
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: _TopBanner(listing: listing, isUpcoming: _isUpcoming),
            ),
            // ── Body: title + info rows ───────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 14.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    listing.auctionTitle.isNotEmpty
                        ? listing.auctionTitle
                        : 'Auction',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  // Auction ID + Lot count on same row
                  Row(
                    children: [
                      Expanded(
                        child: _InfoRow(
                          icon: AppAssets.bidPng,
                          label: context.l10n.auctionIdLabel,
                          value: listing.auctionId,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      _InfoRow(
                        icon: AppAssets.bidPng,
                        label: '# LOT',
                        value: listing.vehicleCount.toString().padLeft(2, '0'),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  // End date
                  _InfoRow(
                    icon: AppAssets.calendarPng,
                    label: context.l10n.endDate,
                    value: _formatDate(listing.endAt),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      DateTime dt;
      if (dateStr.contains('-') && dateStr.contains('T')) {
        dt = DateTime.parse(dateStr).toLocal();
      } else {
        dt = _parseApiDate(dateStr);
      }
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final min = dt.minute.toString().padLeft(2, '0');
      final ampm = dt.hour < 12 ? 'AM' : 'PM';
      return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]}'
          ' ${dt.year}, ${h.toString().padLeft(2, '0')}:$min $ampm';
    } catch (_) {
      return dateStr;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Top banner — red timer ribbon (left) + "Tap to Bid" pill (right)
// ─────────────────────────────────────────────────────────────────────────────

class _TopBanner extends StatelessWidget {
  final AuctionListing listing;
  final bool isUpcoming;
  const _TopBanner({required this.listing, required this.isUpcoming});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38.h,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Row(
        children: [
          // ── Timer badge — mirrored so notch points right
          TimerBadge(endAt: listing.endAt, mirrored: true),
          const Spacer(),
          // ── CTA pill
          if (!isUpcoming)
            GestureDetector(
              onTap: () => Get.toNamed(
                AppRoutes.vehicleListings,
                arguments: {'auction': listing},
              ),
              child: Container(
                margin: EdgeInsets.only(right: 10.w),
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 5.h),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.ctaGradientStart,
                      AppColors.ctaGradientEnd,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  context.l10n.tapToBid,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          else
            Container(
              margin: EdgeInsets.only(right: 10.w),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.grey200,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                context.l10n.upcomingTab,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Info row
// ─────────────────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final String icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(icon, width: 13.r, height: 13.r, color: AppColors.grey600),
        SizedBox(width: 5.w),
        Text(
          '$label : ',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.grey600,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Date parser
// ─────────────────────────────────────────────────────────────────────────────

DateTime _parseApiDate(String s) {
  const monthMap = {
    'jan': 1,
    'feb': 2,
    'mar': 3,
    'apr': 4,
    'may': 5,
    'jun': 6,
    'jul': 7,
    'aug': 8,
    'sep': 9,
    'oct': 10,
    'nov': 11,
    'dec': 12,
  };
  final parts = s.split(' - ');
  final dateParts = parts[0].trim().split(' ');
  final day = int.parse(dateParts[0]);
  final month = monthMap[dateParts[1].toLowerCase()] ?? 1;
  final year = int.parse(dateParts[2]);
  int hour = 0, minute = 0;
  if (parts.length > 1) {
    final timePart = parts[1].trim().toUpperCase();
    final isPm = timePart.endsWith('PM');
    final isAm = timePart.endsWith('AM');
    final timeNum = timePart.replaceAll('AM', '').replaceAll('PM', '').trim();
    final hm = timeNum.split(':');
    hour = int.parse(hm[0]);
    minute = int.parse(hm[1]);
    if (isPm && hour != 12) hour += 12;
    if (isAm && hour == 12) hour = 0;
  }
  return DateTime(year, month, day, hour, minute);
}
