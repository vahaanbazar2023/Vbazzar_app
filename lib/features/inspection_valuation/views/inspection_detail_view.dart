import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../../theme/app_fonts.dart';
import '../data/models/inspection_vehicle_model.dart';

/// Displays detailed information about a single inspection submission.
class InspectionDetailView extends StatelessWidget {
  const InspectionDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final vehicle = Get.arguments as InspectionVehicleModel?;

    if (vehicle == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Inspection Details')),
        body: const Center(child: Text('No inspection data found')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.black, size: 24.r),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Inspection Details',
          style: AppFonts.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Vehicle Info Card ─────────────────────────────
            _buildVehicleInfoCard(vehicle),
            SizedBox(height: 16.h),

            // ── Location Card ─────────────────────────────────
            _buildLocationCard(vehicle),
            SizedBox(height: 16.h),

            // ── Owner Card ────────────────────────────────────
            _buildOwnerCard(vehicle),
            SizedBox(height: 16.h),

            // ── Report Link ───────────────────────────────────
            if (vehicle.webUrl != null && vehicle.webUrl!.isNotEmpty)
              _buildReportLink(vehicle.webUrl!),

            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  VEHICLE INFO CARD
  // ══════════════════════════════════════════════════════════════

  Widget _buildVehicleInfoCard(InspectionVehicleModel vehicle) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: Vehicle number + status badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    vehicle.vehicleNo,
                    style: AppFonts.titleLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                _buildStatusBadge(vehicle.status),
              ],
            ),
            SizedBox(height: 12.h),

            // Brand + Type
            Row(
              children: [
                Icon(Icons.local_shipping_outlined,
                    size: 18.r, color: AppColors.primary),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    '${vehicle.vehicleBrand} — ${vehicle.vehicleType}',
                    style: AppFonts.bodyLarge.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),

            // Chassis number
            _buildInfoRow(
              icon: Icons.confirmation_number_outlined,
              label: 'Chassis No',
              value: vehicle.chasisNo,
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  LOCATION CARD
  // ══════════════════════════════════════════════════════════════

  Widget _buildLocationCard(InspectionVehicleModel vehicle) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Location',
              style: AppFonts.titleSmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 12.h),
            _buildInfoRow(
              icon: Icons.map_outlined,
              label: 'State',
              value: vehicle.vehicleState,
            ),
            SizedBox(height: 8.h),
            _buildInfoRow(
              icon: Icons.location_city_outlined,
              label: 'City',
              value: vehicle.vehicleCity,
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  OWNER CARD
  // ══════════════════════════════════════════════════════════════

  Widget _buildOwnerCard(InspectionVehicleModel vehicle) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Owner Information',
              style: AppFonts.titleSmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Icon(Icons.phone_outlined,
                    size: 18.r, color: AppColors.primary),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    vehicle.vehicleOwnerNumber,
                    style: AppFonts.bodyLarge.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                // Call button
                GestureDetector(
                  onTap: () => _makePhoneCall(vehicle.vehicleOwnerNumber),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.phone,
                            size: 14.r, color: AppColors.success),
                        SizedBox(width: 4.w),
                        Text(
                          'Call',
                          style: AppFonts.labelSmall.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  REPORT LINK
  // ══════════════════════════════════════════════════════════════

  Widget _buildReportLink(String url) {
    return GestureDetector(
      onTap: () => _launchUrl(url),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(Icons.description_outlined,
                  size: 22.r, color: AppColors.primary),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'View Full Report',
                    style: AppFonts.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Open inspection report in browser',
                    style: AppFonts.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.open_in_new, size: 20.r, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  HELPERS
  // ══════════════════════════════════════════════════════════════

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18.r, color: AppColors.grey500),
        SizedBox(width: 8.w),
        Text(
          '$label: ',
          style: AppFonts.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        Expanded(
          child: Text(
            value,
            style: AppFonts.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status.toLowerCase()) {
      case 'completed':
        bgColor = const Color(0xFFE8F5E9);
        textColor = const Color(0xFF2E7D32);
        label = 'Completed';
        break;
      case 'in_progress':
        bgColor = const Color(0xFFE3F2FD);
        textColor = const Color(0xFF1565C0);
        label = 'In Progress';
        break;
      case 'rejected':
        bgColor = const Color(0xFFFFEBEE);
        textColor = const Color(0xFFC62828);
        label = 'Rejected';
        break;
      case 'pending':
      default:
        bgColor = const Color(0xFFFFF3E0);
        textColor = const Color(0xFFEF6C00);
        label = 'Pending';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label,
        style: AppFonts.labelSmall.copyWith(
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}