import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../molecules/gradient_button.dart'; // GradientBorder

/// A fully customisable search bar inspired by _VehicleSearchBar.
///
/// Features:
/// - Gradient border (defaults to CTA gradient) or solid border
/// - Custom border radius
/// - Custom height
/// - Prefix icon (defaults to search icon)
/// - Optional suffix clear button
/// - Optional [enabled] = false for tap-through use (home header)
///
/// Usage — tappable pill on home header:
/// ```dart
/// GestureDetector(
///   onTap: () => Get.toNamed(AppRoutes.search),
///   child: AbsorbPointer(
///     child: CustomSearchBar(enabled: false, hint: 'Search...'),
///   ),
/// )
/// ```
///
/// Usage — active search field:
/// ```dart
/// CustomSearchBar(
///   controller: _controller,
///   autofocus: true,
///   onChanged: (v) { ... },
/// )
/// ```
class CustomSearchBar extends StatefulWidget {
  final TextEditingController? controller;
  final String hint;
  final bool enabled;
  final bool autofocus;
  final bool showGradientBorder;
  final bool
  alwaysShowGradientBorder; // true = gradient always; false = gradient only on focus
  final double borderRadius;
  final double height;
  final double borderWidth;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final TextInputAction textInputAction;

  /// Gradient used for the border (defaults to CTA gradient).
  final Gradient? borderGradient;

  /// Solid border colour used when [showGradientBorder] is false.
  final Color? borderColor;

  const CustomSearchBar({
    super.key,
    this.controller,
    this.hint = 'Search...',
    this.enabled = true,
    this.autofocus = false,
    this.showGradientBorder = true,
    this.alwaysShowGradientBorder = false,
    this.borderRadius = 24,
    this.height = 46,
    this.borderWidth = 1.5,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.textInputAction = TextInputAction.search,
    this.borderGradient,
    this.borderColor,
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  late final TextEditingController _ctrl;
  late final FocusNode _focus;
  bool _isFocused = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _ctrl = widget.controller ?? TextEditingController();
    _focus = FocusNode();
    _focus.addListener(() => setState(() => _isFocused = _focus.hasFocus));
    _ctrl.addListener(() => setState(() => _hasText = _ctrl.text.isNotEmpty));
    _hasText = _ctrl.text.isNotEmpty;
  }

  @override
  void dispose() {
    _focus.dispose();
    if (widget.controller == null) _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(widget.borderRadius.r);
    final gradient =
        widget.borderGradient ??
        const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.ctaGradientStart, AppColors.ctaGradientEnd],
        );

    return Container(
      height: widget.height.h,
      decoration: BoxDecoration(
        borderRadius: radius,
        color: AppColors.white,
        // Gradient border via GradientBorder (from gradient_button.dart)
        border: widget.showGradientBorder
            ? GradientBorder(
                gradient: (_isFocused || widget.alwaysShowGradientBorder)
                    ? gradient
                    : const LinearGradient(
                        colors: [AppColors.grey300, AppColors.grey300],
                      ),
                width: widget.borderWidth,
              )
            : Border.all(
                color: _isFocused
                    ? AppColors.primary
                    : (widget.borderColor ?? AppColors.grey300),
                width: widget.borderWidth,
              ),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: TextField(
        controller: _ctrl,
        focusNode: _focus,
        enabled: widget.enabled,
        autofocus: widget.autofocus,
        textAlignVertical: TextAlignVertical.center,
        textInputAction: widget.textInputAction,
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 13.sp,
          color: AppColors.textPrimary,
        ),
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 14.w, right: 8.w),
            child: Icon(
              Icons.search_rounded,
              size: 20.r,
              color: _isFocused ? AppColors.primary : AppColors.grey500,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(),
          suffixIcon: (_hasText && widget.enabled)
              ? GestureDetector(
                  onTap: () {
                    _ctrl.clear();
                    widget.onClear?.call();
                    widget.onChanged?.call('');
                  },
                  child: Padding(
                    padding: EdgeInsets.only(right: 12.w),
                    child: Icon(
                      Icons.close_rounded,
                      size: 18.r,
                      color: AppColors.grey400,
                    ),
                  ),
                )
              : null,
          suffixIconConstraints: const BoxConstraints(),
          hintText: widget.hint,
          hintStyle: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 13.sp,
            color: AppColors.grey500,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 12.h),
          isDense: true,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          filled: false,
        ),
      ),
    );
  }
}
