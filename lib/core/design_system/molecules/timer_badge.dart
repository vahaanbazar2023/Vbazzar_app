import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../features/auction/models/my_bids_wins_models.dart';
import '../../constants/app_assets.dart';
import '../../constants/app_colors.dart';

/// Red arrow-shaped badge showing live countdown until [endAt].
/// Ticks every second. When [endAt] is empty/unparseable or the end time has
/// already passed, it shows "Auction Closed".
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

  static const _closedLabel = 'Auction Closed';

  bool get _isClosed {
    final end = parseAuctionDate(widget.endAt);
    if (end == null) return true;
    return !DateTime.now().isBefore(end);
  }

  String _timeLeft() {
    final end = parseAuctionDate(widget.endAt);
    if (end == null) return _closedLabel;
    final diff = end.difference(DateTime.now());
    if (!diff.isNegative && diff.inSeconds > 0) {
      final d = diff.inDays;
      final h = diff.inHours % 24;
      final m = diff.inMinutes % 60;
      final s = diff.inSeconds % 60;
      if (d > 0) return '${d}d ${h}h ${m}m ${s}s left';
      if (h > 0) return '${h}h ${m}m ${s}s left';
      if (m > 0) return '${m}m ${s}s left';
      return '${s}s left';
    }
    return _closedLabel;
  }

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _ArrowBadgeClipper(mirrored: widget.mirrored),
      child: Container(
        color: _isClosed ? AppColors.grey600 : AppColors.red,
        padding: EdgeInsets.only(
          left: widget.mirrored ? 10.w : 20.w,
          right: widget.mirrored ? 10.w : 10.w,
          top: 4.h,
          bottom: 4.h,
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
                fontSize: 8.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
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
