import 'package:get/get.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/storage/storage_keys.dart';
import '../../../routes/app_routes.dart';
import '../models/subscription_plan.dart';
import '../models/subscription_image.dart';
import '../services/subscription_service.dart';

class SubscriptionController extends GetxController {
  final SubscriptionService _service;
  final String subscriptionSource;

  SubscriptionController({
    required this.subscriptionSource,
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
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final userId =
          await SecureStorageService.to.read(StorageKeys.userId) ?? '';
      final result = await _service.fetchPlans(
        userId: userId,
        subscriptionSource: subscriptionSource,
      );
      plans.assignAll(result.plans);
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
      arguments: {'plan': selectedPlan, 'source': subscriptionSource},
    );
  }

  void retry() => _loadPlans();
}
