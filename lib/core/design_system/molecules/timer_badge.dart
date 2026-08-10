import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_assets.dart';
import '../../constants/app_colors.dart';

/// Red arrow-shaped badge showing time remaining until [endAt].
///
/// Supports ISO-8601 strings, API date strings ("28 May 2025 - 05:30AM"),
/// and an empty string (shows "Live").
///
/// Set [mirrored] = true to flip the V-notch to the right side
/// (use when the badge is anchored to the left edge of a card).
class TimerBadge extends StatelessWidget {
  /// ISO-8601 or API-format date string. Pass empty string for "Live".
  final String endAt;

  /// When true the arrow notch is on the right; when false (default) on the left.
  final bool mirrored;

  const TimerBadge({super.key, required this.endAt, this.mirrored = false});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _ArrowBadgeClipper(mirrored: mirrored),
      child: Container(
        color: AppColors.red,
        padding: EdgeInsets.only(
          left: mirrored ? 10.w : 30.w,
          right: mirrored ? 30.w : 10.w,
          top: 6.h,
          bottom: 6.h,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              AppAssets.hourglassPng,
              width: 12.r,
              height: 12.r,
              color: AppColors.white,
            ),
            SizedBox(width: 4.w),
            Text(
              _timeLeft(),
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _timeLeft() {
    if (endAt.isEmpty) return 'Live';
    try {
      final DateTime end;
      if (endAt.contains('T')) {
        end = DateTime.parse(endAt).toLocal();
      } else {
        end = _parseApiDate(endAt);
      }
      final diff = end.difference(DateTime.now());
      if (diff.isNegative) return 'Ended';
      final d = diff.inDays;
      final h = diff.inHours % 24;
      final m = diff.inMinutes % 60;
      if (d > 0) return '${d}d ${h}h ${m}m left';
      if (h > 0) return '${h}h ${m}m left';
      return '${m}m left';
    } catch (_) {
      return 'Time left';
    }
  }

  /// Parses API date strings like "28 May 2025 - 05:30AM".
  static DateTime _parseApiDate(String s) {
    const monthMap = {
      'jan': 1,
      'feb': 2,
      'mar': 3,
      'apr': 4,
      'may': 5,
      'jun': 6,
      'jul': 7,
      'aug': 8,
      'sep': 9,
      'oct': 10,
      'nov': 11,
      'dec': 12,
    };
    final parts = s.split(' - ');
    final dateParts = parts[0].trim().split(' ');
    final day = int.parse(dateParts[0]);
    final month = monthMap[dateParts[1].toLowerCase()] ?? 1;
    final year = int.parse(dateParts[2]);
    int hour = 0, minute = 0;
    if (parts.length > 1) {
      final timePart = parts[1].trim().toUpperCase();
      final isPm = timePart.endsWith('PM');
      final isAm = timePart.endsWith('AM');
      final timeNum = timePart.replaceAll('AM', '').replaceAll('PM', '').trim();
      final hm = timeNum.split(':');
      hour = int.parse(hm[0]);
      minute = int.parse(hm[1]);
      if (isPm && hour != 12) hour += 12;
      if (isAm && hour == 12) hour = 0;
    }
    return DateTime(year, month, day, hour, minute);
  }
}

class _ArrowBadgeClipper extends CustomClipper<Path> {
  final bool mirrored;
  const _ArrowBadgeClipper({this.mirrored = false});

  @override
  Path getClip(Size size) {
    const notch = 12.0;
    if (mirrored) {
      // Notch on the RIGHT — badge sits on left edge, points right
      return Path()
        ..moveTo(0, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width - notch, size.height / 2)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
    }
    // Notch on the LEFT (default) — badge sits on right edge, points left
    return Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..lineTo(notch, size.height / 2)
      ..close();
  }

  @override
  bool shouldReclip(_ArrowBadgeClipper old) => old.mirrored != mirrored;
}
