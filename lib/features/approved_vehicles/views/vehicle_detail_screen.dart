import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/design_system/organisms/network_image_carousel.dart';
import '../../../core/design_system/templates/app_layout.dart';
import '../../../core/design_system/tokens/app_radius.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../theme/app_fonts.dart';
import '../controllers/approved_vehicle_controller.dart';
import '../domain/entities/approved_vehicle_listing_entity.dart';

class VehicleDetailScreen extends StatelessWidget {
  const VehicleDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ApprovedVehicleController>();
    final args = Get.arguments as Map<String, dynamic>?;
    final listing = args?['listing'] as ApprovedVehicleListingEntity?;

    if (listing == null) {
      return AppLayout(
        title: 'Vehicle Details',
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48.w, color: AppColors.error),
              SizedBox(height: 12.h),
              Text(
                'Vehicle details not available',
                style: AppFonts.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 16.h),
              GradientButton.filled(
                text: 'Go Back',
                onPressed: () => Get.back(),
                width: 140.w,
              ),
            ],
          ),
        ),
      );
    }

    return _ApprVehicleDetail(listing: listing, ctrl: ctrl);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Main detail widget
// ─────────────────────────────────────────────────────────────────────────────

class _ApprVehicleDetail extends StatelessWidget {
  final ApprovedVehicleListingEntity listing;
  final ApprovedVehicleController ctrl;

