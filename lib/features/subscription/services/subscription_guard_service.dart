import 'dart:async';
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

  // Completers waiting for an in-flight load to finish
  final _waiters = <Completer<void>>[];

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

  /// Returns ALL currently-valid subscriptions for [typeCode].
  /// Useful for summing available balances across multiple active plans.
  List<UserSubscription> allActiveSubscriptions(String typeCode) {
    return _byTypeCode[typeCode]?.where((s) => s.isCurrentlyValid).toList() ??
        [];
  }

  /// Returns the best active subscription for [typeCode].
  ///
  /// For bid-limit subscriptions (SUBT002) that have no end date, we pick
  /// the one with the highest [planAvailableBidAmount] so the revalidation
  /// always uses the subscription with the most remaining balance.
  ///
  /// For all other types we pick the one with the latest end date.
  /// Returns null if no valid subscription exists.
  UserSubscription? bestSubscription(String typeCode) {
    final subs = _byTypeCode[typeCode]
        ?.where((s) => s.isCurrentlyValid)
        .toList();
    if (subs == null || subs.isEmpty) return null;

    subs.sort((a, b) {
      // For amount-based bid-limit plans: prefer highest available balance.
      final aAmount = a.planAvailableBidAmount ?? 0;
      final bAmount = b.planAvailableBidAmount ?? 0;
      if (aAmount > 0 || bAmount > 0) {
        // At least one has an amount — sort descending by available balance.
        return bAmount.compareTo(aAmount);
      }

      // For time-based plans: prefer latest end date.
      final aEnd = UserSubscription.parseApiDate(a.endDate);
      final bEnd = UserSubscription.parseApiDate(b.endDate);
      if (aEnd == null && bEnd == null) return 0;
      if (aEnd == null) return 1;
      if (bEnd == null) return -1;
      return bEnd.compareTo(aEnd); // latest first
    });

    final best = subs.first;
    debugPrint(
      '🏆 bestSubscription($typeCode): ${best.planName} '
      '| available=₹${best.planAvailableBidAmount} '
      '| end=${best.endDate}',
    );
    return best;
  }

  /// Loads subscriptions from the API and caches them.
  /// Safe to call multiple times — concurrent callers all await the same
  /// in-flight request rather than firing duplicate requests.
  Future<void> ensureLoaded({bool forceRefresh = false}) async {
    if (_loaded && !forceRefresh) return;

    // If a load is already in progress, wait for it to complete instead of
    // returning immediately with stale data.
    if (_loading) {
      final completer = Completer<void>();
      _waiters.add(completer);
      return completer.future;
    }

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
      // Wake all callers that were waiting on this load
      for (final w in _waiters) {
        w.complete();
      }
      _waiters.clear();
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
    // Log every subscription for diagnosis
    for (final sub in subscriptions) {
      debugPrint(
        '  📋 ${sub.typeCode} | ${sub.planName} | status=${sub.status} '
        '| start="${sub.startDate}" | end="${sub.endDate}" '
        '| isCurrentlyValid=${sub.isCurrentlyValid}',
      );
    }
  }
}
