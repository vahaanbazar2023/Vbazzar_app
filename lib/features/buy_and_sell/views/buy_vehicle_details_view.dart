import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/design_system/templates/app_layout.dart';
import '../../../core/design_system/tokens/app_radius.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../domain/entities/buy_vehicle_entity.dart';

class BuyVehicleDetailsView extends StatelessWidget {
  const BuyVehicleDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final vehicle = args['vehicle'] as BuyVehicleEntity?;

    if (vehicle == null) {
      return AppLayout(
        title: 'Vehicle Details',
        showBack: true,
        body: const Center(child: Text('Vehicle not found')),
      );
    }

    final title = '${vehicle.brandName ?? ''} ${vehicle.model ?? ''}'.trim();

    return AppLayout(
      title: title.isEmpty ? vehicle.categoryName : title,
      subtitle: 'ID: ${vehicle.sbVehicleId}',
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Image carousel ───────────────────────────────────────
                  ClipRRect(
                    borderRadius: AppRadius.borderRadiusMd,
                    child: Stack(
                      children: [
                        NetworkImageCarousel(
                          imageUrls: vehicle.allImageUrls,
                          height: 220.h,
                        ),
                        // Category badge top-left
                        Positioned(
                          top: 10,
                          left: 10,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 5.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              vehicle.categoryName.toUpperCase(),
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),
                        // Status badge top-right
                        if (vehicle.status != null)
                          Positioned(
                            top: 10,
                            right: 10,
                            child: _StatusBadge(status: vehicle.status!),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm),

                  // ── Vehicle title + location ─────────────────────────────
                  Center(
                    child: Text(
                      title.isEmpty ? vehicle.categoryName : title,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  // Red underline accent
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

                  // Location row
                  if ((vehicle.city ?? '').isNotEmpty ||
                      (vehicle.state ?? '').isNotEmpty)
                    Center(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: AppSpacing.sm),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              size: 14.sp,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              [vehicle.city, vehicle.state]
                                  .where((s) => s != null && s.isNotEmpty)
                                  .join(', '),
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 13.sp,
                                color: AppColors.grey600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // ── 2×2 Info boxes ───────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: _InfoBox(
                            icon: Icons.fingerprint_rounded,
                            label: 'Vehicle ID',
                            value: vehicle.sbVehicleId,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: _InfoBox(
                            icon: Icons.category_outlined,
                            label: 'Category',
                            value: vehicle.categoryName,
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
                            icon: Icons.location_city_outlined,
                            label: 'Location',
                            value:
                                [vehicle.city, vehicle.state]
                                    .where((s) => s != null && s.isNotEmpty)
                                    .join(', ')
                                    .isEmpty
                                ? 'N/A'
                                : [vehicle.city, vehicle.state]
                                      .where((s) => s != null && s.isNotEmpty)
                                      .join(', '),
                          ),
                        ),

                        SizedBox(width: 8.w),
                        Expanded(
                          child: _InfoBox(
                            icon: Icons.info_outline_rounded,
                            label: 'Status',
                            value: vehicle.status != null
                                ? vehicle.status!.toUpperCase()
                                : 'N/A',
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),

                  // ── Key specs card ───────────────────────────────────────
                  _KeySpecsCard(vehicle: vehicle),
                  SizedBox(height: AppSpacing.md),

                  // ── Vehicle details accordion ────────────────────────────
                  _VehicleDetailsAccordion(vehicle: vehicle),
                  SizedBox(height: AppSpacing.md),

                  // ── Actions label ────────────────────────────────────────
                  _SectionLabel(icon: Icons.bolt_rounded, title: 'Take Action'),
                  SizedBox(height: 12.h),

                  // ── Action card 1: Become Member ─────────────────────────
                  _ActionCard(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1A3A6B), Color(0xFF2A5298)],
                    ),
                    icon: Icons.workspace_premium_rounded,
                    title: 'Become Member',
                    subtitle: 'Connect With Owner',
                    buttonText: 'Subscribe',
                    buttonColor: Colors.white,
                    buttonTextColor: const Color(0xFF1A3A6B),
                    onTap: () => _snack(
                      'Subscribe',
                      'Redirecting to subscription plans',
                    ),
                  ),
                  SizedBox(height: 10.h),

                  // ── Action card 2: Show Interest ─────────────────────────
                  _ActionCard(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F9B8E), Color(0xFF16C79A)],
                    ),
                    icon: Icons.favorite_rounded,
                    title: 'Let Us Know',
                    subtitle: "You're Interested",
                    buttonText: 'Interested',
                    buttonColor: Colors.white,
                    buttonTextColor: const Color(0xFF0F9B8E),
                    onTap: () => _snack(
                      'Interest Recorded',
                      'The seller has been notified of your interest',
                    ),
                  ),
                  SizedBox(height: 10.h),

