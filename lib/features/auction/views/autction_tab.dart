import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/design_system/templates/app_layout.dart';
import '../../../core/design_system/tokens/app_radius.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../routes/app_routes.dart';
import '../controllers/auction_controller.dart';
import '../models/auction_listing.dart';

class AuctionTab extends GetView<AuctionController> {
  const AuctionTab({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: 'Auction',
      subtitle: 'Know the real condition of your vehicle.',
      body: Column(
        children: [
          SizedBox(height: 8.h),
          // ── Tab bar ──────────────────────────────────────────
          TabBar(
            controller: controller.tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.grey600,
            indicatorColor: AppColors.primary,
            indicatorWeight: 2,
            dividerColor: AppColors.grey200,
            labelStyle: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
            ),
            tabs: const [
              Tab(text: 'Live'),
              Tab(text: 'Closing Today'),
              Tab(text: 'Upcoming'),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          // ── Search bar ───────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                Expanded(child: _SearchBar()),
                SizedBox(width: AppSpacing.sm),
                GestureDetector(
                  onTap: () {},
                  child: Image.asset(
                    AppAssets.filterPng,
                    width: 28.r,
                    height: 28.r,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.md),
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

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(24.r);
    return SizedBox(
      height: 44.h,
      child: TextField(
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.search,
        textAlign: TextAlign.start,
        textAlignVertical: TextAlignVertical.center,
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 13.sp,
          color: AppColors.grey900,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 20.r,
            color: AppColors.grey500,
          ),
          hintText: 'Search',
          hintStyle: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 13.sp,
            color: AppColors.grey500,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 12.h),
          isDense: true,
          filled: true,
          fillColor: AppColors.white,
          border: OutlineInputBorder(
            borderRadius: radius,
            borderSide: BorderSide(color: AppColors.grey300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: radius,
            borderSide: BorderSide(color: AppColors.grey300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: radius,
            borderSide: BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}

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
                fontFamily: 'Plus Jakarta Sans',
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
            'No auctions available',
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
        padding: EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.md,
        ),
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
          return _AuctionCard(listing: auctions[index]);
        },
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _AuctionCard extends StatelessWidget {
  final AuctionListing listing;

  const _AuctionCard({required this.listing});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      padding: EdgeInsets.only(top: AppSpacing.sm),
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
          // ── Title row + timer badge ─────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.xs,
                    AppSpacing.sm,
                    0,
                  ),
                  child: Text(
                    listing.auctionTitle.isNotEmpty
                        ? listing.auctionTitle
                        : 'Auction',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                      height: 1.3,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: TimerBadge(endAt: listing.endAt),
              ),
            ],
          ),

          // ── Details ─────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _InfoRow(
                        icon: Image.asset(
                          AppAssets.bidPng,
                          width: 14,
                          height: 14,
                          color: AppColors.grey600,
                        ),
                        label: 'AUCTION ID',
                        value: listing.auctionId,
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm),
                  ],
                ),
                _InfoRow(
                  icon: Image.asset(AppAssets.bidPng, width: 14, height: 14),
                  label: 'LOT',
                  value: listing.vehicleCount.toString().padLeft(2, '0'),
                ),
                SizedBox(height: AppSpacing.xs),
                _InfoRow(
                  icon: Image.asset(
                    AppAssets.calendarPng,
                    width: 14,
                    height: 14,
                    color: AppColors.grey600,
                  ),
                  label: 'End Date',
                  value: _formatDate(listing.endAt),
                ),
                SizedBox(height: AppSpacing.md),

                // Tap to Bid — gradient button
                GradientButton.filled(
                  text: 'Tap to Bid',
                  onPressed: () => Get.toNamed(
                    AppRoutes.vehicleListings,
                    arguments: {'auction': listing},
                  ),
                  isLoading: false,
                  width: double.infinity,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      // Try ISO first, then API format "28 May 2025 - 05:30AM"
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
      return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]} ${dt.year},'
          ' ${h.toString().padLeft(2, '0')}:$min $ampm';
    } catch (_) {
      return dateStr;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final Widget icon;
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        icon,
        SizedBox(width: 6),
        Text(
          '$label : ',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.black,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.grey850,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

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
