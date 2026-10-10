import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/design_system/organisms/app_header.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../routes/app_routes.dart';
import '../../../core/design_system/organisms/app_bottom_nav_bar.dart';
import '../../main_shell/controllers/main_shell_controller.dart';
import '../controllers/profile_controller.dart';
import '../models/profile_models.dart';
import '../../buy_and_sell/views/my_vehicles_view.dart';
import '../../buy_and_sell/views/subscribed_vehicles_view.dart';
import '../../buy_and_sell/controllers/sell_vehicle_controller.dart';
import '../../buy_and_sell/controllers/vehicle_detail_controller.dart';
import '../../buy_and_sell/data/repositories/buy_sell_repository_impl.dart';

/// Back from Profile always lands on the Categories tab.
///
/// Profile can be shown as a bottom-nav tab (nothing to pop) or pushed as its
/// own route (e.g. from the Home avatar). In both cases we make sure the shell
/// shows Categories and that no stray route is left on top of it. We never pop
/// the shell itself, which would leave a black screen.
void _goToCategories(BuildContext context) {
  if (Get.isRegistered<MainShellController>()) {
    Get.find<MainShellController>().changePage(BottomNavTab.categories.index);
  }
  if (Navigator.of(context).canPop()) {
    Get.until((route) => route.isFirst);
  }
}

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Profile exists both as a shell tab and as a pushed route. Popping the
    // pushed route disposes the controller its binding created, which would
    // leave the (still mounted) shell tab without one. Re-create on demand.
    if (!Get.isRegistered<ProfileController>()) {
      Get.put(ProfileController());
    }
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF6F5),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final profile = controller.profileData.value;

          return _ProfilePage(profile: profile, controller: controller);
        }),
      ),
    );
  }
}

// ============================================================================
// PROFILE PAGE
// ============================================================================

class _ProfilePage extends StatelessWidget {
  final ProfileData? profile;
  final ProfileController controller;

