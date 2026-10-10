import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/design_system/templates/app_layout.dart';
import '../controllers/sell_vehicle_controller.dart';
import '../data/repositories/buy_sell_repository_impl.dart';
import '../domain/entities/sell_vehicle_entity.dart';
import 'buy_vehicle_details_view.dart';

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
      title: context.l10n.myVehicles,
      subtitle: context.l10n.spareYourPostedVehicleListings,
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
                    onDetails: () => _openDetails(vehicles[i]),
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

  void _openDetails(SellVehicleEntity v) {
    Get.to(
      () => const BuyVehicleDetailsView(ownerMode: true),
      arguments: {
        'sb_vehicle_id': v.sbVehicleId,
        'category_code': v.categoryCode ?? '',
      },
    );
  }

  void _confirmMarkSold(SellVehicleEntity v) {
    Get.defaultDialog(
      title: context.l10n.spareMarkAsSold,
      middleText: context.l10n.spareMarkVehicleAsSoldPrompt(
        '${v.brandName ?? ''} ${v.model ?? ''}'.trim(),
      ),
      textConfirm: context.l10n.spareConfirm,
      textCancel: context.l10n.cancel,
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
      title: context.l10n.spareMarkAsAvailable,
      middleText: context.l10n.spareMarkVehicleAsAvailablePrompt(
        '${v.brandName ?? ''} ${v.model ?? ''}'.trim(),
      ),
      textConfirm: context.l10n.spareConfirm,
      textCancel: context.l10n.cancel,
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
  final VoidCallback onDetails;
  final VoidCallback onMarkSold;
  final VoidCallback onMarkUnsold;
  const _MyVehicleCard({
    required this.vehicle,
    required this.onDetails,
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

    return GestureDetector(
      onTap: onDetails,
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
                        Flexible(
                          child: Text(
                            vehicle.statusLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
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
                        ? (vehicle.categoryName ?? context.l10n.spareVehicle)
                        : '${vehicle.brandName ?? ''} ${vehicle.model ?? ''}'
                              .trim(),
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
                  Row(
                    children: [
                      if (vehicle.year != null) ...[
                        _chip(Icons.calendar_today_outlined, vehicle.year!),
                        SizedBox(width: AppSpacing.xs),
                      ],
                      if (vehicle.registrationNumber != null) ...[
                        _chip(
                          Icons.badge_outlined,
                          vehicle.registrationNumber!,
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          vehicle.formattedPrice,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Flexible(
                        child: Wrap(
                          alignment: WrapAlignment.end,
                          spacing: 8.w,
                          runSpacing: 6.h,
                          children: [
                            _pill(
                              context.l10n.aucDetails,
                              onTap: onDetails,
                              filled: true,
                            ),
                            if (!vehicle.isVehicleSold)
                              _pill(
                                context.l10n.spareMarkSold,
                                onTap: onMarkSold,
                                tint: AppColors.primary,
                              )
                            else
                              _pill(
                                context.l10n.spareMarkAvailable,
                                onTap: onMarkUnsold,
                                tint: AppColors.grey600,
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

  /// Small rounded action pill. [filled] uses the brand gradient.
  Widget _pill(
    String text, {
    required VoidCallback onTap,
    bool filled = false,
    Color tint = AppColors.primary,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
        decoration: BoxDecoration(
          gradient: filled
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.ctaGradientStart,
                    AppColors.ctaGradientEnd,
                  ],
                )
              : null,
          color: filled ? null : tint.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: filled
              ? null
              : Border.all(color: tint.withValues(alpha: 0.3)),
        ),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: filled ? Colors.white : tint,
          ),
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
                context.l10n.retry,
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
            context.l10n.spareNoPostedVehiclesYet,
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
            context.l10n.spareTapSellToPostVehicle,
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
