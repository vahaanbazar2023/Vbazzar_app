import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/atoms/custom_loader.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/design_system/molecules/custom_snackbar.dart';
import '../../../core/design_system/organisms/network_image_carousel.dart';
import '../../../core/design_system/templates/app_layout.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/extensions/context_extensions.dart';
import '../controllers/my_bids_wins_controller.dart';
import '../models/my_bids_wins_models.dart';
import '../../../core/design_system/molecules/timer_badge.dart';
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
          return const Center(child: CustomLoader());
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
// Bid card — matches auction vehicle listing card layout
// ─────────────────────────────────────────────────────────────────────────────

class _BidCard extends StatefulWidget {
  final MyBidItem item;
  const _BidCard({required this.item});

  @override
  State<_BidCard> createState() => _BidCardState();
}

class _BidCardState extends State<_BidCard> {
  bool _expanded = false;
  bool _isPlacing = false;
  late int _bidAmount;
  late TextEditingController _bidCtrl;

  @override
  void initState() {
    super.initState();
    final v = widget.item.vehicleDetails;
    _bidAmount = v.minimumNextBid ?? v.minimumPrice;
    _bidCtrl = TextEditingController(text: _fmt(_bidAmount));
  }

  @override
  void dispose() {
    _bidCtrl.dispose();
    super.dispose();
  }

  int get _increment {
    final v = widget.item.vehicleDetails;
    if ((v.bidIncrementAmount ?? 0) > 0) return v.bidIncrementAmount!;
    return 5000;
  }

  void _decrease() {
    final v = widget.item.vehicleDetails;
    final min = v.minimumNextBid ?? v.minimumPrice;
    final next = _bidAmount - _increment;
    if (next >= min) {
      setState(() {
        _bidAmount = next;
        _bidCtrl.text = _fmt(_bidAmount);
      });
    }
  }

  void _increase() {
    setState(() {
      _bidAmount += _increment;
      _bidCtrl.text = _fmt(_bidAmount);
    });
  }

  Future<void> _placeBid() async {
    setState(() => _isPlacing = true);
    final ctrl = Get.find<MyBidsController>();
    final error = await ctrl.placeBid(
      bidItem: widget.item,
      bidAmount: _bidAmount,
    );
    if (mounted) setState(() => _isPlacing = false);
    if (error != null && error != '__navigated__') {
      CustomSnackbar.show(message: error, type: SnackbarType.error);
    } else if (error == null) {
      CustomSnackbar.show(
        message: appL10n.bidPlacedSuccessfully,
        type: SnackbarType.success,
      );
    }
  }

  Color get _statusColor {
    switch (widget.item.bidStatus.toLowerCase()) {
      case 'approved':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      case 'pending':
        return AppColors.warning;
      case 'won':
        return AppColors.success;
      case 'lost':
        return AppColors.error;
      default:
        return AppColors.grey600;
    }
  }