  const _ProfilePage({required this.profile, required this.controller});

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ── AppHeader ────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Column(
            children: [
              SizedBox(height: topPad),
              AppHeader(title: context.l10n.profile, showBack: false),
            ],
          ),
        ),

        // ── Hero: identity + floating stats ──────────────────────────
        SliverToBoxAdapter(
          child: _ProfileHero(profile: profile, controller: controller),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _section(context, context.l10n.profMyAccount, [
                  _Item(
                    iconAsset: AppAssets.subIconAuction,
                    iconBg: const Color(0xFFFFE3E1),
                    label: context.l10n.manageProfile,
                    subtitle: context.l10n.profUpdatePersonalInfo,
                    onTap: () => controller.openManageProfile(),
                  ),

                  _Item(
                    iconAsset: AppAssets.subIconSubscriptions,
                    iconBg: const Color(0xFFE3EBFF),
                    chipColor: const Color(0xFF4C6EF5),
                    label: context.l10n.my_subscriptions_title,
                    subtitle: context.l10n.profViewManagePlans,
                    onTap: () => Get.toNamed(AppRoutes.mySubscriptions),
                  ),

                  _Item(
                    iconAsset: AppAssets.subIconGroup1,
                    iconBg: const Color(0xFFDDF5E0),
                    label: context.l10n.language,
                    subtitle: context.l10n.profChoosePreferredLanguage,
                    onTap: () => Get.toNamed(
                      AppRoutes.languageSelection,
                      arguments: {'fromProfile': true},
                    ),
                  ),
                ]),

                SizedBox(height: 14.h),

                _section(context, context.l10n.auction, [
                  _Item(
                    iconAsset: AppAssets.subIconStar,
                    iconBg: const Color(0xFFFFEFC2),
                    label: context.l10n.myWins,
                    subtitle: context.l10n.profViewItemsWon,
                    onTap: () => Get.toNamed(AppRoutes.myWins),
                  ),

                  _Item(
                    iconAsset: AppAssets.subIconBidLimit,
                    iconBg: const Color(0xFFE3EBFF),
                    label: context.l10n.myBids,
                    subtitle: context.l10n.profTrackBids,
                    onTap: () => Get.toNamed(AppRoutes.myBids),
                  ),

                  _Item(
                    iconData: Icons.favorite_rounded,
                    iconBg: const Color(0xFFFFE1E1),
                    label: context.l10n.profWishlist,
                    subtitle: context.l10n.profAuctionVehiclesSaved,
                    onTap: () => Get.toNamed(AppRoutes.myWishlist),
                  ),

                  _Item(
                    iconAsset: AppAssets.subIconPending,
                    iconBg: const Color(0xFFFFE1E1),
                    label: context.l10n.initiateRefund,
                    subtitle: context.l10n.profRequestRefund,
                    onTap: () => Get.toNamed(AppRoutes.initiateRefund),
                  ),
                ]),

                SizedBox(height: 14.h),

                _section(context, context.l10n.profBuyAndSell, [
                  _Item(
                    iconAsset: AppAssets.subIconVehicle,
                    iconBg: const Color(0xFFE3EBFF),
                    label: context.l10n.myVehicles,
                    subtitle: context.l10n.profManageListedVehicles,
                    onTap: () => Get.to(
                      () => const MyVehiclesView(),
                      binding: BindingsBuilder(() {
                        if (!Get.isRegistered<SellVehicleController>()) {
                          Get.put(
                            SellVehicleController(
                              repository: BuySellRepositoryImpl(),
                            ),
                          );
                        }
                      }),
                    ),
                  ),

                  _Item(
                    iconAsset: AppAssets.subIconWallet,
                    iconBg: const Color(0xFFFFEFC2),
                    label: context.l10n.profWishlist,
                    subtitle: context.l10n.profItemsSaved,
                    onTap: () => Get.to(
                      () => const SubscribedVehiclesView(),
                      binding: BindingsBuilder(() {
                        if (!Get.isRegistered<BuyVehicleController>()) {
                          Get.put(
                            BuyVehicleController(
                              repository: BuySellRepositoryImpl(),
                            ),
                          );
                        }
                      }),
                    ),
                  ),

                  _Item(
                    iconAsset: AppAssets.subIconGroup2,
                    iconBg: const Color(0xFFDDF5E0),
                    label: context.l10n.spareSubscribedVehicles,
                    subtitle: context.l10n.spareVehiclesWithPremiumAccess,
                    onTap: () => Get.to(
                      () => const SubscribedVehiclesView(),
                      binding: BindingsBuilder(() {
                        if (!Get.isRegistered<BuyVehicleController>()) {
                          Get.put(
                            BuyVehicleController(
                              repository: BuySellRepositoryImpl(),
                            ),
                          );
                        }
                      }),
                    ),
                  ),
                ]),

                SizedBox(height: 16.h),

                _LogoutButton(controller: controller),

                SizedBox(height: 8.h),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------------------------
  // Bottom floating navigation visual
  //
  // No existing navigation functionality is changed here.
  // --------------------------------------------------------------------
}

Widget _section(BuildContext context, String title, List<_Item> items) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: EdgeInsets.only(left: 2.w, bottom: 8.h),
        child: Row(
          children: [
            Container(
              width: 4.w,
              height: 16.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2.r),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.ctaGradientStart,
                    AppColors.ctaGradientEnd,
                  ],
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),

      for (int i = 0; i < items.length; i++) ...[
        _ItemTile(item: items[i]),
        if (i != items.length - 1) SizedBox(height: 8.h),
      ],
    ],
  );
}

// ============================================================================
// PROFILE HEADER
// ============================================================================

class _ProfileHero extends StatelessWidget {
  final ProfileData? profile;
  final ProfileController controller;

  const _ProfileHero({required this.profile, required this.controller});

