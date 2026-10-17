import 'package:flutter/material.dart';

/// Smoothly collapses [child] to zero height (and back) when [hidden] changes.
///
/// Used to tuck bars away while a list is scrolling. The child keeps its state
/// and stays mounted; it is only clipped and made untouchable while hidden.
///
/// Set [overflowTop] for a child that paints above its own bounds (e.g. the
/// bottom nav's wave): the top is then left unclipped.
class CollapsibleSection extends StatelessWidget {
  final bool hidden;
  final Widget child;
  final bool overflowTop;
  final Duration duration;
  final Alignment alignment;

  const CollapsibleSection({
    super.key,
    required this.hidden,
    required this.child,
    this.overflowTop = false,
    this.duration = const Duration(milliseconds: 220),
    this.alignment = Alignment.topCenter,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: hidden ? 0 : 1),
      duration: duration,
      curve: Curves.easeOutCubic,
      child: child,
      builder: (context, factor, child) {
        return IgnorePointer(
          ignoring: factor < 0.5,
          child: ClipRect(
            clipper: overflowTop ? const _KeepTopOverflow() : null,
            child: Align(
              alignment: alignment,
              heightFactor: factor,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

/// Clips the bottom edge only, so content may paint above the section.
class _KeepTopOverflow extends CustomClipper<Rect> {
  const _KeepTopOverflow();

  @override
  Rect getClip(Size size) => Rect.fromLTRB(0, -120, size.width, size.height);

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) => false;
}
