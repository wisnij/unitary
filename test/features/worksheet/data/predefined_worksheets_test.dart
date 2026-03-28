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

      test('has 10 rows', () {
        expect(template.rows, hasLength(10));
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
          containsAll([
            'µm',
            'm',
            'cm',
            'mm',
            'km',
            'in',
            'ft',
            'yd',
            'mi',
            'nmi',
          ]),
        );
      });
    });

    group('mass template', () {
      late WorksheetTemplate template;
      setUp(() {
        template = predefinedWorksheets.firstWhere((t) => t.id == 'mass');
      });

      test('has 10 rows', () {
        expect(template.rows, hasLength(10));
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

      test('has 10 rows', () {
        expect(template.rows, hasLength(10));
      });

      test('all rows are UnitRow', () {
        for (final row in template.rows) {
          expect(row.kind, isA<UnitRow>());
        }
      });

      test('contains expected expressions', () {
        final expressions = template.rows.map((r) => r.expression).toList();
        expect(
          expressions,
          containsAll([
            'ns',
            'µs',
            'ms',
            's',
            'min',
            'hr',
            'd',
            'wk',
            'yr',
            'century',
          ]),
        );
      });
    });

    group('temperature template', () {
      late WorksheetTemplate template;
      setUp(() {
        template = predefinedWorksheets.firstWhere(
          (t) => t.id == 'temperature',
        );
      });

      test('has 6 rows', () {
        expect(template.rows, hasLength(6));
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

      test('gasmark row is FunctionRow', () {
        final row = template.rows.firstWhere(
          (r) => r.expression == 'gasmark',
        );
        expect(row.kind, isA<FunctionRow>());
      });
    });

    group('speed template', () {
      late WorksheetTemplate template;
      setUp(() {
        template = predefinedWorksheets.firstWhere((t) => t.id == 'speed');
      });

      test('has 10 rows', () {
        expect(template.rows, hasLength(10));
      });

      test('contains expected expressions', () {
        final expressions = template.rows.map((r) => r.expression).toList();
        expect(
          expressions,
          containsAll(['m/min', 'in/s', 'm/s', 'km/hr', 'mach', 'km/s', 'c']),
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

      test('has 10 rows', () {
        expect(template.rows, hasLength(10));
      });

      test('contains SI and IEC units interleaved', () {
        final expressions = template.rows.map((r) => r.expression).toList();
        expect(
          expressions,
          containsAll([
            'bit',
            'B',
            'kB',
            'KiB',
            'MB',
            'MiB',
            'GB',
            'GiB',
            'TB',
            'TiB',
          ]),
        );
      });

      test('SI units appear before corresponding IEC units', () {
        final expressions = template.rows.map((r) => r.expression).toList();
        expect(expressions.indexOf('kB'), lessThan(expressions.indexOf('KiB')));
        expect(expressions.indexOf('MB'), lessThan(expressions.indexOf('MiB')));
        expect(expressions.indexOf('GB'), lessThan(expressions.indexOf('GiB')));
        expect(expressions.indexOf('TB'), lessThan(expressions.indexOf('TiB')));
      });
    });

    group('energy template', () {
      late WorksheetTemplate template;
      setUp(() {
        template = predefinedWorksheets.firstWhere((t) => t.id == 'energy');
      });

      test('has 10 rows', () {
        expect(template.rows, hasLength(10));
      });

      test('small calories row uses cal_th expression', () {
        final row = template.rows.firstWhere((r) => r.expression == 'cal_th');
        expect(row.label, 'small calories');
      });

      test('food Calories row uses kcal expression', () {
        final row = template.rows.firstWhere((r) => r.expression == 'kcal');
        expect(row.label, 'food Calories');
      });

      test('contains watt-hours', () {
        final expressions = template.rows.map((r) => r.expression).toList();
        expect(expressions, contains('Wh'));
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
