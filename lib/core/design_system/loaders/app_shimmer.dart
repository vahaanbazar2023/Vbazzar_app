import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

/// Loading placeholders used while an API call is in flight.
///
/// Rule: a skeleton mirrors the real layout of the screen — same card shape,
/// padding, image and text positions, button size — so nothing jumps when the
/// data arrives. Keep the real card's decoration (white, border, shadow) around
/// an [AppShimmer] and put [SkeletonBox]es where the content will be.
///
/// Spinners stay only for in-button loading and "loading more" at the end of a
/// list.

const _base = Color(0xFFEDEDED);
const _highlight = Color(0xFFF8F8F8);

/// The shimmer sweep. Everything opaque inside [child] is drawn as the
/// shimmering grey, so wrap the skeleton boxes, not the card around them.
class AppShimmer extends StatelessWidget {
  final Widget child;
  final bool enabled;
  const AppShimmer({super.key, required this.child, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: _base,
      highlightColor: _highlight,
      period: const Duration(milliseconds: 1300),
      enabled: enabled,
      child: child,
    );
  }
}

/// A grey placeholder block (an image, a line of text, a button).
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;
  final BoxShape shape;
  const SkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.radius = 6,
    this.shape = BoxShape.rectangle,
  });

  /// A circle (avatar, round icon).
  const SkeletonBox.circle({super.key, required double size})
    : width = size,
      height = size,
      radius = 0,
      shape = BoxShape.circle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: _base,
        shape: shape,
        borderRadius: shape == BoxShape.circle
            ? null
            : BorderRadius.circular(radius.r),
      ),
    );
  }
}

/// A non-scrolling list of [count] skeleton items laid out like the real list
/// (same padding and spacing), so the page keeps its shape while loading.
class SkeletonList extends StatelessWidget {
  final int count;
  final IndexedWidgetBuilder itemBuilder;
  final EdgeInsetsGeometry? padding;
  final double spacing;
  final Axis scrollDirection;
  const SkeletonList({
    super.key,
    required this.itemBuilder,
    this.count = 5,
    this.padding,
    this.spacing = 12,
    this.scrollDirection = Axis.vertical,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding,
      scrollDirection: scrollDirection,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      separatorBuilder: (_, __) => scrollDirection == Axis.vertical
          ? SizedBox(height: spacing)
          : SizedBox(width: spacing),
      itemBuilder: itemBuilder,
    );
  }
}
