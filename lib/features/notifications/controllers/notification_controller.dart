import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/network/endpoints/api_endpoints.dart';
import '../../../core/network/network_service.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/storage/storage_keys.dart';
import '../models/notification_model.dart';

class NotificationController extends GetxController {
  final NetworkService _network;

  NotificationController({NetworkService? network})
      : _network = network ?? NetworkService.to;

  final notifications = <AppNotification>[].obs;
  final unreadCount = 0.obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;
  final errorMessage = ''.obs;

  int _currentPage = 1;
  static const int _limit = 20;

  @override
  void onInit() {
    super.onInit();
    fetchUnreadCount();
  }

  Future<String> get _userId async =>
      await SecureStorageService.to.read(StorageKeys.userId) ?? '';

  // ── Fetch unread count (for badge on home screen) ──────────────

  Future<void> fetchUnreadCount() async {
    try {
      final uid = await _userId;
      final response = await _network.post<Map<String, dynamic>>(
        ApiEndpoints.notificationHistory,
        data: {'user_id': uid, 'is_read': '0', 'page': 1, 'limit': 1},
      );
      final data = response.data?['data'] as Map<String, dynamic>?;
      unreadCount.value = (data?['total'] as num?)?.toInt() ?? 0;
    } catch (e) {
      debugPrint('⚠️ fetchUnreadCount error: $e');
    }
  }

  // ── Fetch all notifications (called on opening notification screen) ──

  Future<void> fetchNotifications({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      hasMore.value = true;
      notifications.clear();
      errorMessage.value = '';
    }
    if (!hasMore.value) return;

    if (_currentPage == 1) {
      isLoading.value = true;
    } else {
      isLoadingMore.value = true;
    }

    try {
      final uid = await _userId;
      final response = await _network.post<Map<String, dynamic>>(
        ApiEndpoints.notificationHistory,
        data: {
          'user_id': uid,
          'is_read': 'all',
          'page': _currentPage,
          'limit': _limit,
        },
      );

      final data = response.data?['data'] as Map<String, dynamic>?;
      final rawList = (data?['notifications'] as List<dynamic>?) ?? [];
      final totalPages = (data?['total_pages'] as num?)?.toInt() ?? 1;

      final items = rawList
          .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
          .toList();

      if (_currentPage == 1) {
        notifications.assignAll(items);
      } else {
        notifications.addAll(items);
      }

      hasMore.value = _currentPage < totalPages;
      if (hasMore.value) _currentPage++;
    } catch (e) {
      debugPrint('❌ fetchNotifications error: $e');
      if (_currentPage == 1) {
        errorMessage.value = 'Failed to load notifications.';
      }
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  // ── Mark all read (called when user opens notification screen) ──

  Future<void> markAllRead() async {
    if (unreadCount.value == 0) return;
    try {
      final uid = await _userId;
      await _network.post<Map<String, dynamic>>(
        ApiEndpoints.notificationMarkRead,
        data: {'user_id': uid, 'is_read': 1},
      );
      unreadCount.value = 0;
      // Update local list
      final updated = notifications
          .map((n) => n.isRead
              ? n
              : AppNotification(
                  id: n.id,
                  userId: n.userId,
                  title: n.title,
                  body: n.body,
                  data: n.data,
                  createdAt: n.createdAt,
                  isRead: true,
                ))
          .toList();
      notifications.assignAll(updated);
    } catch (e) {
      debugPrint('⚠️ markAllRead error: $e');
    }
  }

  // ── Navigate based on onclick route ──────────────────────────────

  void handleTap(AppNotification notification) {
    final route = notification.onClickRoute;
    if (route == null || route.isEmpty) return;

    // Strip "AppRoutes." prefix if present
    final path = route.startsWith('AppRoutes.')
        ? _resolveRoute(route)
        : route.startsWith('/')
            ? route
            : null;

    if (path != null) Get.toNamed(path);
  }

  String? _resolveRoute(String routeKey) {
    switch (routeKey) {
      case 'AppRoutes.buySellHome':
        return '/buy-sell-home';
      case 'AppRoutes.auctionType':
        return '/auction';
      case 'AppRoutes.auctionListings':
        return '/auction/listings';
      case 'AppRoutes.categories':
        return '/categories';
      case 'AppRoutes.spareFms':
        return '/spare-fms';
      case 'AppRoutes.myBids':
        return '/auction/my-bids';
      case 'AppRoutes.mySubscriptions':
        return '/my-subscriptions';
      case 'AppRoutes.walletDashboard':
        return '/wallet-dashboard';
      case 'AppRoutes.profile':
        return '/profile';
      default:
        return null;
    }
  }
}
