import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/storage/storage_keys.dart';
import '../../../features/payment/controllers/payment_controller.dart';
import '../../../routes/app_routes.dart';
import '../controllers/combo_controller.dart';
import '../models/combo_listing_model.dart';
import '../services/subscription_guard_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Combo icon + chip image helper — pick PNG based on combo index & plan type
// ─────────────────────────────────────────────────────────────────────────────

/// Returns the header image for a combo card by its 0-based list index.
String _comboHeaderImage(int index) {
  switch (index) {
    case 0:
      return AppAssets.subIconAllAccess; // All Access — red medal
    case 1:
      return AppAssets.subIconEssential; // Essential  — grey star
    default:
      return AppAssets.subIconCombo; // Value      — orange stack
  }
}

/// Returns the chip image for an included plan by typeCode and combo index.
String _chipImage(String typeCode, int comboIndex) {
  switch (typeCode.toUpperCase()) {
    case 'SUBT001': // Auction Access
      return comboIndex == 0
          ? AppAssets.subIconKing
          : comboIndex == 1
          ? AppAssets.subIconKing1
          : AppAssets.subIconKing2;
    case 'SUBT004': // Vehicle Details
      return comboIndex == 0
          ? AppAssets.subIconShield2
          : comboIndex == 1
          ? AppAssets.subIconShield2
          : AppAssets.subIconShield2;
    default: // Support / any other
      return comboIndex == 0
          ? AppAssets.subIconSupport
          : comboIndex == 1
          ? AppAssets.subIconSupport
          : AppAssets.subIconSupport;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 3 — Combo Plans (real API data)
// ─────────────────────────────────────────────────────────────────────────────

class ComboPlansTab extends StatelessWidget {
  const ComboPlansTab({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.isRegistered<ComboController>()
        ? Get.find<ComboController>()
        : Get.put(ComboController());

    return Obx(() {
      if (ctrl.isLoading.value) return _ComboShimmer();
      if (ctrl.errorMessage.value.isNotEmpty) {
        return _ErrorState(
          message: ctrl.errorMessage.value,
          onRetry: ctrl.retry,
        );
      }
      final combos = ctrl.combos;
      final ownerPacks = ctrl.ownerPacks;
      if (combos.isEmpty && ownerPacks.isEmpty) {
        return _EmptyState(onRetry: ctrl.retry);
      }
      return RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => ctrl.fetchCombos(isRefresh: true),
        child: ListView(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
          children: [
            ...combos.asMap().entries.map(
              (e) => Padding(
                padding: EdgeInsets.only(bottom: 14.h),
                child: _ComboCard(combo: e.value, index: e.key),
              ),
            ),
            if (ownerPacks.isNotEmpty) ...[
              if (combos.isNotEmpty) SizedBox(height: 4.h),
              Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: Text(
                  context.l10n.profSubOwnerContactPacks,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              ...ownerPacks.map(
                (p) => Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: _OwnerPackCard(pack: p),
                ),
              ),
            ],
          ],
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Combo card — matches screenshot exactly
// ─────────────────────────────────────────────────────────────────────────────

class _ComboCard extends StatelessWidget {
  final ComboProduct combo;
  final int index;
  const _ComboCard({required this.combo, required this.index});

  String _fmt(double p) {
    final s = p.toStringAsFixed(0);
    if (s.length <= 3) return s;
    return '${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.grey300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: image + name + description ────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52.r,
                height: 52.r,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F0),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                padding: EdgeInsets.all(8.r),
                child: Image.asset(
                  _comboHeaderImage(index),
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      combo.name,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                        fontSize: 15.sp,
                        color: AppColors.black,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      combo.description?.isNotEmpty == true
                          ? combo.description!
                          : context.l10n.profSubGetBestValue,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 11.sp,
                        color: AppColors.grey500,
                        height: 1.4,
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          // ── 3 chips: API plans (2) + 1 static support chip ────
          IntrinsicHeight(
            child: Row(
              children: [
                // Chip 1
                Expanded(
                  child: _PlanChip(
                    image: combo.plans.isNotEmpty
                        ? _chipImage(combo.plans[0].typeCode, index)
                        : AppAssets.subIconKing,
                    label: combo.plans.isNotEmpty
                        ? combo.plans[0].displayName
                        : context.l10n.profSubAuctionAccessPlan,
                  ),
                ),
                // Divider
                VerticalDivider(
                  width: 1,
                  thickness: 2,
                  color: AppColors.grey200,
                ),
                // Chip 2
                Expanded(
                  child: _PlanChip(
                    image: combo.plans.length > 1
                        ? _chipImage(combo.plans[1].typeCode, index)
                        : AppAssets.subIconShield,
                    label: combo.plans.length > 1
                        ? combo.plans[1].displayName
                        : context.l10n.profSubVehicleDetailsPlan,
                  ),
                ),
                // Divider
                VerticalDivider(
                  width: 1,
                  thickness: 2,
                  color: AppColors.grey200,
                ),
                // Chip 3 — static support
                Expanded(
                  child: _PlanChip(
                    image: AppAssets.subIconSupport,
                    label: index == 0
                        ? context.l10n.profSubPrioritySupport
                        : index == 1
                        ? context.l10n.profSubStandardSupport
                        : context.l10n.profSubEmailSupport,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 14.h),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          SizedBox(height: 12.h),
          // ── Price + Pay Now ────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '₹${_fmt(combo.sellingPrice)}',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w800,
                            fontSize: 20.sp,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          width: 1,
                          height: 16.h,
                          color: AppColors.grey300,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          '₹${_fmt(combo.actualPrice)}',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 13.sp,
                            color: AppColors.grey400,
                            decoration: TextDecoration.lineThrough,
                            decorationColor: AppColors.grey400,
                          ),
                        ),
                      ],
                    ),
                    if (combo.savings > 0) ...[
                      SizedBox(height: 2.h),
                      Text(
                        context.l10n.profSubSave(_fmt(combo.savings)),
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              _PayNowButton(
                label: context.l10n.profSubPayNow,
                onTap: () => _onPayNow(
                  context,
                  combo.comboCode,
                  combo.sellingPrice,
                  combo.name,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _onPayNow(
    BuildContext context,
    String comboCode,
    double price,
    String name,
  ) async {
    final userId = await SecureStorageService.to.read(StorageKeys.userId) ?? '';
    if (userId.isEmpty) {
      Get.snackbar(
        context.l10n.profSubError,
        context.l10n.pleaseLoginToContinue,
      );
      return;
    }
    final pc = Get.put(PaymentController());
    pc.onSuccess = (_, __) async {
      SubscriptionGuardService.to.invalidateAndReload();
      Get.offAllNamed(AppRoutes.mySubscriptions);
      CustomSnackbar.show(
        message: context.l10n.profSubActivatedSuccessfully(name),
        type: SnackbarType.success,
      );
    };
    pc.onFailure = (msg, __) => Get.snackbar(
      context.l10n.paymentFailed,
      msg,
      backgroundColor: Colors.red.shade100,
    );
    pc.onCancelled = () => Get.snackbar(
      context.l10n.paymentCancelled,
      context.l10n.youCancelledPayment,
      backgroundColor: Colors.orange.shade100,
    );
    await pc.initiatePayment(
      userId: userId,
      planCode: comboCode,
      forPayment: price,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Owner Pack card
// ─────────────────────────────────────────────────────────────────────────────

class _OwnerPackCard extends StatelessWidget {
  final OwnerPackProduct pack;
  const _OwnerPackCard({required this.pack});

  String _fmt(double p) {
    final s = p.toStringAsFixed(0);
    if (s.length <= 3) return s;
    return '${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(16.r),
      child: Row(
        children: [
          Container(
            width: 52.r,
            height: 52.r,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0F0),
              borderRadius: BorderRadius.circular(14.r),
            ),
            padding: EdgeInsets.all(10.r),
            child: Image.asset(AppAssets.subIconGift, fit: BoxFit.contain),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pack.name,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                    color: AppColors.black,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  context.l10n.profSubOwnerContactsCount(pack.contactCount),
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 11.sp,
                    color: AppColors.grey500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${_fmt(pack.price)}',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w800,
                  fontSize: 18.sp,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 8.h),
              _PayNowButton(
                label: context.l10n.profSubBuy,
                onTap: () =>
                    _onBuy(context, pack.planCode, pack.price, pack.name),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _onBuy(
    BuildContext context,
    String planCode,
    double price,
    String name,
  ) async {
    final userId = await SecureStorageService.to.read(StorageKeys.userId) ?? '';
    if (userId.isEmpty) {
      Get.snackbar(
        context.l10n.profSubError,
        context.l10n.pleaseLoginToContinue,
      );
      return;
    }
    final pc = Get.put(PaymentController());
    pc.onSuccess = (_, __) async {
      SubscriptionGuardService.to.invalidateAndReload();
      Get.offAllNamed(AppRoutes.mySubscriptions);
      CustomSnackbar.show(
        message: context.l10n.profSubPurchasedSuccessfully(name),
        type: SnackbarType.success,
      );
    };
    pc.onFailure = (msg, __) => Get.snackbar(
      context.l10n.paymentFailed,
      msg,
      backgroundColor: Colors.red.shade100,
    );
    pc.onCancelled = () => Get.snackbar(
      context.l10n.paymentCancelled,
      context.l10n.youCancelledPayment,
      backgroundColor: Colors.orange.shade100,
    );
    await pc.initiatePayment(
      userId: userId,
      planCode: planCode,
      forPayment: price,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Plan chip — bordered box: PNG icon top + label bottom
// ─────────────────────────────────────────────────────────────────────────────

class _PlanChip extends StatelessWidget {
  final String image;
  final String label;
  const _PlanChip({required this.image, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(image, width: 30.r, height: 30.r, fit: BoxFit.contain),
          SizedBox(height: 6.h),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 10.sp,
              color: AppColors.grey600,
              height: 1.3,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pay Now button — GradientButton.filled
// ─────────────────────────────────────────────────────────────────────────────

class _PayNowButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _PayNowButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GradientButton.filled(
      text: label,
      onPressed: onTap,
      width: 100.w,
      height: 28.h,
      fontSize: 12.sp,
      fontWeight: FontWeight.w600,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shimmer skeleton
// ─────────────────────────────────────────────────────────────────────────────

/// Mirrors the loaded screen: two combo cards (header, three plan chips with
/// dividers, price row with the Pay Now button) and the owner-contact-pack
/// section, in the same cards, padding and spacing.
class _ComboShimmer extends StatelessWidget {
  BoxDecoration _cardDecoration(Color border) => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16.r),
    border: Border.all(color: border),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.06),
        blurRadius: 12,
        offset: const Offset(0, 3),
      ),
    ],
  );

  Widget _chip() => Padding(
    padding: EdgeInsets.symmetric(vertical: 8.h),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SkeletonBox(width: 30.r, height: 30.r, radius: 8),
        SizedBox(height: 6.h),
        SkeletonBox(width: 60.w, height: 10.h),
        SizedBox(height: 3.h),
        SkeletonBox(width: 40.w, height: 10.h),
      ],
    ),
  );

  Widget _comboCard() => Container(
    decoration: _cardDecoration(AppColors.grey300),
    padding: EdgeInsets.all(16.r),
    child: AppShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(width: 52.r, height: 52.r, radius: 14),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: 150.w, height: 15.h),
                    SizedBox(height: 6.h),
                    SkeletonBox(height: 11.h),
                    SizedBox(height: 4.h),
                    SkeletonBox(width: 120.w, height: 11.h),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(child: _chip()),
                VerticalDivider(width: 1, thickness: 2, color: AppColors.grey200),
                Expanded(child: _chip()),
                VerticalDivider(width: 1, thickness: 2, color: AppColors.grey200),
                Expanded(child: _chip()),
              ],
            ),
          ),
          SizedBox(height: 14.h),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          SizedBox(height: 12.h),
          Row(
            children: [
              SkeletonBox(width: 72.w, height: 20.h),
              SizedBox(width: 8.w),
              SkeletonBox(width: 1, height: 16.h, radius: 0),
              SizedBox(width: 8.w),
              SkeletonBox(width: 48.w, height: 13.h),
              const Spacer(),
              SkeletonBox(width: 100.w, height: 28.h, radius: 20),
            ],
          ),
        ],
      ),
    ),
  );

  Widget _packCard() => Container(
    decoration: _cardDecoration(const Color(0xFFEEEEEE)),
    padding: EdgeInsets.all(16.r),
    child: AppShimmer(
      child: Row(
        children: [
          SkeletonBox(width: 52.r, height: 52.r, radius: 14),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 130.w, height: 14.h),
                SizedBox(height: 5.h),
                SkeletonBox(width: 90.w, height: 11.h),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SkeletonBox(width: 64.w, height: 18.h),
              SizedBox(height: 8.h),
              SkeletonBox(width: 100.w, height: 28.h, radius: 20),
            ],
          ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => ListView(
    padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
    physics: const NeverScrollableScrollPhysics(),
    children: [
      _comboCard(),
      SizedBox(height: 14.h),
      _comboCard(),
      SizedBox(height: 18.h),
      Align(
        alignment: Alignment.centerLeft,
        child: AppShimmer(child: SkeletonBox(width: 160.w, height: 14.h)),
      ),
      SizedBox(height: 10.h),
      _packCard(),
    ],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty + Error states
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onRetry;
  const _EmptyState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(AppAssets.subIconCombo, width: 64.r, height: 64.r),
            SizedBox(height: 16.h),
            Text(
              context.l10n.profSubNoComboPlans,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
                fontSize: 16.sp,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              context.l10n.profSubNoComboPlansAvailable,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 13.sp,
                color: AppColors.grey500,
              ),
            ),
            SizedBox(height: 20.h),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  context.l10n.retry,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                    fontSize: 13.sp,
                    color: Colors.white,
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

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: 48.r, color: AppColors.grey300),
            SizedBox(height: 16.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 13.sp,
                color: AppColors.grey500,
                height: 1.5,
              ),
            ),
            SizedBox(height: 16.h),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  context.l10n.retry,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                    fontSize: 13.sp,
                    color: Colors.white,
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
