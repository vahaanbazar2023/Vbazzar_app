import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../tokens/app_spacing.dart';

/// Standalone decorative header — decorative image strip with back button,
/// title and optional actions overlaid on top.
///
/// Tabs or any extra content should be placed BELOW this widget in the
/// parent Column, not inside it.
///
/// Usage:
/// ```dart
/// AppHeader(title: 'Auction Zone')
/// AppHeader(title: 'Buy & Sell', showBack: false)
/// ```
class AppHeader extends StatelessWidget {
  final String title;
  final bool showBack;
  final VoidCallback? onBack;
  final List<Widget>? actions;

  const AppHeader({
    super.key,
    required this.title,
    this.showBack = true,
    this.onBack,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 72.h,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── Decorative background image ──────────────────────────────
          Positioned.fill(
            child: Image.asset(
              'assets/images/png/Top_header_bar.png',
              fit: BoxFit.cover,
              alignment: Alignment.centerRight,
            ),
          ),

          // ── Title row ────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Row(
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
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (actions != null) ...actions!,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
