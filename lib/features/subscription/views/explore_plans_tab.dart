import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/storage/storage_keys.dart';
import '../../../features/auction/controllers/vehicle_listing_controller.dart';
import '../../../features/auction/controllers/my_bids_wins_controller.dart';
import '../../../features/buy_and_sell/controllers/vehicle_detail_controller.dart';
import '../../../features/payment/controllers/payment_controller.dart';
import '../../../routes/app_routes.dart';
import '../controllers/subscription_controller.dart';
import '../models/subscription_plan.dart';
import '../services/subscription_guard_service.dart';
import '../../../core/design_system/molecules/custom_snackbar.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Tab 2 — Explore Plans
// ─────────────────────────────────────────────────────────────────────────────

class ExplorePlansTab extends StatefulWidget {
  final SubscriptionController ctrl;
  const ExplorePlansTab({super.key, required this.ctrl});

  @override
  State<ExplorePlansTab> createState() => _ExplorePlansTabState();
}

class _ExplorePlansTabState extends State<ExplorePlansTab> {
  final _referralCtrl = TextEditingController();

  @override
  void dispose() {
    _referralCtrl.dispose();
    super.dispose();
  }

  void _onProceed() async {
    final plan = widget.ctrl.selectedPlan;
    if (plan == null) return;
    final userId = await SecureStorageService.to.read(StorageKeys.userId) ?? '';
    if (userId.isEmpty) {
      Get.snackbar('Error', context.l10n.pleaseLoginToContinue);
      return;
    }
    final pc = Get.put(PaymentController());
    pc.onSuccess = (_, __) async {
      _navigateAfterPayment(widget.ctrl.subscriptionSource);
      SubscriptionGuardService.to.invalidateAndReload();
    };
    pc.onFailure = (msg, __) => Get.snackbar(
      context.l10n.paymentFailed,
      msg,
      backgroundColor: Colors.red.shade100,
    );
    pc.onCancelled = () => Get.snackbar(
      context.l10n.paymentCancelled,
      context.l10n.youCancelledPayment,
      backgroundColor: Colors.orange.shade100,
    );
    await pc.initiatePayment(
      userId: userId,
      planCode: plan.planCode,
      forPayment: plan.price,
      referralCode: _referralCtrl.text.trim().isNotEmpty
          ? _referralCtrl.text.trim()
          : null,
    );
  }

  void _navigateAfterPayment(String source) {
    if (!mounted) return;
    bool until(route) =>
        route.settings.name != AppRoutes.subscription &&
        route.settings.name != AppRoutes.subscriptionConfirm &&
        route.settings.name != AppRoutes.walletPayment &&
        route.settings.name != AppRoutes.mySubscriptions;

    if (source == 'SUBT001') {
      Get.until(until);
      Get.toNamed(AppRoutes.auctionType);
      CustomSnackbar.show(
        message: context.l10n.auctionAccessActivated,
        type: SnackbarType.success,
      );
    } else if (source == 'SUBT002') {
      Get.until(until);
      if (Get.isRegistered<VehicleListingController>())
        _runSUBT002(Get.find<VehicleListingController>());
      if (Get.isRegistered<MyBidsController>())
        _runMyBids(Get.find<MyBidsController>());
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
    } else {
      Get.offAllNamed(AppRoutes.mySubscriptions);
      CustomSnackbar.show(
        message: context.l10n.subscriptionActivated,
        type: SnackbarType.success,
      );
    }
  }

  Future<void> _runSUBT002(VehicleListingController c) async {
    try {
      await SubscriptionGuardService.to.invalidateAndReload();
    } catch (_) {
      return;
    }
    await c.silentRefresh();
    await c.revalidatePendingBid();
  }

