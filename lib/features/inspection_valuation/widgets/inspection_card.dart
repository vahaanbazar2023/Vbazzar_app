import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_colors.dart';
import '../data/models/inspection_vehicle_model.dart';

/// Card widget for displaying a single inspection item in the My Inspections list.
class InspectionCard extends StatelessWidget {
  final InspectionVehicleModel inspection;
  final VoidCallback? onTap;

  const InspectionCard({
    super.key,
    required this.inspection,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildVehicleIcon(),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Vehicle No + Status Badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          inspection.vehicleNo,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _buildStatusBadge(),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  // Brand + Type
                  Text(
                    '${inspection.vehicleBrand} • ${inspection.vehicleType}',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  // City, State
                  Text(
                    '${inspection.vehicleCity}, ${inspection.vehicleState}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  // Chassis number
                  Text(
                    'Chassis: ${inspection.chasisNo}',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.grey500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6.h),
                  // Owner + View Report
                  Row(
                    children: [
                      Icon(
                        Icons.phone,
                        size: 12.r,
                        color: AppColors.grey500,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        inspection.vehicleOwnerNumber,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      if (inspection.webUrl?.isNotEmpty == true)
                        GestureDetector(
                          onTap: () {
                            // TODO: Launch URL with url_launcher
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.open_in_new,
                                size: 12.r,
                                color: AppColors.primary,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                'View Report',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
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

  Widget _buildVehicleIcon() {
    IconData iconData;
    switch (inspection.vehicleType.toLowerCase()) {
      case 'truck':
        iconData = Icons.local_shipping;
        break;
      case 'bus':
        iconData = Icons.directions_bus;
        break;
      case 'car':
        iconData = Icons.directions_car;
        break;
      case 'tractor':
        iconData = Icons.agriculture;
        break;
      case 'jcb':
      case 'crane':
        iconData = Icons.construction;
        break;
      default:
        iconData = Icons.commute;
    }

    return Container(
      width: 44.r,
      height: 44.r,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Icon(iconData, color: AppColors.primary, size: 24.r),
    );
  }

  Widget _buildStatusBadge() {
    final (color, label) = _statusStyle;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  (Color, String) get _statusStyle {
    switch (inspection.status.toLowerCase()) {
      case 'completed':
        return (AppColors.success, 'Completed');
      case 'in_progress':
        return (AppColors.info, 'In Progress');
      case 'rejected':
        return (AppColors.error, 'Rejected');
      case 'pending':
      default:
        return (AppColors.warning, 'Pending');
    }
  }
}