  @override
  Widget build(BuildContext context) {
    final hasUsername = profile?.username.isNotEmpty == true;
    final hasPhone = profile?.phoneNumber.isNotEmpty == true;

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            // ── Brand gradient surface ──────────────────────────────
            Container(
              width: double.infinity,
              margin: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.ctaGradientStart,
                    AppColors.ctaGradientEnd,
                  ],
                ),
                borderRadius: BorderRadius.circular(26.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.30),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 58.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // ── Avatar with ring ────────────────────────
                        Container(
                          padding: EdgeInsets.all(3.r),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.25),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.6),
                              width: 1.5,
                            ),
                          ),
                          child: ClipOval(
                            child: Container(
                              color: Colors.white,
                              child: Image.asset(
                                'assets/images/png/Boy_avatar.png',
                                width: 54.r,
                                height: 54.r,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 14.w),
                        // ── Identity ───────────────────────────────
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      profile?.fullName ??
                                          context.l10n.profUser,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 5.w),
                                  Icon(
                                    Icons.verified_rounded,
                                    color: const Color(0xFFFFD700),
                                    size: 17.r,
                                  ),
                                ],
                              ),
                              if (hasUsername) ...[
                                SizedBox(height: 3.h),
                                Text(
                                  '@${profile!.username}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 12.sp,
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                                ),
                              ],

                              Row(
                                children: [
                                  if (hasPhone) ...[
                                    SizedBox(height: 2.h),
                                    Text(
                                      profile!.phoneNumber,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 12.sp,
                                        color: Colors.white.withValues(
                                          alpha: 0.8,
                                        ),
                                      ),
                                    ),
                                  ],
                                  Spacer(),
                                  _Badge(
                                    icon: Icons.workspace_premium_rounded,
                                    label: _memberLabel(
                                      context,
                                      profile?.userType ?? '',
                                    ),
                                    iconColor: const Color(0xFFFFD700),
                                  ),
                                ],
                              ),

                              SizedBox(height: 8.h),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // ── Edit ───────────────────────────────────────
                  Positioned(
                    top: 12.h,
                    right: 12.w,
                    child: GestureDetector(
                      onTap: () => controller.openManageProfile(),
                      child: Container(
                        width: 32.r,
                        height: 32.r,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Icon(
                          Icons.edit_rounded,
                          size: 15.r,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Floating stats panel overlapping the hero ───────────
            Positioned(
              left: 32.w,
              right: 32.w,
              bottom: -44.h,
              child: _StatsCard(),
            ),
          ],
        ),
        SizedBox(height: 52.h),
      ],
    );
  }
}

// class _ProfileHeader extends StatelessWidget {
//   final ProfileData? profile;
//   final ProfileController controller;

//   const _ProfileHeader({required this.profile, required this.controller});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: [Color(0xFF9E1111), Color(0xFF750606)],
//         ),
//         borderRadius: BorderRadius.only(
//           bottomLeft: Radius.circular(52.r),
//           bottomRight: Radius.circular(52.r),
//         ),
//       ),
//       child: SafeArea(
//         bottom: false,
//         child: Padding(
//           padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 52.h),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // --------------------------------------------------------------
//               // Header title
//               // --------------------------------------------------------------
//               Text(
//                 context.l10n.profile,
//                 style: TextStyle(
//                   fontFamily: 'Montserrat',
//                   fontSize: 21.sp,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.white,
//                 ),
//               ),

//               SizedBox(height: 12.h),

//               // --------------------------------------------------------------
//               // Profile information
//               // --------------------------------------------------------------
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _ProfileAvatar(),

//                   SizedBox(width: 14.w),

