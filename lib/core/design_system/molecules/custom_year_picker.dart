import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../core/constants/app_colors.dart';
import '../../../theme/app_fonts.dart';

class CustomYearPicker extends StatefulWidget {
  final String labelText;
  final String hintText;
  final String? selectedYear;
  final Function(String) onYearSelected;
  final String? errorText;
  final int? startYear;
  final int? endYear;
  final Color? labelColor;
  final Color? borderColor;
  final Color? fillColor;
  final String? prefixIcon;

  const CustomYearPicker({
    super.key,
    required this.labelText,
    required this.hintText,
    required this.onYearSelected,
    this.selectedYear,
    this.errorText,
    this.startYear,
    this.endYear,
    this.labelColor,
    this.borderColor,
    this.fillColor,
    this.prefixIcon,
  });

  @override
  State<CustomYearPicker> createState() => _CustomYearPickerState();
}

class _CustomYearPickerState extends State<CustomYearPicker> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.selectedYear ?? '');
  }

  @override
  void didUpdateWidget(CustomYearPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedYear != widget.selectedYear) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _controller.text = widget.selectedYear ?? '';
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentYear = DateTime.now().year;
    final startYr = widget.startYear ?? 1900;
    final endYr = widget.endYear ?? currentYear;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.labelText,
          style: AppFonts.labelMedium.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 6.h),
        GestureDetector(
          onTap: () => _showYearPicker(context, startYr, endYr),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: 14.w,
              vertical: 14.h,
            ),
            decoration: BoxDecoration(
              color: widget.fillColor ?? AppColors.white,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: widget.borderColor ?? AppColors.grey300,
              ),
            ),
            child: Row(
              children: [
                if (widget.prefixIcon != null) ...[
                  SvgPicture.asset(
                    widget.prefixIcon!,
                    height: 20.r,
                    width: 20.r,
                  ),
                  SizedBox(width: 10.w),
                ],
                Expanded(
                  child: Text(
                    (widget.selectedYear != null &&
                            widget.selectedYear!.isNotEmpty)
                        ? widget.selectedYear!
                        : widget.hintText,
                    style: AppFonts.bodyMedium.copyWith(
                      color: (widget.selectedYear != null &&
                              widget.selectedYear!.isNotEmpty)
                          ? AppColors.textPrimary
                          : AppColors.textDisabled,
                    ),
                  ),
                ),
                if (widget.selectedYear != null &&
                    widget.selectedYear!.isNotEmpty)
                  GestureDetector(
                    onTap: () => widget.onYearSelected(''),
                    child: Icon(
                      Icons.clear,
                      size: 20.r,
                      color: AppColors.textSecondary,
                    ),
                  ),
                SizedBox(width: 4.w),
                Icon(
                  Icons.calendar_today,
                  size: 18.r,
                  color: AppColors.grey500,
                ),
              ],
            ),
          ),
        ),
        if (widget.errorText != null)
          Padding(
            padding: EdgeInsets.only(top: 4.h, left: 14.w),
            child: Text(
              widget.errorText!,
              style: AppFonts.bodySmall.copyWith(color: AppColors.error),
            ),
          ),
      ],
    );
  }

  void _showYearPicker(BuildContext context, int startYear, int endYear) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Select Year',
                  style: AppFonts.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 20.h),
                SizedBox(
                  height: 300.h,
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: (endYear - startYear + 1),
                    itemBuilder: (context, index) {
                      final year = (endYear - index).toString();
                      final isSelected = widget.selectedYear == year;

                      return InkWell(
                        onTap: () {
                          widget.onYearSelected(year);
                          Navigator.of(context).pop();
                        },
                        borderRadius: BorderRadius.circular(8.r),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.white,
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.grey300,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              year,
                              style: AppFonts.bodyMedium.copyWith(
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 20.h),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        side: BorderSide(color: AppColors.grey300),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: AppFonts.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}