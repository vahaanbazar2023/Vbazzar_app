import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../constants/app_assets.dart';

/// Custom SVG icon widget for displaying SVG assets throughout the app
///
/// Features:
/// - Automatic responsive sizing with ScreenUtil
/// - Customizable color/tint
/// - Size presets (small, medium, large, custom)
/// - Optional semantic label for accessibility
///
/// Usage:
/// ```dart
/// AppSvgIcon(
///   assetPath: 'assets/icons/back_arrow.svg',
///   color: Colors.white,
///   size: 24,
/// )
/// ```
class AppSvgIcon extends StatelessWidget {
  /// Path to the SVG asset file
  final String assetPath;

  /// Color to apply to the SVG (uses ColorFilter)
  final Color? color;

  /// Size of the icon (width and height will be equal)
  /// Uses ScreenUtil for responsive sizing
  final double? size;

  /// Custom width (overrides size)
  final double? width;

  /// Custom height (overrides size)
  final double? height;

  /// Fit mode for the SVG
  final BoxFit fit;

  /// Semantic label for accessibility
  final String? semanticLabel;

  /// Alignment of the SVG within its bounds
  final Alignment alignment;

  const AppSvgIcon({
    super.key,
    required this.assetPath,
    this.color,
    this.size,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.semanticLabel,
    this.alignment = Alignment.center,
  });

  /// Factory constructor for small icons (16sp)
  factory AppSvgIcon.small({
    required String assetPath,
    Color? color,
    String? semanticLabel,
  }) {
    return AppSvgIcon(
      assetPath: assetPath,
      color: color,
      size: 16,
      semanticLabel: semanticLabel,
    );
  }

  /// Factory constructor for medium icons (24sp) - default size
  factory AppSvgIcon.medium({
    required String assetPath,
    Color? color,
    String? semanticLabel,
  }) {
    return AppSvgIcon(
      assetPath: assetPath,
      color: color,
      size: 24,
      semanticLabel: semanticLabel,
    );
  }

  /// Factory constructor for large icons (32sp)
  factory AppSvgIcon.large({
    required String assetPath,
    Color? color,
    String? semanticLabel,
  }) {
    return AppSvgIcon(
      assetPath: assetPath,
      color: color,
      size: 32,
      semanticLabel: semanticLabel,
    );
  }

  /// Factory constructor for extra large icons (48sp)
  factory AppSvgIcon.xlarge({
    required String assetPath,
    Color? color,
    String? semanticLabel,
  }) {
    return AppSvgIcon(
      assetPath: assetPath,
      color: color,
      size: 48,
      semanticLabel: semanticLabel,
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveWidth = width ?? size?.w ?? 24.w;
    final effectiveHeight = height ?? size?.h ?? 24.h;

    return SvgPicture.asset(
      assetPath,
      width: effectiveWidth,
      height: effectiveHeight,
      fit: fit,
      alignment: alignment,
      semanticsLabel: semanticLabel,
      colorFilter: color != null
          ? ColorFilter.mode(color!, BlendMode.srcIn)
          : null,
    );
  }
}

/// Specialized back arrow icon widget
class BackArrowIcon extends StatelessWidget {
  final Color? color;
  final double? size;

  const BackArrowIcon({super.key, this.color, this.size});

  @override
  Widget build(BuildContext context) {
    return AppSvgIcon(
      assetPath: AppAssets.arrowBack,
      color: color ?? Colors.white,
      size: size ?? 24,
      semanticLabel: 'Back',
    );
  }
}
