import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../core/network/endpoints/api_endpoints.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/storage/storage_keys.dart';
import '../models/combo_listing_model.dart';
import '../services/subscription_service.dart';

class ComboController extends GetxController {
  final SubscriptionService _service;

  ComboController({SubscriptionService? service})
    : _service = service ?? SubscriptionService();

  final combos = <ComboProduct>[].obs;
  final ownerPacks = <OwnerPackProduct>[].obs;
  // Start false so the guard never blocks the first onInit call
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  bool _isFetching = false; // internal re-entry guard

  @override
  void onInit() {
    super.onInit();
    fetchCombos();
  }

  Future<void> fetchCombos({bool isRefresh = false}) async {
    if (_isFetching) return; // prevent double-call, but never block first call
    _isFetching = true;
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final userId =
          await SecureStorageService.to.read(StorageKeys.userId) ?? '';
      debugPrint(
        '🎁 [ComboController] POST ${ApiEndpoints.comboListing} '
        '| body: {user_id: "$userId", listing_type: "all"}',
      );
      final data = await _service.fetchComboListing(userId: userId);
      debugPrint(
        '🎁 [ComboController] ✅ response → '
        'combos: ${data.comboCount}, ownerPacks: ${data.ownerPackCount}',
      );
      combos.assignAll(data.combos);
      ownerPacks.assignAll(data.ownerPacks);
    } catch (e, st) {
      debugPrint('🎁 [ComboController] ❌ ERROR: $e\n$st');
      errorMessage.value = 'Failed to load combos. Pull to refresh.';
    } finally {
      _isFetching = false;
      isLoading.value = false;
    }
  }

  void retry() => fetchCombos(isRefresh: true);
}
