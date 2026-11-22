import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/app_colors.dart';

/// Round "watch" (eye) button for the auction watchlist — same look as [WishlistButton]:
/// white circle, red outline eye when not watching, filled eye when watching.
class WatchlistButton extends StatelessWidget {
  final bool isWatchlisted;
  final VoidCallback? onTap;
  final double? size;
  final String? tooltip;

  const WatchlistButton({
    super.key,
    this.isWatchlisted = false,
    this.onTap,
    this.size,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final s = size ?? 32.w;
    final button = GestureDetector(
      onTap: onTap,
      child: Container(
        width: s,
        height: s,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          isWatchlisted ? Icons.visibility_rounded : Icons.visibility_outlined,
          color: AppColors.primary,
          size: s * 0.50,
        ),
      ),
    );
    return Semantics(
      button: true,
      selected: isWatchlisted,
      label: tooltip,
      child: tooltip == null
          ? button
          : Tooltip(message: tooltip!, child: button),
    );
  }
}
