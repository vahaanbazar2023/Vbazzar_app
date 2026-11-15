import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_constants.dart';
import '../../../routes/app_routes.dart';

/// Website screens the bot links to, mapped to the matching app screens.
const Map<String, String> _appRoutes = {
  '/app/buy-sell': AppRoutes.buySellHome,
  '/app/buy-sell/sell': AppRoutes.sellVehicle,
  '/app/approved': AppRoutes.approvedVehicleBuySell,
  '/app/inspection': AppRoutes.inspectionHome,
  '/app/insurance-finance': AppRoutes.insuranceFinance,
  '/app/spares': AppRoutes.spareFms,
  '/app/notifications': AppRoutes.notifications,
  '/app/partner': AppRoutes.partnerWithUs,
};

Future<void> openChatLink(String href) async {
  final path = href.split('?').first.replaceAll(RegExp(r'/+$'), '');
  final route = _appRoutes[path];
  if (route != null) {
    Get.toNamed(route);
    return;
  }
  final uri = href.startsWith('/')
      ? Uri.parse('${ApiConstants.chatBaseUrl}$href')
      : Uri.tryParse(href);
  if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

/// Small renderer for the markdown the bot writes: **bold**, `code`,
/// [links](url), bullet and numbered lists, headings and plain tables.
class ChatMarkdown extends StatefulWidget {
  final String text;
  final Color color;
  const ChatMarkdown({super.key, required this.text, required this.color});

  @override
  State<ChatMarkdown> createState() => _ChatMarkdownState();
}

class _ChatMarkdownState extends State<ChatMarkdown> {
  final List<TapGestureRecognizer> _taps = [];

  @override
  void dispose() {
    for (final t in _taps) {
      t.dispose();
    }
    super.dispose();
  }

  static final _inline = RegExp(
    r'\*\*(.+?)\*\*|`([^`]+)`|\[([^\]]+)\]\(([^)\s]+)\)',
  );

  List<InlineSpan> _spans(String s, TextStyle base) {
    final out = <InlineSpan>[];
    var i = 0;
    for (final m in _inline.allMatches(s)) {
      if (m.start > i) out.add(TextSpan(text: s.substring(i, m.start)));
      if (m.group(1) != null) {
        out.add(
          TextSpan(
            text: m.group(1),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        );
      } else if (m.group(2) != null) {
        out.add(
          TextSpan(
            text: m.group(2),
            style: TextStyle(
              fontFamily: 'monospace',
              backgroundColor: widget.color.withValues(alpha: 0.08),
            ),
          ),
        );
      } else {
        final href = m.group(4)!;
        final tap = TapGestureRecognizer()..onTap = () => openChatLink(href);
        _taps.add(tap);
        out.add(
          TextSpan(
            text: m.group(3),
            recognizer: tap,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
            ),
          ),
        );
      }
      i = m.end;
    }
    if (i < s.length) out.add(TextSpan(text: s.substring(i)));
    return out;
  }

  @override
  Widget build(BuildContext context) {
    for (final t in _taps) {
      t.dispose();
    }
    _taps.clear();

    final base = TextStyle(
      color: widget.color,
      fontSize: 14.sp,
      height: 1.45,
      fontWeight: FontWeight.w400,
    );
    final blocks = <Widget>[];
    for (final raw in widget.text.split('\n')) {
      final line = raw.trimRight();
      if (line.trim().isEmpty) {
        if (blocks.isNotEmpty) blocks.add(SizedBox(height: 6.h));
        continue;
      }
      // Table separator rows (|---|---|) carry no content.
      if (RegExp(r'^\s*\|?[\s:\-|]+\|?\s*$').hasMatch(line) &&
          line.contains('-') &&
          line.contains('|')) {
        continue;
      }
      var marker = '';
      var body = line.trim();
      var style = base;
      final num = RegExp(r'^(\d+)[.)]\s+(.*)$').firstMatch(body);
      final bullet = RegExp(r'^[-*•]\s+(.*)$').firstMatch(body);
      final heading = RegExp(r'^#{1,6}\s+(.*)$').firstMatch(body);
      if (num != null) {
        marker = '${num.group(1)}.';
        body = num.group(2)!;
      } else if (bullet != null) {
        marker = '•';
        body = bullet.group(1)!;
      } else if (heading != null) {
        body = heading.group(1)!;
        style = base.copyWith(fontWeight: FontWeight.w700);
      } else if (body.startsWith('|')) {
        body = body
            .replaceAll(RegExp(r'^\||\|$'), '')
            .split('|')
            .map((c) => c.trim())
            .join('  ·  ');
      }
      final text = Text.rich(
        TextSpan(style: style, children: _spans(body, style)),
      );
      blocks.add(
        Padding(
          padding: EdgeInsets.only(bottom: 2.h),
          child: marker.isEmpty
              ? text
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 22.w,
                      child: Text(marker, style: style),
                    ),
                    Expanded(child: text),
                  ],
                ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: blocks,
    );
  }
}
