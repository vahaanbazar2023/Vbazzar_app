import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/organisms/app_header.dart';
import '../controllers/notification_controller.dart';
import '../models/notification_model.dart';

class NotificationScreen extends GetView<NotificationController> {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Fetch when screen opens — don't auto-mark all read
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchNotifications(refresh: true);
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: AppHeader(title: 'Notifications', showBack: true),
          ),
          // ── Mark all read — right-aligned, below header ──────
          Obx(() {
            if (controller.unreadCount.value == 0) {
              return const SizedBox.shrink();
            }
            return Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: controller.markAllRead,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 6.h,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.done_all_rounded,
                        size: 14.r,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Mark all read',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }
              if (controller.errorMessage.value.isNotEmpty &&
                  controller.notifications.isEmpty) {
                return Center(
                  child: Text(
                    controller.errorMessage.value,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14.sp,
                      color: AppColors.grey500,
                    ),
                  ),
                );
              }
              if (controller.notifications.isEmpty) {
                return _EmptyState();
              }

              final grouped = _groupByDay(controller.notifications);

              return NotificationListener<ScrollNotification>(
                onNotification: (n) {
                  if (n is ScrollEndNotification &&
                      n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
                    controller.fetchNotifications();
                  }
                  return false;
                },
                child: RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () => controller.fetchNotifications(refresh: true),
                  child: ListView.builder(
                    padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 32.h),
                    itemCount:
                        _countItems(grouped) +
                        (controller.isLoadingMore.value ? 1 : 0),
                    itemBuilder: (_, i) {
                      if (i == _countItems(grouped)) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                        );
                      }
                      return _buildItem(grouped, i);
                    },
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── Grouping helpers ────────────────────────────────────────────

  List<_Group> _groupByDay(List<AppNotification> items) {
    final map = <String, List<AppNotification>>{};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (final item in items) {
      final d = DateTime(
        item.createdAt.year,
        item.createdAt.month,
        item.createdAt.day,
      );
      String label;
      if (d == today) {
        label = 'Today';
      } else if (d == yesterday) {
        label = 'Yesterday';
      } else {
        label = DateFormat('dd MMM yyyy').format(d);
      }
      map.putIfAbsent(label, () => []).add(item);
    }

    // Preserve insertion order
    final groups = <_Group>[];
    for (final entry in map.entries) {
      groups.add(_Group(label: entry.key, items: entry.value));
    }
    return groups;
  }

  int _countItems(List<_Group> groups) {
    int count = 0;
    for (final g in groups) {
      count += 1 + g.items.length; // header + items
    }
    return count;
  }

  Widget _buildItem(List<_Group> groups, int flatIndex) {
    int pos = 0;
    for (final group in groups) {
      if (flatIndex == pos) {
        return _DayHeader(label: group.label);
      }
      pos++;
      for (final item in group.items) {
        if (flatIndex == pos) {
          return _NotificationTile(
            notification: item,
            onTap: () {
              controller.markOneRead(item);
              controller.handleTap(item);
            },
          );
        }
        pos++;
      }
    }
    return const SizedBox.shrink();
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _Group {
  final String label;
  final List<AppNotification> items;
  const _Group({required this.label, required this.items});
}

// ─────────────────────────────────────────────────────────────────────────────

class _DayHeader extends StatelessWidget {
  final String label;
  const _DayHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 16.h, bottom: 8.h),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 13.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.black,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;
  const _NotificationTile({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final n = notification;
    final timeStr = DateFormat('h:mm a').format(n.createdAt.toLocal());
    final diff = DateTime.now().difference(n.createdAt);
    final timeLabel = diff.inMinutes < 60
        ? '${diff.inMinutes} min ago'
        : diff.inHours < 24
        ? '${diff.inHours} hr ago'
        : timeStr;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Unread dot
            Padding(
              padding: EdgeInsets.only(top: 6.h, right: 8.w),
              child: Container(
                width: 8.r,
                height: 8.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: n.isRead ? Colors.transparent : AppColors.primary,
                ),
              ),
            ),
            // Icon
            Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                color: _iconBg(n),
                shape: BoxShape.circle,
              ),
              child: Icon(_iconData(n), size: 18.r, color: _iconColor(n)),
            ),
            SizedBox(width: 12.w),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _typeLabel(n),
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                                color: _iconColor(n),
                                letterSpacing: 0.3,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              n.title,
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        timeLabel,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 10.sp,
                          color: AppColors.grey500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    n.body,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 12.sp,
                      color: AppColors.grey600,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Icon(
              Icons.chevron_right_rounded,
              size: 18.r,
              color: AppColors.grey400,
            ),
          ],
        ),
      ),
    );
  }

  String _typeLabel(AppNotification n) {
    final onclick = n.onClickRoute ?? '';
    if (onclick.contains('auction') || onclick.contains('bid')) {
      return 'LIVE AUCTION';
    }
    if (onclick.contains('buySell') || onclick.contains('buy')) {
      return 'PRICE UPDATE';
    }
    if (onclick.contains('wallet') || onclick.contains('referral')) {
      return 'REFERRAL BONUS';
    }
    if (onclick.contains('subscription') || onclick.contains('payment')) {
      return 'PAYMENT';
    }
    return 'GENERAL';
  }

  IconData _iconData(AppNotification n) {
    final onclick = n.onClickRoute ?? '';
    if (onclick.contains('auction') || onclick.contains('bid')) {
      return Icons.gavel_rounded;
    }
    if (onclick.contains('buySell') || onclick.contains('buy')) {
      return Icons.local_offer_rounded;
    }
    if (onclick.contains('wallet')) return Icons.account_balance_wallet_rounded;
    if (onclick.contains('referral')) return Icons.people_rounded;
    if (onclick.contains('subscription') || onclick.contains('payment')) {
      return Icons.payment_rounded;
    }
    return Icons.notifications_rounded;
  }

  Color _iconColor(AppNotification n) {
    final onclick = n.onClickRoute ?? '';
    if (onclick.contains('auction') || onclick.contains('bid')) {
      return AppColors.primary;
    }
    if (onclick.contains('buySell') || onclick.contains('buy')) {
      return AppColors.ctaGradientStart;
    }
    if (onclick.contains('wallet')) return const Color(0xFF388E3C);
    if (onclick.contains('referral')) return const Color(0xFF7B1FA2);
    if (onclick.contains('subscription') || onclick.contains('payment')) {
      return const Color(0xFF0288D1);
    }
    return AppColors.grey600;
  }

  Color _iconBg(AppNotification n) {
    return _iconColor(n).withValues(alpha: 0.1);
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 56.r,
            color: AppColors.grey300,
          ),
          SizedBox(height: 16.h),
          Text(
            'No notifications yet',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            "We'll notify you about auctions, bids and more.",
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 12.sp,
              color: AppColors.grey400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
