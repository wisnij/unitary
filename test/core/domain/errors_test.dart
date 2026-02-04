import 'package:flutter_test/flutter_test.dart';
import 'package:unitary/core/domain/errors.dart';

void main() {
  group('UnitaryException hierarchy', () {
    test('LexException is a UnitaryException', () {
      final error = LexException('bad character');
      expect(error, isA<UnitaryException>());
    });

    test('ParseException is a UnitaryException', () {
      final error = ParseException('unexpected token');
      expect(error, isA<UnitaryException>());
    });

    test('EvalException is a UnitaryException', () {
      final error = EvalException('division by zero');
      expect(error, isA<UnitaryException>());
    });

    test('DimensionException is a UnitaryException', () {
      final error = DimensionException('non-conformable');
      expect(error, isA<UnitaryException>());
    });

    test('all subtypes are caught by UnitaryException', () {
      final exceptions = <UnitaryException>[
        LexException('a'),
        ParseException('b'),
        EvalException('c'),
        DimensionException('d'),
      ];
      for (final e in exceptions) {
        expect(() => throw e, throwsA(isA<UnitaryException>()));
      }
    });
  });

  group('LexException', () {
    test('stores message', () {
      final error = LexException('unexpected character');
      expect(error.message, 'unexpected character');
    });

    test('stores line and column', () {
      final error = LexException('bad char', line: 3, column: 7);
      expect(error.line, 3);
      expect(error.column, 7);
    });

    test('line and column default to null', () {
      final error = LexException('bad char');
      expect(error.line, isNull);
      expect(error.column, isNull);
    });

    test('toString includes position when available', () {
      final error = LexException('bad char', line: 1, column: 5);
      expect(error.toString(), contains('1:5'));
      expect(error.toString(), contains('bad char'));
    });

    test('toString omits position when not available', () {
      final error = LexException('bad char');
      final str = error.toString();
      expect(str, contains('bad char'));
      expect(str, isNot(matches(RegExp(r'\d+:\d+'))));
    });
  });

  group('ParseException', () {
    test('stores message and position', () {
      final error = ParseException('unexpected token', line: 2, column: 10);
      expect(error.message, 'unexpected token');
      expect(error.line, 2);
      expect(error.column, 10);
    });

    test('toString includes position when available', () {
      final error = ParseException('unexpected', line: 1, column: 3);
      expect(error.toString(), contains('1:3'));
      expect(error.toString(), contains('unexpected'));
    });
  });

  group('EvalException', () {
    test('stores message', () {
      final error = EvalException('division by zero');
      expect(error.message, 'division by zero');
    });

    test('toString includes message', () {
      final error = EvalException('division by zero');
      expect(error.toString(), contains('division by zero'));
    });
  });

  group('DimensionException', () {
    test('stores message', () {
      final error = DimensionException('non-conformable');
      expect(error.message, 'non-conformable');
    });

    test('toString includes message', () {
      final error = DimensionException('non-conformable');
      expect(error.toString(), contains('non-conformable'));
    });
  });
}
