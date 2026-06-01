import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../controllers/sell_vehicle_controller.dart';
import '../domain/entities/sell_vehicle_entity.dart';

/// My Vehicles tab showing the user's posted vehicles with status filtering,
/// pull-to-refresh, infinite scroll, and action buttons (edit, mark sold).
class MyVehiclesView extends StatefulWidget {
  const MyVehiclesView({super.key});

  @override
  State<MyVehiclesView> createState() => _MyVehiclesViewState();
}

class _MyVehiclesViewState extends State<MyVehiclesView> {
  final SellVehicleController controller = Get.find<SellVehicleController>();
  final ScrollController _scrollController = ScrollController();

  static const _statusFilters = ['All', 'Pending', 'Approved', 'Sold', 'Rejected'];
  final _selectedFilter = 'All'.obs;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      controller.loadMoreSellVehicles();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildStatusFilterChips(),
        Expanded(child: _buildVehicleList()),
      ],
    );
  }

  // ─── Status Filter Chips ───────────────────────────────────────

  Widget _buildStatusFilterChips() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Obx(() => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _statusFilters.map((filter) {
                final isSelected = _selectedFilter.value == filter;
                return Padding(
                  padding: EdgeInsets.only(right: AppSpacing.sm),
                  child: GestureDetector(
                    onTap: () => _selectedFilter.value = filter,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs + 2,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.grey100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.grey300,
                        ),
                      ),
                      child: Text(
                        filter,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12.sp,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? AppColors.white : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          )),
    );
  }

  // ─── Vehicle List ──────────────────────────────────────────────

  Widget _buildVehicleList() {
    return Obx(() {
      if (controller.isLoadingSellVehicles.value) {
        return _buildLoadingState();
      }

      if (controller.hasErrorSellVehicles.value) {
        return _buildErrorState();
      }

      final vehicles = _filteredVehicles;

      if (vehicles.isEmpty) {
        return _buildEmptyState();
      }

      return RefreshIndicator(
        color: AppColors.primary,
        onRefresh: controller.refreshSellVehiclesList,
        child: ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          itemCount: vehicles.length +
              (controller.isLoadingMoreSellVehicles.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= vehicles.length) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              );
            }
            return _MyVehicleCard(
              vehicle: vehicles[index],
              onEdit: () => _onEdit(vehicles[index]),
              onMarkSold: () => _onMarkSold(vehicles[index]),
              onMarkUnsold: () => _onMarkUnsold(vehicles[index]),
            );
          },
        ),
      );
    });
  }

  // ─── Filtered Vehicles ─────────────────────────────────────────

  List<SellVehicleEntity> get _filteredVehicles {
    switch (_selectedFilter.value) {
      case 'Pending':
        return controller.pendingVehicles;
      case 'Approved':
        return controller.approvedVehicles;
      case 'Sold':
        return controller.soldVehicles;
      case 'Rejected':
        return controller.rejectedVehicles;
      default:
        return controller.sellVehicles;
    }
  }

  // ─── Empty State ───────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.directions_car_outlined,
              size: 64.w,
              color: AppColors.grey400,
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              "You haven't posted any vehicles yet",
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Switch to the Sell tab to post your first vehicle',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Loading State ─────────────────────────────────────────────

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      itemCount: 4,
      itemBuilder: (context, index) => _ShimmerCard(),
    );
  }

  // ─── Error State ───────────────────────────────────────────────

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48.w, color: AppColors.error),
            SizedBox(height: AppSpacing.md),
            Text(
              controller.errorMessageSellVehicles.value,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14.sp,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.lg),
            GestureDetector(
              onTap: () => controller.refreshSellVehiclesList(),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.sm + 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Retry',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Actions ───────────────────────────────────────────────────

  void _onEdit(SellVehicleEntity vehicle) {
    // Navigate to sell tab in edit mode
    final tabCtrl = Get.find<SellVehicleController>();
    tabCtrl.enterEditMode(vehicle);
    // Switch to sell tab (index 1) via parent tab controller
    // For now, show a snackbar — the tab switch will be handled by the parent
    Get.snackbar(
      'Edit Mode',
      'Editing ${vehicle.brandName ?? ''} ${vehicle.model ?? ''}',
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.info,
      colorText: AppColors.white,
    );
  }

  void _onMarkSold(SellVehicleEntity vehicle) {
    Get.defaultDialog(
      title: 'Mark as Sold',
      middleText: 'Mark "${vehicle.brandName ?? ''} ${vehicle.model ?? ''}" as sold?',
      textConfirm: 'Confirm',
      textCancel: 'Cancel',
      confirmTextColor: AppColors.white,
      buttonColor: AppColors.primary,
      cancelTextColor: AppColors.textSecondary,
      onConfirm: () {
        Get.back();
        controller.markAsSold(vehicle.sbVehicleId);
      },
    );
  }

  void _onMarkUnsold(SellVehicleEntity vehicle) {
    Get.defaultDialog(
      title: 'Mark as Available',
      middleText: 'Mark "${vehicle.brandName ?? ''} ${vehicle.model ?? ''}" as available?',
      textConfirm: 'Confirm',
      textCancel: 'Cancel',
      confirmTextColor: AppColors.white,
      buttonColor: AppColors.primary,
      cancelTextColor: AppColors.textSecondary,
      onConfirm: () {
        Get.back();
        controller.markAsUnsold(vehicle.sbVehicleId);
      },
    );
  }
}

