import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/design_system/molecules/custom_snackbar.dart';
import '../../../core/design_system/organisms/network_image_carousel.dart';
import '../../../core/design_system/templates/app_layout.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/extensions/context_extensions.dart';
import '../controllers/watchlist_controller.dart';
import '../controllers/wishlist_controller.dart';
import '../controllers/vehicle_listing_controller.dart';
import '../models/vehicle_listing.dart';
import '../../../core/design_system/molecules/timer_badge.dart';
import 'my_wishlist_detail_view.dart';

class MyWishlistView extends GetView<WishlistController> {
  const MyWishlistView({super.key});
  bool _isAuctionEnded(String auctionEndDate) {
    if (auctionEndDate.isEmpty) return false;
    try {
      final endDate = DateTime.parse(auctionEndDate);
      return endDate.isBefore(DateTime.now());
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: context.l10n.aucMyWishlist,
      subtitle: context.l10n.aucYourFavoriteVehicles,
      showBack: true,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const _WishlistCardSkeletonList();
        }
        if (controller.errorMessage.value != null) {
          return _ErrorState(
            message: controller.errorMessage.value!,
            onRetry: controller.refresh,
          );
        }
        if (controller.vehicles.isEmpty) {
          return _EmptyState(
            icon: Icons.gavel_outlined,
            message: context.l10n.aucNoWishlistItems,
          );
        }
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: controller.refresh,
          child: ListView.builder(
            controller: controller.scrollController,
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
            ),
            itemCount:
                controller.vehicles.length +
                (controller.isLoadingMore.value ? 1 : 0),
            itemBuilder: (_, i) {
              if (i >= controller.vehicles.length) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                );
              }
              return Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.md),
                child: _WishlistCard(vehicle: controller.vehicles[i]),
              );
            },
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Auction watchlist — same cards as the wishlist, plus an auto-bid switch
// ─────────────────────────────────────────────────────────────────────────────

class MyWatchlistView extends GetView<WatchlistController> {
  const MyWatchlistView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: context.l10n.aucMyWatchlist,
      subtitle: context.l10n.aucWatchlistSubtitle,
      showBack: true,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const _WishlistCardSkeletonList();
        }
        if (controller.errorMessage.value != null) {
          return _ErrorState(
            message: controller.errorMessage.value!,
            onRetry: controller.refresh,
          );
        }
        if (controller.vehicles.isEmpty) {
          return _EmptyState(
            icon: Icons.visibility_outlined,
            message: context.l10n.aucNoWatchlistItems,
          );
        }
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: controller.refresh,
          child: ListView.builder(
            controller: controller.scrollController,
            padding: EdgeInsets.all(AppSpacing.md),
            itemCount:
                controller.vehicles.length +
                (controller.isLoadingMore.value ? 1 : 0),
            itemBuilder: (_, i) {
              if (i >= controller.vehicles.length) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                );
              }
              final v = controller.vehicles[i];
              return Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.md),
                child: _WishlistCard(
                  key: ValueKey('watch-${v.vehicleId}'),
                  vehicle: v,
                  watchlist: controller,
                ),
              );
            },
          ),
        );
      }),
    );
  }
}

/// Auto-bid switch shown on watchlist cards while the auction is open.
class _AutoBidRow extends StatelessWidget {
  final VehicleListing vehicle;
  final WatchlistController controller;
  const _AutoBidRow({required this.vehicle, required this.controller});

