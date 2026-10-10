import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/design_system/molecules/custom_snackbar.dart';
import '../../../core/design_system/organisms/network_image_carousel.dart';
import '../../../core/design_system/molecules/gradient_button.dart';
import '../../../core/design_system/molecules/custom_search_bar.dart';
import '../../../core/services/share_service.dart';
import '../widgets/buy_filter_sheet.dart';
import '../../../core/design_system/templates/app_layout.dart';
import '../../../routes/app_routes.dart';
import '../domain/entities/paginated_buy_vehicles_response.dart';
import '../../subscription/models/user_subscription.dart';
import '../../subscription/services/subscription_guard_service.dart';
import '../controllers/vehicle_detail_controller.dart';
import '../domain/entities/buy_vehicle_entity.dart';
import '../domain/entities/vehicle_category_entity.dart';
import '../widgets/buy_sell_activity_fab.dart';

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

    final categoryName = category?.categoryName ?? context.l10n.spareVehicles;

    return AppLayout(
      title: categoryName,
      subtitle: context.l10n.spareBrowseAvailableListings,
      body: Stack(
        children: [
          Column(
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
                      child: CustomSearchBar(
                        controller: controller.searchController,
                        hint: context.l10n.searchVehicles,
                        onChanged: (value) {
                          // Search functionality preserved
                        },
                        onClear: () {
                          controller.searchController.clear();
                        },
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    // Filter icon button
                    Obx(() {
                      final hasFilters = controller.appliedFilters.isNotEmpty;
                      return GestureDetector(
                        onTap: () => _showFilterSheet(context, controller),
                        child: Container(
                          width: 46.h,
                          height: 46.h,
                          decoration: BoxDecoration(
                            color: hasFilters
                                ? AppColors.primary
                                : AppColors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: hasFilters
                                  ? AppColors.primary
                                  : AppColors.grey200,
                            ),
                          ),
                          child: Center(
                            child: Image.asset(
                              AppAssets.filterPng,
                              width: 22.r,
                              height: 22.r,
                              color: hasFilters
                                  ? Colors.white
                                  : AppColors.primary,
                            ),
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
                            n.metrics.pixels >=
                                n.metrics.maxScrollExtent - 150) {
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
                            _adCount(controller) +
                            (controller.isLoadingMoreBuyVehicles.value ? 1 : 0),
                        itemBuilder: (_, i) {
                          final totalVehicles = controller.buyVehicles.length;
                          final totalAds = _adCount(controller);
                          if (i == totalVehicles + totalAds) {
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
                          // Resolve actual item accounting for inserted ads
                          final resolved = _resolveItem(i, controller);
                          if (resolved is ListingAd) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: AppSpacing.sm),
                              child: _ListingAdBanner(ad: resolved),
                            );
                          }
                          final vehicle = resolved as BuyVehicleEntity;
                          return Padding(
                            padding: EdgeInsets.only(bottom: AppSpacing.sm),
                            child: _VehicleCard(vehicle: vehicle),
                          );
                        },
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
          // ── Activity FAB ──────────────────────────────────
          const Positioned(right: 16, bottom: 24, child: BuySellActivityFab()),
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
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 130.w),
            child: GestureDetector(
              onTap: controller.clearAllFilters,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Text(
                  context.l10n.clearFilters,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12.sp,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
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
// Ad interleaving helpers
// ─────────────────────────────────────────────────────────────────────────────

/// How many ad slots will be inserted given the current vehicle count.
int _adCount(BuyVehicleController ctrl) {
  if (ctrl.feedAds.isEmpty) return 0;
  final n = ctrl.feedAds.first.insertEveryN;
  if (n <= 0) return 0;
  return ctrl.buyVehicles.length ~/ n;
}

/// Maps a flat list index (vehicles + ads combined) to either a
/// [BuyVehicleEntity] or a [ListingAd].
dynamic _resolveItem(int flatIndex, BuyVehicleController ctrl) {
  if (ctrl.feedAds.isEmpty) return ctrl.buyVehicles[flatIndex];
  final n = ctrl.feedAds.first.insertEveryN;
  if (n <= 0) return ctrl.buyVehicles[flatIndex];

  // Every (n+1) slots: n vehicles then 1 ad
  final slot = flatIndex % (n + 1);
  if (slot == n) {
    // Cycle through all available ads
    final adSlotIndex = flatIndex ~/ (n + 1);
    return ctrl.feedAds[adSlotIndex % ctrl.feedAds.length];
  }

  // Vehicle slot — count how many ads have been inserted before this index
  final adsInserted = flatIndex ~/ (n + 1);
  final vehicleIndex = flatIndex - adsInserted;
  if (vehicleIndex >= ctrl.buyVehicles.length) {
    return ctrl.feedAds[0];
  }
  return ctrl.buyVehicles[vehicleIndex];
}

// ─────────────────────────────────────────────────────────────────────────────
// Listing Ad Banner
// ─────────────────────────────────────────────────────────────────────────────

class _ListingAdBanner extends StatelessWidget {
  final ListingAd ad;
  const _ListingAdBanner({required this.ad});

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
                height: 160,
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

class _VehicleCard extends StatelessWidget {
  final BuyVehicleEntity vehicle;
  const _VehicleCard({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final ctrl = Get.find<BuyVehicleController>();
        final granted = await ctrl.requestVehicleDetails(vehicle);
        if (granted) {
          Get.toNamed(
            AppRoutes.buyVehicleDetail,
            arguments: {'vehicle': vehicle},
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.grey200, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 12,
              spreadRadius: 0,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Left: Image with badges ────────────────────────────────────
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.r),
                    bottomLeft: Radius.circular(16.r),
                  ),
                  child: Container(
                    width: 140.w,
                    height: 100.h,
                    color: AppColors.grey100,
                    child: vehicle.allImageUrls.isNotEmpty
                        ? NetworkImageCarousel(
                            imageUrls: vehicle.allImageUrls,
                            height: 100.h,
                          )
                        : Icon(
                            Icons.local_shipping_outlined,
                            size: 48.r,
                            color: AppColors.grey400,
                          ),
                  ),
                ),
                // Share button - top left
                Positioned(
                  top: 8.h,
                  left: 8.w,
                  child: GestureDetector(
                    onTap: () async {
                      if (Get.isRegistered<ShareService>()) {
                        await ShareService.to.shareVehicle(
                          sbVehicleId: vehicle.sbVehicleId,
                          brandName: vehicle.brandName,
                          modelName: vehicle.model,
                          year: vehicle.year,
                          categoryName: vehicle.categoryName,
                          imageUrl: vehicle.allImageUrls.isNotEmpty
                              ? vehicle.allImageUrls.first
                              : null,
                        );
                      }
                    },
                    child: Container(
                      width: 32.w,
                      height: 32.w,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.92),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.share_rounded,
                        size: 16.r,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                // Wishlist button - top right of image
                Positioned(
                  top: 8.h,
                  right: 8.w,
                  child: Obx(() {
                    final ctrl = Get.find<BuyVehicleController>();
                    return GestureDetector(
                      onTap: () => ctrl.toggleWishlist(vehicle),
                      child: Container(
                        width: 32.w,
                        height: 32.w,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.92),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          ctrl.isWishlisted(vehicle.sbVehicleId)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          size: 16.r,
                          color: ctrl.isWishlisted(vehicle.sbVehicleId)
                              ? AppColors.error
                              : AppColors.grey600,
                        ),
                      ),
                    );
                  }),
                ),
                // Image count badge - bottom left
                if (vehicle.allImageUrls.length > 1)
                  Positioned(
                    bottom: 8.h,
                    left: 8.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.camera_alt,
                            size: 12.r,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '${vehicle.allImageUrls.length}',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            // ── Right: Details ─────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(12.w, 4.h, 0, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title with star rating
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            _buildTitle(),
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // // Star rating
                        // Container(
                        //   padding: EdgeInsets.symmetric(
                        //     horizontal: 6.w,
                        //     vertical: 2.h,
                        //   ),
                        //   decoration: BoxDecoration(
                        //     color: const Color(0xFFFFF9E6),
                        //     borderRadius: BorderRadius.circular(8.r),
                        //   ),
                        //   child: Row(
                        //     mainAxisSize: MainAxisSize.min,
                        //     children: [
                        //       Icon(
                        //         Icons.star,
                        //         size: 12.r,
                        //         color: const Color(0xFFFFC107),
                        //       ),
                        //       SizedBox(width: 2.w),
                        //       Text(
                        //         '4.${(vehicle.sbVehicleId.hashCode % 6 + 1)}',
                        //         style: TextStyle(
                        //           fontFamily: 'Montserrat',
                        //           fontSize: 11.sp,
                        //           fontWeight: FontWeight.w600,
                        //           color: AppColors.textPrimary,
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    // Year and Location
                    Row(
                      children: [
                        if (vehicle.year != null) ...[
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 13.r,
                            color: AppColors.grey500,
                          ),
                          SizedBox(width: 3.w),
                          Text(
                            vehicle.year!,
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.grey600,
                            ),
                          ),
                        ],
                        if (vehicle.year != null && vehicle.state != null)
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6.w),
                            child: Container(
                              width: 3.w,
                              height: 3.w,
                              decoration: BoxDecoration(
                                color: AppColors.grey400,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        if (vehicle.state != null) ...[
                          Icon(
                            Icons.location_on_outlined,
                            size: 13.r,
                            color: AppColors.grey500,
                          ),
                          SizedBox(width: 3.w),
                          Flexible(
                            child: Text(
                              vehicle.state!,
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColors.grey600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 6.h),
                    // Specs row (fuel, transmission, km)
                    Wrap(
                      spacing: 6.w,
                      runSpacing: 4.h,
                      children: [
                        _specChip(Icons.local_gas_station, context.l10n.diesel),
                        _specChip(Icons.settings, context.l10n.manual),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    // Price and View More button
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
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.error,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 4.0, bottom: 4),
                          child: GradientButton.filled(
                            text: context.l10n.spareViewMore,
                            onPressed: () async {
                              final ctrl = Get.find<BuyVehicleController>();
                              final granted = await ctrl.requestVehicleDetails(
                                vehicle,
                              );
                              if (granted) {
                                Get.toNamed(
                                  AppRoutes.buyVehicleDetail,
                                  arguments: {'vehicle': vehicle},
                                );
                              }
                            },
                            width: 80.w,
                            height: 24.h,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                          ),
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

  String _buildTitle() {
    final brand = (vehicle.brandName ?? '').trim();
    final model = (vehicle.model ?? '').trim();
    if (brand.isNotEmpty && model.isNotEmpty) return '$brand - $model';
    if (brand.isNotEmpty) return brand;
    if (model.isNotEmpty) return model;
    return vehicle.categoryName;
  }

  Widget _specChip(IconData icon, String text) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 12.r, color: AppColors.grey500),
      SizedBox(width: 3.w),
      Flexible(
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 10.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.grey600,
          ),
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
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.grey200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Left: Image shimmer ──────────────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.r),
              bottomLeft: Radius.circular(16.r),
            ),
            child: _shimmerBox(140.w, 100.h),
          ),
          // ── Right: Details shimmer ───────────────────────────────────────
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title lines (2 lines)
                  _shimmerBox(double.infinity, 14.h, radius: 4),
                  SizedBox(height: 6.h),
                  _shimmerBox(120.w, 14.h, radius: 4),
                  SizedBox(height: 8.h),
                  // Year + Location row
                  Row(
                    children: [
                      _shimmerBox(45.w, 10.h, radius: 4),
                      SizedBox(width: 6.w),
                      _shimmerBox(60.w, 10.h, radius: 4),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  // Specs row (3 chips)
                  Row(
                    children: [
                      _shimmerBox(40.w, 10.h, radius: 4),
                      SizedBox(width: 4.w),
                      _shimmerBox(40.w, 10.h, radius: 4),
                      SizedBox(width: 4.w),
                      _shimmerBox(45.w, 10.h, radius: 4),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  // Price + Button row - using Flexible to prevent overflow
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Container(
                          height: 16.h,
                          constraints: BoxConstraints(maxWidth: 65.w),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: Colors.white,
                          ),
                          child: _shimmerBox(65.w, 16.h, radius: 4),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      _shimmerBox(80.w, 28.h, radius: 14),
                    ],
                  ),
                ],
              ),
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
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.grey300),
          SizedBox(height: AppSpacing.md),
          Text(
            context.l10n.noVehiclesFound,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.grey700,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            context.l10n.spareTryAdjustingFilters,
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
