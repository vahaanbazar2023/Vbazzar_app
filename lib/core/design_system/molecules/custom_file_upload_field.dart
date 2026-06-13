import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:file_picker/file_picker.dart';

import '../../constants/app_colors.dart';
import '../../../theme/app_fonts.dart';

/// A custom file upload field with a dashed border design.
///
/// Displays a cloud upload icon with file type info inside a dashed border.
/// When files are selected, each file is shown below the upload area as a
/// card with a cross (X) icon to remove it.
///
/// Features:
/// - Dashed border upload area (always visible, allows adding more files)
/// - Multi-file support with individual file cards below
/// - Each file card shows icon, file name, file size, and remove button
/// - Error state with error message
/// - Consistent with the app's design system
///
/// Usage:
/// ```dart
/// CustomFileUploadField(
///   title: 'Upload RC Document',
///   label: 'Choose a file/browse multiple files',
///   subtitle: 'JPEG, PNG & PDF (up to 12 MB)',
///   onTap: () => controller.pickFiles(targetList),
///   files: controller.rcFiles,
///   onRemove: (index) => controller.removeFile(targetList, index),
///   errorText: errorText,
/// )
/// ```
class CustomFileUploadField extends StatelessWidget {
  /// Label text shown inside the dashed area
  final String label;

  /// Subtitle text describing allowed file types
  final String subtitle;

  /// Callback when the upload area is tapped
  final VoidCallback onTap;

  /// List of selected files (PlatformFile from file_picker)
  final List<PlatformFile> files;

  /// Callback to remove a file at the given index
  final Function(int)? onRemove;

  /// Error message to display below the field
  final String? errorText;

  /// Icon to display in the upload area
  final IconData icon;

  /// Accent color for the icon (defaults to AppColors.primary)
  final Color? accentColor;

  /// Whether multiple files are allowed
  final bool allowMultiple;

  /// Optional label displayed above the upload box
  final String? title;

  /// Height of the upload container
  final double? height;

  const CustomFileUploadField({
    super.key,
    required this.label,
    required this.onTap,
    required this.files,
    this.onRemove,
    this.errorText,
    this.subtitle = 'JPEG, PNG & PDF (up to 12 MB)',
    this.icon = Icons.cloud_upload,
    this.accentColor,
    this.allowMultiple = false,
    this.title,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Title label above the upload box ──
        if (title != null) ...[
          Text(
            title!,
            style: AppFonts.labelLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 6.h),
        ],

        // ── Upload area (always shows dashed border) ──
        GestureDetector(
          onTap: onTap,
          child: CustomPaint(
            painter: _DashedBorderPainter(
              color: errorText != null && errorText!.isNotEmpty
                  ? AppColors.error
                  : AppColors.grey400,
              radius: 12.r,
              dashWidth: 6,
              dashSpace: 4,
              strokeWidth: 1.5,
            ),
            child: Container(
              width: double.infinity,
              height: height ?? 120.h,
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: _buildEmptyState(),
            ),
          ),
        ),

        // ── Uploaded file cards below the upload area ──
        if (files.isNotEmpty) ...[
          SizedBox(height: 8.h),
          ...List.generate(files.length, (index) {
            return Padding(
              padding: EdgeInsets.only(bottom: 6.h),
              child: _buildFileCard(files[index], index),
            );
          }),
        ],

        // ── Error text ──
        if (errorText != null && errorText!.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: 6.h, left: 4.w),
            child: Text(
              errorText!,
              style: AppFonts.bodySmall.copyWith(
                color: AppColors.error,
                fontSize: 12.sp,
              ),
            ),
          ),
      ],
    );
  }

  /// Empty state inside the dashed upload area
  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Upload icon
        Icon(icon, size: 40.sp, color: accentColor ?? AppColors.primary),
        SizedBox(height: 12.h),

        // Label text
        Text(
          label,
          style: AppFonts.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8.h),

        // Subtitle / file type info
        Text(
          subtitle,
          style: AppFonts.bodySmall.copyWith(
            color: AppColors.grey500,
            fontSize: 12.sp,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Individual file card shown below the upload area
  Widget _buildFileCard(PlatformFile file, int index) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.grey200, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── File type icon ──
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: _getFileColor(file.name).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Center(child: _buildFileIcon(file.name)),
          ),
          SizedBox(width: 12.w),

          // ── File info ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  style: AppFonts.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                SizedBox(height: 3.h),
                Text(
                  _formatFileSize(file.size),
                  style: AppFonts.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),

          // ── Remove (X) button ──
          if (onRemove != null)
            GestureDetector(
              onTap: () => onRemove!(index),
              child: Container(
                width: 28.w,
                height: 28.w,
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(Icons.close, color: AppColors.error, size: 16.sp),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getFileColor(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return AppColors.error;
      case 'png':
      case 'jpg':
      case 'jpeg':
      case 'gif':
      case 'bmp':
      case 'webp':
        return AppColors.primary;
      case 'mp4':
      case 'mov':
      case 'avi':
        return AppColors.secondary;
      default:
        return AppColors.textSecondary;
    }
  }

  Widget _buildFileIcon(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    IconData iconData;
    Color iconColor;

    switch (ext) {
      case 'pdf':
        iconData = Icons.picture_as_pdf;
        iconColor = AppColors.error;
        break;
      case 'png':
      case 'jpg':
      case 'jpeg':
      case 'gif':
      case 'bmp':
      case 'webp':
        iconData = Icons.image;
        iconColor = AppColors.primary;
        break;
      case 'mp4':
      case 'mov':
      case 'avi':
        iconData = Icons.videocam;
        iconColor = AppColors.secondary;
        break;
      default:
        iconData = Icons.insert_drive_file;
        iconColor = AppColors.textSecondary;
    }

    return Icon(iconData, color: iconColor, size: 22.sp);
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

/// Custom painter for dashed border effect.
/// Avoids the need for the dotted_border package.
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double dashWidth;
  final double dashSpace;
  final double strokeWidth;

  _DashedBorderPainter({
    required this.color,
    this.radius = 12,
    this.dashWidth = 6,
    this.dashSpace = 4,
    this.strokeWidth = 1.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rect);
    final pathMetrics = path.computeMetrics().first;
    double distance = 0;

    while (distance < pathMetrics.length) {
      final segment = pathMetrics.extractPath(distance, distance + dashWidth);
      canvas.drawPath(segment, paint);
      distance += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.radius != radius ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.dashSpace != dashSpace ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
