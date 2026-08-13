import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/subscription_controller.dart';
import '../models/subscription_plan.dart';
import '../services/subscription_guard_service.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/design_system/templates/app_layout.dart';
import '../../../core/design_system/molecules/custom_snackbar.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/storage/storage_keys.dart';
import '../../../features/auction/controllers/vehicle_listing_controller.dart';
import '../../../features/auction/controllers/my_bids_wins_controller.dart';
import '../../../features/buy_and_sell/controllers/vehicle_detail_controller.dart';
import '../../../features/payment/controllers/payment_controller.dart';
import '../../../routes/app_routes.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SubscriptionScreen — uses AppLayout (back button + bottom nav included)
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
    // Always clear pending bid when leaving the subscription flow
    if (Get.isRegistered<VehicleListingController>()) {
      Get.find<VehicleListingController>().pendingBid.value = null;
    }
    if (Get.isRegistered<MyBidsController>()) {
      Get.find<MyBidsController>().pendingBid.value = null;
    }
    super.dispose();
  }

  VoidCallback get _onBack {
    // SUBT002: skip the Place Bid screen that sits below in the stack
    if (widget.subscriptionSource == 'SUBT002') {
      return () => Get.until(
        (route) =>
            route.settings.name != AppRoutes.subscription &&
            route.settings.name != AppRoutes.subscriptionConfirm &&
            route.settings.name != AppRoutes.walletPayment,
      );
    }
    return () => Get.back();
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

    return AppLayout(
      title: widget.title,
      subtitle: widget.subtitle.isEmpty
          ? 'Choose Your Subscription'
          : widget.subtitle,
      showBack: true,
      onBack: _onBack,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        if (controller.errorMessage.value.isNotEmpty) {
          return _ErrorState(
            message: controller.errorMessage.value,
            onRetry: controller.retry,
          );
        }
        return SubscriptionPlanBody(
          controller: controller,
          subscriptionSource: widget.subscriptionSource,
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared plan body — used by both SubscriptionScreen and can be reused
// ─────────────────────────────────────────────────────────────────────────────

class SubscriptionPlanBody extends StatefulWidget {
  final SubscriptionController controller;
  final String subscriptionSource;

  const SubscriptionPlanBody({
    super.key,
    required this.controller,
    required this.subscriptionSource,
  });

  @override
  State<SubscriptionPlanBody> createState() => _SubscriptionPlanBodyState();
}

class _SubscriptionPlanBodyState extends State<SubscriptionPlanBody> {
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
        // ── Plan cards list ───────────────────────────────────
        Expanded(
          child: Obx(
            () => ListView.builder(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
              itemCount: widget.controller.plans.length,
              itemBuilder: (_, i) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
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
              ),
            ),
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
              height: 36.h,
              width: 120,
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
// Plan card
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

  String get _tierAsset {
    switch (plan.name.toLowerCase()) {
      case 'gold':
      case 'elite':
        return AppAssets.tierGold;
      case 'silver':
      case 'premium':
        return AppAssets.tierSilver;
      case 'bronze':
      case 'basic':
        return AppAssets.tierBronze;
      default:
        return AppAssets.tierGold;
    }
  }

  Color get _bgColor {
    if (!isSelected) return Colors.white;
    switch (plan.name.toLowerCase()) {
      case 'gold':
      case 'elite':
        return const Color(0xFFFFF9EE);
      case 'silver':
      case 'premium':
        return const Color(0xFFF8F8F8);
      default:
        return const Color(0xFFFFF5EE);
    }
  }

  Color get _borderColor {
    if (!isSelected) return const Color(0xFFEEEEEE);
    switch (plan.name.toLowerCase()) {
      case 'gold':
      case 'elite':
        return const Color(0xFFD4A017);
      case 'silver':
      case 'premium':
        return AppColors.grey400;
      default:
        return const Color(0xFFCD7F32);
    }
  }

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

  String get _supportIcon {
    switch (plan.name.toLowerCase()) {
      case 'gold':
      case 'elite':
        return AppAssets.subIconSupport1;
      case 'silver':
      case 'premium':
        return AppAssets.subIconSupport2;
      default:
        return AppAssets.subIconSupport;
    }
  }

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

  String get _originalPrice {
    final orig = (plan.price * 1.20).round();
    final s = orig.toString();
    if (s.length <= 3) return s;
    return '${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}';
  }

  String _fmt(double p) {
    final s = p.toStringAsFixed(0);
    if (s.length <= 3) return s;
    return '${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}';
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
              padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Top: badge + name + price + radio ────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        _tierAsset,
                        width: 52.r,
                        height: 52.r,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 2.h),
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
                                  : 'Unlimited Access',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 11.sp,
                                color: AppColors.grey500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 4.w),
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
                          SizedBox(height: 6.h),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '₹${_fmt(plan.price)}',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 20.sp,
                                  color: AppColors.black,
                                ),
                              ),
                              SizedBox(width: 5.w),
                              Text(
                                '₹$_originalPrice',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 12.sp,
                                  color: AppColors.grey400,
                                  decoration: TextDecoration.lineThrough,
                                  decorationColor: AppColors.grey400,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  // ── Support row ───────────────────────────────────
                  Row(
                    children: [
                      Image.asset(
                        _supportIcon,
                        width: 18.r,
                        height: 18.r,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(width: 6.w),
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
                  SizedBox(height: 6.h),
                  const Divider(height: 1, color: Color(0xFFF0F0F0)),
                  SizedBox(height: 6.h),
                  // ── Feature chips ─────────────────────────────────
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
// Feature chip
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
                      color: AppColors.grey400,
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
