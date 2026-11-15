import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/molecules/gradient_button.dart';
import '../../../core/design_system/organisms/app_header.dart';
import '../../../core/extensions/context_extensions.dart';

const _font = 'Plus Jakarta Sans';

/// Shown in place of the withdraw screen while bank withdrawals are not live
/// (see `CashOutScreen.enabled`). It tells the user what is happening and that
/// their balance is unaffected; it makes no network calls.
class CashOutComingSoonView extends StatelessWidget {
  const CashOutComingSoonView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top),
          AppHeader(title: l10n.profWithdrawToBank),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(8.w, 12.h, 8.w, 24.h),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(20.w, 28.h, 20.w, 20.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const _WalletBadge(),
                    SizedBox(height: 18.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 5.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        l10n.aucComingSoon.toUpperCase(),
                        style: TextStyle(
                          fontFamily: _font,
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      l10n.cashOutSoonTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: _font,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.black,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      l10n.cashOutSoonBody,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: _font,
                        fontSize: 13.sp,
                        color: AppColors.grey600,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 18.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(14.r),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAFAFA),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: AppColors.grey200),
                      ),
                      child: Column(
                        children: [
                          _Point(
                            icon: Icons.verified_user_outlined,
                            text: l10n.cashOutSoonPoint1,
                          ),
                          SizedBox(height: 12.h),
                          _Point(
                            icon: Icons.card_giftcard_outlined,
                            text: l10n.cashOutSoonPoint2,
                          ),
                          SizedBox(height: 12.h),
                          _Point(
                            icon: Icons.notifications_active_outlined,
                            text: l10n.cashOutSoonPoint3,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),
                    GradientButton.filled(
                      text: l10n.cashOutSoonCta,
                      onPressed: () => Navigator.of(context).pop(),
                      width: 200.w,
                      height: 44.h,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Wallet in a soft red circle with a small clock, meaning "not yet".
class _WalletBadge extends StatelessWidget {
  const _WalletBadge();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 92.r,
      height: 92.r,
      child: Stack(
        children: [
          Container(
            width: 92.r,
            height: 92.r,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.account_balance_wallet_outlined,
              size: 42.r,
              color: AppColors.primary,
            ),
          ),
          Positioned(
            right: 2.r,
            bottom: 2.r,
            child: Container(
              width: 30.r,
              height: 30.r,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: Icon(
                Icons.schedule_rounded,
                size: 15.r,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Point extends StatelessWidget {
  const _Point({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18.r, color: AppColors.primary),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: _font,
              fontSize: 12.5.sp,
              color: AppColors.black,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
