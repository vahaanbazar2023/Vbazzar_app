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

      // Refresh the guard cache — must succeed before revalidating
      try {
        await SubscriptionGuardService.to.invalidateAndReload();
      } catch (_) {
        CustomSnackbar.show(
          message: 'Failed to refresh subscription. Please try again.',
          type: SnackbarType.error,
        );
        return; // do NOT navigate on stale data (Req 3.4)
      }

      // For SUBT002, also refresh the vehicle list so availableBalance
      // reflects the newly purchased plan before revalidatePendingBid runs.
      if (source == SubscriptionTypeCode.auctionBidLimit &&
          Get.isRegistered<VehicleListingController>()) {
        await Get.find<VehicleListingController>().silentRefresh();
      }

      _handlePostPaymentNavigation(source);
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

  /// Source-aware post-payment navigation.
  ///
  /// SUBT001 — Auction Access: pop subscription screens, push Auction Zone.
  /// SUBT002 — Bid Limit: delegate to [VehicleListingController.revalidatePendingBid].
  /// Default — go to My Subscriptions.
  Future<void> _handlePostPaymentNavigation(String src) async {
    switch (src) {
      case SubscriptionTypeCode.auction: // SUBT001
        Get.until(
          (route) =>
              route.settings.name != AppRoutes.subscription &&
              route.settings.name != AppRoutes.subscriptionConfirm &&
              route.settings.name != AppRoutes.walletPayment,
        );
        Get.toNamed(AppRoutes.auctionType);
        CustomSnackbar.show(
          message:
              'Auction Access Activated! You can now browse and bid on auctions.',
          type: SnackbarType.success,
        );
        break;

      case SubscriptionTypeCode.auctionBidLimit: // SUBT002
        // Delegate to VehicleListingController — it owns pendingBid state
        // and knows whether Case A or Case B applies.
        if (Get.isRegistered<VehicleListingController>()) {
          // await so the bid revalidation uses the fully-refreshed vehicle list
          await Get.find<VehicleListingController>().revalidatePendingBid();
        } else {
          // Fallback: VehicleListingController was disposed (unlikely)
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
        }
        break;

      default:
        Get.offAllNamed(AppRoutes.mySubscriptions);
        CustomSnackbar.show(
          message: 'Subscription Activated! Your plan is now active.',
          type: SnackbarType.success,
        );
        break;
    }
  }
}
