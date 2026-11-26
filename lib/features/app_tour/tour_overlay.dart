import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constants/app_colors.dart';
import '../../core/extensions/context_extensions.dart';

/// One highlighted spot in a guided tour.
class TourStep {
  /// The target's rect in global (screen) coordinates, or null if it isn't
  /// laid out right now. Steps that resolve to null are skipped.
  final Rect? Function() resolve;

  /// A context inside the target, used to scroll it into view first.
  final BuildContext? Function()? scrollContext;

  final String title;
  final String body;
  final bool circle;

  const TourStep({
    required this.resolve,
    required this.title,
    required this.body,
    this.scrollContext,
    this.circle = false,
  });

  /// A step on the widget behind [context()], inflated by [padding].
  factory TourStep.forContext(
    BuildContext? Function() context, {
    required String title,
    required String body,
    double padding = 8,
    bool circle = false,
  }) {
    return TourStep(
      resolve: () => rectOf(context(), padding: padding),
      scrollContext: context,
      title: title,
      body: body,
      circle: circle,
    );
  }

  /// Global rect of the render box behind [ctx], or null.
  static Rect? rectOf(BuildContext? ctx, {double padding = 0}) {
    if (ctx == null || !ctx.mounted) return null;
    final box = ctx.findRenderObject();
    if (box is! RenderBox || !box.hasSize || !box.attached) return null;
    return (box.localToGlobal(Offset.zero) & box.size).inflate(padding);
  }
}

/// Dims the screen and walks through [steps] one at a time. Completes when
/// the user finishes, skips or backs out.
Future<void> showTourOverlay(BuildContext context, List<TourStep> steps) {
  return Navigator.of(context, rootNavigator: true).push(
    PageRouteBuilder<void>(
      opaque: false,
      barrierDismissible: false,
      transitionDuration: const Duration(milliseconds: 250),
      reverseTransitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (_, __, ___) => _TourOverlay(steps: steps),
      transitionsBuilder: (_, anim, __, child) =>
          FadeTransition(opacity: anim, child: child),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────

class _TourOverlay extends StatefulWidget {
  final List<TourStep> steps;
  const _TourOverlay({required this.steps});

  @override
  State<_TourOverlay> createState() => _TourOverlayState();
}

class _TourOverlayState extends State<_TourOverlay> {
  late final List<TourStep> _steps;
  int _index = 0;
  Rect? _hole;
  Rect? _firstHole;

  @override
  void initState() {
    super.initState();
    // Skip any target that isn't on screen (e.g. a section the server hid).
    _steps = widget.steps.where((s) => s.resolve() != null).toList();
    WidgetsBinding.instance.addPostFrameCallback((_) => _goTo(0));
  }

  Future<void> _goTo(int i) async {
    if (i >= _steps.length) {
      _close();
      return;
    }
    final step = _steps[i];
    final ctx = step.scrollContext?.call();
    if (ctx != null && ctx.mounted) {
      // Bring the target into view on small phones before measuring it.
      await Scrollable.ensureVisible(
        ctx,
        alignment: 0.3,
        duration: const Duration(milliseconds: 300),
        alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
      );
    }
    if (!mounted) return;
    // Keep the cut-out on screen (a target can be taller than the viewport).
    final screen = Offset.zero & MediaQuery.of(context).size;
    final raw = step.resolve();
    final rect = raw?.intersect(screen);
    if (rect != null && (rect.width <= 0 || rect.height <= 0)) {
      _goTo(i + 1);
      return;
    }
    if (rect == null) {
      _goTo(i + 1);
      return;
    }
    setState(() {
      _index = i;
      _hole = rect;
      _firstHole ??= rect;
    });
  }

  void _next() => _goTo(_index + 1);

  void _close() {
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final hole = _hole;
    if (_steps.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _close());
      return const SizedBox.shrink();
    }
    final step = _steps[_index];
    final size = MediaQuery.of(context).size;
    final isLast = _index == _steps.length - 1;

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          // Dim layer with an animated cut-out; tapping anywhere moves on.
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _next,
              child: hole == null
                  ? CustomPaint(
                      painter: _HolePainter(hole: null, circle: false),
                    )
                  // Starts on the first target, then glides between targets.
                  : TweenAnimationBuilder<Rect?>(
                      tween: RectTween(begin: _firstHole, end: hole),
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOutCubic,
                      builder: (_, r, __) => CustomPaint(
                        painter: _HolePainter(hole: r, circle: step.circle),
                      ),
                    ),
            ),
          ),
          if (hole != null)
            _TipCard(
              hole: hole,
              screen: size,
              title: step.title,
              body: step.body,
              stepLabel: context.l10n.tourStepOf(_index + 1, _steps.length),
              nextLabel: isLast ? context.l10n.tourDone : context.l10n.tourNext,
              skipLabel: context.l10n.tourSkip,
              showSkip: !isLast,
              onNext: _next,
              onSkip: _close,
            ),
        ],
      ),
    );
  }
}

class _HolePainter extends CustomPainter {
  final Rect? hole;
  final bool circle;
  _HolePainter({required this.hole, required this.circle});

  @override
  void paint(Canvas canvas, Size size) {
    final full = Path()..addRect(Offset.zero & size);
    final dim = Paint()..color = Colors.black.withValues(alpha: 0.72);
    final h = hole;
    if (h == null) {
      canvas.drawPath(full, dim);
      return;
    }
    final cut = Path();
    if (circle) {
      cut.addOval(h);
    } else {
      cut.addRRect(RRect.fromRectAndRadius(h, const Radius.circular(14)));
    }
    canvas.drawPath(Path.combine(PathOperation.difference, full, cut), dim);
    final ring = Paint()
      ..color = AppColors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    if (circle) {
      canvas.drawOval(h, ring);
    } else {
      canvas.drawRRect(
        RRect.fromRectAndRadius(h, const Radius.circular(14)),
        ring,
      );
    }
  }

  @override
  bool shouldRepaint(_HolePainter old) =>
      old.hole != hole || old.circle != circle;
}

class _TipCard extends StatelessWidget {
  final Rect hole;
  final Size screen;
  final String title, body, stepLabel, nextLabel, skipLabel;
  final bool showSkip;
  final VoidCallback onNext, onSkip;

  const _TipCard({
    required this.hole,
    required this.screen,
    required this.title,
    required this.body,
    required this.stepLabel,
    required this.nextLabel,
    required this.skipLabel,
    required this.showSkip,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    // Card goes on whichever side of the target has more room.
    final below = (screen.height - hole.bottom) > hole.top;
    const gap = 14.0;
    final card = Container(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 10.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stepLabel,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            body,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 13.sp,
              height: 1.4,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              if (showSkip)
                TextButton(
                  onPressed: onSkip,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(48, 36),
                  ),
                  child: Text(
                    skipLabel,
                    style: TextStyle(fontFamily: 'Montserrat', fontSize: 13.sp),
                  ),
                ),
              const Spacer(),
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.ctaGradientStart,
                      AppColors.ctaGradientEnd,
                    ],
                  ),
                ),
                child: TextButton(
                  onPressed: onNext,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    minimumSize: const Size(64, 36),
                  ),
                  child: Text(
                    nextLabel,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return Positioned(
      left: 16,
      right: 16,
      top: below ? hole.bottom + gap : null,
      bottom: below ? null : screen.height - hole.top + gap,
      child: card,
    );
  }
}
