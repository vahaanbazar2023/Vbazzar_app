import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../controllers/sell_vehicle_controller.dart';
import '../controllers/vehicle_detail_controller.dart';
import '../data/repositories/buy_sell_repository_impl.dart';
import '../views/my_vehicles_view.dart';
import '../views/subscribed_vehicles_view.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Expandable Buy & Sell activity FAB
// Actions: My Vehicles · Wishlist · Purchase History
// ─────────────────────────────────────────────────────────────────────────────

class BuySellActivityFab extends StatefulWidget {
  const BuySellActivityFab({super.key});

  @override
  State<BuySellActivityFab> createState() => _BuySellActivityFabState();
}

class _BuySellActivityFabState extends State<BuySellActivityFab>
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

  void _close() {
    if (_open) _toggle();
  }

  void _goMyVehicles() {
    _close();
    Get.to(
      () => const MyVehiclesView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<SellVehicleController>()) {
          Get.put(
            SellVehicleController(repository: BuySellRepositoryImpl()),
          );
        }
      }),
    );
  }

  void _goWishlist() {
    _close();
    Get.to(
      () => const SubscribedVehiclesView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<BuyVehicleController>()) {
          Get.put(
            BuyVehicleController(repository: BuySellRepositoryImpl()),
          );
        }
      }),
    );
  }

  void _goPurchaseHistory() {
    _close();
    Get.toNamed(AppRoutes.spareOrders);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // ── Action items ────────────────────────────────────
        ScaleTransition(
          scale: _expand,
          alignment: Alignment.bottomRight,
          child: FadeTransition(
            opacity: _expand,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _FabItem(
                  label: 'My Vehicles',
                  iconAsset: AppAssets.subIconVehicle,
                  bgColor: const Color(0xFFEEF4FF),
                  onTap: _goMyVehicles,
                ),
                SizedBox(height: 10.h),
                _FabItem(
                  label: 'Wishlist',
                  iconAsset: AppAssets.subIconWallet,
                  bgColor: const Color(0xFFFFF8E0),
                  onTap: _goWishlist,
                ),
                SizedBox(height: 10.h),
                _FabItem(
                  label: 'Purchase History',
                  iconAsset: AppAssets.subIconGroup2,
                  bgColor: const Color(0xFFF0FFF0),
                  onTap: _goPurchaseHistory,
                ),
                SizedBox(height: 4.h),
              ],
            ),
          ),
        ),
        // ── Trigger button ──────────────────────────────────
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
