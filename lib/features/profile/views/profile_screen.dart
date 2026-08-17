import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../routes/app_routes.dart';
import '../controllers/profile_controller.dart';
import '../models/profile_models.dart';
import '../../buy_and_sell/views/my_vehicles_view.dart';
import '../../buy_and_sell/views/subscribed_vehicles_view.dart';
import '../../buy_and_sell/controllers/sell_vehicle_controller.dart';
import '../../buy_and_sell/controllers/vehicle_detail_controller.dart';
import '../../buy_and_sell/data/repositories/buy_sell_repository_impl.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),
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
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ============================================================
        // HEADER + OVERLAPPING STATS
        // ============================================================
        SliverToBoxAdapter(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // RED HEADER
              _ProfileHeader(profile: profile, controller: controller),

              // STATS CARD OVERLAPPING THE HEADER
              Positioned(
                left: 16.w,
                right: 16.w,
                bottom: -20.h,
                child: _StatsCard(),
              ),
            ],
          ),
        ),

        // ============================================================
        // SPACE RESERVED FOR OVERLAPPING STATS CARD
        // ============================================================

        // ============================================================
        // BODY
        // ============================================================
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 40.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _section(context, 'My Account', [
                  _Item(
                    iconAsset: AppAssets.subIconAuction,
                    iconBg: const Color(0xFFFFEEEE),
                    label: context.l10n.manageProfile,
                    subtitle: 'Update your personal information',
                    onTap: () => controller.openManageProfile(),
                  ),

                  _Item(
                    iconAsset: AppAssets.subIconSubscriptions,
                    iconBg: const Color(0xFFEEF4FF),
                    label: context.l10n.my_subscriptions_title,
                    subtitle: 'View and manage your plans',
                    onTap: () => Get.toNamed(AppRoutes.mySubscriptions),
                  ),

                  _Item(
                    iconAsset: AppAssets.subIconGroup1,
                    iconBg: const Color(0xFFF0FFF0),
                    label: context.l10n.language,
                    subtitle: 'Choose your preferred language',
                    onTap: () => Get.toNamed(
                      AppRoutes.languageSelection,
                      arguments: {'fromProfile': true},
                    ),
                  ),
                ]),

                SizedBox(height: 22.h),

                _section(context, 'Auction Activity', [
                  _Item(
                    iconAsset: AppAssets.subIconStar,
                    iconBg: const Color(0xFFFFF8E0),
                    label: context.l10n.myWins,
                    subtitle: 'View items you have won',
                    onTap: () => Get.toNamed(AppRoutes.myWins),
                  ),

                  _Item(
                    iconAsset: AppAssets.subIconBidLimit,
                    iconBg: const Color(0xFFEEF4FF),
                    label: context.l10n.myBids,
                    subtitle: 'Track your active and past bids',
                    onTap: () => Get.toNamed(AppRoutes.myBids),
                  ),

                  _Item(
                    iconAsset: AppAssets.subIconPending,
                    iconBg: const Color(0xFFFFF0F0),
                    label: context.l10n.initiateRefund,
                    subtitle: 'Request a refund for your orders',
                    onTap: () => Get.toNamed(AppRoutes.initiateRefund),
                  ),
                ]),

                SizedBox(height: 22.h),

                _section(context, 'Marketplace', [
                  _Item(
                    iconAsset: AppAssets.subIconVehicle,
                    iconBg: const Color(0xFFEEF4FF),
                    label: context.l10n.myVehicles,
                    subtitle: 'Manage your listed vehicles',
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
                    iconBg: const Color(0xFFFFF8E0),
                    label: 'Wishlist',
                    subtitle: 'Items you have saved',
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
                    iconBg: const Color(0xFFF0FFF0),
                    label: 'Purchase History',
                    subtitle: 'View your past purchases',
                    onTap: () => Get.toNamed(AppRoutes.spareOrders),
                  ),
                ]),

                SizedBox(height: 28.h),

                _LogoutButton(controller: controller),

                SizedBox(height: 30.h),
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
        padding: EdgeInsets.only(left: 2.w, bottom: 10.h),
        child: Text(
          title,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),

      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.035),
              blurRadius: 18,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: List.generate(items.length, (index) {
            return Column(
              children: [
                _ItemTile(item: items[index]),
                if (index != items.length - 1)
                  Padding(
                    padding: EdgeInsets.only(left: 70.w),
                    child: Divider(
                      height: 1,
                      thickness: 0.8,
                      color: AppColors.grey100,
                    ),
                  ),
              ],
            );
          }),
        ),
      ),
    ],
  );
}

