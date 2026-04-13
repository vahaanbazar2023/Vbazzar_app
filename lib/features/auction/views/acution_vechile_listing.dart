import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/design_system/templates/app_layout.dart';
import '../../../core/design_system/tokens/app_radius.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../routes/app_routes.dart';
import '../controllers/vehicle_listing_controller.dart';
import '../models/vehicle_listing.dart';

class AuctionVehicleListingScreen extends GetView<VehicleListingController> {
  const AuctionVehicleListingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: 'Live Auctions',
      subtitle: '',
      showBack: true,
      body: Column(
        children: [
          SizedBox(height: AppSpacing.md),
          // Auction title (plain — auction is not reactive)
          if (controller.auction.auctionTitle.isNotEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: Text(
                controller.auction.auctionTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
            ),
          // Search bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: _VehicleSearchBar(controller: controller),
          ),
          SizedBox(height: AppSpacing.sm),
          // Vehicle content
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }
              final error = controller.errorMessage.value;
              if (error.isNotEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          error,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 14.sp,
                            color: AppColors.grey600,
                          ),
                        ),
                        SizedBox(height: AppSpacing.md),
                        GradientButton.filled(
                          text: 'Retry',
                          onPressed: controller.refresh,
                          width: 120.w,
                        ),
                      ],
                    ),
                  ),
                );
              }
              final vehicles = controller.filteredVehicles;
              if (vehicles.isEmpty) {
                return Center(
                  child: Text(
                    'No vehicles found',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14.sp,
                      color: AppColors.grey500,
                    ),
                  ),
                );
              }
              // Extra item at the end for the loading spinner
              final itemCount =
                  vehicles.length + (controller.isLoadingMore.value ? 1 : 0);
              return ListView.builder(
                controller: controller.scrollController,
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.md,
                ),
                itemCount: itemCount,
                itemBuilder: (_, index) {
                  if (index >= vehicles.length) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    );
                  }
                  return Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.md),
                    child: _VehicleCard(
                      vehicle: vehicles[index],
                      endAt: controller.auction.endAt,
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _VehicleSearchBar extends StatelessWidget {
  final VehicleListingController controller;

  const _VehicleSearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(24.r);
    return SizedBox(
      height: 44.h,
      child: TextField(
        controller: controller.searchController,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.search,
        textAlignVertical: TextAlignVertical.center,
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 13.sp,
          color: AppColors.grey900,
        ),
        onChanged: (_) => controller.currentIndex.value = 0,
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 20.r,
            color: AppColors.grey500,
          ),
          hintText: 'Search vehicles',
          hintStyle: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 13.sp,
            color: AppColors.grey500,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 12.h),
          isDense: true,
          filled: true,
          fillColor: AppColors.white,
          border: OutlineInputBorder(
            borderRadius: radius,
            borderSide: BorderSide(color: AppColors.grey300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: radius,
            borderSide: BorderSide(color: AppColors.grey300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: radius,
            borderSide: BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _VehicleCard extends StatelessWidget {
  final VehicleListing vehicle;
  final String endAt;

  const _VehicleCard({required this.vehicle, required this.endAt});

  @override
  Widget build(BuildContext context) {
    final v = vehicle;
    return Container(
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
          // ── Image carousel ───────────────────────────────────
          Stack(
            children: [
              NetworkImageCarousel(imageUrls: v.images, height: 200.h),
              Positioned(top: 0, right: 0, child: TimerBadge(endAt: endAt)),
            ],
          ),

          // ── Title ────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: AppColors.lightOrangeBackground.withOpacity(0.5),
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.sm,
                    AppSpacing.md,
                    0,
                  ),
                  child: Text(
                    '${v.make} ${v.model} - ${v.registrationNo}',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  ),
                ),
                // ── Bid info ─────────────────────────────────────────
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.sm,
                    AppSpacing.md,
                    0,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _BidInfoRow(
                            label: 'Bids Left',
                            value: v.bidsLeft.toString().padLeft(2, '0'),
                          ),
                          SizedBox(width: AppSpacing.xxl),
                          _BidInfoRow(
                            label: 'Bids Received',
                            value: v.bidsReceived.toString().padLeft(2, '0'),
                          ),
                        ],
                      ),

                      Row(
                        children: [
                          Text(
                            'Bid Start Price:',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 14.sp,
                              color: AppColors.lightOrangeDark,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: AppSpacing.md),
                          GradientText(
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
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.sm),
                // ── Bottom: Bid Start Price + Bid Now ────────────────
                Container(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.sm,
                    AppSpacing.md,
                    AppSpacing.md,
                  ),

                  child: Column(
                    children: [
                      SizedBox(width: AppSpacing.md),
                      GradientButton.filled(
                        text: 'Bid Now',
                        onPressed: () => Get.toNamed(
                          AppRoutes.vehicleDetail,
                          arguments: {'vehicle': v, 'endAt': endAt},
                        ),
                        isLoading: false,
                      ),
                      SizedBox(height: AppSpacing.md),
                      GradientButton.outlined(
                        text: 'View more details',
                        backgroundColor: Colors.transparent,
                        onPressed: () => Get.toNamed(
                          AppRoutes.vehicleDetail,
                          arguments: {'vehicle': v, 'endAt': endAt},
                        ),
                        isLoading: false,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(int price) {
    if (price == 0) return '0';
    final s = price.toString();
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

class _BidInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _BidInfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label :',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 14.sp,
              color: AppColors.lightOrangeDark,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
          ),
        ],
      ),
    );
  }
}
