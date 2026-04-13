import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/main_shell_controller.dart';

// ── Figma-exact constants ────────────────────────────────────────────────────
// Bar (Rectangle 372): height 90, radius 6 top / 24 bottom
// Dome oval (Ellipse 205 small): 72 × 67.75, center 5.545px ABOVE bar top
// Arc ellipse (Ellipse 205 large): 84.5 × 29.5, center 13.55px ABOVE bar top
// Circle (Frame 47): 48px diameter, protrudes 18px above bar top
const double _kOverlap = 40; // widget height reserved ABOVE bar top
const double _kBarH = 90; // bar height
const double _kCircle = 48; // floating red circle diameter
const double _kCircleAbove = 18; // px the circle protrudes above bar top
const double _kDomeW = 72;
const double _kDomeH = 67.75;
const double _kArcW = 84.5;
const double _kArcH = 29.5;
const int _kCount = 5;
// ────────────────────────────────────────────────────────────────────────────

class BottomNavBar extends GetView<MainShellController> {
  const BottomNavBar({super.key});

  static const _iconPaths = [
    'assets/images/png/home.png',
    'assets/images/png/subscriptions.png',
    'assets/images/png/category.png',
    'assets/images/png/rewards.png',
    'assets/images/png/settings.png',
  ];

  static const _labels = [
    'Home',
    'Subscriptions',
    'Categories',
    'Rewards',
    'Settings',
  ];

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    return Obx(
      () => _BottomNavContent(
        selected: controller.currentIndex.value,
        iconPaths: _iconPaths,
        labels: _labels,
        bottomPadding: bottomPadding,
        onTap: controller.changePage,
      ),
    );
  }
}

// ── Stateful inner widget (handles slide animation) ──────────────────────────
class _BottomNavContent extends StatefulWidget {
  final int selected;
  final List<String> iconPaths;
  final List<String> labels;
  final double bottomPadding;
  final ValueChanged<int> onTap;

  const _BottomNavContent({
    required this.selected,
    required this.iconPaths,
    required this.labels,
    required this.bottomPadding,
    required this.onTap,
  });

  @override
  State<_BottomNavContent> createState() => _BottomNavContentState();
}

class _BottomNavContentState extends State<_BottomNavContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _curve;
  double _from = 0;
  double _to = 0;

  double get _pos => _from + (_to - _from) * _curve.value;

  @override
  void initState() {
    super.initState();
    _from = _to = widget.selected.toDouble();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _curve = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
  }

  @override
  void didUpdateWidget(_BottomNavContent old) {
    super.didUpdateWidget(old);
    if (old.selected != widget.selected) {
      _from = _pos; // capture current animated position (not from previous _to)
      _to = widget.selected.toDouble();
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalH = _kOverlap + _kBarH + widget.bottomPadding;

    return AnimatedBuilder(
      animation: _curve,
      builder: (ctx, _) {
        return LayoutBuilder(
          builder: (ctx, constraints) {
            final w = constraints.maxWidth;
            final tabW = w / _kCount;
            final pos = _pos;
            // centre-x of the bump in the widget's coordinate space
            final cx = pos * tabW + tabW / 2;

            return SizedBox(
              height: totalH,
              child: Stack(
                // clipBehavior.none lets the dome overflow upward
                clipBehavior: Clip.none,
                children: [
                  // ── Layer 1: bar + dome shape (CustomPaint) ───────────────
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: _kOverlap + _kBarH,
                    child: CustomPaint(painter: _BumpPainter(cx: cx)),
                  ),

                  // ── Layer 2: tap targets + inactive icons + active label ──
                  Positioned(
                    top: _kOverlap,
                    left: 0,
                    right: 0,
                    height: _kBarH,
                    child: Row(
                      children: List.generate(_kCount, (i) {
                        final isActive = i == widget.selected;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => widget.onTap(i),
                            behavior: HitTestBehavior.opaque,
                            child: SizedBox(
                              height: _kBarH,
                              child: isActive
                                  // Active slot: only show label at bottom;
                                  // icon is on the floating circle above the bar
                                  ? Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 10,
                                        ),
                                        child: Text(
                                          widget.labels[i],
                                          style: const TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                            height: 1.0,
                                            letterSpacing: 0,
                                            color: Color(0xFFF40C0C),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    )
                                  // Inactive slot: white icon centred in bar
                                  : Center(
                                      child: Image.asset(
                                        widget.iconPaths[i],
                                        width: 28,
                                        height: 28,
                                        color: Colors.white,
                                        colorBlendMode: BlendMode.srcIn,
                                      ),
                                    ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  // ── Layer 3: floating red circle (protrudes above bar) ────
                  Positioned(
                    // Circle top = bar_top - circleAbove = overlap - 18 = 22
                    top: _kOverlap - _kCircleAbove,
                    left: cx - _kCircle / 2,
                    width: _kCircle,
                    height: _kCircle,
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: const Color(0xFFD41F1F),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFFD41F1F,
                              ).withValues(alpha: 0.45),
                              blurRadius: 10.47,
                              offset: const Offset(0, 3.49),
                            ),
                          ],
                        ),
                        child: Center(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Image.asset(
                              widget.iconPaths[widget.selected],
                              key: ValueKey(widget.selected),
                              width: 28,
                              height: 28,
                              color: Colors.white,
                              colorBlendMode: BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ── CustomPainter: draws bar + red arc wings + dark dome ─────────────────────
class _BumpPainter extends CustomPainter {
  final double cx;
  const _BumpPainter({required this.cx});

  @override
  void paint(Canvas canvas, Size size) {
    final barTop = _kOverlap;

    // ── 1. Dark bar ──────────────────────────────────────────────────────────
    final barPaint = Paint()..color = const Color(0xFF1E1E1E);
    canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        0,
        barTop,
        size.width,
        size.height,
        topLeft: const Radius.circular(6),
        topRight: const Radius.circular(6),
        bottomLeft: const Radius.circular(24),
        bottomRight: const Radius.circular(24),
      ),
      barPaint,
    );

    // ── 2. Red glow blur behind the arc ─────────────────────────────────────
    // Arc center is 13.55px above bar top (from Figma)
    final arcCy = barTop - 13.55;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, arcCy),
        width: _kArcW + 12,
        height: _kArcH + 12,
      ),
      Paint()
        ..color = const Color(0xFFD41F1F).withValues(alpha: 0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );

    // ── 3. Red arc ellipse (full ellipse, 4px stroke) ────────────────────────
    // The dark dome (step 4) will cover the inner portion,
    // leaving only the outer "wing" segments visible around the dome base.
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, arcCy), width: _kArcW, height: _kArcH),
      Paint()
        ..color = const Color(0xFFE60D0D)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );

    // ── 4. Dark dome oval (same colour as bar → seamless bump) ───────────────
    // Dome center is 5.545px above bar top (from Figma)
    final domeCy = barTop - 5.545;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, domeCy),
        width: _kDomeW,
        height: _kDomeH,
      ),
      barPaint,
    );

    // ── 5. Thin red border on dome (1px, Figma: border 1px solid #E60D0D) ────
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, domeCy),
        width: _kDomeW,
        height: _kDomeH,
      ),
      Paint()
        ..color = const Color(0xFFE60D0D)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(_BumpPainter old) => old.cx != cx;
}

// ignore: unused_import
// (math import kept for potential arc calculations)
final _pi = math.pi;
