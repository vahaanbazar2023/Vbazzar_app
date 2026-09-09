import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_assets.dart';
import '../../constants/app_colors.dart';

/// Red arrow-shaped badge showing live countdown until [endAt].
/// Ticks every second. Pass empty string to show "Live".
class TimerBadge extends StatefulWidget {
  final String endAt;
  final bool mirrored;

  const TimerBadge({super.key, required this.endAt, this.mirrored = false});

  @override
  State<TimerBadge> createState() => _TimerBadgeState();
}

class _TimerBadgeState extends State<TimerBadge> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _timeLeft() {
    if (widget.endAt.isEmpty) return 'Live';
    try {
      final DateTime end;
      if (widget.endAt.contains('T')) {
        end = DateTime.parse(widget.endAt).toLocal();
      } else {
        end = _parseApiDate(widget.endAt);
      }
      final diff = end.difference(DateTime.now());
      if (diff.isNegative) return 'Ended';
      final d = diff.inDays;
      final h = diff.inHours % 24;
      final m = diff.inMinutes % 60;
      final s = diff.inSeconds % 60;
      if (d > 0) return '${d}d ${h}h ${m}m ${s}s left';
      if (h > 0) return '${h}h ${m}m ${s}s left';
      if (m > 0) return '${m}m ${s}s left';
      return '${s}s left';
    } catch (_) {
      return 'Time left';
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _ArrowBadgeClipper(mirrored: widget.mirrored),
      child: Container(
        color: AppColors.red,
        padding: EdgeInsets.only(
          left: widget.mirrored ? 10.w : 20.w,
          right: widget.mirrored ? 10.w : 10.w,
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
}

class _ArrowBadgeClipper extends CustomClipper<Path> {
  final bool mirrored;
  const _ArrowBadgeClipper({this.mirrored = false});

  @override
  Path getClip(Size size) {
    const notch = 12.0;
    if (mirrored) {
      return Path()
        ..moveTo(0, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width - notch, size.height / 2)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
    }
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
