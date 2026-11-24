import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/subscription_controller.dart';
import '../models/subscription_plan.dart';
import '../models/user_subscription.dart';
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
  final String? title;
  final String? subtitle;
  final SubscriptionPlan? prebuiltPlan;
  final Map<String, dynamic> extraArgs;

  const SubscriptionScreen({
    super.key,
    required this.subscriptionSource,
    this.title,
    this.subtitle,
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
    final controller =
        Get.isRegistered<SubscriptionController>(tag: widget.subscriptionSource)
        ? Get.find<SubscriptionController>(tag: widget.subscriptionSource)
        : Get.put(
            SubscriptionController(
              subscriptionSource: widget.subscriptionSource,
              prebuiltPlan: widget.prebuiltPlan,
              extraArgs: widget.extraArgs,
            ),
            tag: widget.subscriptionSource,
          );

    return AppLayout(
      title: widget.title ?? context.l10n.profSubSubscription,
      subtitle: (widget.subtitle == null || widget.subtitle!.isEmpty)
          ? context.l10n.profSubChooseYourSubscription
          : widget.subtitle!,
      showBack: true,
      onBack: _onBack,
      body: Obx(() {
        if (controller.isLoading.value) {
          if (widget.subscriptionSource == SubscriptionTypeCode.auction &&
              widget.prebuiltPlan == null &&
              widget.extraArgs['plans_only'] != true) {
            return const _AuctionEntrySkeleton();
          }
          return _PlanListSkeleton(
            deposit: widget.subscriptionSource ==
                SubscriptionTypeCode.auctionDeposit,
          );
        }
        if (controller.errorMessage.value.isNotEmpty) {
          return _ErrorState(
            message: controller.errorMessage.value,
            onRetry: controller.retry,
          );
        }
        // Auction Zone entry: offer the access pass (SUBT001) and the refundable deposit (SUBT008) side by side.
        if (widget.subscriptionSource == SubscriptionTypeCode.auction &&
            widget.prebuiltPlan == null &&
            widget.extraArgs['plans_only'] != true) {
          return AuctionEntryBody(accessController: controller);
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

/// Pay for a plan and continue the right way afterwards (shared by the plan list and the Auction Zone choice step).
mixin _PlanPayment<T extends StatefulWidget> on State<T> {
  Future<void> payForPlan(SubscriptionPlan? plan, String source) async {
    if (plan == null) return;
    final userId = await SecureStorageService.to.read(StorageKeys.userId) ?? '';
    if (userId.isEmpty) {
      Get.snackbar(
        context.l10n.profSubError,
        context.l10n.pleaseLoginToContinue,
      );
      return;
    }
    final pc = Get.put(PaymentController());
    pc.onSuccess = (data, callback) async {
      _navigateAfterPayment(source);
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

    if (source == 'SUBT001' || source == SubscriptionTypeCode.auctionDeposit) {
      final message = source == SubscriptionTypeCode.auctionDeposit
          ? context.l10n.auctionDepActivated
          : context.l10n.auctionAccessActivated;
      Get.until(until);
      Get.toNamed(AppRoutes.auctionType);
      CustomSnackbar.show(message: message, type: SnackbarType.success);
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
}

class _SubscriptionPlanBodyState extends State<SubscriptionPlanBody> with _PlanPayment<SubscriptionPlanBody> {
  void _onProceed() => payForPlan(widget.controller.selectedPlan, widget.subscriptionSource);

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
                  () => widget.subscriptionSource ==
                          SubscriptionTypeCode.auctionDeposit
                      ? _DepositPlanCard(
                          plan: widget.controller.plans[i],
                          isSelected:
                              widget.controller.selectedPlanIndex.value == i,
                          isFirst: i == 0,
                          onTap: () => widget.controller.selectPlan(i),
                        )
                      : _PlanCard(
                          plan: widget.controller.plans[i],
                          index: i,
                          isSelected:
                              widget.controller.selectedPlanIndex.value == i,
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
          final isDeposit =
              widget.subscriptionSource == SubscriptionTypeCode.auctionDeposit;
          return Container(
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 28.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GradientButton.filled(
                  text: isDeposit
                      ? context.l10n.auctionDepPay
                      : context.l10n.profSubPayNow,
                  onPressed: hasPlan ? _onProceed : null,
                  height: 36.h,
                  width: 120,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                ),
                if (isDeposit) ...[
                  SizedBox(height: 8.h),
                  Text(
                    context.l10n.auctionDepFootnote,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 11.sp,
                      color: AppColors.grey600,
                    ),
                  ),
                ],
              ],
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

  String _supportLabel(BuildContext context) {
    // Use label from API if available, otherwise fallback to tier-based
    if (plan.supportLabel != null && plan.supportLabel!.isNotEmpty) {
      return plan.supportLabel!;
    }
    switch (plan.name.toLowerCase()) {
      case 'gold':
      case 'elite':
        return context.l10n.profSubEliteSupport;
      case 'silver':
      case 'premium':
        return context.l10n.profSubPremiumSupport;
      default:
        return context.l10n.profSubBasicSupport;
    }
  }

  String? get _supportIconUrl {
    // Use icon URL from API if available
    return plan.iconUrlSupport;
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

  String _badgeLabel(BuildContext context) {
    switch (plan.name.toLowerCase()) {
      case 'gold':
      case 'elite':
        return context.l10n.profSubElitePlan;
      case 'silver':
      case 'premium':
        return context.l10n.profSubPremiumPlan;
      default:
        return context.l10n.profSubBasicPlan;
    }
  }

  String get _originalPrice {
    final actual = plan.actualPrice;
    final orig = actual != null && actual > plan.price
        ? actual.round()
        : (plan.price * 1.20).round();
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
                                fontWeight: FontWeight.w600,
                                fontSize: 18.sp,
                                color: AppColors.black,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              plan.featDescription.isNotEmpty
                                  ? plan.featDescription
                                  : context.l10n.profSubUnlimitedAccess,
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
                                  fontWeight: FontWeight.w600,
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
                      _supportIconUrl != null && _supportIconUrl!.isNotEmpty
                          ? Image.network(
                              _supportIconUrl!,
                              width: 18.r,
                              height: 18.r,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => Image.asset(
                                _supportIcon,
                                width: 18.r,
                                height: 18.r,
                                fit: BoxFit.contain,
                              ),
                            )
                          : Image.asset(
                              _supportIcon,
                              width: 18.r,
                              height: 18.r,
                              fit: BoxFit.contain,
                            ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          _supportLabel(context),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
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
                                  iconUrl: plan.iconUrlBenefit,
                                  label:
                                      plan.benefitLabel ??
                                      context.l10n.profSubBidLimit,
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
                                  iconUrl: plan.iconUrlShield,
                                  label: context.l10n.profSubSecureTrusted,
                                  value: context.l10n.profSubHundredSafe,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: _FeatureChip(
                                  icon: AppAssets.calendarPng,
                                  iconUrl: plan.iconUrlCalendar,
                                  label: context.l10n.profSubValidityLabel,
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
                                  iconUrl: plan.iconUrlShield,
                                  label: context.l10n.profSubSecureTrusted,
                                  value: context.l10n.profSubHundredSafe,
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
                                  iconUrl: plan.iconUrlBenefit,
                                  label: isMostPopular
                                      ? (plan.benefitLabel ??
                                            context.l10n.profSubEliteBenefits)
                                      : '',
                                  value: _badgeLabel(context),
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
                    context.l10n.profSubMostPopular,
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
  final String? iconUrl;
  final String label;
  final String value;
  const _FeatureChip({
    required this.icon,
    this.iconUrl,
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
          iconUrl != null && iconUrl!.isNotEmpty
              ? Image.network(
                  iconUrl!,
                  width: 18.r,
                  height: 18.r,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Image.asset(
                    icon,
                    width: 18.r,
                    height: 18.r,
                    fit: BoxFit.contain,
                  ),
                )
              : Image.asset(
                  icon,
                  width: 18.r,
                  height: 18.r,
                  fit: BoxFit.contain,
                ),
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
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
                    fontWeight: FontWeight.w600,
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

// ─────────────────────────────────────────────────────────────────────────────
// Auction Zone entry — access pass (SUBT001) or refundable deposit (SUBT008)
// ─────────────────────────────────────────────────────────────────────────────

/// Vahaan Bazar's own accents for this flow: the maroon of the home tiles and the gold of the plan ribbons.
const _maroon = AppColors.red;                     // #9E1F1C — home tile borders and labels
const _cream = Color(0xFFFFF9EE);                  // gold plan card fill
const _goldBorder = Color(0xFFD4A017);             // gold plan card border
const _goldText = Color(0xFFFFD27A);               // amounts on the maroon band
const _goldGradient = LinearGradient(colors: [Color(0xFFE6A817), Color(0xFFB8730A)]);
const _maroonGradient = LinearGradient(colors: [AppColors.ctaGradientStart, AppColors.ctaGradientEnd]);

/// "1,00,000" — Indian digit grouping.
String _inr(num value) {
  final s = value.round().toString();
  if (s.length <= 3) return s;
  final last = s.substring(s.length - 3);
  final rest = s.substring(0, s.length - 3);
  final b = StringBuffer();
  for (var i = 0; i < rest.length; i++) {
    if (i != 0 && (rest.length - i) % 2 == 0) b.write(',');
    b.write(rest[i]);
  }
  return '$b,$last';
}

class AuctionEntryBody extends StatefulWidget {
  final SubscriptionController accessController;
  const AuctionEntryBody({super.key, required this.accessController});

  @override
  State<AuctionEntryBody> createState() => _AuctionEntryBodyState();
}

/// Step 1 of Auction Zone: choose the access pass or the refundable deposit. Step 2 is the usual plan list
/// (same screen, same Pay flow) for the chosen type.
class _AuctionEntryBodyState extends State<AuctionEntryBody> with _PlanPayment<AuctionEntryBody> {
  static const _depositTag = SubscriptionTypeCode.auctionDeposit;
  late final SubscriptionController _deposit;
  final _accessKey = GlobalKey();
  final _depositKey = GlobalKey();

  /// The open card: SUBT001 (access pass), SUBT008 (deposit) or none.
  String? _open;

  @override
  void initState() {
    super.initState();
    _deposit = Get.isRegistered<SubscriptionController>(tag: _depositTag)
        ? Get.find<SubscriptionController>(tag: _depositTag)
        : Get.put(
            SubscriptionController(subscriptionSource: _depositTag),
            tag: _depositTag,
          );
  }

  @override
  void dispose() {
    // Deposit plans are fetched fresh each time Auction Zone is opened.
    Get.delete<SubscriptionController>(tag: _depositTag);
    super.dispose();
  }

  SubscriptionController _controllerFor(String source) =>
      source == _depositTag ? _deposit : widget.accessController;

  /// Open one card (closing the other) and bring its plans into view.
  void _toggle(String source) {
    HapticFeedback.selectionClick();
    setState(() => _open = _open == source ? null : source);
    if (_open == null) return;
    final key = source == _depositTag ? _depositKey : _accessKey;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 230), () {
        final ctx = key.currentContext;
        if (ctx != null && ctx.mounted) {
          Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 300), curve: Curves.easeOutCubic, alignment: 0.02);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_deposit.isLoading.value) {
        return const _AuctionEntrySkeleton();
      }
      // No deposit plans (none set up, or the server doesn't offer them yet): straight to the access-pass plans.
      if (_deposit.errorMessage.value.isNotEmpty || _deposit.plans.isEmpty) {
        debugPrint(
          '🎯 Auction Zone: no choice step — deposit plans (SUBT008) '
          '${_deposit.errorMessage.value.isNotEmpty ? 'failed to load: ${_deposit.errorMessage.value}' : 'list is empty (create one in the admin panel)'}; '
          'showing the access plans.',
        );
        return SubscriptionPlanBody(
          controller: widget.accessController,
          subscriptionSource: SubscriptionTypeCode.auction,
        );
      }
      final access = widget.accessController.plans;
      final deposits = _deposit.plans;
      final accessFrom = access.isEmpty
          ? null
          : access.map((p) => p.price).reduce((a, b) => a < b ? a : b);
      final longest = access.isEmpty
          ? null
          : access.reduce((a, b) =>
              (int.tryParse(a.planMetricValue) ?? 0) >= (int.tryParse(b.planMetricValue) ?? 0) ? a : b);
      final depositFrom = deposits.map((p) => p.price).reduce((a, b) => a < b ? a : b);
      final topLimit = deposits
          .map((p) => num.tryParse(p.planMetricValue) ?? 0)
          .reduce((a, b) => a > b ? a : b);
      final open = _open;
      final selected = open == null ? null : _controllerFor(open).selectedPlan;
      return Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, open == null ? 120.h : 16.h),
              children: [
                const _EntryHero(),
                SizedBox(height: 14.h),
                if (access.isNotEmpty) ...[
                  _EntryOptionCard(
                    key: _accessKey,
                    artwork: AppAssets.tierGold,
                    title: context.l10n.auctionDepTabAccess,
                    price: context.l10n.auctionDepFrom(_inr(accessFrom!)),
                    facts: [
                      (AppAssets.calendarPng, context.l10n.profSubValidityLabel, longest!.metricLabel),
                      (AppAssets.bidPng, context.l10n.auctionDepBidLimit, context.l10n.auctionDepSeparately),
                    ],
                    expanded: open == SubscriptionTypeCode.auction,
                    onTap: () => _toggle(SubscriptionTypeCode.auction),
                    plans: _PlanChoices(
                      controller: widget.accessController,
                      deposit: false,
                    ),
                  ),
                  SizedBox(height: 12.h),
                ],
                _EntryOptionCard(
                  key: _depositKey,
                  artwork: AppAssets.subIconWallet111,
                  title: context.l10n.auctionDepTabDeposit,
                  ribbon: context.l10n.auctionDepBestFor,
                  price: context.l10n.auctionDepFrom(_inr(depositFrom)),
                  limitLabel: context.l10n.auctionDepBidLimit,
                  limitValue: '₹${_inr(topLimit)}',
                  facts: [
                    (AppAssets.auction, context.l10n.auctionDepAccess, context.l10n.auctionDepUntilRefund),
                    (AppAssets.subIconShield2, context.l10n.auctionDepRefund, context.l10n.auctionDepRefundTerms),
                  ],
                  expanded: open == _depositTag,
                  onTap: () => _toggle(_depositTag),
                  plans: _PlanChoices(controller: _deposit, deposit: true),
                ),
                SizedBox(height: 10.h),
                Text(
                  context.l10n.auctionDepTerms,
                  style: TextStyle(fontFamily: 'Montserrat', fontSize: 11.sp, height: 1.4, color: AppColors.grey600),
                ),
              ],
            ),
          ),
          // Pay bar for the plan picked in the open card
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            child: open == null || selected == null
                ? const SizedBox(width: double.infinity)
                : Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 28.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, -3)),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GradientButton.filled(
                          text: open == _depositTag
                              ? '${context.l10n.auctionDepPay} · ₹${_inr(selected.price)}'
                              : '${context.l10n.profSubPayNow} · ₹${_inr(selected.price)}',
                          onPressed: () => payForPlan(selected, open),
                          height: 40.h,
                          width: 200,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        if (open == _depositTag) ...[
                          SizedBox(height: 6.h),
                          Text(
                            context.l10n.auctionDepFootnote,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontFamily: 'Montserrat', fontSize: 10.5.sp, color: AppColors.grey600),
                          ),
                        ],
                      ],
                    ),
                  ),
          ),
        ],
      );
    });
  }
}

/// The plans of one option, as compact selectable rows inside its card.
class _PlanChoices extends StatelessWidget {
  final SubscriptionController controller;
  final bool deposit;
  const _PlanChoices({required this.controller, required this.deposit});

  static String _tier(String name) {
    switch (name.toLowerCase()) {
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

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final plans = controller.plans;
      final picked = controller.selectedPlanIndex.value;
      return Column(
        children: [
          for (var i = 0; i < plans.length; i++) ...[
            if (i > 0) SizedBox(height: 8.h),
            _PlanRow(
              artwork: deposit ? AppAssets.subIconWallet111 : _tier(plans[i].name),
              name: plans[i].name,
              detail: deposit
                  ? '${context.l10n.auctionDepBidLimit} ₹${_inr(num.tryParse(plans[i].planMetricValue) ?? 0)}'
                  : plans[i].metricLabel,
              badge: !deposit && i == 0 && plans.length > 1 ? context.l10n.profSubMostPopular : null,
              price: '₹${_inr(plans[i].price)}',
              selected: picked == i,
              onTap: () {
                HapticFeedback.selectionClick();
                controller.selectPlan(i);
              },
            ),
          ],
        ],
      );
    });
  }
}

