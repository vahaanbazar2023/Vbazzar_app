import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../organisms/app_header.dart';

/// Shell-tab layout: same [AppHeader] decorative header but with
/// **no bottom navigation bar** — the shell scaffold provides it.
///
/// Use for screens embedded as tabs in [MainShellScreen]
/// (Subscriptions, Rewards, Settings).
class ShellLayout extends StatelessWidget {
  final String title;
  final String? subtitle; // kept for API compat, not rendered
  final Widget body;
  final List<Widget>? actions;
  final bool showBack;
  final VoidCallback? onBack;
  final Widget? headerExtra;
  final Color? bodyColor;

  const ShellLayout({
    super.key,
    required this.title,
    this.subtitle,
    required this.body,
    this.actions,
    this.showBack = false,
    this.onBack,
    this.headerExtra,
    this.bodyColor,
  });

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: bodyColor ?? Colors.white,
        // No bottomNavigationBar — provided by the shell
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
}
