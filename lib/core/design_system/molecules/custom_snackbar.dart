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
        type: type,
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
          leftBarColor: const Color(0xFF059669), // Green
          backgroundColor: const Color(0xFFD1FAE5), // Light green
          borderColor: const Color(0xFF059669),
        );
      case SnackbarType.error:
        return _SnackbarConfig(
          leftBarColor: const Color(0xFFDC2626), // Red
          backgroundColor: const Color(0xFFFEE2E2), // Light red
          borderColor: const Color(0xFFDC2626),
        );
      case SnackbarType.warning:
        return _SnackbarConfig(
          leftBarColor: const Color(0xFFD97706), // Orange/Amber
          backgroundColor: const Color(0xFFFEF3C7), // Light yellow
          borderColor: const Color(0xFFD97706),
        );
      case SnackbarType.info:
        return _SnackbarConfig(
          leftBarColor: const Color(0xFF2563EB), // Blue
          backgroundColor: const Color(0xFFDCEFFF), // Light blue
          borderColor: const Color(0xFF2563EB),
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
  final SnackbarType type;
  final Color leftBarColor;
  final Color backgroundColor;
  final Color borderColor;
  final Duration duration;
  final bool showProgressBar;
  final VoidCallback? onTap;

  const _CustomSnackbarContent({
    required this.message,
    required this.type,
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
        margin: EdgeInsets.only(top: 8.h, left: 16.w, right: 16.w),
        child: Container(
          height: 40.h,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(40.r),
            border: Border.all(color: widget.borderColor, width: 1.w),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                offset: const Offset(0, 2),
                blurRadius: 8,
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            children: [
              // Icon based on type
              _buildIcon(),

              SizedBox(width: 12.w),

              // Message text
              Expanded(
                child: Text(
                  widget.message,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: widget.leftBarColor,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              SizedBox(width: 12.w),

              // Close icon
              GestureDetector(
                onTap: () {
                  Get.back();
                },
                child: Icon(
                  Icons.close,
                  size: 18.r,
                  color: widget.leftBarColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    IconData iconData;

    switch (widget.type) {
      case SnackbarType.success:
        iconData = Icons.check_circle;
        break;
      case SnackbarType.error:
        iconData = Icons.cancel;
        break;
      case SnackbarType.warning:
        iconData = Icons.warning;
        break;
      case SnackbarType.info:
        iconData = Icons.info;
        break;
    }

    return Icon(iconData, size: 20.r, color: widget.leftBarColor);
  }
}
