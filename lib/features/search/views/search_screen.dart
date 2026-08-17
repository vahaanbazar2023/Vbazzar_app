import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/molecules/custom_search_bar.dart';
import '../../../routes/app_routes.dart';
import '../../buy_and_sell/domain/entities/vehicle_category_entity.dart';
import '../../home/controllers/home_controller.dart';
import '../../subscription/models/user_subscription.dart';
import '../../subscription/services/subscription_guard_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Search entry model — supports both network image URL and Material icon
// ─────────────────────────────────────────────────────────────────────────────

class _SearchEntry {
  final String title;
  final String subtitle;
  final String? imageUrl; // network icon
  final String? assetImage; // local asset PNG
  final IconData? icon; // material icon fallback
  final Color iconColor;
  final Color iconBg;
  final Future<void> Function() onTap;

  const _SearchEntry({
    required this.title,
    required this.subtitle,
    this.imageUrl,
    this.assetImage,
    this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.onTap,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Static app feature entries
// ─────────────────────────────────────────────────────────────────────────────

List<_SearchEntry> _buildFeatureEntries() => [
  _SearchEntry(
    title: 'Auction Zone',
    subtitle: 'Bid on live vehicle auctions',
    assetImage: AppAssets.auction,
    iconColor: const Color(0xFFBB2625),
    iconBg: const Color(0xFFFFEEEE),
    onTap: () async {
      final guard = SubscriptionGuardService.to;
      await guard.ensureLoaded(forceRefresh: false);
      if (guard.hasActiveSubscription(SubscriptionTypeCode.auction)) {
        Get.toNamed(AppRoutes.auctionType);
      } else {
        Get.toNamed(
          AppRoutes.subscription,
          arguments: {
            'subscription_source': SubscriptionTypeCode.auction,
            'title': 'Choose Subscription Plan',
            'subtitle': 'Choose a plan to unlock auction features',
          },
        );
      }
    },
  ),
  _SearchEntry(
    title: 'Buy & Sell',
    subtitle: 'Browse and list vehicles for sale',
    assetImage: AppAssets.buySell,
    iconColor: const Color(0xFF1976D2),
    iconBg: const Color(0xFFE3F2FD),
    onTap: () async => Get.toNamed(AppRoutes.buySellHome),
  ),
  _SearchEntry(
    title: 'FMS / Spare Parts',
    subtitle: 'Find spare parts and FMS items',
    assetImage: AppAssets.fms,
    iconColor: const Color(0xFF388E3C),
    iconBg: const Color(0xFFE8F5E9),
    onTap: () async => Get.toNamed(AppRoutes.spareFms),
  ),
  _SearchEntry(
    title: 'Insurance & Finance',
    subtitle: 'Get insurance quotes and financing',
    assetImage: AppAssets.insuranceFinance,
    iconColor: const Color(0xFF7B1FA2),
    iconBg: const Color(0xFFF3E5F5),
    onTap: () async => Get.toNamed(AppRoutes.insuranceFinance),
  ),
  _SearchEntry(
    title: 'Inspection',
    subtitle: 'Request vehicle inspection & valuation',
    assetImage: AppAssets.inspection,
    iconColor: const Color(0xFFE65100),
    iconBg: const Color(0xFFFFF3E0),
    onTap: () async => Get.toNamed(AppRoutes.inspectionHome),
  ),
  _SearchEntry(
    title: 'Service Support',
    subtitle: 'Find mechanics and service centers',
    assetImage: AppAssets.spareParts,
    iconColor: const Color(0xFF0288D1),
    iconBg: const Color(0xFFE1F5FE),
    onTap: () async => Get.toNamed(AppRoutes.serviceSupport),
  ),
  _SearchEntry(
    title: 'My Bids',
    subtitle: 'Track your active and past bids',
    assetImage: AppAssets.auction,
    iconColor: const Color(0xFFBB2625),
    iconBg: const Color(0xFFFFEEEE),
    onTap: () async => Get.toNamed(AppRoutes.myBids),
  ),
  _SearchEntry(
    title: 'My Wins',
    subtitle: 'View vehicles you have won',
    icon: Icons.emoji_events_rounded,
    iconColor: const Color(0xFFD4A017),
    iconBg: const Color(0xFFFFF8E0),
    onTap: () async => Get.toNamed(AppRoutes.myWins),
  ),
  _SearchEntry(
    title: 'My Subscriptions',
    subtitle: 'Manage your subscription plans',
    assetImage: AppAssets.subIconSubscriptions,
    iconColor: const Color(0xFF1976D2),
    iconBg: const Color(0xFFE3F2FD),
    onTap: () async => Get.toNamed(AppRoutes.mySubscriptions),
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Vehicle category entries (icon_url from API)
// ─────────────────────────────────────────────────────────────────────────────

const _baseIconUrl =
    'https://vahaan-buy-and-sell-category-images.s3.ap-south-1.amazonaws.com/';

List<_SearchEntry> _buildCategoryEntries() => [
  _cat('Backhoe Loader (BHL)', 'BHLD', 'bhl.png', 14),
  _cat('Excavators', 'EXCV', 'excavator.png', 7),
  _cat('Tippers', 'TIPR', 'tipper.png', 24),
  _cat('Trucks', 'TRUC', 'truck.png', 9),
  _cat('ICV', 'ICVH', 'icv.png', 12),
  _cat('LCV', 'LCVH', 'lcv.png', 5),
  _cat('Trailers', 'TRLR', 'trailer.png', 4),
  _cat('Buses', 'BUSS', 'bus.png', 3),
  _cat('Farm Equipment', 'FARM', 'farmequipment.png', 7),
  _cat('Wheel Loader', 'WHLD', 'wheelloader.png', 0),
  _cat('Rollers', 'ROLL', 'roller.png', 2),
  _cat('Motor Grader', 'MGRD', 'motorgrader.png', 0),
  _cat('Self Loading Mixer', 'SLMX', 'selfloadingmixer.png', 0),
  _cat('Transitmixer', 'TRMX', 'transitmixer.png', 0),
  _cat('Crushing & Batching Plant', 'CBPL', 'crushingbatchingplant.png', 0),
  _cat('Cranes (Lifter)', 'CRNS', 'cranes.png', 2),
  _cat('Gen-Set', 'GENS', 'genset.png', 0),
  _cat('Other Machines', 'OTHR', 'other.png', 0),
  _cat('Scrap', 'SCRP', 'scrap.png', 0),
  _cat('jeepsy', 'ADVENTURE', 'jeepsy.png', 0),
  _cat('Cars', 'CARS', 'car.png', 34),
];

_SearchEntry _cat(String name, String code, String iconFile, int count) =>
    _SearchEntry(
      title: name,
      subtitle: '$count vehicles available',
      imageUrl: '$_baseIconUrl$iconFile',
      iconColor: const Color(0xFFBB2625),
      iconBg: const Color(0xFFFFEEEE),
      onTap: () async {
        final entity = VehicleCategoryEntity(
          categoryCode: code,
          categoryName: name,
          vehicleCount: count,
          categoryPlan: '',
          subscriptionAmount: 0,
        );
        Get.toNamed(
          AppRoutes.buyVehicleListings,
          arguments: {'category': entity},
        );
      },
    );

// ─────────────────────────────────────────────────────────────────────────────
// Search Screen
// ─────────────────────────────────────────────────────────────────────────────

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  final List<_SearchEntry> _features = _buildFeatureEntries();
  final List<_SearchEntry> _categories = _buildCategoryEntries();
  late final List<_SearchEntry> _all;

  @override
  void initState() {
    super.initState();
    _all = [..._features, ..._categories];
    _controller.addListener(() {
      setState(() => _query = _controller.text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<_SearchEntry> get _results {
    if (_query.trim().isEmpty) return [];
    final q = _query.toLowerCase();
    return _all
        .where(
          (e) =>
              e.title.toLowerCase().contains(q) ||
              e.subtitle.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              _SearchHeader(controller: _controller, onBack: () => Get.back()),
              Expanded(
                child: _query.isEmpty
                    ? _SuggestionsView(
                        features: _features,
                        categories: _categories,
                      )
                    : _SearchResultsList(results: _results, query: _query),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────────────────────────

class _SearchHeader extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onBack;
  const _SearchHeader({required this.controller, required this.onBack});

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Location + icons row
          GetX<HomeController>(
            builder: (ctrl) {
              final label = ctrl.locationLabel.value;
              return Row(
                children: [
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
                            color: AppColors.textPrimary,
                            size: 14.r,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SvgPicture.asset(
                    AppAssets.iconNotification,
                    width: 26.r,
                    height: 26.r,
                  ),
                  SizedBox(width: 14.w),
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
          SizedBox(height: 10.h),
          // Back + search bar
          Row(
            children: [
              GestureDetector(
                onTap: onBack,
                child: Container(
                  width: 32.r,
                  height: 32.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.ctaGradientStart,
                        AppColors.ctaGradientEnd,
                      ],
                    ),
                    border: Border.all(
                      color: const Color(0xFFD41F1F),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppColors.white,
                    size: 14.r,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: CustomSearchBar(
                  controller: controller,
                  autofocus: true,
                  hint: 'Search by service, vehicle...',
                  showGradientBorder: true,
                  alwaysShowGradientBorder: false,
                  borderRadius: 12,
                  height: 40,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Suggestions — features grid + categories horizontal list
// ─────────────────────────────────────────────────────────────────────────────

class _SuggestionsView extends StatelessWidget {
  final List<_SearchEntry> features;
  final List<_SearchEntry> categories;
  const _SuggestionsView({required this.features, required this.categories});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Quick Access ───────────────────────────────────────
          Text(
            'Quick Access',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w700,
              fontSize: 14.sp,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 12.h,
              crossAxisSpacing: 12.w,
              childAspectRatio: 0.9,
            ),
            itemCount: features.length,
            itemBuilder: (_, i) => _SuggestionTile(entry: features[i]),
          ),
          SizedBox(height: 24.h),
          // ── Browse by Category ─────────────────────────────────
          Text(
            'Browse by Category',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w700,
              fontSize: 14.sp,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 10.h,
              crossAxisSpacing: 10.w,
              childAspectRatio: 0.85,
            ),
            itemCount: categories.length,
            itemBuilder: (_, i) => _SuggestionTile(entry: categories[i]),
          ),
        ],
      ),
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  final _SearchEntry entry;
  const _SuggestionTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => entry.onTap(),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFFEEEEEE)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.all(8.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36.r,
              height: 36.r,

              padding: EdgeInsets.all(6.r),
              child: entry.imageUrl != null
                  ? Image.network(
                      entry.imageUrl!,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(
                        entry.icon ?? Icons.category_rounded,
                        color: entry.iconColor,
                        size: 32.r,
                      ),
                    )
                  : entry.assetImage != null
                  ? Image.asset(entry.assetImage!, fit: BoxFit.contain)
                  : Icon(
                      entry.icon ?? Icons.category_rounded,
                      color: entry.iconColor,
                      size: 18.r,
                    ),
            ),
            SizedBox(height: 6.h),
            Text(
              entry.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
                fontSize: 9.sp,
                color: AppColors.textPrimary,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Search results list
// ─────────────────────────────────────────────────────────────────────────────

class _SearchResultsList extends StatelessWidget {
  final List<_SearchEntry> results;
  final String query;
  const _SearchResultsList({required this.results, required this.query});

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 56.r, color: AppColors.grey300),
            SizedBox(height: 16.h),
            Text(
              'No results for "$query"',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Try auction, buy & sell, inspection...',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 12.sp,
                color: AppColors.grey400,
              ),
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: EdgeInsets.all(16.w),
      itemCount: results.length,
      separatorBuilder: (_, __) => SizedBox(height: 10.h),
      itemBuilder: (_, i) => _ResultTile(entry: results[i]),
    );
  }
}

class _ResultTile extends StatelessWidget {
  final _SearchEntry entry;
  const _ResultTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => entry.onTap(),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: const Color(0xFFEEEEEE)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42.r,
              height: 42.r,
              decoration: BoxDecoration(
                color: entry.iconBg,
                shape: BoxShape.circle,
              ),
              padding: EdgeInsets.all(8.r),
              child: entry.imageUrl != null
                  ? Image.network(
                      entry.imageUrl!,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(
                        entry.icon ?? Icons.category_rounded,
                        color: entry.iconColor,
                        size: 18.r,
                      ),
                    )
                  : entry.assetImage != null
                  ? Image.asset(entry.assetImage!, fit: BoxFit.contain)
                  : Icon(
                      entry.icon ?? Icons.category_rounded,
                      color: entry.iconColor,
                      size: 20.r,
                    ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.title,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    entry.subtitle,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 11.sp,
                      color: AppColors.grey500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14.r,
              color: AppColors.grey400,
            ),
          ],
        ),
      ),
    );
  }
}
