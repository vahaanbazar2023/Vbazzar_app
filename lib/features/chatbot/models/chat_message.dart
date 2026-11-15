/// One bubble in the Vaani chat. Mirrors the website widget's `Msg` type.
class ChatMessage {
  final bool isUser;
  String content;

  /// Hidden marker the server sends once a callback request is saved, so later
  /// turns do not submit it again. Never shown to the user.
  String? note;

  ChatMessage({required this.isUser, this.content = '', this.note});
}

class ParsedReply {
  final String body;
  final List<String> chips;
  const ParsedReply(this.body, this.chips);
}

final _suggestRe = RegExp(r'\[\[suggest:([\s\S]*?)\]\]');
final _openMarkerRe = RegExp(r'\[\[[^\]]*$');

/// Splits a reply into the visible text and the tap-to-ask follow-ups, and
/// hides a half-streamed `[[suggest: ...` marker (same rule as the website).
ParsedReply parseReply(String text) {
  final m = _suggestRe.firstMatch(text);
  final chips = m == null
      ? <String>[]
      : m
            .group(1)!
            .split('|')
            .map((c) => c.trim())
            .where((c) => c.isNotEmpty)
            .take(3)
            .toList();
  final body = text
      .replaceAll(_suggestRe, '')
      .replaceFirst(_openMarkerRe, '')
      .trimRight();
  return ParsedReply(body, chips);
}
