import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/design_system/organisms/network_image_carousel.dart';
import '../../../routes/app_routes.dart';
import '../controllers/vehicle_detail_controller.dart';
import '../domain/entities/buy_vehicle_entity.dart';

/// Vehicle card grid shown when a category is selected.
///
/// Search bar and filter controls are handled by [BuySellHomeView].
/// This widget only renders the scrollable list of vehicle cards with
/// Buy / Sell action buttons.
class BuyView extends StatelessWidget {
  const BuyView({super.key});

  static const _redAccent = Color(0xFFD32F2F);

  BuyVehicleController get _ctrl => Get.find<BuyVehicleController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // ── Loading state ────────────────────────────────────
      if (_ctrl.isLoadingBuyVehicles.value && _ctrl.buyVehicles.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(color: _redAccent),
        );
      }

      // ── Error state ──────────────────────────────────────
      if (_ctrl.hasErrorBuyVehicles.value && _ctrl.buyVehicles.isEmpty) {
        return _buildErrorState();
      }

      // ── Empty state ──────────────────────────────────────
      if (_ctrl.buyVehicles.isEmpty) {
        return _buildEmptyState();
      }

      // ── Vehicle list ─────────────────────────────────────
      return RefreshIndicator(
        color: _redAccent,
        onRefresh: () => _ctrl.refreshBuyVehiclesList(),
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollEndNotification &&
                notification.metrics.pixels >=
                    notification.metrics.maxScrollExtent - 100) {
              _ctrl.loadMoreBuyVehicles();
            }
            return false;
          },
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount:
                _ctrl.buyVehicles.length +
                (_ctrl.hasMoreBuyVehicles.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _ctrl.buyVehicles.length) {
                // Load-more indicator
                return _ctrl.isLoadingMoreBuyVehicles.value
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: _redAccent,
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink();
              }
              return _VehicleCard(vehicle: _ctrl.buyVehicles[index]);
            },
          ),
        ),
      );
    });
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _ctrl.errorMessageBuyVehicles.value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _ctrl.refreshBuyVehiclesList(),
              style: ElevatedButton.styleFrom(
                backgroundColor: _redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  color: Colors.white,
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
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_car_outlined,
              size: 48,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'No vehicles found',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Try adjusting your filters',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Vehicle Card Widget (Premium Design)
// ═══════════════════════════════════════════════════════════════

class _VehicleCard extends StatelessWidget {
  final BuyVehicleEntity vehicle;
  const _VehicleCard({required this.vehicle});

  static const _redAccent = Color(0xFFD32F2F);

  @override
  Widget build(BuildContext context) {
    // Build image list from vehicle_files (file_url) + imageUrls
    final images = vehicle.allImageUrls;

    return GestureDetector(
      onTap: () {
        Get.toNamed(
          AppRoutes.buyVehicleDetail,
          arguments: {
            'vehicleId': vehicle.sbVehicleId,
            'categoryCode': vehicle.categoryCode,
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(color: Colors.grey.withValues(alpha: 0.08)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Vehicle Image (with zoom) ─────────────────
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: NetworkImageCarousel(imageUrls: images, height: 160.h),
            ),

            // ── Details Section ───────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Row 1: brand_name/model | manufacturing_year
                  Text(
                    _buildTitleLine(),
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // ── Row 2: city_name | state_name ────────
                  if (_formatLocation().isNotEmpty)
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 15,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _formatLocation(),
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // ── Row 3: price ─────────────────────────
                  if (vehicle.price != null && vehicle.price! > 0)
                    Text(
                      vehicle.formattedPrice,
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: _redAccent,
                      ),
                    ),

                  const SizedBox(height: 12),

                  // ── View Details button ──────────────────
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFD32F2F), Color(0xFFB71C1C)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFD32F2F).withValues(alpha: 0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            'View Details',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 11,
                            color: Colors.white,
                          ),
                        ],
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

  String _buildTitleLine() {
    final brand = (vehicle.brandName ?? '').trim();
    final model = (vehicle.model ?? '').trim();
    final year = vehicle.manufacturingYear;

    if (brand.isNotEmpty && model.isNotEmpty) {
      return '$brand $model | $year';
    } else if (brand.isNotEmpty) {
      return '$brand | $year';
    } else if (model.isNotEmpty) {
      return '$model | $year';
    }
    return 'Vehicle | $year';
  }

  String _formatLocation() {
    final parts = <String>[];
    if (vehicle.city != null && vehicle.city!.isNotEmpty) {
      parts.add(vehicle.city!);
    }
    if (vehicle.state != null && vehicle.state!.isNotEmpty) {
      parts.add(vehicle.state!);
    }
    return parts.join(' | ');
  }
}
