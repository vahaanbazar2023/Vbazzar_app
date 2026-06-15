import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/storage/storage_keys.dart';
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
    // Use put with fenix so it registers a new instance if the route binding
    // didn't already register one (e.g. when instantiated programmatically).
    _paymentCtrl = Get.isRegistered<PaymentController>()
        ? Get.find<PaymentController>()
        : Get.put(PaymentController());

    // Resolve plan from constructor args or Get.arguments
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
      // Placeholder: replace with real API/service call when available
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
      _showSnack('No plan selected');
      return;
    }

    final userId = await SecureStorageService.to.read(StorageKeys.userId);
    if (userId == null || userId.isEmpty) {
      _showSnack('Please login to continue');
      return;
    }

    isPaymentInProgress.value = true;

    _paymentCtrl.onSuccess = (data, callback) async {
      isPaymentInProgress.value = false;

      // Bust the subscription guard cache so the new subscription is
      // immediately visible on the next guard check.
      await SubscriptionGuardService.to.invalidateAndReload();

      _handlePostPaymentNavigation(source);
    };

    _paymentCtrl.onFailure = (message, callback) {
      isPaymentInProgress.value = false;
      _showSnack('Payment failed: $message');
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
  /// SUBT001 — Auction Access: pop all subscription screens from the stack
  ///           and push the Auction Zone so the user lands there directly.
  ///
  /// Everything else — go to My Subscriptions to confirm the active plan.
  void _handlePostPaymentNavigation(String src) {
    switch (src) {
      case SubscriptionTypeCode.auction: // 'SUBT001'
        // Remove every subscription-related route from the stack first.
        Get.until(
          (route) =>
              route.settings.name != AppRoutes.subscription &&
              route.settings.name != AppRoutes.subscriptionConfirm &&
              route.settings.name != AppRoutes.walletPayment,
        );
        // Then push the Auction Zone on top of the now-clean stack.
        Get.toNamed(AppRoutes.auctionType);
        _showSuccessSnack(
          'Auction Access Activated! 🎉',
          'You can now browse and bid on auctions.',
        );
        break;

      default:
        Get.offAllNamed(AppRoutes.mySubscriptions);
        _showSuccessSnack(
          'Subscription Activated! 🎉',
          'Your plan is now active.',
        );
        break;
    }
  }

  void _showSnack(String message) {
    Get.snackbar(
      'Subscription',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF2E2E2E),
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
      duration: const Duration(seconds: 3),
    );
  }

  void _showSuccessSnack(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle, color: Colors.white),
      margin: const EdgeInsets.all(12),
      duration: const Duration(seconds: 3),
    );
  }
}
