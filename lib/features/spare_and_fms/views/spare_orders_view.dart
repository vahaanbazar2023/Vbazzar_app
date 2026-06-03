import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/design_system/templates/app_layout.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../theme/app_fonts.dart';
import '../controllers/spare_and_fms_controller.dart';

/// "My Bookings" — displays the user's spare part orders with pagination.
class SpareOrdersView extends GetView<SpareAndFmsController> {
  const SpareOrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: 'My Bookings',
      subtitle: 'Your spare parts orders',
      showBack: true,
      body: Obx(() {
        // Loading state
        if (controller.isSpareOrdersLoading.value &&
            controller.spareOrdersList.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        // Empty state
        if (controller.spareOrdersList.isEmpty) {
          return _buildEmptyState();
        }

        // Orders list
        return RefreshIndicator(
          onRefresh: () async => controller.loadUserSpareOrders(isRefresh: true),
          child: ListView.builder(
            padding: EdgeInsets.all(AppSpacing.md),
            itemCount: controller.spareOrdersList.length +
                (controller.hasMoreSpareOrders.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == controller.spareOrdersList.length) {
                // Load more indicator
                if (!controller.isLoadingMoreSpareOrders.value) {
                  controller.loadMoreSpareOrders();
                }
                return Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Center(
                    child: SizedBox(
                      width: 24.r,
                      height: 24.r,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
              }

              final order = controller.spareOrdersList[index];
              return _OrderCard(
                order: order,
                onTap: () => controller.navigateToSpareOrderDetail(order),
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 64.r, color: AppColors.grey400),
          SizedBox(height: AppSpacing.md),
          Text(
            'No bookings yet',
            style: AppFonts.titleMedium.copyWith(color: AppColors.grey600),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            'Your spare parts orders will appear here',
            style: AppFonts.bodySmall.copyWith(color: AppColors.grey500),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final dynamic order;
  final VoidCallback onTap;

  const _OrderCard({required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(order.orderStatus);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppSizes.radiusMd),
                bottomLeft: Radius.circular(AppSizes.radiusMd),
              ),
              child: SizedBox(
                width: 90.w,
                height: 90.w,
                child: order.photos.isNotEmpty
                    ? Image.network(
                        order.photos.first,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholderImage(),
                      )
                    : _placeholderImage(),
              ),
            ),
            // Info
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            order.spareName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFonts.labelMedium.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        // Status badge
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusFull,
                            ),
                          ),
                          child: Text(
                            order.orderStatus.toUpperCase(),
                            style: AppFonts.labelSmall.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Order #${order.spareOrderId}',
                      style: AppFonts.bodySmall.copyWith(
                        color: AppColors.grey500,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Text(
                          '₹${order.price}',
                          style: AppFonts.titleSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 14.r,
                          color: AppColors.grey400,
                        ),
                      ],
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

  Widget _placeholderImage() {
    return Container(
      color: AppColors.grey100,
      child: Center(
        child: Icon(Icons.build_outlined, size: 32.r, color: AppColors.grey400),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppColors.warning;
      case 'confirmed':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.grey400;
    }
  }
}