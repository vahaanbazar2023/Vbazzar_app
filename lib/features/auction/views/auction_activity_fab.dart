import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../controllers/vehicle_listing_controller.dart';
import '../services/vehicle_excel_download_service.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/storage/storage_keys.dart';
import '../../../core/design_system/molecules/custom_snackbar.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Expandable auction activity FAB
// Tap the red circle to expand → My Wins / My Bids / Wishlist / Initiate Refund
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
    if (route.isEmpty) {
      _handleDownload();
    } else {
      Get.toNamed(route);
    }
  }

  Future<void> _handleDownload() async {
    try {
      // Get user ID
      final userId = await SecureStorageService.to.read(StorageKeys.userId);
      if (userId == null || userId.isEmpty) {
        CustomSnackbar.show(
          message: 'Please login to download',
          type: SnackbarType.error,
        );
        return;
      }

      // Auto-detect auction ID from current tab's first vehicle
      final vehicleCtrl = Get.find<VehicleListingController>();
      final currentTab = vehicleCtrl.tabController.index;
      final vehicles = vehicleCtrl.tabVehicles(currentTab);

      if (vehicles.isEmpty) {
        CustomSnackbar.show(
          message: 'No auction data available',
          type: SnackbarType.error,
        );
        return;
      }

      final auctionId = vehicles.first.auctionId;

      // Show loading
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final service = Get.find<VehicleExcelDownloadService>();
      await service.downloadVehicleExcel(auctionId: auctionId, userId: userId);

      Get.back(); // Close loading

      CustomSnackbar.show(
        message: 'Excel file downloaded successfully',
        type: SnackbarType.success,
      );
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      CustomSnackbar.show(
        message: 'Failed to download: $e',
        type: SnackbarType.error,
      );
    }
  }

  static final _items = [
    (
      label: 'My Wins',
      iconAsset: AppAssets.subIconStar,
      iconData: null,
      route: AppRoutes.myWins,
    ),
    (
      label: 'My Bids',
      iconAsset: AppAssets.subIconBidLimit,
      iconData: null,
      route: AppRoutes.myBids,
    ),
    (
      label: 'Wishlist',
      iconAsset: null,
      iconData: Icons.favorite_rounded,
      route: AppRoutes.myWishlist,
    ),
    (
      label: 'Download Listing',
      iconAsset: null,
      iconData: Icons.download_rounded,
      route: '', // Empty route triggers download
    ),
    (
      label: 'Initiate Refund',
      iconAsset: AppAssets.subIconPending,
      iconData: null,
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
                    iconAsset: item.iconAsset,
                    iconData: item.iconData,
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
// Single action row: label pill + icon circle
// ─────────────────────────────────────────────────────────────────────────────

class _FabItem extends StatelessWidget {
  final String label;
  final String? iconAsset;
  final IconData? iconData;
  final VoidCallback onTap;

  const _FabItem({
    required this.label,
    this.iconAsset,
    this.iconData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 38.r,
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
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  shadows: const [Shadow(color: Colors.black26, blurRadius: 6)],
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
                child: iconData != null
                    ? Icon(iconData, size: 18.r, color: Colors.white)
                    : Image.asset(
                        iconAsset!,
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
