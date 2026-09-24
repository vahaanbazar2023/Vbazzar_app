import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/design_system/molecules/timer_badge.dart';
import '../../../core/design_system/organisms/network_image_carousel.dart';
import '../../../core/design_system/templates/app_layout.dart';
import '../../../core/design_system/tokens/app_radius.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../routes/app_routes.dart';
import '../controllers/vehicle_listing_controller.dart';
import '../domain/entities/auction_entity.dart';
import '../models/vehicle_listing.dart';
import 'auction_activity_fab.dart';
import 'auction_filter_bottom_sheet.dart';

class AuctionVehicleListingScreen extends GetView<VehicleListingController> {
  const AuctionVehicleListingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: controller.auctionTitle.isNotEmpty
          ? controller.auctionTitle
          : context.l10n.liveAuctions,
      showBack: true,
      headerExtra: _TabAndFilterBar(controller: controller),
      body: Stack(
        children: [
          TabBarView(
            controller: controller.tabController,
            children: List.generate(3, (i) => _TabContent(tabIndex: i)),
          ),
          const Positioned(right: 16, bottom: 24, child: AuctionActivityFab()),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab bar + filter icon row — passed as headerExtra to AppLayout
// ─────────────────────────────────────────────────────────────────────────────

class _TabAndFilterBar extends StatelessWidget {
  final VehicleListingController controller;
  const _TabAndFilterBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
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
            tabAlignment: TabAlignment.fill,
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
            tabs: [
              Tab(text: context.l10n.liveTab),
              Tab(text: context.l10n.closingTodayTab),
              Tab(text: context.l10n.upcomingTab),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            controller.backupCurrentFilters();
            AuctionFilterBottomSheetV2.show(context, controller);
          },
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
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Per-tab content
// ─────────────────────────────────────────────────────────────────────────────

class _TabContent extends StatelessWidget {
  final int tabIndex;
  const _TabContent({required this.tabIndex});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<VehicleListingController>();
    return Obx(() {
      if (ctrl.tabLoading(tabIndex).value) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        );
      }
      final error = ctrl.tabError(tabIndex).value;
      if (error.isNotEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  error,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 14.sp,
                    color: AppColors.grey600,
                  ),
                ),
                SizedBox(height: AppSpacing.md),
                GradientButton.filled(
                  text: context.l10n.retry,
                  onPressed: ctrl.refresh,
                  width: 120.w,
                ),
              ],
            ),
          ),
        );
      }
      final vehicles = ctrl.tabVehicles(tabIndex);
      if (vehicles.isEmpty) {
        return Center(
          child: Text(
            context.l10n.noVehiclesFound,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 14.sp,
              color: AppColors.grey500,
            ),
          ),
        );
      }
      final loadingMore = ctrl.tabLoadingMore(tabIndex).value;
      return ListView.builder(
        controller: ctrl.scrollControllers[tabIndex],
        padding: EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
        ),
        itemCount: vehicles.length + (loadingMore ? 1 : 0),
        itemBuilder: (_, index) {
          if (index >= vehicles.length) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            );
          }
          return Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.sm),
            child: _VehicleCard(
              vehicle: vehicles[index],
              bidIncrementAmount: ctrl.bidIncrementAmount,
              controller: ctrl,
            ),
          );
        },
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Vehicle Card — matching the screenshot design
// ─────────────────────────────────────────────────────────────────────────────

class _VehicleCard extends StatefulWidget {
  final VehicleListing vehicle;
  final int bidIncrementAmount;
  final VehicleListingController controller;

  const _VehicleCard({
    required this.vehicle,
    required this.bidIncrementAmount,
    required this.controller,
  });

  @override
  State<_VehicleCard> createState() => _VehicleCardState();
}

class _VehicleCardState extends State<_VehicleCard> {
  bool _expanded = false;
  bool _isPlacingBid = false;
  late int _bidAmount;
  late TextEditingController _bidController;

  @override
  void initState() {
    super.initState();
    final v = widget.vehicle;
    // Use minimum_next_bid from API — it's the correct next valid bid amount
    _bidAmount = v.minimumNextBid ?? v.minimumPrice;
    _bidController = TextEditingController(text: _fmt(_bidAmount));
  }