                  // ── Action card 3: Make Offer ────────────────────────────
                  _ActionCard(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE8882A), Color(0xFFF5A623)],
                    ),
                    icon: Icons.local_offer_rounded,
                    title: 'Submit Your',
                    subtitle: 'Best Vehicle Offer',
                    buttonText: 'Submit',
                    buttonColor: Colors.white,
                    buttonTextColor: const Color(0xFFE8882A),
                    onTap: () => _offerDialog(context, vehicle),
                  ),
                  SizedBox(height: 12.h),

                  // ── Inspection button ────────────────────────────────────
                  GestureDetector(
                    onTap: () => _snack(
                      'Inspection Requested',
                      'Our team will contact you to schedule an inspection',
                    ),
                    child: Container(
                      width: double.infinity,
                      height: 52.h,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.ctaGradientStart,
                            AppColors.ctaGradientEnd,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.manage_search_rounded,
                              color: Colors.white,
                              size: 20.sp,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'Request Vehicle Inspection',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _snack(String t, String m) => Get.snackbar(
    t,
    m,
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: AppColors.black,
    colorText: Colors.white,
    margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
    borderRadius: 14,
    duration: const Duration(seconds: 3),
  );

  void _offerDialog(BuildContext context, BuyVehicleEntity vehicle) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(22.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44.w,
                    height: 44.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8882A).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: const Icon(
                      Icons.local_offer_rounded,
                      color: Color(0xFFE8882A),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Make an Offer',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.black,
                          ),
                        ),
                        Text(
                          'Propose your best price',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 12.sp,
                            color: AppColors.grey600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 18.h),
              Text(
                'Offer Amount',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.grey600,
                ),
              ),
              SizedBox(height: 8.h),
              TextField(
                controller: ctrl,
                keyboardType: TextInputType.number,
                autofocus: true,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.black,
                ),
                decoration: InputDecoration(
                  hintText: '0',
                  hintStyle: TextStyle(color: AppColors.grey400),
                  prefixText: '₹ ',
                  prefixStyle: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                  filled: true,
                  fillColor: AppColors.grey50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: AppColors.grey300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: AppColors.grey300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: Get.back,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.grey600,
                        side: BorderSide(color: AppColors.grey300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 13.h),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        _snack(
                          'Offer Submitted',
                          'Your offer of ₹${ctrl.text} has been sent',
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 13.h),
                        elevation: 0,
                      ),
                      child: Text(
                        'Submit Offer',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Status badge overlay on image
// ─────────────────────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isActive = status.toLowerCase() == 'active';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.success.withValues(alpha: 0.9)
            : Colors.grey.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.w,
            height: 6.w,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 5.w),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 9.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Info box — matches auction detail _InfoBox exactly
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
// Key Specs card — horizontal grid of spec chips
// ─────────────────────────────────────────────────────────────────────────────