// ============================================================================
// PROFILE HEADER
// ============================================================================

class _ProfileHeader extends StatelessWidget {
  final ProfileData? profile;
  final ProfileController controller;

  const _ProfileHeader({
    required this.profile,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(52.r),
        bottomRight: Radius.circular(52.r),
      ),
      child: Stack(
        children: [
          // ============================================================
          // CUSTOM DECORATIVE BACKGROUND
          // ============================================================

          Positioned.fill(
            child: CustomPaint(
              painter: _ProfileBackgroundPainter(),
            ),
          ),

          // ============================================================
          // YOUR EXISTING CONTENT
          // ============================================================

          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                16.w,
                12.h,
                16.w,
                52.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.profile,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 21.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),

                  SizedBox(height: 12.h),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       _ProfileAvatar(),

                      SizedBox(width: 14.w),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hi, ${profile?.fullName ?? 'User'} 👋',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),

                            if (profile?.username.isNotEmpty ==
                                true) ...[
                              SizedBox(height: 4.h),
                              Text(
                                '@${profile!.username}',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 12.sp,
                                  color: Colors.white70,
                                ),
                              ),
                            ],

                            if (profile?.phoneNumber.isNotEmpty ==
                                true) ...[
                              SizedBox(height: 3.h),
                              Text(
                                profile!.phoneNumber,
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 12.sp,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      SizedBox(width: 8.w),

                      GestureDetector(
                        onTap: () =>
                            controller.openManageProfile(),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 11.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(
                              alpha: 0.10,
                            ),
                            borderRadius:
                                BorderRadius.circular(22.r),
                            border: Border.all(
                              color: Colors.white38,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.edit_rounded,
                                color: Colors.white,
                                size: 13.r,
                              ),
                              SizedBox(width: 5.w),
                              Text(
                                'Edit',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 11.sp,
                                  fontWeight:
                                      FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  Padding(
                    padding: EdgeInsets.only(left: 80.w),
                    child: Row(
                      children: [
                        _Badge(
                          icon: Icons.verified_rounded,
                          label: 'Verified',
                          iconColor: Colors.white,
                        ),
                        SizedBox(width: 8.w),
                        _Badge(
                          icon: Icons.star_rounded,
                          label: _memberLabel(
                            profile?.userType ?? '',
                          ),
                          iconColor:
                              const Color(0xFFFFD700),
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
    );
  }

  String _memberLabel(String type) {
    switch (type.toUpperCase()) {
      case 'VENDOR':
      case 'AGENT':
        return 'Agent';
      default:
        return 'Premium Member';
    }
  }
}
class _ProfileBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // ================================================================
    // 1. BASE RED
    // ================================================================

    final basePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF970707);

    canvas.drawRect(
      Offset.zero & size,
      basePaint,
    );

    // ================================================================
    // 2. DARK RED LARGE WAVE
    // ================================================================

    final darkWave = Path();

    darkWave.moveTo(0, h * 0.53);

    darkWave.cubicTo(
      w * 0.13,
      h * 0.64,
      w * 0.28,
      h * 0.69,
      w * 0.43,
      h * 0.64,
    );

    darkWave.cubicTo(
      w * 0.62,
      h * 0.58,
      w * 0.77,
      h * 0.61,
      w,
      h * 0.48,
    );

    darkWave.lineTo(w, h);
    darkWave.lineTo(0, h);
    darkWave.close();

    final darkWavePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF760505);

    canvas.drawPath(
      darkWave,
      darkWavePaint,
    );

    // ================================================================
    // 3. BRIGHT RED WAVE
    // ================================================================

    final brightWave = Path();

    brightWave.moveTo(0, h * 0.61);

    brightWave.cubicTo(
      w * 0.15,
      h * 0.73,
      w * 0.30,
      h * 0.76,
      w * 0.46,
      h * 0.69,
    );

    brightWave.cubicTo(
      w * 0.63,
      h * 0.62,
      w * 0.78,
      h * 0.66,
      w,
      h * 0.53,
    );

    brightWave.lineTo(w, h);
    brightWave.lineTo(0, h);
    brightWave.close();

    final brightPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFFE31313);

    canvas.drawPath(
      brightWave,
      brightPaint,
    );

    // ================================================================
    // 4. SECOND DARK WAVE
    // ================================================================

    final secondWave = Path();

    secondWave.moveTo(0, h * 0.57);

    secondWave.cubicTo(
      w * 0.18,
      h * 0.69,
      w * 0.34,
      h * 0.72,
      w * 0.51,
      h * 0.65,
    );

    secondWave.cubicTo(
      w * 0.68,
      h * 0.58,
      w * 0.83,
      h * 0.60,
      w,
      h * 0.51,
    );

    final secondWavePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0xFFB70B0B);

    canvas.drawPath(
      secondWave,
      secondWavePaint,
    );

    // ================================================================
    // 5. FLOWING CURVES
    // ================================================================

    for (int i = 0; i < 10; i++) {
      final path = Path();

      final double startY =
          h * 0.53 + (i * 5.0);

      final double endY =
          h * 0.18 + (i * 4.0);

      path.moveTo(
        w * 0.34,
        startY,
      );

      path.cubicTo(
        w * 0.88,
        h * 0.60 - i * 2,
        w * 0.62,
        h * 0.31 + i * 1.5,
        w * 0.82,
        endY,
      );

      path.cubicTo(
        w * 0.91,
        endY - 5,
        w * 0.96,
        endY + 2,
        w,
        endY - 4,
      );

      final curvePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..color = const Color(0xFFE62A2A)
            .withValues(alpha: 0.20);

      canvas.drawPath(
        path,
        curvePaint,
      );
    }

    // ================================================================
    // 6. MORE SUBTLE CURVES
    // ================================================================

    for (int i = 0; i < 5; i++) {
      final path = Path();

      path.moveTo(
        w * 0.48,
        h * 0.97 + i * 5,
      );

      path.cubicTo(
        w * 0.62,
        h * 0.32 + i * 3,
        w * 0.76,
        h * 0.28 + i * 3,
        w * 0.96,
        h * 0.20 + i * 4,
      );

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = Colors.red.withValues(
          alpha: 0.16,
        );

      canvas.drawPath(
        path,
        paint,
      );
    }

    // ================================================================
    // 7. RIGHT-SIDE DOT PATTERN
    // ================================================================

    final dotPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFFFF3B3B)
          .withValues(alpha: 0.20);

    const int rows = 13;
    const int columns = 13;

    for (int row = 0; row < rows; row++) {
      for (int column = 0;
          column < columns;
          column++) {
        final double x =
            w * 0.78 + column * 7.0;

        final double y =
            h * 0.18 + row * 7.0;

        // Fade dots toward the edges
        final double distance =
            ((column - 5).abs() +
                (row - 5).abs()) /
            12;

        final double opacity =
            (0.22 * (1 - distance))
                .clamp(0.02, 0.22);

        final paint = Paint()
          ..color = const Color(0xFFFF4A4A)
              .withValues(alpha: opacity);

        canvas.drawCircle(
          Offset(x, y),
          1.0,
          paint,
        );
      }
    }

    // ================================================================
    // 8. SMALL DECORATIVE ARC
    // ================================================================

    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = const Color(0xFFE92828)
          .withValues(alpha: 0.22);

    final arcRect = Rect.fromLTWH(
      w * 0.58,
      h * 0.13,
      w * 0.52,
      h * 0.38,
    );

    canvas.drawArc(
      arcRect,
      6.25,
      2.3,
      false,
      arcPaint,
    );

    // ================================================================
    // 9. SOFT HIGHLIGHT CURVE
    // ================================================================

    final highlightPath = Path();

    highlightPath.moveTo(
      w * 0.50,
      h * 0.49,
    );

    highlightPath.cubicTo(
      w * 0.64,
      h * 0.61,
      w * 0.78,
      h * 0.59,
      w,
      h * 0.17,
    );

    final highlightPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..color = const Color(0xFFFF4545)
          .withValues(alpha: 0.17);

    canvas.drawPath(
      highlightPath,
      highlightPaint,
    );
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return false;
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
//                   fontWeight: FontWeight.w700,
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
//                                   fontWeight: FontWeight.w700,
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
//                       decoration: BoxDecoration(
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

  String _memberLabel(String type) {
    switch (type.toUpperCase()) {
      case 'VENDOR':
      case 'AGENT':
        return 'Agent';

      default:
        return 'Premium Member';
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
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: Colors.white30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.r, color: iconColor),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
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
    return Container(
      width: double.infinity,
    
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withValues(alpha: 0.07),
        //     blurRadius: 18,
        //     offset: const Offset(0, 7),
        //   ),
        // ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatCell(
              iconAsset: AppAssets.subIconStar,
              value: '12',
              label: 'Total Wins',
            ),
          ),

          VerticalDivider(width: 1, thickness: 1, color: AppColors.grey100),

          Expanded(
            child: _StatCell(
              iconAsset: AppAssets.subIconVehicle,
              value: '3',
              label: 'Vehicles',
            ),
          ),

          VerticalDivider(width: 1, thickness: 1, color: AppColors.grey100),

          Expanded(
            child: _StatCell(
              iconAsset: AppAssets.subIconBidLimit,
              value: '5',
              label: 'Active Bids',
            ),
          ),
        ],
      ),
    );
  }
}

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
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
      child: Column(
        children: [
          Row(
            children: [
              Container(
              width: 32.r,
                              height: 32.r,
                              decoration:  BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.lightOrange.withOpacity(0.5)
                              ),
                padding: EdgeInsets.all(7.r),
                child: Image.asset(iconAsset, fit: BoxFit.contain),
              ),
SizedBox(width: 8.w,),
               Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w700,
                  fontSize: 14.sp,
                  color: AppColors.black,
                ),
              ),

               SizedBox(height: 3.h),

          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 10.5.sp,
              color: AppColors.grey500,
            ),
          ),
            ],
          ),
            ],
          ),

          SizedBox(height: 2.h),

         

         
        ],
      ),
    );
  }
}

