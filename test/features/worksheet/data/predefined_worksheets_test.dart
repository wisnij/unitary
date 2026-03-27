import 'package:flutter_test/flutter_test.dart';

import 'package:unitary/features/worksheet/data/predefined_worksheets.dart';
import 'package:unitary/features/worksheet/models/worksheet.dart';

void main() {
  group('predefinedWorksheets', () {
    test('contains exactly 10 templates', () {
      expect(predefinedWorksheets, hasLength(10));
    });

    test('all template ids are distinct', () {
      final ids = predefinedWorksheets.map((t) => t.id).toList();
      expect(ids.toSet(), hasLength(ids.length));
    });

    test('all templates have non-empty rows', () {
      for (final template in predefinedWorksheets) {
        expect(template.rows, isNotEmpty, reason: '${template.id} has no rows');
      }
    });

    group('length template', () {
      late WorksheetTemplate template;
      setUp(() {
        template = predefinedWorksheets.firstWhere((t) => t.id == 'length');
      });

      test('has 9 rows', () {
        expect(template.rows, hasLength(9));
      });

      test('all rows are UnitRow', () {
        for (final row in template.rows) {
          expect(
            row.kind,
            isA<UnitRow>(),
            reason: '${row.expression} is not UnitRow',
          );
        }
      });

      test('contains expected expressions', () {
        final expressions = template.rows.map((r) => r.expression).toList();
        expect(
          expressions,
          containsAll(['m', 'cm', 'mm', 'km', 'in', 'ft', 'yd', 'mi', 'nmi']),
        );
      });
    });

    group('mass template', () {
      late WorksheetTemplate template;
      setUp(() {
        template = predefinedWorksheets.firstWhere((t) => t.id == 'mass');
      });

      test('has 9 rows', () {
        expect(template.rows, hasLength(9));
      });

      test('all rows are UnitRow', () {
        for (final row in template.rows) {
          expect(row.kind, isA<UnitRow>());
        }
      });

      test('contains stone, shortton, longton', () {
        final expressions = template.rows.map((r) => r.expression).toList();
        expect(expressions, containsAll(['stone', 'uston', 'brton']));
      });
    });

    group('time template', () {
      late WorksheetTemplate template;
      setUp(() {
        template = predefinedWorksheets.firstWhere((t) => t.id == 'time');
      });

      test('has 7 rows', () {
        expect(template.rows, hasLength(7));
      });

      test('all rows are UnitRow', () {
        for (final row in template.rows) {
          expect(row.kind, isA<UnitRow>());
        }
      });

      test('uses d, wk, year expressions', () {
        final expressions = template.rows.map((r) => r.expression).toList();
        expect(expressions, contains('d'));
        expect(expressions, contains('wk'));
        expect(expressions, contains('year'));
      });
    });

    group('temperature template', () {
      late WorksheetTemplate template;
      setUp(() {
        template = predefinedWorksheets.firstWhere(
          (t) => t.id == 'temperature',
        );
      });

      test('has 5 rows', () {
        expect(template.rows, hasLength(5));
      });

      test('K row is UnitRow', () {
        final row = template.rows.firstWhere((r) => r.expression == 'K');
        expect(row.kind, isA<UnitRow>());
      });

      test('tempC row is FunctionRow', () {
        final row = template.rows.firstWhere((r) => r.expression == 'tempC');
        expect(row.kind, isA<FunctionRow>());
      });

      test('tempF row is FunctionRow', () {
        final row = template.rows.firstWhere((r) => r.expression == 'tempF');
        expect(row.kind, isA<FunctionRow>());
      });

      test('degR row is UnitRow', () {
        final row = template.rows.firstWhere((r) => r.expression == 'degR');
        expect(row.kind, isA<UnitRow>());
      });

      test('tempreaumur row is FunctionRow', () {
        final row = template.rows.firstWhere(
          (r) => r.expression == 'tempreaumur',
        );
        expect(row.kind, isA<FunctionRow>());
      });
    });

    group('speed template', () {
      late WorksheetTemplate template;
      setUp(() {
        template = predefinedWorksheets.firstWhere((t) => t.id == 'speed');
      });

      test('contains expected expressions', () {
        final expressions = template.rows.map((r) => r.expression).toList();
        expect(
          expressions,
          containsAll(['m/s', 'km/hr', 'mach', 'km/s', 'c']),
        );
      });

      test('all rows are UnitRow', () {
        for (final row in template.rows) {
          expect(row.kind, isA<UnitRow>());
        }
      });
    });

    group('digital-storage template', () {
      late WorksheetTemplate template;
      setUp(() {
        template = predefinedWorksheets.firstWhere(
          (t) => t.id == 'digital-storage',
        );
      });

      test('has 6 rows', () {
        expect(template.rows, hasLength(6));
      });

      test('uses binary units', () {
        final expressions = template.rows.map((r) => r.expression).toList();
        expect(
          expressions,
          containsAll(['bit', 'B', 'KiB', 'MiB', 'GiB', 'TiB']),
        );
      });
    });

    group('area template', () {
      late WorksheetTemplate template;
      setUp(() {
        template = predefinedWorksheets.firstWhere((t) => t.id == 'area');
      });

      test('contains compound expressions', () {
        final expressions = template.rows.map((r) => r.expression).toList();
        expect(expressions, contains('m^2'));
        expect(expressions, contains('ft^2'));
      });
    });
  });
}
