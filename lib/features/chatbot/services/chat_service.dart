import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../core/network/api_constants.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/storage/storage_keys.dart';
import '../models/chat_message.dart';

/// One event from the website's `/api/chat` NDJSON stream.
class ChatEvent {
  final String? text;
  final String? error;
  final String? callbackNote;
  const ChatEvent({this.text, this.error, this.callbackNote});
}

/// Talks to the same assistant ("Vaani") as the website: POST /api/chat on the
/// website host, which streams newline-delimited JSON
/// (`{"t": "..."}`, `{"event":"callback_saved","note":"..."}`, `{"error":"..."}`, `{"done":true}`).
class ChatService {
  ChatService._();
  static final ChatService instance = ChatService._();

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.chatBaseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 90),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  Future<Map<String, String>> _sessionHeaders() async {
    // The website identifies a signed-in visitor by these two cookies (the
    // backend token and user id). The app holds the same values, so the bot
    // knows who is chatting and can use the master search.
    final token = await SecureStorageService.instance.read(
      StorageKeys.authToken,
    );
    final uid = await SecureStorageService.instance.read(StorageKeys.userId);
    if (token == null || token.isEmpty || uid == null || uid.isEmpty) {
      return const {};
    }
    return {
      'Cookie':
          'vb_token=${Uri.encodeComponent(token)}; vb_uid=${Uri.encodeComponent(uid)}',
    };
  }

  /// [history] ends with the user's new message. Yields reply chunks as they stream in.
  Stream<ChatEvent> send({
    required List<ChatMessage> history,
    required String lang,
    CancelToken? cancel,
  }) async* {
    final messages = history
        .where((m) => m.content.trim().isNotEmpty)
        .map(
          (m) => {
            'role': m.isUser ? 'user' : 'assistant',
            'content': m.isUser
                ? m.content
                : '${parseReply(m.content).body}${m.note != null ? '\n\n${m.note}' : ''}',
          },
        )
        .toList();

    final Response<ResponseBody> res;
    try {
      res = await _dio.post<ResponseBody>(
        '/api/chat',
        data: jsonEncode({'messages': messages, 'page': '/app', 'lang': lang}),
        cancelToken: cancel,
        options: Options(
          responseType: ResponseType.stream,
          headers: await _sessionHeaders(),
          validateStatus: (_) => true,
        ),
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) return;
      yield const ChatEvent(
        error:
            'Could not reach the assistant. Please check your internet connection and try again.',
      );
      return;
    }

    if ((res.statusCode ?? 0) >= 400) {
      var msg = 'Something went wrong. Please try again.';
      try {
        final raw = await utf8.decodeStream(res.data!.stream);
        final j = jsonDecode(raw);
        if (j is Map && j['error'] is String) msg = j['error'] as String;
      } catch (_) {}
      yield ChatEvent(error: msg);
      return;
    }

    try {
      final lines = res.data!.stream
          .cast<List<int>>()
          .transform(utf8.decoder)
          .transform(const LineSplitter());
      await for (final line in lines) {
        if (line.trim().isEmpty) continue;
        final Object? ev;
        try {
          ev = jsonDecode(line);
        } catch (_) {
          continue;
        }
        if (ev is! Map) continue;
        if (ev['t'] is String) yield ChatEvent(text: ev['t'] as String);
        if (ev['event'] == 'callback_saved' && ev['note'] is String) {
          yield ChatEvent(callbackNote: ev['note'] as String);
        }
        if (ev['error'] is String)
          yield ChatEvent(error: ev['error'] as String);
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) return;
      yield const ChatEvent(error: 'Connection lost. Please try again.');
    } catch (_) {
      yield const ChatEvent(error: 'Connection lost. Please try again.');
    }
  }
}
