import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// Common app layout: red gradient header + white rounded body.
/// Use this for any screen that follows the brand layout pattern.
///
/// Example:
/// ```dart
/// AppScaffold(
///   title: 'Auction Zone',
///   body: MyContent(),
/// )
/// ```
class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final bool showBack;
  final VoidCallback? onBack;

  /// Extra widget shown inside the red header, below the title bar.
  /// Use this for tab bars, search fields, or any header expansion.
  final Widget? headerExtra;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.showBack = true,
    this.onBack,
    this.headerExtra,
  });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFFD41F1F),
        body: Column(
          children: [
            _Header(
              title: title,
              showBack: showBack,
              onBack: onBack,
              actions: actions,
              headerExtra: headerExtra,
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                child: ColoredBox(color: Colors.white, child: body),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final bool showBack;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final Widget? headerExtra;

  const _Header({
    required this.title,
    required this.showBack,
    this.onBack,
    this.actions,
    this.headerExtra,
  });

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE82020), Color(0xFF9B0800)],
        ),
      ),
      padding: EdgeInsets.only(top: topPad),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 56,
            child: Row(
              children: [
                if (showBack)
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: onBack ?? () => Get.back(),
                  )
                else
                  const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: Colors.white,
                      height: 1.0,
                    ),
                  ),
                ),
                if (actions != null) ...actions!,
                const SizedBox(width: 8),
              ],
            ),
          ),
          if (headerExtra != null) headerExtra!,
        ],
      ),
    );
  }
}
