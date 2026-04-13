import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../constants/app_assets.dart';
import '../../constants/app_colors.dart';
import '../atoms/app_svg_icon.dart';
import '../organisms/app_bottom_nav_bar.dart';
import '../tokens/app_radius.dart';
import '../../../features/main_shell/controllers/main_shell_controller.dart';
import '../../../routes/app_routes.dart';
import '../tokens/app_spacing.dart';

/// Main app layout: red gradient header + white rounded body + bottom navigation.
///
/// Use this for any top-level feature screen that is accessed via [Get.toNamed]
/// but still wants the bottom nav visible (auction, subscriptions, etc.).
///
/// The bottom nav is wired to [MainShellController] so switching tabs works
/// exactly as in the main shell.
///
/// Example:
/// ```dart
/// AppLayout(
///   title: 'Auction Zone',
///   body: MyContent(),
/// )
/// ```
class AppLayout extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget body;
  final List<Widget>? actions;
  final bool showBack;
  final VoidCallback? onBack;

  /// Extra widget rendered inside the red header, below the title row.
  /// Useful for tab bars or search fields.
  final Widget? headerExtra;

  const AppLayout({
    super.key,
    required this.title,
    this.subtitle,
    required this.body,
    this.actions,
    this.showBack = true,
    this.onBack,
    this.headerExtra,
  });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        // backgroundColor: const Color(0xFFD41F1F),
        bottomNavigationBar: GetBuilder<MainShellController>(
          builder: (ctrl) => AppBottomNavBar(
            currentTab: BottomNavTab.values[ctrl.currentIndex.value],
            onTabSelected: (tab) {
              ctrl.changePage(tab.index);
              Get.until((route) => route.settings.name == AppRoutes.home);
            },
          ),
        ),
        body: Column(
          children: [
            _AppLayoutHeader(
              title: title,
              subtitle: subtitle,
              showBack: showBack,
              onBack: onBack,
              actions: actions,
              headerExtra: headerExtra,
            ),
            Expanded(
              child: Transform.translate(
                offset: Offset(0, -AppRadius.xxl),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(AppRadius.xxl),
                      topRight: Radius.circular(AppRadius.xxl),
                    ),
                  ),
                  child: body,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppLayoutHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showBack;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final Widget? headerExtra;

  const _AppLayoutHeader({
    required this.title,
    this.subtitle,
    required this.showBack,
    this.onBack,
    this.actions,
    this.headerExtra,
  });

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      height: 120.h + topPad,
      padding: EdgeInsets.only(
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        bottom: AppSpacing.lg,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.authHeaderGradientStart,
            AppColors.authHeaderGradientEnd,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox.shrink(),
          // Back button + title in a Row, subtitle below
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  if (showBack)
                    GestureDetector(
                      onTap: onBack ?? () => Navigator.of(context).pop(),
                      child: Padding(
                        padding: EdgeInsets.only(right: AppSpacing.sm),
                        child: AppSvgIcon(
                          assetPath: AppAssets.arrowBack,
                          color: Colors.white,
                          size: 10.w,
                          semanticLabel: 'Back',
                        ),
                      ),
                    ),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  if (actions != null) ...actions!,
                ],
              ),
              if (subtitle != null) ...[
                SizedBox(height: AppSpacing.xs),
                Padding(
                  padding: EdgeInsets.only(left: AppSpacing.lg),
                  child: Text(
                    subtitle!,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.white,
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.md),
              ],
            ],
          ),
          if (headerExtra != null) headerExtra!,
        ],
      ),
    );
  }
}
