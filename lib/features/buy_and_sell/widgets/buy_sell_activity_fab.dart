import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../controllers/sell_vehicle_controller.dart';
import '../controllers/vehicle_detail_controller.dart';
import '../data/repositories/buy_sell_repository_impl.dart';
import '../views/my_vehicles_view.dart';
import '../views/subscribed_vehicles_view.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Expandable Buy & Sell activity FAB — matches Auction FAB design
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

  void _go(String action) {
    if (_open) _toggle();
    switch (action) {
      case 'my_vehicles':
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
        break;
      case 'wishlist':
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
        break;
      case 'purchase_history':
        Get.toNamed(AppRoutes.spareOrders);
        break;
    }
  }

  List<({String label, String iconAsset, String action})> _items(
    BuildContext context,
  ) => [
    (
      label: context.l10n.myVehicles,
      iconAsset: AppAssets.subIconVehicle,
      action: 'my_vehicles',
    ),
    (
      label: context.l10n.spareWishlist,
      iconAsset: AppAssets.subIconWallet,
      action: 'wishlist',
    ),
    (
      label: context.l10n.sparePurchaseHistory,
      iconAsset: AppAssets.subIconGroup2,
      action: 'purchase_history',
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
                for (final item in _items(context)) ...[
                  _FabItem(
                    label: item.label,
                    iconAsset: item.iconAsset,
                    onTap: () => _go(item.action),
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
                  AppColors.ctaGradientStartfab,
                  AppColors.ctaGradientEndfab,
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
// Single action row: label pill + icon circle — matches Auction FAB design
// ─────────────────────────────────────────────────────────────────────────────

class _FabItem extends StatelessWidget {
  final String label;
  final String iconAsset;
  final VoidCallback onTap;

  const _FabItem({
    required this.label,
    required this.iconAsset,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: BoxConstraints(
          minHeight: 38.r,
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        clipBehavior: Clip.none,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.ctaGradientStartfab.withValues(alpha: 0.95),
              AppColors.ctaGradientEndfab,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(19.r),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Label ──────────────────────────────────────────
            Flexible(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    shadows: const [
                      Shadow(color: Colors.black26, blurRadius: 6),
                    ],
                  ),
                ),
              ),
            ),
            // ── Icon circle ────────────────────────────────────
            Container(
              width: 36.r,
              height: 36.r,
              margin: EdgeInsets.only(right: 1.r),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.20),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: Center(
                child: Image.asset(
                  iconAsset,
                  width: 18.r,
                  height: 18.r,
                  fit: BoxFit.contain,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