//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             Expanded(
//                               child: Text(
//                                 'Hi, ${profile?.fullName ?? 'User'} 👋',
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                                 style: TextStyle(
//                                   fontFamily: 'Montserrat',
//                                   fontSize: 17.sp,
//                                   fontWeight: FontWeight.w600,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),

//                         if (profile?.username.isNotEmpty == true) ...[
//                           SizedBox(height: 4.h),
//                           Text(
//                             '@${profile!.username}',
//                             style: TextStyle(
//                               fontFamily: 'Montserrat',
//                               fontSize: 12.sp,
//                               color: Colors.white70,
//                             ),
//                           ),
//                         ],

//                         if (profile?.phoneNumber.isNotEmpty == true) ...[
//                           SizedBox(height: 3.h),
//                           Text(
//                             profile!.phoneNumber,
//                             style: TextStyle(
//                               fontFamily: 'Montserrat',
//                               fontSize: 12.sp,
//                               color: Colors.white70,
//                             ),
//                           ),
//                         ],

//                         SizedBox(height: 10.h),

//                       ],
//                     ),
//                   ),

//                   SizedBox(width: 8.w),

//                   GestureDetector(
//                     behavior: HitTestBehavior.opaque,
//                     onTap: () => controller.openManageProfile(),
//                     child: Container(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: 11.w,
//                         vertical: 4.h,
//                       ),
//                       decoration: BoxDecoration(e
//                         color: Colors.white.withValues(alpha: 0.14),
//                         borderRadius: BorderRadius.circular(22.r),
//                         border: Border.all(color: Colors.white38, width: 1),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Icon(
//                             Icons.edit_rounded,
//                             color: Colors.white,
//                             size: 13.r,
//                           ),
//                           SizedBox(width: 5.w),
//                           Text(
//                             'Edit',
//                             style: TextStyle(
//                               fontFamily: 'Montserrat',
//                               fontSize: 11.sp,
//                               fontWeight: FontWeight.w600,
//                               color: Colors.white,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),

//               Padding(
//                 padding: const EdgeInsets.only(left: 88),
//                 child: Row(

//                             children: [
//                               _Badge(
//                                 icon: Icons.verified_rounded,
//                                 label: 'Verified',
//                                 iconColor: Colors.white,
//                               ),
//                               SizedBox(width: 8.w,),
//                               _Badge(
//                                 icon: Icons.star_rounded,
//                                 label: _memberLabel(profile?.userType ?? ''),
//                                 iconColor: const Color(0xFFFFD700),
//                               ),
//                             ],
//                           ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

String _memberLabel(BuildContext context, String type) {
  final l10n = context.l10n;
  switch (type.toUpperCase().trim()) {
    case 'CUSTOMER':
      return l10n.profCustomer;
    case 'VENDOR':
      return l10n.profVendor;
    case 'AGENT':
      return l10n.profAgent;
    case 'MECHANIC':
      return l10n.profMechanic;
    case '':
      return l10n.profPremiumMember;
    default:
      return type;
  }
}

// ============================================================================
// PROFILE AVATAR
// ============================================================================

class _ProfileAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 66.r,
      height: 66.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.18),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Icon(Icons.person_rounded, color: Colors.white, size: 34.r),
    );
  }
}

// ============================================================================
// BADGE
// ============================================================================

class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;

  const _Badge({
    required this.icon,
    required this.label,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.r, color: iconColor),
          SizedBox(width: 4.w),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// STATS CARD
// ============================================================================

class _StatsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget divider() =>
        Container(width: 1, height: 40.h, color: AppColors.grey100);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: _StatCell(
              iconAsset: AppAssets.subIconStar,
              value: '12',
              label: context.l10n.profTotalWins,
            ),
          ),
          divider(),
          Expanded(
            child: _StatCell(
              iconAsset: AppAssets.subIconVehicle,
              value: '3',
              label: context.l10n.profVehicles,
            ),
          ),
          divider(),
          Expanded(
            child: _StatCell(
              iconAsset: AppAssets.subIconBidLimit,
              value: '5',
              label: context.l10n.profActiveBids,
            ),
          ),
        ],
      ),
    );
  }
}

/// One stat: icon chip, big value, small label — all centred in an equal column.
class _StatCell extends StatelessWidget {
  final String iconAsset;
  final String value;
  final String label;

  const _StatCell({
    required this.iconAsset,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 30.r,
            height: 30.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.09),
            ),
            padding: EdgeInsets.all(6.r),
            child: Image.asset(iconAsset, fit: BoxFit.contain),
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            maxLines: 1,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w800,
              fontSize: 18.sp,
              height: 1.1,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            maxLines: 1,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 10.5.sp,
              color: AppColors.grey500,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// MENU ITEM MODEL
// ============================================================================

class _Item {
  final String? iconAsset;
  final IconData? iconData;
  final Color iconBg;

