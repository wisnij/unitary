import 'package:flutter_test/flutter_test.dart';

import 'package:unitary/core/domain/models/unit_repository.dart';
import 'package:unitary/core/domain/parser/ast.dart';
import 'package:unitary/core/domain/parser/expression_parser.dart';
import 'package:unitary/features/worksheet/data/predefined_worksheets.dart';
import 'package:unitary/features/worksheet/models/worksheet.dart';

void main() {
  late ExpressionParser parser;

  group('predefinedWorksheets', () {
    setUpAll(() {
      parser = ExpressionParser(repo: UnitRepository.withPredefinedUnits());
    });

    test('contains exactly 11 templates', () {
      expect(predefinedWorksheets, hasLength(11));
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

    test('every row kind matches parseQuery result', () {
      for (final template in predefinedWorksheets) {
        for (final row in template.rows) {
          final node = parser.parseQuery(row.expression);
          if (node is FunctionNameNode) {
            expect(
              row.kind,
              isA<FunctionRow>(),
              reason:
                  '${template.id}/${row.expression}: '
                  'parseQuery returned FunctionNameNode but kind is ${row.kind.runtimeType}',
            );
          } else {
            expect(
              row.kind,
              isA<UnitRow>(),
              reason:
                  '${template.id}/${row.expression}: '
                  'parseQuery returned ${node.runtimeType} but kind is ${row.kind.runtimeType}',
            );
          }
        }
      }
    });

    test('all-UnitRow templates are ordered smallest to largest', () {
      for (final template in predefinedWorksheets) {
        if (template.rows.any((r) => r.kind is! UnitRow)) {
          continue;
        }
        double? prevValue;
        String? prevExpression;
        for (final row in template.rows) {
          final qty = parser.evaluate(row.expression);
          if (prevValue != null) {
            if (qty.value == prevValue) {
              expect(
                row.expression.compareTo(prevExpression!) >= 0,
                isTrue,
                reason:
                    '${template.id}: equal-magnitude rows "${row.expression}" and '
                    '"$prevExpression" are in wrong expression order',
              );
            } else {
              expect(
                qty.value,
                greaterThanOrEqualTo(prevValue),
                reason:
                    '${template.id}: "${row.expression}" (${qty.value}) is smaller '
                    'than "$prevExpression" ($prevValue)',
              );
            }
          }
          prevValue = qty.value;
          prevExpression = row.expression;
        }
      }
    });

    group('angle template', () {
      late WorksheetTemplate template;
      setUp(() {
        template = predefinedWorksheets.firstWhere((t) => t.id == 'angle');
      });

      test('has id "angle" and name "Angle"', () {
        expect(template.id, equals('angle'));
        expect(template.name, equals('Angle'));
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
            'mas',
            'arcsec',
            'seclongitude',
            'arcmin',
            'gon',
            'degree',
            'radian',
            'sextant',
            'rightangle',
            'circle',
          ]),
        );
      });
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
            'mm',
            'cm',
            'in',
            'ft',
            'yd',
            'm',
            'km',
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

      test('contains expected expressions', () {
        final expressions = template.rows.map((r) => r.expression).toList();
        expect(
          expressions,
          containsAll([
            'µg',
            'mg',
            'g',
            'oz',
            'lb',
            'kg',
            'stone',
            'uston',
            't',
            'brton',
          ]),
        );
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

      test('contains expected expressions', () {
        final expressions = template.rows.map((r) => r.expression).toList();
        expect(
          expressions,
          containsAll([
            'K',
            'tempC',
            'tempF',
            'degR',
            'tempreaumur',
            'gasmark',
          ]),
        );
      });
    });

    group('volume template', () {
      late WorksheetTemplate template;
      setUp(() {
        template = predefinedWorksheets.firstWhere((t) => t.id == 'volume');
      });

      test('has 10 rows', () {
        expect(template.rows, hasLength(10));
      });

      test('contains expected expressions', () {
        final expressions = template.rows.map((r) => r.expression).toList();
        expect(
          expressions,
          containsAll([
            'mL',
            'tsp',
            'tbsp',
            'floz',
            'cup',
            'pt',
            'qt',
            'L',
            'gal',
            'bbl',
          ]),
        );
      });
    });

    group('area template', () {
      late WorksheetTemplate template;
      setUp(() {
        template = predefinedWorksheets.firstWhere((t) => t.id == 'area');
      });

      test('has 10 rows', () {
        expect(template.rows, hasLength(10));
      });

      test('contains expected expressions', () {
        final expressions = template.rows.map((r) => r.expression).toList();
        expect(
          expressions,
          containsAll([
            'mm^2',
            'cm^2',
            'in^2',
            'ft^2',
            'yd^2',
            'm^2',
            'acre',
            'ha',
            'km^2',
            'mi^2',
          ]),
        );
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
            'm/min',
            'in/s',
            'km/hr',
            'ft/s',
            'mph',
            'knot',
            'm/s',
            'mach',
            'km/s',
            'c',
          ]),
        );
      });
    });

    group('pressure template', () {
      late WorksheetTemplate template;
      setUp(() {
        template = predefinedWorksheets.firstWhere((t) => t.id == 'pressure');
      });

      test('has 10 rows', () {
        expect(template.rows, hasLength(10));
      });

      test('contains expected expressions', () {
        final expressions = template.rows.map((r) => r.expression).toList();
        expect(
          expressions,
          containsAll([
            'Pa',
            'mbar',
            'mmHg',
            'Torr',
            'kPa',
            'inHg',
            'psi',
            'bar',
            'atm',
            'MPa',
          ]),
        );
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

      test('contains expected expressions', () {
        final expressions = template.rows.map((r) => r.expression).toList();
        expect(
          expressions,
          containsAll([
            'eV',
            'erg',
            'J',
            'cal_th',
            'kJ',
            'BTU',
            'Wh',
            'kcal',
            'kWh',
            'ton tnt',
          ]),
        );
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
    });
  });
}
