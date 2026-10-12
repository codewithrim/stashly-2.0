import 'errors.dart';

/// Validation rules defined in section 3 of stashly.md
class Validators {
  /// Title: trimmed; if empty, auto-fill from URL host, first line of content, or "Untitled". Max 200 chars.
  static String sanitizeTitle(String? rawTitle, {String? url, String? content}) {
    final trimmed = rawTitle?.trim() ?? '';
    if (trimmed.isNotEmpty) {
      return trimmed.length > 200 ? trimmed.substring(0, 200) : trimmed;
    }

    if (url != null && url.trim().isNotEmpty) {
      final uri = Uri.tryParse(url.trim());
      if (uri != null && uri.host.isNotEmpty) {
        return uri.host.length > 200 ? uri.host.substring(0, 200) : uri.host;
      }
    }

    if (content != null && content.trim().isNotEmpty) {
      final firstLine = content.trim().split('\n').first.trim();
      if (firstLine.isNotEmpty) {
        return firstLine.length > 200 ? firstLine.substring(0, 200) : firstLine;
      }
    }

    return 'Untitled';
  }

  /// URL: trim, add https:// if no scheme, parse with Uri.tryParse, allow only http/https, max 2048 chars.
  static String? validateAndNormalizeUrl(String? rawUrl) {
    if (rawUrl == null) return null;
    var trimmed = rawUrl.trim();
    if (trimmed.isEmpty) return null;

    if (!trimmed.startsWith(RegExp(r'^https?://', caseSensitive: false))) {
      trimmed = 'https://$trimmed';
    }

    if (trimmed.length > 2048) {
      throw const ValidationException('URL must not exceed 2048 characters.');
    }

    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      throw const ValidationException('Invalid URL format.');
    }

    if (uri.scheme != 'http' && uri.scheme != 'https') {
      throw const ValidationException('Only http and https protocols are supported.');
    }

    return trimmed;
  }

  /// Tags: trim, lowercase, strip leading '#', dedupe, max 30 chars each, max 20 per item.
  static List<String> sanitizeTags(Iterable<String>? rawTags) {
    if (rawTags == null) return const [];
    final set = <String>{};

    for (final raw in rawTags) {
      var t = raw.trim().toLowerCase();
      while (t.startsWith('#')) {
        t = t.substring(1).trim();
      }
      if (t.isEmpty) continue;
      if (t.length > 30) {
        t = t.substring(0, 30);
      }
      set.add(t);
      if (set.length >= 20) break;
    }

    return set.toList();
  }

  /// Content: max 20,000 chars. Whitespace-only counts as empty.
  static String? sanitizeContent(String? rawContent) {
    if (rawContent == null) return null;
    final trimmed = rawContent.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.length > 20000) {
      return trimmed.substring(0, 20000);
    }
    return trimmed;
  }
}
