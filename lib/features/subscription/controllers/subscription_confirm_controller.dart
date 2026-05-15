import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/storage/storage_keys.dart';
import '../../payment/controllers/payment_controller.dart';
import '../models/subscription_plan.dart';
import '../models/wallet_eligibility.dart';
import '../services/subscription_service.dart';
import '../services/subscription_guard_service.dart';

class SubscriptionConfirmController extends GetxController {
  final SubscriptionService _service;
  final SubscriptionPlan plan;
  final String source;
  final String? referralCode;

  SubscriptionConfirmController({
    required this.plan,
    required this.source,
    this.referralCode,
    SubscriptionService? service,
  }) : _service = service ?? SubscriptionService();

  final isLoading = true.obs;
  final errorMessage = ''.obs;
  final useWallet = false.obs;
  final eligibility = Rxn<WalletEligibility>();
  final isPaymentInProgress = false.obs;

  late final PaymentController _paymentController;

  @override
  void onInit() {
    super.onInit();
    _paymentController = Get.put(PaymentController(), tag: 'subscription_payment');
    _fetchEligibility();
  }

  @override
  void onClose() {
    _paymentController.reset();
    super.onClose();
  }

  Future<void> _fetchEligibility() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final userId =
          await SecureStorageService.to.read(StorageKeys.userId) ?? '';
      final result = await _service.checkWalletEligibility(
        userId: userId,
        planCode: plan.planCode,
        referralCode: referralCode,
      );
      eligibility.value = result;
    } catch (e) {
      debugPrint('⚠️ walletEligibility error: $e');
      // Non-fatal — screen still usable without wallet info
      eligibility.value = WalletEligibility(
        userId: '',
        walletBalance: 0,
        planCode: plan.planCode,
        planName: plan.name,
        subscriptionPrice: plan.price,
        maximumRedeemableAmount: 0,
        commissionAmount: 0,
        referralCommissionPercentage: 0,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void toggleWallet(bool? value) {
    final e = eligibility.value;
    if (e == null || !e.hasRedeemableAmount) return;
    useWallet.value = value ?? false;
  }

  double get displayBalance {
    final e = eligibility.value;
    if (e == null) return 0;
    return e.remainingBalance(useWallet.value);
  }

  double get finalPrice {
    final e = eligibility.value;
    if (e == null) return plan.price;
    return e.finalPrice(useWallet.value);
  }

  String get priceDisplay {
    final p = finalPrice;
    return '₹${p.toStringAsFixed(p % 1 == 0 ? 0 : 2)}';
  }

  String get originalPriceDisplay {
    final p = plan.price;
    return '₹${p.toStringAsFixed(p % 1 == 0 ? 0 : 2)}';
  }

  bool get isPriceDiscounted =>
      useWallet.value && (eligibility.value?.maximumRedeemableAmount ?? 0) > 0;

  Future<void> onProceedPayment() async {
    if (isPaymentInProgress.value) return;

    final e = eligibility.value;
    final userId = await SecureStorageService.to.read(StorageKeys.userId) ?? '';
    if (userId.isEmpty) {
      Get.snackbar('Error', 'User not found. Please login again.',
          snackPosition: SnackPosition.TOP);
      return;
    }

    isPaymentInProgress.value = true;

    // Determine wallet & PayU amounts
    final double? fromWallet =
        (useWallet.value && e != null && e.maximumRedeemableAmount > 0)
            ? e.maximumRedeemableAmount
            : null;
    final double forPayment = finalPrice;

    // Set callbacks before initiating
    _paymentController.onSuccess = (data, callback) async {
      isPaymentInProgress.value = false;
      await SubscriptionGuardService.to.invalidateAndReload();
      Get.snackbar(
        'Payment Successful',
        'Your subscription has been activated.',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
      // Navigate back to home or subscription list
      Get.until((route) => route.isFirst);
    };

    _paymentController.onFailure = (message, callback) {
      isPaymentInProgress.value = false;
      Get.snackbar(
        'Payment Failed',
        message,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
    };

    _paymentController.onCancelled = () {
      isPaymentInProgress.value = false;
      Get.snackbar(
        'Payment Cancelled',
        'You cancelled the payment.',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    };

    // If forPayment is 0 (fully covered by wallet), skip PayU
    if (forPayment <= 0) {
      // Wallet covers full amount — just report to backend
      await SubscriptionGuardService.to.invalidateAndReload();
      isPaymentInProgress.value = false;
      Get.snackbar(
        'Subscription Activated',
        'Paid entirely from wallet.',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
      Get.until((route) => route.isFirst);
      return;
    }

    // Initiate PayU payment
    await _paymentController.initiatePayment(
      userId: userId,
      planCode: plan.planCode,
      fromWallet: fromWallet,
      forPayment: forPayment,
      referralCode: referralCode,
    );
  }
}
