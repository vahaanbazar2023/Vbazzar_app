import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/storage/storage_keys.dart';
import '../../../routes/app_routes.dart';
import '../models/subscription_plan.dart';
import '../models/subscription_image.dart';
import '../models/user_subscription.dart';
import '../services/subscription_guard_service.dart';
import '../services/subscription_service.dart';

class SubscriptionController extends GetxController {
  final SubscriptionService _service;
  final String subscriptionSource;

  /// When set, skips the API call and uses this plan directly.
  final SubscriptionPlan? prebuiltPlan;

  /// Extra args to carry through to the confirm screen (e.g. pending_vehicle_id).
  final Map<String, dynamic> extraArgs;

  SubscriptionController({
    required this.subscriptionSource,
    this.prebuiltPlan,
    this.extraArgs = const {},
    SubscriptionService? service,
  }) : _service = service ?? SubscriptionService();

  final plans = <SubscriptionPlan>[].obs;
  final images = <SubscriptionImage>[].obs;
  final selectedPlanIndex = 0.obs;
  final isLoading = true.obs;
  final errorMessage = ''.obs;

  SubscriptionPlan? get selectedPlan =>
      plans.isEmpty ? null : plans[selectedPlanIndex.value];

  @override
  void onInit() {
    super.onInit();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    // If a plan is pre-built (e.g. from categories data), skip the API.
    if (prebuiltPlan != null) {
      plans.assignAll([prebuiltPlan!]);
      selectedPlanIndex.value = 0;
      isLoading.value = false;
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';
    try {
      final userId =
          await SecureStorageService.to.read(StorageKeys.userId) ?? '';
      final result = await _service.fetchPlans(
        userId: userId,
        subscriptionSource: subscriptionSource,
      );

      // For SUBT002 (bid limit), sort ascending by price so the lowest
      // tier (smallest limit) appears first — matches Req 5.4.
      final sortedPlans = List<SubscriptionPlan>.from(result.plans);
      if (subscriptionSource == 'SUBT002') {
        sortedPlans.sort((a, b) => a.price.compareTo(b.price));
      }

      plans.assignAll(sortedPlans);
      images.assignAll(result.images);
      selectedPlanIndex.value = 0;
    } catch (e) {
      errorMessage.value =
          'Failed to load subscription plans. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  void selectPlan(int index) {
    selectedPlanIndex.value = index;
  }

  void onContinue() {
    if (selectedPlan == null) return;
    Get.toNamed(
      AppRoutes.subscriptionConfirm,
      arguments: {
        ...extraArgs,
        'plan': selectedPlan,
        'source': subscriptionSource,
      },
    );
  }

  void retry() => _loadPlans();
}

// ─────────────────────────────────────────────────────────────────────────────
// My Subscriptions controller — lists the user's active subscriptions
// ─────────────────────────────────────────────────────────────────────────────
class MySubscriptionController extends GetxController {
  final SubscriptionService _service;

  MySubscriptionController({SubscriptionService? service})
    : _service = service ?? SubscriptionService();

  final mySubscriptions = <UserSubscription>[].obs;
  final isLoading = true.obs;
  final errorMessage = Rxn<String>();
  final auctionBidLimitOverall = 0.obs;
  final totalCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMySubscriptions();
  }

  Future<void> fetchMySubscriptions() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final userId =
          await SecureStorageService.to.read(StorageKeys.userId) ?? '';
      final result = await _service.fetchMySubscriptions(userId: userId);
      mySubscriptions.assignAll(result.subscriptions);
      auctionBidLimitOverall.value = result.auctionBidLimitOverall;
      totalCount.value = result.totalCount;
      // Keep the guard cache in sync so category access-checks stay fresh
      SubscriptionGuardService.to.invalidateAndReload();
    } catch (e, st) {
      debugPrint('❌ MySubscriptionController error: $e\n$st');
      errorMessage.value = 'Failed to load subscriptions. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  void retry() => fetchMySubscriptions();
}
