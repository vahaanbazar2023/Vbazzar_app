import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';

/// Round share button for [AppLayout] `actions`, styled like the header's back
/// button. Ignores taps while a share is being prepared.
class HeaderShareButton extends StatefulWidget {
  final Future<void> Function() onShare;
  const HeaderShareButton({super.key, required this.onShare});

  @override
  State<HeaderShareButton> createState() => _HeaderShareButtonState();
}

class _HeaderShareButtonState extends State<HeaderShareButton> {
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
    return Semantics(
      button: true,
      label: 'Share',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _tap,
        child: Padding(
          padding: EdgeInsets.only(left: 8.w),
          child: Container(
            width: 30.r,
            height: 30.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.ctaGradientStart, AppColors.ctaGradientEnd],
              ),
              border: Border.all(color: const Color(0xFFD41F1F), width: 1),
            ),
            child: _busy
                ? Padding(
                    padding: EdgeInsets.all(8.r),
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Icon(Icons.share_rounded, color: Colors.white, size: 16.r),
          ),
        ),
      ),
    );
  }
}
