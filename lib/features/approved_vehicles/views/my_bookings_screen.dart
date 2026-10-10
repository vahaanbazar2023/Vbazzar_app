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
import '../controllers/approved_vehicle_controller.dart';
import '../domain/entities/approved_vehicle_listing_entity.dart';
import '../../../routes/app_routes.dart';
import '../../../core/extensions/context_extensions.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  late final ApprovedVehicleController ctrl;
  late final bool _isInspections;

  @override
  void initState() {
    super.initState();
    ctrl = Get.find<ApprovedVehicleController>();
    _isInspections = Get.currentRoute.contains('inspection');
    _loadData();
  }

  void _loadData() {
    if (_isInspections) {
      ctrl.fetchMyInspections(isRefresh: true);
    } else {
      ctrl.fetchMyBookings(isRefresh: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: _isInspections
          ? context.l10n.myInspections
          : context.l10n.myBookings,
      subtitle: _isInspections
          ? context.l10n.apprInspectionsSubtitle
          : context.l10n.apprBookingsSubtitle,
      showBack: true,
      body: Obx(() {
        final loading = _isInspections
            ? ctrl.isLoadingMyInspections.value
            : ctrl.isLoadingMyBookings.value;
        final vehicles = _isInspections ? ctrl.myInspections : ctrl.myBookings;

        if (loading && vehicles.isEmpty) {
          return _ShimmerList();
        }

        if (vehicles.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () async => _loadData(),
          color: AppColors.primary,
          child: ListView.builder(
            padding: EdgeInsets.all(AppSpacing.md),
            itemCount: vehicles.length,
            itemBuilder: (_, i) => _BookingCard(
              vehicle: vehicles[i],
              isInspections: _isInspections,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(40.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isInspections
                  ? Icons.search_outlined
                  : Icons.bookmark_border_outlined,
              size: 64.r,
              color: AppColors.grey300,
            ),
            SizedBox(height: 16.h),
            Text(
              _isInspections
                  ? context.l10n.apprNoInspectionsYet
                  : context.l10n.apprNoBookingsYet,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.grey500,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              _isInspections
                  ? context.l10n.apprInspectionsEmptyHint
                  : context.l10n.apprBookingsEmptyHint,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 13.sp,
                color: AppColors.grey400,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            GradientButton.filled(
              text: context.l10n.apprRefresh,
              width: 120.w,
              isLoading: false,
              onPressed: _loadData,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Booking / Inspection Card — same style as vehicle_listings_screen
// ─────────────────────────────────────────────────────────────────────────────

class _BookingCard extends StatelessWidget {
  final ApprovedVehicleListingEntity vehicle;
  final bool isInspections;

  const _BookingCard({required this.vehicle, required this.isInspections});

  @override
  Widget build(BuildContext context) {
    final imageUrls =
        vehicle.files?.images
            .map((e) => e.fileUrl)
            .where((u) => u.isNotEmpty)
            .toList() ??
        [];

    final title = vehicle.displayTitle.isNotEmpty
        ? vehicle.displayTitle
        : vehicle.registrationNumber;

    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoutes.approvedVehicleDetail,
        arguments: {'listing': vehicle},
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.grey200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image ─────────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppRadius.lg),
                topRight: Radius.circular(AppRadius.lg),
              ),
              child: imageUrls.isNotEmpty
                  ? NetworkImageCarousel(imageUrls: imageUrls, height: 180.h)
                  : Container(
                      height: 180.h,
                      color: AppColors.grey100,
                      child: Center(
                        child: Icon(
                          Icons.directions_car_outlined,
                          size: 48.r,
                          color: AppColors.grey400,
                        ),
                      ),
                    ),
            ),
            // ── Details ───────────────────────────────────────
            Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: AppSpacing.xs),
                  if (vehicle.assetDescription.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(bottom: AppSpacing.xs),
                      child: Text(
                        vehicle.assetDescription,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12.sp,
                          color: AppColors.grey500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  // Chips + price
                  Row(
                    children: [
                      if (vehicle.yearOfManufacturing > 0)
                        _chip(
                          Icons.calendar_today_outlined,
                          '${vehicle.yearOfManufacturing}',
                        ),
                      if (vehicle.yearOfManufacturing > 0)
                        SizedBox(width: AppSpacing.sm),
                      if (vehicle.stateName.isNotEmpty)
                        Flexible(
                          child: _chip(
                            Icons.location_on_outlined,
                            vehicle.stateName,
                          ),
                        ),
                      const Spacer(),
                      if (vehicle.price > 0)
                        Text(
                          '₹${_formatPrice(vehicle.price)}',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.sm),
                  // Action buttons — disabled if already booked/inspected
                  Row(
                    children: [
                      Expanded(
                        child: vehicle.isBookedVehicle
                            ? _disabledBtn(context.l10n.apprBookedCheck)
                            : GradientButton.filled(
                                text: context.l10n.apprBookNow,
                                height: 44.h,
                                isLoading: false,
                                onPressed: () {},
                              ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: vehicle.isInspectionRequested
                            ? _disabledBtn(context.l10n.apprRequestedCheck)
                            : GradientButton.filled(
                                text: context.l10n.apprInspection,
                                height: 44.h,
                                isLoading: false,
                                onPressed: () {},
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String text) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 12, color: AppColors.grey500),
      SizedBox(width: 3.w),
      Flexible(
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 11.sp,
            color: AppColors.grey600,
          ),
        ),
      ),
    ],
  );

  Widget _disabledBtn(String text) => ConstrainedBox(
    constraints: BoxConstraints(minHeight: 44.h),
    child: Container(
      decoration: BoxDecoration(
        color: AppColors.grey200,
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
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
    ),
  );

  static String _formatPrice(double price) {
    return NumberFormat('#,##,###', 'en_IN').format(price.toInt());
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shimmer
// ─────────────────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────
// Shimmer
// ─────────────────────────────────────────────────────────────────────────────

class _ShimmerList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(AppSpacing.md),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      itemBuilder: (_, __) => Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.grey200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Container(
              height: 180.h,
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.lg),
                  topRight: Radius.circular(AppRadius.lg),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title bone
                  Container(
                    height: 14.h,
                    width: 160.w,
                    decoration: BoxDecoration(
                      color: AppColors.grey100,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  // Subtitle bone
                  Container(
                    height: 11.h,
                    width: 220.w,
                    decoration: BoxDecoration(
                      color: AppColors.grey100,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  // Button bones
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 38.h,
                          decoration: BoxDecoration(
                            color: AppColors.grey100,
                            borderRadius: BorderRadius.circular(30.r),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Container(
                          height: 38.h,
                          decoration: BoxDecoration(
                            color: AppColors.grey100,
                            borderRadius: BorderRadius.circular(30.r),
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
      ),
    );
  }
}