class _KeySpecsCard extends StatelessWidget {
  final BuyVehicleEntity vehicle;
  const _KeySpecsCard({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    final specs = <_SpecItem>[];
    if (vehicle.year != null)
      specs.add(_SpecItem(Icons.calendar_month_rounded, 'Year', vehicle.year!));
    if (vehicle.fuelType != null)
      specs.add(
        _SpecItem(Icons.local_gas_station_outlined, 'Fuel', vehicle.fuelType!),
      );
    if (vehicle.bodyType != null)
      specs.add(
        _SpecItem(Icons.view_in_ar_outlined, 'Body Type', vehicle.bodyType!),
      );
    if (vehicle.tonnage != null)
      specs.add(
        _SpecItem(Icons.fitness_center_outlined, 'Tonnage', vehicle.tonnage!),
      );
    if (vehicle.noOfTyres != null)
      specs.add(
        _SpecItem(
          Icons.radio_button_unchecked_rounded,
          'Tyres',
          vehicle.noOfTyres!,
        ),
      );
    if (vehicle.kv != null)
      specs.add(_SpecItem(Icons.bolt_rounded, 'KV', vehicle.kv!));

    if (specs.isEmpty) return const SizedBox.shrink();

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              14.h,
              AppSpacing.md,
              10.h,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.speed_outlined,
                  size: 18.r,
                  color: AppColors.primary,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Key Specifications',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: AppColors.grey100),
          // Spec chips grid
          Padding(
            padding: EdgeInsets.all(AppSpacing.sm),
            child: Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: specs
                  .map(
                    (s) => Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.grey50,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: AppColors.grey200),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(s.icon, size: 14.r, color: AppColors.primary),
                          SizedBox(width: 6.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                s.label,
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 9.sp,
                                  color: AppColors.grey500,
                                ),
                              ),
                              Text(
                                s.value,
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.black,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpecItem {
  final IconData icon;
  final String label;
  final String value;
  const _SpecItem(this.icon, this.label, this.value);
}

// ─────────────────────────────────────────────────────────────────────────────
// Vehicle Details Accordion — expandable, matches auction style
// ─────────────────────────────────────────────────────────────────────────────

class _VehicleDetailsAccordion extends StatefulWidget {
  final BuyVehicleEntity vehicle;
  const _VehicleDetailsAccordion({required this.vehicle});

  @override
  State<_VehicleDetailsAccordion> createState() =>
      _VehicleDetailsAccordionState();
}

class _VehicleDetailsAccordionState extends State<_VehicleDetailsAccordion> {
  bool _expanded = true; // open by default so user sees the details

  @override
  Widget build(BuildContext context) {
    final v = widget.vehicle;
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
            secondChild: _buildDetails(v),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 280),
          ),
        ],
      ),
    );
  }

  Widget _buildDetails(BuyVehicleEntity v) {
    final rows = <_DetailRowData>[];
    if (v.brandName != null)
      rows.add(
        _DetailRowData(
          Icons.branding_watermark_outlined,
          'Brand',
          v.brandName!,
        ),
      );
    if (v.model != null)
      rows.add(
        _DetailRowData(Icons.directions_car_outlined, 'Model', v.model!),
      );
    if (v.year != null)
      rows.add(
        _DetailRowData(
          Icons.calendar_today_outlined,
          'Year of Manufacture',
          v.year!,
        ),
      );
    rows.add(
      _DetailRowData(Icons.category_outlined, 'Category', v.categoryName),
    );
    rows.add(
      _DetailRowData(Icons.code_rounded, 'Category Code', v.categoryCode),
    );
    if (v.brandCode != null)
      rows.add(_DetailRowData(Icons.tag_rounded, 'Brand Code', v.brandCode!));
    if (v.fuelType != null)
      rows.add(
        _DetailRowData(
          Icons.local_gas_station_outlined,
          'Fuel Type',
          v.fuelType!,
        ),
      );
    if (v.bodyType != null)
      rows.add(
        _DetailRowData(Icons.view_in_ar_outlined, 'Body Type', v.bodyType!),
      );
    if (v.tonnage != null)
      rows.add(
        _DetailRowData(Icons.fitness_center_outlined, 'Tonnage', v.tonnage!),
      );
    if (v.noOfTyres != null)
      rows.add(
        _DetailRowData(
          Icons.radio_button_unchecked_rounded,
          'No. of Tyres',
          v.noOfTyres!,
        ),
      );
    if (v.kv != null)
      rows.add(
        _DetailRowData(Icons.electrical_services_outlined, 'KV Rating', v.kv!),
      );
    if (v.city != null)
      rows.add(_DetailRowData(Icons.location_city_outlined, 'City', v.city!));
    if (v.state != null)
      rows.add(_DetailRowData(Icons.map_outlined, 'State', v.state!));
    if (v.status != null)
      rows.add(_DetailRowData(Icons.info_outline, 'Status', v.status!));

    return Column(
      children: [
        Divider(height: 1, thickness: 1, color: AppColors.grey100),
        ...rows.asMap().entries.map(
          (entry) => _DetailRow(
            icon: entry.value.icon,
            label: entry.value.label,
            value: entry.value.value,
            isLast: entry.key == rows.length - 1,
          ),
        ),
      ],
    );
  }
}

class _DetailRowData {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRowData(this.icon, this.label, this.value);
}

// ─────────────────────────────────────────────────────────────────────────────
// Detail row — matches auction _DetailRow
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

// ─────────────────────────────────────────────────────────────────────────────
// Section label row
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionLabel({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3.w,
          height: 22.h,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.ctaGradientStart, AppColors.ctaGradientEnd],
            ),
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(width: 10.w),
        Icon(icon, size: 18.r, color: AppColors.primary),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.black,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Action card — preserved exactly (gradient colored cards)
// ─────────────────────────────────────────────────────────────────────────────

class _ActionCard extends StatelessWidget {
  final LinearGradient gradient;
  final IconData icon;
  final String title;
  final String subtitle;
  final String buttonText;
  final Color buttonColor;
  final Color buttonTextColor;
  final VoidCallback onTap;

  const _ActionCard({
    required this.gradient,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.buttonColor,
    required this.buttonTextColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72.h,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 42.w,
                  height: 42.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(icon, color: Colors.white, size: 22.sp),
                ),
                SizedBox(width: 14.w),
                // Text
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                // Button
                GestureDetector(
                  onTap: onTap,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 18.w,
                      vertical: 9.h,
                    ),
                    decoration: BoxDecoration(
                      color: buttonColor,
                      borderRadius: BorderRadius.circular(24.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      buttonText,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w800,
                        color: buttonTextColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
