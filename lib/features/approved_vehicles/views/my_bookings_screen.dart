import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/templates/app_layout.dart';
import '../../../core/design_system/tokens/app_radius.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../theme/app_fonts.dart';
import '../controllers/approved_vehicle_controller.dart';
import '../domain/entities/approved_vehicle_listing_entity.dart';
import '../../../routes/app_routes.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  final ctrl = Get.find<ApprovedVehicleController>();
  bool _isInspections = false;

  @override
  void initState() {
    super.initState();
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
      title: _isInspections ? 'My Inspections' : 'My Bookings',
      body: Obx(() {
        final loading = _isInspections
            ? ctrl.isLoadingMyInspections.value
            : ctrl.isLoadingMyBookings.value;
        final vehicles = _isInspections
            ? ctrl.myInspections
            : ctrl.myBookings;

        if (loading && vehicles.isEmpty) {
          return _buildShimmerList();
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
            itemBuilder: (_, i) => _buildBookingCard(vehicles[i]),
          ),
        );
      }),
    );
  }

  Widget _buildBookingCard(ApprovedVehicleListingEntity v) {
    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoutes.approvedVehicleDetail,
        arguments: {'listing': v},
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.borderRadiusMd,
          border: Border.all(color: AppColors.grey200),
          boxShadow: [
            BoxShadow(
              color: AppColors.blackTransparent,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Container(
                width: 70.w,
                height: 70.h,
                color: AppColors.grey100,
                child: (v.files?.images.isNotEmpty == true)
                    ? Image.network(
                        v.files!.images.first.fileUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.directions_car_outlined,
                          size: 28.w,
                          color: AppColors.grey400,
                        ),
                      )
                    : Icon(
                        Icons.directions_car_outlined,
                        size: 28.w,
                        color: AppColors.grey400,
                      ),
              ),
            ),
            SizedBox(width: 12.w),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    v.registrationNumber,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    '${v.brand ?? ""} • ${v.assetDescription}',
                    style: AppFonts.bodySmall.copyWith(
                      color: AppColors.grey600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    '${v.cityName}, ${v.stateName}',
                    style: AppFonts.bodySmall.copyWith(
                      color: AppColors.grey500,
                    ),
                  ),
                ],
              ),
            ),
            // Status badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: (_isInspections
                    ? AppColors.success
                    : AppColors.primary)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                _isInspections ? 'Inspected' : 'Booked',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: _isInspections ? AppColors.success : AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _isInspections
                ? Icons.search_outlined
                : Icons.bookmark_border_outlined,
            size: 56.w,
            color: AppColors.grey300,
          ),
          SizedBox(height: 12.h),
          Text(
            _isInspections
                ? 'No inspections requested yet'
                : 'No vehicles booked yet',
            style: AppFonts.bodyMedium.copyWith(color: AppColors.grey500),
          ),
          SizedBox(height: 16.h),
          GestureDetector(
            onTap: _loadData,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                'Refresh',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: EdgeInsets.all(AppSpacing.md),
      itemCount: 5,
      itemBuilder: (_, __) => Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.borderRadiusMd,
          border: Border.all(color: AppColors.grey200),
        ),
        child: Row(
          children: [
            Container(
              width: 70.w,
              height: 70.h,
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 14.h,
                    width: 120.w,
                    color: AppColors.grey100,
                  ),
                  SizedBox(height: 6.h),
                  Container(
                    height: 12.h,
                    width: 180.w,
                    color: AppColors.grey100,
                  ),
                  SizedBox(height: 6.h),
                  Container(
                    height: 10.h,
                    width: 100.w,
                    color: AppColors.grey100,
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