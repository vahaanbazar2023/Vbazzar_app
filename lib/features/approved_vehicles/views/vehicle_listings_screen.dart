import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/loaders/loading_widget.dart';
import '../../../core/design_system/templates/app_layout.dart';
import '../../../core/design_system/tokens/app_radius.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_fonts.dart';
import '../controllers/approved_vehicle_controller.dart';
import '../domain/entities/approved_vehicle_category_entity.dart';
import '../domain/entities/approved_vehicle_listing_entity.dart';

class VehicleListingsScreen extends StatefulWidget {
  const VehicleListingsScreen({super.key});

  @override
  State<VehicleListingsScreen> createState() => _VehicleListingsScreenState();
}

class _VehicleListingsScreenState extends State<VehicleListingsScreen> {
  final _scrollController = ScrollController();
  late final ApprovedVehicleController ctrl;
  late final ApprovedVehicleCategoryEntity category;

  @override
  void initState() {
    super.initState();
    ctrl = Get.find<ApprovedVehicleController>();
    final args = Get.arguments as Map<String, dynamic>;
    category = args['category'] as ApprovedVehicleCategoryEntity;
    // Clear old listings immediately so shimmer shows for new category
    ctrl.listings.clear();
    ctrl.listingsError.value = '';
    ctrl.fetchListings(categoryType: category.categoryCode);
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final current = _scrollController.position.pixels;
    final threshold = maxScroll * 0.9;
    final thresholdPx = maxScroll - 50.0;
    final trigger = threshold < thresholdPx ? threshold : thresholdPx;
    if (current >= trigger) {
      ctrl.loadMoreListings();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: category.categoryName,
      subtitle: 'Approved vehicles available',
      body: Obx(() {
        if (ctrl.isLoadingListings.value && ctrl.listings.isEmpty) {
          return _buildShimmerList();
        }
        if (ctrl.listingsError.value.isNotEmpty && ctrl.listings.isEmpty) {
          return _buildErrorState();
        }
        if (ctrl.listings.isEmpty) {
          return _buildEmptyState();
        }
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => ctrl.fetchListings(
            categoryType: category.categoryCode,
            isRefresh: true,
          ),
          child: ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.all(AppSpacing.md),
            itemCount: ctrl.listings.length +
                (ctrl.isLoadingMoreListings.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= ctrl.listings.length) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: const Center(
                    child:
                        CircularProgressIndicator(color: AppColors.primary),
                  ),
                );
              }
              return Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.md),
                child: _VehicleListingCard(
                  listing: ctrl.listings[index],
                  onTap: () => Get.toNamed(
                    AppRoutes.approvedVehicleDetail,
                    arguments: {'listing': ctrl.listings[index]},
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: EdgeInsets.all(AppSpacing.md),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.md),
          child: _ShimmerCard(),
        );
      },
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 48.w, color: AppColors.error),
            SizedBox(height: 12.h),
            Text(
              ctrl.listingsError.value,
              style: AppFonts.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            GestureDetector(
              onTap: () => ctrl.fetchListings(
                categoryType: category.categoryCode,
                isRefresh: true,
              ),
              child: Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'Retry',
                  style: AppFonts.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
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
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.directions_car_outlined,
                size: 56.w, color: AppColors.grey400),
            SizedBox(height: 12.h),
            Text(
              'No vehicles available',
              style: AppFonts.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
            ),
            SizedBox(height: 8.h),
            Text(
              'Pull down to refresh',
              style:
                  AppFonts.bodySmall.copyWith(color: AppColors.textDisabled),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Vehicle Listing Card
// ─────────────────────────────────────────────────────────────────────────────

class _VehicleListingCard extends StatelessWidget {
  final ApprovedVehicleListingEntity listing;
  final VoidCallback onTap;

  const _VehicleListingCard({required this.listing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        listing.files?.images.isNotEmpty == true
            ? listing.files!.images.first.fileUrl
            : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
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
            // ── Image ────────────────────────────────────────────
            SizedBox(
              height: 180.h,
              width: double.infinity,
              child: imageUrl != null
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _imagePlaceholder(),
                    )
                  : _imagePlaceholder(),
            ),

            // ── Info ─────────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: AppColors.lightOrangeBackground.withOpacity(0.3),
              ),
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Registration + Year
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            listing.registrationNumber,
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.black,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            '${listing.yearOfManufacturing}',
                            style: AppFonts.bodySmall.copyWith(
                              color: AppColors.successDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      listing.assetDescription,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 13.sp,
                        color: AppColors.grey600,
                      ),
                    ),
                    SizedBox(height: 8.h),

                    // Location + Price Row
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Icon(Icons.location_on_outlined,
                                  size: 14.w, color: AppColors.grey500),
                              SizedBox(width: 4.w),
                              Flexible(
                                child: Text(
                                  '${listing.cityName}, ${listing.stateName}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppFonts.bodySmall.copyWith(
                                    color: AppColors.grey600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          '₹${_formatPrice(listing.price)}',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    // Know More Button
                    SizedBox(
                      width: double.infinity,
                      height: 40.h,
                      child: ElevatedButton(
                        onPressed: onTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Know More',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: AppColors.grey100,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.directions_car_outlined,
                size: 40.w, color: AppColors.grey400),
            SizedBox(height: 4.h),
            Text(
              'No Image',
              style: AppFonts.bodySmall.copyWith(color: AppColors.grey400),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    if (price == 0) return '0';
    final s = price.toInt().toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buffer.write(',');
      buffer.write(s[i]);
      count++;
    }
    return buffer.toString().split('').reversed.join('');
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shimmer Card Skeleton — mirrors the actual _VehicleListingCard layout
// ─────────────────────────────────────────────────────────────────────────────

class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.borderRadiusMd,
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image placeholder ──────────────────────────────────
          SkeletonBox(
            width: double.infinity,
            height: 180.h,
            radius: 0,
          ),

          // ── Info section ──────────────────────────────────────
          Container(
            color: AppColors.lightOrangeBackground.withOpacity(0.3),
            padding: EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Registration + Year row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SkeletonBox(width: 140.w, height: 16.h, radius: 6),
                    SkeletonBox(width: 48.w, height: 16.h, radius: 6),
                  ],
                ),
                SizedBox(height: 8.h),
                // Description line
                SkeletonBox(width: 200.w, height: 14.h, radius: 6),
                SizedBox(height: 12.h),
                // Location + Price row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SkeletonBox(width: 120.w, height: 14.h, radius: 6),
                    SkeletonBox(width: 80.w, height: 18.h, radius: 6),
                  ],
                ),
                SizedBox(height: 16.h),
                // Button placeholder
                SkeletonBox(
                    width: double.infinity, height: 40.h, radius: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
