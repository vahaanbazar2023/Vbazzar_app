import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../routes/app_routes.dart';
import '../../../features/auction/models/auction_listing.dart';
import '../../../features/spare_and_fms/domain/entities/spare_part_entity.dart';
import '../controllers/home_controller.dart';
import '../data/models/dashboard_model.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }
            if (controller.hasError.value) {
              return _ErrorState(
                message: controller.errorMessage.value,
                onRetry: controller.fetchDashboard,
              );
            }
            final data = controller.dashboardData.value;
            if (data == null) {
              return _ErrorState(
                message: 'No data available.',
                onRetry: controller.fetchDashboard,
              );
            }
            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: controller.fetchDashboard,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header ──────────────────────────────────
                    _HomeHeader(),
                    SizedBox(height: 16.h),
                    // ── Live Auction Carousel ────────────────────
                    if (data.liveAuctions.isNotEmpty) ...[
                      _LiveAuctionCarousel(auctions: data.liveAuctions),
                      SizedBox(height: 24.h),
                    ],
                    // ── Most Bought Vehicles ─────────────────────
                    if (data.mostBoughtVehicles.isNotEmpty) ...[
                      _SectionHeader(
                        title: context.l10n.mostBoughtVehicles,
                        onViewAll: () => Get.toNamed(AppRoutes.auctionListings),
                      ),
                      SizedBox(height: 12.h),
                      _MostBoughtVehiclesList(
                        vehicles: data.mostBoughtVehicles,
                      ),
                      SizedBox(height: 24.h),
                    ],
                    // ── Inspection Banner ────────────────────────
                    _InspectionBanner(),
                    SizedBox(height: 24.h),
                    // ── FMS Items ────────────────────────────────
                    if (data.sparesFms.isNotEmpty) ...[
                      _SectionHeader(
                        title: context.l10n.fmsItems,
                        onViewAll: () => Get.toNamed(AppRoutes.spareFms),
                      ),
                      SizedBox(height: 12.h),
                      _FmsItemsGrid(spares: data.sparesFms),
                      SizedBox(height: 24.h),
                    ],
                    // ── Insurance Banner ─────────────────────────
                    _InsuranceBanner(),
                    SizedBox(height: 24.h),
                    // ── Spare Support Near You ───────────────────
                    _SectionHeader(title: context.l10n.spareSupportNearYou),
                    SizedBox(height: 12.h),
                    _SpareSupportSection(),
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────────────────────────

