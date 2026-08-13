import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/subscription_controller.dart';
import '../models/subscription_plan.dart';
import '../services/subscription_guard_service.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/design_system/organisms/app_bottom_nav_bar.dart';
import '../../../core/design_system/molecules/custom_snackbar.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/storage/storage_keys.dart';
import '../../../features/auction/controllers/vehicle_listing_controller.dart';
import '../../../features/auction/controllers/my_bids_wins_controller.dart';
import '../../../features/buy_and_sell/controllers/vehicle_detail_controller.dart';
import '../../../features/main_shell/controllers/main_shell_controller.dart';
import '../../../features/payment/controllers/payment_controller.dart';
import '../../../routes/app_routes.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SubscriptionScreen
// ─────────────────────────────────────────────────────────────────────────────

class SubscriptionScreen extends StatefulWidget {
  final String subscriptionSource;
  final String title;
  final String subtitle;
  final SubscriptionPlan? prebuiltPlan;
  final Map<String, dynamic> extraArgs;

  const SubscriptionScreen({
    super.key,
    required this.subscriptionSource,
    this.title = 'Subscription',
    this.subtitle = 'Choose Your Subscription',
    this.prebuiltPlan,
    this.extraArgs = const {},
  });

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  @override
  void dispose() {
    if (widget.subscriptionSource != 'SUBT002') {
      if (Get.isRegistered<VehicleListingController>()) {
        Get.find<VehicleListingController>().pendingBid.value = null;
      }
      if (Get.isRegistered<MyBidsController>()) {
        Get.find<MyBidsController>().pendingBid.value = null;
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      SubscriptionController(
        subscriptionSource: widget.subscriptionSource,
        prebuiltPlan: widget.prebuiltPlan,
        extraArgs: widget.extraArgs,
      ),
      tag: widget.subscriptionSource,
    );

    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      bottomNavigationBar: Obx(() {
        final shell = Get.isRegistered<MainShellController>()
            ? Get.find<MainShellController>()
            : null;
        return AppBottomNavBar(
          currentTab: shell != null
              ? BottomNavTab.values[shell.currentIndex.value]
              : BottomNavTab.categories,
          onTabSelected: (tab) {
            shell?.changePage(tab.index);
            Get.until((route) => route.isFirst);
          },
        );
      }),
      body: Column(
        children: [
          // ── Red gradient header ───────────────────────────────
          _SubHeader(
            topPad: topPad,
            title: widget.title,
            subtitle: widget.subtitle.isEmpty
                ? 'Choose Your Subscription'
                : widget.subtitle,
          ),
          // ── White rounded body ────────────────────────────────
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -24),
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }
                  if (controller.errorMessage.value.isNotEmpty) {
                    return _ErrorState(
                      message: controller.errorMessage.value,
                      onRetry: controller.retry,
                    );
                  }
                  return _SubscriptionBody(
                    controller: controller,
                    subscriptionSource: widget.subscriptionSource,
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Red gradient header
// ─────────────────────────────────────────────────────────────────────────────

class _SubHeader extends StatelessWidget {
  final double topPad;
  final String title;
  final String subtitle;
  const _SubHeader({
    required this.topPad,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: topPad + 12.h,
        left: 20.w,
        right: 20.w,
        bottom: 32.h,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.authHeaderGradientStart,
            AppColors.authHeaderGradientEnd,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  width: 28.r,
                  height: 28.r,
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
                    Icons.chevron_left_rounded,
                    color: Colors.white,
                    size: 20.r,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Padding(
            padding: EdgeInsets.only(left: 40.w),
            child: Text(
              subtitle,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 13.sp,
                color: Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Body — plan cards list + proceed button
// ─────────────────────────────────────────────────────────────────────────────

class _SubscriptionBody extends StatefulWidget {
  final SubscriptionController controller;
  final String subscriptionSource;
  const _SubscriptionBody({
    required this.controller,
    required this.subscriptionSource,
  });

  @override
  State<_SubscriptionBody> createState() => _SubscriptionBodyState();
}

class _SubscriptionBodyState extends State<_SubscriptionBody> {
  final _referralController = TextEditingController();

  @override
  void dispose() {
    _referralController.dispose();
    super.dispose();
  }

  void _onProceed() async {
    final plan = widget.controller.selectedPlan;
    if (plan == null) return;
    final userId = await SecureStorageService.to.read(StorageKeys.userId) ?? '';
    if (userId.isEmpty) {
      Get.snackbar('Error', context.l10n.pleaseLoginToContinue);
      return;
    }
    final pc = Get.put(PaymentController());
    pc.onSuccess = (data, callback) async {
      _navigateAfterPayment(widget.subscriptionSource);
      SubscriptionGuardService.to.invalidateAndReload();
    };
    pc.onFailure = (message, callback) {
      Get.snackbar(
        context.l10n.paymentFailed,
        message,
        backgroundColor: Colors.red.shade100,
        duration: const Duration(seconds: 3),
      );
    };
    pc.onCancelled = () {
      Get.snackbar(
        context.l10n.paymentCancelled,
        context.l10n.youCancelledPayment,
        backgroundColor: Colors.orange.shade100,
        duration: const Duration(seconds: 2),
      );
    };
    await pc.initiatePayment(
      userId: userId,
      planCode: plan.planCode,
      forPayment: plan.price,
      referralCode: _referralController.text.trim().isNotEmpty
          ? _referralController.text.trim()
          : null,
    );
  }

  void _navigateAfterPayment(String source) {
    if (!mounted) return;
    final until = (route) =>
        route.settings.name != AppRoutes.subscription &&
        route.settings.name != AppRoutes.subscriptionConfirm &&
        route.settings.name != AppRoutes.walletPayment;
    if (source == 'SUBT001') {
      Get.until(until);
      Get.toNamed(AppRoutes.auctionType);
      CustomSnackbar.show(
        message: context.l10n.auctionAccessActivated,
        type: SnackbarType.success,
      );
    } else if (source == 'SUBT002') {
      final hasV = Get.isRegistered<VehicleListingController>();
      final hasM = Get.isRegistered<MyBidsController>();
      Get.until(until);
      if (hasV) _runSUBT002(Get.find<VehicleListingController>());
      if (hasM) _runMyBids(Get.find<MyBidsController>());
      if (!hasV && !hasM)
        CustomSnackbar.show(
          message: context.l10n.buyingLimitUpdated,
          type: SnackbarType.success,
        );
    } else if (source == 'SUBT003') {
      final args = Get.arguments as Map<String, dynamic>? ?? {};
      Get.until(until);
      CustomSnackbar.show(
        message: context.l10n.membershipActivated,
        type: SnackbarType.success,
      );
      SubscriptionGuardService.to.invalidateAndReload();
      final vid = args['pending_vehicle_id'] as String?;
      if (vid != null && Get.isRegistered<BuyVehicleController>())
        Get.find<BuyVehicleController>().unlockOwnerContactAndRefresh(
          vid,
          categoryCode: args['category_code'] as String? ?? '',
        );
    } else if (source == 'SUBT005' || source == 'INSPECTION') {
      final vid =
          (Get.arguments as Map<String, dynamic>? ?? {})['pending_vehicle_id']
              as String?;
      Get.until(until);
      if (vid != null && Get.isRegistered<BuyVehicleController>())
        Get.find<BuyVehicleController>().unlockInspectionAndRequest(vid);
      else
        CustomSnackbar.show(
          message: context.l10n.inspectionSubmitted,
          type: SnackbarType.success,
        );
      SubscriptionGuardService.to.invalidateAndReload();
    } else if (source == 'SUBT004') {
      final pending =
          (Get.arguments as Map<String, dynamic>? ?? {})['pending_vehicle'];
      Get.until(until);
      if (pending != null)
        Get.toNamed(
          AppRoutes.buyVehicleDetail,
          arguments: {'vehicle': pending},
        );
      CustomSnackbar.show(
        message: context.l10n.vehicleDetailsUnlocked,
        type: SnackbarType.success,
      );
      SubscriptionGuardService.to.invalidateAndReload();
    } else {
      Get.offAllNamed(AppRoutes.mySubscriptions);
      CustomSnackbar.show(
        message: context.l10n.subscriptionActivated,
        type: SnackbarType.success,
      );
    }
  }

  Future<void> _runSUBT002(VehicleListingController ctrl) async {
    try {
      await SubscriptionGuardService.to.invalidateAndReload();
    } catch (_) {
      CustomSnackbar.show(
        message: context.l10n.couldNotRefreshSubscription,
        type: SnackbarType.error,
      );
      return;
    }
    await ctrl.silentRefresh();
    await ctrl.revalidatePendingBid();
  }

  Future<void> _runMyBids(MyBidsController ctrl) async {
    try {
      await SubscriptionGuardService.to.invalidateAndReload();
    } catch (_) {
      CustomSnackbar.show(
        message: context.l10n.couldNotRefreshSubscription,
        type: SnackbarType.error,
      );
      return;
    }
    await ctrl.revalidatePendingBid();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
            itemCount: widget.controller.plans.length,
            itemBuilder: (_, i) {
              return Padding(
                padding: EdgeInsets.only(bottom: 14.h),
                child: Obx(
                  () => _PlanCard(
                    plan: widget.controller.plans[i],
                    index: i,
                    isSelected: widget.controller.selectedPlanIndex.value == i,
                    isMostPopular: i == 0,
                    subscriptionSource: widget.subscriptionSource,
                    onTap: () => widget.controller.selectPlan(i),
                  ),
                ),
              );
            },
          ),
        ),
        // ── Pay Now button ────────────────────────────────────
        Obx(() {
          final hasPlan = widget.controller.selectedPlan != null;
          return Container(
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 28.h),
            child: GradientButton.filled(
              text: 'Pay Now',
              onPressed: hasPlan ? _onProceed : null,
              height: 30.h,
              width: 150,
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
            ),
          );
        }),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Plan card — matches screenshot
// ─────────────────────────────────────────────────────────────────────────────

class _PlanCard extends StatelessWidget {
  final SubscriptionPlan plan;
  final int index;
  final bool isSelected;
  final bool isMostPopular;
  final String subscriptionSource;
  final VoidCallback onTap;

  const _PlanCard({
    required this.plan,
    required this.index,
    required this.isSelected,
    required this.isMostPopular,
    required this.subscriptionSource,
    required this.onTap,
  });

  bool get _isBidLimit => subscriptionSource == 'SUBT002';

  // Tier asset
  // Tier asset — matches API plan names: Basic/Premium/Elite (also gold/silver/bronze)
  String get _tierAsset {
    switch (plan.name.toLowerCase()) {
      case 'gold':
      case 'elite':
        return AppAssets.tierGold; // gold.png
      case 'silver':
      case 'premium':
        return AppAssets.tierSilver; // silver.png
      case 'bronze':
      case 'basic':
        return AppAssets.tierBronze; // bronze.png
      default:
        return AppAssets.tierGold; // safe fallback
    }
  }

  // Card bg
  Color get _bgColor {
    if (!isSelected) return Colors.white;
    switch (plan.name.toLowerCase()) {
      case 'gold':
      case 'elite':
        return const Color(0xFFFFF9EE);
      case 'silver':
      case 'premium':
        return const Color(0xFFF8F8F8);
      case 'bronze':
      case 'basic':
        return const Color(0xFFFFF5EE);
      default:
        return const Color(0xFFFFF9EE);
    }
  }

  // Card border & accent color
  Color get _borderColor {
    if (isSelected) {
      switch (plan.name.toLowerCase()) {
        case 'gold':
        case 'elite':
          return const Color(0xFFD4A017);
        case 'silver':
        case 'premium':
          return AppColors.grey400;
        case 'bronze':
        case 'basic':
          return const Color(0xFFCD7F32);
        default:
          return AppColors.primary;
      }
    }
    return const Color(0xFFEEEEEE);
  }

  // Support label
  String get _supportLabel {
    switch (plan.name.toLowerCase()) {
      case 'gold':
      case 'elite':
        return 'Elite Support';
      case 'silver':
      case 'premium':
        return 'Premium Support';
      default:
        return 'Basic Support';
    }
  }

  // Badge label
  String get _badgeLabel {
    switch (plan.name.toLowerCase()) {
      case 'gold':
      case 'elite':
        return 'Elite Plan';
      case 'silver':
      case 'premium':
        return 'Premium Plan';
      default:
        return 'Basic Plan';
    }
  }

  // Support icon — support.png for basic, support-2.png for premium/elite
  String get _supportIcon {
    switch (plan.name.toLowerCase()) {
      case 'gold':
      case 'elite':
        return AppAssets.subIconSupport1; // support-1.png
      case 'silver':
      case 'premium':
        return AppAssets.subIconSupport2; // support-2.png
      default:
        return AppAssets.subIconSupport; // support.png  (shield2 alias)
    }
  }

  // Original price for display (20% above)
  String get _originalPrice {
    final orig = (plan.price * 1.20).round();
    final s = orig.toString();
    if (s.length <= 3) return s;
    final last = s.substring(s.length - 3);
    final rest = s.substring(0, s.length - 3);
    return '$rest,$last';
  }

  String _fmtPrice(double p) {
    final s = p.toStringAsFixed(0);
    if (s.length <= 3) return s;
    final last = s.substring(s.length - 3);
    final rest = s.substring(0, s.length - 3);
    return '$rest,$last';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: _bgColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: _borderColor, width: isSelected ? 2 : 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 18.h, 14.w, 14.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Top row: badge + name/desc + radio/price ──────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tier badge — always show PNG
                      Image.asset(
                        _tierAsset,
                        width: 44.r,
                        height: 44.r,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(width: 14.w),
                      // Name + description
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 4.h),
                            Text(
                              plan.name,
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w700,
                                fontSize: 18.sp,
                                color: AppColors.black,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              plan.featDescription.isNotEmpty
                                  ? plan.featDescription
                                  : 'Unlimited Auction Access',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 12.sp,
                                color: AppColors.grey800,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 4.w),
                      // Radio/check + price column (right)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (isSelected)
                            Container(
                              width: 24.r,
                              height: 24.r,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary,
                              ),
                              child: Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 14.r,
                              ),
                            )
                          else
                            Container(
                              width: 24.r,
                              height: 24.r,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.grey300,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          SizedBox(height: 8.h),
                          Text(
                            '₹${_fmtPrice(plan.price)}',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
                              fontSize: 20.sp,
                              color: AppColors.black,
                            ),
                          ),
                          Text(
                            '₹$_originalPrice',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 12.sp,
                              color: AppColors.grey600,
                              decoration: TextDecoration.lineThrough,
                              decorationColor: AppColors.grey600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // ── Support row ────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Row(
                      children: [
                        Image.asset(
                          _supportIcon,
                          width: 20.r,
                          height: 20.r,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          _supportLabel,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 4.h),
                  const Divider(height: 1, color: Color(0xFFF0F0F0)),
                  SizedBox(height: 4.h),
                  // ── Feature chips — different layout for bid-limit plans ──
                  IntrinsicHeight(
                    child: _isBidLimit
                        ? Row(
                            children: [
                              Expanded(
                                child: _FeatureChip(
                                  icon: AppAssets.bidPng,
                                  label: 'Bid Limit',
                                  value: plan.metricLabel,
                                ),
                              ),
                              VerticalDivider(
                                width: 1,
                                thickness: 1,
                                color: const Color(0xFFF0F0F0),
                              ),
                              Expanded(
                                child: _FeatureChip(
                                  icon: AppAssets.subIconShield2,
                                  label: 'Secure & Trusted',
                                  value: '100% Safe',
                                ),
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: _FeatureChip(
                                  icon: AppAssets.calendarPng,
                                  label: 'Validity',
                                  value: plan.metricLabel,
                                ),
                              ),
                              VerticalDivider(
                                width: 1,
                                thickness: 1,
                                color: const Color(0xFFF0F0F0),
                              ),
                              Expanded(
                                child: _FeatureChip(
                                  icon: AppAssets.subIconShield2,
                                  label: 'Secure & Trusted',
                                  value: '100% Safe',
                                ),
                              ),
                              VerticalDivider(
                                width: 1,
                                thickness: 1,
                                color: const Color(0xFFF0F0F0),
                              ),
                              Expanded(
                                child: _FeatureChip(
                                  icon: AppAssets.subIconStar,
                                  label: isMostPopular ? 'Elite Benefits' : '',
                                  value: _badgeLabel,
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
            // ── MOST POPULAR ribbon ────────────────────────────────
            if (isMostPopular)
              Positioned(
                top: 0,
                left: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 5.h,
                  ),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFE6A817), Color(0xFFB8730A)],
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(14),
                      bottomRight: Radius.circular(10),
                    ),
                  ),
                  child: Text(
                    'MOST POPULAR',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.8,
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

// ─────────────────────────────────────────────────────────────────────────────
// Feature chip — icon + label + value stacked vertically
// ─────────────────────────────────────────────────────────────────────────────

class _FeatureChip extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  const _FeatureChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(icon, width: 18.r, height: 18.r, fit: BoxFit.contain),
          SizedBox(width: 5.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (label.isNotEmpty)
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 9.sp,
                      color: AppColors.grey600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Error state
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: 48.r, color: AppColors.grey300),
            SizedBox(height: 16.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 13.sp,
                color: AppColors.grey500,
                height: 1.5,
              ),
            ),
            SizedBox(height: 16.h),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  context.l10n.retry,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w700,
                    fontSize: 13.sp,
                    color: Colors.white,
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
