import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/app_colors.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_sizes.dart';
import '../tokens/app_spacing.dart';
import '../typography/app_text_styles.dart';

/// Search bar molecule component
/// Specialized text field for search functionality
class AppSearchBar extends StatefulWidget {
  final TextEditingController? controller;
  final String? hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final bool showFilter;
  final VoidCallback? onFilterTap;
  final bool autofocus;

  const AppSearchBar({
    super.key,
    this.controller,
    this.hint,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.showFilter = false,
    this.onFilterTap,
    this.autofocus = false,
  });

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
    _controller.addListener(_onTextChange);
    _hasText = _controller.text.isNotEmpty;
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _controller.removeListener(_onTextChange);
    _focusNode.dispose();
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _onTextChange() {
    setState(() {
      _hasText = _controller.text.isNotEmpty;
    });
  }

  void _clearText() {
    _controller.clear();
    widget.onClear?.call();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.inputMd.h,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderRadiusMd,
        border: Border.all(
          color: _isFocused ? AppColors.primary : AppColors.border,
          width: _isFocused
              ? AppSizes.borderWidthMedium
              : AppSizes.borderWidthThin,
        ),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          // Search icon
          Padding(
            padding: EdgeInsets.only(left: AppSpacing.md, right: AppSpacing.sm),
            child: Icon(
              Icons.search,
              color: _isFocused ? AppColors.primary : AppColors.grey400,
              size: AppSizes.iconMd,
            ),
          ),

          // Text field
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              autofocus: widget.autofocus,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              style: AppTextStyles.bodyMedium,
              decoration: InputDecoration(
                hintText: widget.hint ?? 'Search...',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.grey400,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),

          // Clear button
          if (_hasText)
            IconButton(
              icon: Icon(
                Icons.close,
                color: AppColors.grey400,
                size: AppSizes.iconSm,
              ),
              onPressed: _clearText,
              padding: EdgeInsets.all(AppSpacing.xs),
            ),

          // Filter button
          if (widget.showFilter)
            Container(
              margin: EdgeInsets.only(right: AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: AppRadius.borderRadiusSm,
              ),
              child: IconButton(
                icon: Icon(
                  Icons.tune,
                  color: AppColors.textPrimary,
                  size: AppSizes.iconSm,
                ),
                onPressed: widget.onFilterTap,
                padding: EdgeInsets.all(AppSpacing.xs),
              ),
            ),
        ],
      ),
    );
  }
}
