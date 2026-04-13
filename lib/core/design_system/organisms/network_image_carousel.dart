import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import 'zoomable_image_viewer.dart';

/// A reusable horizontal image carousel that loads images from network URLs.
///
/// Features:
/// - Cached network images (CachedNetworkImage)
/// - Loading shimmer placeholder
/// - Error fallback with icon
/// - Animated dot indicators
/// - Configurable height, aspect-ratio crop, and dot colors
///
/// Usage:
/// ```dart
/// NetworkImageCarousel(
///   imageUrls: vehicle.images,
///   height: 180.h,
/// )
/// ```
class NetworkImageCarousel extends StatefulWidget {
  final List<String> imageUrls;

  /// Fixed height of the carousel. Set either [height] or [aspectRatio].
  final double? height;

  /// Aspect ratio (width / height). Ignored if [height] is set.
  final double aspectRatio;

  /// Icon shown when no images or image fails to load.
  final IconData placeholderIcon;

  /// Active dot color (defaults to [AppColors.primary]).
  final Color? activeDotColor;

  /// Inactive dot color (defaults to white 70%).
  final Color? inactiveDotColor;

  const NetworkImageCarousel({
    super.key,
    required this.imageUrls,
    this.height,
    this.aspectRatio = 16 / 9,
    this.placeholderIcon = Icons.directions_car_outlined,
    this.activeDotColor,
    this.inactiveDotColor,
  });

  @override
  State<NetworkImageCarousel> createState() => _NetworkImageCarouselState();
}

class _NetworkImageCarouselState extends State<NetworkImageCarousel> {
  final _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final urls = widget.imageUrls.where((u) => u.isNotEmpty).toList();
    final activeDot = widget.activeDotColor ?? AppColors.primary;
    final inactiveDot =
        widget.inactiveDotColor ?? AppColors.white.withOpacity(0.7);

    Widget carousel;

    if (urls.isEmpty) {
      carousel = _Placeholder(icon: widget.placeholderIcon);
    } else {
      carousel = Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: urls.length,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemBuilder: (_, i) => GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      ZoomableImageViewer(imageUrls: urls, initialIndex: i),
                ),
              ),
              child: _CarouselImage(
                url: urls[i],
                placeholderIcon: widget.placeholderIcon,
              ),
            ),
          ),
          if (urls.length > 1)
            Positioned(
              bottom: 8.h,
              left: 0,
              right: 0,
              child: _DotIndicator(
                count: urls.length,
                current: _currentIndex,
                activeColor: activeDot,
                inactiveColor: inactiveDot,
              ),
            ),
        ],
      );
    }

    if (widget.height != null) {
      return SizedBox(height: widget.height, child: carousel);
    }
    return AspectRatio(aspectRatio: widget.aspectRatio, child: carousel);
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _CarouselImage extends StatelessWidget {
  final String url;
  final IconData placeholderIcon;

  const _CarouselImage({required this.url, required this.placeholderIcon});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return _LoadingShimmer();
      },
      errorBuilder: (_, __, ___) => _Placeholder(icon: placeholderIcon),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _LoadingShimmer extends StatefulWidget {
  @override
  State<_LoadingShimmer> createState() => _LoadingShimmerState();
}

class _LoadingShimmerState extends State<_LoadingShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 0.9).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        color: Color.lerp(AppColors.grey100, AppColors.grey200, _anim.value),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _Placeholder extends StatelessWidget {
  final IconData icon;

  const _Placeholder({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.grey100,
      child: Center(
        child: Icon(icon, size: 48.r, color: AppColors.grey400),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _DotIndicator extends StatelessWidget {
  final int count;
  final int current;
  final Color activeColor;
  final Color inactiveColor;

  const _DotIndicator({
    required this.count,
    required this.current,
    required this.activeColor,
    required this.inactiveColor,
  });

  static const int _maxVisible = 10;

  @override
  Widget build(BuildContext context) {
    // Compute start index for the sliding window of max _maxVisible dots
    final int half = _maxVisible ~/ 2;
    int start = (current - half).clamp(
      0,
      (count - _maxVisible).clamp(0, count),
    );
    final int end = (start + _maxVisible).clamp(0, count);
    // Adjust start if end hit the boundary
    start = (end - _maxVisible).clamp(0, end);

    final visibleIndices = List.generate(end - start, (i) => start + i);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: visibleIndices.map((i) {
        final isActive = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.symmetric(horizontal: 3.w),
          width: isActive ? 16.w : 6.w,
          height: 6.h,
          decoration: BoxDecoration(
            color: isActive ? activeColor : inactiveColor,
            borderRadius: BorderRadius.circular(3.r),
          ),
        );
      }).toList(),
    );
  }
}
