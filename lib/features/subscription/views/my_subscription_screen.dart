import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/subscription_controller.dart';
import '../models/user_subscription.dart';

class MySubscriptionScreen extends StatelessWidget {
  const MySubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MySubscriptionController());

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFF121212),
        appBar: _buildAppBar(),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFD41F1F)),
            );
          }
          if (controller.errorMessage.value != null) {
            return _ErrorState(
              message: controller.errorMessage.value!,
              onRetry: controller.retry,
            );
          }
          if (controller.mySubscriptions.isEmpty) {
            return const _EmptyState();
          }
          return _SubscriptionList(controller: controller);
        }),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF121212),
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leading: GestureDetector(
        onTap: () => Get.back(),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.white,
          size: 20,
        ),
      ),
      title: const Text(
        'My Subscriptions',
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w700,
          fontSize: 18,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Subscription list
// ─────────────────────────────────────────────────────────────────────────────
class _SubscriptionList extends StatelessWidget {
  final MySubscriptionController controller;

  const _SubscriptionList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: const Color(0xFFD41F1F),
      backgroundColor: const Color(0xFF1E1E1E),
      onRefresh: controller.fetchMySubscriptions,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          // Summary chip
          Obx(() => _SummaryChip(total: controller.totalCount.value)),
          const SizedBox(height: 16),
          Obx(
            () => Column(
              children: controller.mySubscriptions
                  .map(
                    (sub) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _SubscriptionCard(subscription: sub),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Summary chip
// ─────────────────────────────────────────────────────────────────────────────
class _SummaryChip extends StatelessWidget {
  final int total;

  const _SummaryChip({required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2E2E2E)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF00AC28),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$total Active Subscription${total == 1 ? '' : 's'}',
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Individual subscription card
// ─────────────────────────────────────────────────────────────────────────────
class _SubscriptionCard extends StatelessWidget {
  final UserSubscription subscription;

  const _SubscriptionCard({required this.subscription});

  Color get _tierColor {
    switch (subscription.planName.toLowerCase()) {
      case 'gold':
        return const Color(0xFFFFCC00);
      case 'silver':
        return const Color(0xFFB0B0B0);
      case 'bronze':
        return const Color(0xFFCD7F32);
      default:
        return const Color(0xFFD41F1F);
    }
  }

  String get _planInitial {
    final name = subscription.planName.trim();
    return name.isNotEmpty ? name[0].toUpperCase() : 'S';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2E2E2E)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              // Tier badge
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _tierColor.withOpacity(0.12),
                  border: Border.all(color: _tierColor, width: 2),
                ),
                child: Center(
                  child: Text(
                    _planInitial,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: _tierColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subscription.subscriptionType,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: Color(0xFF9E9E9E),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subscription.planName,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: _tierColor,
                      ),
                    ),
                  ],
                ),
              ),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: subscription.isActive
                      ? const Color(0xFF00AC28).withOpacity(0.12)
                      : const Color(0xFF9E9E9E).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: subscription.isActive
                        ? const Color(0xFF00AC28).withOpacity(0.4)
                        : const Color(0xFF9E9E9E).withOpacity(0.4),
                  ),
                ),
                child: Text(
                  subscription.status.toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                    color: subscription.isActive
                        ? const Color(0xFF00AC28)
                        : const Color(0xFF9E9E9E),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),

          // Divider
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0xFF2E2E2E)),
          ),

          // Date info
          if (subscription.startDate != null || subscription.endDate != null)
            Row(
              children: [
                if (subscription.startDate != null)
                  Expanded(
                    child: _DateInfo(
                      label: 'Start Date',
                      value: subscription.startDate!,
                      icon: Icons.calendar_today_outlined,
                    ),
                  ),
                if (subscription.startDate != null &&
                    subscription.endDate != null)
                  const SizedBox(width: 12),
                if (subscription.endDate != null)
                  Expanded(
                    child: _DateInfo(
                      label: 'End Date',
                      value: subscription.endDate!,
                      icon: Icons.event_outlined,
                      isEnd: true,
                    ),
                  ),
              ],
            )
          else
            Row(
              children: [
                const Icon(
                  Icons.all_inclusive,
                  color: Color(0xFF9E9E9E),
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  'No expiry date',
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: Color(0xFF9E9E9E),
                  ),
                ),
              ],
            ),

          const SizedBox(height: 10),

          // Sub code
          Row(
            children: [
              const Icon(Icons.tag, color: Color(0xFF555555), size: 13),
              const SizedBox(width: 4),
              Text(
                subscription.userSubCode,
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                  color: Color(0xFF555555),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Date info cell
// ─────────────────────────────────────────────────────────────────────────────
class _DateInfo extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isEnd;

  const _DateInfo({
    required this.label,
    required this.value,
    required this.icon,
    this.isEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF9E9E9E), size: 14),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w400,
                    fontSize: 10,
                    color: Color(0xFF9E9E9E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    color: isEnd
                        ? const Color(0xFFD41F1F)
                        : const Color(0xFF00AC28),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF2E2E2E)),
            ),
            child: const Icon(
              Icons.card_membership_outlined,
              color: Color(0xFF9E9E9E),
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Active Subscriptions',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'You have not subscribed to any plan yet.',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w400,
              fontSize: 13,
              color: Color(0xFF9E9E9E),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Error state
// ─────────────────────────────────────────────────────────────────────────────
class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFD41F1F), size: 48),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w400,
              fontSize: 13,
              color: Color(0xFF9E9E9E),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFBB2625), Color(0xFF67100B)],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