  Future<void> _runMyBids(MyBidsController c) async {
    try {
      await SubscriptionGuardService.to.invalidateAndReload();
    } catch (_) {
      return;
    }
    await c.revalidatePendingBid();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (widget.ctrl.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        );
      }
      if (widget.ctrl.errorMessage.value.isNotEmpty) {
        return _ErrorWidget(
          message: widget.ctrl.errorMessage.value,
          onRetry: widget.ctrl.retry,
        );
      }
      if (widget.ctrl.plans.isEmpty) {
        return Center(
          child: Text(
            'No plans available',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 14.sp,
              color: AppColors.grey500,
            ),
          ),
        );
      }
      return ListView.builder(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
        itemCount: widget.ctrl.plans.length,
        itemBuilder: (_, i) => Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: ExploreCard(
            plan: widget.ctrl.plans[i],
            isSelected: widget.ctrl.selectedPlanIndex.value == i,
            onTap: () => widget.ctrl.selectPlan(i),
          ),
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Explore card — white card, gradient circle icon, radio dot on right
// ─────────────────────────────────────────────────────────────────────────────

class ExploreCard extends StatelessWidget {
  final SubscriptionPlan plan;
  final bool isSelected;
  final VoidCallback onTap;
  const ExploreCard({
    super.key,
    required this.plan,
    required this.isSelected,
    required this.onTap,
  });

  String get _displayName {
    switch (plan.typeCode) {
      case 'SUBT001':
        return 'Auction Access Plan';
      case 'SUBT002':
        return 'Bid Limit Plan';
      case 'SUBT003':
        return 'Owner Contact Plan';
      case 'SUBT004':
        return 'Vehicle Details Plan';
      case 'SUBT005':
        return 'Inspection Plan';
      case 'SUBT006':
        return 'Mechanic Contact Plan';
      default:
        return plan.name;
    }
  }

  String get _iconAsset {
    switch (plan.typeCode) {
      case 'SUBT001':
        return AppAssets.subIconKing;
      case 'SUBT002':
        return AppAssets.subIconBidLimit;
      case 'SUBT003':
        return AppAssets.subIconOwnerPack;
      case 'SUBT004':
        return AppAssets.subIconShield;
      case 'SUBT005':
        return AppAssets.subIconInspection;
      case 'SUBT006':
        return AppAssets.subIconMechanic;
      default:
        return AppAssets.subIconKing;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.grey400, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
            ),
          ],
        ),
        child: Row(
          children: [
            // Rounded square icon — pink bg + PNG
            Container(
              width: 52.r,
              height: 52.r,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0F0),
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.all(10.r),
              child: Image.asset(_iconAsset, fit: BoxFit.contain),
            ),
            SizedBox(width: 14.w),
            // Name + description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _displayName,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w700,
                      fontSize: 15.sp,
                      color: AppColors.black,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    plan.featDescription.isNotEmpty
                        ? plan.featDescription
                        : 'Unlock unlimited access to live auctions',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 12.sp,
                      color: AppColors.grey500,
                      height: 1.4,
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            // Radio circle — plain outline always, filled dot when selected
            Container(
              width: 24.r,
              height: 24.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.grey400, width: 1.5),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12.r,
                        height: 12.r,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Proceed bar — referral field + proceed button + wallet link
// ─────────────────────────────────────────────────────────────────────────────

class ProceedBar extends StatelessWidget {
  final SubscriptionController ctrl;
  final TextEditingController referralCtrl;
  final VoidCallback onProceed;
  const ProceedBar({
    super.key,
    required this.ctrl,
    required this.referralCtrl,
    required this.onProceed,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final hasPlan = ctrl.selectedPlan != null;
      return Container(
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 28.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasPlan) ...[
              TextField(
                controller: referralCtrl,
                textCapitalization: TextCapitalization.characters,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w500,
                  fontSize: 13.sp,
                  color: AppColors.black,
                ),
                decoration: InputDecoration(
                  hintText: context.l10n.enterHere,
                  hintStyle: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 13.sp,
                    color: AppColors.grey400,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF8F8F8),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.h),
            ],
            GestureDetector(
              onTap: hasPlan ? onProceed : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 48.h,
                decoration: BoxDecoration(
                  gradient: hasPlan
                      ? const LinearGradient(
                          colors: [
                            AppColors.ctaGradientStart,
                            AppColors.ctaGradientEnd,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        )
                      : null,
                  color: hasPlan ? null : AppColors.grey200,
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: Center(
                  child: Text(
                    context.l10n.proceedPayment,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                      color: hasPlan ? Colors.white : AppColors.grey400,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            GestureDetector(
              onTap: () {
                final plan = ctrl.selectedPlan;
                if (plan == null) return;
                final args = Get.arguments as Map<String, dynamic>? ?? {};
                Get.toNamed(
                  AppRoutes.walletPayment,
                  arguments: {
                    ...args,
                    'plan': plan,
                    'source': ctrl.subscriptionSource,
                  },
                );
              },
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 11.sp,
                    color: AppColors.grey500,
                  ),
                  children: [
                    TextSpan(text: context.l10n.orPayFromWallet),
                    TextSpan(
                      text: context.l10n.myWalletLink,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: hasPlan
                            ? AppColors.primaryLight
                            : AppColors.grey400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared error widget
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorWidget({required this.message, required this.onRetry});

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
                  'Retry',
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
