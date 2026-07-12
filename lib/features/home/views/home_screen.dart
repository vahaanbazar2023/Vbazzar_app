import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/storage/storage_keys.dart';
import '../../../routes/app_routes.dart';
import '../../../features/buy_and_sell/domain/entities/vehicle_category_entity.dart';
import '../../../features/auction/models/auction_listing.dart';
import '../../../features/spare_and_fms/domain/entities/spare_part_entity.dart';
import '../../../features/subscription/models/user_subscription.dart';
import '../../../features/subscription/services/subscription_guard_service.dart';
import '../controllers/home_controller.dart';
import '../data/models/dashboard_model.dart';

/// Returns up to 2 uppercase initials from a full name string.
/// "Prem Kumar" → "PK", "John" → "J", "" → ""
String _initials(String fullName) {
  final parts = fullName.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty || parts.first.isEmpty) return '';
  if (parts.length == 1) return parts.first[0].toUpperCase();
  return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
}

/// Gate for any auction navigation from the home screen.
/// Checks SUBT001 — if not active, redirects to the subscription screen.
Future<void> _openAuction({Map<String, dynamic>? arguments}) async {
  final guard = SubscriptionGuardService.to;
  await guard.ensureLoaded(forceRefresh: false);

  final hasAccess = guard.hasActiveSubscription(SubscriptionTypeCode.auction);

  if (hasAccess) {
    Get.toNamed(AppRoutes.auctionListings, arguments: arguments);
    return;
  }

  Get.toNamed(
    AppRoutes.subscription,
    arguments: {
      'subscription_source': SubscriptionTypeCode.auction,
      'title': 'Choose Subscription Plan',
      'subtitle': 'Choose a subscription plan to unlock features of auction',
    },
  );
}

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
              return const _DashboardShimmer();
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
                    _LiveAuctionCarousel(auctions: data.liveAuctions),
                    SizedBox(height: 24.h),
                    // ── Most Bought Categories ───────────────────
                    if (data.mostBoughtCategories.isNotEmpty) ...[
                      _SectionHeader(
                        title: context.l10n.mostBoughtVehicles,
                        onViewAll: () => Get.toNamed(AppRoutes.buySellHome),
                      ),
                      SizedBox(height: 12.h),
                      _MostBoughtCategoriesGrid(
                        categories: data.mostBoughtCategories,
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
                    SizedBox(height: 28.h),
                    // ── Mechanics Near You ───────────────────────
                    _SectionHeader(
                      title: context.l10n.mechanicsNearYou,
                      onViewAll: () =>
                          Get.toNamed(AppRoutes.serviceSupportListView),
                    ),
                    SizedBox(height: 12.h),
                    _MechanicsMarquee(),
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
  const _HomeHeader();

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
      child: GetX<HomeController>(
        builder: (ctrl) {
          final label = ctrl.locationLabel.value;
          return Row(
            children: [
              // Location — left side
              Expanded(
                child: GestureDetector(
                  onTap: () => ctrl.refreshLocation(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        color: AppColors.primary,
                        size: 18.r,
                      ),
                      SizedBox(width: 4.w),
                      Flexible(
                        child: Text(
                          label.isNotEmpty ? label : 'Locating...',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.grey600,
                        size: 18.r,
                      ),
                    ],
                  ),
                ),
              ),
              // Notification
              SvgPicture.asset(
                AppAssets.iconNotification,
                width: 26.r,
                height: 26.r,
              ),
              SizedBox(width: 14.w),
              // Customer care
              GestureDetector(
                onTap: () async {
                  final uri = Uri(scheme: 'tel', path: '+918008801806');
                  if (await canLaunchUrl(uri)) launchUrl(uri);
                },
                child: Image.asset(
                  AppAssets.customerCare,
                  width: 28.r,
                  height: 28.r,
                ),
              ),
            ],
          );
        },
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
  Timer? _autoSlideTimer;

  // When auctions is empty we fall back to the promo poster images.
  bool get _showPosters => widget.auctions.isEmpty;
  List<String> get _posterPaths => AppAssets.promoPosterImages;
  int get _itemCount =>
      _showPosters ? _posterPaths.length : widget.auctions.length;

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _autoSlideTimer?.cancel();
    if (_itemCount <= 1) return;
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted || !_pageCtrl.hasClients) return;
      final next = (_currentPage + 1) % _itemCount;
      _pageCtrl.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageCtrl.dispose();
    super.dispose();
  }

  Widget _buildDots() {
    if (_itemCount <= 1) return const SizedBox.shrink();
    return Positioned(
      bottom: 10.h,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          _itemCount,
          (i) => AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: EdgeInsets.symmetric(horizontal: 3.w),
            width: i == _currentPage ? 16.w : 6.w,
            height: 6.h,
            decoration: BoxDecoration(
              color: i == _currentPage
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(3.r),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 210.h,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageCtrl,
            physics: _itemCount <= 1
                ? const NeverScrollableScrollPhysics()
                : const BouncingScrollPhysics(),
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: _itemCount,
            itemBuilder: (_, i) => _showPosters
                ? _PromoPostCard(imagePath: _posterPaths[i])
                : _AuctionBannerCard(auction: widget.auctions[i]),
          ),
          _buildDots(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Promo Poster Card — shown when liveAuctions is empty
// ─────────────────────────────────────────────────────────────────────────────

class _PromoPostCard extends StatelessWidget {
  final String imagePath;
  const _PromoPostCard({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Image.asset(
          imagePath,
          width: double.infinity,
          height: 180.h,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: AppColors.grey100,
            child: Center(
              child: Icon(
                Icons.image_outlined,
                size: 48.r,
                color: AppColors.grey400,
              ),
            ),
          ),
        ),
      ),
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
      onTap: () => _openAuction(arguments: {'auction': auction}),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          color: const Color(0xFF6B0000),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8B1A1A).withValues(alpha: 0.45),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Stack(
            children: [
              // Radial glow background
              Positioned.fill(
                child: CustomPaint(painter: _RadialGlowPainter()),
              ),
              // Bulldozer — right side, fills height
              Positioned(
                right: -8.w,
                bottom: 0,
                top: 0,
                child: Image.asset(
                  AppAssets.yellowBulldoser,
                  fit: BoxFit.contain,
                  width: 170.w,
                ),
              ),
              // Content — left side
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 14.h, 170.w, 14.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Live badge
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 5.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.7),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7.w,
                            height: 7.w,
                            decoration: const BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 5.w),
                          Text(
                            context.l10n.liveAuction.toUpperCase(),
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 6.h),
                    // Title — large
                    Text(
                      auction.auctionTitle.isNotEmpty
                          ? auction.auctionTitle
                          : '${auction.category} Auction',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    // Timer — hourglass + countdown inline
                    _AuctionTimer(endAt: auction.endAt),
                    SizedBox(height: 35.h),
                    // Bid Now — white pill, red text
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            context.l10n.bid_now,
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
                            size: 14.r,
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
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Auction timer — hourglass emoji + "XXh XXm left" plain text
// ─────────────────────────────────────────────────────────────────────────────

class _AuctionTimer extends StatefulWidget {
  final String endAt;
  const _AuctionTimer({required this.endAt});

  @override
  State<_AuctionTimer> createState() => _AuctionTimerState();
}

class _AuctionTimerState extends State<_AuctionTimer> {
  Timer? _timer;
  String _label = '';

  @override
  void initState() {
    super.initState();
    _update();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _update());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _update() {
    if (!mounted) return;
    setState(() => _label = _remaining(widget.endAt));
  }

  static String _remaining(String endAt) {
    try {
      DateTime end;
      if (endAt.contains('T')) {
        end = DateTime.parse(endAt).toLocal();
      } else {
        // "29 Jun 2029 - 06:00PM"
        final parts = endAt.split(' - ');
        final dp = parts[0].trim().split(' ');
        const m = {
          'Jan': 1,
          'Feb': 2,
          'Mar': 3,
          'Apr': 4,
          'May': 5,
          'Jun': 6,
          'Jul': 7,
          'Aug': 8,
          'Sep': 9,
          'Oct': 10,
          'Nov': 11,
          'Dec': 12,
        };
        final day = int.parse(dp[0]);
        final month = m[dp[1]] ?? 1;
        final year = int.parse(dp[2]);
        int h = 0, min = 0;
        if (parts.length > 1) {
          final t = parts[1].trim().toUpperCase();
          final isPm = t.endsWith('PM');
          final nums = t
              .replaceAll('AM', '')
              .replaceAll('PM', '')
              .trim()
              .split(':');
          h = int.parse(nums[0]);
          min = int.parse(nums[1]);
          if (isPm && h != 12) h += 12;
          if (!isPm && h == 12) h = 0;
        }
        end = DateTime(year, month, day, h, min);
      }
      final diff = end.difference(DateTime.now());
      if (diff.isNegative) return 'Ended';
      final totalH = diff.inHours;
      final mins = diff.inMinutes % 60;
      if (totalH >= 24) {
        final days = totalH ~/ 24;
        return '${days}d ${totalH % 24}h left';
      }
      return '${totalH}h ${mins}m left';
    } catch (_) {
      return endAt;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('⏳', style: TextStyle(fontSize: 14)),
        SizedBox(width: 5.w),
        Text(
          _label,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Most Bought Vehicles List
// ─────────────────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────
// Most Bought Categories Grid — 2-column
// ─────────────────────────────────────────────────────────────────────────────

class _MostBoughtCategoriesGrid extends StatelessWidget {
  final List<DashboardCategory> categories;
  const _MostBoughtCategoriesGrid({required this.categories});

  @override
  Widget build(BuildContext context) {
    // Only top 4
    final items = categories.take(4).toList();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12.h,
          crossAxisSpacing: 12.w,
          childAspectRatio: 0.78,
        ),
        itemCount: items.length,
        itemBuilder: (_, i) => _CategoryCard(category: items[i]),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final DashboardCategory category;
  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final entity = VehicleCategoryEntity(
          categoryCode: category.categoryCode,
          categoryName: category.categoryName,
          vehicleCount: category.vehicleCount,
          categoryPlan: category.categoryPlan,
          subscriptionAmount: category.subscriptionAmount,
        );
        Get.toNamed(
          AppRoutes.buyVehicleListings,
          arguments: {'category': entity},
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.grey200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image + badges ───────────────────────────────
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16.r),
                    ),
                    child: ColoredBox(
                      color: AppColors.grey50,
                      child: category.appDashImageUrl.isNotEmpty
                          ? Image.network(
                              category.appDashImageUrl,
                              height: double.infinity,
                              width: double.infinity,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => _placeholder(),
                            )
                          : _placeholder(),
                    ),
                  ),
                ],
              ),
            ),
            // ── Info ─────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(8.w, 6.h, 8.w, 8.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 1.h),
                  Text(
                    category.categoryName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Available',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 9.sp,
                                color: AppColors.grey500,
                              ),
                            ),
                            Text(
                              '${category.vehicleCount}',
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
                      // Buy Now pill
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 5.h,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.ctaGradientStart,
                              AppColors.ctaGradientEnd,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Buy Now',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 3.w),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 9.r,
                              color: Colors.white,
                            ),
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

  Widget _placeholder() => Container(
    color: AppColors.grey100,
    child: Center(
      child: Icon(
        Icons.directions_car_outlined,
        size: 28.r,
        color: AppColors.grey400,
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
class _RadialGlowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Base fill
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF1E1E1E),
    );
    // Radial glow — centered in the card
    final center = Offset(size.width * 0.5, size.height * 0.5);
    final radius = size.width * 0.55;
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFBB2625).withValues(alpha: 0.55),
          const Color(0xFFBB2625).withValues(alpha: 0.15),
          const Color(0xFF1E1E1E).withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.45, 1.0],
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
  const _InspectionBanner();

  Future<void> _openInspection() async {
    final userType =
        await SecureStorageService.to.read(StorageKeys.userType) ?? '';
    final normalized = userType.toUpperCase().trim();
    if (normalized == 'VENDOR' || normalized == 'AGENT') {
      Get.toNamed(AppRoutes.agentValuationForm);
    } else {
      Get.toNamed(AppRoutes.customerValuationForm);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _openInspection,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        // bottom padding gives room for the overflowing 3D image
        padding: EdgeInsets.only(bottom: 28.h),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // ── Card ─────────────────────────────────────────────
            Container(
              height: 200.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.r),
                color: const Color(0xFF1E1E1E),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18.r),
                child: Stack(
                  children: [
                    // Radial glow — centered
                    Positioned.fill(
                      child: CustomPaint(painter: _RadialGlowPainter()),
                    ),
                    // Content
                    Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 20.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title spans full width
                          Text(
                            context.l10n.isYourVehicleReadyForInspection,
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              height: 1.3,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          // Subtitle + button pushed to the right of the figure
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(left: 155.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    context.l10n.inspectionBannerSubtitle,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 11.sp,
                                      color: Colors.white.withValues(
                                        alpha: 0.85,
                                      ),
                                      height: 1.45,
                                    ),
                                  ),
                                  SizedBox(height: 14.h),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16.w,
                                      vertical: 6.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(28.r),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(
                                            0xFFBB2625,
                                          ).withValues(alpha: 0.45),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          context.l10n.inspectNow,
                                          style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        SizedBox(width: 6.w),
                                        Icon(
                                          Icons.arrow_forward_rounded,
                                          size: 14.r,
                                          color: AppColors.primary,
                                        ),
                                      ],
                                    ),
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
            ),
            // ── 3D figure — overflows bottom of card ─────────────
            Positioned(
              left: -4.w,
              bottom: -28.h,
              child: Image.asset(
                AppAssets.inspectionDashboardIcon,
                height: 185.h,
                fit: BoxFit.contain,
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
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 12,
              spreadRadius: 1,
              offset: const Offset(0, 4),
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
        // bottom padding gives room for the overflowing 3D image
        padding: EdgeInsets.only(bottom: 28.h),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // ── Card ─────────────────────────────────────────────
            Container(
              height: 200.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.r),
                color: const Color(0xFF1E1E1E),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18.r),
                child: Stack(
                  children: [
                    // Radial glow — same as inspection
                    Positioned.fill(
                      child: CustomPaint(painter: _RadialGlowPainter()),
                    ),
                    // Content
                    Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 20.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title spans full width
                          Text(
                            context.l10n.isYourVehicleLookingForInsurance,
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              height: 1.3,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          // Subtitle + button pushed to the right of the image
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(left: 180.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    context.l10n.insuranceBannerSubtitle,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 11.sp,
                                      color: Colors.white.withValues(
                                        alpha: 0.85,
                                      ),
                                      height: 1.45,
                                    ),
                                  ),
                                  SizedBox(height: 14.h),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16.w,
                                      vertical: 6.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(28.r),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(
                                            0xFFBB2625,
                                          ).withValues(alpha: 0.45),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          context.l10n.applyNow,
                                          style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        SizedBox(width: 6.w),
                                        Icon(
                                          Icons.arrow_forward_rounded,
                                          size: 14.r,
                                          color: AppColors.primary,
                                        ),
                                      ],
                                    ),
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
            ),
            // ── 3D vehicle + clipboard — overflows bottom ─────────
            Positioned(
              left: -4.w,
              bottom: -28.h,
              child: Image.asset(
                AppAssets.insuranceDashboardIcon,
                height: 185.h,
                fit: BoxFit.contain,
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
              icon: AppAssets.CE,
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
              icon: AppAssets.CV,
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
      child: Stack(
        children: [
          // Gradient border wrapper
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14.r),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.ctaGradientStart, AppColors.ctaGradientEnd],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.10),
                  blurRadius: 12,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Container(
              margin: const EdgeInsets.all(1.5), // border thickness
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(13.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(icon, height: 48.h, fit: BoxFit.contain),
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
          ),
          // Arrow badge pinned to top-right of the card
          Positioned(
            top: 10.h,
            right: 10.w,
            child: Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.ctaGradientStart,
                    AppColors.ctaGradientEnd,
                  ],
                ),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.arrow_outward_rounded,
                color: Colors.white,
                size: 13.r,
              ),
            ),
          ),
        ],
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

