import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/app_colors.dart';
import '../typography/app_text_styles.dart';

/// Custom dropdown field with search functionality
///
/// Design specs:
/// - Border: 1px solid #00000024
/// - Box shadow: 0px 1px 2px 0px #E4E5E73D
/// - Height: 46px
/// - Matches CustomInputField design
///
/// Features:
/// - Searchable dropdown
/// - Dynamic error state with error message
/// - Custom prefix icon
/// - Loading state
/// - Optional empty state message
///
/// Usage:
/// ```dart
/// CustomDropdownField<StateModel>(
///   value: selectedState,
///   items: states,
///   placeholder: 'Select State',
///   prefixIcon: Icons.location_on_outlined,
///   errorText: stateError,
///   isLoading: isLoadingStates,
///   onChanged: (state) => controller.onStateSelected(state),
/// )
/// ```
class CustomDropdownField<T> extends StatefulWidget {
  /// Currently selected value
  final T? value;

  /// List of items to display in dropdown
  final List<T> items;

  /// Placeholder text when no value is selected
  final String placeholder;

  /// Error message to display below the field
  final String? errorText;

  /// Icon to display at the start of the field
  final IconData? prefixIcon;

  /// Callback when value changes
  final ValueChanged<T?>? onChanged;

  /// Function to get display text from item
  final String Function(T)? itemLabel;

  /// Whether the dropdown is loading
  final bool isLoading;

  /// Message to display when items list is empty
  final String? emptyMessage;

  /// Whether the field is enabled
  final bool enabled;

  /// Custom height (default: 46.h)
  final double? height;

  /// Whether to show search field in dropdown
  final bool searchable;

  /// Search hint text
  final String searchHint;

  const CustomDropdownField({
    super.key,
    this.value,
    required this.items,
    required this.placeholder,
    this.errorText,
    this.prefixIcon,
    this.onChanged,
    this.itemLabel,
    this.isLoading = false,
    this.emptyMessage,
    this.enabled = true,
    this.height,
    this.searchable = true,
    this.searchHint = 'Search...',
  });

  @override
  State<CustomDropdownField<T>> createState() => _CustomDropdownFieldState<T>();
}

class _CustomDropdownFieldState<T> extends State<CustomDropdownField<T>> {
  bool _isFocused = false;
  final GlobalKey _fieldKey = GlobalKey();

  bool get _hasError =>
      widget.errorText != null && widget.errorText!.isNotEmpty;

  Color get _borderColor {
    if (!widget.enabled) return AppColors.border;
    if (_hasError) return AppColors.error;
    if (_isFocused) return AppColors.primary;
    return AppColors.border;
  }

  String _getItemLabel(T item) {
    if (widget.itemLabel != null) {
      return widget.itemLabel!(item);
    }
    return item.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          key: _fieldKey,
          onTap: widget.enabled && !widget.isLoading ? _showDropdown : null,
          borderRadius: BorderRadius.circular(6.r),
          child: Container(
            height: widget.height ?? 46.h,
            decoration: BoxDecoration(
              color: widget.enabled ? AppColors.white : AppColors.grey100,
              border: Border.all(color: _borderColor, width: 1),
              borderRadius: BorderRadius.circular(6.r),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE4E5E7).withOpacity(0.24),
                  offset: const Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Row(
                children: [
                  // Prefix Icon
                  if (widget.prefixIcon != null) ...[
                    Icon(
                      widget.prefixIcon,
                      size: 20.sp,
                      color: _hasError
                          ? AppColors.error
                          : widget.enabled
                          ? AppColors.textSecondary
                          : AppColors.textDisabled,
                    ),
                    SizedBox(width: 8.w),
                  ],

                  // Display Text
                  Expanded(
                    child: widget.isLoading
                        ? Row(
                            children: [
                              SizedBox(
                                width: 16.w,
                                height: 16.h,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primary,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'Loading...',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            widget.value != null
                                ? _getItemLabel(widget.value as T)
                                : widget.placeholder,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: widget.value != null
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                  ),

                  // Suffix Icon (dropdown arrow)
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 20.sp,
                    color: widget.enabled
                        ? AppColors.textSecondary
                        : AppColors.textDisabled,
                  ),
                ],
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

  void _showDropdown() async {
    setState(() => _isFocused = true);

    if (widget.items.isEmpty) {
      // Show empty message
      _showEmptyDialog();
      setState(() => _isFocused = false);
      return;
    }

    // Get the position and size of the field
    final RenderBox? renderBox =
        _fieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      setState(() => _isFocused = false);
      return;
    }

    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    final result = await showDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      builder: (context) => Stack(
        children: [
          // Invisible barrier to dismiss
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(color: Colors.transparent),
            ),
          ),
          // Dropdown positioned below the field
          Positioned(
            left: offset.dx,
            top: offset.dy + size.height + 4.h,
            width: size.width,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(8.r),
              child: _DropdownMenu<T>(
                items: widget.items,
                selectedValue: widget.value,
                itemLabel: _getItemLabel,
                searchable: widget.searchable,
                searchHint: widget.searchHint,
                maxHeight: 300.h,
              ),
            ),
          ),
        ],
      ),
    );

    setState(() => _isFocused = false);

    if (result != null && widget.onChanged != null) {
      widget.onChanged!(result);
    }
  }

  void _showEmptyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'No Items Available',
          style: AppTextStyles.headingMedium.copyWith(fontSize: 18.sp),
        ),
        content: Text(
          widget.emptyMessage ?? 'No items to display.',
          style: AppTextStyles.bodyMedium.copyWith(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DropdownMenu<T> extends StatefulWidget {
  final List<T> items;
  final T? selectedValue;
  final String Function(T) itemLabel;
  final bool searchable;
  final String searchHint;
  final double maxHeight;

  const _DropdownMenu({
    required this.items,
    required this.selectedValue,
    required this.itemLabel,
    required this.searchable,
    required this.searchHint,
    required this.maxHeight,
  });

  @override
  State<_DropdownMenu<T>> createState() => _DropdownMenuState<T>();
}

class _DropdownMenuState<T> extends State<_DropdownMenu<T>> {
  late List<T> _filteredItems;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredItems = widget.items.where((item) {
        final label = widget.itemLabel(item).toLowerCase();
        return label.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: widget.maxHeight),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Search Field
          if (widget.searchable) ...[
            Padding(
              padding: EdgeInsets.all(12.w),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: widget.searchHint,
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 14.sp,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    size: 20.sp,
                    color: AppColors.textSecondary,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6.r),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6.r),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6.r),
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                  isDense: true,
                ),
                style: AppTextStyles.bodyMedium.copyWith(fontSize: 14.sp),
              ),
            ),
            Divider(height: 1, color: AppColors.border),
          ],

          // Items List
          Flexible(
            child: _filteredItems.isEmpty
                ? Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Text(
                      'No results found',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 14.sp,
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.symmetric(vertical: 4.h),
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = _filteredItems[index];
                      final isSelected = item == widget.selectedValue;

                      return InkWell(
                        onTap: () => Navigator.pop(context, item),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 12.h,
                          ),
                          color: isSelected
                              ? AppColors.primary.withOpacity(0.1)
                              : null,
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.itemLabel(item),
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
                                Icon(
                                  Icons.check,
                                  color: AppColors.primary,
                                  size: 20.sp,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
