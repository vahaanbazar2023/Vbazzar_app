import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Custom gradient text widget
///
/// Creates text with a gradient color effect using ShaderMask
/// Default gradient: linear-gradient(200.97deg, #BB2625 8.99%, #67100B 77.71%)
///
/// Usage:
/// ```dart
/// GradientText(
///   'Hello World',
///   style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
/// )
/// ```
class GradientText extends StatelessWidget {
  /// The text to display with gradient
  final String text;

  /// Text style (font size, weight, etc.)
  final TextStyle? style;

  /// Custom gradient colors (defaults to primary gradient)
  final List<Color>? gradientColors;

  /// Gradient begin alignment (defaults to match 200.97deg angle)
  final Alignment? begin;

  /// Gradient end alignment (defaults to match 200.97deg angle)
  final Alignment? end;

  /// Text alignment
  final TextAlign? textAlign;

  /// Maximum number of lines
  final int? maxLines;

  /// Text overflow behavior
  final TextOverflow? overflow;

  const GradientText(
    this.text, {
    super.key,
    this.style,
    this.gradientColors,
    this.begin,
    this.end,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  // Default gradient colors: #BB2625 to #67100B
  static const List<Color> _defaultGradientColors = [
    AppColors.ctaGradientStart,
    AppColors.ctaGradientEnd,
  ];

  // Default gradient angle: 200.97deg converted to alignment values
  static const Alignment _defaultBegin = Alignment(0.35, -0.94);
  static const Alignment _defaultEnd = Alignment(-0.35, 0.94);

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => LinearGradient(
        colors: gradientColors ?? _defaultGradientColors,
        begin: begin ?? _defaultBegin,
        end: end ?? _defaultEnd,
      ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
      child: Text(
        text,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      ),
    );
  }
}

/// Rich text with gradient support
///
/// Allows mixing regular text with gradient text spans
class GradientRichText extends StatelessWidget {
  /// List of text spans (regular or gradient)
  final List<InlineSpan> children;

  /// Base text style
  final TextStyle? style;

  /// Text alignment
  final TextAlign? textAlign;

  /// Maximum number of lines
  final int? maxLines;

  /// Text overflow behavior
  final TextOverflow? overflow;

  const GradientRichText({
    super.key,
    required this.children,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(style: style, children: children),
      textAlign: textAlign ?? TextAlign.start,
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.clip,
    );
  }
}

/// Widget span with gradient text for use in RichText
class GradientTextSpan extends WidgetSpan {
  GradientTextSpan({
    required String text,
    TextStyle? style,
    List<Color>? gradientColors,
    Alignment? begin,
    Alignment? end,
  }) : super(
         child: GradientText(
           text,
           style: style,
           gradientColors: gradientColors,
           begin: begin,
           end: end,
         ),
       );
}

/// Pre-configured gradient text with Montserrat font
class GradientTextMontserrat extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const GradientTextMontserrat(
    this.text, {
    super.key,
    required this.fontSize,
    this.fontWeight = FontWeight.w600,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return GradientText(
      text,
      style: TextStyle(
        fontFamily: 'Montserrat',
        fontSize: fontSize.sp,
        fontWeight: fontWeight,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
