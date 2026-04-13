import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/subscription_plan.dart';

class SubscriptionConfirmScreen extends StatelessWidget {
  const SubscriptionConfirmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final plan = args['plan'] as SubscriptionPlan?;
    final source = args['source'] as String? ?? '';

    if (plan == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF121212),
        appBar: AppBar(
          backgroundColor: const Color(0xFF121212),
          leading: GestureDetector(
            onTap: () => Get.back(),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
        body: const Center(
          child: Text(
            'No plan selected.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: const Text(
          'Confirm Subscription',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  // Plan summary card
                  _PlanSummaryCard(plan: plan),
                  const SizedBox(height: 24),
                  // What you get section
                  _WhatYouGet(plan: plan, source: source),
                  const SizedBox(height: 24),
                  // Order summary
                  _OrderSummary(plan: plan),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          // Pay button
          _PayButton(plan: plan),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Plan summary card at the top
// ─────────────────────────────────────────────────────────────────────────────
class _PlanSummaryCard extends StatelessWidget {
  final SubscriptionPlan plan;

  const _PlanSummaryCard({required this.plan});

  Color get _tierColor {
    switch (plan.name.toLowerCase()) {
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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(1.09, -1.0),
          radius: 1.12,
          colors: [
            const Color(0xFF9A0800).withOpacity(0.9),
            const Color(0xFF1F0301),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF3A0A0A), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Tier badge
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _tierColor.withOpacity(0.15),
              border: Border.all(color: _tierColor, width: 2.5),
            ),
            child: Center(
              child: Text(
                plan.name[0].toUpperCase(),
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w800,
                  fontSize: 30,
                  color: _tierColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            '${plan.name} Plan',
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w800,
              fontSize: 22,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: _tierColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              plan.metricLabel,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: _tierColor,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            plan.featDescription,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w400,
              fontSize: 13,
              color: Color(0xFFBBBBBB),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// What you get section
// ─────────────────────────────────────────────────────────────────────────────
class _WhatYouGet extends StatelessWidget {
  final SubscriptionPlan plan;
  final String source;

  const _WhatYouGet({required this.plan, required this.source});

  List<String> get _features {
    switch (source) {
      case 'SUBT001':
        return [
          'View all auction vehicle listings',
          'Participate in live auctions',
          'Access complete auction history',
          '${plan.metricLabel} of uninterrupted access',
        ];
      case 'SUBT002':
        return [
          'Place bids up to ${plan.metricLabel}',
          'Unlimited bid placements',
          'Real-time bid tracking',
          'Priority bid notifications',
        ];
      case 'SUBT003':
        return [
          'Seller name and contact details',
          'Phone number and email access',
          'Direct WhatsApp communication',
          'View seller\'s other listings',
        ];
      case 'SUBT004':
        return [
          'Complete vehicle history report',
          'Detailed technical specifications',
          'High-resolution vehicle images',
          'Professional inspection reports',
          'Ownership history and documents',
          'Market valuation insights',
        ];
      case 'SUBT005':
        return [
          'On-site professional inspection',
          'Comprehensive mechanical assessment',
          'Body condition evaluation',
          'Engine and transmission diagnostics',
          'Detailed inspection report with photos',
          'Expert recommendations and ratings',
        ];
      default:
        return [
          'Access to premium features',
          '${plan.metricLabel} validity',
          'Priority customer support',
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What\'s Included',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            children: _features
                .map(
                  (f) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFD41F1F).withOpacity(0.15),
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Color(0xFFD41F1F),
                            size: 13,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            f,
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                              color: Color(0xFFDDDDDD),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Order summary
// ─────────────────────────────────────────────────────────────────────────────
class _OrderSummary extends StatelessWidget {
  final SubscriptionPlan plan;

  const _OrderSummary({required this.plan});

  @override
  Widget build(BuildContext context) {
    final priceStr =
        '₹${plan.price.toStringAsFixed(plan.price % 1 == 0 ? 0 : 2)}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Order Summary',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              _SummaryRow(label: 'Plan', value: '${plan.name} Plan'),
              const SizedBox(height: 12),
              _SummaryRow(label: 'Validity', value: plan.metricLabel),
              const SizedBox(height: 12),
              _SummaryRow(label: 'Plan Code', value: plan.planCode),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Divider(color: Color(0xFF2E2E2E), height: 1),
              ),
              _SummaryRow(
                label: 'Total Amount',
                value: priceStr,
                highlight: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w400,
            fontSize: 13,
            color: Color(0xFF9E9E9E),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: highlight ? FontWeight.w800 : FontWeight.w600,
            fontSize: highlight ? 18 : 13,
            color: highlight ? const Color(0xFFD41F1F) : Colors.white,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pay button
// ─────────────────────────────────────────────────────────────────────────────
class _PayButton extends StatelessWidget {
  final SubscriptionPlan plan;

  const _PayButton({required this.plan});

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final priceStr =
        '₹${plan.price.toStringAsFixed(plan.price % 1 == 0 ? 0 : 2)}';

    return Container(
      color: const Color(0xFF121212),
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomPad),
      child: GestureDetector(
        onTap: () {
          // Payment integration hook — wired by calling feature
          Get.snackbar(
            'Coming Soon',
            'Payment integration will be available shortly.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: const Color(0xFF1E1E1E),
            colorText: Colors.white,
            borderRadius: 12,
            margin: const EdgeInsets.all(12),
            duration: const Duration(seconds: 3),
          );
        },
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFD41F1F), Color(0xFF9A0800)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD41F1F).withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: Text(
              'Pay $priceStr',
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
