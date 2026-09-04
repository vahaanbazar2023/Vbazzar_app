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
      body: TabBarView(
        controller: controller.tabController,
        children: List.generate(3, (i) => _TabContent(tabIndex: i)),
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
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            );
          }
          return Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.md),
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
    // Determine bid status for border + image chip
    final bool hasBid = v.yourBid > 0;
    final bool isWinning =
        hasBid &&
        (v.currentHighestBid == null || v.yourBid >= v.currentHighestBid!);
    final bool isLosing = hasBid && !isWinning;

    final cardBorderColor = isWinning
        ? const Color(0xFF2E7D32)
        : isLosing
        ? const Color(0xFFC62828)
        : AppColors.grey300;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(width: hasBid ? 1.0 : 1.0, color: cardBorderColor),
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
          // ── Image + overlays ──────────────────────────────────
          Stack(
            children: [
              // Light grey bg so white vehicles are visible
              Container(
                height: 200.h,
                color: const Color(0xFFF0F0F0),
                child: NetworkImageCarousel(imageUrls: v.images, height: 200.h),
              ),
              // VHID badge — top-left, white bg, primary border
              Positioned(
                top: 10.h,
                left: 10.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6.r),
                    border: Border.all(color: AppColors.primary, width: 1.2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.directions_car_outlined,
                        size: 12.r,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'VHID: ${v.vehicleId}',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Timer badge — top-right (uses existing TimerBadge widget)
              Positioned(top: 0, right: 0, child: TimerBadge(endAt: '')),
              // Winning / Losing chip — bottom-left of image — glassmorphism
              if (hasBid)
                Positioned(
                  bottom: 10.h,
                  left: 10.w,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.r),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 5.h,
                        ),
                        decoration: BoxDecoration(
                          color: isWinning
                              ? const Color(0xFF2E7D32).withValues(alpha: 0.35)
                              : const Color(0xFFC62828).withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: isWinning
                                ? const Color(0xFF66BB6A).withValues(alpha: 0.6)
                                : const Color(
                                    0xFFEF9A9A,
                                  ).withValues(alpha: 0.6),
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isWinning
                                  ? Icons.emoji_events_rounded
                                  : Icons.trending_down_rounded,
                              size: 12.r,
                              color: Colors.white,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              isWinning ? 'Winning' : 'Losing',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                shadows: const [
                                  Shadow(color: Colors.black54, blurRadius: 4),
                                ],
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

          // ── Content ───────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 14.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Title: Make Model  -  RegNo  -  Year
                Text(
                  '${v.make} | ${v.model}  ',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  ' ${v.registrationNo}  |  ${v.year}',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),
                SizedBox(height: 12.h),
                // ── Always-visible info rows ───────────────────
                _InfoRow(
                  icon: Icons.business_rounded,
                  label: 'Yard Name',
                  value: v.yardName,
                  isEven: true,
                  truncate: !_expanded,
                ),
                _InfoRow(
                  icon: Icons.location_on_outlined,
                  label: 'Yard Location',
                  value: _expanded
                      ? v.yardLocation
                      : v.yardLocation.split(',').first.trim(),
                  isEven: false,
                  truncate: !_expanded,
                ),
                // ── Expanded details ───────────────────────────
                if (_expanded) ...[
                  _InfoRow(
                    icon: Icons.vpn_key_outlined,
                    label: 'Vehicle ID',
                    value: v.vehicleId,
                    isEven: true,
                  ),
                  _InfoRow(
                    icon: Icons.fingerprint,
                    label: 'Chassis No',
                    value: v.chassisNo,
                    isEven: false,
                  ),
                  _InfoRow(
                    icon: Icons.settings_outlined,
                    label: 'Engine No',
                    value: v.engineNo,
                    isEven: true,
                  ),
                  _InfoRow(
                    icon: Icons.description_outlined,
                    label: 'RC Availability',
                    value: '—',
                    isEven: false,
                  ),
                  _InfoRow(
                    icon: Icons.person_outline_rounded,
                    label: 'Owner',
                    value: v.owner,
                    isEven: true,
                  ),
                  _InfoRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Repo Date',
                    value: v.repoDate,
                    isEven: false,
                  ),
                  _InfoRow(
                    icon: Icons.local_parking_rounded,
                    label: 'Parking Charges',
                    value: '0.0',
                    isEven: true,
                  ),
                  _InfoRow(
                    icon: Icons.location_city_outlined,
                    label: 'Registered RTO',
                    value: v.registeredRto,
                    isEven: false,
                  ),
                  _InfoRow(
                    icon: Icons.swap_horiz_rounded,
                    label: 'Transmission',
                    value: v.transmission,
                    isEven: true,
                  ),
                  _InfoRow(
                    icon: Icons.tune_rounded,
                    label: 'Variant',
                    value: v.variant,
                    isEven: false,
                  ),
                  _InfoRow(
                    icon: Icons.palette_outlined,
                    label: 'Colour',
                    value: v.colour,
                    isEven: true,
                  ),
                  _InfoRow(
                    icon: Icons.local_gas_station_outlined,
                    label: 'Fuel Type',
                    value: v.fuelType,
                    isEven: false,
                  ),
                  _InfoRow(
                    icon: Icons.receipt_outlined,
                    label: 'Transaction Fees',
                    value: '0.0',
                    isEven: true,
                  ),
                  _InfoRow(
                    icon: Icons.badge_outlined,
                    label: 'Contact Person',
                    value: v.contactPersonName,
                    isEven: false,
                  ),
                  _InfoRow(
                    icon: Icons.phone_outlined,
                    label: 'Mobile',
                    value: v.contactPersonNumber,
                    isEven: true,
                  ),
                  _InfoRow(
                    icon: Icons.category_outlined,
                    label: 'Category',
                    value: v.category,
                    isEven: false,
                  ),
                  _InfoRow(
                    icon: Icons.attach_money_rounded,
                    label: 'Start Price',
                    value: '₹ ${_fmt(v.minimumPrice)}',
                    isEven: true,
                  ),
                  _InfoRow(
                    icon: Icons.gavel_rounded,
                    label: 'Highest Bid',
                    value: v.currentHighestBid != null
                        ? '₹ ${_fmt(v.currentHighestBid!)}'
                        : 'No bids yet',
                    isEven: false,
                  ),
                  if (v.remarks.isNotEmpty)
                    _InfoRow(
                      icon: Icons.notes_rounded,
                      label: 'Remarks',
                      value: v.remarks,
                      isEven: true,
                    ),
                  SizedBox(height: 14.h),
                  // ── Available Buying Limit ────────────────────
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 6.h,
                    ),
                    color: AppColors.grey100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Available Buying Limit: ',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 13.sp,
                            color: AppColors.grey600,
                          ),
                        ),
                        Text(
                          '₹ ${_fmt(v.availableBalance)}',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.h),
                  // ── 2×2 chips grid ────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _BidChip(
                          label: 'Your Bid',
                          value: v.yourBid > 0 ? '₹ ${_fmt(v.yourBid)}' : '₹ 0',
                          showNoBid: v.yourBid == 0,
                          winStatus: v.yourBid > 0
                              ? (v.currentHighestBid == null ||
                                    v.yourBid >= v.currentHighestBid!)
                              : null,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: _BidChip(
                          label: 'Max Bids',
                          value: v.maxBids.toString(),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Expanded(
                        child: _BidChip(
                          label: 'Start Price',
                          value: '₹ ${_fmt(v.minimumPrice)}',
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: _BidChip(
                          label: 'Bids Received',
                          value: v.bidsReceived.toString(),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                ],
                SizedBox(height: 8.h),
                // ── See More with divider lines on both sides ─────
                Row(
                  children: [
                    Expanded(
                      child: Divider(color: AppColors.grey400, thickness: 1),
                    ),
                    SizedBox(width: 10.w),
                    GestureDetector(
                      onTap: () => setState(() => _expanded = !_expanded),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.grey400,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _expanded ? 'See Less' : 'See More',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.grey700,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Icon(
                              _expanded
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.keyboard_arrow_down_rounded,
                              size: 18.r,
                              color: AppColors.grey700,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Divider(color: AppColors.grey400, thickness: 1),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                // ── Bid row ──────────────────────────────────────
                Row(
                  children: [
                    // [-  ₹ amount  +] single pill
                    Expanded(
                      child: Container(
                        height: 36.h,
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFCCCCCC)),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: _decreaseBid,
                              behavior: HitTestBehavior.opaque,
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.w),
                                child: Container(
                                  width: 28.r,
                                  height: 28.r,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.grey400,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.remove,
                                    size: 16.r,
                                    color: AppColors.black,
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
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.black,
                                ),
                                decoration: InputDecoration(
                                  prefixText: '₹  ',
                                  prefixStyle: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w700,
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
                                padding: EdgeInsets.symmetric(horizontal: 8.w),
                                child: Container(
                                  width: 28.r,
                                  height: 28.r,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.grey400,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.add,
                                    size: 16.r,
                                    color: AppColors.black,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    // BID NOW pill
                    // BID NOW pill — uses per-card _isPlacingBid (not shared controller state)
                    GestureDetector(
                      onTap: _isPlacingBid ? null : () => _placeBid(context),
                      child: Container(
                        height: 32.h,
                        padding: EdgeInsets.symmetric(horizontal: 18.w),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _isPlacingBid
                                ? [
                                    const Color(0xFFAA5555),
                                    const Color(0xFF884444),
                                  ]
                                : [
                                    const Color(0xFF8B1212),
                                    const Color(0xFF5C0A0A),
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(30.r),
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
                                'BID NOW',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 0.3,
                                ),
                              ),
                      ),
                    ),
                  ],
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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isEven;
  final bool truncate;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isEven = false,
    this.truncate = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isEven ? Colors.white : AppColors.grey200.withOpacity(0.9),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 12.r, color: AppColors.grey1),
          SizedBox(width: 6.w),
          SizedBox(
            width: 100.w,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 12.sp,
                color: AppColors.black,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : '\u2014',
              textAlign: TextAlign.right,
              maxLines: truncate ? 1 : null,
              overflow: truncate ? TextOverflow.ellipsis : TextOverflow.visible,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
                    fontWeight: FontWeight.w700,
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
  final bool showNoBid;
  // null = no bid placed, true = winning, false = losing
  final bool? winStatus;

  const _BidChip({
    required this.label,
    required this.value,
    this.showNoBid = false,
    this.winStatus,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = winStatus == null
        ? AppColors.grey300
        : winStatus!
        ? const Color(0xFF2E7D32) // green
        : const Color(0xFFC62828); // red

    return Container(
      height: 52.h,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: borderColor,
          width: winStatus != null ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Status chip (Winning / Losing) or label
          if (winStatus != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: winStatus!
                    ? const Color(0xFF2E7D32)
                    : const Color(0xFFC62828),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                winStatus! ? 'Winning' : 'Losing',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 8.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            )
          else
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 11.sp,
                color: AppColors.black,
              ),
            ),
          SizedBox(height: 2.h),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: winStatus == null
                  ? AppColors.black
                  : winStatus!
                  ? const Color(0xFF2E7D32)
                  : const Color(0xFFC62828),
            ),
          ),
          if (showNoBid)
            Text(
              'No Bid',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 8.sp,
                color: AppColors.grey500,
              ),
            ),
        ],
      ),
    );
  }
}
