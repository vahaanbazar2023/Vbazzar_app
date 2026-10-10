import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/design_system/molecules/inline_dropdown_field.dart';
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
        fit: StackFit.expand,
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Search bar + Filter icon ────────────────────────
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 4.h, 8.w, 0.h),
          child: Row(
            children: [
              Expanded(
                child: CustomSearchBar(
                  controller: controller.searchController,
                  hint: context.l10n.aucSearchVehicles,
                  showGradientBorder: false,
                  borderColor: AppColors.grey300,
                  height: 40,
                ),
              ),
              GestureDetector(
                onTap: () {
                  controller.backupCurrentFilters();
                  AuctionFilterBottomSheetV2.show(context, controller);
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
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
        ),
        // ── Tab bar ─────────────────────────────────────────
        SizedBox(
          height: 34.h,
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
      // Show search results if search is active
      if (ctrl.isSearchActive) {
        if (ctrl.isSearching.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        final searchError = ctrl.searchError.value;
        if (searchError.isNotEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Text(
                searchError,
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
        final searchVehicles = ctrl.searchResults;
        if (searchVehicles.isEmpty) {
          return Center(
            child: Text(
              context.l10n.aucNoVehiclesFoundShort,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 12.sp,
                color: AppColors.grey500,
              ),
            ),
          );
        }
        return ListView.builder(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.s,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          itemCount: searchVehicles.length,
          itemBuilder: (_, index) {
            return Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.s),
              child: _VehicleCard(
                vehicle: searchVehicles[index],
                bidIncrementAmount: ctrl.bidIncrementAmount,
                controller: ctrl,
                isUpcoming: false,
              ),
            );
          },
        );
      }

      // Show normal tab content
      if (ctrl.tabLoading(tabIndex).value) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        );
      }
      final error = ctrl.tabError(tabIndex).value;
      if (error.isNotEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.md),
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
              fontSize: 12.sp,
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
          AppSpacing.s,
          AppSpacing.md,
          AppSpacing.sm,
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
            padding: EdgeInsets.only(bottom: AppSpacing.s),
            child: _VehicleCard(
              vehicle: vehicles[index],
              bidIncrementAmount: ctrl.bidIncrementAmount,
              controller: ctrl,
              isUpcoming: tabIndex == 2,
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
  final bool isUpcoming;

  const _VehicleCard({
    required this.vehicle,
    required this.bidIncrementAmount,
    required this.controller,
    this.isUpcoming = false,
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
    final bool isUpcoming = widget.isUpcoming;

    final cardBorderColor = isUpcoming
        ? AppColors.grey300
        : isWinning
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
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            spreadRadius: 0,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─────────────────────────────────────────────────
              // ROW 1: Image | Make · Reg · See More
              // ─────────────────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image panel
                  SizedBox(
                    width: 135.w,
                    height: 108.h,
                    child: Stack(
                      fit: StackFit.expand,
                      clipBehavior: Clip.none,
                      children: [
                        NetworkImageCarousel(
                          imageUrls: v.images,
                          height: 108.h,
                        ),
                        // Timer badge — top-left, arrow notch points right
                        Positioned(
                          top: 4.h,
                          left: 0,
                          child: ExcludeSemantics(
                            child: TimerBadge(
                              endAt: v.auctionEndDate,
                              mirrored: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Right panel
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(10.w, 8.h, 10.w, 8.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Make + Model
                          Text(
                            '${v.make} ${v.model}',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2.h),
                          // Reg · Year
                          Text(
                            '${v.registrationNo}  ·  ${v.year}',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 11.sp,
                              color: AppColors.grey600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          // See More / Less pill
                          GestureDetector(
                            onTap: () => setState(() => _expanded = !_expanded),
                            child: Container(
                              constraints: BoxConstraints(minHeight: 26.h),
                              padding: EdgeInsets.symmetric(horizontal: 10.w),
                              margin: EdgeInsets.only(left: 30.w, top: 10.h),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1.0,
                                  color: AppColors.grey400,
                                ),
                                borderRadius: BorderRadius.circular(13.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      _expanded
                                          ? context.l10n.aucSeeLess
                                          : context.l10n.seeMore,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.black,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 3.w),
                                  Icon(
                                    _expanded
                                        ? Icons.keyboard_arrow_up_rounded
                                        : Icons.keyboard_arrow_down_rounded,
                                    size: 16.r,
                                    color: AppColors.black,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: 12.h),

                          // Remarks row — always visible
                          Center(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 8.sp,
                                  color: AppColors.grey700,
                                ),
                                children: [
                                  if (hasBid)
                                    TextSpan(
                                      text: isWinning
                                          ? context.l10n.aucYouAreWinning
                                          : context.l10n.aucYouAreLosing,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: isWinning
                                            ? const Color(0xFF2E7D32)
                                            : const Color(0xFFC62828),
                                      ),
                                    )
                                  else
                                    TextSpan(
                                      text: context.l10n
                                          .aucStartBiddingStartPrice(
                                            _fmt(v.minimumPrice),
                                          ),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.secondary,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // ─────────────────────────────────────────────────
              // EXPANDED DETAILS
              // ─────────────────────────────────────────────────
              if (_expanded)
                Padding(
                  padding: EdgeInsets.fromLTRB(12.w, 4.h, 12.w, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _OptGridRow(
                        context.l10n.rc_availability,
                        v.rcAvailability,
                        context.l10n.repo_date,
                        v.repoDate,
                      ),
                      _OptGridRow(
                        context.l10n.chassis_no,
                        v.chassisNo,
                        context.l10n.engine_no,
                        v.engineNo,
                      ),
                      _OptGridRow(
                        context.l10n.registered_rto,
                        v.registeredRto,
                        context.l10n.transmission,
                        v.transmission,
                      ),
                      _OptGridRow(
                        context.l10n.variant,
                        v.variant,
                        context.l10n.colour,
                        v.colour,
                      ),
                      _OptGridRow(
                        context.l10n.fuel_type,
                        v.fuelType,
                        context.l10n.owner,
                        v.owner,
                      ),
                      _OptGridRow(
                        context.l10n.aucContactPerson,
                        v.contactPersonName,
                        context.l10n.aucMobile,
                        v.contactPersonNumber,
                      ),
                      // _OptGridRow(
                      //   context.l10n.start_price,
                      //   '₹ ${_fmt(v.minimumPrice)}',
                      //   context.l10n.aucHighestBid,
                      //   v.currentHighestBid != null
                      //       ? '₹ ${_fmt(v.currentHighestBid!)}'
                      //       : context.l10n.aucNoBids,
                      // ),
                      _OptGridRow(
                        context.l10n.parking_charges,
                        v.parkingCharges,
                        context.l10n.transaction_fees,
                        v.transactionFees,
                      ),
                      _OptGridRow(
                        context.l10n.yard_name,
                        v.yardName,
                        context.l10n.yard_location,
                        v.yardLocation,
                      ),
                      if (v.remarks.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(bottom: 6.h),
                          child: _Cell(
                            label: context.l10n.remarks,
                            value: v.remarks,
                          ),
                        ),
                      SizedBox(height: 4.h),
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
                            Flexible(
                              child: Text(
                                '${context.l10n.availableBuyingLimit}: ',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 12.sp,
                                  color: AppColors.grey600,
                                ),
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
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Expanded(
                            child: _BidChip(
                              label: context.l10n.your_bid,
                              value: v.yourBid > 0
                                  ? '₹ ${_fmt(v.yourBid)}'
                                  : '₹ 0',
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: _BidChip(
                              label: context.l10n.bids_left,
                              value: v.bidsLeft.toString(),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: _BidChip(
                              label: context.l10n.aucBids,
                              value: v.bidsReceived.toString(),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                    ],
                  ),
                ),

              // Start Price + Highest Bid — shown only when expanded
              if (_expanded)
                Padding(
                  padding: EdgeInsets.fromLTRB(10.w, 4.h, 10.w, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _BidChip(
                          label: context.l10n.start_price,
                          value: '₹ ${_fmt(v.minimumPrice)}',
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: _BidChip(
                          label: context.l10n.aucHighestBid,
                          value: (v.currentHighestBid ?? 0) > 0
                              ? '₹ ${_fmt(v.currentHighestBid!)}'
                              : context.l10n.aucNoBids,
                        ),
                      ),
                    ],
                  ),
                ),

              // ─────────────────────────────────────────────────
              // BID ROW + REMARKS — hidden for upcoming auctions
              // ─────────────────────────────────────────────────
              if (isUpcoming)
                Padding(
                  padding: EdgeInsets.fromLTRB(10.w, 6.h, 10.w, 10.h),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    decoration: BoxDecoration(
                      color: AppColors.grey100,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: AppColors.grey300),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 14.r,
                          color: AppColors.grey600,
                        ),
                        SizedBox(width: 6.w),
                        Flexible(
                          child: Text(
                            context.l10n.aucUpcomingBiddingNotStarted,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.grey600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else ...[
                // BID ROW: ⊖  ₹ amount  ⊕   |   PLACE BID
                Padding(
                  padding: EdgeInsets.fromLTRB(10.w, 6.h, 10.w, 4.h),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 30.h,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.grey300,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(19.r),
                          ),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: _decreaseBid,
                                behavior: HitTestBehavior.opaque,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                  ),
                                  child: Icon(
                                    Icons.remove_circle_outline_rounded,
                                    size: 20.r,
                                    color: AppColors.grey700,
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
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.black,
                                  ),
                                  decoration: InputDecoration(
                                    prefixText: '₹ ',
                                    prefixStyle: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 13.sp,
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
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                  ),
                                  child: Icon(
                                    Icons.add_circle_outline_rounded,
                                    size: 20.r,
                                    color: AppColors.grey700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Flexible(
                        child: GestureDetector(
                          onTap: _isPlacingBid
                              ? null
                              : () => _placeBid(context),
                          child: Container(
                            constraints: BoxConstraints(minHeight: 28.h),
                            padding: EdgeInsets.symmetric(horizontal: 14.w),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: _isPlacingBid
                                    ? [
                                        const Color(0xFFAA5555),
                                        const Color(0xFF884444),
                                      ]
                                    : [
                                        AppColors.ctaGradientStart,
                                        AppColors.ctaGradientEnd,
                                      ],
                              ),
                              borderRadius: BorderRadius.circular(19.r),
                            ),
                            alignment: Alignment.center,
                            child: _isPlacingBid
                                ? SizedBox(
                                    width: 18.r,
                                    height: 18.r,
                                    child: const CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      context.l10n.placeBid.toUpperCase(),
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ], // end else (upcoming guard)
            ],
          ),
          // Wishlist heart button — top right of card
          Positioned(
            top: 8.h,
            right: 8.w,
            child: WishlistButton(
              isWishlisted: v.isWishlisted,
              onTap: () => widget.controller.toggleWishlist(v),
              size: 32.r,
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
        message: appL10n.bidPlacedSuccessfully,
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
// Filter bottom sheet: Vehicle Type, Category, State (no Region)
// Using custom InlineDropdownField for better UX
// ─────────────────────────────────────────────────────────────────────────────

class AuctionFilterBottomSheetV2 extends StatelessWidget {
  final VehicleListingController ctrl;
  const AuctionFilterBottomSheetV2({super.key, required this.ctrl});

  static Future<void> show(
    BuildContext context,
    VehicleListingController ctrl,
  ) {
    ctrl.backupCurrentFilters();
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
      height: MediaQuery.of(context).size.height * 0.55,
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
                Expanded(
                  child: Text(
                    context.l10n.filterAuctions,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
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
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category
                  _FilterLabel(
                    label: context.l10n.category,
                    icon: Icons.category_outlined,
                  ),
                  SizedBox(height: 8.h),
                  Obx(() {
                    final categories = ctrl.categories;
                    final isLoading = ctrl.isLoadingCategories.value;
                    return InlineDropdownField<String>(
                      value: ctrl.selectedCategory.value,
                      items: categories
                          .map((cat) => cat['value'] ?? '')
                          .where((v) => v.isNotEmpty)
                          .toList(),
                      placeholder: context.l10n.aucAllCategories,
                      prefixIcon: Icons.category_outlined,
                      isLoading: isLoading,
                      itemLabel: (v) {
                        final cat = categories.firstWhere(
                          (c) => c['value'] == v,
                          orElse: () => {'label': v},
                        );
                        return cat['label'] ?? v;
                      },
                      onChanged: (val) => ctrl.selectedCategory.value = val,
                      maxDropdownHeight: 200,
                    );
                  }),
                  SizedBox(height: 20.h),

                  // State
                  _FilterLabel(
                    label: context.l10n.state,
                    icon: Icons.location_city_outlined,
                  ),
                  SizedBox(height: 8.h),
                  Obx(() {
                    final states = ctrl.statesByRegion;
                    final isLoading = ctrl.isLoadingStatesByRegion.value;
                    return InlineDropdownField<StateByRegionEntity>(
                      value: ctrl.selectedState.value,
                      items: states,
                      placeholder: context.l10n.aucAllStates,
                      prefixIcon: Icons.location_city_outlined,
                      isLoading: isLoading,
                      itemLabel: (s) => s.stateName,
                      onChanged: (val) => ctrl.selectedState.value = val,
                      maxDropdownHeight: 220,
                    );
                  }),
                ],
              ),
            ),
          ),
          // Apply / Cancel buttons
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
            child: Row(
              children: [
                Expanded(
                  child: GradientButton.outlined(
                    text: context.l10n.cancel,
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
                    text: context.l10n.aucApply,
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

// ─── Filter Label Helper ─────────────────────────────────────────────────────

class _FilterLabel extends StatelessWidget {
  final String label;
  final IconData icon;
  const _FilterLabel({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16.r, color: AppColors.primary),
        SizedBox(width: 6.w),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.grey900,
            ),
          ),
        ),
      ],
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
      constraints: BoxConstraints(minHeight: 36.h),
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
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 10.sp,
              color: AppColors.grey500,
            ),
          ),

          Text(
            value,
            textAlign: TextAlign.center,
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
