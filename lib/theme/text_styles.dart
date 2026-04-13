import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import 'app_fonts.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextTheme get light => TextTheme(
    displayLarge: AppFonts.displayLarge.copyWith(color: AppColors.textPrimary),
    displayMedium: AppFonts.displayMedium.copyWith(
      color: AppColors.textPrimary,
    ),
    displaySmall: AppFonts.displaySmall.copyWith(color: AppColors.textPrimary),
    headlineLarge: AppFonts.headlineLarge.copyWith(
      color: AppColors.textPrimary,
    ),
    headlineMedium: AppFonts.headlineMedium.copyWith(
      color: AppColors.textPrimary,
    ),
    headlineSmall: AppFonts.headlineSmall.copyWith(
      color: AppColors.textPrimary,
    ),
    titleLarge: AppFonts.titleLarge.copyWith(color: AppColors.textPrimary),
    titleMedium: AppFonts.titleMedium.copyWith(color: AppColors.textPrimary),
    titleSmall: AppFonts.titleSmall.copyWith(color: AppColors.textPrimary),
    bodyLarge: AppFonts.bodyLarge.copyWith(color: AppColors.textPrimary),
    bodyMedium: AppFonts.bodyMedium.copyWith(color: AppColors.textPrimary),
    bodySmall: AppFonts.bodySmall.copyWith(color: AppColors.textSecondary),
    labelLarge: AppFonts.labelLarge.copyWith(color: AppColors.textPrimary),
    labelMedium: AppFonts.labelMedium.copyWith(color: AppColors.textSecondary),
    labelSmall: AppFonts.labelSmall.copyWith(color: AppColors.textDisabled),
  );

  static TextTheme get dark => TextTheme(
    displayLarge: AppFonts.displayLarge.copyWith(color: AppColors.white),
    displayMedium: AppFonts.displayMedium.copyWith(color: AppColors.white),
    displaySmall: AppFonts.displaySmall.copyWith(color: AppColors.white),
    headlineLarge: AppFonts.headlineLarge.copyWith(color: AppColors.white),
    headlineMedium: AppFonts.headlineMedium.copyWith(color: AppColors.white),
    headlineSmall: AppFonts.headlineSmall.copyWith(color: AppColors.white),
    titleLarge: AppFonts.titleLarge.copyWith(color: AppColors.white),
    titleMedium: AppFonts.titleMedium.copyWith(color: AppColors.white),
    titleSmall: AppFonts.titleSmall.copyWith(color: AppColors.white),
    bodyLarge: AppFonts.bodyLarge.copyWith(color: AppColors.white),
    bodyMedium: AppFonts.bodyMedium.copyWith(color: AppColors.white),
    bodySmall: AppFonts.bodySmall.copyWith(color: AppColors.grey400),
    labelLarge: AppFonts.labelLarge.copyWith(color: AppColors.white),
    labelMedium: AppFonts.labelMedium.copyWith(color: AppColors.grey400),
    labelSmall: AppFonts.labelSmall.copyWith(color: AppColors.grey500),
  );
}
