import 'package:flutter/material.dart';

/// Custom text styles for Moul font
class MoulTextStyle {
  MoulTextStyle._();

  static TextStyle get regular =>
      const TextStyle(fontFamily: 'Moul', fontWeight: FontWeight.w400);

  /// Custom method to create Moul text style with specific properties
  static TextStyle style({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
    Paint? foreground,
  }) {
    return TextStyle(
      fontFamily: 'Moul',
      fontSize: fontSize,
      fontWeight: fontWeight ?? FontWeight.w400,
      color: foreground == null ? color : null,
      letterSpacing: letterSpacing,
      height: height,
      foreground: foreground,
    );
  }
}

/// Custom text styles for Plus Jakarta Sans font
class PlusJakartaSansTextStyle {
  PlusJakartaSansTextStyle._();

  static TextStyle get regular => const TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontWeight: FontWeight.w400,
  );

  static TextStyle get medium => const TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontWeight: FontWeight.w500,
  );

  static TextStyle get semiBold => const TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontWeight: FontWeight.w600,
  );

  static TextStyle get bold => const TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontWeight: FontWeight.w700,
  );

  static TextStyle get extraBold => const TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontWeight: FontWeight.w800,
  );

  /// Custom method to create Plus Jakarta Sans text style with specific properties
  static TextStyle style({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
    Paint? foreground,
  }) {
    return TextStyle(
      fontFamily: 'PlusJakartaSans',
      fontSize: fontSize,
      fontWeight: fontWeight ?? FontWeight.w400,
      color: foreground == null ? color : null,
      letterSpacing: letterSpacing,
      height: height,
      foreground: foreground,
    );
  }
}
