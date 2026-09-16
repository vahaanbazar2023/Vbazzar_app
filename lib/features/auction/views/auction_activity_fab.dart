import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../routes/app_routes.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Expandable auction activity FAB
// Tap the red circle to expand → My Wins / My Bids / Initiate Refund
// ─────────────────────────────────────────────────────────────────────────────

class AuctionActivityFab extends StatefulWidget {
  const AuctionActivityFab({super.key});

  @override
  State<AuctionActivityFab> createState() => _AuctionActivityFabState();
}

class _AuctionActivityFabState extends State<AuctionActivityFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final Animation<double> _expand;
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _expand = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _open = !_open);
    _open ? _anim.forward() : _anim.reverse();
  }

  void _go(String route) {
    if (_open) _toggle();
    Get.toNamed(route);
  }

  static const _items = [
    (
      label: 'My Wins',
      icon: AppAssets.subIconStar,
      bg: Color(0xFFFFF8E0),
      route: AppRoutes.myWins,
    ),
    (
      label: 'My Bids',
      icon: AppAssets.subIconBidLimit,
      bg: Color(0xFFEEF4FF),
      route: AppRoutes.myBids,
    ),
    (
      label: 'Initiate Refund',
      icon: AppAssets.subIconPending,
      bg: Color(0xFFFFF0F0),
      route: AppRoutes.initiateRefund,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // ── Expanded action items ───────────────────────────
        ScaleTransition(
          scale: _expand,
          alignment: Alignment.bottomRight,
          child: FadeTransition(
            opacity: _expand,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final item in _items) ...[
                  _FabItem(
                    label: item.label,
                    iconAsset: item.icon,
                    bgColor: item.bg,
                    onTap: () => _go(item.route),
                  ),
                  SizedBox(height: 10.h),
                ],
                SizedBox(height: 4.h),
              ],
            ),
          ),
        ),
        // ── Main trigger button ─────────────────────────────
        GestureDetector(
          onTap: _toggle,
          child: Container(
            width: 52.r,
            height: 52.r,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppColors.ctaGradientStart,
                  AppColors.ctaGradientEnd,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: AnimatedRotation(
              turns: _open ? 0.125 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                _open ? Icons.close_rounded : Icons.menu_rounded,
                color: Colors.white,
                size: 22.r,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Single action row: label pill + icon circle
// ─────────────────────────────────────────────────────────────────────────────

class _FabItem extends StatelessWidget {
  final String label;
  final String iconAsset;
  final Color bgColor;
  final VoidCallback onTap;

  const _FabItem({
    required this.label,
    required this.iconAsset,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Label pill
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.09),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.grey800,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          // Icon circle
          Container(
            width: 42.r,
            height: 42.r,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.09),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Image.asset(
                iconAsset,
                width: 22.r,
                height: 22.r,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
