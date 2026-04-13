import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/app_colors.dart';
import '../atoms/app_text.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_sizes.dart';

/// Product tile organism
/// Complex component for displaying product/vehicle items
class ProductTile extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String? subtitle;
  final String price;
  final String? location;
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;
  final List<String>? tags;

  const ProductTile({
    super.key,
    required this.imageUrl,
    required this.title,
    this.subtitle,
    required this.price,
    this.location,
    this.isFavorite = false,
    this.onTap,
    this.onFavoriteTap,
    this.tags,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.borderRadiusMd,
          border: Border.all(
            color: AppColors.border,
            width: AppSizes.borderWidthThin,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            Stack(
              children: [
                // Product image
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppRadius.md),
                    topRight: Radius.circular(AppRadius.md),
                  ),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.grey200,
                          child: Icon(
                            Icons.directions_car,
                            size: AppSizes.iconXl,
                            color: AppColors.grey400,
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Favorite button
                Positioned(
                  top: AppSpacing.sm,
                  right: AppSpacing.sm,
                  child: GestureDetector(
                    onTap: onFavoriteTap,
                    child: Container(
                      padding: EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? AppColors.error : AppColors.grey400,
                        size: AppSizes.iconSm,
                      ),
                    ),
                  ),
                ),

                // Tags
                if (tags != null && tags!.isNotEmpty)
                  Positioned(
                    bottom: AppSpacing.sm,
                    left: AppSpacing.sm,
                    child: Wrap(
                      spacing: AppSpacing.xs,
                      children: tags!.take(2).map((tag) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: AppRadius.borderRadiusSm,
                          ),
                          child: AppText.caption(tag, color: AppColors.white),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),

            // Content section
            Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  AppText.bodyLarge(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    color: AppColors.textPrimary,
                  ),

                  if (subtitle != null) ...[
                    SizedBox(height: AppSpacing.xs),
                    AppText.bodySmall(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      color: AppColors.textSecondary,
                    ),
                  ],

                  SizedBox(height: AppSpacing.sm),

                  // Price
                  AppText.headingSmall(price, color: AppColors.primary),

                  if (location != null) ...[
                    SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: AppSizes.iconXs,
                          color: AppColors.grey400,
                        ),
                        SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: AppText.caption(
                            location!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// List variant of product tile (horizontal layout)
class ProductListTile extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String? subtitle;
  final String price;
  final String? location;
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;

  const ProductListTile({
    super.key,
    required this.imageUrl,
    required this.title,
    this.subtitle,
    required this.price,
    this.location,
    this.isFavorite = false,
    this.onTap,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.borderRadiusMd,
          border: Border.all(
            color: AppColors.border,
            width: AppSizes.borderWidthThin,
          ),
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: AppRadius.borderRadiusSm,
              child: SizedBox(
                width: 80.w,
                height: 80.w,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.grey200,
                      child: Icon(
                        Icons.directions_car,
                        size: AppSizes.iconLg,
                        color: AppColors.grey400,
                      ),
                    );
                  },
                ),
              ),
            ),

            SizedBox(width: AppSpacing.md),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.bodyLarge(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: AppSpacing.xs),
                    AppText.caption(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  SizedBox(height: AppSpacing.sm),
                  AppText.headingXSmall(price, color: AppColors.primary),
                  if (location != null) ...[
                    SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: AppSizes.iconXs,
                          color: AppColors.grey400,
                        ),
                        SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: AppText.caption(
                            location!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Favorite button
            IconButton(
              onPressed: onFavoriteTap,
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? AppColors.error : AppColors.grey400,
                size: AppSizes.iconMd,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
