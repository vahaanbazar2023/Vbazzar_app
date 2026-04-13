import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/app_colors.dart';
import '../typography/app_text_styles.dart';

/// Custom input field with dynamic error handling
///
/// Design specs:
/// - Border: 1px solid #00000024
/// - Box shadow: 0px 1px 2px 0px #E4E5E73D
/// - Height: 46px
/// - No label (reusable throughout project)
///
/// Features:
/// - Dynamic error state with error message
/// - Custom prefix/suffix icons
/// - Placeholder text
/// - Focus state handling
/// - Optional obscure text for passwords
///
/// Usage:
/// ```dart
/// CustomInputField(
///   controller: phoneController,
///   placeholder: 'Enter your phone number',
///   prefixIcon: Icons.phone,
///   errorText: errorMessage, // Pass null or empty string when no error
///   keyboardType: TextInputType.phone,
/// )
/// ```
class CustomInputField extends StatefulWidget {
  /// Text editing controller for the input field
  final TextEditingController? controller;

  /// Placeholder/hint text displayed when field is empty
  final String? placeholder;

  /// Error message to display below the field
  /// Pass null or empty string when there's no error
  final String? errorText;

  /// Validator function that returns error message or null if valid
  final String? Function(String?)? validator;

  /// Whether to show success state (green border/checkmark) when valid
  final bool showSuccessState;

  /// Icon to display at the start of the input field
  final IconData? prefixIcon;

  /// Widget to display at the start of the input field (overrides prefixIcon)
  final Widget? prefixWidget;

  /// Icon to display at the end of the input field
  final IconData? suffixIcon;

  /// Widget to display at the end of the input field (overrides suffixIcon)
  final Widget? suffixWidget;

  /// Callback when suffix widget is tapped
  final VoidCallback? onSuffixTap;

  /// Whether to obscure the text (for passwords)
  final bool obscureText;

  /// Keyboard type for the input
  final TextInputType? keyboardType;

  /// Text input action (next, done, etc.)
  final TextInputAction? textInputAction;

  /// Callback when the text changes
  final ValueChanged<String>? onChanged;

  /// Callback when the user submits the field
  final ValueChanged<String>? onSubmitted;

  /// Maximum number of lines (default: 1)
  final int? maxLines;

  /// Maximum length of the input
  final int? maxLength;

  /// Whether the field is enabled
  final bool enabled;

  /// Whether the field is read-only
  final bool readOnly;

  /// Focus node for the input field
  final FocusNode? focusNode;

  /// Input formatters for the field
  final List<TextInputFormatter>? inputFormatters;

  /// Custom text style for the input
  final TextStyle? textStyle;

  /// Custom text style for the placeholder
  final TextStyle? placeholderStyle;

  /// Custom height (default: 46.h)
  final double? height;

  const CustomInputField({
    super.key,
    this.controller,
    this.placeholder,
    this.errorText,
    this.validator,
    this.showSuccessState = false,
    this.prefixIcon,
    this.prefixWidget,
    this.suffixIcon,
    this.suffixWidget,
    this.onSuffixTap,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.readOnly = false,
    this.focusNode,
    this.inputFormatters,
    this.textStyle,
    this.placeholderStyle,
    this.height,
  });

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  String? _validationError;
  bool _hasInteracted = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;

