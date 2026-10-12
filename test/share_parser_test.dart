import 'package:flutter_test/flutter_test.dart';
import 'package:stashly/data/models/item.dart';
import 'package:stashly/data/services/share_parser.dart';

void main() {
  group('Share Parser Test Suite', () {
    test('parses plain text note', () {
      final payload = SharedPayload.parseText('My Grocery List\n- Milk\n- Eggs');
      expect(payload, isNotNull);
      expect(payload!.type, ItemType.note);
      expect(payload.title, 'My Grocery List');
      expect(payload.content, '- Milk\n- Eggs');
      expect(payload.url, isNull);
    });

    test('parses Chrome style Title\\nURL as link', () {
      final payload = SharedPayload.parseText('Flutter Documentation\nhttps://flutter.dev/docs');
      expect(payload, isNotNull);
      expect(payload!.type, ItemType.link);
      expect(payload.title, 'Flutter Documentation');
      expect(payload.url, 'https://flutter.dev/docs');
    });

    test('parses bare URL with host as fallback title', () {
      final payload = SharedPayload.parseText('https://supabase.com/docs');
      expect(payload, isNotNull);
      expect(payload!.type, ItemType.link);
      expect(payload.title, 'supabase.com');
      expect(payload.url, 'https://supabase.com/docs');
    });

    test('safely handles empty or null input without crash', () {
      expect(SharedPayload.parseText(null), isNull);
      expect(SharedPayload.parseText('   '), isNull);
    });

    test('truncates text over 20,000 characters and sets warning', () {
      final huge = 'A' * 25000;
      final payload = SharedPayload.parseText(huge);
      expect(payload, isNotNull);
      expect(payload!.content!.length, lessThanOrEqualTo(20000));
      expect(payload.warningMessage, isNotNull);
    });
  });
}
