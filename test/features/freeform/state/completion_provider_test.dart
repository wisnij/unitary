import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:unitary/features/freeform/state/completion_provider.dart';

ProviderContainer _makeContainer() => ProviderContainer();

void main() {
  group('completionsProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = _makeContainer();
    });

    tearDown(() {
      container.dispose();
    });

    List<String> names(String text, int cursor) {
      return container
          .read(
            completionsProvider(
              CompletionQuery(text: text, cursorOffset: cursor),
            ),
          )
          .map((e) => e.name)
          .toList();
    }

    test('returns suggestions for partial unit identifier', () {
      // "5 kg" — cursor at 4 (end of "kg")
      final result = names('5 kg', 4);
      expect(result, isNotEmpty);
      expect(result, contains('kg'));
    });

    test('returns empty list when cursor is in whitespace', () {
      // "5 kg" — cursor at 1 (space)
      expect(names('5 kg', 1), isEmpty);
    });

    test('returns empty list for single-character token', () {
      // "5 k" — cursor at 3; token "k" is suppressed (< 2 chars)
      expect(names('5 k', 3), isEmpty);
    });

    test('returns empty list when no entries match', () {
      expect(names('zzzzz', 5), isEmpty);
    });

    test('returns function suggestions', () {
      final result = names('tempC', 5);
      expect(result, contains('tempC'));
    });

    test('returns prefix suggestions', () {
      final result = names('kilo', 4);
      expect(result, contains('kilo'));
    });

    test('results are passed through from repo.suggestCompletions', () {
      // Smoke-test: non-empty result for a known prefix.
      final result = names('kilogram', 8);
      expect(result, contains('kilogram'));
    });

    test('different queries produce independent results', () {
      final r1 = names('kg', 2);
      final r2 = names('tempC', 5);
      expect(r1, isNot(equals(r2)));
    });
  });
}