      // Validate on blur (when focus is lost) if validator is provided and field has been interacted with
      if (!_isFocused && _hasInteracted && widget.validator != null) {
        _validateField();
      }
    });
  }

  void _validateField() {
    if (widget.validator != null) {
      final value = widget.controller?.text;
      setState(() {
        _validationError = widget.validator!(value);
      });
    }
  }

  void _handleTextChange(String value) {
    setState(() {
      _hasInteracted = true;

      // Always validate on change if validator is provided
      if (widget.validator != null) {
        _validationError = widget.validator!(value);
      }
    });

    // Call the external onChanged callback
    widget.onChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    // External errorText always shows; internal _validationError only shows after interaction
    final hasExternalError =
        widget.errorText != null && widget.errorText!.isNotEmpty;
    final displayError = hasExternalError
        ? widget.errorText
        : (_hasInteracted ? _validationError : null);
    final hasError = displayError != null && displayError.isNotEmpty;

    // Check if field is valid (for success state)
    final currentValue = widget.controller?.text ?? '';
    final isValid =
        widget.showSuccessState &&
        _hasInteracted &&
        currentValue.isNotEmpty &&
        !hasError &&
        (widget.validator == null || widget.validator!(currentValue) == null);

    final inputHeight = widget.height ?? 46.h;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Input field with gradient border for all states
        Container(
          height: widget.maxLines == 1 ? inputHeight : null,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: AppColors.greyTransparent,
                offset: const Offset(0, 1),
                blurRadius: 2,
                spreadRadius: 0,
              ),
            ],
          ),
          padding: EdgeInsets.all(0.5.w), // Thin gradient border
          child: Container(
            decoration: BoxDecoration(
              color: widget.enabled ? Colors.white : AppColors.grey100,
              borderRadius: BorderRadius.circular(7.5.r),
            ),
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              obscureText: widget.obscureText,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              onChanged: _handleTextChange,
              onSubmitted: widget.onSubmitted,
              maxLines: widget.maxLines,
              maxLength: widget.maxLength,
              enabled: widget.enabled,
              readOnly: widget.readOnly,
              inputFormatters: widget.inputFormatters,
              style:
                  widget.textStyle ??
                  AppTextStyles.bodyMedium.copyWith(
                    fontSize: 14.sp,
                    color: AppColors.grey850,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Montserrat',
                  ),
              decoration: InputDecoration(
                hintText: widget.placeholder,
                hintStyle:
                    widget.placeholderStyle ??
                    AppTextStyles.bodyMedium.copyWith(
                      fontSize: 14.sp,
                      color: AppColors.grey550,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Montserrat',
                    ),
                prefixIcon: _buildPrefixWidget(),
                suffixIcon: _buildSuffixWidget(isValid, hasError),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7.5.r),
                  borderSide: BorderSide(
                    color: AppColors.blackTransparent,
                    width: 1.w,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7.5.r),
                  borderSide: BorderSide(
                    color: isValid
                        ? AppColors.successLight
                        : AppColors.blackTransparent,
                    width: 1.w,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7.5.r),
                  borderSide: BorderSide(
                    color: AppColors.ctaGradientStart,
                    width: 1.w,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7.5.r),
                  borderSide: BorderSide(color: AppColors.error, width: 1.w),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7.5.r),
                  borderSide: BorderSide(color: AppColors.error, width: 1.w),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7.5.r),
                  borderSide: BorderSide(color: AppColors.grey550, width: 1.w),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: widget.maxLines == 1 ? 0 : 12.h,
                ),
                counterText: '',
                isDense: widget.maxLines == 1,
              ),
            ),
          ),
        ),

        // Error message
        if (hasError) ...[
          SizedBox(height: 6.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.error_outline, size: 14.sp, color: AppColors.error),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  displayError,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12.sp,
                    color: AppColors.error,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  /// Builds the prefix widget (icon or custom widget)
  Widget? _buildPrefixWidget() {
    if (widget.prefixWidget != null) {
      return widget.prefixWidget;
    }

    if (widget.prefixIcon != null) {
      return Padding(
        padding: EdgeInsets.only(left: 12.w, right: 8.w),
        child: Icon(
          widget.prefixIcon,
          size: 20.sp,
          color: _isFocused ? AppColors.primary : AppColors.grey650,
        ),
      );
    }

    return null;
  }

  /// Builds the suffix widget (icon or custom widget)
  Widget? _buildSuffixWidget(bool isValid, bool hasError) {
    // Show success checkmark if field is valid and showSuccessState is enabled
    if (isValid && widget.suffixWidget == null && widget.suffixIcon == null) {
      return Padding(
        padding: EdgeInsets.only(right: 12.w, left: 8.w),
        child: Icon(
          Icons.check_circle,
          size: 20.sp,
          color: AppColors.successLight,
        ),
      );
    }

    if (widget.suffixWidget != null) {
      return GestureDetector(
        onTap: widget.onSuffixTap,
        child: widget.suffixWidget,
      );
    }

    if (widget.suffixIcon != null) {
      return GestureDetector(
        onTap: widget.onSuffixTap,
        child: Padding(
          padding: EdgeInsets.only(right: 12.w, left: 8.w),
          child: Icon(
            widget.suffixIcon,
            size: 20.sp,
            color: _isFocused ? AppColors.primary : AppColors.grey650,
          ),
        ),
      );
    }

    return null;
  }
}

/// Password input field variant with show/hide toggle
class CustomPasswordField extends StatefulWidget {
  final TextEditingController? controller;
  final String? placeholder;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;

  const CustomPasswordField({
    super.key,
    this.controller,
    this.placeholder,
    this.errorText,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
  });

  @override
  State<CustomPasswordField> createState() => _CustomPasswordFieldState();
}

class _CustomPasswordFieldState extends State<CustomPasswordField> {
  bool _obscureText = true;

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomInputField(
      controller: widget.controller,
      placeholder: widget.placeholder ?? 'Enter password',
      errorText: widget.errorText,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      focusNode: widget.focusNode,
      obscureText: _obscureText,
      prefixIcon: Icons.lock_outline,
      suffixIcon: _obscureText ? Icons.visibility_off : Icons.visibility,
      onSuffixTap: _toggleObscureText,
    );
  }
}
