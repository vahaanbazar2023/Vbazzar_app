import 'package:get/get.dart';
import '../../../core/design_system/molecules/custom_snackbar.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/storage/storage_keys.dart';
import '../../../features/auction/controllers/vehicle_listing_controller.dart';
import '../../../features/payment/controllers/payment_controller.dart';
import '../../../routes/app_routes.dart';
import '../models/subscription_plan.dart';
import '../models/user_subscription.dart';
import '../services/subscription_guard_service.dart';

class SubscriptionEligibility {
  final double walletBalance;
  final bool hasRedeemableAmount;

  const SubscriptionEligibility({
    required this.walletBalance,
    required this.hasRedeemableAmount,
  });
}

class SubscriptionConfirmController extends GetxController {
  final SubscriptionPlan? planArg;
  final String? sourceArg;

  final isLoading = false.obs;
  final isPaymentInProgress = false.obs;
  final priceDisplay = ''.obs;
  final eligibility = Rxn<SubscriptionEligibility>();
  final isPriceDiscounted = false.obs;

  late final PaymentController _paymentCtrl;
  SubscriptionPlan? _plan;

  SubscriptionConfirmController({this.planArg, this.sourceArg});

  @override
  void onInit() {
    super.onInit();
    _paymentCtrl = Get.isRegistered<PaymentController>()
        ? Get.find<PaymentController>()
        : Get.put(PaymentController());

    final args = Get.arguments as Map<String, dynamic>? ?? {};
    _plan = planArg ?? args['plan'] as SubscriptionPlan?;

    if (_plan != null) {
      priceDisplay.value =
          '₹${_plan!.price.toStringAsFixed(_plan!.price % 1 == 0 ? 0 : 2)}';
    }

    _loadEligibility();
  }

  Future<void> _loadEligibility() async {
    isLoading.value = true;
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      eligibility.value = const SubscriptionEligibility(
        walletBalance: 0,
        hasRedeemableAmount: false,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void toggleWallet(bool value) {
    final plan = _plan;
    if (plan == null) return;

    final elig = eligibility.value;
    if (value && elig != null && elig.walletBalance > 0) {
      final discounted = (plan.price - elig.walletBalance).clamp(0, plan.price);
      isPriceDiscounted.value = discounted < plan.price;
      priceDisplay.value =
          '₹${discounted.toStringAsFixed(discounted % 1 == 0 ? 0 : 2)}';
    } else {
      isPriceDiscounted.value = false;
      priceDisplay.value =
          '₹${plan.price.toStringAsFixed(plan.price % 1 == 0 ? 0 : 2)}';
    }
  }

  String get source =>
      sourceArg ??
      (Get.arguments as Map<String, dynamic>? ?? {})['source'] as String? ??
      '';

  Future<void> onProceedPayment() async {
    final plan = _plan;
    if (plan == null) {
      CustomSnackbar.show(
        message: 'No plan selected',
        type: SnackbarType.error,
      );
      return;
    }

    final userId = await SecureStorageService.to.read(StorageKeys.userId);
    if (userId == null || userId.isEmpty) {
      CustomSnackbar.show(
        message: 'Please login to continue',
        type: SnackbarType.error,
      );
      return;
    }

    isPaymentInProgress.value = true;

    _paymentCtrl.onSuccess = (data, callback) async {
      isPaymentInProgress.value = false;
      // Navigate immediately — don't make the user wait on API calls.
      // All refreshes happen in the background after navigation.
      _navigateImmediately(source);
    };

    _paymentCtrl.onFailure = (message, callback) {
      isPaymentInProgress.value = false;
      CustomSnackbar.show(
        message: 'Payment failed: $message',
        type: SnackbarType.error,
      );
    };

    _paymentCtrl.onCancelled = () {
      isPaymentInProgress.value = false;
    };

    final success = await _paymentCtrl.initiatePayment(
      userId: userId,
      planCode: plan.planCode,
    );

    if (!success && isPaymentInProgress.value) {
      isPaymentInProgress.value = false;
    }
  }

  // ─── Immediate navigation — no waiting ──────────────────────────────────

  /// Pops the subscription stack and navigates instantly.
  /// Background refreshes are kicked off after navigation completes.
  void _navigateImmediately(String src) {
    switch (src) {
      case SubscriptionTypeCode.auction: // SUBT001
        // Pop subscription screens, push Auction Zone.
        Get.until(
          (route) =>
              route.settings.name != AppRoutes.subscription &&
              route.settings.name != AppRoutes.subscriptionConfirm &&
              route.settings.name != AppRoutes.walletPayment,
        );
        Get.toNamed(AppRoutes.auctionType);
        CustomSnackbar.show(
          message: 'Auction Access Activated! You can now browse and bid.',
          type: SnackbarType.success,
        );
        // Refresh guard cache in background — no await needed here.
        SubscriptionGuardService.to.invalidateAndReload();
        break;

      case SubscriptionTypeCode.auctionBidLimit: // SUBT002
        if (Get.isRegistered<VehicleListingController>()) {
          final ctrl = Get.find<VehicleListingController>();

          // Pop subscription screens immediately — user is back on vehicle
          // detail/listing screen right away.
          Get.until(
            (route) =>
                route.settings.name != AppRoutes.subscription &&
                route.settings.name != AppRoutes.subscriptionConfirm &&
                route.settings.name != AppRoutes.walletPayment,
          );

          // Now run the full refresh + bid revalidation pipeline in the
          // background. The vehicle detail screen's isPlacingBid spinner
          // shows while the bid is being placed.
          _runSUBT002BackgroundFlow(ctrl);
        } else {
          // Fallback: controller was disposed — just clean the stack.
          Get.until(
            (route) =>
                route.settings.name != AppRoutes.subscription &&
                route.settings.name != AppRoutes.subscriptionConfirm &&
                route.settings.name != AppRoutes.walletPayment,
          );
          CustomSnackbar.show(
            message: 'Buying limit updated!',
            type: SnackbarType.success,
          );
          SubscriptionGuardService.to.invalidateAndReload();
        }
        break;

      default:
        Get.offAllNamed(AppRoutes.mySubscriptions);
        CustomSnackbar.show(
          message: 'Subscription Activated! Your plan is now active.',
          type: SnackbarType.success,
        );
        SubscriptionGuardService.to.invalidateAndReload();
        break;
    }
  }

  // ─── SUBT002 background pipeline ────────────────────────────────────────

  /// Runs after navigation:
  ///   1. Refresh subscription guard cache
  ///   2. Silent-refresh vehicle list (updates availableBalance in the UI)
  ///   3. Revalidate the pending bid (Case A: place it / Case B: show error)
  Future<void> _runSUBT002BackgroundFlow(VehicleListingController ctrl) async {
    // 1. Refresh subscription cache
    try {
      await SubscriptionGuardService.to.invalidateAndReload();
    } catch (_) {
      CustomSnackbar.show(
        message: 'Could not refresh subscription. Please try again.',
        type: SnackbarType.error,
      );
      return;
    }

    // 2. Refresh vehicle list so availableBalance is up to date in the UI
    await ctrl.silentRefresh();

    // 3. Revalidate pending bid
    await ctrl.revalidatePendingBid();
  }
}
