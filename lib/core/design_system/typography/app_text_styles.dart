import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/app_colors.dart';

/// Typography system using local Plus Jakarta Sans and Montserrat fonts
/// All font sizes use ScreenUtil for responsive design
class AppTextStyles {
  AppTextStyles._();

  // Font families
  static const String _fontFamily = 'PlusJakartaSans';
  static const String fontFamilyMontserrat = 'Montserrat';

  // ── Headings ──────────────────────────────────────────────────

  /// Heading 1 - Extra Bold, 32sp
  /// Usage: Page titles, major sections
  static TextStyle get headingXLarge => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 32.sp,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    height: 1.25,
    letterSpacing: -0.5,
  );

  /// Heading 2 - Bold, 28sp
  /// Usage: Section headers, screen titles
  static TextStyle get headingLarge => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.3,
    letterSpacing: -0.3,
  );

  /// Heading 3 - Bold, 24sp
  /// Usage: Card titles, subsection headers
  static TextStyle get headingMedium => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.35,
    letterSpacing: 0,
  );

  /// Heading 4 - SemiBold, 20sp
  /// Usage: Small section titles
  static TextStyle get headingSmall => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
    letterSpacing: 0,
  );

  /// Heading 5 - SemiBold, 18sp
  /// Usage: List item headers
  static TextStyle get headingXSmall => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
    letterSpacing: 0,
  );

  // ── Body Text ──────────────────────────────────────────────────

  /// Body 1 - Regular, 16sp
  /// Usage: Main content, paragraphs
  static TextStyle get bodyLarge => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
    letterSpacing: 0.15,
  );

  /// Body 2 - Regular, 14sp
  /// Usage: Secondary content, descriptions
  static TextStyle get bodyMedium => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
    letterSpacing: 0.25,
  );

  /// Body 3 - Regular, 12sp
  /// Usage: Small body text
  static TextStyle get bodySmall => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
    letterSpacing: 0.4,
  );

  // ── Labels & Buttons ──────────────────────────────────────────

  /// Button text - SemiBold, 16sp
  /// Usage: Primary buttons, CTAs
  static TextStyle get buttonLarge => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    height: 1.25,
    letterSpacing: 0.5,
  );

  /// Button text - SemiBold, 14sp
  /// Usage: Secondary buttons
  static TextStyle get buttonMedium => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    height: 1.25,
    letterSpacing: 0.5,
  );

  /// Button text - Medium, 12sp
  /// Usage: Small buttons, chips
  static TextStyle get buttonSmall => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.white,
    height: 1.25,
    letterSpacing: 0.5,
  );

  /// Label - Medium, 14sp
  /// Usage: Form labels, input labels
  static TextStyle get labelMedium => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.4,
    letterSpacing: 0.1,
  );

  /// Label - Medium, 12sp
  /// Usage: Small labels, tags
  static TextStyle get labelSmall => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.4,
    letterSpacing: 0.5,
  );

  // ── Caption & Overline ────────────────────────────────────────

  /// Caption - Regular, 12sp
  /// Usage: Helper text, timestamps, metadata
  static TextStyle get caption => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.35,
    letterSpacing: 0.4,
  );

  /// Overline - SemiBold, 10sp
  /// Usage: Category labels, overlines
  static TextStyle get overline => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 10.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    height: 1.6,
    letterSpacing: 1.5,
  );

  // ── Special Styles ─────────────────────────────────────────────

  /// Link text - Medium, 14sp
  /// Usage: Hyperlinks, navigation text
  static TextStyle get link => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
    height: 1.5,
    decoration: TextDecoration.underline,
    decorationColor: AppColors.primary,
  );

  /// Error text - Regular, 12sp
  /// Usage: Error messages, validation messages
  static TextStyle get error => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.error,
    height: 1.35,
    letterSpacing: 0.4,
  );

  // ── Helper methods for customization ───────────────────────────

  /// Get Montserrat text style with custom parameters
  static TextStyle getMontserratStyle(
    double fontSize,
    FontWeight fontWeight,
    Color color, {
    double? letterSpacing,
    double? height,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      decoration: decoration ?? TextDecoration.none,
      fontSize: fontSize.sp,
      fontFamily: fontFamilyMontserrat,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  /// Apply color to any text style
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// Apply weight to any text style
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  /// Apply size to any text style
  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size.sp);
  }
}
