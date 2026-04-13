import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/app_colors.dart';
import '../tokens/app_sizes.dart';

/// Atomic component for icons
/// Provides consistent icon sizing and coloring
class AppIcon extends StatelessWidget {
  final IconData icon;
  final double? size;
  final Color? color;

  const AppIcon(this.icon, {super.key, this.size, this.color});

  // ── Factory constructors for common sizes ────────────────────

  /// Extra small icon (16pt)
  factory AppIcon.xs(IconData icon, {Key? key, Color? color}) =>
      AppIcon(icon, key: key, size: AppSizes.iconXs, color: color);

  /// Small icon (20pt)
  factory AppIcon.sm(IconData icon, {Key? key, Color? color}) =>
      AppIcon(icon, key: key, size: AppSizes.iconSm, color: color);

  /// Medium icon (24pt) - Default
  factory AppIcon.md(IconData icon, {Key? key, Color? color}) =>
      AppIcon(icon, key: key, size: AppSizes.iconMd, color: color);

  /// Large icon (32pt)
  factory AppIcon.lg(IconData icon, {Key? key, Color? color}) =>
      AppIcon(icon, key: key, size: AppSizes.iconLg, color: color);

  /// Extra large icon (48pt)
  factory AppIcon.xl(IconData icon, {Key? key, Color? color}) =>
      AppIcon(icon, key: key, size: AppSizes.iconXl, color: color);

  /// 2X large icon (64pt)
  factory AppIcon.xxl(IconData icon, {Key? key, Color? color}) =>
      AppIcon(icon, key: key, size: AppSizes.iconXxl, color: color);

  // ── Colored variants ──────────────────────────────────────────

  /// Primary colored icon
  factory AppIcon.primary(IconData icon, {Key? key, double? size}) =>
      AppIcon(icon, key: key, size: size, color: AppColors.primary);

  /// Secondary colored icon
  factory AppIcon.secondary(IconData icon, {Key? key, double? size}) =>
      AppIcon(icon, key: key, size: size, color: AppColors.secondary);

  /// White icon
  factory AppIcon.white(IconData icon, {Key? key, double? size}) =>
      AppIcon(icon, key: key, size: size, color: AppColors.white);

  /// Grey icon
  factory AppIcon.grey(IconData icon, {Key? key, double? size}) =>
      AppIcon(icon, key: key, size: size, color: AppColors.grey500);

  /// Success colored icon
  factory AppIcon.success(IconData icon, {Key? key, double? size}) =>
      AppIcon(icon, key: key, size: size, color: AppColors.success);

  /// Error colored icon
  factory AppIcon.error(IconData icon, {Key? key, double? size}) =>
      AppIcon(icon, key: key, size: size, color: AppColors.error);

  /// Warning colored icon
  factory AppIcon.warning(IconData icon, {Key? key, double? size}) =>
      AppIcon(icon, key: key, size: size, color: AppColors.warning);

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      size: size?.w ?? AppSizes.iconMd,
      color: color ?? AppColors.textPrimary,
    );
  }
}
