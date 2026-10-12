import 'package:flutter_test/flutter_test.dart';
import 'package:stashly/core/errors.dart';
import 'package:stashly/core/validators.dart';

void main() {
  group('Validators Test Suite', () {
    test('sanitizeTitle fallback rules', () {
      expect(Validators.sanitizeTitle(null), 'Untitled');
      expect(Validators.sanitizeTitle('   '), 'Untitled');
      expect(
        Validators.sanitizeTitle('', url: 'https://github.com/flutter/flutter'),
        'github.com',
      );
      expect(
        Validators.sanitizeTitle('', content: 'First line of snippet\nSecond line'),
        'First line of snippet',
      );
      expect(
        Validators.sanitizeTitle('Custom Title', url: 'https://github.com'),
        'Custom Title',
      );
    });

    test('validateAndNormalizeUrl protocol and limits', () {
      expect(Validators.validateAndNormalizeUrl('example.com'), 'https://example.com');
      expect(Validators.validateAndNormalizeUrl('http://insecure.com'), 'http://insecure.com');
      expect(
        () => Validators.validateAndNormalizeUrl('javascript:alert(1)'),
        throwsA(isA<ValidationException>()),
      );
    });

    test('sanitizeTags formatting and limits', () {
      final tags = ['#flutter', 'Dart', 'FLUTTER', '#supabase', ' '];
      final sanitized = Validators.sanitizeTags(tags);
      expect(sanitized, ['flutter', 'dart', 'supabase']);
    });
  });
}
