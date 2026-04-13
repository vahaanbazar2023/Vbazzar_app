import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../atoms/app_text.dart';
import '../tokens/app_spacing.dart';

/// Dashboard layout template
/// Provides consistent layout for main app screens
class DashboardLayout extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final PreferredSizeWidget? bottom;

  const DashboardLayout({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.showBackButton = false,
    this.onBackPressed,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: showBackButton
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.textPrimary,
                ),
                onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
              )
            : null,
        title: AppText.headingMedium(title, color: AppColors.textPrimary),
        actions: actions,
        bottom: bottom,
      ),
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}

/// Page layout with header and content
class PageLayout extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool scrollable;
  final Widget? headerWidget;
  final Widget? bottomWidget;

  const PageLayout({
    super.key,
    this.title,
    this.subtitle,
    required this.child,
    this.padding,
    this.scrollable = true,
    this.headerWidget,
    this.bottomWidget,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Custom header widget
        if (headerWidget != null) ...[
          headerWidget!,
          SizedBox(height: AppSpacing.lg),
        ],

        // Title and subtitle
        if (title != null) ...[
          AppText.headingLarge(title!),
          if (subtitle != null) ...[
            SizedBox(height: AppSpacing.sm),
            AppText.bodyMedium(subtitle!, color: AppColors.textSecondary),
          ],
          SizedBox(height: AppSpacing.lg),
        ],

        // Main content
        if (scrollable) Expanded(child: child) else child,

        // Bottom widget
        if (bottomWidget != null) ...[
          SizedBox(height: AppSpacing.lg),
          bottomWidget!,
        ],
      ],
    );

    if (scrollable) {
      content = SingleChildScrollView(
        padding: padding ?? EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (headerWidget != null) ...[
              headerWidget!,
              SizedBox(height: AppSpacing.lg),
            ],
            if (title != null) ...[
              AppText.headingLarge(title!),
              if (subtitle != null) ...[
                SizedBox(height: AppSpacing.sm),
                AppText.bodyMedium(subtitle!, color: AppColors.textSecondary),
              ],
              SizedBox(height: AppSpacing.lg),
            ],
            child,
            if (bottomWidget != null) ...[
              SizedBox(height: AppSpacing.lg),
              bottomWidget!,
            ],
          ],
        ),
      );
    } else {
      content = Padding(
        padding: padding ?? EdgeInsets.all(AppSpacing.lg),
        child: content,
      );
    }

    return content;
  }
}

/// List layout with search and filter
class ListLayout extends StatelessWidget {
  final String title;
  final Widget searchBar;
  final Widget listView;
  final Widget? emptyState;
  final bool isLoading;
  final bool isEmpty;
  final Widget? floatingActionButton;

  const ListLayout({
    super.key,
    required this.title,
    required this.searchBar,
    required this.listView,
    this.emptyState,
    this.isLoading = false,
    this.isEmpty = false,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return DashboardLayout(
      title: title,
      floatingActionButton: floatingActionButton,
      body: Column(
        children: [
          // Search bar
          Padding(padding: EdgeInsets.all(AppSpacing.md), child: searchBar),

          // List content
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : isEmpty && emptyState != null
                ? Center(child: emptyState)
                : listView,
          ),
        ],
      ),
    );
  }
}
