import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

/// A dropdown that expands inline below the field.
/// The main page scroll view handles scrolling naturally.
class InlineDropdownField<T> extends StatefulWidget {
  const InlineDropdownField({
    super.key,
    this.value,
    required this.items,
    required this.placeholder,
    this.label,
    this.errorText,
    this.prefixIcon,
    this.onChanged,
    this.itemLabel,
    this.isLoading = false,
    this.emptyMessage,
    this.enabled = true,
    this.height,
    this.maxDropdownHeight = 260,
  });

  final T? value;
  final List<T> items;
  final String placeholder;
  final String? label;
  final String? errorText;
  final IconData? prefixIcon;
  final ValueChanged<T?>? onChanged;
  final String Function(T)? itemLabel;
  final bool isLoading;
  final String? emptyMessage;
  final bool enabled;
  final double? height;
  final double maxDropdownHeight;

  @override
  State<InlineDropdownField<T>> createState() => _InlineDropdownFieldState<T>();
}

class _InlineDropdownFieldState<T> extends State<InlineDropdownField<T>>
    with SingleTickerProviderStateMixin {
  bool _isOpen = false;
  AnimationController? _animController;
  Animation<double>? _expandAnimation;

  AnimationController get _anim => _animController!;
  Animation<double> get _expand => _expandAnimation!;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _expandAnimation = CurvedAnimation(
      parent: _animController!,
      curve: Curves.easeInOut,
    );
  }

  @override
  void didUpdateWidget(InlineDropdownField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Close dropdown if items change
    if (oldWidget.items != widget.items && _isOpen) {
      _closeDropdown();
    }
  }

  @override
  void dispose() {
    _animController?.dispose();
    super.dispose();
  }

  String _labelOf(T item) {
    return widget.itemLabel?.call(item) ?? item.toString();
  }

  void _toggleDropdown() {
    if (!widget.enabled || widget.isLoading) return;

    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    setState(() {
      _isOpen = !_isOpen;
    });

    if (_isOpen) {
      _anim.forward();
    } else {
      _anim.reverse();
    }
  }

  void _closeDropdown() {
    if (!_isOpen) return;
    setState(() {
      _isOpen = false;
    });
    _anim.reverse();
  }

  void _selectItem(T item) {
    _closeDropdown();
    widget.onChanged?.call(item);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool hasError =
        widget.errorText != null && widget.errorText!.trim().isNotEmpty;

    Color borderColor = AppColors.border;
    if (!widget.enabled) {
      borderColor = AppColors.border;
    } else if (hasError) {
      borderColor = AppColors.error;
    } else if (_isOpen) {
      borderColor = AppColors.primary;
    }

    final int itemCount = widget.items.isEmpty ? 1 : widget.items.length;
    final double estimatedItemHeight = 48.0;
    final double dividerHeight = 1.0;
    final double estimatedListHeight =
        itemCount * estimatedItemHeight + (itemCount - 1) * dividerHeight + 8;
    final double expandedHeight = estimatedListHeight > widget.maxDropdownHeight
        ? widget.maxDropdownHeight
        : estimatedListHeight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (widget.label != null && widget.label!.trim().isNotEmpty) ...<Widget>[
          Text(
            widget.label!,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
        ],
        GestureDetector(
          onTap: _toggleDropdown,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            height: widget.height ?? 52,
            decoration: BoxDecoration(
              color: widget.enabled
                  ? AppColors.surface
                  : AppColors.white,
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(14),
              boxShadow: <BoxShadow>[
                if (_isOpen)
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: <Widget>[
                  if (widget.prefixIcon != null) ...<Widget>[
                    Icon(
                      widget.prefixIcon,
                      size: 20,
                      color: hasError
                          ? AppColors.error
                          : widget.enabled
                              ? AppColors.textSecondary
                              : AppColors.border,
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: widget.isLoading
                        ? Row(
                            children: <Widget>[
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Loading...',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            widget.value != null
                                ? _labelOf(widget.value as T)
                                : widget.placeholder,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: widget.value != null
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                  ),
                  AnimatedRotation(
                    turns: _isOpen ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Inline expanding list below the field
        SizeTransition(
          sizeFactor: _expand,
          axisAlignment: -1,
          child: Container(
            constraints: BoxConstraints(maxHeight: expandedHeight),
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.5),
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: widget.items.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 16,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.info_outline,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.emptyMessage ?? 'No items available',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      itemCount: widget.items.length,
                      separatorBuilder: (BuildContext context, int index) {
                        return Divider(
                          height: 1,
                          thickness: 1,
                          indent: 16,
                          endIndent: 16,
                          color: AppColors.border.withValues(alpha: 0.3),
                        );
                      },
                      itemBuilder: (BuildContext context, int index) {
                        final T item = widget.items[index];
                        final bool isSelected = item == widget.value;

                        return InkWell(
                          onTap: () => _selectItem(item),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            color: isSelected
                                ? AppColors.primary.withValues(alpha: 0.08)
                                : null,
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    _labelOf(item),
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.textPrimary,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check_circle,
                                    size: 18,
                                    color: AppColors.primary,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ),
        if (hasError) ...<Widget>[
          const SizedBox(height: 5),
          Text(
            widget.errorText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}