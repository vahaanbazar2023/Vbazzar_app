import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_colors.dart';

/// Reusable image upload section for the agent inspection form.
/// Shows a grid of image thumbnails with add/remove capability.
class ImageUploadSection extends StatelessWidget {
  final String title;
  final List<File> images;
  final VoidCallback onAdd;
  final Function(int) onRemove;
  final int maxImages;

  const ImageUploadSection({
    super.key,
    required this.title,
    required this.images,
    required this.onAdd,
    required this.onRemove,
    this.maxImages = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title row with count
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              '${images.length}/$maxImages',
              style: TextStyle(
                fontSize: 12.sp,
                color: images.length >= maxImages
                    ? AppColors.error
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),

        // Image grid + add button
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: [
            // Existing images
            ...List.generate(images.length, (index) {
              return _buildImageTile(images[index], index);
            }),
            // Add button (if under limit)
            if (images.length < maxImages) _buildAddButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildImageTile(File file, int index) {
    return Stack(
      children: [
        Container(
          width: 80.w,
          height: 80.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: AppColors.grey200),
            image: DecorationImage(
              image: FileImage(file),
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Remove button
        Positioned(
          top: 2,
          right: 2,
          child: GestureDetector(
            onTap: () => onRemove(index),
            child: Container(
              width: 22.r,
              height: 22.r,
              decoration: BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Icon(Icons.close, size: 14.r, color: AppColors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: onAdd,
      child: Container(
        width: 80.w,
        height: 80.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: AppColors.grey300,
            style: BorderStyle.solid,
          ),
          color: AppColors.grey50,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo, size: 24.r, color: AppColors.primary),
            SizedBox(height: 4.h),
            Text(
              'Add',
              style: TextStyle(
                fontSize: 10.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}