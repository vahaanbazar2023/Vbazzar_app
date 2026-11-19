import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Winning / losing look shared by the auction listing and watchlist / wishlist cards:
/// the whole card is tinted green (winning) or red (losing), and the status is a solid pill.
class BidStatusStyle {
  BidStatusStyle._();

  static const Color win = Color(0xFF2E7D32);
  static const Color lose = Color(0xFFC62828);
  static const Color winBackground = Color(0xFFE8F5E9);
  static const Color loseBackground = Color(0xFFFFEBEE);

  /// Card background: green tint when winning, red tint when losing, white otherwise.
  static Color cardBackground({
    required bool isWinning,
    required bool isLosing,
  }) => isWinning ? winBackground : (isLosing ? loseBackground : Colors.white);
}

/// Highlighted "You Are Winning" / "You Are Losing" label.
class BidStatusPill extends StatelessWidget {
  final bool isWinning;
  final String label;
  const BidStatusPill({
    super.key,
    required this.isWinning,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final color = isWinning ? BidStatusStyle.win : BidStatusStyle.lose;
    return Semantics(
      label: label,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.35),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isWinning
                  ? Icons.emoji_events_rounded
                  : Icons.trending_down_rounded,
              size: 12.r,
              color: Colors.white,
            ),
            SizedBox(width: 4.w),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
