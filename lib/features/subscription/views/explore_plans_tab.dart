import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../models/user_subscription.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Explore Plans tab — static card per subscription type
// Tapping a card navigates to SubscriptionScreen with the relevant SUBT code
// ─────────────────────────────────────────────────────────────────────────────

class ExplorePlansTab extends StatelessWidget {
  const ExplorePlansTab({super.key});

  static const _plans = [
    _ExplorePlanItem(
      typeCode: SubscriptionTypeCode.auction,
      title: 'Auction Access Plan',
      description: 'Unlock unlimited access to live auctions',
      iconAsset: AppAssets.subIconKing,
      routeTitle: 'Auction Access Plan',
    ),
    _ExplorePlanItem(
      typeCode: SubscriptionTypeCode.auctionBidLimit,
      title: 'Auction Bid Limit',
      description: 'Increase your bidding limit to place higher bids',
      iconAsset: AppAssets.subIconShield,
      routeTitle: 'Bid Limit Plan',
    ),
    _ExplorePlanItem(
      typeCode: SubscriptionTypeCode.ownerContact,
      title: 'Owner Contact Plan',
      description: 'Connect directly with vehicle owners',
      iconAsset: AppAssets.subIconOwnerPack,
      routeTitle: 'Owner Contact Plan',
    ),
    _ExplorePlanItem(
      typeCode: SubscriptionTypeCode.vehicleDetailsAccess,
      title: 'Vehicle Details Plan',
      description: 'Unlock complete vehicle history & details',
      iconAsset: AppAssets.subIconVehicle,
      routeTitle: 'Vehicle Details Plan',
    ),
    _ExplorePlanItem(
      typeCode: SubscriptionTypeCode.vehicleInspection,
      title: 'Inspection Plan',
      description: 'Request professional vehicle inspection',
      iconAsset: AppAssets.subIconInspection,
      routeTitle: 'Inspection Plan',
    ),
    _ExplorePlanItem(
      typeCode: SubscriptionTypeCode.mechanicContact,
      title: 'Mechanic Contact Plan',
      description: 'Connect with certified mechanics near you',
      iconAsset: AppAssets.subIconMechanic,
      routeTitle: 'Mechanic Contact Plan',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
      itemCount: _plans.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (_, i) => _ExploreCard(item: _plans[i]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Data model
// ─────────────────────────────────────────────────────────────────────────────

class _ExplorePlanItem {
  final String typeCode;
  final String title;
  final String description;
  final String iconAsset;
  final String routeTitle;

  const _ExplorePlanItem({
    required this.typeCode,
    required this.title,
    required this.description,
    required this.iconAsset,
    required this.routeTitle,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Explore card — white, red border, icon + name + description + arrow
// ─────────────────────────────────────────────────────────────────────────────

class _ExploreCard extends StatelessWidget {
  final _ExplorePlanItem item;
  const _ExploreCard({required this.item});

  void _onTap() {
    Get.toNamed(
      AppRoutes.subscription,
      arguments: {
        'subscription_source': item.typeCode,
        'title': item.routeTitle,
        'subtitle': item.description,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.primary, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon — rounded square, pink bg
            Container(
              width: 52.r,
              height: 52.r,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0F0),
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.all(10.r),
              child: Image.asset(item.iconAsset, fit: BoxFit.contain),
            ),
            SizedBox(width: 14.w),
            // Name + description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                      color: AppColors.black,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    item.description,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 11.sp,
                      color: AppColors.grey500,
                      height: 1.4,
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            SizedBox(width: 10.w),
            // Arrow
            Container(
              width: 32.r,
              height: 32.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.ctaGradientStart,
                    AppColors.ctaGradientEnd,
                  ],
                ),
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white,
                size: 14.r,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
