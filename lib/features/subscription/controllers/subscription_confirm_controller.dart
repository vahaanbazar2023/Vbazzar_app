import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/storage/storage_keys.dart';
import '../../../features/payment/controllers/payment_controller.dart';
import '../../../routes/app_routes.dart';
import '../models/subscription_plan.dart';

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
  bool _useWallet = false;

  SubscriptionConfirmController({this.planArg, this.sourceArg});

  @override
  void onInit() {
    super.onInit();
    _paymentCtrl = Get.find<PaymentController>();

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
    _useWallet = value;
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

  String get source => sourceArg ??
      (Get.arguments as Map<String, dynamic>? ?? {})['source'] as String? ??
      '';

  Future<void> onProceedPayment() async {
    final plan = _plan;
    if (plan == null) {
      _showSnack('No plan selected');
      return;
    }

    final userId =
        await SecureStorageService.to.read(StorageKeys.userId);
    if (userId == null || userId.isEmpty) {
      _showSnack('Please login to continue');
      return;
    }

    isPaymentInProgress.value = true;

    _paymentCtrl.onSuccess = (data, callback) async {
      isPaymentInProgress.value = false;
      _showSnack('Payment successful! Activating subscription...');
      // Wait for backend to activate subscription after payment callback
      await Future.delayed(const Duration(seconds: 3));
      Get.offAllNamed(AppRoutes.mySubscriptions);
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
}