  /// Solid backdrop behind artwork that is itself white (e.g. the crown).
  final Color? chipColor;
  final String label;
  final String subtitle;
  final VoidCallback? onTap;

  const _Item({
    this.iconAsset,
    this.iconData,
    required this.iconBg,
    this.chipColor,
    required this.label,
    required this.subtitle,
    this.onTap,
  });
}

// ============================================================================
// MENU TILE
// ============================================================================

class _ItemTile extends StatelessWidget {
  final _Item item;

  const _ItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: item.iconBg,
      borderRadius: BorderRadius.circular(18.r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: item.onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          child: Row(
            children: [
              Container(
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  color: item.chipColor ?? Colors.white,
                  borderRadius: BorderRadius.circular(13.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.07),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(9.r),
                child: item.iconData != null
                    ? Icon(item.iconData, color: AppColors.primary)
                    : Image.asset(item.iconAsset!, fit: BoxFit.contain),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      item.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 11.sp,
                        color: AppColors.textPrimary.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                width: 26.r,
                height: 26.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 18.r,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// LOGOUT
// ============================================================================

class _LogoutButton extends StatelessWidget {
  final ProfileController controller;

  const _LogoutButton({required this.controller});

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Text(
            context.l10n.logout,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            context.l10n.areYouSureLogout,
            style: const TextStyle(fontFamily: 'Montserrat'),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                context.l10n.cancel,
                style: const TextStyle(
                  color: AppColors.grey500,
                  fontFamily: 'Montserrat',
                ),
              ),
            ),

            TextButton(
              onPressed: () {
                Get.back();
                controller.logout();
              },
              child: Text(
                context.l10n.logout,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GestureDetector(
        onTap: controller.isLoading.value
            ? null
            : () => _confirmLogout(context),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: const Color(0xFFFFE9E7),
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: const Color(0xFFFFCACA)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.035),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded, color: AppColors.primary, size: 18.r),

              SizedBox(width: 8.w),

              Flexible(
                child: Text(
                  context.l10n.logout,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// BOTTOM BAR
//
// Visual component only.
// Existing application navigation is intentionally untouched.
// ============================================================================

class _ProfileBottomBar extends StatelessWidget {
  const _ProfileBottomBar();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 14.w,
      right: 14.w,
      bottom: 12.h,
      child: SizedBox(
        height: 82.h,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF171717),
                  borderRadius: BorderRadius.circular(26.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 20,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 22.w),
                  child: Row(
                    children: [
                      _BottomIcon(icon: Icons.home_rounded, active: false),

                      const Spacer(),

                      _BottomIcon(
                        icon: Icons.workspace_premium_rounded,
                        active: false,
                      ),

                      const Spacer(),

                      _BottomIcon(icon: Icons.grid_view_rounded, active: false),

                      const Spacer(),

                      _BottomIcon(
                        icon: Icons.military_tech_rounded,
                        active: false,
                      ),

                      SizedBox(width: 60.w),
                    ],
                  ),
                ),
              ),
            ),

            // ---------------------------------------------------------------
            // Floating settings visual
            // ---------------------------------------------------------------
            Positioned(
              right: 18.w,
              top: -31.h,
              child: Column(
                children: [
                  Container(
                    width: 62.r,
                    height: 62.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFE51B1B),
                      border: Border.all(
                        color: const Color(0xFF171717),
                        width: 5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withValues(alpha: 0.35),
                          blurRadius: 18,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.settings_rounded,
                      color: Colors.white,
                      size: 28.r,
                    ),
                  ),

                  SizedBox(height: 3.h),

                  Text(
                    context.l10n.settings,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFE51B1B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomIcon extends StatelessWidget {
  final IconData icon;
  final bool active;

  const _BottomIcon({required this.icon, required this.active});

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      size: 26.r,
      color: active ? const Color(0xFFE51B1B) : Colors.white,
    );
  }
}
