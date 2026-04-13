import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../constants/app_assets.dart';
import '../../constants/app_colors.dart';
import '../typography/app_text_styles.dart';

enum SnackbarType { success, error, warning, info }

class CustomSnackbar {
  CustomSnackbar._();

  /// Show a custom snackbar with specified type and message
  static void show({
    required String message,
    String? title,
    SnackbarType type = SnackbarType.info,
    Duration duration = const Duration(seconds: 3),
    bool showProgressBar = true,
    VoidCallback? onTap,
  }) {
    final snackbarConfig = _getSnackbarConfig(type);

    Get.snackbar(
      '',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.transparent,
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      duration: duration,
      borderRadius: 0,
      overlayBlur: 0,
      isDismissible: true,
      dismissDirection: DismissDirection.up,
      messageText: _CustomSnackbarContent(
        message: message,
        leftBarColor: snackbarConfig.leftBarColor,
        backgroundColor: snackbarConfig.backgroundColor,
        borderColor: snackbarConfig.borderColor,
        duration: duration,
        showProgressBar: showProgressBar,
        onTap: onTap,
      ),
      titleText: const SizedBox.shrink(),
    );
  }

  static _SnackbarConfig _getSnackbarConfig(SnackbarType type) {
    switch (type) {
      case SnackbarType.success:
        return _SnackbarConfig(
          leftBarColor: AppColors.success,
          backgroundColor: AppColors.successBackground,
          borderColor: AppColors.success.withOpacity(0.3),
        );
      case SnackbarType.error:
        return _SnackbarConfig(
          leftBarColor: AppColors.warning,
          backgroundColor: AppColors.warningBackground,
          borderColor: AppColors.warningBorder,
        );
      case SnackbarType.warning:
        return _SnackbarConfig(
          leftBarColor: AppColors.warning,
          backgroundColor: AppColors.warningBackground,
          borderColor: AppColors.warningBorder,
        );
      case SnackbarType.info:
        return _SnackbarConfig(
          leftBarColor: AppColors.success,
          backgroundColor: AppColors.successBackground,
          borderColor: AppColors.success.withOpacity(0.3),
        );
    }
  }
}

class _SnackbarConfig {
  final Color leftBarColor;
  final Color backgroundColor;
  final Color borderColor;

  _SnackbarConfig({
    required this.leftBarColor,
    required this.backgroundColor,
    required this.borderColor,
  });
}

class _CustomSnackbarContent extends StatefulWidget {
  final String message;
  final Color leftBarColor;
  final Color backgroundColor;
  final Color borderColor;
  final Duration duration;
  final bool showProgressBar;
  final VoidCallback? onTap;

  const _CustomSnackbarContent({
    required this.message,
    required this.leftBarColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.duration,
    required this.showProgressBar,
    this.onTap,
  });

  @override
  State<_CustomSnackbarContent> createState() => _CustomSnackbarContentState();
}

class _CustomSnackbarContentState extends State<_CustomSnackbarContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _progressAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.linear),
    );

    if (widget.showProgressBar) {
      _progressController.forward();
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: EdgeInsets.only(top: 4.h, left: 17.w, right: 17.w),
        child: Stack(
          children: [
            // Main snackbar container
            Container(
              width: 379.w,
              height: 52.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.r),
                border: Border.all(color: widget.borderColor, width: 1.w),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Left color bar (5% width)
                  Container(
                    width: 379.w * 0.02,
                    height: 52.h,
                    decoration: BoxDecoration(
                      color: widget.leftBarColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(4.r),
                        bottomLeft: Radius.circular(4.r),
                      ),
                    ),
                  ),

                  // Main content container (95% width)
                  Expanded(
                    child: Container(
                      height: 52.h,
                      decoration: BoxDecoration(
                        color: widget.backgroundColor,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(4.r),
                          bottomRight: Radius.circular(4.r),
                        ),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
                      child: Row(
                        children: [
                          // Message text
                          Expanded(
                            child: Text(
                              widget.message,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.black,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          SizedBox(width: 8.w),

                          // Close icon (cancel.svg)
                          GestureDetector(
                            onTap: () {
                              Get.back();
                            },
                            child: SvgPicture.asset(
                              AppAssets.cancel,
                              width: 16.w,
                              height: 16.h,
                              colorFilter: ColorFilter.mode(
                                AppColors.grey650,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Progress bar at the bottom
            if (widget.showProgressBar)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return ClipRRect(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(4.r),
                        bottomRight: Radius.circular(4.r),
                      ),
                      child: LinearProgressIndicator(
                        value: _progressAnimation.value,
                        minHeight: 3.h,
                        backgroundColor: widget.leftBarColor.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          widget.leftBarColor.withOpacity(0.6),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