  const _ApprVehicleDetail({required this.listing, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final imageUrls =
        listing.files?.images
            .map((e) => e.fileUrl)
            .where((u) => u.isNotEmpty)
            .toList() ??
        [];

    final title = listing.displayTitle.isNotEmpty
        ? listing.displayTitle
        : listing.registrationNumber;

    return AppLayout(
      title: title,
      subtitle: listing.approvedVehicleId,
      showBack: true,
      bodyColor: AppColors.cardBackground,
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
                  // ── Image carousel ─────────────────────────────
                  ClipRRect(
                    borderRadius: AppRadius.borderRadiusMd,
                    child: Stack(
                      children: [
                        imageUrls.isNotEmpty
                            ? NetworkImageCarousel(
                                imageUrls: imageUrls,
                                height: 220.h,
                              )
                            : Container(
                                height: 220.h,
                                color: AppColors.grey100,
                                child: Center(
                                  child: Icon(
                                    Icons.directions_car_outlined,
                                    size: 56.r,
                                    color: AppColors.grey400,
                                  ),
                                ),
                              ),
                        // Category badge — top left
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
                              listing.categoryType.toUpperCase(),
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
                        // Status badge — top right
                        Positioned(
                          top: 10,
                          right: 10,
                          child: _ApprStatusBadge(
                            status: listing.vehicleStatus,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm),

                  // ── Title + underline ───────────────────────────
                  Center(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                      textAlign: TextAlign.center,
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

                  // ── 2×2 Info boxes ──────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _ApprInfoBox(
                          icon: Icons.fingerprint_rounded,
                          label: 'Vehicle ID',
                          value: listing.approvedVehicleId,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: _ApprInfoBox(
                          icon: Icons.category_outlined,
                          label: 'Category',
                          value: listing.categoryType,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Expanded(
                        child: _ApprInfoBox(
                          icon: Icons.location_city_outlined,
                          label: 'Location',
                          value: [
                            listing.cityName,
                            listing.stateName,
                          ].where((s) => s.isNotEmpty).join(', '),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: _ApprInfoBox(
                          icon: Icons.calendar_month_rounded,
                          label: 'Year',
                          value: listing.yearOfManufacturing > 0
                              ? '${listing.yearOfManufacturing}'
                              : 'N/A',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.md),

                  // ── Details accordion ───────────────────────────
                  _ApprDetailsAccordion(listing: listing),
                  SizedBox(height: AppSpacing.md),

                  // ── Actions ──────────────────────────────────────
                  SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      // Book Now
                      Expanded(
                        child: listing.isBookedVehicle
                            ? _disabledBtn('Booked ✓')
                            : GradientButton.filled(
                                text: 'Book Now',
                                height: 48.h,
                                isLoading: false,
                                onPressed: () => _showPaymentDialog(
                                  context: context,
                                  title: 'Book Vehicle',
                                  description:
                                      'Pay to book this vehicle and access full details.',
                                  amount: listing
                                      .categorySubscription
                                      ?.subscriptionAmount,
                                  planCode: listing
                                      .categorySubscription
                                      ?.apprVehCommonSubPlan,
                                  approvedVehicleId: listing.approvedVehicleId,
                                  subscriptionType: 'category',
                                  ctrl: ctrl,
                                ),
                              ),
                      ),
                      SizedBox(width: 12.w),
                      // Request Inspection
                      Expanded(
                        child: listing.isInspectionRequested
                            ? _disabledBtn('Requested ✓')
                            : GradientButton.filled(
                                text: 'Inspection',
                                height: 48.h,
                                isLoading: false,
                                onPressed: () => _showPaymentDialog(
                                  context: context,
                                  title: 'Request Inspection',
                                  description:
                                      'Pay to request professional inspection.',
                                  amount: listing
                                      .inspectionSubscription
                                      ?.inspectionAmount,
                                  planCode: listing
                                      .inspectionSubscription
                                      ?.categoryPlan,
                                  approvedVehicleId: listing.approvedVehicleId,
                                  subscriptionType: 'inspection',
                                  ctrl: ctrl,
                                ),
                              ),
                      ),
                    ],
                  ),
                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPaymentDialog({
    required BuildContext context,
    required String title,
    required String description,
    required double? amount,
    required String? planCode,
    required String approvedVehicleId,
    required String subscriptionType,
    required ApprovedVehicleController ctrl,
  }) {
    if (amount == null || planCode == null) {
      Get.snackbar(
        'Error',
        '$subscriptionType subscription not available',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.verified_rounded,
                size: 48.w,
                color: AppColors.primary,
              ),
              SizedBox(height: 12.h),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Text(
                description,
                style: AppFonts.bodyMedium.copyWith(color: AppColors.grey600),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              Text(
                '₹${_fmtPrice(amount)}',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.back();
                        final ok = subscriptionType == 'category'
                            ? await ctrl.bookVehicle(approvedVehicleId)
                            : await ctrl.requestInspection(approvedVehicleId);
                        Get.snackbar(
                          ok ? 'Success' : 'Error',
                          ok
                              ? (subscriptionType == 'category'
                                    ? 'Vehicle booked!'
                                    : 'Inspection requested!')
                              : 'Something went wrong. Try again.',
                          snackPosition: SnackPosition.TOP,
                          backgroundColor: ok
                              ? Colors.green.shade100
                              : Colors.red.shade100,
                          colorText: ok
                              ? Colors.green.shade900
                              : Colors.red.shade900,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Pay Now'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  static String _fmtPrice(double price) {
    final formatter = NumberFormat('#,##,###', 'en_IN');
    return formatter.format(price.toInt());
  }

  static Widget _disabledBtn(String text) {
    return SizedBox(
      height: 48.h,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.grey200,
          borderRadius: BorderRadius.circular(30.r),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.grey600,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Status badge
// ─────────────────────────────────────────────────────────────────────────────

class _ApprStatusBadge extends StatelessWidget {
  final String status;
  const _ApprStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isActive = status.toLowerCase() == 'active';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: (isActive ? AppColors.success : AppColors.grey500).withValues(
          alpha: 0.88,
        ),
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
// Info box
// ─────────────────────────────────────────────────────────────────────────────

class _ApprInfoBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _ApprInfoBox({
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
            value.isNotEmpty ? value : 'N/A',
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
// Details accordion
// ─────────────────────────────────────────────────────────────────────────────

class _ApprDetailsAccordion extends StatefulWidget {
  final ApprovedVehicleListingEntity listing;
  const _ApprDetailsAccordion({required this.listing});

  @override
  State<_ApprDetailsAccordion> createState() => _ApprDetailsAccordionState();
}

class _ApprDetailsAccordionState extends State<_ApprDetailsAccordion> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.borderRadiusMd,
        border: Border.all(color: AppColors.grey200),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
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
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _buildRows(),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 280),
          ),
        ],
      ),
    );
  }

  Widget _buildRows() {
    final l = widget.listing;
    final rows = <_ApprDetailRow>[
      _ApprDetailRow(
        Icons.tag_rounded,
        'Registration No.',
        l.registrationNumber,
      ),
      if ((l.brand ?? '').isNotEmpty)
        _ApprDetailRow(Icons.branding_watermark_outlined, 'Brand', l.brand!),
      if (l.yearOfManufacturing > 0)
        _ApprDetailRow(
          Icons.calendar_today_outlined,
          'Year',
          '${l.yearOfManufacturing}',
        ),
      _ApprDetailRow(Icons.category_outlined, 'Category', l.categoryType),
      if (l.chassisNumber.isNotEmpty)
        _ApprDetailRow(Icons.numbers_rounded, 'Chassis No.', l.chassisNumber),
      if (l.cityName.isNotEmpty)
        _ApprDetailRow(Icons.location_city_outlined, 'City', l.cityName),
      if (l.stateName.isNotEmpty)
        _ApprDetailRow(Icons.map_outlined, 'State', l.stateName),
      _ApprDetailRow(
        Icons.currency_rupee_rounded,
        'Price',
        '₹${NumberFormat('#,##,###', 'en_IN').format(l.price.toInt())}',
      ),
      _ApprDetailRow(
        Icons.verified_outlined,
        'Fitness Certificate',
        l.hasFitnessCertificate ? 'Yes' : 'No',
      ),
      _ApprDetailRow(
        Icons.receipt_long_outlined,
        'Original Invoice',
        l.hasOriginalInvoice ? 'Yes' : 'No',
      ),
      _ApprDetailRow(
        Icons.receipt_outlined,
        'GST Applicable',
        l.isGstApplicable ? 'Yes' : 'No',
      ),
      if (l.vehicleInsuranceDate.isNotEmpty &&
          l.vehicleInsuranceDate.toLowerCase() != 'null')
        _ApprDetailRow(
          Icons.shield_outlined,
          'Insurance Valid Until',
          _fmtDate(l.vehicleInsuranceDate),
        ),
      if (l.offerEndDate.isNotEmpty && l.offerEndDate.toLowerCase() != 'null')
        _ApprDetailRow(
          Icons.timer_outlined,
          'Offer Ends',
          '${_fmtDate(l.offerEndDate)} ${l.offerEndTime}',
        ),
      _ApprDetailRow(
        Icons.description_outlined,
        'RC Document',
        l.hasRcDocument ? 'Available' : 'Not available',
      ),
      _ApprDetailRow(
        Icons.policy_outlined,
        'Insurance Doc',
        l.hasInsuranceDocument ? 'Available' : 'Not available',
      ),
      _ApprDetailRow(
        Icons.info_outline,
        'Status',
        l.vehicleStatus.toUpperCase(),
      ),
    ];

    return Column(
      children: [
        Divider(height: 1, thickness: 1, color: AppColors.grey100),
        ...rows.asMap().entries.map(
          (e) => _buildRow(e.value, e.key == rows.length - 1),
        ),
      ],
    );
  }

  Widget _buildRow(_ApprDetailRow r, bool isLast) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 11.h,
          ),
          child: Row(
            children: [
              Icon(r.icon, size: 16.r, color: AppColors.grey500),
              SizedBox(width: 8.w),
              Expanded(
                flex: 2,
                child: Text(
                  r.label,
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
                  r.value,
                  textAlign: TextAlign.end,
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

  static String _fmtDate(String d) {
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(d));
    } catch (_) {
      return d;
    }
  }
}

class _ApprDetailRow {
  final IconData icon;
  final String label;
  final String value;
  const _ApprDetailRow(this.icon, this.label, this.value);
}

