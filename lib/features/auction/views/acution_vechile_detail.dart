import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/design_system/templates/app_layout.dart';
import '../../../core/design_system/tokens/app_radius.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../models/vehicle_listing.dart';

class AuctionVehicleDetailScreen extends StatelessWidget {
  const AuctionVehicleDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final VehicleListing v = args['vehicle'] as VehicleListing;
    final String endAt = args['endAt'] as String? ?? '';

    return AppLayout(
      title: 'Place Bid',
      subtitle: 'Auction ID: ${v.auctionId}',
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
                            label: 'Auction ID',
                            value: v.auctionId,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: _InfoBox(
                            icon: Icons.description_outlined,
                            label: 'Vehicle Ref',
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
                            label: 'Registration RTO',
                            value: v.registeredRto.isNotEmpty
                                ? v.registeredRto
                                : 'N/A',
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: _InfoBox(
                            icon: Icons.badge_outlined,
                            label: 'Reg. Number',
                            value: v.registrationNo.isNotEmpty
                                ? v.registrationNo
                                : 'N/A',
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),

                  // ── Bid info ──────────────────────────────
                  _SectionCard(
                    children: [
                      _BidInfoRow(
                        label: 'Your Bid',
                        value: '₹ ${_formatPrice(v.yourBid)}',
                      ),
                      _BidInfoRow(
                        label: 'Bids Left',
                        value: v.bidsLeft.toString().padLeft(2, '0'),
                      ),
                      _BidInfoRow(
                        label: 'Bids Received',
                        value: v.bidsReceived.toString().padLeft(2, '0'),
                      ),
                      _BidInfoRow(
                        label: 'Available Buying Limit',
                        value: '₹ ${_formatPrice(v.availableBalance)}',
                        isLast: true,
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.md),

                  // ── Vehicle Details accordion ─────────────
                  _VehicleDetailsAccordion(v: v),

                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),

          // ── Fixed bottom: price + bid button ───────────────
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Bid Start Price',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 11.sp,
                          color: AppColors.grey600,
                        ),
                      ),
                      Text(
                        '₹ ${_formatPrice(v.minimumPrice)}',
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
                    text: 'Bid Now',
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
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
}

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
                      'Vehicle Details',
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
                  label: 'Repo Date',
                  value: v.repoDate.isNotEmpty ? v.repoDate : 'N/A',
                ),
                _DetailRow(
                  icon: Icons.receipt_long_outlined,
                  label: 'Transaction Fees',
                  value: 'N/A',
                ),
                _DetailRow(
                  icon: Icons.directions_car_outlined,
                  label: 'Make & Model',
                  value: '${v.make} ${v.model}',
                ),
                _DetailRow(
                  icon: Icons.build_circle_outlined,
                  label: 'Variant',
                  value: v.variant.isNotEmpty ? v.variant : 'N/A',
                ),
                _DetailRow(
                  icon: Icons.date_range_outlined,
                  label: 'Mfg Year',
                  value: v.year > 0 ? v.year.toString() : 'N/A',
                ),
                _DetailRow(
                  icon: Icons.color_lens_outlined,
                  label: 'Colour',
                  value: v.colour.isNotEmpty ? v.colour : 'N/A',
                ),
                _DetailRow(
                  icon: Icons.speed_outlined,
                  label: 'Kilometers',
                  value: v.kilometers > 0 ? '${v.kilometers} km' : 'N/A',
                ),
                _DetailRow(
                  icon: Icons.local_gas_station_outlined,
                  label: 'Fuel Type',
                  value: v.fuelType.isNotEmpty ? v.fuelType : 'N/A',
                ),
                _DetailRow(
                  icon: Icons.settings_outlined,
                  label: 'Transmission',
                  value: v.transmission.isNotEmpty ? v.transmission : 'N/A',
                ),
                _DetailRow(
                  icon: Icons.person_outline_rounded,
                  label: 'Owner',
                  value: v.owner.isNotEmpty ? v.owner : 'N/A',
                ),
                _DetailRow(
                  icon: Icons.confirmation_number_outlined,
                  label: 'Chassis No',
                  value: v.chassisNo.isNotEmpty ? v.chassisNo : 'N/A',
                ),
                _DetailRow(
                  icon: Icons.memory_outlined,
                  label: 'Engine No',
                  value: v.engineNo.isNotEmpty ? v.engineNo : 'N/A',
                ),
                _DetailRow(
                  icon: Icons.verified_outlined,
                  label: 'RC Status',
                  value: 'N/A',
                ),
                _DetailRow(
                  icon: Icons.local_parking_outlined,
                  label: 'Parking Charges',
                  value: 'N/A',
                ),
                _DetailRow(
                  icon: Icons.warehouse_outlined,
                  label: 'Yard Name',
                  value: v.yardName.isNotEmpty ? v.yardName : 'N/A',
                ),
                _DetailRow(
                  icon: Icons.location_city_outlined,
                  label: 'Yard Details',
                  value: v.yardLocation.isNotEmpty ? v.yardLocation : 'N/A',
                ),
                _DetailRow(
                  icon: Icons.notes_outlined,
                  label: 'Remarks',
                  value: v.remarks.isNotEmpty ? v.remarks : 'N/A',
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
                        'Contact Details',
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
                  label: 'Name',
                  value: v.contactPersonName.isNotEmpty
                      ? v.contactPersonName
                      : 'N/A',
                ),
                _DetailRow(
                  icon: Icons.phone_outlined,
                  label: 'Mobile No.',
                  value: v.contactPersonNumber.isNotEmpty
                      ? v.contactPersonNumber
                      : 'N/A',
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
