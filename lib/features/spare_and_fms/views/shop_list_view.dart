import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/design_system/loaders/app_shimmer.dart';
import '../../../core/design_system/templates/app_layout.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_fonts.dart';
import '../../buy_and_sell/domain/entities/paginated_buy_vehicles_response.dart';
import '../controllers/spare_and_fms_controller.dart';
import '../domain/entities/shop_entity.dart';
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
            itemCount:
                _controller.shopsListData.length + _shopAdCount(_controller),
            itemBuilder: (_, index) {
              final resolved = _resolveShopItem(index, _controller);
              if (resolved is ListingAd) {
                return Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.md),
                  child: _ShopAdBanner(ad: resolved),
                );
              }
              final shop = resolved as ShopEntity;
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
              context.l10n.spareNoCategoryShopsFound(_category),
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
// Ad interleaving helpers
// ─────────────────────────────────────────────────────────────────────────────

/// How many ad slots will be inserted given the current shop count.
int _shopAdCount(SpareAndFmsController ctrl) {
  if (ctrl.shopFeedAds.isEmpty) return 0;
  final n = ctrl.shopFeedAds.first.insertEveryN;
  if (n <= 0) return 0;
  return ctrl.shopsListData.length ~/ n;
}

/// Maps a flat list index (shops + ads combined) to either a
/// [ShopEntity] or a [ListingAd].
dynamic _resolveShopItem(int flatIndex, SpareAndFmsController ctrl) {
  if (ctrl.shopFeedAds.isEmpty) return ctrl.shopsListData[flatIndex];
  final n = ctrl.shopFeedAds.first.insertEveryN;
  if (n <= 0) return ctrl.shopsListData[flatIndex];

  // Every (n+1) slots: n shops then 1 ad
  final slot = flatIndex % (n + 1);
  if (slot == n) {
    // Cycle through all available ads
    final adSlotIndex = flatIndex ~/ (n + 1);
    return ctrl.shopFeedAds[adSlotIndex % ctrl.shopFeedAds.length];
  }

  // Shop slot — count how many ads have been inserted before this index
  final adsInserted = flatIndex ~/ (n + 1);
  final shopIndex = flatIndex - adsInserted;
  if (shopIndex >= ctrl.shopsListData.length) {
    return ctrl.shopFeedAds[0];
  }
  return ctrl.shopsListData[shopIndex];
}

// ─────────────────────────────────────────────────────────────────────────────
// Shop Ad Banner
// ─────────────────────────────────────────────────────────────────────────────

class _ShopAdBanner extends StatelessWidget {
  final ListingAd ad;
  const _ShopAdBanner({required this.ad});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (ad.isInternal) {
          final route = _resolveRoute(ad.redirectValue);
          if (route != null) Get.toNamed(route);
        } else {
          final uri = Uri.tryParse(ad.redirectValue);
          if (uri != null && await canLaunchUrl(uri)) {
            launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ad.bannerImageUrl.isNotEmpty
            ? Image.network(
                ad.bannerImageUrl,
                width: double.infinity,
                height: 160.h,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  String? _resolveRoute(String value) {
    switch (value) {
      case 'AppRoutes.auctionListings':
        return AppRoutes.auctionListings;
      case 'AppRoutes.auctionType':
        return AppRoutes.auctionType;
      case 'AppRoutes.buySellHome':
        return AppRoutes.buySellHome;
      case 'AppRoutes.spareFms':
        return AppRoutes.spareFms;
      case 'AppRoutes.insuranceFinance':
        return AppRoutes.insuranceFinance;
      default:
        if (value.startsWith('/')) return value;
        return null;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shimmer skeleton — mirrors ShopCard layout
// ─────────────────────────────────────────────────────────────────────────────

class _ShopListShimmer extends StatelessWidget {
  const _ShopListShimmer();

  @override
  Widget build(BuildContext context) {
    return SkeletonList(
      count: 5,
      padding: EdgeInsets.all(AppSpacing.md),
      spacing: 0,
      itemBuilder: (_, __) => const _ShopCardSkeleton(),
    );
  }
}

class _ShopCardSkeleton extends StatelessWidget {
  const _ShopCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.grey200, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.10),
            blurRadius: 14,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: AppShimmer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Shop icon + name/badge + address
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: 48.r, height: 48.r, radius: 12),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: SkeletonBox(width: 150.w, height: 15.h),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            SkeletonBox(width: 32.w, height: 18.h, radius: 20),
                          ],
                        ),
                        SizedBox(height: 6.h),
                        SkeletonBox(height: 11.h),
                        SizedBox(height: 4.h),
                        SkeletonBox(width: 140.w, height: 11.h),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              // Distance chip + stars + call button
              Row(
                children: [
                  SkeletonBox(width: 72.w, height: 28.h, radius: 20),
                  SizedBox(width: 12.w),
                  SkeletonBox(width: 110.w, height: 26.h, radius: 20),
                  const Spacer(),
                  SkeletonBox.circle(size: 36.r),
                ],
              ),
              SizedBox(height: 14.h),
              // Contact button
              SkeletonBox(width: double.infinity, height: 42.h, radius: 21),
            ],
          ),
        ),
      ),
    );
  }
}
