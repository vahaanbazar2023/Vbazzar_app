import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/app_colors.dart';
import '../tokens/app_sizes.dart';
import '../tokens/app_spacing.dart';

/// Atomic component for dividers
/// Provides consistent divider styling
class AppDivider extends StatelessWidget {
  final double? thickness;
  final Color? color;
  final double? indent;
  final double? endIndent;
  final double? height;

  const AppDivider({
    super.key,
    this.thickness,
    this.color,
    this.indent,
    this.endIndent,
    this.height,
  });

  // ── Factory constructors for common variants ──────────────────

  /// Default divider (thin, standard color)
  factory AppDivider.thin({
    Key? key,
    Color? color,
    double? indent,
    double? endIndent,
  }) => AppDivider(
    key: key,
    thickness: AppSizes.dividerThickness,
    color: color ?? AppColors.divider,
    indent: indent,
    endIndent: endIndent,
  );

  /// Bold divider (thicker)
  factory AppDivider.bold({
    Key? key,
    Color? color,
    double? indent,
    double? endIndent,
  }) => AppDivider(
    key: key,
    thickness: AppSizes.dividerThicknessBold,
    color: color ?? AppColors.divider,
    indent: indent,
    endIndent: endIndent,
  );

  /// Divider with margin/padding
  factory AppDivider.spaced({Key? key, Color? color, double? thickness}) =>
      AppDivider(
        key: key,
        thickness: thickness ?? AppSizes.dividerThickness,
        color: color ?? AppColors.divider,
        indent: AppSpacing.md,
        endIndent: AppSpacing.md,
        height: AppSpacing.lg,
      );

  /// Primary colored divider
  factory AppDivider.primary({Key? key, double? thickness}) => AppDivider(
    key: key,
    thickness: thickness ?? AppSizes.dividerThickness,
    color: AppColors.primary,
  );

  @override
  Widget build(BuildContext context) {
    return Divider(
      thickness: thickness?.w ?? AppSizes.dividerThickness,
      color: color ?? AppColors.divider,
      indent: indent?.w,
      endIndent: endIndent?.w,
      height: height?.h,
    );
  }
}

/// Vertical divider component
class AppVerticalDivider extends StatelessWidget {
  final double? thickness;
  final Color? color;
  final double? indent;
  final double? endIndent;
  final double? width;

  const AppVerticalDivider({
    super.key,
    this.thickness,
    this.color,
    this.indent,
    this.endIndent,
    this.width,
  });

  factory AppVerticalDivider.thin({
    Key? key,
    Color? color,
    double? indent,
    double? endIndent,
  }) => AppVerticalDivider(
    key: key,
    thickness: AppSizes.dividerThickness,
    color: color ?? AppColors.divider,
    indent: indent,
    endIndent: endIndent,
  );

  @override
  Widget build(BuildContext context) {
    return VerticalDivider(
      thickness: thickness?.w ?? AppSizes.dividerThickness,
      color: color ?? AppColors.divider,
      indent: indent?.h,
      endIndent: endIndent?.h,
      width: width?.w,
    );
  }
}
