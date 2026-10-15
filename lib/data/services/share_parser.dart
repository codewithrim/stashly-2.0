import '../models/item.dart';

class SharedPayload {
  final ItemType type;
  final String title;
  final String? content;
  final String? url;
  final String? attachmentPath;
  final String? warningMessage;

  const SharedPayload({
    required this.type,
    required this.title,
    this.content,
    this.url,
    this.attachmentPath,
    this.warningMessage,
  });

  /// Parsing rules per section 5.5:
  /// - Trim the text.
  /// - If it contains a URL (first http(s) match), create a link item with URL filled in
  ///   and remaining text as title/content. Handle Chrome's "Title\nURL" format.
  /// - Otherwise create a note with the text as content.
  /// - Malformed, empty, huge (truncate over limit with notice) are handled safely without crash.
  static SharedPayload? parseText(String? rawText) {
    if (rawText == null || rawText.trim().isEmpty) {
      return null;
    }

    var text = rawText.trim();
    String? warning;

    // Truncate huge text over 20,000 characters
    if (text.length > 20000) {
      text = text.substring(0, 20000);
      warning = 'Content was truncated because it exceeded 20,000 characters.';
    }

    final urlRegex = RegExp(r'https?://[^\s]+', caseSensitive: false);
    final match = urlRegex.firstMatch(text);

    if (match != null) {
      final foundUrl = match.group(0)!;
      final beforeUrl = text.substring(0, match.start).trim();
      final afterUrl = text.substring(match.end).trim();

      String title = '';
      String? content;

      if (beforeUrl.isNotEmpty) {
        final lines = beforeUrl
            .split('\n')
            .map((l) => l.trim())
            .where((l) => l.isNotEmpty)
            .toList();
        if (lines.isNotEmpty) {
          title = lines.first;
          if (lines.length > 1) {
            content = lines.sublist(1).join('\n');
          }
        }
      }

      if (afterUrl.isNotEmpty) {
        content = (content == null || content.isEmpty)
            ? afterUrl
            : '$content\n$afterUrl';
      }

      if (title.isEmpty) {
        final uri = Uri.tryParse(foundUrl);
        title = uri?.host ?? 'Shared Link';
      }

      return SharedPayload(
        type: ItemType.link,
        title: title.length > 200 ? title.substring(0, 200) : title,
        url: foundUrl.length > 2048 ? foundUrl.substring(0, 2048) : foundUrl,
        content: content,
        warningMessage: warning,
      );
    } else {
      // Note item
      final lines = text
          .split('\n')
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty)
          .toList();
      final title = lines.isNotEmpty ? lines.first : 'Shared Note';
      final content = lines.length > 1 ? lines.sublist(1).join('\n') : text;

      return SharedPayload(
        type: ItemType.note,
        title: title.length > 200 ? title.substring(0, 200) : title,
        content: content,
        warningMessage: warning,
      );
    }
  }
}
