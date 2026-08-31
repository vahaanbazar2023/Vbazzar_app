import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/design_system/molecules/custom_snackbar.dart';
import '../../../core/design_system/templates/app_layout.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/extensions/context_extensions.dart';
import '../controllers/vehicle_listing_controller.dart';
import '../models/auction_listing.dart';
import '../models/vehicle_listing.dart';

class AuctionVehicleDetailScreen extends StatelessWidget {
  const AuctionVehicleDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final vehicle = args['vehicle'] as VehicleListing?;

    if (vehicle == null) {
      return AppLayout(
        title: context.l10n.placeBidTitle,
        showBack: true,
        body: const Center(child: Text('Vehicle not found')),
      );
    }

    final VehicleListing v = vehicle;
    final String endAt = args['endAt'] as String? ?? '';
    // Ensure controller is available — create standalone instance if not registered via binding
    final ctrl = Get.isRegistered<VehicleListingController>()
        ? Get.find<VehicleListingController>()
        : Get.put(
            VehicleListingController(
              auctionType: 'live_auctions',
              vehicleType: v.vehicleType.toLowerCase(),
              auctionTitle: '',
            ),
            tag: v.vehicleId,
          );

    debugPrint(
      '🎯 [BidDetail] ctrl=${ctrl.runtimeType}, vehicleId=${v.vehicleId}',
    );

