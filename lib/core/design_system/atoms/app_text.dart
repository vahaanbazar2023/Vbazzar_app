import 'package:flutter/material.dart';
import '../typography/app_text_styles.dart';

/// Atomic component for text rendering
/// Wraps Flutter's Text widget with design system styles
class AppText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;
  final Color? color;

  const AppText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.color,
  });

  // ── Factory constructors for common text styles ──────────────

  /// Heading XL text
  factory AppText.headingXLarge(
    String text, {
    Key? key,
    Color? color,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) => AppText(
    text,
    key: key,
    style: AppTextStyles.headingXLarge,
    color: color,
    textAlign: textAlign,
    maxLines: maxLines,
    overflow: overflow,
  );

  /// Heading Large text
  factory AppText.headingLarge(
    String text, {
    Key? key,
    Color? color,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) => AppText(
    text,
    key: key,
    style: AppTextStyles.headingLarge,
    color: color,
    textAlign: textAlign,
    maxLines: maxLines,
    overflow: overflow,
  );

  /// Heading Medium text
  factory AppText.headingMedium(
    String text, {
    Key? key,
    Color? color,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) => AppText(
    text,
    key: key,
    style: AppTextStyles.headingMedium,
    color: color,
    textAlign: textAlign,
    maxLines: maxLines,
    overflow: overflow,
  );

  /// Heading Small text
  factory AppText.headingSmall(
    String text, {
    Key? key,
    Color? color,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) => AppText(
    text,
    key: key,
    style: AppTextStyles.headingSmall,
    color: color,
    textAlign: textAlign,
    maxLines: maxLines,
    overflow: overflow,
  );

  /// Heading XSmall text
  factory AppText.headingXSmall(
    String text, {
    Key? key,
    Color? color,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) => AppText(
    text,
    key: key,
    style: AppTextStyles.headingXSmall,
    color: color,
    textAlign: textAlign,
    maxLines: maxLines,
    overflow: overflow,
  );

  /// Body Large text
  factory AppText.bodyLarge(
    String text, {
    Key? key,
    Color? color,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) => AppText(
    text,
    key: key,
    style: AppTextStyles.bodyLarge,
    color: color,
    textAlign: textAlign,
    maxLines: maxLines,
    overflow: overflow,
  );

  /// Body Medium text
  factory AppText.bodyMedium(
    String text, {
    Key? key,
    Color? color,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) => AppText(
    text,
    key: key,
    style: AppTextStyles.bodyMedium,
    color: color,
    textAlign: textAlign,
    maxLines: maxLines,
    overflow: overflow,
  );

  /// Body Small text
  factory AppText.bodySmall(
    String text, {
    Key? key,
    Color? color,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) => AppText(
    text,
    key: key,
    style: AppTextStyles.bodySmall,
    color: color,
    textAlign: textAlign,
    maxLines: maxLines,
    overflow: overflow,
  );

  /// Caption text
  factory AppText.caption(
    String text, {
    Key? key,
    Color? color,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) => AppText(
    text,
    key: key,
    style: AppTextStyles.caption,
    color: color,
    textAlign: textAlign,
    maxLines: maxLines,
    overflow: overflow,
  );

  /// Label text
  factory AppText.label(
    String text, {
    Key? key,
    Color? color,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) => AppText(
    text,
    key: key,
    style: AppTextStyles.labelMedium,
    color: color,
    textAlign: textAlign,
    maxLines: maxLines,
    overflow: overflow,
  );

  /// Button text
  factory AppText.button(
    String text, {
    Key? key,
    Color? color,
    TextAlign? textAlign,
  }) => AppText(
    text,
    key: key,
    style: AppTextStyles.buttonMedium,
    color: color,
    textAlign: textAlign,
  );

  /// Link text
  factory AppText.link(
    String text, {
    Key? key,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) => AppText(
    text,
    key: key,
    style: AppTextStyles.link,
    textAlign: textAlign,
    maxLines: maxLines,
    overflow: overflow,
  );

  /// Error text
  factory AppText.error(
    String text, {
    Key? key,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) => AppText(
    text,
    key: key,
    style: AppTextStyles.error,
    textAlign: textAlign,
    maxLines: maxLines,
    overflow: overflow,
  );

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: color != null ? style?.copyWith(color: color) : style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
    );
  }
}
