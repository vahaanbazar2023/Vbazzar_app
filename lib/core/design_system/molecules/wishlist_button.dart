import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/app_colors.dart';

/// Reusable wishlist (heart) button.
///
/// Usage — overlay on a card image:
/// ```dart
/// Positioned(
///   top: 10, right: 10,
///   child: WishlistButton(
///     isWishlisted: item.isSaved,
///     onTap: () => controller.toggleWishlist(item),
///   ),
/// )
/// ```
class WishlistButton extends StatelessWidget {
  final bool isWishlisted;
  final VoidCallback? onTap;

  /// Size of the circle container. Defaults to 32.
  final double? size;

  const WishlistButton({
    super.key,
    this.isWishlisted = false,
    this.onTap,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final s = size ?? 32.w;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: s,
        height: s,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          isWishlisted ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          color: AppColors.primary,
          size: s * 0.50,
        ),
      ),
    );
  }
}
