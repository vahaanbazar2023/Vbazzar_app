import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/design_system/templates/app_layout.dart';
import '../../../routes/app_routes.dart';
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
      headerExtra: _SearchBar(controller: controller),
      body: Column(
        children: [
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
// Search Bar (shown in header extra)
// ─────────────────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final BuyVehicleController controller;
  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: SizedBox(
        height: 40.h,
        child: TextField(
          controller: controller.searchController,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 13.sp,
            color: Colors.white,
          ),
          decoration: InputDecoration(
            hintText: 'Search vehicles...',
            hintStyle: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 13.sp,
              color: Colors.white70,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: Colors.white70,
              size: 18,
            ),
            suffixIcon: Obx(
              () => controller.searchQuery.value.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        controller.searchController.clear();
                      },
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white70,
                        size: 16,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 8.h),
            isDense: true,
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.15),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Colors.white30),
            ),
          ),
        ),
      ),
    );
  }
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
    final images = vehicle.allImageUrls;
    final imageUrl = images.isNotEmpty ? images.first : '';

    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoutes.buyVehicleDetail,
        arguments: {'vehicle': vehicle},
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
            // ── Image ──────────────────────────────────────────────────────
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
            // ── Details ────────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${vehicle.brandName ?? ''} ${vehicle.model ?? ''}'
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
                    children: [
                      if (vehicle.year != null) ...[
                        _chip(Icons.calendar_today_outlined, vehicle.year!),
                        SizedBox(width: AppSpacing.xs),
                      ],
                      if (vehicle.fuelType != null) ...[
                        _chip(
                          Icons.local_gas_station_outlined,
                          vehicle.fuelType!,
                        ),
                        SizedBox(width: AppSpacing.xs),
                      ],
                      if (vehicle.state != null)
                        _chip(Icons.location_on_outlined, vehicle.state!),
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
                      Container(
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
