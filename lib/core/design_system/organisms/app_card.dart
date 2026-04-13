import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/app_colors.dart';
import '../atoms/app_text.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_sizes.dart';

/// App card organism
/// Reusable card component with consistent styling
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final double? elevation;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.elevation,
    this.onTap,
    this.borderRadius,
  });

  factory AppCard.elevated({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
  }) => AppCard(
    key: key,
    padding: padding,
    margin: margin,
    elevation: 4,
    onTap: onTap,
    child: child,
  );

  factory AppCard.outlined({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
  }) => AppCard(
    key: key,
    padding: padding,
    margin: margin,
    elevation: 0,
    onTap: onTap,
    child: child,
  );

  @override
  Widget build(BuildContext context) {
    Widget cardContent = Container(
      padding: padding ?? EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        borderRadius: borderRadius ?? AppRadius.borderRadiusMd,
        border: elevation == 0
            ? Border.all(
                color: AppColors.border,
                width: AppSizes.borderWidthThin,
              )
            : null,
        boxShadow: elevation != null && elevation! > 0
            ? [
                BoxShadow(
                  color: AppColors.black.withOpacity(0.08),
                  blurRadius: elevation! * 2,
                  offset: Offset(0, elevation! / 2),
                ),
              ]
            : null,
      ),
      child: child,
    );

    if (onTap != null) {
      cardContent = InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? AppRadius.borderRadiusMd,
        child: cardContent,
      );
    }

    return Container(margin: margin, child: cardContent);
  }
}

/// Info card with icon and text
class InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? iconColor;
  final VoidCallback? onTap;

  const InfoCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: (iconColor ?? AppColors.primary).withOpacity(0.1),
              borderRadius: AppRadius.borderRadiusMd,
            ),
            child: Icon(
              icon,
              color: iconColor ?? AppColors.primary,
              size: AppSizes.iconMd,
            ),
          ),

          SizedBox(width: AppSpacing.md),

          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.bodyLarge(title, color: AppColors.textPrimary),
                if (subtitle != null) ...[
                  SizedBox(height: AppSpacing.xs),
                  AppText.caption(subtitle!, color: AppColors.textSecondary),
                ],
              ],
            ),
          ),

          // Arrow
          if (onTap != null)
            Icon(
              Icons.chevron_right,
              color: AppColors.grey400,
              size: AppSizes.iconMd,
            ),
        ],
      ),
    );
  }
}

/// Stat card for displaying metrics
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? color;
  final String? trend;
  final bool isTrendPositive;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.color,
    this.trend,
    this.isTrendPositive = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard.elevated(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon and trend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (icon != null)
                Icon(
                  icon,
                  color: color ?? AppColors.primary,
                  size: AppSizes.iconMd,
                ),
              if (trend != null)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color:
                        (isTrendPositive ? AppColors.success : AppColors.error)
                            .withOpacity(0.1),
                    borderRadius: AppRadius.borderRadiusSm,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isTrendPositive
                            ? Icons.trending_up
                            : Icons.trending_down,
                        size: AppSizes.iconXs,
                        color: isTrendPositive
                            ? AppColors.success
                            : AppColors.error,
                      ),
                      SizedBox(width: AppSpacing.xs),
                      AppText.caption(
                        trend!,
                        color: isTrendPositive
                            ? AppColors.success
                            : AppColors.error,
                      ),
                    ],
                  ),
                ),
            ],
          ),

          SizedBox(height: AppSpacing.md),

          // Value
          AppText.headingLarge(value, color: color ?? AppColors.textPrimary),

          SizedBox(height: AppSpacing.xs),

          // Label
          AppText.caption(label, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}
