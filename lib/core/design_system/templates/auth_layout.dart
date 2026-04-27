import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/app_assets.dart';
import '../../constants/app_colors.dart';
import '../atoms/app_svg_icon.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_spacing.dart';

/// Authentication layout template with red gradient header and white content section
/// Provides consistent layout for auth screens (login, register, OTP verification, etc.)
///
/// Design pattern:
/// - Red gradient header section at the top (customizable height)
/// - White content section with rounded corners that overlaps the header
/// - Optional back button in the header
/// - Title and subtitle in the header
/// - Scrollable content area
class AuthLayout extends StatelessWidget {
  /// Main heading text displayed in the red header
  final String title;

  /// Optional subtitle text displayed below title in the red header
  final String? subtitle;

  /// Optional underlined clickable text at the end of subtitle
  final String? subtitleUnderlinedText;

  /// Callback when the underlined subtitle text is tapped
  final VoidCallback? onSubtitleUnderlinedTap;

  /// Main content widget displayed in the white section
  final Widget child;

  /// Optional widget displayed at the bottom (e.g., "Don't have an account?")
  final Widget? bottomWidget;

  /// Whether to show a back button in the top-left of the header
  final bool showBackButton;

  /// Custom callback for back button press
  final VoidCallback? onBackPressed;

  /// Custom height for the red header section (default: 220.h)
  final double? headerHeight;

  /// Custom widget to display in the header instead of title/subtitle
  /// Useful for adding logos or custom header content
  final Widget? customHeaderContent;

  const AuthLayout({
    super.key,
    required this.title,
    this.subtitle,
    this.subtitleUnderlinedText,
    this.onSubtitleUnderlinedTap,
    required this.child,
    this.bottomWidget,
    this.showBackButton = false,
    this.onBackPressed,
    this.headerHeight,
    this.customHeaderContent,
  });

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final effectiveHeaderHeight = (headerHeight ?? 200.h) + statusBarHeight;

    return Scaffold(
      backgroundColor: AppColors.black,
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          /// RED GRADIENT HEADER SECTION
          ///
          Container(
            width: double.infinity,
            height: effectiveHeaderHeight,
            padding: EdgeInsets.only(
              top: statusBarHeight + AppSpacing.sm,
              left: AppSpacing.xl,
              right: AppSpacing.xl,
              bottom: AppSpacing.xl,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.authHeaderGradientStart,
                  AppColors.authHeaderGradientEnd,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button (if enabled)
                SizedBox(height: AppSpacing.lg),
                if (showBackButton)
                  GestureDetector(
                    onTap: onBackPressed ?? () => Navigator.of(context).pop(),
                    child: Container(
                      padding: EdgeInsets.all(AppSpacing.xs),
                      child: AppSvgIcon(
                        assetPath: AppAssets.arrowBack,
                        color: Colors.white,
                        size: 10.w,
                        semanticLabel: 'Back',
                      ),
                    ),
                  ),

                const Spacer(),

                // Custom content or default title/subtitle
                if (customHeaderContent != null)
                  customHeaderContent!
                else
                  _buildDefaultHeaderContent(),

                SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),

          /// WHITE CONTENT SECTION WITH OVERLAP
          Expanded(
            child: Transform.translate(
              offset: Offset(0, -AppRadius.xxl),
              child: Padding(
                padding: EdgeInsets.only(bottom: AppRadius.xxl),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(AppRadius.xxl),
                      topRight: Radius.circular(AppRadius.xxl),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Main scrollable content
                      Expanded(
                        child: SingleChildScrollView(
                          padding:
                              EdgeInsets.symmetric(
                                horizontal: AppSpacing.xl,
                              ).copyWith(
                                top: AppSpacing.md,
                                bottom:
                                    AppSpacing.xxl +
                                    MediaQuery.of(context).viewInsets.bottom,
                              ),
                          child: child,
                        ),
                      ),

                      // Bottom widget (optional)
                      if (bottomWidget != null)
                        Container(
                          padding: EdgeInsets.fromLTRB(
                            AppSpacing.xl,
                            AppSpacing.lg,
                            AppSpacing.xl,
                            AppSpacing.lg +
                                MediaQuery.of(context).padding.bottom,
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: AppColors.border.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                          ),
                          child: bottomWidget,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the default header content with title and optional subtitle
  Widget _buildDefaultHeaderContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 26.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
        if (subtitle != null) ...[
          SizedBox(height: AppSpacing.xs),
          // If underlined text is provided, use Row with clickable underlined text
          if (subtitleUnderlinedText != null)
            Row(
              children: [
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.white,
                  ),
                ),
                SizedBox(width: 4.w),
                GestureDetector(
                  onTap: onSubtitleUnderlinedTap,
                  child: Text(
                    subtitleUnderlinedText!,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.white,
                    ),
                  ),
                ),
              ],
            )
          else
            // Regular subtitle without underlined text
            Text(
              subtitle!,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.white,
              ),
            ),
        ],
      ],
    );
  }
}
