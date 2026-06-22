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
class ShopListView extends StatefulWidget {
  const ShopListView({super.key});

  @override
  State<ShopListView> createState() => _ShopListViewState();
}

class _ShopListViewState extends State<ShopListView> {
  late final SpareAndFmsController _controller;
  late final String _category;

  @override
  void initState() {
    super.initState();
    // Always resolve controller via Get.find — binding guarantees it exists.
    _controller = Get.find<SpareAndFmsController>();

    final args = Get.arguments as Map<String, dynamic>? ?? {};
    _category = args['category'] as String? ?? 'CE';

    // Always trigger a fresh load for this category on every open.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.loadShopsByCategory(_category);
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = _category == 'CE'
        ? context.l10n.constructionEquipmentShops
        : context.l10n.commercialVehicleShops;

    return AppLayout(
      title: title,
      subtitle: context.l10n.shopsNearLocation,
      showBack: true,
      actions: [
        GestureDetector(
          onTap: () => _controller.refreshLocationAndReloadShops(),
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
        if (_controller.isShopsLoading.value ||
            !_controller.hasShopsInitiallyLoaded.value) {
          return const _ShopListShimmer();
        }

        if (_controller.shopsListData.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () async => _controller.refreshShopsData(),
          child: ListView.builder(
            padding: EdgeInsets.all(AppSpacing.md),
            itemCount: _controller.shopsListData.length,
            itemBuilder: (_, index) {
              final shop = _controller.shopsListData[index];
              return ShopCard(
                shop: shop,
                onContact: () => _controller.contactShop(shop),
                onCall: shop.hasValidMobileNumber
                    ? () => _controller.contactShop(shop)
                    : null,
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.store_outlined, size: 64.r, color: AppColors.grey400),
            SizedBox(height: AppSpacing.md),
            Text(
              context.l10n.noShopsFound,
              style: AppFonts.titleMedium.copyWith(color: AppColors.grey600),
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              'No $_category shops found near your location.\nTry enabling location or check back later.',
              textAlign: TextAlign.center,
              style: AppFonts.bodySmall.copyWith(color: AppColors.grey500),
            ),
            SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: () => _controller.enableLocationFromUI(),
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
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shimmer skeleton — mirrors ShopCard layout
// ─────────────────────────────────────────────────────────────────────────────

class _ShopListShimmer extends StatefulWidget {
  const _ShopListShimmer();

  @override
  State<_ShopListShimmer> createState() => _ShopListShimmerState();
}

class _ShopListShimmerState extends State<_ShopListShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _anim = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => ListView.builder(
        padding: EdgeInsets.all(AppSpacing.md),
        itemCount: 6,
        itemBuilder: (_, __) => _ShopCardSkeleton(opacity: _anim.value),
      ),
    );
  }
}

class _ShopCardSkeleton extends StatelessWidget {
  final double opacity;
  const _ShopCardSkeleton({required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _bone(w: 48.r, h: 48.r, r: AppSizes.radiusMd),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _bone(w: double.infinity, h: 14.h, r: 4),
                          ),
                          SizedBox(width: 8.w),
                          _bone(w: 36.w, h: 20.h, r: 20),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      _bone(w: double.infinity, h: 11.h, r: 4),
                      SizedBox(height: 4.h),
                      _bone(w: 140.w, h: 11.h, r: 4),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                _bone(w: 80.w, h: 28.h, r: 20),
                SizedBox(width: 12.w),
                _bone(w: 90.w, h: 28.h, r: 20),
              ],
            ),
            SizedBox(height: 14.h),
            _bone(w: double.infinity, h: 42.h, r: 20),
          ],
        ),
      ),
    );
  }

  Widget _bone({required double w, required double h, required double r}) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: AppColors.grey200,
        borderRadius: BorderRadius.circular(r),
      ),
    );
  }
}
