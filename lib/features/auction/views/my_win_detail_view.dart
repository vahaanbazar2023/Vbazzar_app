import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/design_system/templates/app_layout.dart';
import '../../../core/design_system/tokens/app_radius.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/extensions/context_extensions.dart';
import '../models/my_bids_wins_models.dart';

class MyWinDetailView extends StatelessWidget {
  final MyWinItem item;
  const MyWinDetailView({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final v = item.vehicleDetails;

    return AppLayout(
      title: context.l10n.winDetails,
      subtitle: '${context.l10n.auction_id}: ${item.auctionId}',
      showBack: true,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: Column(
                children: [
                  // ── Image carousel ────────────────────────────────────────
                  ClipRRect(
                    borderRadius: AppRadius.borderRadiusMd,
                    child: NetworkImageCarousel(
                      imageUrls: v.images,
                      height: 200.h,
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm),

                  // ── Title ─────────────────────────────────────────────────
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

                  // ── 2×2 info boxes ────────────────────────────────────────
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
                            icon: Icons.check_circle_outline_rounded,
                            label: context.l10n.paymentStatus,
                            value: item.userAuctionStatus,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),

                  // ── Win summary card ──────────────────────────────────────
                  _SectionCard(
                    children: [
                      _Row(
                        label: context.l10n.winningBidLabel,
                        value: '₹ ${_fmt(item.winningBidAmount)}',
                      ),
                      _Row(
                        label: context.l10n.bidApprovedAt,
                        value: item.bidApprovedAt.isNotEmpty
                            ? item.bidApprovedAt
                            : 'N/A',
                      ),
                      _Row(
                        label: context.l10n.paymentStatus,
                        value: item.paymentStatus.isNotEmpty
                            ? item.paymentStatus
                            : 'N/A',
                        valueColor: item.isPaid
                            ? AppColors.success
                            : AppColors.warning,
                      ),
                      _Row(
                        label: context.l10n.winningLetter,
                        value: item.winningLetterStatus == 'sent'
                            ? context.l10n.sentStatus
                            : context.l10n.pendingStatus,
                        valueColor: item.winningLetterStatus == 'sent'
                            ? AppColors.success
                            : AppColors.grey600,
                      ),
                      _Row(
                        label: context.l10n.auctionEnded,
                        value: item.auctionEndTime.isNotEmpty
                            ? item.auctionEndTime
                            : 'N/A',
                        isLast: true,
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.md),

                  // ── Vehicle accordion ─────────────────────────────────────
                  _VehicleAccordion(v: v),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),

          // ── Fixed bottom — payment status pill ───────────────────────────
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
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        context.l10n.winningBidLabel,
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 11.sp,
                          color: AppColors.grey600,
                        ),
                      ),
                      Text(
                        '₹ ${_fmt(item.winningBidAmount)}',
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
                  child: Container(
                    height: 44.h,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: item.isPaid
                          ? const LinearGradient(
                              colors: [
                                AppColors.ctaGradientStart,
                                AppColors.ctaGradientEnd,
                              ],
                            )
                          : null,
                      color: item.isPaid ? null : AppColors.grey200,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      item.userAuctionStatus,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w700,
                        fontSize: 13.sp,
                        color: item.isPaid ? Colors.white : AppColors.grey700,
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

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;
  final Color? valueColor;
  const _Row({
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

class _VehicleAccordion extends StatefulWidget {
  final dynamic v;
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
