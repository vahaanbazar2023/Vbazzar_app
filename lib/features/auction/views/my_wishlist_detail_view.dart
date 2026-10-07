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
import '../controllers/vehicle_listing_controller.dart';
import '../models/vehicle_listing.dart';

class MyWishlistDetailView extends StatefulWidget {
  final VehicleListing vehicle;
  const MyWishlistDetailView({super.key, required this.vehicle});

  @override
  State<MyWishlistDetailView> createState() => _MyWishlistDetailViewState();
}

class _MyWishlistDetailViewState extends State<MyWishlistDetailView> {
  int? _bidAmountOverride;
  TextEditingController? _bidCtrlOverride;
  String? _errorText;

  int get _bidAmount {
    if (_bidAmountOverride != null) return _bidAmountOverride!;
    final v = widget.vehicle;
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
    final v = widget.vehicle;
    if ((v.bidIncrementAmount ?? 0) > 0) return v.bidIncrementAmount!;
    return 5000;
  }

  void _decrease() {
    final v = widget.vehicle;
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

  bool _isAuctionEnded(String auctionEndDate) {
    if (auctionEndDate.isEmpty) return false;
    try {
      final endDate = DateTime.parse(auctionEndDate);
      return endDate.isBefore(DateTime.now());
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.vehicle;
    final isClosed = _isAuctionEnded(v.auctionEndDate);

    // Winning / Losing status for wishlist
    final bool hasBid = v.yourBid > 0;
    final bool isWinning =
        hasBid &&
        ((v.currentHighestBid ?? 0) <= 0 ||
            v.yourBid >= (v.currentHighestBid ?? 0));
    final bool isLosing = hasBid && !isWinning;
    final bool showBidChip = hasBid && (isWinning || isLosing);

    return AppLayout(
      title: 'Wishlist Details',
      subtitle: '${context.l10n.auction_id}: ${v.auctionId}',
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
                        // Winning/Losing chip
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
                        // Wishlist heart icon
                        Positioned(
                          top: 10.h,
                          right: 10.w,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12.r),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 9.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withValues(
                                    alpha: 0.45,
                                  ),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Icon(
                                  Icons.favorite,
                                  size: 16.r,
                                  color: Colors.white,
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
                            value: v.auctionId,
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
                            value: v.auctionEndDate.isNotEmpty
                                ? v.auctionEndDate
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
                        value: '₹ ${_fmt(v.yourBid)}',
                      ),
                      _BidRow(
                        label: context.l10n.currentHighest,
                        value: '₹ ${_fmt(v.currentHighestBid ?? 0)}',
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
                        label: 'Status',
                        value: 'Wishlisted',
                        valueColor: AppColors.error,
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
                            final ctrl = Get.find<VehicleListingController>();
                            final loading = ctrl.isPlacingBid.value;
                            return GestureDetector(
                              onTap: loading ? null : () => _onBidNow(ctrl),
                              child: Container(
                                height: 32.h,
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
                                  borderRadius: BorderRadius.circular(16.r),
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

  Future<void> _onBidNow(VehicleListingController ctrl) async {
    if (_bidAmount <= 0) {
      setState(() => _errorText = context.l10n.enterValidBidAmount);
      return;
    }
    setState(() => _errorText = null);
    final error = await ctrl.placeBid(
      vehicle: widget.vehicle,
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
// Vehicle accordion — same as bid detail view
// ─────────────────────────────────────────────────────────────────────────────

class _VehicleAccordion extends StatefulWidget {
  final VehicleListing v;
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
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: AppRadius.borderRadiusMd,
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Vehicle Details',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.grey600,
                  ),
                ],
              ),
            ),
          ),
          // Expandable content
          if (_expanded)
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: Column(
                children: [
                  Divider(color: AppColors.grey200, height: 1),
                  SizedBox(height: AppSpacing.sm),
                  _DetailRow('Make', v.make),
                  _DetailRow('Model', v.model),
                  _DetailRow('Year', v.year.toString()),
                  _DetailRow('Variant', v.variant),
                  _DetailRow('Fuel Type', v.fuelType),
                  _DetailRow('Transmission', v.transmission),
                  _DetailRow('Colour', v.colour),
                  _DetailRow('Owner', v.owner),
                  _DetailRow('Chassis No', v.chassisNo),
                  _DetailRow('Engine No', v.engineNo),
                  _DetailRow('RC Availability', v.rcAvailability),
                  _DetailRow('Repo Date', v.repoDate),
                  _DetailRow('Registered RTO', v.registeredRto),
                  _DetailRow('Parking Charges', v.parkingCharges),
                  _DetailRow('Transaction Fees', v.transactionFees),
                  _DetailRow('Yard Name', v.yardName),
                  _DetailRow('Yard Location', v.yardLocation),
                  _DetailRow('Contact Person', v.contactPersonName),
                  _DetailRow('Mobile', v.contactPersonNumber),
                  if (v.remarks.isNotEmpty) _DetailRow('Remarks', v.remarks),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              '$label :',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 12.sp,
                color: AppColors.grey600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