// ─────────────────────────────────────────────────────────────────────────────
// Mechanics Marquee — 2 rows, infinite auto-scroll, row 2 reversed direction
// ─────────────────────────────────────────────────────────────────────────────

// Static mechanic data — city labels paired with SVG assets
const _kMechanicCities = [
  'Vijayawada',
  'Hyderabad',
  'Vizag',
  'Guntur',
  'Vijayawada',
  'Hyderabad',
  'Vizag',
  'Guntur',
];

class _MechanicsMarquee extends StatelessWidget {
  const _MechanicsMarquee();

  @override
  Widget build(BuildContext context) {
    final icons = AppAssets.mechanicIcons;
    // Build a sufficiently long list by repeating to ensure seamless loop
    final row1 = List.generate(
      24,
      (i) => _MechanicCardData(
        svgPath: icons[i % icons.length],
        city: _kMechanicCities[i % _kMechanicCities.length],
      ),
    );
    final row2 = List.generate(
      24,
      (i) => _MechanicCardData(
        svgPath: icons[(i + 3) % icons.length],
        city: _kMechanicCities[(i + 2) % _kMechanicCities.length],
      ),
    );

    return Column(
      children: [
        // Row 1 — scrolls left
        _MarqueeRow(items: row1, reverse: false),
        SizedBox(height: 12.h),
        // Row 2 — scrolls right (opposite)
        _MarqueeRow(items: row2, reverse: true),
      ],
    );
  }
}

