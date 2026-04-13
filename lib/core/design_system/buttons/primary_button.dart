import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';

enum ButtonVariant { primary, secondary, outlined, text }

enum ButtonSize { small, medium, large }

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final ButtonVariant variant;
  final ButtonSize size;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final height = switch (size) {
      ButtonSize.small => AppSizes.buttonHeightSm,
      ButtonSize.medium => AppSizes.buttonHeight,
      ButtonSize.large => AppSizes.buttonHeightLg,
    };

    return SizedBox(
      height: height,
      width: isFullWidth ? double.infinity : null,
      child: switch (variant) {
        ButtonVariant.primary => _elevated(context),
        ButtonVariant.secondary => _elevated(context, bg: AppColors.secondary),
        ButtonVariant.outlined => _outlined(context),
        ButtonVariant.text => _textBtn(context),
      },
    );
  }

  Widget _child() => isLoading
      ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation(AppColors.white),
          ),
        )
      : Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (prefixIcon != null) ...[prefixIcon!, const SizedBox(width: 8)],
            Text(label),
            if (suffixIcon != null) ...[const SizedBox(width: 8), suffixIcon!],
          ],
        );

  ButtonStyle _baseStyle(Color bg, Color fg) => ElevatedButton.styleFrom(
    backgroundColor: bg,
    foregroundColor: fg,
    disabledBackgroundColor: bg.withOpacity(0.5),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
    ),
    elevation: AppSizes.elevationSm,
  );

  Widget _elevated(BuildContext ctx, {Color? bg}) => ElevatedButton(
    style: _baseStyle(bg ?? AppColors.primary, AppColors.white),
    onPressed: isLoading ? null : onPressed,
    child: _child(),
  );

  Widget _outlined(BuildContext ctx) => OutlinedButton(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      side: const BorderSide(color: AppColors.primary),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
    ),
    onPressed: isLoading ? null : onPressed,
    child: _child(),
  );

  Widget _textBtn(BuildContext ctx) => TextButton(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
    ),
    onPressed: isLoading ? null : onPressed,
    child: _child(),
  );
}
