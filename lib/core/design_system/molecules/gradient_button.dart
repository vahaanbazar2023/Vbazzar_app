import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/app_colors.dart';
import '../atoms/gradient_text.dart';

/// Custom gradient button for the entire project
///
/// Supports two states:
/// - Outlined: White background with gradient border
/// - Filled: Gradient background (active state)
class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isFilled;
  final double? width;
  final double? height;
  final double? fontSize;
  final FontWeight? fontWeight;
  final bool isLoading;
  final Color? backgroundColor;

  const GradientButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isFilled = false,
    this.width,
    this.height,
    this.fontSize,
    this.fontWeight,
    this.isLoading = false,
    this.backgroundColor,
  });

  /// Factory constructor for filled/active state button
  factory GradientButton.filled({
    required String text,
    VoidCallback? onPressed,
    double? width,
    double? height,
    double? fontSize,
    FontWeight? fontWeight,
    bool isLoading = false,
    Color? backgroundColor,
  }) {
    return GradientButton(
      text: text,
      onPressed: onPressed,
      isFilled: true,
      width: width,
      height: height,
      fontSize: fontSize,
      fontWeight: fontWeight,
      isLoading: isLoading,
      backgroundColor: backgroundColor,
    );
  }

  /// Factory constructor for outlined state button
  factory GradientButton.outlined({
    required String text,
    VoidCallback? onPressed,
    double? width,
    double? height,
    double? fontSize,
    FontWeight? fontWeight,
    bool isLoading = false,
    Color? backgroundColor,
  }) {
    return GradientButton(
      text: text,
      onPressed: onPressed,
      isFilled: false,
      width: width,
      height: height,
      fontSize: fontSize,
      fontWeight: fontWeight,
      isLoading: isLoading,
      backgroundColor: backgroundColor,
    );
  }

  static const _gradientColors = [
    AppColors.ctaGradientStart,
    AppColors.ctaGradientEnd,
  ];

  // Gradient: Top to bottom
  static const _gradientBegin = Alignment.topCenter;
  static const _gradientEnd = Alignment.bottomCenter;

  @override
  Widget build(BuildContext context) {
    final buttonWidth = width ?? 325.w;
    final buttonHeight = height ?? 48.h;
    final textSize = fontSize ?? 18.sp;
    final textWeight = fontWeight ?? FontWeight.w500;

    return Container(
      width: buttonWidth,
      height: buttonHeight,
      decoration: BoxDecoration(
        gradient: isFilled
            ? const LinearGradient(
                begin: _gradientBegin,
                end: _gradientEnd,
                colors: _gradientColors,
              )
            : null,
        color: isFilled ? null : (backgroundColor ?? Colors.white),
        borderRadius: BorderRadius.circular(188.r),
        border: isFilled
            ? null
            : GradientBorder(
                gradient: const LinearGradient(
                  begin: _gradientBegin,
                  end: _gradientEnd,
                  colors: _gradientColors,
                ),
                width: 1.w,
              ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(188.r),
          child: Container(
            alignment: Alignment.center,
            child: isLoading
                ? SizedBox(
                    width: 24.w,
                    height: 24.h,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.w,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isFilled ? Colors.white : AppColors.primary,
                      ),
                    ),
                  )
                : isFilled
                ? Text(
                    text,
                    style: TextStyle(
                      fontSize: textSize,
                      fontWeight: textWeight,
                      color: Colors.white,
                      fontFamily: 'montserrat',
                    ),
                  )
                : GradientText(
                    text,
                    style: TextStyle(
                      fontSize: textSize,
                      fontWeight: textWeight,
                      fontFamily: 'PlusJakartaSans',
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

/// Custom gradient border painter
class GradientBorder extends BoxBorder {
  final Gradient gradient;
  final double width;

  const GradientBorder({required this.gradient, this.width = 1.0});

  @override
  BorderSide get bottom => BorderSide.none;

  @override
  BorderSide get top => BorderSide.none;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(width);

  @override
  bool get isUniform => true;

  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    TextDirection? textDirection,
    BoxShape shape = BoxShape.rectangle,
    BorderRadius? borderRadius,
  }) {
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeWidth = width
      ..style = PaintingStyle.stroke;

    if (shape == BoxShape.circle) {
      canvas.drawCircle(rect.center, rect.shortestSide / 2, paint);
    } else if (borderRadius != null) {
      canvas.drawRRect(borderRadius.toRRect(rect).deflate(width / 2), paint);
    } else {
      canvas.drawRect(rect.deflate(width / 2), paint);
    }
  }

  @override
  ShapeBorder scale(double t) => this;
}