class _HomeHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 40.w,
            height: 40.w,
            decoration: const BoxDecoration(
              color: Color(0xFFFFE5E5),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person, color: AppColors.primary, size: 22.sp),
          ),
          SizedBox(width: 10.w),
          // Search bar
          Expanded(
            child: Container(
              height: 40.h,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: AppColors.grey200),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: AppColors.grey500, size: 18.r),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      context.l10n.searchByServiceVehicle,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 12.sp,
                        color: AppColors.grey500,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 10.w),
          // Notification
          Stack(
            children: [
              Icon(
                Icons.notifications_outlined,
                color: AppColors.textPrimary,
                size: 26.r,
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 8.r,
                  height: 8.r,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 12.w),
          // Chat
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              color: Colors.white,
              size: 18.r,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section Header
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onViewAll;
  const _SectionHeader({required this.title, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          if (onViewAll != null)
            GestureDetector(
              onTap: onViewAll,
              child: Text(
                context.l10n.viewAll,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Live Auction Carousel
// ─────────────────────────────────────────────────────────────────────────────

class _LiveAuctionCarousel extends StatefulWidget {
  final List<AuctionListing> auctions;
  const _LiveAuctionCarousel({required this.auctions});

  @override
  State<_LiveAuctionCarousel> createState() => _LiveAuctionCarouselState();
}

class _LiveAuctionCarouselState extends State<_LiveAuctionCarousel> {
  final PageController _pageCtrl = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 180.h,
          child: PageView.builder(
            controller: _pageCtrl,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: widget.auctions.length,
            itemBuilder: (_, i) =>
                _AuctionBannerCard(auction: widget.auctions[i]),
          ),
        ),
        if (widget.auctions.length > 1) ...[
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.auctions.length,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: EdgeInsets.symmetric(horizontal: 3.w),
                width: i == _currentPage ? 16.w : 6.w,
                height: 6.h,
                decoration: BoxDecoration(
                  color: i == _currentPage
                      ? AppColors.primary
                      : AppColors.grey300,
                  borderRadius: BorderRadius.circular(3.r),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Auction Banner Card (dark red gradient with bulldozer image)
// ─────────────────────────────────────────────────────────────────────────────

class _AuctionBannerCard extends StatelessWidget {
  final AuctionListing auction;
  const _AuctionBannerCard({required this.auction});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoutes.auctionListings,
        arguments: {'auction': auction},
      ),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFF8B1A1A), Color(0xFFBB2625)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFBB2625).withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Bulldozer image — right side
            Positioned(
              right: 0,
              bottom: 0,
              top: 0,
              child: Image.asset(
                AppAssets.yellowBulldoser,
                fit: BoxFit.contain,
                width: 160.w,
              ),
            ),
            // Content — left side
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 155.w, 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Live badge
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6.w,
                          height: 6.w,
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          context.l10n.liveAuction.toUpperCase(),
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 8.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8.h),
                  // Title
                  Text(
                    auction.auctionTitle.isNotEmpty
                        ? auction.auctionTitle
                        : '${auction.category} Auction',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.25,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  // Timer row — clipped to available width
                  TimerBadge(endAt: auction.endAt),
                  SizedBox(height: 10.h),
                  // Bid Now button
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          context.l10n.bid_now,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 12.r,
                          color: AppColors.primary,
                        ),
                      ],
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
}

// ─────────────────────────────────────────────────────────────────────────────
// Most Bought Vehicles List
// ─────────────────────────────────────────────────────────────────────────────

class _MostBoughtVehiclesList extends StatelessWidget {
  final List<DashboardVehicle> vehicles;
  const _MostBoughtVehiclesList({required this.vehicles});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: vehicles.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (_, i) => _MostBoughtVehicleCard(vehicle: vehicles[i]),
    );
  }
}

class _MostBoughtVehicleCard extends StatelessWidget {
  final DashboardVehicle vehicle;
  const _MostBoughtVehicleCard({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoutes.vehicleDetail,
        arguments: {
          'vehicle_id': vehicle.vehicleId,
          'auction_id': vehicle.auctionId,
        },
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.grey200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(16.r),
                  ),
                  child: vehicle.primaryImage.isNotEmpty
                      ? Image.network(
                          vehicle.primaryImage,
                          height: 180.h,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _imagePlaceholder(),
                        )
                      : _imagePlaceholder(),
                ),
                // Rating badge
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star_rounded,
                          color: const Color(0xFFFFC107),
                          size: 14.r,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          vehicle.bidCount.toString(),
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Favourite
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.favorite_border_rounded,
                      color: AppColors.primary,
                      size: 16.r,
                    ),
                  ),
                ),
              ],
            ),
            // Info row
            Padding(
              padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 10.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Vehicle model
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          context.l10n.vehicleModel,
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 10.sp,
                            color: AppColors.grey500,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          vehicle.displayTitle,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  // Available vehicles
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        context.l10n.availableVehicles,
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 10.sp,
                          color: AppColors.grey500,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        vehicle.bidsReceived.toString(),
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 8.w),
                  // Buy Now button
                  GestureDetector(
                    onTap: () => Get.toNamed(
                      AppRoutes.vehicleDetail,
                      arguments: {
                        'vehicle_id': vehicle.vehicleId,
                        'auction_id': vehicle.auctionId,
                      },
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 7.h,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.ctaGradientStart,
                            AppColors.ctaGradientEnd,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            context.l10n.buyNow,
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 12.r,
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

  Widget _imagePlaceholder() {
    return Container(
      height: 180.h,
      width: double.infinity,
      color: AppColors.grey100,
      child: Center(
        child: Icon(
          Icons.directions_car_outlined,
          size: 48.r,
          color: AppColors.grey400,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Radial Glow Painter — #1E1E1E base with #BB2625 glow from center-right
// ─────────────────────────────────────────────────────────────────────────────

class _RadialGlowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Base fill
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF1E1E1E),
    );
    // Radial glow — positioned at center-right
    final center = Offset(size.width * 0.75, size.height * 0.55);
    final radius = size.width * 0.7;
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFBB2625).withValues(alpha: 0.65),
          const Color(0xFFBB2625).withValues(alpha: 0.0),
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(_RadialGlowPainter old) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Inspection Banner
// ─────────────────────────────────────────────────────────────────────────────

class _InspectionBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.inspectionHome),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        height: 230.h,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18.r),
          color: const Color(0xFF1E1E1E),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Radial red glow from center-right
            Positioned.fill(child: CustomPaint(painter: _RadialGlowPainter())),
            // Main content column
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title — full width top
                  Text(
                    context.l10n.isYourVehicleReadyForInspection,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  // Bottom row: image left + text+button right
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Inspector image
                      Image.asset(
                        AppAssets.inspectionDashboardIcon,
                        height: 130.h,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(width: 12.w),
                      // Subtitle + button
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              context.l10n.inspectionBannerSubtitle,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 13.sp,
                                color: Colors.white.withValues(alpha: 0.85),
                                height: 1.4,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(28.r),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    context.l10n.inspectNow,
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  SizedBox(width: 6.w),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 16.r,
                                    color: AppColors.primary,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20.h),
                          ],
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
}

