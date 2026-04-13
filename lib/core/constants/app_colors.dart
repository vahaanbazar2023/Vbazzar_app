import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Brand ─────────────────────────────────────────────────────
  // Figma: primary red from CTA gradient / ellipse fills
  static const Color primary = Color(0xFFBB2625);
  static const Color primaryLight = Color(0xFFD41F1F);
  static const Color primaryDark = Color(0xFF67100B);
  static const Color primaryFill = Color(0xFFA40301);

  static const Color secondary = Color(0xFFFF6F00);
  static const Color secondaryLight = Color(0xFFFFA040);
  static const Color secondaryDark = Color(0xFFC43E00);

  // Figma CTA gradient
  static const Color ctaGradientStart = Color(0xFFBB2625);
  static const Color ctaGradientEnd = Color(0xFF67100B);

  // Auth layout header gradient
  static const Color authHeaderGradientStart = Color(0xFF6B1111);
  static const Color authHeaderGradientEnd = Color(0xFF4A0B0B);

  // ── Semantic ──────────────────────────────────────────────────
  static const Color success = Color(0xFF00AC28);
  static const Color successDark = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFF10B981);
  static const Color successBackground = Color(0xFFD7FFE1);

  static const Color warning = Color(0xFFFEB528);
  static const Color warningDark = Color(0xFFF57F17);
  static const Color warningBackground = Color(0xFFFFDD9B);
  static const Color warningBorder = Color(0xFFFFDD9B);

  static const Color error = Color(0xFFE53E3E);
  static const Color errorDark = Color(0xFFC62828);

  static const Color info = Color(0xFF01579B);
  static const Color red = Color(0xFF9E1F1C);
  static const Color lightOrange = Color(0xFFFFCACA);
  static const Color lightOrangeBackground = Color(0xFFF3EAEA);
  static const Color lightOrangeDark = Color(0xFF6D6D6D);

  // ── Neutrals ─────────────────────────────────────────────────
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey550 = Color(0xFF999999);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey650 = Color(0xFF666666);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey850 = Color(0xFF1A1A1A);
  static const Color grey900 = Color(0xFF212121);

  // Transparent colors
  static const Color blackTransparent = Color(0x24000000);
  static const Color greyTransparent = Color(0x3DE4E5E7);

  // ── Background ───────────────────────────────────────────────
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFEEEEEE);

  // ── Text ─────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textDisabled = Color(0xFFBDBDBD);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textHelper = Color(0xFF362525);

  // ── Dark theme mirrors ───────────────────────────────────────
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF2C2C2C);
}
