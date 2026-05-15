import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
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
              Text('Vehicle details not available',
                  style: AppFonts.bodyMedium
                      .copyWith(color: AppColors.textSecondary)),
              SizedBox(height: 16.h),
              _actionButton('Go Back', () => Get.back(), AppColors.primary),
            ],
          ),
        ),
      );
    }

    return AppLayout(
      title: 'Vehicle Details',
      subtitle: listing.registrationNumber,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image Carousel ──────────────────────────────────
            _buildImageCarousel(listing),
            SizedBox(height: AppSpacing.lg),

            // ── Title Section ───────────────────────────────────
            _buildTitleSection(listing),
            SizedBox(height: AppSpacing.md),
            Divider(color: AppColors.grey200, thickness: 1),
            SizedBox(height: AppSpacing.md),

            // ── Detail Rows ─────────────────────────────────────
            _buildDetailRows(listing),
            SizedBox(height: AppSpacing.xl),

            // ── Action Buttons ──────────────────────────────────
            _buildActionButtons(listing, ctrl),
            SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCarousel(ApprovedVehicleListingEntity listing) {
    final images = listing.files?.images ?? [];
    if (images.isEmpty) {
      return Container(
        height: 220.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.grey100,
          borderRadius: AppRadius.borderRadiusMd,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_not_supported_outlined,
                  size: 48.w, color: AppColors.grey400),
              SizedBox(height: 8.h),
              Text('No Images Available',
                  style:
                      AppFonts.bodyMedium.copyWith(color: AppColors.grey400)),
            ],
          ),
        ),
      );
    }

    return _ImageCarousel(images: images.map((e) => e.fileUrl).toList());
  }

  Widget _buildTitleSection(ApprovedVehicleListingEntity listing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${listing.brand ?? "Vehicle"} | ${listing.yearOfManufacturing}',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.black,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          '${listing.approvedVehicleId} • ${listing.assetDescription}',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 13.sp,
            color: AppColors.grey600,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRows(ApprovedVehicleListingEntity listing) {
    final rows = <_DetailRowData>[
      _DetailRowData('Category', listing.categoryType),
      _DetailRowData('Price', '₹${_formatPrice(listing.price)}'),
      _DetailRowData('Registration No.', listing.registrationNumber),
      _DetailRowData('Chassis Number', listing.chassisNumber),
      _DetailRowData('State', listing.stateName),
      _DetailRowData('City', listing.cityName),
      _DetailRowData('Fitness Certificate', listing.fitnessAvailable),
      _DetailRowData('Original Invoice', listing.originalInvoiceAvailable),
      _DetailRowData(
        'Insurance Valid Until',
        _formatDate(listing.vehicleInsuranceDate),
      ),
      _DetailRowData('GST Applicable', listing.gstApplicable),
      _DetailRowData(
        'RC Document',
        (listing.files?.rcDocuments.isNotEmpty == true) ? 'Yes' : 'No',
      ),
      _DetailRowData(
        'Insurance Document',
        (listing.files?.insuranceDocuments.isNotEmpty == true) ? 'Yes' : 'No',
      ),
      _DetailRowData(
        'Offer Ends On',
        '${_formatDate(listing.offerEndDate)} ${listing.offerEndTime}',
      ),
      _DetailRowData('Status', listing.vehicleStatus.toUpperCase()),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.borderRadiusMd,
        border: Border.all(color: AppColors.grey200),
      ),
      child: ClipRRect(
        borderRadius: AppRadius.borderRadiusMd,
        child: Column(
          children: List.generate(rows.length, (index) {
            final row = rows[index];
            final isEven = index % 2 == 0;
            // Hide null/empty values
            if (row.value.isEmpty || row.value.toLowerCase() == 'null') {
              return const SizedBox.shrink();
            }
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              color: isEven ? Colors.white : AppColors.grey100.withOpacity(0.5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 130.w,
                    child: Text(
                      row.label,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.grey600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      row.value,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildActionButtons(
      ApprovedVehicleListingEntity listing, ApprovedVehicleController ctrl) {
    final isBooked = listing.isBooked == 'yes';
    final isInspectionRequested = listing.inspectionRequested == 'yes';

    return Row(
      children: [
        // ── Book Now ──────────────────────────────────────────
        Expanded(
          child: _actionButton(
            isBooked ? 'Booked' : 'Book Now',
            isBooked
                ? null
                : () => _showPaymentDialog(
                      title: 'Book Vehicle',
                      description:
                          'Pay to book this vehicle and access full details.',
                      amount: listing.categorySubscription?.subscriptionAmount,
                      planCode:
                          listing.categorySubscription?.apprVehCommonSubPlan,
                      approvedVehicleId: listing.approvedVehicleId,
                      subscriptionType: 'category',
                      regNo: listing.registrationNumber,
                      ctrl: ctrl,
                    ),
            isBooked ? AppColors.grey400 : AppColors.primary,
          ),
        ),
        SizedBox(width: 12.w),
        // ── Inspection ────────────────────────────────────────
        Expanded(
          child: _actionButton(
            isInspectionRequested ? 'Requested' : 'Inspection',
            isInspectionRequested
                ? null
                : () => _showPaymentDialog(
                      title: 'Request Vehicle Inspection',
                      description:
                          'Pay to request professional inspection for this vehicle.',
                      amount: listing
                          .inspectionSubscription?.inspectionAmount,
                      planCode:
                          listing.inspectionSubscription?.categoryPlan,
                      approvedVehicleId: listing.approvedVehicleId,
                      subscriptionType: 'inspection',
                      regNo: listing.registrationNumber,
                      ctrl: ctrl,
                    ),
            isInspectionRequested ? AppColors.grey400 : AppColors.success,
          ),
        ),
      ],
    );
  }

  void _showPaymentDialog({
    required String title,
    required String description,
    required double? amount,
    required String? planCode,
    required String approvedVehicleId,
    required String subscriptionType,
    required String regNo,
    required ApprovedVehicleController ctrl,
  }) {
    if (amount == null || planCode == null) {
      Get.snackbar(
        'Error',
        subscriptionType == 'category'
            ? 'Category subscription not available'
            : 'Inspection subscription not available',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
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
              Icon(Icons.verified_rounded,
                  size: 48.w, color: AppColors.primary),
              SizedBox(height: 12.h),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Text(
                description,
                style:
                    AppFonts.bodyMedium.copyWith(color: AppColors.grey600),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 20.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  '₹${_formatPrice(amount)}',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.grey300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      child: Text(
                        'Cancel',
                        style: AppFonts.bodyMedium.copyWith(
                          color: AppColors.grey600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        _processPayment(
                          planCode: planCode,
                          approvedVehicleId: approvedVehicleId,
                          subscriptionType: subscriptionType,
                          regNo: regNo,
                          ctrl: ctrl,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        elevation: 0,
                      ),
                      child: Text(
                        'Pay Now',
                        style: AppFonts.bodyMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
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
      barrierDismissible: false,
    );
  }

  Future<void> _processPayment({
    required String planCode,
    required String approvedVehicleId,
    required String subscriptionType,
    required String regNo,
    required ApprovedVehicleController ctrl,
  }) async {
    try {
      // Direct book/inspection without PayU for now
      bool success;
      if (subscriptionType == 'category') {
        success = await ctrl.bookVehicle(approvedVehicleId);
      } else {
        success = await ctrl.requestInspection(approvedVehicleId);
      }

      if (success) {
        Get.snackbar(
          'Success',
          subscriptionType == 'category'
              ? 'Vehicle booked successfully!'
              : 'Inspection requested successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
        );
        // Refresh listings
        if (ctrl.listings.isNotEmpty) {
          // Update local listing state
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Payment processing failed. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    }
  }

  static Widget _actionButton(String text, VoidCallback? onPressed, Color color) {
    return SizedBox(
      height: 46.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: onPressed == null ? color.withOpacity(0.2) : color,
          foregroundColor: onPressed == null ? AppColors.grey600 : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    if (price == 0) return '0';
    final formatter = NumberFormat('#,##,###', 'en_IN');
    return formatter.format(price.toInt());
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty || dateStr.toLowerCase() == 'null') return '';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Image Carousel
// ─────────────────────────────────────────────────────────────────────────────

class _ImageCarousel extends StatefulWidget {
  final List<String> images;
  const _ImageCarousel({required this.images});

  @override
  State<_ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<_ImageCarousel> {
  final _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 220.h,
          decoration: BoxDecoration(
            borderRadius: AppRadius.borderRadiusMd,
            border: Border.all(color: AppColors.grey200),
          ),
          child: ClipRRect(
            borderRadius: AppRadius.borderRadiusMd,
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: widget.images.length,
                  onPageChanged: (i) => setState(() => _currentIndex = i),
                  itemBuilder: (_, i) {
                    return Image.network(
                      widget.images[i],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.grey100,
                        child: Center(
                          child: Icon(Icons.broken_image_outlined,
                              size: 40.w, color: AppColors.grey400),
                        ),
                      ),
                    );
                  },
                ),
                // Left arrow
                if (_currentIndex > 0)
                  Positioned(
                    left: 8.w,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: GestureDetector(
                        onTap: () => _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        ),
                        child: Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.arrow_back_ios_new,
                              size: 16.w, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                // Right arrow
                if (_currentIndex < widget.images.length - 1)
                  Positioned(
                    right: 8.w,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: GestureDetector(
                        onTap: () => _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        ),
                        child: Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.arrow_forward_ios,
                              size: 16.w, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                // Page indicator dots
                if (widget.images.length > 1)
                  Positioned(
                    bottom: 8.h,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        widget.images.length,
                        (i) => Container(
                          width: i == _currentIndex ? 16.w : 6.w,
                          height: 6.h,
                          margin: EdgeInsets.symmetric(horizontal: 2.w),
                          decoration: BoxDecoration(
                            color: i == _currentIndex
                                ? AppColors.primary
                                : Colors.white54,
                            borderRadius: BorderRadius.circular(3.r),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _DetailRowData {
  final String label;
  final String value;
  _DetailRowData(this.label, this.value);
}