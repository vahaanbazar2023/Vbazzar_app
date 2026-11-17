import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../../core/storage/storage_keys.dart';
import '../../../routes/app_routes.dart';

/// Short greeting shown in the popup bubble next to Vaani, per app language.
const Map<String, String> kVaaniNudge = {
  'en': "Hi! I'm Vahaan Vani. Need help? Tap to chat.",
  'hi': 'नमस्ते! मैं वाहन वाणी हूँ। मदद चाहिए? चैट करने के लिए टैप करें।',
  'te': 'నమస్కారం! నేను వాహన్ వాణి. సహాయం కావాలా? చాట్ చేయడానికి నొక్కండి.',
  'kn': 'ನಮಸ್ಕಾರ! ನಾನು ವಾಹನ್ ವಾಣಿ. ಸಹಾಯ ಬೇಕೇ? ಚಾಟ್ ಮಾಡಲು ಟ್ಯಾಪ್ ಮಾಡಿ.',
  'ml': 'നമസ്കാരം! ഞാൻ വാഹൻ വാണി. സഹായം വേണോ? ചാറ്റ് ചെയ്യാൻ ടാപ്പ് ചെയ്യൂ.',
  'ta': 'வணக்கம்! நான் வாகன் வாணி. உதவி வேண்டுமா? அரட்டையடிக்க தட்டவும்.',
};

/// Vaani, the AI assistant, floating over the main screens.
///
/// - Tap: opens the chat.
/// - Drag: move it anywhere; on release it snaps to the nearest side. The spot is remembered.
/// - Popup: a greeting bubble appears beside it once per app launch and hides after a few seconds
///   (or when closed, dragged or tapped).
///
/// Place it as the last child of a [Stack] that fills the area it may move in.
class VaaniFloatingButton extends StatefulWidget {
  const VaaniFloatingButton({super.key});

  @override
  State<VaaniFloatingButton> createState() => _VaaniFloatingButtonState();
}

class _VaaniFloatingButtonState extends State<VaaniFloatingButton> {
  static const double _size = 68;
  static const double _margin = 12;
  static const String _keyX = 'vaani_fab_x'; // 0..1 of the free width
  static const String _keyY = 'vaani_fab_y'; // 0..1 of the free height

  /// The popup shows once per app launch, not on every tab or screen rebuild.
  static bool _popupShownThisLaunch = false;

  double? _fx, _fy; // position as fractions, so it survives screen size changes
  bool _dragging = false;
  bool _showPopup = false;
  Timer? _popupShow, _popupHide;

  @override
  void initState() {
    super.initState();
    try {
      _fx = (LocalStorageService.to.read<num>(_keyX))?.toDouble();
      _fy = (LocalStorageService.to.read<num>(_keyY))?.toDouble();
    } catch (_) {}
    if (!_popupShownThisLaunch) {
      _popupShownThisLaunch = true;
      _popupShow = Timer(const Duration(milliseconds: 1500), () {
        if (!mounted) return;
        setState(() => _showPopup = true);
        _popupHide = Timer(const Duration(seconds: 6), _hidePopup);
      });
    }
  }

  @override
  void dispose() {
    _popupShow?.cancel();
    _popupHide?.cancel();
    super.dispose();
  }

  void _hidePopup() {
    _popupShow?.cancel();
    _popupHide?.cancel();
    if (mounted && _showPopup) setState(() => _showPopup = false);
  }

  void _openChat() {
    _hidePopup();
    Get.toNamed(AppRoutes.chatbot);
  }

  String get _nudge {
    final code = LocalStorageService.to.getString(
      StorageKeys.languageCode,
      defaultValue: 'en',
    );
    return kVaaniNudge[code] ?? kVaaniNudge['en']!;
  }

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.paddingOf(context);
    return LayoutBuilder(
      builder: (context, box) {
        final minX = _margin + pad.left;
        final maxX = box.maxWidth - _size - _margin - pad.right;
        final minY = _margin + pad.top;
        final maxY = box.maxHeight - _size - _margin;
        final freeW = (maxX - minX).clamp(1.0, double.infinity);
        final freeH = (maxY - minY).clamp(1.0, double.infinity);

        // Default spot: bottom-right, where the old chat button was.
        final left = minX + (_fx ?? 1.0).clamp(0.0, 1.0) * freeW;
        final top = minY + (_fy ?? 1.0).clamp(0.0, 1.0) * freeH;
        final onRight = left + _size / 2 > box.maxWidth / 2;

        return Stack(
          children: [
            if (_showPopup && !_dragging)
              Positioned(
                top: (top + _size / 2 - 32).clamp(minY, maxY),
                left: onRight ? null : left + _size + 8,
                right: onRight ? box.maxWidth - left + 8 : null,
                child: _Popup(
                  text: _nudge,
                  pointRight: onRight,
                  onTap: _openChat,
                  onClose: _hidePopup,
                ),
              ),
            AnimatedPositioned(
              duration: _dragging
                  ? Duration.zero
                  : const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              left: left,
              top: top,
              child: GestureDetector(
                onTap: _openChat,
                onPanStart: (_) {
                  _hidePopup();
                  setState(() => _dragging = true);
                },
                onPanUpdate: (d) => setState(() {
                  _fx = ((left + d.delta.dx - minX) / freeW).clamp(0.0, 1.0);
                  _fy = ((top + d.delta.dy - minY) / freeH).clamp(0.0, 1.0);
                }),
                onPanEnd: (_) {
                  setState(() {
                    _dragging = false;
                    _fx = (_fx ?? 1.0) < 0.5 ? 0.0 : 1.0; // snap to the nearest side
                  });
                  try {
                    LocalStorageService.to.write(_keyX, _fx);
                    LocalStorageService.to.write(_keyY, _fy);
                  } catch (_) {}
                },
                child: Semantics(
                  button: true,
                  label: 'Chat with Vahaan Vani. Drag to move.',
                  child: AnimatedScale(
                    scale: _dragging ? 1.08 : 1.0,
                    duration: const Duration(milliseconds: 150),
                    child: Container(
                      width: _size,
                      height: _size,
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: _dragging ? 0.25 : 0.15),
                            blurRadius: _dragging ? 14 : 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        AppAssets.vaaniAi,
                        fit: BoxFit.contain,
                        cacheWidth: 240,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Popup extends StatelessWidget {
  final String text;
  final bool pointRight;
  final VoidCallback onTap;
  final VoidCallback onClose;

  const _Popup({
    required this.text,
    required this.pointRight,
    required this.onTap,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutBack,
      builder: (_, t, child) => Opacity(
        opacity: t.clamp(0.0, 1.0),
        child: Transform.scale(
          scale: 0.85 + 0.15 * t,
          alignment: pointRight ? Alignment.centerRight : Alignment.centerLeft,
          child: child,
        ),
      ),
      child: Material(
        color: Colors.white,
        elevation: 4,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(14),
          topRight: const Radius.circular(14),
          bottomLeft: Radius.circular(pointRight ? 14 : 2),
          bottomRight: Radius.circular(pointRight ? 2 : 14),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 210),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Text(
                      text,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.35,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  InkResponse(
                    onTap: onClose,
                    radius: 16,
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.close_rounded, size: 16, color: AppColors.grey500),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