// ─────────────────────────────────────────────────────────────────────────────
// FMS Items 2×2 Grid
// ─────────────────────────────────────────────────────────────────────────────

class _FmsItemsGrid extends StatelessWidget {
  final List<SparePartEntity> spares;
  const _FmsItemsGrid({required this.spares});

  @override
  Widget build(BuildContext context) {
    final items = spares.take(4).toList();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12.h,
          crossAxisSpacing: 12.w,
          childAspectRatio: 1.1,
        ),
        itemCount: items.length,
        itemBuilder: (_, i) => _FmsItemCard(spare: items[i]),
      ),
    );
  }
}

class _FmsItemCard extends StatelessWidget {
  final SparePartEntity spare;
  const _FmsItemCard({required this.spare});

  @override
  Widget build(BuildContext context) {
    final imageUrl = spare.photos.isNotEmpty ? spare.photos.first : '';
    return GestureDetector(
      onTap: () =>
          Get.toNamed(AppRoutes.spareDetail, arguments: {'spare': spare}),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.grey200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholder(),
                      )
                    : _placeholder(),
              ),
            ),
            // Details
            Padding(
              padding: EdgeInsets.all(8.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    spare.spareName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '₹${spare.price}',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
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

  Widget _placeholder() => Container(
    color: AppColors.grey100,
    child: Center(
      child: Icon(Icons.build_outlined, color: AppColors.grey400, size: 28.r),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Insurance Banner
// ─────────────────────────────────────────────────────────────────────────────

class _InsuranceBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.insuranceFinance),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        height: 230.h,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18.r),
          color: const Color(0xFF1E1E1E),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Radial red glow from center-right
            Positioned.fill(child: CustomPaint(painter: _RadialGlowPainter())),
            // Main content column
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title — full width top
                  Text(
                    context.l10n.isYourVehicleLookingForInsurance,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  // Bottom row: image left + text+button right
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Insurance image
                      Image.asset(
                        AppAssets.insuranceDashboardIcon,
                        height: 130.h,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(width: 12.w),
                      // Subtitle + button
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              context.l10n.insuranceBannerSubtitle,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 13.sp,
                                color: Colors.white.withValues(alpha: 0.85),
                                height: 1.4,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(28.r),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    context.l10n.applyNow,
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  SizedBox(width: 6.w),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 16.r,
                                    color: AppColors.primary,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20.h),
                          ],
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
}

// ─────────────────────────────────────────────────────────────────────────────
// Spare Support Near You — CE & CV tiles
// ─────────────────────────────────────────────────────────────────────────────

class _SpareSupportSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Expanded(
            child: _SpareSupportTile(
              icon: AppAssets.inspection,
              title: context.l10n.constructionEquipmentCe,
              subtitle: context.l10n.spareSupportTileSubtitle,
              onTap: () => Get.toNamed(
                AppRoutes.shopList,
                arguments: {'category': 'CE'},
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _SpareSupportTile(
              icon: AppAssets.buySell,
              title: context.l10n.commercialVehicleCv,
              subtitle: context.l10n.spareSupportTileSubtitle,
              onTap: () => Get.toNamed(
                AppRoutes.shopList,
                arguments: {'category': 'CV'},
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpareSupportTile extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SpareSupportTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.grey200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.asset(icon, height: 48.h, fit: BoxFit.contain),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 22.w,
                    height: 22.w,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_outward_rounded,
                      color: Colors.white,
                      size: 12.r,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 10.sp,
                color: AppColors.grey500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Error State
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: AppColors.primary,
              size: 56.r,
            ),
            SizedBox(height: 16.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14.sp,
                color: AppColors.grey600,
              ),
            ),
            SizedBox(height: 20.h),
            GradientButton.filled(
              text: context.l10n.retry,
              onPressed: onRetry,
              width: 120.w,
            ),
          ],
        ),
      ),
    );
  }
}
