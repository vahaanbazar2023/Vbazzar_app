import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/app_colors.dart';
import '../typography/app_text_styles.dart';

/// Custom autocomplete field with search and filtering
///
/// Design specs:
/// - Border: 1px solid #00000024
/// - Box shadow: 0px 1px 2px 0px #E4E5E73D
/// - Height: 46px
/// - Matches CustomInputField design
///
/// Features:
/// - Real-time search with filtering
/// - Dynamic error state with error message
/// - Custom prefix icon
/// - Loading state
/// - Force selection mode (user must select from list)
/// - Clear button when text is entered
///
/// Usage:
/// ```dart
/// CustomAutocompleteField<StateModel>(
///   controller: stateController,
///   placeholder: 'Select State',
///   prefixIcon: Icons.location_on_outlined,
///   errorText: stateError,
///   isLoading: isLoadingStates,
///   options: availableStates,
///   displayStringForOption: (state) => state.stateName,
///   onSelected: (state) => controller.onStateSelected(state),
/// )
/// ```
class CustomAutocompleteField<T extends Object> extends StatefulWidget {
  /// Text controller for the input field
  final TextEditingController controller;

  /// List of options to display
  final List<T> options;

  /// Placeholder text when field is empty
  final String placeholder;

  /// Error message to display below the field
  final String? errorText;

  /// Icon to display at the start of the field
  final IconData? prefixIcon;

  /// Function to get display text from option
  final String Function(T) displayStringForOption;

  /// Callback when option is selected
  final ValueChanged<T?>? onSelected;

  /// Callback when text changes
  final ValueChanged<String>? onChanged;

  /// Whether the dropdown is loading
  final bool isLoading;

  /// Message to display when options list is empty
  final String? emptyMessage;

  /// Whether the field is enabled
  final bool enabled;

  /// Custom height (default: 46.h)
  final double? height;

  /// Whether user must select from list (clears invalid input on blur)
  final bool forceSelection;

  /// Search hint text
  final String searchHint;

  /// Maximum height of dropdown
  final double maxDropdownHeight;

  const CustomAutocompleteField({
    super.key,
    required this.controller,
    required this.options,
    required this.placeholder,
    required this.displayStringForOption,
    this.errorText,
    this.prefixIcon,
    this.onSelected,
    this.onChanged,
    this.isLoading = false,
    this.emptyMessage,
    this.enabled = true,
    this.height,
    this.forceSelection = true,
    this.searchHint = 'Search...',
    this.maxDropdownHeight = 200,
  });

  @override
  State<CustomAutocompleteField<T>> createState() =>
      _CustomAutocompleteFieldState<T>();
}

class _CustomAutocompleteFieldState<T extends Object>
    extends State<CustomAutocompleteField<T>> {
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  List<T> _filteredOptions = [];
  T? _selectedOption;

  bool get _hasError =>
      widget.errorText != null && widget.errorText!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _filteredOptions = widget.options;
    _focusNode.addListener(_onFocusChange);
    widget.controller.addListener(_onTextChange);
  }

  @override
  void didUpdateWidget(CustomAutocompleteField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.options != oldWidget.options) {
      _filteredOptions = widget.options;
      if (_overlayEntry != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _overlayEntry != null) {
            _overlayEntry!.markNeedsBuild();
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    widget.controller.removeListener(_onTextChange);
    _focusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _showOverlay();
    } else {
      _removeOverlay();
      // Validate selection if forceSelection is enabled
      if (widget.forceSelection && widget.controller.text.isNotEmpty) {
        final isValid = widget.options.any(
          (option) =>
              widget.displayStringForOption(option).toLowerCase() ==
              widget.controller.text.toLowerCase(),
        );
        if (!isValid) {
          widget.controller.clear();
          widget.onSelected?.call(null);
        }
      }
    }
    setState(() {}); // Rebuild to update border color
  }

  void _onTextChange() {
    final query = widget.controller.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredOptions = widget.options;
      } else {
        _filteredOptions = widget.options.where((option) {
          final optionText = widget
              .displayStringForOption(option)
              .toLowerCase();
          return optionText.contains(query);
        }).toList();
      }
    });

    if (_overlayEntry != null) {
      _overlayEntry!.markNeedsBuild();
    }

    widget.onChanged?.call(widget.controller.text);
  }

  void _showOverlay() {
    if (_overlayEntry != null) return;

    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 4.h),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(8.r),
            child: _buildDropdown(),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Widget _buildDropdown() {
    if (widget.isLoading) {
      return Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(color: AppColors.white),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20.w,
              height: 20.h,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              'Loading...',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      );
    }

    if (_filteredOptions.isEmpty) {
      return Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          widget.controller.text.isEmpty
              ? (widget.emptyMessage ?? 'No options available')
              : 'No results found for "${widget.controller.text}"',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            fontSize: 14.sp,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Container(
      constraints: BoxConstraints(maxHeight: widget.maxDropdownHeight.h),
      decoration: BoxDecoration(color: AppColors.white),
      child: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        shrinkWrap: true,
        itemCount: _filteredOptions.length,
        itemBuilder: (context, index) {
          final option = _filteredOptions[index];
          final displayText = widget.displayStringForOption(option);
          final isSelected = _selectedOption == option;

          return InkWell(
            onTap: () {
              setState(() {
                _selectedOption = option;
                widget.controller.text = displayText;
              });
              widget.onSelected?.call(option);
              _focusNode.unfocus();
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      displayText,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 14.sp,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Icon(Icons.check, color: AppColors.primary, size: 20.sp),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CompositedTransformTarget(
          link: _layerLink,
          child: Container(
            height: widget.height ?? 46.h,
            decoration: BoxDecoration(
              color: widget.enabled ? AppColors.white : AppColors.grey100,

              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE4E5E7).withOpacity(0.24),
                  offset: const Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              enabled: widget.enabled && !widget.isLoading,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                hintText: widget.placeholder,
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: widget.prefixIcon != null
                    ? Icon(
                        widget.prefixIcon,
                        size: 20.sp,
                        color: _hasError
                            ? AppColors.error
                            : widget.enabled
                            ? AppColors.textSecondary
                            : AppColors.textDisabled,
                      )
                    : null,
                suffixIcon: widget.controller.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          size: 20.sp,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () {
                          widget.controller.clear();
                          _selectedOption = null;
                          widget.onSelected?.call(null);
                          _focusNode.unfocus();
                        },
                      )
                    : widget.isLoading
                    ? Padding(
                        padding: EdgeInsets.all(12.w),
                        child: SizedBox(
                          width: 20.w,
                          height: 20.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                          ),
                        ),
                      )
                    : Icon(
                        Icons.keyboard_arrow_down,
                        size: 20.sp,
                        color: widget.enabled
                            ? AppColors.textSecondary
                            : AppColors.textDisabled,
                      ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 12.h,
                ),
              ),
            ),
          ),
        ),

        // Error Text
        if (_hasError) ...[
          SizedBox(height: 4.h),
          Text(
            widget.errorText!,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.error,
              fontSize: 12.sp,
            ),
          ),
        ],
      ],
    );
  }
}
