import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';

/// Round share button that matches [WishlistButton] (white circle, soft shadow)
/// so the two can be stacked on a card. Ignores taps while a share is being
/// prepared and shows a small spinner meanwhile.
class ShareCircleButton extends StatefulWidget {
  final Future<void> Function() onShare;

  /// Circle diameter. Defaults to 32.
  final double? size;

  const ShareCircleButton({super.key, required this.onShare, this.size});

  @override
  State<ShareCircleButton> createState() => _ShareCircleButtonState();
}

class _ShareCircleButtonState extends State<ShareCircleButton> {
  bool _busy = false;

  Future<void> _tap() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await widget.onShare();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size ?? 32.w;
    return Semantics(
      button: true,
      label: 'Share vehicle',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _tap,
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
          child: _busy
              ? Padding(
                  padding: EdgeInsets.all(s * 0.28),
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                )
              : Icon(Icons.share_rounded, color: AppColors.primary, size: s * 0.50),
        ),
      ),
    );
  }
}
