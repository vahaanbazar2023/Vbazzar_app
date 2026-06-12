import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_colors.dart';

/// 6-step progress indicator for the agent inspection form.
class InspectionStepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String> stepLabels;
  final ValueChanged<int>? onStepTap;

  const InspectionStepIndicator({
    super.key,
    required this.currentStep,
    this.totalSteps = 6,
    required this.stepLabels,
    this.onStepTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Step indicators row
          Row(
            children: List.generate(totalSteps, (index) {
              final isActive = index == currentStep;
              final isCompleted = index < currentStep;
              return Expanded(
                child: GestureDetector(
                  onTap: onStepTap != null ? () => onStepTap!(index) : null,
                  child: Row(
                    children: [
                      // Circle
                      Container(
                        width: 28.r,
                        height: 28.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCompleted
                              ? AppColors.success
                              : isActive
                                  ? AppColors.primary
                                  : AppColors.grey200,
                          border: isActive
                              ? Border.all(
                                  color: AppColors.primaryDark,
                                  width: 2,
                                )
                              : null,
                        ),
                        child: Center(
                          child: isCompleted
                              ? Icon(
                                  Icons.check,
                                  size: 14.r,
                                  color: AppColors.white,
                                )
                              : Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w600,
                                    color: isActive
                                        ? AppColors.white
                                        : AppColors.grey500,
                                  ),
                                ),
                        ),
                      ),
                      // Line connector
                      if (index < totalSteps - 1)
                        Expanded(
                          child: Container(
                            height: 2,
                            color: isCompleted
                                ? AppColors.success
                                : AppColors.grey200,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: 8.h),
          // Step label
          Text(
            stepLabels.length > currentStep
                ? stepLabels[currentStep]
                : 'Step ${currentStep + 1}',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}