    return AppLayout(
      title: context.l10n.placeBidTitle,
      subtitle: '${context.l10n.auction_id}: ${v.auctionId}',
      showBack: true,
      body: Column(
        children: [
          // ── Scrollable content ──────────────────────────────
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
                  // ── Image carousel ────────────────────────
                  ClipRRect(
                    borderRadius: AppRadius.borderRadiusMd,
                    child: Stack(
                      children: [
                        NetworkImageCarousel(
                          imageUrls: v.images,
                          height: 200.h,
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: TimerBadge(endAt: endAt),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm),

                  // ── Vehicle title ─────────────────────────
                  Center(
                    child: Text(
                      '${v.make} | ${v.model}',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
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

                  // ── 2×2 Info boxes ────────────────────────
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8),
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
                    padding: const EdgeInsets.only(left: 8.0, right: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: _InfoBox(
                            icon: Icons.app_registration_outlined,
                            label: context.l10n.registrationRto,
                            value: v.registeredRto.isNotEmpty
                                ? v.registeredRto
                                : context.l10n.na,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: _InfoBox(
                            icon: Icons.badge_outlined,
                            label: context.l10n.regNumber,
                            value: v.registrationNo.isNotEmpty
                                ? v.registrationNo
                                : context.l10n.na,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),

                  // ── Bid info — reactive: updates after each bid ───────
                  Obx(() {
                    // Find the freshest version of this vehicle from the
                    // controller's list; fall back to the initial snapshot.
                    final live =
                        ctrl.vehicles.firstWhereOrNull(
                          (x) => x.vehicleId == v.vehicleId,
                        ) ??
                        v;
                    return _SectionCard(
                      children: [
                        _BidInfoRow(
                          label: context.l10n.your_bid,
                          value: '₹ ${_formatPrice(live.yourBid)}',
                        ),
                        _BidInfoRow(
                          label: context.l10n.bids_left,
                          value: live.bidsLeft.toString().padLeft(2, '0'),
                        ),
                        _BidInfoRow(
                          label: context.l10n.bids_received,
                          value: live.bidsReceived.toString().padLeft(2, '0'),
                        ),
                        _BidInfoRow(
                          label: context.l10n.availableBuyingLimit,
                          value: '₹ ${_formatPrice(live.availableBalance)}',
                          isLast: true,
                        ),
                      ],
                    );
                  }),
                  SizedBox(height: AppSpacing.md),

                  // ── Vehicle Details accordion ─────────────
                  _VehicleDetailsAccordion(v: v),

                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),

          // ── Fixed bottom: price + bid button ───────────────
          Obx(() {
            final live =
                ctrl.vehicles.firstWhereOrNull(
                  (x) => x.vehicleId == v.vehicleId,
                ) ??
                v;
            return Container(
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          context.l10n.bidStartPrice,
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 11.sp,
                            color: AppColors.grey600,
                          ),
                        ),
                        Text(
                          '₹ ${_formatPrice(live.minimumPrice)}',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: GradientButton.filled(
                      text: context.l10n.bid_now,
                      isLoading: ctrl.isPlacingBid.value,
                      onPressed: ctrl.isPlacingBid.value
                          ? null
                          : () => _showBidDialog(context, live, ctrl),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  static String _formatPrice(int price) {
    if (price == 0) return '0';
    final s = price.toString();
    final buf = StringBuffer();
    int count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buf.write(',');
      buf.write(s[i]);
      count++;
    }
    return buf.toString().split('').reversed.join('');
  }

  static void _showBidDialog(
    BuildContext context,
    VehicleListing v,
    VehicleListingController ctrl,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BidSheet(vehicle: v, ctrl: ctrl),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bid placement bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

class _BidSheet extends StatefulWidget {
  final VehicleListing vehicle;
  final VehicleListingController ctrl;
  const _BidSheet({required this.vehicle, required this.ctrl});

  @override
  State<_BidSheet> createState() => _BidSheetState();
}

class _BidSheetState extends State<_BidSheet> {
  final _amountCtrl = TextEditingController();
  bool _isSubmitting = false;
  String? _errorText;

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
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

  Future<void> _submit() async {
    debugPrint('🔵 [BidSheet] _submit called, amount=${_amountCtrl.text}');
    final raw = _amountCtrl.text.replaceAll(',', '').trim();
    final amount = int.tryParse(raw);
    if (amount == null || amount <= 0) {
      setState(() => _errorText = context.l10n.enterValidBidAmount);
      return;
    }
    if (amount % 100 != 0) {
      setState(() => _errorText = context.l10n.bidMultipleOf100);
      return;
    }
    setState(() {
      _errorText = null;
      _isSubmitting = true;
    });

    final error = await widget.ctrl.placeBid(
      vehicle: widget.vehicle,
      bidAmount: amount,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (error == '__navigated__') {
      // Already navigated to subscription screen — just close sheet silently
      if (Navigator.of(context).canPop()) Navigator.of(context).pop();
    } else if (error == null) {
      // Genuine success
      if (Navigator.of(context).canPop()) Navigator.of(context).pop();
      CustomSnackbar.show(
        message: context.l10n.bidPlacedSuccessfully,
        type: SnackbarType.success,
      );
    } else {
      setState(() => _errorText = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.vehicle;
    final keyboardH = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardH),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.grey300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Title
                Text(
                  context.l10n.placeBid,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
                Text(
                  '${v.make} ${v.model} · ${v.registrationNo}',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 12.sp,
                    color: AppColors.grey500,
                  ),
                ),
                const SizedBox(height: 16),
                // Bid info strip
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.grey50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.grey200),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _BidInfoItem(
                          label: context.l10n.minBid,
                          value: '₹${_fmt(v.minimumPrice)}',
                        ),
                      ),
                      Container(width: 1, height: 32, color: AppColors.grey200),
                      Expanded(
                        child: _BidInfoItem(
                          label: context.l10n.bids_left,
                          value: v.bidsLeft.toString().padLeft(2, '0'),
                        ),
                      ),
                      Container(width: 1, height: 32, color: AppColors.grey200),
                      Expanded(
                        child: _BidInfoItem(
                          label: context.l10n.bids_received,
                          value: v.bidsReceived.toString().padLeft(2, '0'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Amount input
                Text(
                  context.l10n.yourBidAmount,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey700,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _amountCtrl,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  onChanged: (_) {
                    if (_errorText != null) setState(() => _errorText = null);
                  },
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                  decoration: InputDecoration(
                    hintText: '0',
                    prefixText: '₹ ',
                    prefixStyle: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                    errorText: _errorText,
                    filled: true,
                    fillColor: AppColors.grey50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: AppColors.grey300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: AppColors.grey300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.error),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                GradientButton.filled(
                  text: context.l10n.placeBid,
                  width: double.infinity,
                  isLoading: _isSubmitting,
                  onPressed: _isSubmitting ? null : _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BidInfoItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _BidInfoItem({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 10.sp,
            color: AppColors.grey500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: valueColor ?? AppColors.black,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Vehicle details accordion
// ─────────────────────────────────────────────────────────────────────────────

class _VehicleDetailsAccordion extends StatefulWidget {
  final VehicleListing v;
  const _VehicleDetailsAccordion({required this.v});

  @override
  State<_VehicleDetailsAccordion> createState() =>
      _VehicleDetailsAccordionState();
}

class _VehicleDetailsAccordionState extends State<_VehicleDetailsAccordion> {
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
          // Header tap row
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 14.h,
              ),
              color: _expanded
                  ? AppColors.lightOrange.withOpacity(0.18)
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
                        fontWeight: FontWeight.w700,
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

          // Expandable content
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                Divider(height: 1, thickness: 1, color: AppColors.grey100),
                _DetailRow(
                  icon: Icons.calendar_today_outlined,
                  label: context.l10n.repoDate,
                  value: v.repoDate.isNotEmpty ? v.repoDate : context.l10n.na,
                ),
                _DetailRow(
                  icon: Icons.receipt_long_outlined,
                  label: context.l10n.transactionFees,
                  value: context.l10n.na,
                ),
                _DetailRow(
                  icon: Icons.directions_car_outlined,
                  label: context.l10n.makeAndModel,
                  value: '${v.make} ${v.model}',
                ),
                _DetailRow(
                  icon: Icons.build_circle_outlined,
                  label: context.l10n.variant,
                  value: v.variant.isNotEmpty ? v.variant : context.l10n.na,
                ),
                _DetailRow(
                  icon: Icons.date_range_outlined,
                  label: context.l10n.mfgYear,
                  value: v.year > 0 ? v.year.toString() : context.l10n.na,
                ),
                _DetailRow(
                  icon: Icons.color_lens_outlined,
                  label: context.l10n.colour,
                  value: v.colour.isNotEmpty ? v.colour : context.l10n.na,
                ),
                _DetailRow(
                  icon: Icons.speed_outlined,
                  label: context.l10n.kilometers,
                  value: v.kilometers > 0
                      ? '${v.kilometers} km'
                      : context.l10n.na,
                ),
                _DetailRow(
                  icon: Icons.local_gas_station_outlined,
                  label: context.l10n.fuelType,
                  value: v.fuelType.isNotEmpty ? v.fuelType : context.l10n.na,
                ),
                _DetailRow(
                  icon: Icons.settings_outlined,
                  label: context.l10n.transmission,
                  value: v.transmission.isNotEmpty
                      ? v.transmission
                      : context.l10n.na,
                ),
                _DetailRow(
                  icon: Icons.person_outline_rounded,
                  label: context.l10n.owner,
                  value: v.owner.isNotEmpty ? v.owner : context.l10n.na,
                ),
                _DetailRow(
                  icon: Icons.confirmation_number_outlined,
                  label: context.l10n.chassisNumber,
                  value: v.chassisNo.isNotEmpty ? v.chassisNo : context.l10n.na,
                ),
                _DetailRow(
                  icon: Icons.memory_outlined,
                  label: context.l10n.engineNumber,
                  value: v.engineNo.isNotEmpty ? v.engineNo : context.l10n.na,
                ),
                _DetailRow(
                  icon: Icons.verified_outlined,
                  label: context.l10n.rcStatus,
                  value: context.l10n.na,
                ),
                _DetailRow(
                  icon: Icons.local_parking_outlined,
                  label: context.l10n.parkingCharges,
                  value: context.l10n.na,
                ),
                _DetailRow(
                  icon: Icons.warehouse_outlined,
                  label: context.l10n.yard_name,
                  value: v.yardName.isNotEmpty ? v.yardName : context.l10n.na,
                ),
                _DetailRow(
                  icon: Icons.location_city_outlined,
                  label: context.l10n.yardDetails,
                  value: v.yardLocation.isNotEmpty
                      ? v.yardLocation
                      : context.l10n.na,
                ),
                _DetailRow(
                  icon: Icons.notes_outlined,
                  label: context.l10n.remarks,
                  value: v.remarks.isNotEmpty ? v.remarks : context.l10n.na,
                ),
                // Contact sub-header
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: 10.h,
                  ),
                  color: AppColors.grey50,
                  child: Row(
                    children: [
                      Icon(
                        Icons.contact_phone_outlined,
                        size: 16.r,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        context.l10n.contactDetails,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                _DetailRow(
                  icon: Icons.person_rounded,
                  label: context.l10n.contactName,
                  value: v.contactPersonName.isNotEmpty
                      ? v.contactPersonName
                      : context.l10n.na,
                ),
                _DetailRow(
                  icon: Icons.phone_outlined,
                  label: context.l10n.mobileNo,
                  value: v.contactPersonNumber.isNotEmpty
                      ? v.contactPersonNumber
                      : context.l10n.na,
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
              fontWeight: FontWeight.w700,
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

class _BidInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;
  const _BidInfoRow({
    required this.label,
    required this.value,
    this.isLast = false,
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
                  color: AppColors.black,
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

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
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