  @override
  void dispose() {
    _bidController.dispose();
    super.dispose();
  }

  int get _increment => (widget.vehicle.bidIncrementAmount ?? 0) > 0
      ? widget.vehicle.bidIncrementAmount!
      : widget.bidIncrementAmount > 0
      ? widget.bidIncrementAmount
      : 5000;

  void _decreaseBid() {
    final min = widget.vehicle.minimumNextBid ?? widget.vehicle.minimumPrice;
    final next = _bidAmount - _increment;
    if (next >= min) {
      setState(() {
        _bidAmount = next;
        _bidController.text = _fmt(_bidAmount);
      });
    }
  }

  void _increaseBid() {
    setState(() {
      _bidAmount += _increment;
      _bidController.text = _fmt(_bidAmount);
    });
  }

  void _onBidTextChanged(String raw) {
    final cleaned = raw.replaceAll(',', '').replaceAll('₹', '').trim();
    final parsed = int.tryParse(cleaned);
    if (parsed != null) {
      _bidAmount = parsed;
    }
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.vehicle;
    final bool hasBid = v.yourBid > 0;
    final bool isWinning =
        hasBid &&
        (v.currentHighestBid == null || v.yourBid >= v.currentHighestBid!);
    final bool isLosing = hasBid && !isWinning;

    final cardBorderColor = isWinning
        ? const Color(0xFF2E7D32)
        : isLosing
        ? const Color(0xFFC62828)
        : AppColors.grey200;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: cardBorderColor, width: hasBid ? 1.5 : 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ══════════════════════════════════════════════════
          // ROW 1: image (left) + title / timer / yard (right)
          // ══════════════════════════════════════════════════
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Image panel ──────────────────────────────
              SizedBox(
                width: 171.w,
                height: 99.h,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      color: const Color(0xFFF0F0F0),
                      child: NetworkImageCarousel(
                        imageUrls: v.images,
                        height: 99.h,
                      ),
                    ),
                    // VEH ID pill — bottom-center
                    // Positioned(
                    //   bottom: 0,
                    //   left: 0,
                    //   right: 0,
                    //   child: Container(
                    //     color: AppColors.primary,
                    //     padding: EdgeInsets.symmetric(
                    //       horizontal: 6.w,
                    //       vertical: 4.h,
                    //     ),
                    //     child: Text(
                    //       v.vehicleId,
                    //       textAlign: TextAlign.center,
                    //       style: TextStyle(
                    //         fontFamily: 'Montserrat',
                    //         fontSize: 9.sp,
                    //         fontWeight: FontWeight.w600,
                    //         color: Colors.white,
                    //         letterSpacing: 0.3,
                    //       ),
                    //       overflow: TextOverflow.ellipsis,
                    //     ),
                    //   ),
                    // ),
                    // Winning/Losing chip
                    if (hasBid)
                      Positioned(
                        top: 8.h,
                        left: 6.w,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 7.w,
                                vertical: 3.h,
                              ),
                              decoration: BoxDecoration(
                                color: isWinning
                                    ? const Color(
                                        0xFF2E7D32,
                                      ).withValues(alpha: 0.45)
                                    : const Color(
                                        0xFFC62828,
                                      ).withValues(alpha: 0.45),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isWinning
                                        ? Icons.emoji_events_rounded
                                        : Icons.trending_down_rounded,
                                    size: 10.r,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 3.w),
                                  Text(
                                    isWinning ? 'Winning' : 'Losing',
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 9.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // ── Right: title + timer + yard ──────────────
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(12.w, 4.h, 12.w, 12.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Make + Model (bold)
                      Text(
                        '${v.make} ${v.model}',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.h),
                      // Reg No · Year
                      Text(
                        '${v.registrationNo}  ·  ${v.year}',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 11.sp,
                          color: AppColors.grey600,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      // Timer badge
                      TimerBadge(endAt: v.auctionEndDate),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ══════════════════════════════════════════════════
          // ROW 2: always-visible 2-col info grid
          // Yard Name | Yard Location (truncated, hidden when expanded)
          // Auction ID | Vehicle ID
          // ══════════════════════════════════════════════════
          // Padding(
          //   padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 0),
          //   child: Column(
          //     children: [
          //       // Show truncated yard rows only when collapsed
          //       if (!_expanded) ...[
          //         _GridRow(
          //           'Yard Name',
          //           v.yardName,
          //           'Yard Location',
          //           v.yardLocation,
          //           singleLine: true,
          //         ),
          //         SizedBox(height: 2.h),
          //       ],
          //       _GridRow(
          //         'Auction ID',
          //         v.auctionId,
          //         'Vehicle ID',
          //         v.vehicleId,
          //         singleLine: true,
          //       ),
          //     ],
          //   ),
          // ),

          // ══════════════════════════════════════════════════
          // EXPANDED DETAILS
          // ══════════════════════════════════════════════════
          if (_expanded)
            Padding(
              padding: EdgeInsets.fromLTRB(12.w, 4.h, 12.w, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _OptGridRow(
                    'RC Availability',
                    v.rcAvailability,
                    'Repo Date',
                    v.repoDate,
                  ),
                  _OptGridRow(
                    'Chassis No',
                    v.chassisNo,
                    'Engine No',
                    v.engineNo,
                  ),
                  _OptGridRow(
                    'Registered RTO',
                    v.registeredRto,
                    'Transmission',
                    v.transmission,
                  ),
                  _OptGridRow('Variant', v.variant, 'Colour', v.colour),
                  _OptGridRow('Fuel Type', v.fuelType, 'Owner', v.owner),
                  _OptGridRow(
                    'Contact Person',
                    v.contactPersonName,
                    'Mobile',
                    v.contactPersonNumber,
                  ),
                  _OptGridRow(
                    'Start Price',
                    '₹ ${_fmt(v.minimumPrice)}',
                    'Highest Bid',
                    v.currentHighestBid != null
                        ? '₹ ${_fmt(v.currentHighestBid!)}'
                        : 'No bids',
                  ),
                  _OptGridRow(
                    'Parking Charges',
                    v.parkingCharges,
                    'Transaction Fees',
                    v.transactionFees,
                  ),
                  // Full Yard Name + Yard Location above remarks
                  _OptGridRow(
                    'Yard Name',
                    v.yardName,
                    'Yard Location',
                    v.yardLocation,
                  ),
                  if (v.remarks.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(bottom: 6.h),
                      child: _Cell(label: 'Remarks', value: v.remarks),
                    ),
                  SizedBox(height: 4.h),
                  // Available buying limit
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.grey100,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Available Buying Limit: ',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 12.sp,
                            color: AppColors.grey600,
                          ),
                        ),
                        Text(
                          '₹ ${_fmt(v.availableBalance)}',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.black,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 10.h),
                    child: Row(
                      children: [
                        Expanded(
                          child: _BidChip(
                            label: 'Your Bid',
                            value: v.yourBid > 0
                                ? '₹ ${_fmt(v.yourBid)}'
                                : '₹ 0',
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: _BidChip(
                            label: 'Bids Left',
                            value: v.bidsLeft.toString(),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: _BidChip(
                            label: 'Bids',
                            value: v.bidsReceived.toString(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // ════════════════════════════════════════════Fyard══════
          // See More / Less
          // ══════════════════════════════════════════════════
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Row(
              children: [
                Expanded(
                  child: Divider(color: AppColors.grey300, thickness: 1),
                ),
                SizedBox(width: 8.w),
                Container(
                  height: 20,
                  decoration: BoxDecoration(
                    border: Border.all(width: 1, color: AppColors.grey400),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _expanded ? 'See Less' : 'See More',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.grey700,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Icon(
                          _expanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          size: 16.r,
                          color: AppColors.grey700,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Divider(color: AppColors.grey300, thickness: 1),
                ),
              ],
            ),
          ),

          // ══════════════════════════════════════════════════
          // ROW 3: always-visible 3-chip bid summary
          // Your Bid | Bids Left | Bids
          // ══════════════════════════════════════════════════
          SizedBox(height: 8.h),
          // ══════════════════════════════════════════════════
          // ROW 4: bid input + PLACE BID
          // ══════════════════════════════════════════════════
          Padding(
            padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 6.h),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 32.h,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.grey300),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: _decreaseBid,
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Container(
                              width: 30.r,
                              height: 30.h,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.grey400),
                              ),
                              child: Icon(
                                Icons.remove_rounded,
                                size: 18.r,
                                color: AppColors.grey700,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _bidController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            onChanged: _onBidTextChanged,
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.black,
                            ),
                            decoration: InputDecoration(
                              prefixText: '₹  ',
                              prefixStyle: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.black,
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: _increaseBid,
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Container(
                              width: 30.r,
                              height: 30.h,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.grey400),
                              ),
                              child: Icon(
                                Icons.add_rounded,
                                size: 18.r,
                                color: AppColors.grey700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                GestureDetector(
                  onTap: _isPlacingBid ? null : () => _placeBid(context),
                  child: Container(
                    height: 28.h,
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _isPlacingBid
                            ? [const Color(0xFFAA5555), const Color(0xFF884444)]
                            : [
                                AppColors.ctaGradientStart,
                                AppColors.ctaGradientEnd,
                              ],
                      ),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    alignment: Alignment.center,
                    child: _isPlacingBid
                        ? SizedBox(
                            width: 16.r,
                            height: 16.r,
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'PLACE BID',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _placeBid(BuildContext context) async {
    setState(() => _isPlacingBid = true);
    final error = await widget.controller.placeBid(
      vehicle: widget.vehicle,
      bidAmount: _bidAmount,
    );
    if (mounted) setState(() => _isPlacingBid = false);
    if (error != null && error != '__navigated__') {
      CustomSnackbar.show(message: error, type: SnackbarType.error);
    } else if (error == null) {
      CustomSnackbar.show(
        message: 'Bid placed successfully!',
        type: SnackbarType.success,
      );
    }
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

// ─────────────────────────────────────────────────────────────────────────────
// Mini info row inside the card header (icon + text)
// ─────────────────────────────────────────────────────────────────────────────

class _MiniInfo extends StatelessWidget {
  final IconData icon;
  final String text;
  const _MiniInfo({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 11.r, color: AppColors.grey500),
        SizedBox(width: 4.w),
        Expanded(
          child: Text(
            text.isNotEmpty ? text : '—',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 10.sp,
              color: AppColors.grey700,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 2-column detail grid row
// ─────────────────────────────────────────────────────────────────────────────

class _GridRow extends StatelessWidget {
  final String label1;
  final String value1;
  final String label2;
  final String value2;
  final bool singleLine;
  const _GridRow(
    this.label1,
    this.value1,
    this.label2,
    this.value2, {
    this.singleLine = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _Cell(label: label1, value: value1, singleLine: singleLine),
        ),
        SizedBox(width: 8.w),
        if (label2.isNotEmpty)
          Expanded(
            child: _Cell(label: label2, value: value2, singleLine: singleLine),
          )
        else
          const Expanded(child: SizedBox()),
      ],
    );
  }
}

/// Like _GridRow but skips itself if both values are blank/dash/zero
class _OptGridRow extends StatelessWidget {
  final String label1;
  final String value1;
  final String label2;
  final String value2;
  const _OptGridRow(this.label1, this.value1, this.label2, this.value2);

  static bool _isEmpty(String v) {
    final t = v.trim();
    return t.isEmpty ||
        t == '—' ||
        t == '-' ||
        t == '0' ||
        t == '0.0' ||
        t == '0.00';
  }

  @override
  Widget build(BuildContext context) {
    final v1empty = _isEmpty(value1);
    final v2empty = label2.isEmpty || _isEmpty(value2);
    // Skip entire row if both sides are empty
    if (v1empty && v2empty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        children: [
          if (!v1empty)
            Expanded(
              child: _Cell(label: label1, value: value1),
            )
          else
            const Expanded(child: SizedBox()),
          SizedBox(width: 8.w),
          if (!v2empty && label2.isNotEmpty)
            Expanded(
              child: _Cell(label: label2, value: value2),
            )
          else
            const Expanded(child: SizedBox()),
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  final String label;
  final String value;
  final bool singleLine;
  const _Cell({
    required this.label,
    required this.value,
    this.singleLine = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 12.sp,
            color: AppColors.black,
            fontWeight: FontWeight.w400,
          ),
        ),

        Text(
          value.isNotEmpty ? value : '—',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
          maxLines: singleLine ? 1 : 6,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _CircleBidButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleBidButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40.r,
        height: 40.r,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.grey400),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20.r, color: AppColors.black),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Lightweight filter bottom sheet that uses VehicleListingController
// ─────────────────────────────────────────────────────────────────────────────

class AuctionFilterBottomSheetV2 extends StatelessWidget {
  final VehicleListingController ctrl;
  const AuctionFilterBottomSheetV2({super.key, required this.ctrl});

  static Future<void> show(
    BuildContext context,
    VehicleListingController ctrl,
  ) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AuctionFilterBottomSheetV2(ctrl: ctrl),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: EdgeInsets.only(top: 12.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.grey300,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          // Header
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
            child: Row(
              children: [
                Icon(Icons.tune_rounded, color: AppColors.primary, size: 22.r),
                SizedBox(width: 8.w),
                Text(
                  context.l10n.filterAuctions,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Obx(
                  () => ctrl.hasActiveFilters
                      ? GestureDetector(
                          onTap: () {
                            ctrl.resetFilters();
                            Get.back();
                          },
                          child: Text(
                            context.l10n.clearFilters,
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 13.sp,
                              color: AppColors.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      : const SizedBox(),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.grey200),
          Expanded(
            child: Obx(() {
              final regions = ctrl.regions;
              final states = ctrl.statesByRegion;
              return ListView(
                padding: EdgeInsets.all(16.w),
                children: [
                  // Region
                  Text(
                    'Region',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  DropdownButtonFormField<RegionEntity>(
                    value: ctrl.selectedRegion.value,
                    hint: Text(
                      'All Regions',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 13.sp,
                        color: AppColors.grey500,
                      ),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text(
                          'All Regions',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 13.sp,
                          ),
                        ),
                      ),
                      ...regions.map(
                        (r) => DropdownMenuItem(
                          value: r,
                          child: Text(
                            r.name,
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 13.sp,
                            ),
                          ),
                        ),
                      ),
                    ],
                    onChanged: ctrl.onRegionSelected,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      isDense: true,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  // State
                  Text(
                    'State',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  DropdownButtonFormField<StateByRegionEntity>(
                    value: ctrl.selectedState.value,
                    hint: Text(
                      'All States',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 13.sp,
                        color: AppColors.grey500,
                      ),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text(
                          'All States',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 13.sp,
                          ),
                        ),
                      ),
                      ...states.map(
                        (s) => DropdownMenuItem(
                          value: s,
                          child: Text(
                            s.stateName,
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 13.sp,
                            ),
                          ),
                        ),
                      ),
                    ],
                    onChanged: (v) =>
                        ctrl.selectedState.value = v as StateByRegionEntity?,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      isDense: true,
                    ),
                  ),
                ],
              );
            }),
          ),
          // Apply / Cancel buttons
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
            child: Row(
              children: [
                Expanded(
                  child: GradientButton.outlined(
                    text: 'Cancel',
                    onPressed: () {
                      ctrl.restoreFilters();
                      Get.back();
                    },
                    height: 44.h,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: GradientButton.filled(
                    text: 'Apply',
                    onPressed: () {
                      ctrl.applyFilters();
                      Get.back();
                    },
                    height: 44.h,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bid info chip (label + bold value, optional sub-label)
// ─────────────────────────────────────────────────────────────────────────────

class _BidChip extends StatelessWidget {
  final String label;
  final String value;

  const _BidChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36.h,
      decoration: BoxDecoration(
        color: AppColors.grey200,
        border: Border.all(color: AppColors.grey300),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 10.sp,
              color: AppColors.grey500,
            ),
          ),

          Text(
            value,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
          ),
        ],
      ),
    );
  }
}
