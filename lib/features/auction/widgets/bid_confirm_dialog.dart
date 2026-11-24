import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/utils/amount_in_words.dart';

/// Asks the user to confirm a manual bid. Shows the amount in figures and in
/// words. Resolves to true only when CONFIRM is tapped; Cancel, back or a tap
/// outside the box resolve to false.
Future<bool> showBidConfirmDialog(int amount) async {
  final ok = await Get.dialog<bool>(
    BidConfirmDialog(amount: amount),
    barrierDismissible: true,
    barrierColor: Colors.black54,
  );
  return ok ?? false;
}

class BidConfirmDialog extends StatelessWidget {
  const BidConfirmDialog({super.key, required this.amount});

  final int amount;

  static const _gradient = LinearGradient(
    colors: [AppColors.ctaGradientStart, AppColors.ctaGradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// 250000 → "2,50,000" (Indian grouping, matching the words below it).
  static String formatIndian(int n) {
    final s = n.abs().toString();
    if (s.length <= 3) return n < 0 ? '-$s' : s;
    final last3 = s.substring(s.length - 3);
    var rest = s.substring(0, s.length - 3);
    final groups = <String>[];
    while (rest.length > 2) {
      groups.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) groups.insert(0, rest);
    return '${n < 0 ? '-' : ''}${groups.join(',')},$last3';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 28.w),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            margin: EdgeInsets.only(top: 30.r),
            padding: EdgeInsets.fromLTRB(18.w, 42.r, 18.w, 18.h),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 24,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.bidConfirmTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  l10n.bidConfirmAmountLabel,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12.sp,
                    color: AppColors.grey600,
                  ),
                ),
                SizedBox(height: 14.h),
                // Amount in figures
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  decoration: BoxDecoration(
                    color: AppColors.lightOrangeBackground,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: AppColors.lightOrange),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: ShaderMask(
                      shaderCallback: (r) => _gradient.createShader(r),
                      child: Text(
                        '₹ ${formatIndian(amount)}',
                        key: const Key('bidConfirmFigures'),
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 28.sp,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                // Amount in words
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 1.h),
                      child: Icon(
                        Icons.format_quote_rounded,
                        size: 16.r,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.bidConfirmInWords.toUpperCase(),
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.8,
                              color: AppColors.grey600,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            AmountInWords.rupees(amount),
                            key: const Key('bidConfirmWords'),
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              fontStyle: FontStyle.italic,
                              color: AppColors.black,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 18.h),
                Row(
                  children: [
                    Expanded(
                      child: _DialogButton(
                        key: const Key('bidConfirmCancel'),
                        label: l10n.cancel,
                        filled: false,
                        onTap: () => Get.back(result: false),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: _DialogButton(
                        key: const Key('bidConfirmOk'),
                        label: l10n.bidConfirmButton,
                        filled: true,
                        onTap: () => Get.back(result: true),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Gavel badge overlapping the top edge
          Container(
            width: 60.r,
            height: 60.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: _gradient,
              border: Border.all(color: AppColors.white, width: 4),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x40BB2625),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.gavel_rounded,
              color: AppColors.white,
              size: 26.r,
            ),
          ),
        ],
      ),
    );
  }
}

/// Same look as the auction card PLACE BID button: pill, Montserrat 12sp
/// w600, letter spacing 0.8, upper case.
class _DialogButton extends StatelessWidget {
  const _DialogButton({
    super.key,
    required this.label,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(19.r);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Ink(
          height: 36.h,
          decoration: BoxDecoration(
            gradient: filled ? BidConfirmDialog._gradient : null,
            color: filled ? null : AppColors.white,
            borderRadius: radius,
            border: filled
                ? null
                : Border.all(color: AppColors.primary, width: 1.2),
          ),
          child: Center(
            child: Text(
              label.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
                color: filled ? AppColors.white : AppColors.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
