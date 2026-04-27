import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/storage/storage_keys.dart';
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

  @override
  void onInit() {
    super.onInit();
    _fetchEligibility();
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
    // TODO: integrate payment gateway.
    // On success call SubscriptionGuardService.to.invalidateAndReload()
    await SubscriptionGuardService.to.invalidateAndReload();
    Get.snackbar(
      'Coming Soon',
      'Payment integration will be available shortly.',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }
}
