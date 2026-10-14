import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constants/app_colors.dart';
import '../../core/design_system/molecules/custom_snackbar.dart';
import 'revvot_service.dart';

/// Compact "Check Buying Power" chip shown beside a vehicle's price.
class RevvotBuyingPowerButton extends StatefulWidget {
  /// Reference returned as-is by Revvot for reconciliation (vehicle id).
  final String externalRef;

  const RevvotBuyingPowerButton({super.key, required this.externalRef});

  @override
  State<RevvotBuyingPowerButton> createState() =>
      _RevvotBuyingPowerButtonState();
}

class _RevvotBuyingPowerButtonState extends State<RevvotBuyingPowerButton> {
  bool _loading = false;

  Future<void> _onTap() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      // Mint the single-use token only now, at tap time.
      final session = await RevvotService.createSession(
        externalRef: widget.externalRef,
      );
      if (!mounted) return;
      final finished = await RevvotService.openSheet(context, session);
      if (!mounted || !finished) return; // user dismissed

      // Display from SDK, decide from the server.
      RevvotConfirmation? confirmed;
      try {
        confirmed = await RevvotService.confirmSession(session.sessionId);
      } catch (_) {}
      if (!mounted) return;
      _showResult(confirmed);
    } catch (e) {
      CustomSnackbar.show(
        message: 'Unable to check buying power. Please try again.',
        type: SnackbarType.error,
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showResult(RevvotConfirmation? c) {
    String title;
    String body;
    switch (c?.outcome) {
      case 'approved':
        title = 'Pre-approved';
        final amt = c!.eligibleAmount?.toStringAsFixed(0) ?? '-';
        body =
            'You can afford up to ₹$amt'
            '${c.interestRate != null ? ' at ${c.interestRate}% p.a.' : ''}'
            '${c.tenureMonths != null ? ' for ${c.tenureMonths} months' : ''}.';
        break;
      case 'notEligible':
        title = 'Not eligible';
        body = 'You do not qualify for financing right now.';
        break;
      default:
        title = 'Under review';
        body = 'Your decision is pending. Please check again shortly.';
    }
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_loading)
              SizedBox(
                width: 12.r,
                height: 12.r,
                child: const CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 14.r,
                color: AppColors.primary,
              ),
            SizedBox(width: 5.w),
            Text(
              'Check Buying Power',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