class _PlanRow extends StatelessWidget {
  final String artwork;
  final String name;
  final String detail;
  final String? badge;
  final String price;
  final bool selected;
  final VoidCallback onTap;

  const _PlanRow({
    required this.artwork,
    required this.name,
    required this.detail,
    required this.price,
    required this.selected,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: '$name, $detail, $price',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          constraints: const BoxConstraints(minHeight: 56),
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: selected ? _cream : Colors.white,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: selected ? _goldBorder : AppColors.grey200, width: selected ? 1.6 : 1),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? AppColors.primary : Colors.transparent,
                  border: selected ? null : Border.all(color: AppColors.grey300, width: 1.5),
                ),
                child: selected ? const Icon(Icons.check_rounded, color: Colors.white, size: 14) : null,
              ),
              SizedBox(width: 10.w),
              Image.asset(artwork, width: 34.r, height: 34.r, fit: BoxFit.contain),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 14.5.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.black,
                            ),
                          ),
                        ),
                        if (badge != null) ...[
                          SizedBox(width: 6.w),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(gradient: _goldGradient, borderRadius: BorderRadius.circular(6.r)),
                            child: Text(
                              badge!.toUpperCase(),
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 8.sp,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      detail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontFamily: 'Montserrat', fontSize: 11.5.sp, color: AppColors.grey600),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                price,
                style: TextStyle(fontFamily: 'Montserrat', fontSize: 16.sp, fontWeight: FontWeight.w700, color: _maroon),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The dark maroon banner at the top — the same look as the home "Live Auctions" banner.
class _EntryHero extends StatelessWidget {
  const _EntryHero();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18.r),
      child: SizedBox(
        height: 104.h,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(AppAssets.liveBidding, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox.shrink()),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xF267100B), Color(0xD9A40301), Color(0x40BB2625)],
                  stops: [0, 0.55, 1],
                ),
              ),
            ),
            Positioned(
              right: -6.w,
              bottom: -4.h,
              height: 104.h,
              child: Image.asset(AppAssets.auction, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const SizedBox.shrink()),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 10.h, 112.w, 10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 28.w,
                    height: 3.h,
                    decoration: BoxDecoration(gradient: _goldGradient, borderRadius: BorderRadius.circular(2.r)),
                  ),
                  SizedBox(height: 7.h),
                  Text(
                    context.l10n.auctionDepChooseTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 17.sp,
                      height: 1.2,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    context.l10n.auctionDepChooseSub,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 11.sp,
                      height: 1.3,
                      color: Colors.white.withValues(alpha: 0.85),
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

/// One way into auctions, drawn like the home category tiles (maroon outline, artwork, facts). Tapping it opens its plans inside.
class _EntryOptionCard extends StatelessWidget {
  final String artwork;
  final String title;
  final String price;
  final String? ribbon;
  final String? limitLabel;
  final String? limitValue;
  final List<(String, String, String)> facts; // (icon asset, label, value)
  final bool expanded;
  final Widget plans;
  final VoidCallback onTap;

  const _EntryOptionCard({
    super.key,
    required this.artwork,
    required this.title,
    required this.price,
    required this.facts,
    required this.expanded,
    required this.plans,
    required this.onTap,
    this.ribbon,
    this.limitLabel,
    this.limitValue,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(color: _maroon.withValues(alpha: expanded ? 0.16 : 0.10), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      // The outline is painted over the contents, so the open plans area can't cover it at the rounded corners.
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: _maroon, width: expanded ? 2 : 1.4),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                button: true,
                expanded: expanded,
                label: '$title. $price',
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onTap,
                    splashColor: _maroon.withValues(alpha: 0.06),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(12.w, ribbon != null ? 20.h : 12.h, 12.w, 12.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 54.r,
                                height: 54.r,
                                padding: EdgeInsets.all(7.r),
                                decoration: BoxDecoration(
                                  color: _cream,
                                  borderRadius: BorderRadius.circular(16.r),
                                  border: Border.all(color: _goldBorder.withValues(alpha: 0.35)),
                                ),
                                child: Image.asset(artwork, fit: BoxFit.contain),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 17.sp,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.black,
                                      ),
                                    ),
                                    SizedBox(height: 3.h),
                                    Text(
                                      price,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w700,
                                        color: _maroon,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 8.w),
                              // Maroon arrow: points down while the plans are open
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  gradient: _maroonGradient,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(color: AppColors.primaryDark.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 3)),
                                  ],
                                ),
                                child: AnimatedRotation(
                                  turns: expanded ? 0.25 : 0,
                                  duration: const Duration(milliseconds: 200),
                                  child: const Icon(Icons.arrow_forward_rounded, size: 20, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          if (limitValue != null) ...[
                            SizedBox(height: 10.h),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                              decoration: BoxDecoration(gradient: _maroonGradient, borderRadius: BorderRadius.circular(12.r)),
                              child: Row(
                                children: [
                                  Image.asset(AppAssets.bidPng, width: 18.r, height: 18.r, color: Colors.white),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Text(
                                      limitLabel ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 12.sp,
                                        color: Colors.white.withValues(alpha: 0.85),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    limitValue!,
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 17.sp,
                                      fontWeight: FontWeight.w800,
                                      color: _goldText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          SizedBox(height: 10.h),
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                for (var i = 0; i < facts.length; i++) ...[
                                  if (i > 0) SizedBox(width: 8.w),
                                  Expanded(child: _Fact(icon: facts[i].$1, label: facts[i].$2, value: facts[i].$3)),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Plans open right inside the card
              AnimatedSize(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                child: expanded
                    ? Container(
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 12.h),
                        decoration: BoxDecoration(
                          color: AppColors.grey50,
                          border: Border(top: BorderSide(color: _maroon.withValues(alpha: 0.15))),
                        ),
                        child: plans,
                      )
                    : const SizedBox(width: double.infinity),
              ),
            ],
          ),
          if (ribbon != null)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                decoration: BoxDecoration(
                  gradient: _goldGradient,
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12.r), topRight: Radius.circular(18.r)),
                ),
                child: Text(
                  ribbon!.toUpperCase(),
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
    );
  }
}

