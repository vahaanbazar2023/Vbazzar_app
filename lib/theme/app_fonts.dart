import 'package:flutter/material.dart';

class AppFonts {
  AppFonts._();

  // Using PlusJakartaSans as the primary font family
  static const String _fontFamily = 'PlusJakartaSans';

  static TextTheme get textTheme => const TextTheme(
    displayLarge: TextStyle(fontFamily: _fontFamily),
    displayMedium: TextStyle(fontFamily: _fontFamily),
    displaySmall: TextStyle(fontFamily: _fontFamily),
    headlineLarge: TextStyle(fontFamily: _fontFamily),
    headlineMedium: TextStyle(fontFamily: _fontFamily),
    headlineSmall: TextStyle(fontFamily: _fontFamily),
    titleLarge: TextStyle(fontFamily: _fontFamily),
    titleMedium: TextStyle(fontFamily: _fontFamily),
    titleSmall: TextStyle(fontFamily: _fontFamily),
    bodyLarge: TextStyle(fontFamily: _fontFamily),
    bodyMedium: TextStyle(fontFamily: _fontFamily),
    bodySmall: TextStyle(fontFamily: _fontFamily),
    labelLarge: TextStyle(fontFamily: _fontFamily),
    labelMedium: TextStyle(fontFamily: _fontFamily),
    labelSmall: TextStyle(fontFamily: _fontFamily),
  );

  static TextStyle get displayLarge => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 57,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
  );
  static TextStyle get displayMedium => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 45,
    fontWeight: FontWeight.w400,
  );
  static TextStyle get displaySmall => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 36,
    fontWeight: FontWeight.w400,
  );

  static TextStyle get headlineLarge => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
  );
  static TextStyle get headlineMedium => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w600,
  );
  static TextStyle get headlineSmall => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
  );

  static TextStyle get titleLarge => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
  );
  static TextStyle get titleMedium => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
  );
  static TextStyle get titleSmall => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );

  static TextStyle get bodyLarge => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
  );
  static TextStyle get bodyMedium => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
  );
  static TextStyle get bodySmall => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
  );

  static TextStyle get labelLarge => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );
  static TextStyle get labelMedium => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );
  static TextStyle get labelSmall => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );
}
