import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/design_system/templates/app_layout.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../theme/app_fonts.dart';
import '../controllers/spare_and_fms_controller.dart';
import '../widgets/shop_card.dart';

/// Shop listing screen filtered by category (CE/CV).
/// Shows shops near the user's GPS location with location permission handling.
class ShopListView extends GetView<SpareAndFmsController> {
  const ShopListView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final category = args['category'] as String? ?? 'CE';

    // Trigger shop loading when this view is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.currentShopCategory.value != category ||
          !controller.hasShopsInitiallyLoaded.value) {
        controller.loadShopsByCategory(category);
      }
    });

    final title = category == 'CE'
        ? context.l10n.constructionEquipmentShops
        : context.l10n.commercialVehicleShops;

    return AppLayout(
      title: title,
      subtitle: context.l10n.shopsNearLocation,
      showBack: true,
      actions: [
        GestureDetector(
          onTap: () => controller.refreshLocationAndReloadShops(),
          child: Padding(
            padding: EdgeInsets.only(right: AppSpacing.md),
            child: Icon(
              Icons.my_location_rounded,
              color: AppColors.white,
              size: 22.r,
            ),
          ),
        ),
      ],
      body: Obx(() {
        // Loading state
        if (controller.isShopsLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // Not loaded yet
        if (!controller.hasShopsInitiallyLoaded.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_searching,
                  size: 64.r,
                  color: AppColors.grey400,
                ),
                SizedBox(height: AppSpacing.md),
                Text(
                  context.l10n.findingShopsNearYou,
                  style: AppFonts.bodyMedium.copyWith(color: AppColors.grey600),
                ),
              ],
            ),
          );
        }

        // Empty state — could be no shops or no location
        if (controller.shopsListData.isEmpty) {
          return _buildEmptyState(category);
        }

        // Shop list
        return RefreshIndicator(
          onRefresh: () async => controller.refreshShopsData(),
          child: ListView.builder(
            padding: EdgeInsets.all(AppSpacing.md),
            itemCount: controller.shopsListData.length,
            itemBuilder: (context, index) {
              final shop = controller.shopsListData[index];
              return ShopCard(
                shop: shop,
                onContact: () => controller.contactShop(shop),
                // Phone icon only shown when number is already revealed
                onCall: shop.hasValidMobileNumber
                    ? () => controller.contactShop(shop)
                    : null,
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState(String category) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.store_outlined, size: 64.r, color: AppColors.grey400),
            SizedBox(height: AppSpacing.md),
            Builder(
              builder: (context) => Text(
                context.l10n.noShopsFound,
                style: AppFonts.titleMedium.copyWith(color: AppColors.grey600),
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              'No $category shops found near your location.\nTry enabling location or check back later.',
              textAlign: TextAlign.center,
              style: AppFonts.bodySmall.copyWith(color: AppColors.grey500),
            ),
            SizedBox(height: AppSpacing.lg),
            Builder(
              builder: (context) => ElevatedButton.icon(
                onPressed: () => controller.enableLocationFromUI(),
                icon: const Icon(Icons.location_on),
                label: Text(context.l10n.enableLocation),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