// ─── My Vehicle Card ─────────────────────────────────────────────

class _MyVehicleCard extends StatelessWidget {
  final SellVehicleEntity vehicle;
  final VoidCallback onEdit;
  final VoidCallback onMarkSold;
  final VoidCallback onMarkUnsold;

  const _MyVehicleCard({
    required this.vehicle,
    required this.onEdit,
    required this.onMarkSold,
    required this.onMarkUnsold,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Image + Info Row
          Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                // Vehicle Image
                _buildImage(),
                SizedBox(width: AppSpacing.md),
                // Info
                Expanded(child: _buildInfo()),
              ],
            ),
          ),
          // Status Badge + Actions
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: vehicle.primaryImageUrl.isNotEmpty
          ? Image.network(
              vehicle.primaryImageUrl,
              width: 90.w,
              height: 75.w,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _placeholderImage(),
            )
          : _placeholderImage(),
    );
  }

  Widget _placeholderImage() {
    return Container(
      width: 90.w,
      height: 75.w,
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.directions_car_outlined,
        size: 32.w,
        color: AppColors.grey400,
      ),
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${vehicle.brandName ?? ''} ${vehicle.model ?? ''}',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 2.h),
        Text(
          vehicle.registrationNumber ?? '',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 4.h),
        Row(
          children: [
            Text(
              vehicle.formattedPrice,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            _buildStatusBadge(),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    final color = _statusColor;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        vehicle.statusLabel,
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Color get _statusColor {
    if (vehicle.isVehicleSold) return AppColors.grey600;
    if (vehicle.isPending) return AppColors.warning;
    if (vehicle.isApproved) return AppColors.success;
    if (vehicle.isRejected) return AppColors.error;
    return AppColors.grey500;
  }

  Widget _buildActions() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          // Edit button (available for non-sold vehicles)
          if (!vehicle.isVehicleSold)
            _ActionButton(
              label: 'Edit',
              icon: Icons.edit_outlined,
              color: AppColors.info,
              onTap: onEdit,
            ),
          if (!vehicle.isVehicleSold) SizedBox(width: AppSpacing.sm),
          // Mark Sold / Unsold button
          if (!vehicle.isVehicleSold)
            _ActionButton(
              label: 'Mark Sold',
              icon: Icons.check_circle_outline,
              color: AppColors.success,
              onTap: onMarkSold,
            ),
          if (vehicle.isVehicleSold)
            _ActionButton(
              label: 'Mark Available',
              icon: Icons.unpublished_outlined,
              color: AppColors.warning,
              onTap: onMarkUnsold,
            ),
          const Spacer(),
          // Created date
          if (vehicle.createdAt != null)
            Text(
              _formatDate(vehicle.createdAt!),
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 10.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textDisabled,
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return dateStr;
    }
  }
}

// ─── Action Button ───────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14.w, color: color),
            SizedBox(width: 4.w),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Shimmer Card Placeholder ────────────────────────────────────

class _ShimmerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        children: [
          // Shimmer image
          Container(
            width: 90.w,
            height: 75.w,
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          SizedBox(width: AppSpacing.md),
          // Shimmer text lines
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _shimmerLine(120.w, 14.h),
                SizedBox(height: 6.h),
                _shimmerLine(80.w, 12.h),
                SizedBox(height: 8.h),
                _shimmerLine(60.w, 14.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmerLine(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}