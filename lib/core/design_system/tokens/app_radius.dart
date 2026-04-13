import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Border radius tokens for consistent rounded corners
/// All values are responsive using ScreenUtil
class AppRadius {
  AppRadius._();

  // Radius values
  static double get none => 0;
  static double get xs => 4.r;
  static double get sm => 8.r;
  static double get md => 12.r;
  static double get lg => 16.r;
  static double get xl => 24.r;
  static double get xxl => 32.r;
  static double get xxxl => 32.r;
  static double get full => 9999.r; // Circular

  // BorderRadius presets
  static BorderRadius get borderRadiusNone => BorderRadius.zero;
  static BorderRadius get borderRadiusXs => BorderRadius.circular(xs);
  static BorderRadius get borderRadiusSm => BorderRadius.circular(sm);
  static BorderRadius get borderRadiusMd => BorderRadius.circular(md);
  static BorderRadius get borderRadiusLg => BorderRadius.circular(lg);
  static BorderRadius get borderRadiusXl => BorderRadius.circular(xl);
  static BorderRadius get borderRadiusXxl => BorderRadius.circular(xxl);
  static BorderRadius get borderRadiusFull => BorderRadius.circular(full);

  // Specific corner radius
  static BorderRadius topOnly(double radius) => BorderRadius.only(
    topLeft: Radius.circular(radius),
    topRight: Radius.circular(radius),
  );

  static BorderRadius bottomOnly(double radius) => BorderRadius.only(
    bottomLeft: Radius.circular(radius),
    bottomRight: Radius.circular(radius),
  );

  static BorderRadius leftOnly(double radius) => BorderRadius.only(
    topLeft: Radius.circular(radius),
    bottomLeft: Radius.circular(radius),
  );

  static BorderRadius rightOnly(double radius) => BorderRadius.only(
    topRight: Radius.circular(radius),
    bottomRight: Radius.circular(radius),
  );
}
