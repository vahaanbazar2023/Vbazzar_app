import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_spacing.dart';

/// Shell-tab layout: same red gradient header as [AppLayout] but with
/// **no bottom navigation bar** — the shell scaffold provides it.
///
/// Use this for screens that are embedded as tabs in [MainShellScreen]
/// (e.g. Subscriptions, Rewards, Settings).
///
/// Parameters mirror [AppLayout]:
/// - [title]        — white title text in the red header
/// - [subtitle]     — smaller white text below the title
/// - [body]         — content placed in the white rounded body
/// - [actions]      — optional icon widgets in the header top-right
/// - [showBack]     — whether to show the gradient back button (default false
///                    for shell tabs; set true when pushed as a route)
/// - [onBack]       — override the back action (defaults to Navigator.pop)
/// - [headerExtra]  — widget rendered at the bottom of the red header
///                    (e.g. a TabBar)
/// - [bodyColor]    — background of the white body (defaults to white)
class ShellLayout extends StatelessWidget {
  final String title;
  final String? subtitle;
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        // No bottomNavigationBar — provided by the shell
        body: Stack(
          children: [
            // ── Red gradient header (fixed height) ───────────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _ShellHeader(
                title: title,
                subtitle: subtitle,
                showBack: showBack,
                onBack: onBack,
                actions: actions,
              ),
            ),
            // ── White rounded body — overlaps the bottom of the header ────
            Positioned.fill(
              child: _ShellBody(
                bodyColor: bodyColor,
                headerExtra: headerExtra,
                child: body,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Red gradient header — exact copy of AppLayout's header
// ─────────────────────────────────────────────────────────────────────────────

class _ShellHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showBack;
  final VoidCallback? onBack;
  final List<Widget>? actions;

  const _ShellHeader({
    required this.title,
    this.subtitle,
    required this.showBack,
    this.onBack,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      height: 120.h + topPad,
      padding: EdgeInsets.only(left: 36.w, right: 20.w, bottom: AppSpacing.lg),
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
          // Back button + title row + optional subtitle
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
                  padding: EdgeInsets.only(left: showBack ? 36.w : 0),
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
        ],
      ),
    );
  }
}

/// White rounded body — places headerExtra (e.g. TabBar) at the top
class _ShellBody extends StatelessWidget {
  final Color? bodyColor;
  final Widget? headerExtra;
  final Widget child;
  const _ShellBody({this.bodyColor, this.headerExtra, required this.child});

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final headerHeight = 120.h + topPad;
    final bodyTop = headerHeight - AppRadius.xxl;

    return Column(
      children: [
        SizedBox(height: bodyTop),
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
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                if (headerExtra != null) headerExtra!,
                Expanded(child: child),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
