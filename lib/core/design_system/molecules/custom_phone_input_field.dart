import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import '../../constants/app_colors.dart';
import '../typography/app_text_styles.dart';

/// Custom phone input field with country code picker and flags
///
/// Design specs:
/// - Matches CustomInputField design
/// - Border: 1px solid #00000024
/// - Box shadow: 0px 1px 2px 0px #E4E5E73D
/// - Height: 46px
/// - Includes country flag and dial code
///
/// Usage:
/// ```dart
/// CustomPhoneInputField(
///   controller: phoneController,
///   placeholder: 'Enter phone number',
///   errorText: errorMessage,
///   onChanged: (phone) {
///     print('Complete phone: ${phone.completeNumber}');
///     print('Country code: ${phone.countryCode}');
///     print('Number: ${phone.number}');
///   },
/// )
/// ```
class CustomPhoneInputField extends StatefulWidget {
  /// Text editing controller for the phone input field
  final TextEditingController? controller;

  /// Placeholder/hint text displayed when field is empty
  final String? placeholder;

  /// Error message to display below the field
  final String? errorText;

  /// Callback when the phone number changes
  final void Function(PhoneNumber)? onChanged;

  /// Callback when the country changes
  final void Function(String)? onCountryChanged;

  /// Whether the field is enabled
  final bool enabled;

  /// Whether the field is read-only
  final bool readOnly;

  /// Focus node for the input field
  final FocusNode? focusNode;

  /// Initial country code (defaults to 'IN' for India)
  final String initialCountryCode;

  /// Custom text style for the input
  final TextStyle? textStyle;

  /// Custom text style for the placeholder
  final TextStyle? placeholderStyle;

  const CustomPhoneInputField({
    super.key,
    this.controller,
    this.placeholder,
    this.errorText,
    this.onChanged,
    this.onCountryChanged,
    this.enabled = true,
    this.readOnly = false,
    this.focusNode,
    this.initialCountryCode = 'IN',
    this.textStyle,
    this.placeholderStyle,
  });

  @override
  State<CustomPhoneInputField> createState() => _CustomPhoneInputFieldState();
}

class _CustomPhoneInputFieldState extends State<CustomPhoneInputField> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 46.h,
          child: IntlPhoneField(
            controller: widget.controller,
            focusNode: _focusNode,
            enabled: widget.enabled,
            readOnly: widget.readOnly,
            initialCountryCode: widget.initialCountryCode,
            decoration: InputDecoration(
              hintText: widget.placeholder ?? 'Enter phone number',
              hintStyle:
                  widget.placeholderStyle ??
                  AppTextStyles.getMontserratStyle(
                    14.sp,
                    FontWeight.w400,
                    AppColors.grey500,
                  ),
              filled: true,
              fillColor: widget.enabled ? Colors.white : AppColors.grey100,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 12.h,
              ),
              counterText: '',
              // Enabled border
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6.r),
                borderSide: BorderSide(
                  color: const Color(0x24000000),
                  width: 1,
                ),
              ),
              // Focused border
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6.r),
                borderSide: BorderSide(color: AppColors.primary, width: 1),
              ),
              // Error border
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6.r),
                borderSide: BorderSide(color: AppColors.error, width: 1),
              ),
              // Focused error border
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6.r),
                borderSide: BorderSide(color: AppColors.error, width: 1),
              ),
              // Disabled border
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6.r),
                borderSide: BorderSide(
                  color: const Color(0x24000000),
                  width: 1,
                ),
              ),
            ),
            style:
                widget.textStyle ??
                AppTextStyles.getMontserratStyle(
                  14.sp,
                  FontWeight.w500,
                  AppColors.black,
                ),
            dropdownTextStyle: AppTextStyles.getMontserratStyle(
              14.sp,
              FontWeight.w500,
              AppColors.black,
            ),
            dropdownIcon: Icon(
              Icons.arrow_drop_down,
              color: AppColors.grey500,
              size: 24.sp,
            ),
            flagsButtonPadding: EdgeInsets.only(left: 8.w),
            dropdownIconPosition: IconPosition.trailing,
            showCountryFlag: true,
            showDropdownIcon: true,
            keyboardType: TextInputType.phone,
            onChanged: widget.onChanged,
            onCountryChanged: (country) {
              if (widget.onCountryChanged != null) {
                widget.onCountryChanged!(country.code);
              }
            },
            disableLengthCheck: true, // Allow flexible length based on country
          ),
        ),
        // Error text
        if (widget.errorText != null && widget.errorText!.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: 6.h, left: 4.w),
            child: Row(
              children: [
                Icon(Icons.error_outline, size: 14.sp, color: AppColors.error),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    widget.errorText!,
                    style: AppTextStyles.getMontserratStyle(
                      12.sp,
                      FontWeight.w400,
                      AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
