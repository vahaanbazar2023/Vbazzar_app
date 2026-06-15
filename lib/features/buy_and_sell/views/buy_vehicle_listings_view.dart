import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/design_system/molecules/custom_snackbar.dart';
import '../../../core/design_system/organisms/network_image_carousel.dart';
import '../widgets/buy_filter_sheet.dart';
import '../../../core/design_system/templates/app_layout.dart';
import '../../../routes/app_routes.dart';
import '../../subscription/models/user_subscription.dart';
import '../../subscription/services/subscription_guard_service.dart';
import '../controllers/vehicle_detail_controller.dart';
import '../domain/entities/buy_vehicle_entity.dart';
import '../domain/entities/vehicle_category_entity.dart';

class BuyVehicleListingsView extends GetView<BuyVehicleController> {
  const BuyVehicleListingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final category = args['category'] as VehicleCategoryEntity?;

    // Select category on first build
    if (category != null &&
        controller.selectedCategory.value?.categoryCode !=
            category.categoryCode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.selectCategory(category);
      });
    }

    final categoryName = category?.categoryName ?? 'Vehicles';

    return AppLayout(
      title: categoryName,
      subtitle: 'Browse available listings',
      body: Column(
        children: [
          // ── Search bar + filter icon (white section) ──────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              0,
            ),
            child: Row(
              children: [
                // Search field
                Expanded(
                  child: SizedBox(
                    height: 44.h,
                    child: TextField(
                      controller: controller.searchController,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 13.sp,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search vehicles...',
                        hintStyle: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 13.sp,
                          color: AppColors.grey400,
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: AppColors.grey400,
                          size: 18,
                        ),
                        suffixIcon: Obx(
                          () => controller.searchQuery.value.isNotEmpty
                              ? GestureDetector(
                                  onTap: () =>
                                      controller.searchController.clear(),
                                  child: const Icon(
                                    Icons.close_rounded,
                                    color: AppColors.grey400,
                                    size: 16,
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                        isDense: true,
                        filled: true,
                        fillColor: AppColors.grey50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.grey200,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.grey200,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                // Filter icon button
                Obx(() {
                  final hasFilters = controller.appliedFilters.isNotEmpty;
                  return GestureDetector(
                    onTap: () => _showFilterSheet(context, controller),
                    child: Container(
                      width: 44.h,
                      height: 44.h,
                      decoration: BoxDecoration(
                        color: hasFilters
                            ? AppColors.primary
                            : AppColors.grey50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: hasFilters
                              ? AppColors.primary
                              : AppColors.grey200,
                        ),
                      ),
                      child: Icon(
                        Icons.tune_rounded,
                        size: 20,
                        color: hasFilters ? Colors.white : AppColors.grey600,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          // ── Active filters strip ──────────────────────────────────────────
          Obx(() {
            if (controller.appliedFilters.isEmpty)
              return const SizedBox.shrink();
            return _ActiveFiltersStrip(controller: controller);
          }),
          // ── Vehicle list ──────────────────────────────────────────────────
          Expanded(
            child: Obx(() {
              if (controller.isLoadingBuyVehicles.value &&
                  controller.buyVehicles.isEmpty) {
                return _ShimmerList();
              }
              if (controller.hasErrorBuyVehicles.value &&
                  controller.buyVehicles.isEmpty) {
                return _ErrorState(
                  message: controller.errorMessageBuyVehicles.value,
                  onRetry: () => controller.refreshBuyVehiclesList(),
                );
              }
              if (controller.buyVehicles.isEmpty) {
                return _EmptyState();
              }
              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () => controller.refreshBuyVehiclesList(),
                child: NotificationListener<ScrollNotification>(
                  onNotification: (n) {
                    if (n is ScrollEndNotification &&
                        n.metrics.pixels >= n.metrics.maxScrollExtent - 150) {
                      controller.loadMoreBuyVehicles();
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
                        controller.buyVehicles.length +
                        (controller.isLoadingMoreBuyVehicles.value ? 1 : 0),
                    itemBuilder: (_, i) {
                      if (i == controller.buyVehicles.length) {
                        return Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: AppSpacing.md,
                          ),
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
                        child: _VehicleCard(vehicle: controller.buyVehicles[i]),
                      );
                    },
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Filter sheet helper (free function so it can be called from build)
// ─────────────────────────────────────────────────────────────────────────────

void _showFilterSheet(BuildContext context, BuyVehicleController controller) {
  showBuyFilterSheet(context, controller);
}

// ─────────────────────────────────────────────────────────────────────────────
// Active Filters Strip
// ─────────────────────────────────────────────────────────────────────────────

class _ActiveFiltersStrip extends StatelessWidget {
  final BuyVehicleController controller;
  const _ActiveFiltersStrip({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      color: AppColors.grey50,
      child: Row(
        children: [
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 6,
              ),
              itemCount: controller.appliedFilters.length,
              separatorBuilder: (_, __) => SizedBox(width: AppSpacing.xs),
              itemBuilder: (_, i) {
                final entry = controller.appliedFilters.entries.elementAt(i);
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${entry.key}: ${entry.value}',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 11.sp,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          controller.applyFilter(entry.key, null);
                          controller.applyFiltersAndFetch();
                        },
                        child: Icon(
                          Icons.close_rounded,
                          size: 12,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          GestureDetector(
            onTap: controller.clearAllFilters,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Text(
                'Clear',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 12.sp,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Vehicle Card
// ─────────────────────────────────────────────────────────────────────────────

class _VehicleCard extends StatelessWidget {
  final BuyVehicleEntity vehicle;
  const _VehicleCard({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // Check SUBT004 (Vehicle Details Access) subscription
        final guard = SubscriptionGuardService.to;
        await guard.ensureLoaded();

        if (guard.hasActiveSubscription(
          SubscriptionTypeCode.vehicleDetailsAccess,
        )) {
          // Has valid subscription — go straight to detail
          Get.toNamed(
            AppRoutes.buyVehicleDetail,
            arguments: {'vehicle': vehicle},
          );
        } else {
          // No subscription — show warning then redirect to subscription screen.
          CustomSnackbar.show(
            message:
                'You need a Vehicle Details plan to view full details. Please subscribe to continue.',
            type: SnackbarType.warning,
          );
          await Future.delayed(const Duration(milliseconds: 600));
          Get.toNamed(
            AppRoutes.subscription,
            arguments: {
              'subscription_source': SubscriptionTypeCode.vehicleDetailsAccess,
              'title': 'Vehicle Details Access',
              'subtitle':
                  'Subscribe to view full vehicle details and connect with the owner.',
              'pending_vehicle': vehicle,
            },
          );
        }
      },
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
            // ── Image Carousel ─────────────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppRadius.lg),
                topRight: Radius.circular(AppRadius.lg),
              ),
              child: NetworkImageCarousel(
                imageUrls: vehicle.allImageUrls,
                height: 180.h,
              ),
            ),
            // ── Details ────────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${vehicle.brandName ?? ''} | ${vehicle.model ?? ''}'
                            .trim()
                            .isEmpty
                        ? vehicle.categoryName
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
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      if (vehicle.year != null) ...[
                        _chip(Icons.calendar_today_outlined, vehicle.year!),
                        SizedBox(width: AppSpacing.sm),
                      ],
                      if (vehicle.state != null)
                        _chip(Icons.location_on_outlined, vehicle.state!),
                    ],
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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
// States
// ─────────────────────────────────────────────────────────────────────────────

class _ShimmerList extends StatefulWidget {
  @override
  State<_ShimmerList> createState() => _ShimmerListState();
}

class _ShimmerListState extends State<_ShimmerList>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _anim = Tween<double>(begin: -1.5, end: 2.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => ListView.builder(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          100,
        ),
        itemCount: 4,
        itemBuilder: (_, __) => Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.md),
          child: _ShimmerCard(anim: _anim),
        ),
      ),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  final Animation<double> anim;
  const _ShimmerCard({required this.anim});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.grey100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image area ───────────────────────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppRadius.lg),
              topRight: Radius.circular(AppRadius.lg),
            ),
            child: _shimmerBox(double.infinity, 180.h),
          ),
          // ── Details ──────────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title line
                _shimmerBox(180.w, 16.h, radius: 6),
                SizedBox(height: 10.h),
                // Chips row
                Row(
                  children: [
                    _shimmerBox(60.w, 12.h, radius: 4),
                    SizedBox(width: 8.w),
                    _shimmerBox(70.w, 12.h, radius: 4),
                    SizedBox(width: 8.w),
                    _shimmerBox(50.w, 12.h, radius: 4),
                  ],
                ),
                SizedBox(height: 14.h),
                // View Details button (right-aligned)
                Align(
                  alignment: Alignment.centerRight,
                  child: _shimmerBox(90.w, 32.h, radius: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmerBox(double width, double height, {double radius = 0}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: width,
        height: height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [
                Color(0xFFEEEEEE),
                Color(0xFFF8F8F8),
                Color(0xFFEEEEEE),
              ],
              stops: [
                (anim.value - 1).clamp(0.0, 1.0),
                anim.value.clamp(0.0, 1.0),
                (anim.value + 1).clamp(0.0, 1.0),
              ],
            ),
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
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.grey300),
          SizedBox(height: AppSpacing.md),
          Text(
            'No vehicles found',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.grey700,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            'Try adjusting your filters',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 13.sp,
              color: AppColors.grey500,
            ),
          ),
        ],
      ),
    );
  }
}
