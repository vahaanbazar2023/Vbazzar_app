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
import '../controllers/search_controller.dart' as sc;
import '../../../core/extensions/context_extensions.dart';

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

List<_SearchEntry> _buildFeatureEntries(BuildContext context) => [
  _SearchEntry(
    title: context.l10n.auctionZone,
    subtitle: context.l10n.aucSearchAuctionSubtitle,
    assetImage: AppAssets.auction,
    iconColor: const Color(0xFFBB2625),
    iconBg: const Color(0xFFFFEEEE),
    onTap: () async {
      final planTitle = context.l10n.aucChooseSubscriptionPlan;
      final planSubtitle = context.l10n.aucChoosePlanUnlockAuction;
      final guard = SubscriptionGuardService.to;
      await guard.ensureLoaded(forceRefresh: false);
      if (guard.hasActiveSubscription(SubscriptionTypeCode.auction)) {
        Get.toNamed(AppRoutes.auctionType);
      } else {
        Get.toNamed(
          AppRoutes.subscription,
          arguments: {
            'subscription_source': SubscriptionTypeCode.auction,
            'title': planTitle,
            'subtitle': planSubtitle,
          },
        );
      }
    },
  ),
  _SearchEntry(
    title: context.l10n.aucSearchBuySellTitle,
    subtitle: context.l10n.aucSearchBuySellSubtitle,
    assetImage: AppAssets.buySell,
    iconColor: const Color(0xFF1976D2),
    iconBg: const Color(0xFFE3F2FD),
    onTap: () async => Get.toNamed(AppRoutes.buySellHome),
  ),
  _SearchEntry(
    title: context.l10n.aucSearchFmsTitle,
    subtitle: context.l10n.aucSearchFmsSubtitle,
    assetImage: AppAssets.fms,
    iconColor: const Color(0xFF388E3C),
    iconBg: const Color(0xFFE8F5E9),
    onTap: () async => Get.toNamed(AppRoutes.spareFms),
  ),
  _SearchEntry(
    title: context.l10n.insuranceFinance,
    subtitle: context.l10n.aucSearchInsuranceSubtitle,
    assetImage: AppAssets.insuranceFinance,
    iconColor: const Color(0xFF7B1FA2),
    iconBg: const Color(0xFFF3E5F5),
    onTap: () async => Get.toNamed(AppRoutes.insuranceFinance),
  ),
  _SearchEntry(
    title: context.l10n.aucSearchInspectionTitle,
    subtitle: context.l10n.aucSearchInspectionSubtitle,
    assetImage: AppAssets.inspection,
    iconColor: const Color(0xFFE65100),
    iconBg: const Color(0xFFFFF3E0),
    onTap: () async => Get.toNamed(AppRoutes.inspectionHome),
  ),
  _SearchEntry(
    title: context.l10n.aucSearchServiceSupportTitle,
    subtitle: context.l10n.aucSearchServiceSupportSubtitle,
    assetImage: AppAssets.spareParts,
    iconColor: const Color(0xFF0288D1),
    iconBg: const Color(0xFFE1F5FE),
    onTap: () async => Get.toNamed(AppRoutes.serviceSupport),
  ),
  _SearchEntry(
    title: context.l10n.myBids,
    subtitle: context.l10n.aucSearchMyBidsSubtitle,
    assetImage: AppAssets.auction,
    iconColor: const Color(0xFFBB2625),
    iconBg: const Color(0xFFFFEEEE),
    onTap: () async => Get.toNamed(AppRoutes.myBids),
  ),
  _SearchEntry(
    title: context.l10n.myWins,
    subtitle: context.l10n.aucSearchMyWinsSubtitle,
    icon: Icons.emoji_events_rounded,
    iconColor: const Color(0xFFD4A017),
    iconBg: const Color(0xFFFFF8E0),
    onTap: () async => Get.toNamed(AppRoutes.myWins),
  ),
  _SearchEntry(
    title: context.l10n.mySubscriptions,
    subtitle: context.l10n.aucSearchMySubscriptionsSubtitle,
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

List<_SearchEntry> _buildCategoryEntries(BuildContext context) => [
  _cat(
    context,
    'Backhoe Loader (BHL)',
    context.l10n.aucCatBackhoeLoader,
    'BHLD',
    'bhl.png',
    14,
  ),
  _cat(
    context,
    'Excavators',
    context.l10n.aucCatExcavators,
    'EXCV',
    'excavator.png',
    7,
  ),
  _cat(
    context,
    'Tippers',
    context.l10n.aucCatTippers,
    'TIPR',
    'tipper.png',
    24,
  ),
  _cat(context, 'Trucks', context.l10n.trucks, 'TRUC', 'truck.png', 9),
  _cat(context, 'ICV', context.l10n.aucCatICV, 'ICVH', 'icv.png', 12),
  _cat(context, 'LCV', context.l10n.aucCatLCV, 'LCVH', 'lcv.png', 5),
  _cat(
    context,
    'Trailers',
    context.l10n.aucCatTrailers,
    'TRLR',
    'trailer.png',
    4,
  ),
  _cat(context, 'Buses', context.l10n.buses, 'BUSS', 'bus.png', 3),
  _cat(
    context,
    'Farm Equipment',
    context.l10n.aucCatFarmEquipment,
    'FARM',
    'farmequipment.png',
    7,
  ),
  _cat(
    context,
    'Wheel Loader',
    context.l10n.aucCatWheelLoader,
    'WHLD',
    'wheelloader.png',
    0,
  ),
  _cat(context, 'Rollers', context.l10n.aucCatRollers, 'ROLL', 'roller.png', 2),
  _cat(
    context,
    'Motor Grader',
    context.l10n.aucCatMotorGrader,
    'MGRD',
    'motorgrader.png',
    0,
  ),
  _cat(
    context,
    'Self Loading Mixer',
    context.l10n.aucCatSelfLoadingMixer,
    'SLMX',
    'selfloadingmixer.png',
    0,
  ),
  _cat(
    context,
    'Transitmixer',
    context.l10n.aucCatTransitmixer,
    'TRMX',
    'transitmixer.png',
    0,
  ),
  _cat(
    context,
    'Crushing & Batching Plant',
    context.l10n.aucCatCrushingBatchingPlant,
    'CBPL',
    'crushingbatchingplant.png',
    0,
  ),
  _cat(
    context,
    'Cranes (Lifter)',
    context.l10n.aucCatCranes,
    'CRNS',
    'cranes.png',
    2,
  ),
  _cat(context, 'Gen-Set', context.l10n.aucCatGenSet, 'GENS', 'genset.png', 0),
  _cat(
    context,
    'Other Machines',
    context.l10n.aucCatOtherMachines,
    'OTHR',
    'other.png',
    0,
  ),
  _cat(context, 'Scrap', context.l10n.aucCatScrap, 'SCRP', 'scrap.png', 0),
  _cat(
    context,
    'jeepsy',
    context.l10n.aucCatJeepsy,
    'ADVENTURE',
    'jeepsy.png',
    0,
  ),
  _cat(context, 'Cars', context.l10n.cars, 'CARS', 'car.png', 34),
];

_SearchEntry _cat(
  BuildContext context,
  String name,
  String displayName,
  String code,
  String iconFile,
  int count,
) => _SearchEntry(
  title: displayName,
  subtitle: context.l10n.vehiclesAvailableCount(count),
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
    Get.toNamed(AppRoutes.buyVehicleListings, arguments: {'category': entity});
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
  final sc.SearchController _ctrl = Get.find<sc.SearchController>();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final features = _buildFeatureEntries(context);
    final categories = _buildCategoryEntries(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              _SearchHeader(
                controller: _ctrl.textController,
                onBack: () => Get.back(),
              ),
              Expanded(
                child: Obx(() {
                  final query = _ctrl.query.value;
                  // Empty query — show static suggestions
                  if (query.trim().length < 2) {
                    return _SuggestionsView(
                      features: features,
                      categories: categories,
                    );
                  }
                  // Loading
                  if (_ctrl.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }
                  // Error
                  if (_ctrl.errorMessage.value.isNotEmpty) {
                    return Center(
                      child: Text(
                        _ctrl.errorMessage.value,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 13.sp,
                          color: AppColors.grey500,
                        ),
                      ),
                    );
                  }
                  // No results
                  if (_ctrl.sections.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 56.r,
                            color: AppColors.grey300,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            context.l10n.aucNoResultsFor(query),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  // API results grouped by section
                  return _GlobalSearchResultsView(
                    sections: _ctrl.sections,
                    onTap: _ctrl.navigate,
                  );
                }),
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
                              label.isNotEmpty
                                  ? label
                                  : context.l10n.aucLocating,
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
                  hint: context.l10n.aucSearchHint,
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
            context.l10n.aucQuickAccess,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
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
            context.l10n.aucBrowseByCategory,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
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
            Flexible(
              child: Text(
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
              context.l10n.aucNoResultsFor(query),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              context.l10n.aucSearchSuggestionHint,
              textAlign: TextAlign.center,
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
                      fontWeight: FontWeight.w600,
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

// ─────────────────────────────────────────────────────────────────────────────
// Global API search results — grouped by section
// ─────────────────────────────────────────────────────────────────────────────

class _GlobalSearchResultsView extends StatelessWidget {
  final List<sc.GlobalSearchSection> sections;
  final void Function(sc.GlobalSearchItem) onTap;

  const _GlobalSearchResultsView({required this.sections, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 32.h),
      itemCount: sections.length,
      itemBuilder: (_, si) {
        final section = sections[si];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            Padding(
              padding: EdgeInsets.only(bottom: 8.h, top: si == 0 ? 0 : 16.h),
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      section.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                        fontSize: 13.sp,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      '${section.totalCount}',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Items
            ...section.items.map(
              (item) => _GlobalResultTile(item: item, onTap: () => onTap(item)),
            ),
          ],
        );
      },
    );
  }
}

class _GlobalResultTile extends StatelessWidget {
  final sc.GlobalSearchItem item;
  final VoidCallback onTap;

  const _GlobalResultTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
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
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(item.icon, size: 18.r, color: AppColors.primary),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                      fontSize: 13.sp,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.subtitle.isNotEmpty) ...[
                    SizedBox(height: 2.h),
                    Text(
                      item.subtitle,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 11.sp,
                        color: AppColors.grey500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 18.r,
              color: AppColors.grey400,
            ),
          ],
        ),
      ),
    );
  }
}