class _MechanicCardData {
  final String svgPath;
  final String city;
  const _MechanicCardData({required this.svgPath, required this.city});
}

class _MarqueeRow extends StatefulWidget {
  final List<_MechanicCardData> items;
  final bool reverse;
  const _MarqueeRow({required this.items, required this.reverse});

  @override
  State<_MarqueeRow> createState() => _MarqueeRowState();
}

class _MarqueeRowState extends State<_MarqueeRow> {
  late final ScrollController _ctrl;
  // Each card width + gap
  static const double _cardW = 110;
  static const double _gap = 10;
  static const double _itemStride = _cardW + _gap;

  @override
  void initState() {
    super.initState();
    // Start at the midpoint so we can scroll both ways
    final mid = widget.items.length / 2 * _itemStride;
    _ctrl = ScrollController(initialScrollOffset: mid);
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScroll());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _startScroll() {
    if (!mounted || !_ctrl.hasClients) return;
    _loop();
  }

  Future<void> _loop() async {
    while (mounted && _ctrl.hasClients) {
      final current = _ctrl.offset;
      final total = widget.items.length * _itemStride;
      final half = total / 2;

      double target;
      if (!widget.reverse) {
        target = current + half;
      } else {
        target = current - half;
      }

      // Clamp to valid range
      final max = _ctrl.position.maxScrollExtent;
      final min = _ctrl.position.minScrollExtent;
      target = target.clamp(min, max);

      await _ctrl.animateTo(
        target,
        duration: Duration(milliseconds: (half * 18).round()),
        curve: Curves.linear,
      );

      if (!mounted || !_ctrl.hasClients) break;

      // Jump back to midpoint to create seamless infinite illusion
      _ctrl.jumpTo(half);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160.h,
      child: ListView.separated(
        controller: _ctrl,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.items.length,
        separatorBuilder: (_, __) => SizedBox(width: _gap.w),
        itemBuilder: (_, i) => _MechanicCard(data: widget.items[i]),
      ),
    );
  }
}

