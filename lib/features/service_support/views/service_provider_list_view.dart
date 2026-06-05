import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/atoms/custom_loader.dart';
import '../../../core/design_system/molecules/gradient_button.dart';
import '../../../core/design_system/templates/app_layout.dart';
import '../../../theme/app_fonts.dart';
import '../controllers/service_support_controller.dart';
import '../data/models/mechanic_model.dart';

class ServiceProviderListView extends GetView<ServiceSupportController> {
  const ServiceProviderListView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: 'Service Providers',
      subtitle: 'Find nearby mechanics and garages',
      showBack: true,
      body: Column(
        children: [
          // ── Search Bar ─────────────────────────────────────────

          // ── Count Badge ────────────────────────────────────────
          Obx(
            () => controller.totalCount.value > 0
                ? Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            '${controller.totalCount.value} providers found',
                            style: AppFonts.bodySmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          // ── Body ───────────────────────────────────────────────
          Expanded(
            child: Obx(() {
              // Loading shimmer
              if (controller.isLoading.value) {
                return _buildShimmerList();
              }

              // Empty state
              if (controller.hasAttemptedLoad.value &&
                  controller.mechanics.isEmpty) {
                return _buildEmptyState();
              }

              // Before load — show shimmer
              if (!controller.hasAttemptedLoad.value) {
                return _buildShimmerList();
              }

              // Filtered mechanics
              final query = controller.searchQuery.value.toLowerCase();
              final filtered = query.isEmpty
                  ? controller.mechanics
                  : controller.mechanics
                        .where(
                          (m) =>
                              m.mechanicName.toLowerCase().contains(query) ||
                              m.garageName.toLowerCase().contains(query) ||
                              m.state.toLowerCase().contains(query),
                        )
                        .toList();

              if (filtered.isEmpty && query.isNotEmpty) {
                return _buildNoResultsState();
              }

              return RefreshIndicator(
                onRefresh: () => controller.refreshMechanics(),
                color: AppColors.primary,
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  itemCount:
                      filtered.length + (controller.hasMore.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= filtered.length) {
                      return Obx(
                        () => controller.isLoadingMore.value
                            ? Padding(
                                padding: EdgeInsets.all(24.r),
                                child: const CustomLoader(),
                              )
                            : Padding(
                                padding: EdgeInsets.symmetric(vertical: 16.h),
                                child: GradientButton.filled(
                                  text: 'Load More',
                                  onPressed: () =>
                                      controller.loadMoreMechanics(),
                                  height: 48.h,
                                  fontSize: 16.sp,
                                ),
                              ),
                      );
                    }
                    return _buildMechanicCard(context, filtered[index]);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  //  MECHANIC CARD
  // ══════════════════════════════════════════════════════════════════

  Widget _buildMechanicCard(BuildContext context, Mechanic mechanic) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top section with primary info
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.05),
                  AppColors.primaryLight.withValues(alpha: 0.02),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r),
              ),
            ),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 56.w,
                  height: 56.h,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Center(
                    child: Text(
                      mechanic.mechanicName.isNotEmpty
                          ? mechanic.mechanicName[0].toUpperCase()
                          : 'M',
                      style: AppFonts.headlineSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 14.w),

                // Name & garage
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mechanic.mechanicName,
                        style: AppFonts.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        mechanic.garageName,
                        style: AppFonts.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (mechanic.description.isNotEmpty) ...[
                        SizedBox(height: 2.h),
                        Text(
                          mechanic.description,
                          style: AppFonts.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Details section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              children: [
                SizedBox(height: 12.h),

                // Address
                if (mechanic.fullAddress.isNotEmpty)
                  _buildInfoRow(
                    Icons.location_on_outlined,
                    AppColors.warning,
                    mechanic.fullAddress,
                  ),

                SizedBox(height: 10.h),

                // Rating & Distance row
                Row(
                  children: [
                    // Star rating — show individual stars
                    if (mechanic.rating > 0) ...[
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ...List.generate(5, (i) {
                              if (i < mechanic.rating.floor()) {
                                return Icon(
                                  Icons.star_rounded,
                                  size: 16.sp,
                                  color: Colors.amber,
                                );
                              } else if (i < mechanic.rating) {
                                return Icon(
                                  Icons.star_half_rounded,
                                  size: 16.sp,
                                  color: Colors.amber,
                                );
                              } else {
                                return Icon(
                                  Icons.star_border_rounded,
                                  size: 16.sp,
                                  color: Colors.amber.shade300,
                                );
                              }
                            }),
                            SizedBox(width: 4.w),
                            Text(
                              mechanic.starRating,
                              style: AppFonts.bodySmall.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.amber.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10.w),
                    ],

                    // Distance
                    if (mechanic.distanceKm > 0)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.info.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.near_me_rounded,
                              size: 16.sp,
                              color: AppColors.info,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              '${mechanic.distanceKm.toStringAsFixed(1)} km',
                              style: AppFonts.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.info,
                              ),
                            ),
                          ],
                        ),
                      ),

                    const Spacer(),

                    // Priority badge
                    if (mechanic.priority.isNotEmpty)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: _getPriorityColor(
                            mechanic.priority,
                          ).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          mechanic.priority.toUpperCase(),
                          style: AppFonts.bodySmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _getPriorityColor(mechanic.priority),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                  ],
                ),

                SizedBox(height: 12.h),
              ],
            ),
          ),

          // Divider
          Divider(height: 1, color: AppColors.divider.withValues(alpha: 0.3)),

          // Action button
          Padding(
            padding: EdgeInsets.all(12.r),
            child: Obx(
              () => controller.hasSubscription.value && mechanic.hasValidMobile
                  ? _buildCallButton(mechanic)
                  : _buildSubscribeButton(mechanic),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, Color color, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18.sp, color: color),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: AppFonts.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildCallButton(Mechanic mechanic) {
    return GradientButton.filled(
      text: 'Call ${mechanic.mechanicName}',
      onPressed: () => _makeDirectCall(mechanic),
      width: double.infinity,
      height: 48.h,
      fontSize: 15.sp,
    );
  }

  Widget _buildSubscribeButton(Mechanic mechanic) {
    return GradientButton.filled(
      text: 'Subscribe to Call',
      onPressed: () => controller.callMechanic(mechanic),
      width: double.infinity,
      height: 48.h,
      fontSize: 15.sp,
      backgroundColor: AppColors.warning,
    );
  }

  Future<void> _makeDirectCall(Mechanic mechanic) async {
    final Uri url = Uri.parse('tel:${mechanic.mobileNumber}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      Get.snackbar(
        'Error',
        'Could not launch phone dialer',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return AppColors.error;
      case 'medium':
        return AppColors.warning;
      default:
        return AppColors.success;
    }
  }

  // ══════════════════════════════════════════════════════════════════
  //  SHIMMER
  // ══════════════════════════════════════════════════════════════════

  Widget _buildShimmerList() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        itemCount: 4,
        itemBuilder: (_, __) => Container(
          margin: EdgeInsets.only(bottom: 16.h),
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 56.w,
                    height: 56.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 160.w,
                          height: 16.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Container(
                          width: 120.w,
                          height: 14.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Container(
                width: double.infinity,
                height: 14.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Container(
                    width: 80.w,
                    height: 28.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Container(
                    width: 70.w,
                    height: 28.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Container(
                width: double.infinity,
                height: 48.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  //  EMPTY / NO RESULTS
  // ══════════════════════════════════════════════════════════════════

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100.w,
              height: 100.h,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.build_circle_outlined,
                size: 50.sp,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'No Mechanics Found',
              style: AppFonts.titleLarge.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Text(
              'No service providers found near your location.\nTry again or expand your search area.',
              style: AppFonts.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            GradientButton.filled(
              text: 'Try Again',
              onPressed: () => controller.refreshMechanics(),
              height: 48.h,
              fontSize: 16.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64.sp,
              color: AppColors.textSecondary.withValues(alpha: 0.4),
            ),
            SizedBox(height: 16.h),
            Text(
              'No results found',
              style: AppFonts.titleMedium.copyWith(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8.h),
            Text(
              'Try a different search term',
              style: AppFonts.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
