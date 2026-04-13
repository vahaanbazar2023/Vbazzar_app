import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 8-point spacing system for consistent spacing throughout the app
/// All values are responsive using ScreenUtil
class AppSpacing {
  AppSpacing._();

  // Base spacing unit (8pt system)
  static double get xs => 4.w; // Extra small
  static double get s => 6.w;
  static double get sm => 8.w; // Small
  static double get md => 16.w; // Medium
  static double get lg => 24.w; // Large
  static double get xl => 32.w; // Extra large
  static double get xxl => 48.w; // 2X large
  static double get xxxl => 64.w; // 3X large

  // Common padding values
  static double get paddingXs => 4.w;
  static double get paddingSm => 8.w;
  static double get paddingMd => 16.w;
  static double get paddingLg => 24.w;
  static double get paddingXl => 32.w;

  // Common margin values
  static double get marginXs => 4.w;
  static double get marginSm => 8.w;
  static double get marginMd => 16.w;
  static double get marginLg => 24.w;
  static double get marginXl => 32.w;

  // Gap between elements
  static double get gapXs => 4.w;
  static double get gapSm => 8.w;
  static double get gapMd => 12.w;
  static double get gapLg => 16.w;
  static double get gapXl => 24.w;

  // Section spacing
  static double get sectionSm => 24.w;
  static double get sectionMd => 32.w;
  static double get sectionLg => 48.w;
  static double get sectionXl => 64.w;
}
