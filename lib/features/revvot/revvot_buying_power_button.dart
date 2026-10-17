import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constants/app_colors.dart';
import '../../core/design_system/molecules/custom_snackbar.dart';
import '../../core/extensions/context_extensions.dart';
import 'revvot_service.dart';

/// "Drive It Home" finance card shown under a vehicle's price. Tapping it opens
/// the Revvot loan-eligibility flow.
class RevvotBuyingPowerButton extends StatefulWidget {
  /// Reference returned as-is by Revvot for reconciliation (vehicle id).
  final String externalRef;

  const RevvotBuyingPowerButton({super.key, required this.externalRef});

  @override
  State<RevvotBuyingPowerButton> createState() =>
      _RevvotBuyingPowerButtonState();
}

class _RevvotBuyingPowerButtonState extends State<RevvotBuyingPowerButton>
    with SingleTickerProviderStateMixin {
  bool _loading = false;
  bool _pressed = false;

  // Gentle repeating nudge on the arrow to invite a tap.
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);
  late final Animation<Offset> _nudge = Tween<Offset>(
    begin: Offset.zero,
    end: const Offset(0.25, 0),
  ).animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _onTap() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      // Mint the single-use token only now, at tap time.
      final session = await RevvotService.createSession(
        externalRef: widget.externalRef,
      );
      if (!mounted) return;
      final completedSessionId = await RevvotService.openSheet(
        context,
        session,
      );
      if (!mounted || completedSessionId == null) return; // user dismissed

      // Decide from the server, not from what the WebView reported.
      RevvotConfirmation? confirmed;
      try {
        confirmed = await RevvotService.confirmSession(completedSessionId);
      } catch (_) {}
      if (!mounted) return;
      _showResult(confirmed);
    } catch (e) {
      CustomSnackbar.show(
        message: context.l10n.revvotStartError,
        type: SnackbarType.error,
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showResult(RevvotConfirmation? c) {
    final l10n = context.l10n;
    String title;
    String body;
    switch (c?.outcome) {
      case 'approved':
        title = l10n.revvotApprovedTitle;
        final lines = <String>[
          l10n.revvotApprovedBody(c!.eligibleAmount?.toStringAsFixed(0) ?? '-'),
          if (c.interestRate != null)
            l10n.revvotInterestRate('${c.interestRate}'),
          if (c.tenureMonths != null) l10n.revvotTenure('${c.tenureMonths}'),
        ];
        body = lines.join('\n');
        break;
      case 'notEligible':
        title = l10n.revvotNotEligibleTitle;
        body = l10n.revvotNotEligibleBody;
        break;
      default:
        title = l10n.revvotUnderReviewTitle;
        body = l10n.revvotUnderReviewBody;
    }
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.revvotOk),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 120),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: _onTap,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.ctaGradientStart, AppColors.ctaGradientEnd],
            ),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.28),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 42.r,
                height: 42.r,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: _loading
                    ? Padding(
                        padding: EdgeInsets.all(11.r),
                        child: const CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        Icons.directions_car_filled_rounded,
                        size: 22.r,
                        color: Colors.white,
                      ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            _loading
                                ? context.l10n.revvotCardChecking
                                : context.l10n.revvotCardTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            context.l10n.revvotCardTag,
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 8.sp,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      context.l10n.revvotCardSubtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 10.5.sp,
                        color: Colors.white.withValues(alpha: 0.88),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              SlideTransition(
                position: _nudge,
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 22.r,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
