import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/design_system/templates/app_layout.dart';
import '../../../core/extensions/context_extensions.dart';
import '../controllers/vehicle_detail_controller.dart';
import 'buy_vehicle_listings_view.dart' show BuyVehicleCard;

/// Buy & Sell wishlist: the vehicles the user marked interested, across every category, shown with
/// the same card (same details) as the Buy & Sell listing.
/// Data: POST /sell-buy/vehicle-category-list-by-filters with category_code "all" + is_interested "yes".
class BuySellWishlistView extends StatefulWidget {
  const BuySellWishlistView({super.key});

  @override
  State<BuySellWishlistView> createState() => _BuySellWishlistViewState();
}

class _BuySellWishlistViewState extends State<BuySellWishlistView> {
  BuyVehicleController get controller => Get.find<BuyVehicleController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.refreshWishlist();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: context.l10n.spareWishlist,
      subtitle: context.l10n.buySellWishlistSubtitle,
      body: Obx(() {
        final vehicles = controller.wishlistVehicles;
        if (controller.isLoadingWishlist.value && vehicles.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        if (controller.hasErrorWishlist.value && vehicles.isEmpty) {
          return _Message(
            icon: Icons.error_outline,
            text: context.l10n.spareFailedToLoadVehicles,
            actionLabel: context.l10n.retry,
            onAction: controller.refreshWishlist,
          );
        }
        if (vehicles.isEmpty) {
          return _Message(
            icon: Icons.favorite_border,
            text: context.l10n.buySellWishlistEmpty,
          );
        }
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: controller.refreshWishlist,
          child: NotificationListener<ScrollNotification>(
            onNotification: (n) {
              if (n is ScrollEndNotification &&
                  n.metrics.pixels >= n.metrics.maxScrollExtent - 150) {
                controller.fetchWishlist();
              }
              return false;
            },
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                24,
              ),
              itemCount:
                  vehicles.length + (controller.isLoadingMoreWishlist.value ? 1 : 0),
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
                  padding: EdgeInsets.only(bottom: AppSpacing.sm),
                  child: BuyVehicleCard(vehicle: vehicles[i]),
                );
              },
            ),
          ),
        );
      }),
    );
  }
}

class _Message extends StatelessWidget {
  final IconData icon;
  final String text;
  final String? actionLabel;
  final Future<void> Function()? onAction;
  const _Message({
    required this.icon,
    required this.text,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48.r, color: AppColors.grey400),
            SizedBox(height: 12.h),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14.sp,
                color: AppColors.grey600,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: 12.h),
              TextButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
