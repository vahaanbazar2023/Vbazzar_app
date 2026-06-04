import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../constants/app_colors.dart';

/// App-wide custom loader using ThreeArchedCircle animation.
///
/// Usage:
/// ```dart
/// // Default (primary color, medium size)
/// const CustomLoader()
///
/// // With custom color and size
/// const CustomLoader(color: Colors.white, size: 40)
///
/// // As a full-screen backdrop overlay
/// CustomLoader.backdrop()
/// ```
class CustomLoader extends StatelessWidget {
  /// The color of the loader. Defaults to [AppColors.primary].
  final Color? color;

  /// The size of the loader in logical pixels. Defaults to 40.
  final double size;

  const CustomLoader({
    super.key,
    this.color,
    this.size = 40,
  });

  /// Creates a full-screen backdrop overlay with a centered loader.
  static Widget backdrop({
    Color? loaderColor,
    double loaderSize = 44,
    double opacity = 0.5,
    Color barrierColor = Colors.black,
  }) {
    return Container(
      color: barrierColor.withOpacity(opacity),
      child: Center(
        child: CustomLoader(
          color: loaderColor ?? AppColors.primary,
          size: loaderSize,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LoadingAnimationWidget.threeArchedCircle(
      color: color ?? AppColors.primary,
      size: size.w,
    );
  }
}