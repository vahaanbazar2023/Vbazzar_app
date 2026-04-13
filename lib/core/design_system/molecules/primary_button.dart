import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/app_colors.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_sizes.dart';
import '../tokens/app_spacing.dart';
import '../typography/app_text_styles.dart';

/// Primary button molecule component
/// Combines atoms (text, icon) with consistent styling
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final IconData? icon;
  final bool isIconRight;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.isIconRight = false,
    this.width,
    this.height,
    this.padding,
  });

  // ── Factory constructors for variants ─────────────────────────

  /// Large primary button
  factory PrimaryButton.large({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isDisabled = false,
    IconData? icon,
    bool isIconRight = false,
  }) => PrimaryButton(
    key: key,
    text: text,
    onPressed: onPressed,
    isLoading: isLoading,
    isDisabled: isDisabled,
    icon: icon,
    isIconRight: isIconRight,
    height: AppSizes.buttonLg,
  );

  /// Medium primary button (default)
  factory PrimaryButton.medium({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isDisabled = false,
    IconData? icon,
    bool isIconRight = false,
  }) => PrimaryButton(
    key: key,
    text: text,
    onPressed: onPressed,
    isLoading: isLoading,
    isDisabled: isDisabled,
    icon: icon,
    isIconRight: isIconRight,
    height: AppSizes.buttonMd,
  );

  /// Small primary button
  factory PrimaryButton.small({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isDisabled = false,
    IconData? icon,
    bool isIconRight = false,
  }) => PrimaryButton(
    key: key,
    text: text,
    onPressed: onPressed,
    isLoading: isLoading,
    isDisabled: isDisabled,
    icon: icon,
    isIconRight: isIconRight,
    height: AppSizes.buttonSm,
  );

  @override
  Widget build(BuildContext context) {
    final bool disabled = isDisabled || isLoading || onPressed == null;

    return SizedBox(
      width: width?.w,
      height: (height ?? AppSizes.buttonMd).h,
      child: ElevatedButton(
        onPressed: disabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.grey300,
          foregroundColor: AppColors.white,
          elevation: 2,
          shadowColor: AppColors.primary.withOpacity(0.3),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusMd),
          padding:
              padding ??
              EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
        ),
        child: isLoading
            ? SizedBox(
                width: AppSizes.iconSm,
                height: AppSizes.iconSm,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.white,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null && !isIconRight) ...[
                    Icon(icon, size: AppSizes.iconSm),
                    SizedBox(width: AppSpacing.sm),
                  ],
                  Text(text, style: AppTextStyles.buttonMedium),
                  if (icon != null && isIconRight) ...[
                    SizedBox(width: AppSpacing.sm),
                    Icon(icon, size: AppSizes.iconSm),
                  ],
                ],
              ),
      ),
    );
  }
}

/// Secondary button (outlined variant)
class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final IconData? icon;
  final bool isIconRight;
  final double? width;
  final double? height;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.isIconRight = false,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final bool disabled = isDisabled || isLoading || onPressed == null;

    return SizedBox(
      width: width?.w,
      height: (height ?? AppSizes.buttonMd).h,
      child: OutlinedButton(
        onPressed: disabled ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          disabledForegroundColor: AppColors.grey400,
          side: BorderSide(
            color: disabled ? AppColors.grey300 : AppColors.primary,
            width: AppSizes.borderWidthMedium,
          ),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusMd),
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: AppSizes.iconSm,
                height: AppSizes.iconSm,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null && !isIconRight) ...[
                    Icon(icon, size: AppSizes.iconSm),
                    SizedBox(width: AppSpacing.sm),
                  ],
                  Text(
                    text,
                    style: AppTextStyles.buttonMedium.copyWith(
                      color: disabled ? AppColors.grey400 : AppColors.primary,
                    ),
                  ),
                  if (icon != null && isIconRight) ...[
                    SizedBox(width: AppSpacing.sm),
                    Icon(icon, size: AppSizes.iconSm),
                  ],
                ],
              ),
      ),
    );
  }
}

/// App text button (minimal variant)
class AppTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isDisabled;
  final IconData? icon;
  final bool isIconRight;

  const AppTextButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isDisabled = false,
    this.icon,
    this.isIconRight = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool disabled = isDisabled || onPressed == null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: disabled ? null : onPressed,
        borderRadius: AppRadius.borderRadiusSm,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null && !isIconRight) ...[
                Icon(
                  icon,
                  size: AppSizes.iconSm,
                  color: disabled ? AppColors.grey400 : AppColors.primary,
                ),
                SizedBox(width: AppSpacing.xs),
              ],
              Text(
                text,
                style: AppTextStyles.buttonSmall.copyWith(
                  color: disabled ? AppColors.grey400 : AppColors.primary,
                ),
              ),
              if (icon != null && isIconRight) ...[
                SizedBox(width: AppSpacing.xs),
                Icon(
                  icon,
                  size: AppSizes.iconSm,
                  color: disabled ? AppColors.grey400 : AppColors.primary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
