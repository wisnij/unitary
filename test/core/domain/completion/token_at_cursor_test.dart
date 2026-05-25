import 'package:flutter_test/flutter_test.dart';

import 'package:unitary/core/domain/completion/token_at_cursor.dart';

void main() {
  group('tokenAtCursor', () {
    group('returns a token', () {
      test('cursor at end of a partial identifier (≥2 chars)', () {
        // "5 kilo" — 'k' is at char 2, 'o' at char 5, end=6.
        final result = tokenAtCursor('5 kilo', 6);
        expect(result, isNotNull);
        expect(result!.prefix, equals('kilo'));
        expect(result.start, equals(2));
      });

      test('cursor at end of a two-character identifier', () {
        final result = tokenAtCursor('km', 2);
        expect(result, isNotNull);
        expect(result!.prefix, equals('km'));
        expect(result.start, equals(0));
      });

      test('cursor at end of identifier preceded by operator', () {
        // "5*km" — '*' at 1, 'k' at 2, end=4.
        final result = tokenAtCursor('5*km', 4);
        expect(result, isNotNull);
        expect(result!.prefix, equals('km'));
        expect(result.start, equals(2));
      });

      test('cursor at end of second identifier in expression', () {
        final result = tokenAtCursor('3 kg + 2 gram', 13);
        expect(result, isNotNull);
        expect(result!.prefix, equals('gram'));
        expect(result.start, equals(9));
      });
    });

    group('returns null', () {
      test('cursor mid-identifier', () {
        // "kilogram" — cursor after "kilo" (offset 4), identifier ends at 8.
        expect(tokenAtCursor('kilogram', 4), isNull);
      });

      test('cursor mid-identifier in longer expression', () {
        // "123 identifier" — cursor after "ident" (offset 8).
        expect(tokenAtCursor('123 identifier', 8), isNull);
      });

      test('single-character token is suppressed', () {
        // "5 k" — 'k' at char 2, end=3; length < 2.
        expect(tokenAtCursor('5 k', 3), isNull);
      });

      test('cursor in whitespace between tokens', () {
        // "5 km" — space is at char 1.
        expect(tokenAtCursor('5 km', 1), isNull);
      });

      test('cursor at start of identifier (not at end)', () {
        expect(tokenAtCursor('km', 0), isNull);
      });

      test('cursor after operator (not at identifier end)', () {
        // "5*km" — cursor at 1 (after '5', at '*').
        expect(tokenAtCursor('5*km', 1), isNull);
      });

      test('scientific-notation exponent not treated as identifier', () {
        // Lexer parses "1e10" as a single number token; 'e' is not an
        // identifier character in this context.
        expect(tokenAtCursor('1e10', 2), isNull);
      });

      test('empty string', () {
        expect(tokenAtCursor('', 0), isNull);
      });

      test('invalid expression (LexException) returns null', () {
        // '[' is in _identifierExcludedChars but not handled by the switch,
        // so Lexer throws LexException for it.
        expect(tokenAtCursor('5 [km', 5), isNull);
      });
    });
  });
}