// ============================================================================
// MENU ITEM MODEL
// ============================================================================

class _Item {
  final String iconAsset;
  final Color iconBg;
  final String label;
  final String subtitle;
  final VoidCallback? onTap;

  const _Item({
    required this.iconAsset,
    required this.iconBg,
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
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 14.h),
          child: Row(
            children: [
              Container(
                width: 46.r,
                height: 46.r,
                decoration: BoxDecoration(
                  color: item.iconBg,
                  borderRadius: BorderRadius.circular(13.r),
                ),
                padding: EdgeInsets.all(10.r),
                child: Image.asset(item.iconAsset, fit: BoxFit.contain),
              ),

              SizedBox(width: 13.w),

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
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    SizedBox(height: 4.h),

                    Text(
                      item.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 11.sp,
                        color: AppColors.grey500,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 8.w),

              Icon(
                Icons.chevron_right_rounded,
                size: 21.r,
                color: AppColors.grey400,
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
              fontWeight: FontWeight.w700,
            ),
          ),
          content: const Text(
            'Are you sure you want to log out?',
            style: TextStyle(fontFamily: 'Montserrat'),
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
                  fontWeight: FontWeight.w700,
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
          padding: EdgeInsets.symmetric(vertical: 15.h),
          decoration: BoxDecoration(
            color: Colors.white,
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

              Text(
                context.l10n.logout,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w700,
                  fontSize: 14.sp,
                  color: AppColors.primary,
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
                    'Settings',
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
