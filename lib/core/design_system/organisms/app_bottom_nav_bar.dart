import 'package:flutter/material.dart';

enum BottomNavTab { home, subscriptions, categories, rewards, settings }

// ── Layout constants ──────────────────────────────────────────────────────────
const int _kCount = 5;
const double _kBarH = 80.0; // dark bar height
const double _kOverlap = 42.0; // vertical space reserved above bar for wave
const double _kCircleSize = 48.0; // active red circle diameter
const double _kWaveW = 100.0; // total horizontal span of the wave arch
const double _kWaveH = 28.0; // wave arch height above bar top edge
const double _kCircleLift =
    -4.0; // negative = centre is 4 px inside bar → ~40 % protrusion (≈20 px)
const double _kPadH = 4.0; // bar left / right padding from screen edges
const double _kIconPad =
    16.0; // extra horizontal padding for icons inside the bar
const double _kPadB = 0.0; // bottom padding

class AppBottomNavBar extends StatefulWidget {
  final BottomNavTab currentTab;
  final ValueChanged<BottomNavTab> onTabSelected;

  const AppBottomNavBar({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
  });

  @override
  State<AppBottomNavBar> createState() => _AppBottomNavBarState();
}

class _AppBottomNavBarState extends State<AppBottomNavBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  double _fromX = 0;
  double _toX = 0;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_ready) {
      _ready = true;
      final cx = _centerX(widget.currentTab.index);
      _fromX = cx;
      _toX = cx;
    }
  }

  @override
  void didUpdateWidget(AppBottomNavBar old) {
    super.didUpdateWidget(old);
    if (old.currentTab != widget.currentTab) {
      _fromX = _fromX + (_toX - _fromX) * _anim.value;
      _toX = _centerX(widget.currentTab.index);
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  double _centerX(int index) {
    final w = MediaQuery.of(context).size.width;
    final usableW = w - _kPadH * 2 - _kIconPad * 2;
    final itemW = usableW / _kCount;
    return _kPadH + _kIconPad + itemW * index + itemW / 2;
  }

  @override
  Widget build(BuildContext context) {
    final safePad = MediaQuery.of(context).padding.bottom;
    // circle top = overlap - lift - radius  →  46 - 18 - 24 = 4 px from widget top
    const circleTop = _kOverlap - _kCircleLift - _kCircleSize / 2;

    return SizedBox(
      height: _kBarH + safePad,
      child: OverflowBox(
        alignment: Alignment.bottomCenter,
        minHeight: _kOverlap + _kBarH + safePad,
        maxHeight: _kOverlap + _kBarH + safePad,
        child: SizedBox(
          height: _kOverlap + _kBarH + safePad,
          child: AnimatedBuilder(
            animation: _anim,
            builder: (_, __) {
              final cx = _fromX + (_toX - _fromX) * _anim.value;

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // ── Layer 1: bar shape + wave + red wave border ────────────────
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: CustomPaint(painter: _WavePainter(cx)),
                    ),
                  ),

                  // ── Layer 2: inactive icons + active label (inside the bar) ───
                  Positioned(
                    top: _kOverlap,
                    left: _kPadH + _kIconPad,
                    right: _kPadH + _kIconPad,
                    height: _kBarH,
                    child: Row(
                      children: BottomNavTab.values.map((tab) {
                        final isActive = tab == widget.currentTab;
                        return Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => widget.onTabSelected(tab),
                            child: isActive
                                ? _ActiveLabel(tab)
                                : _InactiveIcon(tab),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  // ── Layer 3: floating red circle (pops above bar) ─────────────
                  Positioned(
                    top: circleTop,
                    left: cx - _kCircleSize / 2,
                    width: _kCircleSize,
                    height: _kCircleSize,
                    child: _ActiveCircle(widget.currentTab),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ── Painter ───────────────────────────────────────────────────────────────────
// Draws three things in order:
//   1. Red glow (blurred stroke) along the wave path – before bar fill
//   2. Bar fill whose TOP EDGE is the wave arch itself (one seamless shape)
//   3. Red border stroke (4 px) along the wave arch – on top of bar fill
class _WavePainter extends CustomPainter {
  final double cx;
  _WavePainter(this.cx);

  @override
  void paint(Canvas canvas, Size size) {
    final barLeft = _kPadH;
    final barRight = size.width - _kPadH;
    const barTop = _kOverlap;
    final barBottom = size.height - _kPadB;

    // Always full wave width — edge tabs overflow naturally and are clipped
    // by the viewport, giving identical arch shape for every tab.
    final halfW = _kWaveW / 2;
    final waveL = cx - halfW;
    final waveR = cx + halfW;
    const wavePeak = barTop - _kWaveH; // Y of arch peak (above bar top)

    // ── Reusable wave-arch path (open curve, left foot → peak → right foot) ──
    Path _makeWavePath() {
      return Path()
        ..moveTo(waveL, barTop)
        ..cubicTo(
          cx - halfW * 0.55,
          barTop, // CP1 – horizontal tangent at left foot
          cx - halfW * 0.55,
          wavePeak, // CP2 – same X as CP1 → smooth arch, horizontal at peak
          cx,
          wavePeak, // arch peak
        )
        ..cubicTo(
          cx + halfW * 0.55,
          wavePeak, // CP3 – same X as CP4 → smooth arch, horizontal at peak
          cx + halfW * 0.55,
          barTop, // CP4 – horizontal tangent at right foot
          waveR,
          barTop, // right foot
        );
    }

    // ── Full bar outline path (top edge = wave arch + flat segments) ──────────
    // pathWaveL/R are clamped only for the fill shape so we never draw a
    // backwards horizontal segment when the arch overflows the bar edges.
    final pathWaveL = waveL.clamp(barLeft + 6.0, cx - 1.0);
    final pathWaveR = waveR.clamp(cx + 1.0, barRight - 6.0);

    final barPath = Path();
    barPath.moveTo(barLeft + 6, barTop);
    // flat line to wave left foot only when it sits inside the bar
    if (pathWaveL > barLeft + 6) barPath.lineTo(pathWaveL, barTop);
    // wave arch (upward) — control points always based on full halfW
    barPath.cubicTo(
      cx - halfW * 0.55,
      barTop,
      cx - halfW * 0.55,
      wavePeak,
      cx,
      wavePeak,
    );
    barPath.cubicTo(
      cx + halfW * 0.55,
      wavePeak,
      cx + halfW * 0.55,
      barTop,
      pathWaveR,
      barTop,
    );
    // flat line from wave right foot to TR corner only when needed
    if (pathWaveR < barRight - 6) barPath.lineTo(barRight - 6, barTop);
    // TR corner
    barPath.arcToPoint(
      Offset(barRight, barTop + 6),
      radius: const Radius.circular(6),
      clockwise: true,
    );
    // right edge → BR corner
    barPath.lineTo(barRight, barBottom - 24);
    barPath.arcToPoint(
      Offset(barRight - 24, barBottom),
      radius: const Radius.circular(24),
      clockwise: true,
    );
    // bottom edge → BL corner
    barPath.lineTo(barLeft + 24, barBottom);
    barPath.arcToPoint(
      Offset(barLeft, barBottom - 24),
      radius: const Radius.circular(24),
      clockwise: true,
    );
    // left edge → TL corner
    barPath.lineTo(barLeft, barTop + 6);
    barPath.arcToPoint(
      Offset(barLeft + 6, barTop),
      radius: const Radius.circular(6),
      clockwise: true,
    );
    barPath.close();

    final wavePath = _makeWavePath();

    // ── 1. Red glow – drawn BEFORE bar fill so the bar covers the inner blur ──
    canvas.drawPath(
      wavePath,
      Paint()
        ..color = const Color(0xFFE60D0D).withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    // ── 2. Dark bar fill (top edge IS the wave arch) ──────────────────────────
    canvas.drawPath(barPath, Paint()..color = const Color(0xFF1E1E1E));

    // ── 3. Red wave border on top of bar fill ────────────────────────────────
    canvas.drawPath(
      wavePath,
      Paint()
        ..color = const Color(0xFFE60D0D)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _WavePainter old) => old.cx != cx;
}

// ── Active red circle (floats above bar) ─────────────────────────────────────
class _ActiveCircle extends StatelessWidget {
  final BottomNavTab tab;
  const _ActiveCircle(this.tab);

  static const _icons = [
    'assets/images/png/home.png',
    'assets/images/png/subscriptions.png',
    'assets/images/png/category.png',
    'assets/images/png/rewards.png',
    'assets/images/png/settings.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _kCircleSize,
      height: _kCircleSize,
      decoration: BoxDecoration(
        color: const Color(0xFFD41F1F),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD41F1F).withValues(alpha: 0.45),
            blurRadius: 10.47,
            offset: const Offset(0, 3.49),
          ),
        ],
      ),
      child: Center(
        child: Image.asset(
          _icons[tab.index],
          width: 24,
          height: 24,
          color: Colors.white,
        ),
      ),
    );
  }
}

// ── Active label (anchored to bar bottom, inside bar) ────────────────────────
class _ActiveLabel extends StatelessWidget {
  final BottomNavTab tab;
  const _ActiveLabel(this.tab);

  static const _labels = [
    'Home',
    'Subscriptions',
    'Categories',
    'Rewards',
    'Settings',
  ];

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 28),
        child: Text(
          _labels[tab.index],
          style: const TextStyle(
            fontFamily: 'Montserrat',
            color: Color(0xFFF40C0C),
            fontWeight: FontWeight.w600,
            fontSize: 10,
            height: 1.0,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

// ── Inactive icon (centred in bar) ───────────────────────────────────────────
class _InactiveIcon extends StatelessWidget {
  final BottomNavTab tab;
  const _InactiveIcon(this.tab);

  static const _icons = [
    'assets/images/png/home.png',
    'assets/images/png/subscriptions.png',
    'assets/images/png/category.png',
    'assets/images/png/rewards.png',
    'assets/images/png/settings.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        _icons[tab.index],
        width: 28,
        height: 28,
        color: Colors.white,
      ),
    );
  }
}
