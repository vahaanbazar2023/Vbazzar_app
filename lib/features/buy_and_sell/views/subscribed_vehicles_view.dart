import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/design_system/templates/app_layout.dart';
import '../controllers/vehicle_detail_controller.dart';
import '../data/repositories/buy_sell_repository_impl.dart';
import '../domain/entities/subscribed_vehicle_entity.dart';
import '../../../routes/app_routes.dart';

class SubscribedVehiclesView extends StatefulWidget {
  const SubscribedVehiclesView({super.key});

  @override
  State<SubscribedVehiclesView> createState() => _SubscribedVehiclesViewState();
}

class _SubscribedVehiclesViewState extends State<SubscribedVehiclesView> {
  late final BuyVehicleController controller;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<BuyVehicleController>()) {
      Get.put(BuyVehicleController(repository: BuySellRepositoryImpl()));
    }
    controller = Get.find<BuyVehicleController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchSubscribedVehicles(isRefresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: 'Subscribed Vehicles',
      subtitle: 'Vehicles you have premium access to',
      body: Obx(() {
        // ── Loading ───────────────────────────────────────────────────────
        if (controller.isLoadingSubscribed.value &&
            controller.subscribedVehicles.isEmpty) {
          return _ShimmerList();
        }
        // ── Error ─────────────────────────────────────────────────────────
        if (controller.hasErrorSubscribed.value &&
            controller.subscribedVehicles.isEmpty) {
          return _ErrorState(
            message: controller.errorMessageSubscribed.value,
            onRetry: () => controller.fetchSubscribedVehicles(isRefresh: true),
          );
        }
        // ── Empty ─────────────────────────────────────────────────────────
        if (controller.subscribedVehicles.isEmpty) {
          return const _EmptyState();
        }
        // ── List ──────────────────────────────────────────────────────────
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => controller.refreshSubscribedVehicles(),
          child: NotificationListener<ScrollNotification>(
            onNotification: (n) {
              if (n is ScrollEndNotification &&
                  n.metrics.pixels >= n.metrics.maxScrollExtent - 150) {
                controller.loadMoreSubscribedVehicles();
              }
              return false;
            },
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                100,
              ),
              itemCount:
                  controller.subscribedVehicles.length +
                  (controller.isLoadingMoreSubscribed.value ? 1 : 0),
              itemBuilder: (_, i) {
                if (i == controller.subscribedVehicles.length) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 2,
                      ),
                    ),
                  );
                }
                return Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.md),
                  child: _SubscribedCard(
                    vehicle: controller.subscribedVehicles[i],
                  ),
                );
              },
            ),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Subscribed Vehicle Card — same layout as buy vehicle card
// + owner mobile + subscription badges
// ─────────────────────────────────────────────────────────────────────────────

class _SubscribedCard extends StatelessWidget {
  final SubscribedVehicleEntity vehicle;
  const _SubscribedCard({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    final imageUrl = vehicle.imageUrls.isNotEmpty
        ? vehicle.imageUrls.first
        : '';

    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoutes.buyVehicleDetail,
        arguments: {'vehicleId': vehicle.sbVehicleId},
      ),
      child: Container(
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
            // ── Image ────────────────────────────────────────────────────
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppRadius.lg),
                    topRight: Radius.circular(AppRadius.lg),
                  ),
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          height: 180.h,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholder(),
                        )
                      : _placeholder(),
                ),
                // Premium access badge
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 5.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 12.sp,
                          color: Colors.white,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'Premium Access',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // ── Details ──────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${vehicle.brandName ?? ''} ${vehicle.model ?? ''}'
                            .trim()
                            .isEmpty
                        ? (vehicle.categoryName ?? 'Vehicle')
                        : '${vehicle.brandName ?? ''} ${vehicle.model ?? ''}'
                              .trim(),
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      _chip(
                        Icons.calendar_today_outlined,
                        '${vehicle.manufacturingYear ?? ''}',
                      ),
                      SizedBox(width: AppSpacing.xs),
                      _chip(Icons.location_on_outlined, vehicle.location ?? ''),
                    ],
                  ),
                  SizedBox(height: AppSpacing.sm),

                  // ── Owner mobile (visible due to premium access) ────────
                  if (vehicle.ownerMobile != null &&
                      vehicle.ownerMobile!.isNotEmpty) ...[
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.phone_outlined,
                            size: 14.sp,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            vehicle.ownerMobile!,
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppSpacing.sm),
                  ],

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        vehicle.formattedPrice,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 7.h,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.ctaGradientStart,
                              AppColors.ctaGradientEnd,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'View Details',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
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

  Widget _placeholder() => Container(
    height: 180.h,
    width: double.infinity,
    color: AppColors.grey100,
    child: Center(
      child: Icon(
        Icons.directions_car_rounded,
        size: 48,
        color: AppColors.grey300,
      ),
    ),
  );

  Widget _chip(IconData icon, String text) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.grey500),
        SizedBox(width: 3),
        Text(
          text,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 11.sp,
            color: AppColors.grey600,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// States — identical to buy listings
// ─────────────────────────────────────────────────────────────────────────────

class _ShimmerList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(AppSpacing.md),
      itemCount: 4,
      itemBuilder: (_, __) => Padding(
        padding: EdgeInsets.only(bottom: AppSpacing.md),
        child: Container(
          height: 280.h,
          decoration: BoxDecoration(
            color: AppColors.grey100,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 56, color: AppColors.grey300),
            SizedBox(height: AppSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14.sp,
                color: AppColors.grey600,
              ),
            ),
            SizedBox(height: AppSpacing.md),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                'Retry',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.bookmark_border_rounded,
            size: 64,
            color: AppColors.grey300,
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'No subscribed vehicles',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.grey700,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            'Vehicles you get premium access to will appear here',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 13.sp,
              color: AppColors.grey500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
