import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/storage/storage_keys.dart';
import '../models/user_subscription.dart';
import 'subscription_service.dart';

/// Singleton service that caches the current user's subscriptions and
/// exposes fast, date-aware access-checks used throughout the app.
///
/// Usage:
///   final guard = SubscriptionGuardService.to;
///   await guard.ensureLoaded();
///   if (guard.hasActiveSubscription(SubscriptionTypeCode.auction)) { … }
class SubscriptionGuardService extends GetxService {
  // ── registration ---------------------------------------------------------

  /// Returns the registered instance, or registers one on first access.
  /// Registering here (vs. only in AppBinding) makes the service resilient
  /// to binding ordering issues.
  static SubscriptionGuardService get to {
    if (!Get.isRegistered<SubscriptionGuardService>()) {
      Get.put<SubscriptionGuardService>(
        SubscriptionGuardService._(),
        permanent: true,
      );
    }
    return Get.find<SubscriptionGuardService>();
  }

  // ── dependencies ---------------------------------------------------------

  /// Service is created lazily on first API call so that NetworkService
  /// is guaranteed to be registered by then.
  SubscriptionService get _service => SubscriptionService();

  SubscriptionGuardService._();

  // ── state ----------------------------------------------------------------

  /// All subscriptions for the current user, grouped by typeCode.
  /// For duplicates we keep ALL entries; validity checks pick the best one.
  final _byTypeCode = <String, List<UserSubscription>>{};

  bool _loaded = false;
  bool _loading = false;

  // ── public API -----------------------------------------------------------

  /// Returns true if the user has at least one currently-valid subscription
  /// matching [typeCode].
  ///
  /// Handles duplicates: if the user renewed the same plan multiple times,
  /// ANY currently-valid entry counts.
  bool hasActiveSubscription(String typeCode) {
    final subs = _byTypeCode[typeCode];
    if (subs == null || subs.isEmpty) return false;
    return subs.any((s) => s.isCurrentlyValid);
  }

  /// Returns the best active subscription for [typeCode] — the one with the
  /// latest endDate, so callers can display its details.
  /// Returns null if no valid subscription exists.
  UserSubscription? bestSubscription(String typeCode) {
    final subs = _byTypeCode[typeCode]
        ?.where((s) => s.isCurrentlyValid)
        .toList();
    if (subs == null || subs.isEmpty) return null;
    subs.sort((a, b) {
      final aEnd = a.endDate != null ? DateTime.tryParse(a.endDate!) : null;
      final bEnd = b.endDate != null ? DateTime.tryParse(b.endDate!) : null;
      if (aEnd == null && bEnd == null) return 0;
      if (aEnd == null) return 1;
      if (bEnd == null) return -1;
      return bEnd.compareTo(aEnd); // latest first
    });
    return subs.first;
  }

  /// Loads subscriptions from the API and caches them.
  /// Safe to call multiple times — concurrent calls are collapsed.
  Future<void> ensureLoaded({bool forceRefresh = false}) async {
    if (_loaded && !forceRefresh) return;
    if (_loading) return;
    _loading = true;
    try {
      final userId =
          await SecureStorageService.to.read(StorageKeys.userId) ?? '';
      final result = await _service.fetchMySubscriptions(userId: userId);
      _buildIndex(result.subscriptions);
      _loaded = true;
    } catch (e, st) {
      debugPrint('⚠️ SubscriptionGuardService load error: $e\n$st');
    } finally {
      _loading = false;
    }
  }

  /// Must be called after a subscription purchase so the cache reflects the
  /// new subscription immediately.
  Future<void> invalidateAndReload() => ensureLoaded(forceRefresh: true);

  // ── internal -------------------------------------------------------------

  void _buildIndex(List<UserSubscription> subscriptions) {
    _byTypeCode.clear();
    for (final sub in subscriptions) {
      _byTypeCode.putIfAbsent(sub.typeCode, () => []).add(sub);
    }
    debugPrint(
      '🔑 SubscriptionGuardService: indexed ${subscriptions.length} '
      'subscriptions across ${_byTypeCode.length} type(s)',
    );
  }
}
