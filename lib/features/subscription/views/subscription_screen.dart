import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/subscription_controller.dart';
import '../models/subscription_plan.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/design_system/organisms/app_bottom_nav_bar.dart';
import '../../../features/main_shell/controllers/main_shell_controller.dart';
import '../../../routes/app_routes.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Subscription plan listing screen — light theme
// ─────────────────────────────────────────────────────────────────────────────
class SubscriptionScreen extends StatelessWidget {
  final String subscriptionSource;
  final String title;
  final String subtitle;

  const SubscriptionScreen({
    super.key,
    required this.subscriptionSource,
    this.title = 'Choose Subscription Plan',
    this.subtitle = 'Select the subscription plan that suits you best',
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      SubscriptionController(subscriptionSource: subscriptionSource),
      tag: subscriptionSource,
    );

    return Scaffold(
      backgroundColor: AppColors.white,
      bottomNavigationBar: Obx(() {
        final shell = Get.isRegistered<MainShellController>()
            ? Get.find<MainShellController>()
            : null;
        return AppBottomNavBar(
          currentTab: shell != null
              ? BottomNavTab.values[shell.currentIndex.value]
              : BottomNavTab.categories,
          onTabSelected: (tab) {
            shell?.changePage(tab.index);
            Get.until((route) => route.isFirst);
          },
        );
      }),
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: AppSizes.elevationNone,
        surfaceTintColor: Colors.transparent,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: const Icon(
            Icons.arrow_back,
            color: AppColors.black,
            size: AppSizes.iconMd,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: false,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryLight),
          );
        }
        if (controller.errorMessage.value.isNotEmpty) {
          return _ErrorState(
            message: controller.errorMessage.value,
            onRetry: controller.retry,
          );
        }
        return _SubscriptionBody(
          controller: controller,
          subtitle: subtitle,
          subscriptionSource: subscriptionSource,
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Body with plan list + referral + proceed button
// ─────────────────────────────────────────────────────────────────────────────
class _SubscriptionBody extends StatefulWidget {
  final SubscriptionController controller;
  final String subtitle;
  final String subscriptionSource;

  const _SubscriptionBody({
    required this.controller,
    required this.subtitle,
    required this.subscriptionSource,
  });

  @override
  State<_SubscriptionBody> createState() => _SubscriptionBodyState();
}

class _SubscriptionBodyState extends State<_SubscriptionBody> {
  final _referralController = TextEditingController();

  @override
  void dispose() {
    _referralController.dispose();
    super.dispose();
  }

  void _onProceed() {
    final plan = widget.controller.selectedPlan;
    if (plan == null) return;
    Get.toNamed(
      AppRoutes.subscriptionConfirm,
      arguments: {
        'plan': plan,
        'source': widget.subscriptionSource,
        'referral_code': _referralController.text.trim(),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Scrollable plan list + referral field
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Subtitle
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 12, 12, 0),
                  child: Text(
                    widget.subtitle,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: AppColors.grey650,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.spaceLg),

                // Plan cards
                Obx(
                  () => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: List.generate(
                      widget.controller.plans.length,
                      (i) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _PlanCard(
                          plan: widget.controller.plans[i],
                          isSelected:
                              widget.controller.selectedPlanIndex.value == i,
                          onTap: () => widget.controller.selectPlan(i),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),

                // Referral code — appears after plan is selected
                Obx(() {
                  if (widget.controller.selectedPlan == null) {
                    return const SizedBox.shrink();
                  }
                  return AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Have Any Referral Code ?',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            color: AppColors.grey900,
                          ),
                        ),
                        const SizedBox(height: AppSizes.spaceSm),
                        TextField(
                          controller: _referralController,
                          textCapitalization: TextCapitalization.characters,
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                            color: AppColors.black,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Enter here',
                            hintStyle: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w400,
                              fontSize: 13,
                              color: AppColors.grey400,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.spaceMd,
                              vertical: 14,
                            ),
                            filled: true,
                            fillColor: AppColors.white,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusMd,
                              ),
                              borderSide: const BorderSide(
                                color: AppColors.border,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusMd,
                              ),
                              borderSide: const BorderSide(
                                color: AppColors.primaryLight,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),

        // Bottom: Proceed Payment + My Wallet
        Obx(() {
          final hasPlan = widget.controller.selectedPlan != null;
          return Container(
            color: AppColors.white,
            padding: const EdgeInsets.fromLTRB(
              AppSizes.spaceMd,
              0,
              AppSizes.spaceMd,
              AppSizes.space64,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: hasPlan ? _onProceed : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: AppSizes.buttonHeightLg,
                    decoration: BoxDecoration(
                      gradient: hasPlan
                          ? const LinearGradient(
                              colors: [
                                AppColors.ctaGradientStart,
                                AppColors.ctaGradientEnd,
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            )
                          : null,
                      color: hasPlan ? null : AppColors.grey200,
                      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                    ),
                    child: Center(
                      child: Text(
                        'Proceed Payment',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: hasPlan ? AppColors.white : AppColors.grey400,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.spaceSm),
                GestureDetector(
                  onTap: () {
                    final plan = widget.controller.selectedPlan;
                    if (plan == null) return;
                    Get.toNamed(
                      AppRoutes.walletPayment,
                      arguments: {
                        'plan': plan,
                        'source': widget.subscriptionSource,
                      },
                    );
                  },
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w400,
                        fontSize: 11,
                        color: AppColors.grey650,
                      ),
                      children: [
                        const TextSpan(text: 'or pay from '),
                        TextSpan(
                          text: '"My wallet"',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: hasPlan
                                ? AppColors.primaryLight
                                : AppColors.grey650,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Plan card — light theme
// ─────────────────────────────────────────────────────────────────────────────
class _PlanCard extends StatelessWidget {
  final SubscriptionPlan plan;
  final bool isSelected;
  final VoidCallback onTap;

  const _PlanCard({
    required this.plan,
    required this.isSelected,
    required this.onTap,
  });

  String? get _tierAsset {
    switch (plan.name.toLowerCase()) {
      case 'gold':
        return AppAssets.tierGold;
      case 'silver':
        return AppAssets.tierSilver;
      case 'bronze':
        return AppAssets.tierBronze;
      default:
        return null;
    }
  }

  Color get _tierColor {
    switch (plan.name.toLowerCase()) {
      case 'gold':
        return const Color(0xFFD4A017);
      case 'silver':
        return AppColors.grey500;
      case 'bronze':
        return const Color(0xFFCD7F32);
      default:
        return AppColors.primaryLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        height: 85,
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF0F0) : AppColors.grey50,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryLight
                : const Color(0xFFEADDDD),
          ),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.spaceMd,
          vertical: 14,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Tier icon
            SizedBox(
              width: 38,
              height: 38,
              child: _tierAsset != null
                  ? Image.asset(_tierAsset!, fit: BoxFit.contain)
                  : Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _tierColor.withOpacity(0.12),
                        border: Border.all(color: _tierColor, width: 1.8),
                      ),
                      child: Center(
                        child: Text(
                          plan.name[0].toUpperCase(),
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: _tierColor,
                          ),
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: 12),

            // Name + validity
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    plan.name,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Validity : ${plan.metricLabel}',
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: AppColors.black,
                    ),
                  ),
                ],
              ),
            ),

            // Price
            Row(
              children: [
                Icon(Icons.currency_rupee, color: AppColors.grey800, size: 18),
                Text(
                  plan.price.toStringAsFixed(plan.price % 1 == 0 ? 0 : 2),
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: AppColors.grey800,
                  ),
                ),
              ],
            ),
          ],
        ),
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
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spaceXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                color: AppColors.primaryLight,
                size: AppSizes.spaceXl,
              ),
            ),
            const SizedBox(height: AppSizes.spaceLg),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 13,
                color: AppColors.grey500,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppSizes.spaceLg),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.spaceXl,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: const Text(
                  'Retry',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}