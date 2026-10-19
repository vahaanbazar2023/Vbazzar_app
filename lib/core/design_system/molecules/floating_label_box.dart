import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';

/// Outlined box whose [label] sits inside like a placeholder while the box is
/// empty and floats up onto the top border once it has a value or focus.
///
/// Use it for fields that are not a plain `TextField` (dropdown triggers,
/// date / year pickers). Text inputs get the same look natively through
/// `InputDecoration.labelText`.
///
/// [child] holds only the value (and any icons); do not put the label or a
/// placeholder in it.
class FloatingLabelBox extends StatelessWidget {
  final String label;
  final bool hasValue;
  final bool isFocused;
  final bool hasError;
  final bool enabled;
  final double? height;
  final double radius;

  /// Where the label starts while it sits inside the box (leave room for a
  /// prefix icon).
  final double? inlineLeft;
  final Widget child;
  final Color? fillColor;

  const FloatingLabelBox({
    super.key,
    required this.label,
    required this.child,
    this.hasValue = false,
    this.isFocused = false,
    this.hasError = false,
    this.enabled = true,
    this.height,
    this.radius = 8,
    this.inlineLeft,
    this.fillColor,
  });

  @override
  Widget build(BuildContext context) {
    final h = height ?? 46.h;
    final floated = hasValue || isFocused;
    final borderColor = hasError
        ? AppColors.error
        : isFocused
        ? AppColors.primary
        : AppColors.grey300;
    final labelColor = hasError
        ? AppColors.error
        : isFocused
        ? AppColors.primary
        : AppColors.textSecondary;
    final fill = fillColor ?? (enabled ? AppColors.white : AppColors.grey100);
    final restLeft = inlineLeft ?? 12.w;

    return SizedBox(
      height: h,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: fill,
                borderRadius: BorderRadius.circular(radius.r),
                border: Border.all(
                  color: borderColor,
                  width: isFocused ? 1.5 : 1,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: child,
            ),
          ),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(end: floated ? 1.0 : 0.0),
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            builder: (context, t, _) {
              final fontSize = lerpDouble(14.sp, 11.sp, t)!;
              final lineH = fontSize * 1.2;
              final top = lerpDouble((h - lineH) / 2, -lineH / 2, t)!;
              return Positioned(
                left: lerpDouble(restLeft, 10.w, t)!,
                top: top,
                right: lerpDouble(12.w, null, t),
                child: IgnorePointer(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    widthFactor: 1,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 4.w * t),
                      color: t > 0.02 ? fill : Colors.transparent,
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: fontSize,
                          height: 1.2,
                          fontWeight: floated
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: labelColor,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
