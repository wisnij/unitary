import 'package:flutter_test/flutter_test.dart';

import 'package:unitary/features/settings/models/user_settings.dart';

void main() {
  group('Notation', () {
    test('has three values', () {
      expect(Notation.values, hasLength(3));
      expect(Notation.values, contains(Notation.decimal));
      expect(Notation.values, contains(Notation.scientific));
      expect(Notation.values, contains(Notation.engineering));
    });

    test('label returns human-readable string', () {
      expect(Notation.decimal.label, 'Decimal');
      expect(Notation.scientific.label, 'Scientific');
      expect(Notation.engineering.label, 'Engineering');
    });
  });

  group('EvaluationMode', () {
    test('has two values', () {
      expect(EvaluationMode.values, hasLength(2));
      expect(EvaluationMode.values, contains(EvaluationMode.realtime));
      expect(EvaluationMode.values, contains(EvaluationMode.onSubmit));
    });

    test('label returns human-readable string', () {
      expect(EvaluationMode.realtime.label, 'Real-time');
      expect(EvaluationMode.onSubmit.label, 'On submit');
    });
  });

  group('UserSettings', () {
    test('defaults() creates settings with default values', () {
      final settings = UserSettings.defaults();
      expect(settings.precision, 6);
      expect(settings.notation, Notation.decimal);
      expect(settings.darkMode, isNull);
      expect(settings.evaluationMode, EvaluationMode.realtime);
    });

    test('constructor accepts valid precision values', () {
      for (final p in [2, 5, 6, 10]) {
        final settings = UserSettings(precision: p);
        expect(settings.precision, p);
      }
    });

    test('constructor rejects precision below 2', () {
      expect(
        () => UserSettings(precision: 1),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => UserSettings(precision: 0),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => UserSettings(precision: -1),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('constructor rejects precision above 10', () {
      expect(
        () => UserSettings(precision: 11),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => UserSettings(precision: 100),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('constructor accepts all notation values', () {
      for (final n in Notation.values) {
        final settings = UserSettings(notation: n);
        expect(settings.notation, n);
      }
    });

    test('constructor accepts all darkMode values', () {
      for (final d in [null, true, false]) {
        final settings = UserSettings(darkMode: d);
        expect(settings.darkMode, d);
      }
    });

    test('constructor accepts all evaluationMode values', () {
      for (final e in EvaluationMode.values) {
        final settings = UserSettings(evaluationMode: e);
        expect(settings.evaluationMode, e);
      }
    });

    group('copyWith', () {
      test('returns identical settings when no arguments given', () {
        final original = UserSettings(
          precision: 4,
          notation: Notation.scientific,
          darkMode: true,
          evaluationMode: EvaluationMode.onSubmit,
        );
        final copy = original.copyWith();
        expect(copy.precision, original.precision);
        expect(copy.notation, original.notation);
        expect(copy.darkMode, original.darkMode);
        expect(copy.evaluationMode, original.evaluationMode);
        expect(copy, equals(original));
      });

      test('changes precision', () {
        final original = UserSettings.defaults();
        final copy = original.copyWith(precision: 8);
        expect(copy.precision, 8);
        expect(copy.notation, original.notation);
      });

      test('changes notation', () {
        final original = UserSettings.defaults();
        final copy = original.copyWith(notation: Notation.engineering);
        expect(copy.notation, Notation.engineering);
        expect(copy.precision, original.precision);
      });

      test('changes darkMode', () {
        final original = UserSettings.defaults();
        final copy = original.copyWith(darkMode: false);
        expect(copy.darkMode, false);
      });

      test('changes darkMode to null via clearDarkMode', () {
        final original = UserSettings(darkMode: true);
        final copy = original.copyWith(clearDarkMode: true);
        expect(copy.darkMode, isNull);
      });

      test('changes evaluationMode', () {
        final original = UserSettings.defaults();
        final copy = original.copyWith(
          evaluationMode: EvaluationMode.onSubmit,
        );
        expect(copy.evaluationMode, EvaluationMode.onSubmit);
      });

      test('validates precision', () {
        final original = UserSettings.defaults();
        expect(
          () => original.copyWith(precision: 1),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('equality', () {
      test('equal settings are equal', () {
        final a = UserSettings(precision: 4, notation: Notation.scientific);
        final b = UserSettings(precision: 4, notation: Notation.scientific);
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('different precision makes unequal', () {
        final a = UserSettings(precision: 4);
        final b = UserSettings(precision: 6);
        expect(a, isNot(equals(b)));
      });

      test('different notation makes unequal', () {
        final a = UserSettings(notation: Notation.decimal);
        final b = UserSettings(notation: Notation.scientific);
        expect(a, isNot(equals(b)));
      });

      test('different darkMode makes unequal', () {
        final a = UserSettings(darkMode: null);
        final b = UserSettings(darkMode: true);
        expect(a, isNot(equals(b)));
      });

      test('different evaluationMode makes unequal', () {
        final a = UserSettings(evaluationMode: EvaluationMode.realtime);
        final b = UserSettings(evaluationMode: EvaluationMode.onSubmit);
        expect(a, isNot(equals(b)));
      });
    });

    test('toString includes all fields', () {
      final settings = UserSettings.defaults();
      final str = settings.toString();
      expect(str, contains('precision'));
      expect(str, contains('notation'));
      expect(str, contains('darkMode'));
      expect(str, contains('evaluationMode'));
    });
  });
}