class _MechanicCard extends StatelessWidget {
  final _MechanicCardData data;
  const _MechanicCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.serviceSupportListView),
      child: SizedBox(
        width: 110.w,
        child: Image.asset(
          data.svgPath,
          fit: BoxFit.contain,
          width: 110.w,
          errorBuilder: (_, __, ___) => Container(
            width: 110.w,
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Center(
              child: Icon(
                Icons.engineering_outlined,
                color: AppColors.grey400,
                size: 40.r,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dashboard Shimmer — mirrors the real dashboard layout
// ─────────────────────────────────────────────────────────────────────────────

class _DashboardShimmer extends StatefulWidget {
  const _DashboardShimmer();

  @override
  State<_DashboardShimmer> createState() => _DashboardShimmerState();
}

class _DashboardShimmerState extends State<_DashboardShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
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
      builder: (_, __) => SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header shimmer ───────────────────────────────────
            Container(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
              color: AppColors.white,
              child: Row(
                children: [
                  _Bone(width: 40.w, height: 40.w, radius: 20, anim: _anim),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: _Bone(
                      width: double.infinity,
                      height: 40.h,
                      radius: 20,
                      anim: _anim,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  _Bone(width: 26.r, height: 26.r, radius: 4, anim: _anim),
                  SizedBox(width: 12.w),
                  _Bone(width: 36.w, height: 36.w, radius: 18, anim: _anim),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // ── Auction banner shimmer ───────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: _Bone(
                width: double.infinity,
                height: 180.h,
                radius: 18,
                anim: _anim,
              ),
            ),
            SizedBox(height: 8.h),
            // Dot indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (i) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: 3.w),
                  child: _Bone(
                    width: i == 0 ? 16.w : 6.w,
                    height: 6.h,
                    radius: 3,
                    anim: _anim,
                  ),
                ),
              ),
            ),
            SizedBox(height: 24.h),

            // ── Section header shimmer ───────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _Bone(width: 160.w, height: 18.h, radius: 4, anim: _anim),
                  _Bone(width: 60.w, height: 14.h, radius: 4, anim: _anim),
                ],
              ),
            ),
            SizedBox(height: 12.h),

            // ── Most Bought Vehicles shimmer (2 cards) ───────────
            ...List.generate(
              2,
              (_) => Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
                child: Column(
                  children: [
                    _Bone(
                      width: double.infinity,
                      height: 180.h,
                      radius: 16,
                      anim: _anim,
                    ),
                    SizedBox(height: 1.h),
                    Container(
                      padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 10.h),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(16.r),
                        ),
                        border: Border.all(color: AppColors.grey200),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _Bone(
                                  width: 80.w,
                                  height: 10.h,
                                  radius: 4,
                                  anim: _anim,
                                ),
                                SizedBox(height: 4.h),
                                _Bone(
                                  width: 120.w,
                                  height: 14.h,
                                  radius: 4,
                                  anim: _anim,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 8.w),
                          _Bone(
                            width: 60.w,
                            height: 32.h,
                            radius: 16,
                            anim: _anim,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12.h),

            // ── Inspection banner shimmer ────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: _Bone(
                width: double.infinity,
                height: 220.h,
                radius: 18,
                anim: _anim,
              ),
            ),
            SizedBox(height: 24.h),

            // ── FMS section header shimmer ───────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _Bone(width: 100.w, height: 18.h, radius: 4, anim: _anim),
                  _Bone(width: 60.w, height: 14.h, radius: 4, anim: _anim),
                ],
              ),
            ),
            SizedBox(height: 12.h),

            // ── FMS items grid shimmer (2×2) ─────────────────────
            Padding(
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
                itemCount: 4,
                itemBuilder: (_, __) => _Bone(
                  width: double.infinity,
                  height: double.infinity,
                  radius: 12,
                  anim: _anim,
                ),
              ),
            ),
            SizedBox(height: 24.h),

            // ── Insurance banner shimmer ─────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: _Bone(
                width: double.infinity,
                height: 220.h,
                radius: 18,
                anim: _anim,
              ),
            ),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }
}

// ── Single shimmer bone ────────────────────────────────────────────────────

class _Bone extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  final Animation<double> anim;

  const _Bone({
    required this.width,
    required this.height,
    required this.radius,
    required this.anim,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: anim.value,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.grey200,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
