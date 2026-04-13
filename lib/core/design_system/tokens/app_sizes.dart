import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Size tokens for consistent component sizing
/// All values are responsive using ScreenUtil
class AppSizes {
  AppSizes._();

  // Icon sizes
  static double get iconXs => 16.w;
  static double get iconSm => 20.w;
  static double get iconMd => 24.w;
  static double get iconLg => 32.w;
  static double get iconXl => 48.w;
  static double get iconXxl => 64.w;

  // Button heights
  static double get buttonSm => 36.h;
  static double get buttonMd => 44.h;
  static double get buttonLg => 52.h;
  static double get buttonXl => 60.h;

  // Button minimum widths
  static double get buttonMinWidthSm => 80.w;
  static double get buttonMinWidthMd => 120.w;
  static double get buttonMinWidthLg => 160.w;

  // Input field heights
  static double get inputSm => 40.h;
  static double get inputMd => 48.h;
  static double get inputLg => 56.h;

  // Avatar sizes
  static double get avatarXs => 24.w;
  static double get avatarSm => 32.w;
  static double get avatarMd => 48.w;
  static double get avatarLg => 64.w;
  static double get avatarXl => 96.w;

  // Card sizes
  static double get cardMinHeight => 120.h;
  static double get cardMediumHeight => 180.h;
  static double get cardLargeHeight => 240.h;

  // Bottom sheet
  static double get bottomSheetMaxHeight => 600.h;
  static double get bottomSheetMinHeight => 200.h;

  // AppBar
  static double get appBarHeight => 56.h;
  static double get appBarElevation => 0;

  // Divider
  static double get dividerThickness => 1.w;
  static double get dividerThicknessBold => 2.w;

  // Border width
  static double get borderWidthThin => 1.w;
  static double get borderWidthMedium => 2.w;
  static double get borderWidthThick => 3.w;

  // Image sizes
  static double get imageSm => 64.w;
  static double get imageMd => 120.w;
  static double get imageLg => 200.w;
  static double get imageXl => 300.w;
}