  String get _statusLabel {
    switch (widget.item.bidStatus.toLowerCase()) {
      case 'approved':
        return context.l10n.aucWinning;
      case 'rejected':
        return context.l10n.aucOutbid;
      case 'pending':
        return context.l10n.pendingStatus;
      case 'won':
        return context.l10n.aucStatusWon;
      case 'lost':
        return context.l10n.aucStatusLost;
      default:
        final s = widget.item.bidStatus;
        return s.isEmpty ? '—' : '${s[0].toUpperCase()}${s.substring(1)}';
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

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final v = item.vehicleDetails;
    final isClosed = item.isEnded;

    // Winning / Losing status.
    // While the auction is live we compare the user's bid to the current
    // highest. Once it has ended we trust the server's bid status
    // (approved = won/leading, rejected = outbid). The chip is hidden for
    // ended auctions with no decisive status.
    final bool hasBid = item.yourBid > 0;
    final String status = item.bidStatus.toLowerCase();
    final bool isWinning = isClosed
        ? (status == 'approved' || status == 'won')
        : hasBid &&
              (item.currentHighestBid <= 0 ||
                  item.yourBid >= item.currentHighestBid);
    final bool isLosing = isClosed
        ? (status == 'rejected' || status == 'lost')
        : hasBid && !isWinning;
    final bool showBidChip = hasBid && (isWinning || isLosing);

    final cardBorderColor = isWinning
        ? const Color(0xFF2E7D32)
        : isLosing
        ? const Color(0xFFC62828)
        : AppColors.grey200;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: cardBorderColor,
          width: showBidChip ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ════════════════════════════════════════════════
          // ROW 1: image (171w×99h) + title/timer/status
          // ════════════════════════════════════════════════
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
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
                    // VEH ID bar at bottom
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        color: AppColors.primary,
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 3.h,
                        ),
                        child: Text(
                          v.vehicleId,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    // Winning/Losing chip — same as auction listing card
                    if (showBidChip)
                      Positioned(
                        top: 6.h,
                        left: 6.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 7.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: isWinning
                                ? const Color(0xFF2E7D32)
                                : const Color(0xFFC62828),
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
                              Flexible(
                                child: Text(
                                  isWinning
                                      ? context.l10n.aucWinning
                                      : context.l10n.aucLosing,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    // Closed overlay — top-right
                    if (isClosed)
                      Positioned(
                        top: 6.h,
                        right: 6.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 7.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            context.l10n.closedBadge,
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Right panel
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 10.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Make + Model
                      Text(
                        '${v.make} ${v.model}'.trim().isEmpty
                            ? item.auctionTitle
                            : '${v.make} ${v.model}',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.h),
                      // Reg No · Year
                      if (v.registrationNo.isNotEmpty)
                        Text(
                          '${v.registrationNo}  ·  ${v.year}',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 11.sp,
                            color: AppColors.grey600,
                          ),
                        ),
                      SizedBox(height: 6.h),
                      // Timer or Closed
                      if (!isClosed)
                        TimerBadge(endAt: item.auctionEndTime)
                      else
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.grey200,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            context.l10n.auctionClosed,
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.grey600,
                            ),
                          ),
                        ),
                      SizedBox(height: 6.h),
                      // Status badge
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          _statusLabel,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: _statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ════════════════════════════════════════════════
          // ROW 2: always-visible 2-col grid
          // Yard Name | Yard Location  /  Auction ID | Vehicle ID
          // ════════════════════════════════════════════════
          Padding(
            padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 0),
            child: Column(
              children: [
                if (!_expanded) ...[
                  _GRow(
                    context.l10n.yard_name,
                    v.yardName,
                    context.l10n.yard_location,
                    v.yardLocation,
                    single: true,
                  ),
                  SizedBox(height: 6.h),
                ],
                _GRow(
                  context.l10n.auction_id,
                  item.auctionId,
                  context.l10n.vehicle_id,
                  v.vehicleId,
                  single: true,
                ),
                SizedBox(height: 6.h),
                // Always-visible bid summary
                _GRow(
                  context.l10n.your_bid,
                  v.yourBid > 0 ? '₹ ${_fmt(v.yourBid)}' : '₹ 0',
                  context.l10n.aucHighestBid,
                  item.currentHighestBid > 0
                      ? '₹ ${_fmt(item.currentHighestBid)}'
                      : context.l10n.aucNoBids,
                ),
              ],
            ),
          ),

          // ════════════════════════════════════════════════
          // EXPANDED DETAILS
          // ════════════════════════════════════════════════
          if (_expanded)
            Padding(
              padding: EdgeInsets.fromLTRB(12.w, 6.h, 12.w, 0),
              child: Column(
                children: [
                  _OptRow(
                    context.l10n.rc_availability,
                    v.rcAvailability,
                    context.l10n.repo_date,
                    v.repoDate,
                  ),
                  _OptRow(
                    context.l10n.chassis_no,
                    v.chassisNo,
                    context.l10n.engine_no,
                    v.engineNo,
                  ),
                  _OptRow(
                    context.l10n.registered_rto,
                    v.registeredRto,
                    context.l10n.transmission,
                    v.transmission,
                  ),
                  _OptRow(
                    context.l10n.variant,
                    v.variant,
                    context.l10n.colour,
                    v.colour,
                  ),
                  _OptRow(
                    context.l10n.fuel_type,
                    v.fuelType,
                    context.l10n.owner,
                    v.owner,
                  ),
                  _OptRow(
                    context.l10n.aucContactPerson,
                    v.contactPersonName,
                    context.l10n.aucMobile,
                    v.contactPersonNumber,
                  ),
                  _OptRow(
                    context.l10n.start_price,
                    '₹ ${_fmt(v.minimumPrice)}',
                    context.l10n.market_value,
                    v.marketValue.isNotEmpty ? '₹ ${v.marketValue}' : '',
                  ),
                  _OptRow(
                    context.l10n.parking_charges,
                    v.parkingCharges,
                    context.l10n.transaction_fees,
                    v.transactionFees,
                  ),
                  _OptRow(
                    context.l10n.yard_name,
                    v.yardName,
                    context.l10n.yard_location,
                    v.yardLocation,
                  ),
                  if (v.remarks.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(bottom: 6.h),
                      child: _GCell(
                        label: context.l10n.remarks,
                        value: v.remarks,
                      ),
                    ),
                  // Bid placed + count info
                  SizedBox(height: 4.h),
                  _GRow(
                    context.l10n.aucBidsPlaced,
                    item.userBidCount.toString(),
                    context.l10n.bids_left,
                    v.bidsLeft.toString(),
                  ),
                  SizedBox(height: 4.h),
                  if (v.availableBalance > 0)
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
                  SizedBox(height: 4.h),
                ],
              ),
            ),

          // ════════════════════════════════════════════════
          // Details / See Less toggle
          // ════════════════════════════════════════════════
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            child: GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Row(
                children: [
                  Expanded(
                    child: Divider(color: AppColors.grey300, thickness: 1),
                  ),
                  SizedBox(width: 8.w),
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            _expanded
                                ? context.l10n.aucSeeLess
                                : context.l10n.aucDetails,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.grey700,
                            ),
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
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Divider(color: AppColors.grey300, thickness: 1),
                  ),
                ],
              ),
            ),
          ),

          // ════════════════════════════════════════════════
          // BID ROW (active) or CLOSED bar
          // ════════════════════════════════════════════════
          Padding(
            padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
            child: isClosed
                ? Container(
                    width: double.infinity,
                    constraints: BoxConstraints(minHeight: 42.h),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.grey200,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      context.l10n.auctionClosed,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                        fontSize: 13.sp,
                        color: AppColors.grey600,
                      ),
                    ),
                  )
                : Row(
                    children: [
                      // [- ₹ amount +]
                      Expanded(
                        child: Container(
                          height: 42.h,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.grey300),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Row(
                            children: [
                              SizedBox(width: 4.w),
                              GestureDetector(
                                onTap: _decrease,
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  width: 30.r,
                                  height: 30.h,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.grey400,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.remove_rounded,
                                    size: 18.r,
                                    color: AppColors.grey700,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: _bidCtrl,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  onChanged: (raw) {
                                    final parsed = int.tryParse(
                                      raw.replaceAll(',', ''),
                                    );
                                    if (parsed != null) _bidAmount = parsed;
                                  },
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
                                onTap: _increase,
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  width: 30.r,
                                  height: 30.h,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.grey400,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.add_rounded,
                                    size: 18.r,
                                    color: AppColors.grey700,
                                  ),
                                ),
                              ),
                              SizedBox(width: 4.w),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      // PLACE BID
                      Flexible(
                        child: GestureDetector(
                          onTap: _isPlacing ? null : _placeBid,
                          child: Container(
                            constraints: BoxConstraints(minHeight: 32.h),
                            padding: EdgeInsets.symmetric(horizontal: 18.w),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: _isPlacing
                                    ? [
                                        const Color(0xFFAA5555),
                                        const Color(0xFF884444),
                                      ]
                                    : [
                                        AppColors.ctaGradientStart,
                                        AppColors.ctaGradientEnd,
                                      ],
                              ),
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            alignment: Alignment.center,
                            child: _isPlacing
                                ? SizedBox(
                                    width: 16.r,
                                    height: 16.r,
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
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),

          // View Details button
          Padding(
            padding: EdgeInsets.only(left: 12.w, right: 12.w, bottom: 12.h),
            child: GestureDetector(
              onTap: () => Get.to(() => MyBidDetailView(item: item)),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Text(
                  context.l10n.aucViewFullDetails,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12.sp,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Grid helpers (2-col row)
// ─────────────────────────────────────────────────────────────────────────────

class _GRow extends StatelessWidget {
  final String l1, v1, l2, v2;
  final bool single;
  const _GRow(this.l1, this.v1, this.l2, this.v2, {this.single = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _GCell(label: l1, value: v1, singleLine: single),
        ),
        SizedBox(width: 6.w),
        if (l2.isNotEmpty)
          Expanded(
            child: _GCell(label: l2, value: v2, singleLine: single),
          )
        else
          const Expanded(child: SizedBox()),
      ],
    );
  }
}

// Optional row — hidden if both values are blank/zero
class _OptRow extends StatelessWidget {
  final String l1, v1, l2, v2;
  const _OptRow(this.l1, this.v1, this.l2, this.v2);

  static bool _empty(String v) {
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
    if (_empty(v1) && (l2.isEmpty || _empty(v2)))
      return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        children: [
          if (!_empty(v1))
            Expanded(
              child: _GCell(label: l1, value: v1),
            )
          else
            const Expanded(child: SizedBox()),
          SizedBox(width: 6.w),
          if (l2.isNotEmpty && !_empty(v2))
            Expanded(
              child: _GCell(label: l2, value: v2),
            )
          else
            const Expanded(child: SizedBox()),
        ],
      ),
    );
  }
}

class _GCell extends StatelessWidget {
  final String label;
  final String value;
  final bool singleLine;
  const _GCell({
    required this.label,
    required this.value,
    this.singleLine = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 9.sp,
              color: AppColors.grey500,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            value.isNotEmpty ? value : '—',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.grey800,
            ),
            maxLines: singleLine ? 1 : 2,
            overflow: TextOverflow.ellipsis,
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
                fontFamily: 'Montserrat',
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
                fontFamily: 'Montserrat',
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
