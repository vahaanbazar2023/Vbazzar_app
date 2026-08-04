import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../constants/app_colors.dart';
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
  final Color? bodyColor;

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
    this.bodyColor,
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
        body: Stack(
          children: [
            // ── Red header (fixed height) ────────────────────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _AppLayoutHeader(
                title: title,
                subtitle: subtitle,
                showBack: showBack,
                onBack: onBack,
                actions: actions,
                headerExtra: headerExtra,
              ),
            ),
            // ── White body — overlaps the bottom of the header ───────────
            // Using SafeArea + top padding so the body starts just below the
            // header visually. The rounded top corners sit over the header.
            Positioned.fill(
              child: _AppLayoutBody(bodyColor: bodyColor, child: body),
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
                        child: Container(
                          width: 28.r,
                          height: 28.r,
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
                            border: Border.all(
                              color: const Color(0xFFD41F1F),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Icons.chevron_left_rounded,
                            color: Colors.white,
                            size: 20.r,
                          ),
                        ),
                      ),
                    ),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 18.sp,
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
                  padding: EdgeInsets.only(left: 36.w),
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

/// White rounded body that sits below the red header.
/// Positioned with a top padding that equals the header height minus the
/// rounded-corner overlap so the corners visually sit over the header.
class _AppLayoutBody extends StatelessWidget {
  final Color? bodyColor;
  final Widget child;

  const _AppLayoutBody({this.bodyColor, required this.child});

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    // Header height minus the overlap (AppRadius.xxl) so the white card
    // peeks up behind the header's rounded bottom edge.
    final headerHeight = 120.h + topPad;
    final bodyTop = headerHeight - AppRadius.xxl;

    return Column(
      children: [
        // Transparent spacer — sits behind the header
        SizedBox(height: bodyTop),
        // White rounded body — fills the rest of the screen
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: bodyColor ?? Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppRadius.xxl),
                topRight: Radius.circular(AppRadius.xxl),
              ),
            ),
            // clipBehavior clips child content to the rounded corners
            clipBehavior: Clip.antiAlias,
            child: child,
          ),
        ),
      ],
    );
  }
}
