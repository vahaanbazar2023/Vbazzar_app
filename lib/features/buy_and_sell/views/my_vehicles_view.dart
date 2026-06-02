import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/design_system/templates/app_layout.dart';
import '../controllers/sell_vehicle_controller.dart';
import '../data/repositories/buy_sell_repository_impl.dart';
import '../domain/entities/sell_vehicle_entity.dart';

class MyVehiclesView extends StatefulWidget {
  const MyVehiclesView({super.key});

  @override
  State<MyVehiclesView> createState() => _MyVehiclesViewState();
}

class _MyVehiclesViewState extends State<MyVehiclesView> {
  late final SellVehicleController controller;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<SellVehicleController>()) {
      Get.put(SellVehicleController(repository: BuySellRepositoryImpl()));
    }
    controller = Get.find<SellVehicleController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchSellVehiclesList(isRefresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: 'My Vehicles',
      subtitle: 'Your posted vehicle listings',
      body: Obx(() {
        // ── Loading ─────────────────────────────────────────────────────────
        if (controller.isLoadingSellVehicles.value &&
            controller.sellVehicles.isEmpty) {
          return _ShimmerList();
        }
        // ── Error ───────────────────────────────────────────────────────────
        if (controller.hasErrorSellVehicles.value &&
            controller.sellVehicles.isEmpty) {
          return _ErrorState(
            message: controller.errorMessageSellVehicles.value,
            onRetry: () => controller.fetchSellVehiclesList(isRefresh: true),
          );
        }
        final vehicles = controller.sellVehicles;
        // ── Empty ───────────────────────────────────────────────────────────
        if (vehicles.isEmpty) {
          return const _EmptyState();
        }
        // ── List ────────────────────────────────────────────────────────────
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => controller.refreshSellVehiclesList(),
          child: NotificationListener<ScrollNotification>(
            onNotification: (n) {
              if (n is ScrollEndNotification &&
                  n.metrics.pixels >= n.metrics.maxScrollExtent - 150) {
                controller.loadMoreSellVehicles();
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
                  vehicles.length +
                  (controller.isLoadingMoreSellVehicles.value ? 1 : 0),
              itemBuilder: (_, i) {
                if (i == vehicles.length) {
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
                  child: _MyVehicleCard(
                    vehicle: vehicles[i],
                    onMarkSold: () => _confirmMarkSold(vehicles[i]),
                    onMarkUnsold: () => _confirmMarkUnsold(vehicles[i]),
                  ),
                );
              },
            ),
          ),
        );
      }),
    );
  }

  void _confirmMarkSold(SellVehicleEntity v) {
    Get.defaultDialog(
      title: 'Mark as Sold',
      middleText:
          'Mark "${v.brandName ?? ''} ${v.model ?? ''}".trim() as sold?',
      textConfirm: 'Confirm',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.primary,
      onConfirm: () {
        Get.back();
        controller.markAsSold(v.sbVehicleId);
      },
    );
  }

  void _confirmMarkUnsold(SellVehicleEntity v) {
    Get.defaultDialog(
      title: 'Mark as Available',
      middleText:
          'Mark "${v.brandName ?? ''} ${v.model ?? ''}".trim() as available?',
      textConfirm: 'Confirm',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.primary,
      onConfirm: () {
        Get.back();
        controller.markAsUnsold(v.sbVehicleId);
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// My Vehicle Card — same structure as buy vehicle card + status badge + actions
// ─────────────────────────────────────────────────────────────────────────────

class _MyVehicleCard extends StatelessWidget {
  final SellVehicleEntity vehicle;
  final VoidCallback onMarkSold;
  final VoidCallback onMarkUnsold;
  const _MyVehicleCard({
    required this.vehicle,
    required this.onMarkSold,
    required this.onMarkUnsold,
  });

  Color get _statusColor {
    if (vehicle.isVehicleSold) return AppColors.grey600;
    if (vehicle.isRejected) return AppColors.error;
    if (vehicle.isApproved) return AppColors.success;
    if (vehicle.isPending) return AppColors.warning;
    return AppColors.grey500;
  }

  IconData get _statusIcon {
    if (vehicle.isVehicleSold) return Icons.sell_outlined;
    if (vehicle.isRejected) return Icons.cancel_outlined;
    if (vehicle.isApproved) return Icons.check_circle_outline;
    return Icons.schedule_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = vehicle.primaryImageUrl;

    return Container(
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
          // ── Image with status badge overlay ─────────────────────────────
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
              // Status badge top-right
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: _statusColor.withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_statusIcon, size: 12.sp, color: Colors.white),
                      SizedBox(width: 4.w),
                      Text(
                        vehicle.statusLabel,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 11.sp,
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

          // ── Details ─────────────────────────────────────────────────────
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
                    if (vehicle.year != null) ...[
                      _chip(Icons.calendar_today_outlined, vehicle.year!),
                      SizedBox(width: AppSpacing.xs),
                    ],
                    if (vehicle.registrationNumber != null) ...[
                      _chip(Icons.badge_outlined, vehicle.registrationNumber!),
                    ],
                  ],
                ),
                SizedBox(height: AppSpacing.sm),
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
                    // Action button
                    if (!vehicle.isVehicleSold)
                      GestureDetector(
                        onTap: onMarkSold,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 7.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            'Mark Sold',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: onMarkUnsold,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 7.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.grey100,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.grey300),
                          ),
                          child: Text(
                            'Mark Available',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.grey600,
                            ),
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

  Widget _chip(IconData icon, String text) => Row(
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

// ─────────────────────────────────────────────────────────────────────────────
// States — same as buy listings
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
            Icons.directions_car_outlined,
            size: 64,
            color: AppColors.grey300,
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            "You haven't posted any vehicles yet",
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.grey700,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            'Tap Sell on any category to post your vehicle',
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
