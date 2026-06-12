import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_colors.dart';

/// Reusable condition rating selector with selectable chips.
/// Options: Excellent, Good, Average, Poor
class ConditionRatingWidget extends StatelessWidget {
  final String label;
  final String selectedValue;
  final ValueChanged<String> onChanged;
  final List<String> options;

  const ConditionRatingWidget({
    super.key,
    required this.label,
    required this.selectedValue,
    required this.onChanged,
    this.options = const ['Excellent', 'Good', 'Average', 'Poor'],
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: options.map((option) {
            final isSelected = selectedValue == option;
            return GestureDetector(
              onTap: () => onChanged(option),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(
                  horizontal: 14.w,
                  vertical: 8.h,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? _getColorForOption(option).withOpacity(0.15)
                      : AppColors.grey50,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isSelected
                        ? _getColorForOption(option)
                        : AppColors.grey300,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected)
                      Padding(
                        padding: EdgeInsets.only(right: 4.w),
                        child: Icon(
                          Icons.check_circle,
                          size: 14.r,
                          color: _getColorForOption(option),
                        ),
                      ),
                    Text(
                      option,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected
                            ? _getColorForOption(option)
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _getColorForOption(String option) {
    switch (option.toLowerCase()) {
      case 'excellent':
        return AppColors.success;
      case 'good':
        return const Color(0xFF2196F3); // Blue
      case 'average':
        return AppColors.warning;
      case 'poor':
        return AppColors.error;
      default:
        return AppColors.grey500;
    }
  }
}