import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/storage/storage_keys.dart';
import '../../../features/payment/controllers/payment_controller.dart';
import '../../../routes/app_routes.dart';
import '../controllers/combo_controller.dart';
import '../models/combo_listing_model.dart';
import '../services/subscription_guard_service.dart';
import '../../../core/design_system/design_system.dart';

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
      if (ctrl.isLoading.value) {
        return _ComboShimmer();
      }
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
            // ── Combo cards ──────────────────────────────────
            if (combos.isNotEmpty) ...[
              ...combos.map(
                (c) => Padding(
                  padding: EdgeInsets.only(bottom: 14.h),
                  child: _ComboCard(combo: c),
                ),
              ),
            ],
            // ── Owner Pack section header ─────────────────────
            if (ownerPacks.isNotEmpty) ...[
              if (combos.isNotEmpty) SizedBox(height: 8.h),
              Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: Text(
                  'Owner Contact Packs',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
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
// Combo card
// ─────────────────────────────────────────────────────────────────────────────

class _ComboCard extends StatelessWidget {
  final ComboProduct combo;
  const _ComboCard({required this.combo});

  String _fmt(double p) {
    final s = p.toStringAsFixed(0);
    if (s.length <= 3) return s;
    return '${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}';
  }

  IconData _iconForType(String typeCode) {
    switch (typeCode.toUpperCase()) {
      case 'SUBT001':
        return Icons.gavel_rounded;
      case 'SUBT002':
        return Icons.bar_chart_rounded;
      case 'SUBT003':
        return Icons.handshake_rounded;
      case 'SUBT004':
        return Icons.shield_rounded;
      case 'SUBT005':
        return Icons.search_rounded;
      case 'SUBT006':
        return Icons.build_rounded;
      default:
        return Icons.workspace_premium_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.grey300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(14.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44.r,
                height: 44.r,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFFE0E0),
                ),
                child: Icon(
                  Icons.workspace_premium_rounded,
                  color: AppColors.primary,
                  size: 22.r,
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
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp,
                        color: AppColors.black,
                      ),
                    ),
                    if (combo.description != null &&
                        combo.description!.isNotEmpty) ...[
                      SizedBox(height: 2.h),
                      Text(
                        combo.description!,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 11.sp,
                          color: AppColors.grey500,
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          // ── Included plan chips ────────────────────────────────
          Row(
            children: combo.plans
                .map(
                  (plan) => Expanded(
                    child: Column(
                      children: [
                        Container(
                          width: 28.r,
                          height: 28.r,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFFFF0F0),
                          ),
                          child: Icon(
                            _iconForType(plan.typeCode),
                            size: 14.r,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          plan.displayName,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 9.sp,
                            color: AppColors.grey600,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
          SizedBox(height: 12.h),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          SizedBox(height: 10.h),
          // ── Price + savings + Pay Now ──────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '₹${_fmt(combo.sellingPrice)}',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w800,
                            fontSize: 18.sp,
                            color: AppColors.primary,
                          ),
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
                        'Save ₹${_fmt(combo.savings)}',
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
                label: 'Pay Now',
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
      Get.snackbar('Error', context.l10n.pleaseLoginToContinue);
      return;
    }
    final pc = Get.put(PaymentController());
    pc.onSuccess = (_, __) async {
      SubscriptionGuardService.to.invalidateAndReload();
      Get.offAllNamed(AppRoutes.mySubscriptions);
      CustomSnackbar.show(
        message: '$name activated successfully!',
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
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(14.r),
      child: Row(
        children: [
          Container(
            width: 44.r,
            height: 44.r,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFFFF0F0),
            ),
            child: Icon(
              Icons.handshake_rounded,
              color: AppColors.primary,
              size: 22.r,
            ),
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
                    fontWeight: FontWeight.w700,
                    fontSize: 14.sp,
                    color: AppColors.black,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '${pack.contactCount} owner contacts',
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
                  fontSize: 16.sp,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 6.h),
              _PayNowButton(
                label: 'Buy',
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
      Get.snackbar('Error', context.l10n.pleaseLoginToContinue);
      return;
    }
    final pc = Get.put(PaymentController());
    pc.onSuccess = (_, __) async {
      SubscriptionGuardService.to.invalidateAndReload();
      Get.offAllNamed(AppRoutes.mySubscriptions);
      CustomSnackbar.show(
        message: '$name purchased successfully!',
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
// Shared Pay Now button
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
      fontSize: 13.sp,
      fontWeight: FontWeight.w700,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shimmer skeleton
// ─────────────────────────────────────────────────────────────────────────────

class _ComboShimmer extends StatefulWidget {
  @override
  State<_ComboShimmer> createState() => _ComboShimmerState();
}

class _ComboShimmerState extends State<_ComboShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _anim = Tween<double>(
      begin: -1.5,
      end: 1.5,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Widget _shimmerBox({
    required double width,
    required double height,
    double radius = 8,
  }) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius.r),
          gradient: LinearGradient(
            begin: Alignment(_anim.value - 1, 0),
            end: Alignment(_anim.value + 1, 0),
            colors: const [
              Color(0xFFEEEEEE),
              Color(0xFFE0E0E0),
              Color(0xFFEEEEEE),
            ],
          ),
        ),
      ),
    );
  }

  Widget _shimmerCard() {
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _shimmerBox(width: 44.r, height: 44.r, radius: 22),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _shimmerBox(width: 140.w, height: 14.h),
                  SizedBox(height: 6.h),
                  _shimmerBox(width: 100.w, height: 11.h),
                ],
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: List.generate(
              3,
              (_) => Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Column(
                    children: [
                      _shimmerBox(width: 28.r, height: 28.r, radius: 14),
                      SizedBox(height: 4.h),
                      _shimmerBox(width: 55.w, height: 9.h),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          SizedBox(height: 10.h),
          Row(
            children: [
              _shimmerBox(width: 70.w, height: 18.h),
              SizedBox(width: 8.w),
              _shimmerBox(width: 50.w, height: 14.h),
              const Spacer(),
              _shimmerBox(width: 80.w, height: 36.h, radius: 20),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
      physics: const NeverScrollableScrollPhysics(),
      children: List.generate(3, (_) => _shimmerCard()),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state
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
            Icon(Icons.category_outlined, size: 52.r, color: AppColors.grey300),
            SizedBox(height: 16.h),
            Text(
              'No Combo Plans',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w700,
                fontSize: 16.sp,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'No combo plans are available right now.',
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
                  'Retry',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w700,
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
                    fontWeight: FontWeight.w700,
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

// needed for custom_snackbar which was replaced by design_system barrel
