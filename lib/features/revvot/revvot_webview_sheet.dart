import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/constants/app_colors.dart';

/// Bottom sheet that renders the Revvot buying-power flow inside a WebView.
/// Pops with the sessionId string when the flow completes, or null on dismiss.
class RevvotWebViewSheet extends StatefulWidget {
  final String publicKey;
  final String embedToken;
  final String sessionId;

  const RevvotWebViewSheet({
    super.key,
    required this.publicKey,
    required this.embedToken,
    required this.sessionId,
  });

  @override
  State<RevvotWebViewSheet> createState() => _RevvotWebViewSheetState();
}

class _RevvotWebViewSheetState extends State<RevvotWebViewSheet> {
  late final WebViewController _webViewController;
  bool _isLoading = true;

  // Revvot hosted embed URL — `key` is the public/widget key, `token` is the embed token
  String get _embedUrl =>
      'https://app.revvot.com/embed?token=${Uri.encodeComponent(widget.embedToken)}&key=${Uri.encodeComponent(widget.publicKey)}';

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        // Revvot's web app calls window.flutter_inappwebview or postMessage.
        // We listen on both channels for safety.
        'RevvotFlutter',
        onMessageReceived: _onMessage,
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
            // Inject a listener for window.postMessage so we can catch
            // the Revvot result even if they don't use our named channel.
            _injectMessageListener();
          },
          onWebResourceError: (error) {
            debugPrint('Revvot WebView error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(_embedUrl));
    debugPrint('🔗 Revvot embed URL: $_embedUrl');
  }

  /// Inject JS that forwards any postMessage back to Flutter via RevvotFlutter channel.
  Future<void> _injectMessageListener() async {
    await _webViewController.runJavaScript('''
      (function() {
        if (window.__revvotListenerAdded) return;
        window.__revvotListenerAdded = true;
        window.addEventListener('message', function(event) {
          try {
            var data = typeof event.data === 'string'
                ? event.data
                : JSON.stringify(event.data);
            RevvotFlutter.postMessage(data);
          } catch(e) {}
        });
      })();
    ''');
  }

  void _onMessage(JavaScriptMessage message) {
    try {
      final dynamic raw = jsonDecode(message.message);
      final Map<String, dynamic> data = raw is Map<String, dynamic> ? raw : {};

      final type = (data['type'] ?? '').toString();
      final outcome = (data['outcome'] ?? '').toString();

      debugPrint('Revvot message: ${message.message}');

      // Flow complete when outcome is set or type signals completion
      if (outcome.isNotEmpty && outcome != 'pending') {
        final sessionId = (data['sessionId'] ?? widget.sessionId).toString();
        if (mounted) Navigator.of(context).pop(sessionId);
        return;
      }

      // Revvot may also use type-based signalling
      if (type == 'revvot:result' ||
          type == 'result' ||
          type == 'complete' ||
          type == 'revvot:complete') {
        final sessionId = (data['sessionId'] ?? widget.sessionId).toString();
        if (mounted) Navigator.of(context).pop(sessionId);
        return;
      }

      if (type == 'revvot:error' || type == 'error') {
        if (mounted) Navigator.of(context).pop(null);
      }
    } catch (_) {
      // Non-JSON or unrelated postMessage — ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.92,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar + close
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
            child: Row(
              children: [
                const Expanded(
                  child: Center(
                    child: SizedBox(
                      width: 40,
                      height: 4,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Color(0xFFDDDDDD),
                          borderRadius: BorderRadius.all(Radius.circular(2)),
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(null),
                  color: AppColors.grey600,
                ),
              ],
            ),
          ),

          // WebView
          Expanded(
            child: Stack(
              children: [
                WebViewWidget(controller: _webViewController),
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2.5,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
