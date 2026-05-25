import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:unitary/features/freeform/presentation/widgets/completion_field.dart';

TextEditingValue _value(String text, int cursor) => TextEditingValue(
  text: text,
  selection: TextSelection.collapsed(offset: cursor),
);

void main() {
  group('applyCompletion', () {
    test('replaces partial token at start of expression', () {
      final result = applyCompletion(_value('kilo', 4), 'kilogram');
      expect(result.text, equals('kilogram'));
      expect(result.selection.baseOffset, equals(8));
    });

    test('replaces partial token mid-expression', () {
      final result = applyCompletion(_value('3 kg + 2 gra', 12), 'gram');
      expect(result.text, equals('3 kg + 2 gram'));
      expect(result.selection.baseOffset, equals(13));
    });

    test('replaces partial token at end of expression', () {
      final result = applyCompletion(_value('5 kilo', 6), 'kilometer');
      expect(result.text, equals('5 kilometer'));
      expect(result.selection.baseOffset, equals(11));
    });

    test('returns value unchanged when cursor is not at end of identifier', () {
      // Cursor mid-identifier — tokenAtCursor returns null.
      final original = _value('kilogram', 4);
      expect(applyCompletion(original, 'kg'), equals(original));
    });

    test('returns value unchanged when cursor is in whitespace', () {
      final original = _value('5 km', 1);
      expect(applyCompletion(original, 'kg'), equals(original));
    });

    test('cursor positioned immediately after inserted name', () {
      final result = applyCompletion(_value('5 te', 4), 'tempF');
      expect(
        result.selection.baseOffset,
        equals(result.text.indexOf('tempF') + 5),
      );
    });
  });
}