/// A small label / value tile with one of the app's own icon images.
class _Fact extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  const _Fact({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        children: [
          Image.asset(icon, width: 22.r, height: 22.r, fit: BoxFit.contain),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontFamily: 'Montserrat', fontSize: 10.sp, color: AppColors.grey600),
                ),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.grey900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A deposit plan, styled like the access plan cards: cream and gold when selected, gold ribbon, maroon bid-limit band.
class _DepositPlanCard extends StatelessWidget {
  final SubscriptionPlan plan;
  final bool isSelected;
  final bool isFirst;
  final VoidCallback onTap;

  const _DepositPlanCard({
    required this.plan,
    required this.isSelected,
    required this.isFirst,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bidLimit = num.tryParse(plan.planMetricValue) ?? 0;
    return Semantics(
      button: true,
      selected: isSelected,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: isSelected ? _cream : Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: isSelected ? _goldBorder : AppColors.grey200, width: isSelected ? 2 : 1),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 3)),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(12.w, isFirst ? 24.h : 12.h, 12.w, 12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset(AppAssets.subIconWallet111, width: 52.r, height: 52.r, fit: BoxFit.contain),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                plan.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 17.sp,
                                  color: AppColors.black,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                context.l10n.auctionDepDepositLabel,
                                style: TextStyle(fontFamily: 'Montserrat', fontSize: 11.sp, color: AppColors.grey500),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 160),
                              width: 24.r,
                              height: 24.r,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected ? AppColors.primary : Colors.transparent,
                                border: isSelected ? null : Border.all(color: AppColors.grey300, width: 1.5),
                              ),
                              child: isSelected ? Icon(Icons.check_rounded, color: Colors.white, size: 14.r) : null,
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              '₹${_inr(plan.price)}',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w600,
                                fontSize: 20.sp,
                                color: AppColors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                      decoration: BoxDecoration(gradient: _maroonGradient, borderRadius: BorderRadius.circular(12.r)),
                      child: Row(
                        children: [
                          Image.asset(AppAssets.bidPng, width: 18.r, height: 18.r, color: Colors.white),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              context.l10n.auctionDepBidLimit,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 12.sp,
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            '₹${_inr(bidLimit)}',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w800,
                              fontSize: 17.sp,
                              color: _goldText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10.h),
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: _Fact(
                              icon: AppAssets.auction,
                              label: context.l10n.auctionDepAccess,
                              value: context.l10n.auctionDepUntilRefund,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: _Fact(
                              icon: AppAssets.subIconShield2,
                              label: context.l10n.auctionDepRefund,
                              value: context.l10n.auctionDepRefundTerms,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (isFirst)
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      gradient: _goldGradient,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(14.r), bottomRight: Radius.circular(10.r)),
                    ),
                    child: Text(
                      context.l10n.auctionDepRefundable.toUpperCase(),
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
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Loading skeletons — mirror the plan cards and the Auction Zone choice step
// ─────────────────────────────────────────────────────────────────────────────

/// A [_Fact] tile placeholder: same outlined grey tile, shimmering content.
class _FactSkeleton extends StatelessWidget {
  const _FactSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.grey200),
      ),
      child: AppShimmer(
        child: Row(
          children: [
            SkeletonBox(width: 22.r, height: 22.r, radius: 6),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SkeletonBox(width: 50.w, height: 9.h),
                  SizedBox(height: 4.h),
                  SkeletonBox(width: 70.w, height: 11.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Plan list loading state: placeholder plan cards (or deposit cards) plus the
/// white Pay bar, laid out exactly like [SubscriptionPlanBody].
class _PlanListSkeleton extends StatelessWidget {
  final bool deposit;
  const _PlanListSkeleton({required this.deposit});

  BoxDecoration get _cardDecoration => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16.r),
    border: Border.all(
      color: deposit ? AppColors.grey200 : const Color(0xFFEEEEEE),
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.06),
        blurRadius: 10,
        offset: const Offset(0, 3),
      ),
    ],
  );

  Widget _topRow({required double nameWidth, required double subWidth}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkeletonBox(width: 52.r, height: 52.r, radius: 14),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 4.h),
              SkeletonBox(width: nameWidth, height: 17.h),
              SizedBox(height: 6.h),
              SkeletonBox(width: subWidth, height: 11.h),
            ],
          ),
        ),
        SizedBox(width: 4.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SkeletonBox.circle(size: 24.r),
            SizedBox(height: 6.h),
            SkeletonBox(width: 90.w, height: 20.h),
          ],
        ),
      ],
    );
  }

  Widget _chip() => Padding(
    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
    child: Row(
      children: [
        SkeletonBox(width: 18.r, height: 18.r, radius: 5),
        SizedBox(width: 5.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(width: 40.w, height: 9.h),
              SizedBox(height: 3.h),
              SkeletonBox(width: 50.w, height: 11.h),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _planCard() => Container(
    decoration: _cardDecoration,
    padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 10.h),
    child: AppShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _topRow(nameWidth: 90.w, subWidth: 150.w),
          SizedBox(height: 6.h),
          Row(
            children: [
              SkeletonBox(width: 18.r, height: 18.r, radius: 5),
              SizedBox(width: 6.w),
              SkeletonBox(width: 120.w, height: 12.h),
            ],
          ),
          SizedBox(height: 6.h),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          SizedBox(height: 6.h),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(child: _chip()),
                const VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: Color(0xFFF0F0F0),
                ),
                Expanded(child: _chip()),
                const VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: Color(0xFFF0F0F0),
                ),
                Expanded(child: _chip()),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _depositCard() => Container(
    decoration: _cardDecoration,
    padding: EdgeInsets.all(12.r),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppShimmer(
          child: Column(
            children: [
              _topRow(nameWidth: 110.w, subWidth: 80.w),
              SizedBox(height: 10.h),
              SkeletonBox(width: double.infinity, height: 40.h, radius: 12),
            ],
          ),
        ),
        SizedBox(height: 10.h),
        const IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _FactSkeleton()),
              SizedBox(width: 8),
              Expanded(child: _FactSkeleton()),
            ],
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SkeletonList(
            count: deposit ? 3 : 4,
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
            spacing: 12.h,
            itemBuilder: (_, __) => deposit ? _depositCard() : _planCard(),
          ),
        ),
        Container(
          width: double.infinity,
          color: Colors.white,
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 28.h),
          child: Center(
            child: AppShimmer(
              child: SkeletonBox(width: 120, height: 36.h, radius: 18),
            ),
          ),
        ),
      ],
    );
  }
}

