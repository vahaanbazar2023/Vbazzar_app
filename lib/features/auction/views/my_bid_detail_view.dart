import 'package:flutter/material.dart';
import 'dart:ui';

import 'package:flutter/services.dart';
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

class MyBidDetailView extends StatefulWidget {
  final MyBidItem item;
  const MyBidDetailView({super.key, required this.item});

  @override
  State<MyBidDetailView> createState() => _MyBidDetailViewState();
}

class _MyBidDetailViewState extends State<MyBidDetailView> {
  int? _bidAmountOverride;
  TextEditingController? _bidCtrlOverride;
  String? _errorText;

  int get _bidAmount {
    if (_bidAmountOverride != null) return _bidAmountOverride!;
    final v = widget.item.vehicleDetails;
    return v.minimumNextBid ?? v.minimumPrice;
  }

  TextEditingController get _bidCtrl {
    _bidCtrlOverride ??= TextEditingController(text: _fmt(_bidAmount));
    return _bidCtrlOverride!;
  }

  @override
  void dispose() {
    _bidCtrlOverride?.dispose();
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
        _bidAmountOverride = next;
        _bidCtrl.text = _fmt(next);
        _errorText = null;
      });
    }
  }

  void _increase() {
    final next = _bidAmount + _increment;
    setState(() {
      _bidAmountOverride = next;
      _bidCtrl.text = _fmt(next);
      _errorText = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final v = item.vehicleDetails;
    final isClosed = item.isEnded;

    // Winning / Losing status.
    // Live auctions compare the user's bid to the current highest; ended
    // auctions trust the server's bid status. The chip is hidden when there's
    // no decisive result on an ended auction.
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

    return AppLayout(
      title: context.l10n.bidDetails,
      subtitle: '${context.l10n.auction_id}: ${item.auctionId}',
      showBack: true,
      body: Column(
        children: [
          // ── Scrollable content ──────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Image carousel ──────────────────────────────────────
                  ClipRRect(
                    borderRadius: AppRadius.borderRadiusMd,
                    child: Stack(
                      children: [
                        NetworkImageCarousel(
                          imageUrls: v.images,
                          height: 200.h,
                        ),
                        // Winning/Losing chip — same as auction listing card
                        if (showBidChip)
                          Positioned(
                            top: 10.h,
                            left: 10.w,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12.r),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 10,
                                  sigmaY: 10,
                                ),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 9.w,
                                    vertical: 4.h,
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
                                        size: 13.r,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 4.w),
                                      Text(
                                        isWinning ? 'Winning' : 'Losing',
                                        style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontSize: 11.sp,
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
                  SizedBox(height: AppSpacing.sm),

                  // ── Vehicle title ───────────────────────────────────────
                  Center(
                    child: Text(
                      '${v.make} | ${v.model}',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      margin: EdgeInsets.only(top: 5.h, bottom: AppSpacing.sm),
                      height: 3.h,
                      width: 55.w,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),

                  // ── 2×2 info boxes ──────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: _InfoBox(
                            icon: Icons.gavel_rounded,
                            label: context.l10n.auction_id,
                            value: item.auctionId,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: _InfoBox(
                            icon: Icons.description_outlined,
                            label: context.l10n.vehicleRef,
                            value: v.sellerReference.isNotEmpty
                                ? v.sellerReference
                                : v.vehicleId,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: _InfoBox(
                            icon: Icons.badge_outlined,
                            label: context.l10n.regNumber,
                            value: v.registrationNo.isNotEmpty
                                ? v.registrationNo
                                : 'N/A',
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: _InfoBox(
                            icon: Icons.calendar_today_outlined,
                            label: context.l10n.endTime,
                            value: item.auctionEndTime.isNotEmpty
                                ? item.auctionEndTime
                                : 'N/A',
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),

                  // ── Bid summary card ────────────────────────────────────
                  _SectionCard(
                    children: [
                      _BidRow(
                        label: context.l10n.your_bid,
                        value: '₹ ${_fmt(item.userBidAmount)}',
                      ),
                      _BidRow(
                        label: context.l10n.currentHighest,
                        value: '₹ ${_fmt(item.currentHighestBid)}',
                      ),
                      _BidRow(
                        label: context.l10n.bids_left,
                        value: v.bidsLeft.toString().padLeft(2, '0'),
                      ),
                      _BidRow(
                        label: context.l10n.bids_received,
                        value: v.bidsReceived.toString().padLeft(2, '0'),
                      ),
                      _BidRow(
                        label: context.l10n.status,
                        value: _capitalize(item.bidStatus),
                        valueColor: _statusColor(item.bidStatus),
                      ),
                      _BidRow(
                        label: context.l10n.placedAt,
                        value: item.bidPlacedAt.isNotEmpty
                            ? item.bidPlacedAt
                            : 'N/A',
                        isLast: true,
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.md),

                  // ── Vehicle details accordion ───────────────────────────
                  _VehicleAccordion(v: v),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),

          // ── Fixed bottom ────────────────────────────────────────────────
          Container(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border(top: BorderSide(color: AppColors.grey200)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0x14000000),
                  blurRadius: 12,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_errorText != null) ...[
                  Text(
                    _errorText!,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 11.sp,
                      color: AppColors.error,
                    ),
                  ),
                  SizedBox(height: 6.h),
                ],
                isClosed
                    ? Container(
                        width: double.infinity,
                        height: 48.h,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.grey200,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          context.l10n.auctionClosed,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                            fontSize: 15.sp,
                            color: AppColors.grey600,
                          ),
                        ),
                      )
                    : Row(
                        children: [
                          // [- ₹ amount +]
                          Expanded(
                            child: Container(
                              height: 48.h,
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.grey300),
                                borderRadius: BorderRadius.circular(10.r),
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
                                        size: 20.r,
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
                                        if (parsed != null) {
                                          _bidAmountOverride = parsed;
                                          if (_errorText != null) {
                                            setState(() => _errorText = null);
                                          }
                                        }
                                      },
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.black,
                                      ),
                                      decoration: InputDecoration(
                                        prefixText: '₹  ',
                                        prefixStyle: TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontSize: 15.sp,
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
                                        size: 20.r,
                                        color: AppColors.grey700,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 4.w),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: AppSpacing.sm),
                          // PLACE BID
                          Obx(() {
                            final ctrl = Get.find<MyBidsController>();
                            final loading = ctrl.isPlacingBid.value;
                            return GestureDetector(
                              onTap: loading ? null : () => _onBidNow(ctrl),
                              child: Container(
                                height: 48.h,
                                padding: EdgeInsets.symmetric(horizontal: 18.w),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: loading
                                        ? [
                                            const Color(0xFFAA5555),
                                            const Color(0xFF884444),
                                          ]
                                        : [
                                            AppColors.ctaGradientStart,
                                            AppColors.ctaGradientEnd,
                                          ],
                                  ),
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                alignment: Alignment.center,
                                child: loading
                                    ? SizedBox(
                                        width: 18.r,
                                        height: 18.r,
                                        child: const CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        'PLACE BID',
                                        style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                              ),
                            );
                          }),
                        ],
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onBidNow(MyBidsController ctrl) async {
    if (_bidAmount <= 0) {
      setState(() => _errorText = context.l10n.enterValidBidAmount);
      return;
    }
    setState(() => _errorText = null);
    final error = await ctrl.placeBid(
      bidItem: widget.item,
      bidAmount: _bidAmount,
    );
    if (!mounted) return;
    if (error == '__navigated__') {
      // navigated away
    } else if (error != null) {
      setState(() => _errorText = error);
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

  String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
}

// ─────────────────────────────────────────────────────────────────────────────
// Bid amount input field
// ─────────────────────────────────────────────────────────────────────────────

class _BidAmountField extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  const _BidAmountField({
    required this.controller,
    this.errorText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.full);
    return SizedBox(
      height: 48.h,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        textAlignVertical: TextAlignVertical.center,
        onChanged: onChanged,
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.black,
        ),
        decoration: InputDecoration(
          prefixText: '₹ ',
          prefixStyle: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
          hintText: context.l10n.enterBidHint,
          hintStyle: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 13.sp,
            color: AppColors.grey400,
          ),
          errorText: errorText,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 12.h,
          ),
          isDense: true,
          filled: true,
          fillColor: AppColors.grey50,
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
          errorBorder: OutlineInputBorder(
            borderRadius: radius,
            borderSide: const BorderSide(color: AppColors.error),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Info box (2×2 grid)
// ─────────────────────────────────────────────────────────────────────────────

class _InfoBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoBox({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.r, 12.r, 12.r, 16.r),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20.r, color: AppColors.grey600),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 10.sp,
              color: AppColors.grey500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section card
// ─────────────────────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final List<Widget> children;
  const _SectionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
      child: Column(children: children),
    );
  }
}

class _BidRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;
  final Color? valueColor;
  const _BidRow({
    required this.label,
    required this.value,
    this.isLast = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 11.h,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$label :',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 13.sp,
                  color: AppColors.grey700,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? AppColors.black,
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            thickness: 1,
            color: AppColors.grey100,
            indent: AppSpacing.md,
            endIndent: AppSpacing.md,
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Vehicle accordion — same as auction detail screen
// ─────────────────────────────────────────────────────────────────────────────

class _VehicleAccordion extends StatefulWidget {
  final dynamic v; // VehicleListing
  const _VehicleAccordion({required this.v});

  @override
  State<_VehicleAccordion> createState() => _VehicleAccordionState();
}

class _VehicleAccordionState extends State<_VehicleAccordion> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final v = widget.v;
    return Container(
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
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 14.h,
              ),
              color: _expanded
                  ? AppColors.lightOrange.withValues(alpha: 0.18)
                  : AppColors.white,
              child: Row(
                children: [
                  Icon(
                    Icons.directions_car_outlined,
                    size: 18.r,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      context.l10n.vehicleDetailsTitle,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 22.r,
                      color: AppColors.grey600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                Divider(height: 1, thickness: 1, color: AppColors.grey100),
                _DR(
                  Icons.directions_car_outlined,
                  context.l10n.makeAndModel,
                  '${v.make} ${v.model}',
                ),
                _DR(
                  Icons.build_circle_outlined,
                  context.l10n.variant,
                  v.variant.isNotEmpty ? v.variant : 'N/A',
                ),
                _DR(
                  Icons.date_range_outlined,
                  context.l10n.mfgYear,
                  v.year > 0 ? v.year.toString() : 'N/A',
                ),
                _DR(
                  Icons.color_lens_outlined,
                  context.l10n.colour,
                  v.colour.isNotEmpty ? v.colour : 'N/A',
                ),
                _DR(
                  Icons.speed_outlined,
                  context.l10n.kilometers,
                  v.kilometers > 0 ? '${v.kilometers} km' : 'N/A',
                ),
                _DR(
                  Icons.local_gas_station_outlined,
                  context.l10n.fuelType,
                  v.fuelType.isNotEmpty ? v.fuelType : 'N/A',
                ),
                _DR(
                  Icons.settings_outlined,
                  context.l10n.transmission,
                  v.transmission.isNotEmpty ? v.transmission : 'N/A',
                ),
                _DR(
                  Icons.person_outline_rounded,
                  context.l10n.owner,
                  v.owner.isNotEmpty ? v.owner : 'N/A',
                ),
                _DR(
                  Icons.confirmation_number_outlined,
                  context.l10n.chassisNumber,
                  v.chassisNo.isNotEmpty ? v.chassisNo : 'N/A',
                ),
                _DR(
                  Icons.memory_outlined,
                  context.l10n.engineNumber,
                  v.engineNo.isNotEmpty ? v.engineNo : 'N/A',
                ),
                _DR(
                  Icons.warehouse_outlined,
                  context.l10n.yard_name,
                  v.yardName.isNotEmpty ? v.yardName : 'N/A',
                ),
                _DR(
                  Icons.location_city_outlined,
                  context.l10n.yard_location,
                  v.yardLocation.isNotEmpty ? v.yardLocation : 'N/A',
                ),
                _DR(
                  Icons.notes_outlined,
                  context.l10n.remarks,
                  v.remarks.isNotEmpty ? v.remarks : 'N/A',
                  isLast: true,
                ),
              ],
            ),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 280),
          ),
        ],
      ),
    );
  }
}

class _DR extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;
  const _DR(this.icon, this.label, this.value, {this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 11.h,
          ),
          child: Row(
            children: [
              Icon(icon, size: 16.r, color: AppColors.grey500),
              SizedBox(width: 8.w),
              Expanded(
                flex: 2,
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 12.sp,
                    color: AppColors.grey600,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  value,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                  softWrap: true,
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            thickness: 1,
            color: AppColors.grey100,
            indent: AppSpacing.md,
            endIndent: AppSpacing.md,
          ),
      ],
    );
  }
}
