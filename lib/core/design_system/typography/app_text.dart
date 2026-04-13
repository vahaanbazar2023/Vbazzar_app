import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

enum AppTextVariant {
  displayLg,
  displaySm,
  headingXl,
  headingLg,
  headingMd,
  headingSm,
  bodyLg,
  bodyMd,
  bodySm,
  labelLg,
  labelMd,
  labelSm,
  caption,
  overline,
}

class AppText extends StatelessWidget {
  final String text;
  final AppTextVariant variant;
  final Color? color;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;
  final double? letterSpacing;

  const AppText(
    this.text, {
    super.key,
    this.variant = AppTextVariant.bodyMd,
    this.color,
    this.fontWeight,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.letterSpacing,
  });

  @override
  Widget build(BuildContext context) {
    final base = _resolve(context);
    return Text(
      text,
      style: base?.copyWith(
        color: color,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
    );
  }

  TextStyle? _resolve(BuildContext ctx) {
    final tt = Theme.of(ctx).textTheme;
    return switch (variant) {
      AppTextVariant.displayLg => tt.displayLarge,
      AppTextVariant.displaySm => tt.displaySmall,
      AppTextVariant.headingXl => tt.headlineLarge,
      AppTextVariant.headingLg => tt.headlineMedium,
      AppTextVariant.headingMd => tt.headlineSmall,
      AppTextVariant.headingSm => tt.titleLarge,
      AppTextVariant.bodyLg => tt.bodyLarge,
      AppTextVariant.bodyMd => tt.bodyMedium,
      AppTextVariant.bodySm => tt.bodySmall,
      AppTextVariant.labelLg => tt.labelLarge,
      AppTextVariant.labelMd => tt.labelMedium,
      AppTextVariant.labelSm => tt.labelSmall,
      AppTextVariant.caption => tt.bodySmall?.copyWith(
        color: AppColors.textSecondary,
      ),
      AppTextVariant.overline => tt.labelSmall?.copyWith(letterSpacing: 1.2),
    };
  }
}