/// Auction Zone choice step loading state: hero banner, the access-pass and
/// deposit option cards (artwork, title/price, arrow, facts) and the terms.
class _AuctionEntrySkeleton extends StatelessWidget {
  const _AuctionEntrySkeleton();

  Widget _optionCard({required bool withBand}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: _maroon.withValues(alpha: 0.35), width: 1.4),
        boxShadow: [
          BoxShadow(
            color: _maroon.withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(12.w, withBand ? 20.h : 12.h, 12.w, 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppShimmer(
            child: Column(
              children: [
                Row(
                  children: [
                    SkeletonBox(width: 54.r, height: 54.r, radius: 16),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonBox(width: 150.w, height: 17.h),
                          SizedBox(height: 6.h),
                          SkeletonBox(width: 90.w, height: 14.h),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    const SkeletonBox.circle(size: 44),
                  ],
                ),
                if (withBand) ...[
                  SizedBox(height: 10.h),
                  SkeletonBox(width: double.infinity, height: 38.h, radius: 12),
                ],
              ],
            ),
          ),
          SizedBox(height: 10.h),
          const IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _FactSkeleton()),
                SizedBox(width: 8),
                Expanded(child: _FactSkeleton()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 120.h),
      children: [
        AppShimmer(
          child: SkeletonBox(width: double.infinity, height: 104.h, radius: 18),
        ),
        SizedBox(height: 14.h),
        _optionCard(withBand: false),
        SizedBox(height: 12.h),
        _optionCard(withBand: true),
        SizedBox(height: 10.h),
        AppShimmer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(height: 11.h),
              SizedBox(height: 5.h),
              SkeletonBox(width: 220.w, height: 11.h),
            ],
          ),
        ),
      ],
    );
  }
}
