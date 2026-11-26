import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../molecules/collapsible_section.dart';
import '../organisms/app_bottom_nav_bar.dart';
import '../organisms/app_header.dart';
import '../../../features/main_shell/controllers/main_shell_controller.dart';

/// Main app layout: white body with [AppHeader] at the top.
class AppLayout extends StatelessWidget {
  final String title;
  final String? subtitle; // kept for API compat, not rendered
  final Widget body;
  final List<Widget>? actions;
  final bool showBack;
  final VoidCallback? onBack;
  final Color? bodyColor;
  final Widget? headerExtra;
  final Widget? floatingActionButton;

  /// When true the bottom nav slides away (e.g. while a list is scrolling).
  final RxBool? hideBottomNav;

  /// False drops the bottom nav from this screen entirely (vehicle listing
  /// screens). Pair it with [listBottomPadding] so the last card clears the
  /// home indicator and the floating menu button.
  final bool showBottomNav;

  /// Bottom padding for a scrolling list on a screen without the bottom nav:
  /// the safe-area inset plus room for the round floating menu button
  /// (bottom: [fabBottom], about 56 tall), so the last item can scroll fully
  /// into view above it.
  static double listBottomPadding(BuildContext context) =>
      MediaQuery.paddingOf(context).bottom + fabBottom + 72;

  /// Distance of a floating menu button from the bottom on a screen without
  /// the bottom nav, above the home indicator.
  static const double fabBottom = 16;

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
    this.floatingActionButton,
    this.hideBottomNav,
    this.showBottomNav = true,
  });

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: bodyColor ?? Colors.white,
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: showBottomNav ? _bottomNav() : null,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: topPad),
            AppHeader(
              title: title,
              showBack: showBack,
              onBack: onBack,
              actions: actions,
            ),
            if (headerExtra != null) headerExtra!,
            Expanded(
              child: Container(color: bodyColor ?? Colors.white, child: body),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomNav() {
    final nav = GetBuilder<MainShellController>(
      builder: (ctrl) => AppBottomNavBar(
        currentTab: BottomNavTab.values[ctrl.currentIndex.value],
        onTabSelected: (tab) => ctrl.onTabTapped(tab.index),
      ),
    );
    final hide = hideBottomNav;
    if (hide == null) return nav;
    return Obx(
      () =>
          CollapsibleSection(hidden: hide.value, overflowTop: true, child: nav),
    );
  }
}