  Future<void> _onChanged(BuildContext context, bool on) async {
    if (on) {
      final step = (vehicle.bidIncrementAmount ?? 0) > 0
          ? vehicle.bidIncrementAmount!
          : 1;
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(ctx.l10n.aucAutoBidConfirmTitle),
          content: Text(
            ctx.l10n.aucAutoBidConfirmBody(
              WatchlistController.formatAmount(step),
              '${vehicle.maxUserVehiclesBidLimit}',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(ctx.l10n.cancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(ctx.l10n.aucAutoBidConfirmCta),
            ),
          ],
        ),
      );
      if (ok != true) return;
    }
    await controller.setAutoBid(vehicle, on);
  }

  @override
  Widget build(BuildContext context) {
    final on = vehicle.isAutoBidEnabled;
    return Container(
      margin: EdgeInsets.fromLTRB(12.w, 0, 12.w, 10.h),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: on
            ? AppColors.primary.withValues(alpha: 0.08)
            : const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: on ? AppColors.primary.withValues(alpha: 0.35) : AppColors.grey200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.bolt_rounded,
            size: 20.r,
            color: on ? AppColors.primary : AppColors.grey500,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.aucAutoBid,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  on
                      ? context.l10n.aucAutoBidOnStatus(
                          '${vehicle.userVehicleBidCount}',
                          '${vehicle.maxUserVehiclesBidLimit}',
                        )
                      : context.l10n.aucAutoBidHint,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 10.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Obx(() {
            final busy = controller.busy.contains(vehicle.vehicleId);
            return Semantics(
              label: context.l10n.aucAutoBid,
              child: Switch.adaptive(
                value: on,
                activeTrackColor: AppColors.primary,
                onChanged: busy ? null : (v) => _onChanged(context, v),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Loading skeleton — mirrors _WishlistCard (image + right panel, 2-col grid,
// details divider, bid row, view-details button) and the list padding
// ─────────────────────────────────────────────────────────────────────────────

class _WishlistCardSkeletonList extends StatelessWidget {
  const _WishlistCardSkeletonList();

  @override
  Widget build(BuildContext context) {
    return SkeletonList(
      count: 4,
      spacing: AppSpacing.md,
      padding: EdgeInsets.all(AppSpacing.md),
      itemBuilder: (_, __) => const _WishlistCardSkeleton(),
    );
  }
}

class _WishlistCardSkeleton extends StatelessWidget {
  const _WishlistCardSkeleton();

  Widget _cellRow() => Row(
    children: [
      Expanded(child: SkeletonBox(height: 40.h, radius: 6)),
      SizedBox(width: 6.w),
      Expanded(child: SkeletonBox(height: 40.h, radius: 6)),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.grey200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: AppShimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 171.w, height: 99.h, radius: 0),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 10.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(width: 120.w, height: 14.h),
                        SizedBox(height: 4.h),
                        SkeletonBox(width: 95.w, height: 11.h),
                        SizedBox(height: 6.h),
                        SkeletonBox(width: 28.w, height: 20.h, radius: 4),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 0),
              child: Column(
                children: [
                  _cellRow(),
                  SizedBox(height: 6.h),
                  _cellRow(),
                  SizedBox(height: 6.h),
                  _cellRow(),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              child: Row(
                children: [
                  Expanded(child: Divider(color: AppColors.grey300, thickness: 1)),
                  SizedBox(width: 8.w),
                  SkeletonBox(width: 64.w, height: 12.h),
                  SizedBox(width: 8.w),
                  Expanded(child: Divider(color: AppColors.grey300, thickness: 1)),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
              child: Row(
                children: [
                  Expanded(child: SkeletonBox(height: 42.h, radius: 8)),
                  SizedBox(width: 10.w),
                  SkeletonBox(width: 110.w, height: 32.h, radius: 8),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 12.w, right: 12.w, bottom: 12.h),
              child: SkeletonBox(height: 36.h, radius: 16),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bid card — matches auction vehicle listing card layout
// ─────────────────────────────────────────────────────────────────────────────

class _WishlistCard extends StatefulWidget {
  final VehicleListing vehicle;
  /// Set on the watchlist screen: bids go through it and the card shows the auto-bid switch.
  final WatchlistController? watchlist;
  const _WishlistCard({super.key, required this.vehicle, this.watchlist});

  @override
  State<_WishlistCard> createState() => _WishlistCardState();
}

class _WishlistCardState extends State<_WishlistCard> {
  bool _expanded = false;
  bool _isPlacing = false;
  late int _bidAmount;
  late TextEditingController _bidCtrl;

  @override
  void initState() {
    super.initState();
    final v = widget.vehicle;
    _bidAmount = v.minimumNextBid ?? v.minimumPrice;
    _bidCtrl = TextEditingController(text: _fmt(_bidAmount));
  }

  @override
  void didUpdateWidget(covariant _WishlistCard old) {
    super.didUpdateWidget(old);
    // A refresh (e.g. after an auto-bid) moves the minimum next bid — keep the stepper valid.
    final min = widget.vehicle.minimumNextBid ?? widget.vehicle.minimumPrice;
    if (min != (old.vehicle.minimumNextBid ?? old.vehicle.minimumPrice) &&
        _bidAmount < min) {
      _bidAmount = min;
      _bidCtrl.text = _fmt(_bidAmount);
    }
  }

  @override
  void dispose() {
    _bidCtrl.dispose();
    super.dispose();
  }

  int get _increment {
    final v = widget.vehicle;
    if ((v.bidIncrementAmount ?? 0) > 0) return v.bidIncrementAmount!;
    return 5000;
  }

  void _decrease() {
    final v = widget.vehicle;
    final min = v.minimumNextBid ?? v.minimumPrice;
    final next = _bidAmount - _increment;
    if (next >= min) {
      setState(() {
        _bidAmount = next;
        _bidCtrl.text = _fmt(_bidAmount);
      });
    }
  }

  void _increase() {
    setState(() {
      _bidAmount += _increment;
      _bidCtrl.text = _fmt(_bidAmount);
    });
  }

  Future<void> _placeBid() async {
    setState(() => _isPlacing = true);
    final watchlist = widget.watchlist;
    final error = watchlist != null
        ? await watchlist.placeBid(vehicle: widget.vehicle, bidAmount: _bidAmount)
        : await Get.find<VehicleListingController>().placeBid(
            vehicle: widget.vehicle,
            bidAmount: _bidAmount,
          );
    if (mounted) setState(() => _isPlacing = false);
    if (error != null && error != '__navigated__') {
      CustomSnackbar.show(message: error, type: SnackbarType.error);
    } else if (error == null) {
      CustomSnackbar.show(
        message: appL10n.bidPlacedSuccessfully,
        type: SnackbarType.success,
      );
    }
  }

  Color get _statusColor => AppColors.error;

  String get _statusLabel => widget.watchlist != null
      ? context.l10n.aucWatching
      : context.l10n.aucWishlisted;

  static String _fmt(int n) {
    if (n == 0) return '0';
    final s = n.toString();
    final buf = StringBuffer();
    int c = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      if (c > 0 && c % 3 == 0) buf.write(',');
      buf.write(s[i]);
      c++;
    }
    return buf.toString().split('').reversed.join();
  }

  bool _isAuctionEnded(String auctionEndDate) {
    if (auctionEndDate.isEmpty) return false;
    try {
      final endDate = DateTime.parse(auctionEndDate);
      return endDate.isBefore(DateTime.now());
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.vehicle;
    final isClosed = _isAuctionEnded(v.auctionEndDate);

    // Winning / Losing status.
    // While the auction is live we compare the user's bid to the current
    // highest. Once it has ended we trust the server's bid status
    // (approved = won/leading, rejected = outbid). The chip is hidden for
    // ended auctions with no decisive status.
    final bool hasBid = v.yourBid > 0;
    final String status = "active".toLowerCase();
    final bool isWinning = isClosed
        ? (status == 'approved' || status == 'won')
        : hasBid &&
              ((v.currentHighestBid ?? 0) <= 0 ||
                  v.yourBid >= (v.currentHighestBid ?? 0));
    final bool isLosing = isClosed
        ? (status == 'rejected' || status == 'lost')
        : hasBid && !isWinning;
    final bool showBidChip = hasBid && (isWinning || isLosing);

    final cardBorderColor = isWinning
        ? const Color(0xFF2E7D32)
        : isLosing
        ? const Color(0xFFC62828)
        : AppColors.grey200;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: cardBorderColor,
          width: showBidChip ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ════════════════════════════════════════════════
          // ROW 1: image (171w×99h) + title/timer/status
          // ════════════════════════════════════════════════
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              SizedBox(
                width: 171.w,
                height: 99.h,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      color: const Color(0xFFF0F0F0),
                      child: NetworkImageCarousel(
                        imageUrls: v.images,
                        height: 99.h,
                      ),
                    ),
                    // Timer badge — top-left on image
                    if (!isClosed)
                      Positioned(
                        top: 4.h,
                        left: 0,
                        child: ExcludeSemantics(
                          child: TimerBadge(
                            endAt: v.auctionEndDate,
                            mirrored: true,
                          ),
                        ),
                      ),
                    // VEH ID bar at bottom
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        color: AppColors.primary,
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 3.h,
                        ),
                        child: Text(
                          v.vehicleId,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    // Winning/Losing chip — same as auction listing card
                    if (showBidChip)
                      Positioned(
                        top: 6.h,
                        left: 6.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 7.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: isWinning
                                ? const Color(0xFF2E7D32)
                                : const Color(0xFFC62828),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isWinning
                                    ? Icons.emoji_events_rounded
                                    : Icons.trending_down_rounded,
                                size: 10.r,
                                color: Colors.white,
                              ),
                              SizedBox(width: 3.w),
                              Flexible(
                                child: Text(
                                  isWinning
                                      ? context.l10n.aucWinning
                                      : context.l10n.aucLosing,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    // Closed overlay — top-right
                    if (isClosed)
                      Positioned(
                        top: 6.h,
                        right: 6.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 7.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            context.l10n.closedBadge,
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Right panel
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 10.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Make + Model
                      Text(
                        '${v.make} ${v.model}'.trim().isEmpty
                            ? v.vehicleId
                            : '${v.make} ${v.model}',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.h),
                      // Reg No · Year
                      if (v.registrationNo.isNotEmpty)
                        Text(
                          '${v.registrationNo}  ·  ${v.year}',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 11.sp,
                            color: AppColors.grey600,
                          ),
                        ),
                      SizedBox(height: 6.h),
                      // Watchlist: eye badge — tap to remove from the watchlist
                      if (widget.watchlist != null)
                        Obx(() {
                          final busy = widget.watchlist!.busy.contains(v.vehicleId);
                          return Semantics(
                            button: true,
                            label: context.l10n.aucWatching,
                            child: InkWell(
                              onTap: busy
                                  ? null
                                  : () => widget.watchlist!.removeFromWatchlist(v),
                              borderRadius: BorderRadius.circular(4.r),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.visibility_rounded,
                                      size: 12.r,
                                      color: AppColors.primary,
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      context.l10n.aucWatching,
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 9.sp,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    SizedBox(width: 2.w),
                                    Icon(
                                      Icons.close_rounded,
                                      size: 11.r,
                                      color: AppColors.primary,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        })
                      else
                      // Wishlist heart icon badge
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.favorite,
                              size: 12.r,
                              color: AppColors.error,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ════════════════════════════════════════════════
          // ROW 2: always-visible 2-col grid
          // Yard Name | Yard Location  /  Auction ID | Vehicle ID
          // ════════════════════════════════════════════════
          Padding(
            padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 0),
            child: Column(
              children: [
                if (!_expanded) ...[
                  _GRow(
                    context.l10n.yard_name,
                    v.yardName,
                    context.l10n.yard_location,
                    v.yardLocation,
                    single: true,
                  ),
                  SizedBox(height: 6.h),
                ],
                _GRow(
                  context.l10n.auction_id,
                  v.auctionId,
                  context.l10n.vehicle_id,
                  v.vehicleId,
                  single: true,
                ),
                SizedBox(height: 6.h),
                // Always-visible bid summary
                _GRow(
                  context.l10n.your_bid,
                  v.yourBid > 0 ? '₹ ${_fmt(v.yourBid)}' : '₹ 0',
                  context.l10n.aucHighestBid,
                  (v.currentHighestBid ?? 0) > 0
                      ? '₹ ${_fmt((v.currentHighestBid ?? 0))}'
                      : context.l10n.aucNoBids,
                ),
              ],
            ),
          ),

          // ════════════════════════════════════════════════
          // EXPANDED DETAILS
          // ════════════════════════════════════════════════
          if (_expanded)
            Padding(
              padding: EdgeInsets.fromLTRB(12.w, 6.h, 12.w, 0),
              child: Column(
                children: [
                  _OptRow(
                    context.l10n.rc_availability,
                    v.rcAvailability,
                    context.l10n.repo_date,
                    v.repoDate,
                  ),
                  _OptRow(
                    context.l10n.chassis_no,
                    v.chassisNo,
                    context.l10n.engine_no,
                    v.engineNo,
                  ),
                  _OptRow(
                    context.l10n.registered_rto,
                    v.registeredRto,
                    context.l10n.transmission,
                    v.transmission,
                  ),
                  _OptRow(
                    context.l10n.variant,
                    v.variant,
                    context.l10n.colour,
                    v.colour,
                  ),
                  _OptRow(
                    context.l10n.fuel_type,
                    v.fuelType,
                    context.l10n.owner,
                    v.owner,
                  ),
                  _OptRow(
                    context.l10n.aucContactPerson,
                    v.contactPersonName,
                    context.l10n.aucMobile,
                    v.contactPersonNumber,
                  ),
                  _OptRow(
                    context.l10n.start_price,
                    '₹ ${_fmt(v.minimumPrice)}',
                    context.l10n.market_value,
                    v.marketValue.isNotEmpty ? '₹ ${v.marketValue}' : '',
                  ),
                  _OptRow(
                    context.l10n.parking_charges,
                    v.parkingCharges,
                    context.l10n.transaction_fees,
                    v.transactionFees,
                  ),
                  _OptRow(
                    context.l10n.aucBankName,
                    v.displayBankName,
                    '',
                    '',
                  ),
                  _OptRow(
                    context.l10n.yard_name,
                    v.yardName,
                    context.l10n.yard_location,
                    v.yardLocation,
                  ),
                  if (v.remarks.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(bottom: 6.h),
                      child: _GCell(
                        label: context.l10n.remarks,
                        value: v.remarks,
                      ),
                    ),
                  // Bid placed + count info
                  SizedBox(height: 4.h),
                  _GRow(
                    context.l10n.aucBidsPlaced,
                    v.bidsReceived.toString(),
                    context.l10n.bids_left,
                    v.bidsLeft.toString(),
                  ),
                  SizedBox(height: 4.h),
                  if (v.availableBalance > 0)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.grey100,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              '${context.l10n.availableBuyingLimit}: ',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 12.sp,
                                color: AppColors.grey600,
                              ),
                            ),
                          ),
                          Text(
                            '₹ ${_fmt(v.availableBalance)}',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(height: 4.h),
                ],
              ),
            ),

          // ════════════════════════════════════════════════
          // Details / See Less toggle
          // ════════════════════════════════════════════════
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            child: GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Row(
                children: [
                  Expanded(
                    child: Divider(color: AppColors.grey300, thickness: 1),
                  ),
                  SizedBox(width: 8.w),
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            _expanded
                                ? context.l10n.aucSeeLess
                                : context.l10n.aucDetails,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.grey700,
                            ),
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Icon(
                          _expanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          size: 16.r,
                          color: AppColors.grey700,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Divider(color: AppColors.grey300, thickness: 1),
                  ),
                ],
              ),
            ),
          ),

          // Auto-bid switch (watchlist only, while the auction is open)
          if (widget.watchlist != null && !isClosed)
            _AutoBidRow(vehicle: v, controller: widget.watchlist!),

          // ════════════════════════════════════════════════
          // BID ROW (active) or CLOSED bar
          // ════════════════════════════════════════════════
          Padding(
            padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
            child: isClosed
                ? Container(
                    width: double.infinity,
                    constraints: BoxConstraints(minHeight: 42.h),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.grey200,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      context.l10n.auctionClosed,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                        fontSize: 13.sp,
                        color: AppColors.grey600,
                      ),
                    ),
                  )
                : Row(
                    children: [
                      // [- ₹ amount +]
                      Expanded(
                        child: Container(
                          height: 42.h,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.grey300),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Row(
                            children: [
                              SizedBox(width: 4.w),
                              GestureDetector(
                                onTap: _decrease,
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  width: 30.r,
                                  height: 30.h,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.grey400,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.remove_rounded,
                                    size: 18.r,
                                    color: AppColors.grey700,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: _bidCtrl,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  onChanged: (raw) {
                                    final parsed = int.tryParse(
                                      raw.replaceAll(',', ''),
                                    );
                                    if (parsed != null) _bidAmount = parsed;
                                  },
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.black,
                                  ),
                                  decoration: InputDecoration(
                                    prefixText: '₹  ',
                                    prefixStyle: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.black,
                                    ),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: _increase,
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  width: 30.r,
                                  height: 30.h,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.grey400,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.add_rounded,
                                    size: 18.r,
                                    color: AppColors.grey700,
                                  ),
                                ),
                              ),
                              SizedBox(width: 4.w),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      // PLACE BID
                      Flexible(
                        child: GestureDetector(
                          onTap: _isPlacing ? null : _placeBid,
                          child: Container(
                            constraints: BoxConstraints(minHeight: 42.h),
                            padding: EdgeInsets.symmetric(horizontal: 18.w),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: _isPlacing
                                    ? [
                                        const Color(0xFFAA5555),
                                        const Color(0xFF884444),
                                      ]
                                    : [
                                        AppColors.ctaGradientStart,
                                        AppColors.ctaGradientEnd,
                                      ],
                              ),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            alignment: Alignment.center,
                            child: _isPlacing
                                ? SizedBox(
                                    width: 16.r,
                                    height: 16.r,
                                    child: const CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      context.l10n.placeBid.toUpperCase(),
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),

          // View Details button
          Padding(
            padding: EdgeInsets.only(left: 12.w, right: 12.w, bottom: 12.h),
            child: GestureDetector(
              onTap: () =>
                  Get.to(() => MyWishlistDetailView(vehicle: widget.vehicle)),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Text(
                  context.l10n.aucViewFullDetails,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12.sp,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Grid helpers (2-col row)
// ─────────────────────────────────────────────────────────────────────────────

class _GRow extends StatelessWidget {
  final String l1, v1, l2, v2;
  final bool single;
  const _GRow(this.l1, this.v1, this.l2, this.v2, {this.single = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _GCell(label: l1, value: v1, singleLine: single),
        ),
        SizedBox(width: 6.w),
        if (l2.isNotEmpty)
          Expanded(
            child: _GCell(label: l2, value: v2, singleLine: single),
          )
        else
          const Expanded(child: SizedBox()),
      ],
    );
  }
}

// Optional row — hidden if both values are blank/zero
class _OptRow extends StatelessWidget {
  final String l1, v1, l2, v2;
  const _OptRow(this.l1, this.v1, this.l2, this.v2);

  static bool _empty(String v) {
    final t = v.trim();
    return t.isEmpty ||
        t == '—' ||
        t == '-' ||
        t == '0' ||
        t == '0.0' ||
        t == '0.00';
  }

  @override
  Widget build(BuildContext context) {
    if (_empty(v1) && (l2.isEmpty || _empty(v2)))
      return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        children: [
          if (!_empty(v1))
            Expanded(
              child: _GCell(label: l1, value: v1),
            )
          else
            const Expanded(child: SizedBox()),
          SizedBox(width: 6.w),
          if (l2.isNotEmpty && !_empty(v2))
            Expanded(
              child: _GCell(label: l2, value: v2),
            )
          else
            const Expanded(child: SizedBox()),
        ],
      ),
    );
  }
}

class _GCell extends StatelessWidget {
  final String label;
  final String value;
  final bool singleLine;
  const _GCell({
    required this.label,
    required this.value,
    this.singleLine = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 9.sp,
              color: AppColors.grey500,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            value.isNotEmpty ? value : '—',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.grey800,
            ),
            maxLines: singleLine ? 1 : 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty / Error states
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80.r,
              height: 80.r,
              decoration: BoxDecoration(
                color: AppColors.grey50,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.grey200),
              ),
              child: Icon(icon, color: AppColors.grey400, size: 38.r),
            ),
            SizedBox(height: 16.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 13.sp,
                color: AppColors.grey500,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: AppColors.primary, size: 48.r),
            SizedBox(height: 12.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 13.sp,
                color: AppColors.grey500,
              ),
            ),
            SizedBox(height: 16.h),
            GradientButton.filled(text: context.l10n.retry, onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}
