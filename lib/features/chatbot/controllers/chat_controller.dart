import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/storage/local_storage_service.dart';
import '../../../core/storage/storage_keys.dart';
import '../models/chat_message.dart';
import '../services/chat_service.dart';

/// The assistant's name as shown in the app.
const String kBotName = 'Vahaan Vani';

/// Greeting per language, copied from the website widget (name shown as "Vahaan Vani").
const Map<String, String> kVaaniGreeting = {
  'en':
      "Hi, I'm **Vahaan Vani**, Vahaan Bazar's AI assistant. Ask me anything about buying, selling, auctions, insurance, finance or inspections, or any other question. I reply in your language.",
  'hi':
      'नमस्ते, मैं **वाहन वाणी** हूँ, वाहन बाज़ार की AI असिस्टेंट। खरीद-बिक्री, नीलामी, बीमा, फाइनेंस या कोई भी सवाल पूछिए। मैं आपकी भाषा में जवाब दूँगी।',
  'te':
      'నమస్కారం, నేను **వాహన్ వాణి**, వాహన్ బజార్ AI అసిస్టెంట్. కొనుగోలు, అమ్మకం, వేలం, బీమా, ఫైనాన్స్ లేదా ఏ ప్రశ్నైనా అడగండి. మీ భాషలోనే సమాధానం ఇస్తాను.',
  'kn':
      'ನಮಸ್ಕಾರ, ನಾನು **ವಾಹನ್ ವಾಣಿ**, ವಾಹನ್ ಬಜಾರ್ AI ಸಹಾಯಕ. ಖರೀದಿ, ಮಾರಾಟ, ಹರಾಜು, ವಿಮೆ, ಫೈನಾನ್ಸ್ ಅಥವಾ ಯಾವುದೇ ಪ್ರಶ್ನೆ ಕೇಳಿ. ನಿಮ್ಮ ಭಾಷೆಯಲ್ಲೇ ಉತ್ತರಿಸುತ್ತೇನೆ.',
  'ml':
      'നമസ്കാരം, ഞാൻ **വാഹൻ വാണി**, വാഹൻ ബസാറിന്റെ AI അസിസ്റ്റന്റ്. വാങ്ങൽ, വിൽപ്പന, ലേലം, ഇൻഷുറൻസ്, ഫിനാൻസ് അല്ലെങ്കിൽ ഏത് ചോദ്യവും ചോദിക്കൂ. നിങ്ങളുടെ ഭാഷയിൽ മറുപടി നൽകും.',
  'ta':
      'வணக்கம், நான் **வாகன் வாணி**, வாகன் பஜாரின் AI உதவியாளர். வாங்குதல், விற்பனை, ஏலம், காப்பீடு, நிதி அல்லது எந்தக் கேள்வியும் கேளுங்கள். உங்கள் மொழியிலேயே பதிலளிப்பேன்.',
};

/// Starter buttons, same four as the website.
const List<({String label, String ask, IconData icon})> kVaaniQuick = [
  (
    label: 'Sell my vehicle',
    ask: 'How do I sell my vehicle?',
    icon: Icons.swap_horiz_rounded,
  ),
  (
    label: 'Live auctions',
    ask: 'How do live auctions work?',
    icon: Icons.gavel_rounded,
  ),
  (
    label: 'Insurance & finance',
    ask: 'Tell me about insurance & finance',
    icon: Icons.shield_outlined,
  ),
  (
    label: 'Talk to a person',
    ask: 'I would like to talk to a person',
    icon: Icons.headset_mic_outlined,
  ),
];

class ChatController extends GetxController {
  static const int _maxKept = 30; // website keeps and sends the last 30

  final messages = <ChatMessage>[].obs;
  final busy = false.obs;
  final error = ''.obs;

  final input = TextEditingController();
  final scroll = ScrollController();

  CancelToken? _cancel;
  String _lastAsk = '';

  String get lang {
    final code = LocalStorageService.to.getString(
      StorageKeys.languageCode,
      defaultValue: 'en',
    );
    return kVaaniGreeting.containsKey(code) ? code : 'en';
  }

  String get greeting => kVaaniGreeting[lang]!;

  Future<void> send(String text) async {
    final content = text.trim();
    if (content.isEmpty || busy.value) return;
    error.value = '';
    input.clear();
    _lastAsk = content;

    final history = [...messages, ChatMessage(isUser: true, content: content)];
    messages.assignAll(history);
    final reply = ChatMessage(isUser: false);
    messages.add(reply);
    busy.value = true;
    _scrollToEnd();

    final cancel = _cancel = CancelToken();
    try {
      await for (final ev in ChatService.instance.send(
        history: history.length > _maxKept
            ? history.sublist(history.length - _maxKept)
            : history,
        lang: lang,
        cancel: cancel,
      )) {
        if (ev.text != null) reply.content += ev.text!;
        if (ev.callbackNote != null) reply.note = ev.callbackNote;
        if (ev.error != null) error.value = ev.error!;
        messages.refresh();
        _scrollToEnd();
      }
    } finally {
      if (reply.content.isEmpty) messages.remove(reply);
      busy.value = false;
      _cancel = null;
      messages.refresh();
    }
  }

  /// Re-sends the question that failed (drops it first so it is not duplicated).
  void retry() {
    if (busy.value || _lastAsk.isEmpty) return;
    if (messages.isNotEmpty && messages.last.isUser) messages.removeLast();
    send(_lastAsk);
  }

  void newChat() {
    _cancel?.cancel();
    messages.clear();
    error.value = '';
    busy.value = false;
    _lastAsk = '';
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scroll.hasClients) return;
      scroll.animateTo(
        scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void onClose() {
    _cancel?.cancel();
    input.dispose();
    scroll.dispose();
    super.onClose();
  }
}
