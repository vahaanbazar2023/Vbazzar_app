import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../home/controllers/home_controller.dart';

/// Search screen — same header style as HomeScreen, no elevation.
/// The search bar is auto-focused so the keyboard pops up immediately.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _query = '';

  @override
  void initState() {
    super.initState();
    // Auto-focus the search field when the screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
    _controller.addListener(() {
      setState(() => _query = _controller.text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              _SearchHeader(
                controller: _controller,
                focusNode: _focusNode,
                onBack: () => Get.back(),
              ),
              Expanded(
                child: _query.isEmpty
                    ? const _EmptyState()
                    : _SearchResults(query: _query),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header — mirrors HomeScreen _HomeHeader style
// ─────────────────────────────────────────────────────────────────────────────

class _SearchHeader extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onBack;

  const _SearchHeader({
    required this.controller,
    required this.focusNode,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Row 1: location + icons (same as home) ────────────
          GetX<HomeController>(
            builder: (ctrl) {
              final label = ctrl.locationLabel.value;
              return Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => ctrl.refreshLocation(),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            color: AppColors.primary,
                            size: 18.r,
                          ),
                          SizedBox(width: 4.w),
                          Flexible(
                            child: Text(
                              label.isNotEmpty ? label : 'Locating...',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: AppColors.grey600,
                            size: 18.r,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SvgPicture.asset(
                    AppAssets.iconNotification,
                    width: 26.r,
                    height: 26.r,
                  ),
                  SizedBox(width: 14.w),
                  GestureDetector(
                    onTap: () async {
                      final uri = Uri(scheme: 'tel', path: '+918008801806');
                      if (await canLaunchUrl(uri)) launchUrl(uri);
                    },
                    child: Image.asset(
                      AppAssets.customerCare,
                      width: 28.r,
                      height: 28.r,
                    ),
                  ),
                ],
              );
            },
          ),
          SizedBox(height: 10.h),
          // ── Row 2: back arrow + active search field ───────────
          Row(
            children: [
              GestureDetector(
                onTap: onBack,
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.textPrimary,
                  size: 20.r,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Container(
                  height: 44.h,
                  decoration: BoxDecoration(
                    color: AppColors.grey100,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColors.primary, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: 12.w),
                      Icon(Icons.search, color: AppColors.primary, size: 20.r),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: TextField(
                          controller: controller,
                          focusNode: focusNode,
                          autofocus: true,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 13.sp,
                            color: AppColors.textPrimary,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search by service, vehicle...',
                            hintStyle: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 13.sp,
                              color: AppColors.grey400,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          textInputAction: TextInputAction.search,
                        ),
                      ),
                      if (controller.text.isNotEmpty)
                        GestureDetector(
                          onTap: () => controller.clear(),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.w),
                            child: Icon(
                              Icons.close,
                              color: AppColors.grey400,
                              size: 18.r,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state — shown before user types anything
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 64.r, color: AppColors.grey300),
          SizedBox(height: 16.h),
          Text(
            'Search for a service or vehicle',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'e.g. Auction, Buy & Sell, Inspection...',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 12.sp,
              color: AppColors.grey400,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Search results placeholder — replace with real data when API is ready
// ─────────────────────────────────────────────────────────────────────────────

class _SearchResults extends StatelessWidget {
  final String query;
  const _SearchResults({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 56.r, color: AppColors.grey300),
          SizedBox(height: 16.h),
          Text(
            'No results for "$query"',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Try a different keyword',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 12.sp,
              color: AppColors.grey400,
            ),
          ),
        ],
      ),
    );
  }
}
