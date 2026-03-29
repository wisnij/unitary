import 'package:flutter_test/flutter_test.dart';

import 'package:unitary/core/domain/models/unit_repository.dart';
import 'package:unitary/core/domain/parser/expression_parser.dart';
import 'package:unitary/features/settings/models/user_settings.dart';
import 'package:unitary/features/worksheet/models/worksheet.dart';
import 'package:unitary/features/worksheet/services/worksheet_engine.dart';

void main() {
  late ExpressionParser parser;
  late UserSettings settings;

  setUp(() {
    parser = ExpressionParser(repo: UnitRepository.withPredefinedUnits());
    settings = UserSettings(precision: 8, notation: Notation.automatic);
  });

  group('computeWorksheet', () {
    const lengthRows = [
      WorksheetRow(label: 'meters', expression: 'm', kind: UnitRow()),
      WorksheetRow(label: 'centimeters', expression: 'cm', kind: UnitRow()),
      WorksheetRow(label: 'feet', expression: 'ft', kind: UnitRow()),
    ];

    test('simple unit conversion: 1 m → cm and ft', () {
      final result = computeWorksheet(
        rows: lengthRows,
        sourceIndex: 0,
        sourceText: '1',
        parser: parser,
        settings: settings,
      );
      expect(result.values[0], isNull); // source preserved
      expect(result.values[1], isNotNull);
      expect(double.parse(result.values[1]!.text), closeTo(100.0, 0.001));
      expect(result.values[2], isNotNull);
      expect(double.parse(result.values[2]!.text), closeTo(3.28084, 0.0001));
    });

    test('successful conversion result has isError false', () {
      final result = computeWorksheet(
        rows: lengthRows,
        sourceIndex: 0,
        sourceText: '1',
        parser: parser,
        settings: settings,
      );
      expect(result.values[1]!.isError, isFalse);
      expect(result.values[2]!.isError, isFalse);
    });

    test('source row is always null in result', () {
      final result = computeWorksheet(
        rows: lengthRows,
        sourceIndex: 1,
        sourceText: '100',
        parser: parser,
        settings: settings,
      );
      expect(result.values[1], isNull);
      expect(result.values[0], isNotNull); // other rows computed
    });

    test('compound expression: m/s → km/h', () {
      const speedRows = [
        WorksheetRow(label: 'm/s', expression: 'm/s', kind: UnitRow()),
        WorksheetRow(label: 'km/h', expression: 'km/hr', kind: UnitRow()),
        WorksheetRow(label: 'mph', expression: 'mph', kind: UnitRow()),
      ];
      final result = computeWorksheet(
        rows: speedRows,
        sourceIndex: 0,
        sourceText: '1',
        parser: parser,
        settings: settings,
      );
      expect(result.values[0], isNull);
      expect(double.parse(result.values[1]!.text), closeTo(3.6, 0.001));
    });

    test('empty input clears all rows', () {
      final result = computeWorksheet(
        rows: lengthRows,
        sourceIndex: 0,
        sourceText: '',
        parser: parser,
        settings: settings,
      );
      expect(result.values, everyElement(isNull));
    });

    test('non-numeric input clears all rows', () {
      final result = computeWorksheet(
        rows: lengthRows,
        sourceIndex: 0,
        sourceText: 'abc',
        parser: parser,
        settings: settings,
      );
      expect(result.values, everyElement(isNull));
    });

    group('temperature worksheet', () {
      const tempRows = [
        WorksheetRow(label: 'kelvin', expression: 'K', kind: UnitRow()),
        WorksheetRow(
          label: 'celsius',
          expression: 'tempC',
          kind: FunctionRow(),
        ),
        WorksheetRow(
          label: 'fahrenheit',
          expression: 'tempF',
          kind: FunctionRow(),
        ),
        WorksheetRow(label: 'rankine', expression: 'degR', kind: UnitRow()),
      ];

      test('tempC(0) → K=273.15, tempF=32, R=491.67', () {
        final result = computeWorksheet(
          rows: tempRows,
          sourceIndex: 1, // celsius
          sourceText: '0',
          parser: parser,
          settings: settings,
        );
        expect(result.values[1], isNull); // source
        expect(
          double.parse(result.values[0]!.text),
          closeTo(273.15, 0.01),
        ); // K
        expect(
          double.parse(result.values[2]!.text),
          closeTo(32.0, 0.01),
        ); // tempF
        expect(
          double.parse(result.values[3]!.text),
          closeTo(491.67, 0.01),
        ); // R
      });

      test('tempC(100) → K=373.15, tempF=212', () {
        final result = computeWorksheet(
          rows: tempRows,
          sourceIndex: 1,
          sourceText: '100',
          parser: parser,
          settings: settings,
        );
        expect(
          double.parse(result.values[0]!.text),
          closeTo(373.15, 0.01),
        );
        expect(
          double.parse(result.values[2]!.text),
          closeTo(212.0, 0.01),
        );
      });

      test('K source → celsius and fahrenheit', () {
        final result = computeWorksheet(
          rows: tempRows,
          sourceIndex: 0, // kelvin
          sourceText: '373.15',
          parser: parser,
          settings: settings,
        );
        expect(result.values[0], isNull);
        expect(
          double.parse(result.values[1]!.text),
          closeTo(100.0, 0.01),
        ); // celsius
        expect(
          double.parse(result.values[2]!.text),
          closeTo(212.0, 0.01),
        ); // fahrenheit
        expect(
          double.parse(result.values[3]!.text),
          closeTo(671.67, 0.01),
        ); // rankine
      });

      test('fahrenheit source → celsius', () {
        final result = computeWorksheet(
          rows: tempRows,
          sourceIndex: 2, // fahrenheit
          sourceText: '212',
          parser: parser,
          settings: settings,
        );
        expect(result.values[2], isNull);
        expect(double.parse(result.values[1]!.text), closeTo(100.0, 0.01));
        expect(double.parse(result.values[0]!.text), closeTo(373.15, 0.01));
      });
    });

    group('error labels', () {
      test('dimension mismatch produces "wrong unit type" error', () {
        const mixedRows = [
          WorksheetRow(label: 'meters', expression: 'm', kind: UnitRow()),
          WorksheetRow(
            label: 'kilograms',
            expression: 'kg',
            kind: UnitRow(),
          ),
        ];
        final result = computeWorksheet(
          rows: mixedRows,
          sourceIndex: 0,
          sourceText: '1',
          parser: parser,
          settings: settings,
        );
        expect(result.values[1]!.isError, isTrue);
        expect(result.values[1]!.text, 'wrong unit type');
      });

      test('out-of-domain function value produces "out of bounds" error', () {
        // tempC range spec requires K >= 0. A source K value of -1 is below
        // absolute zero, so callInverse on the tempC target throws BoundsException.
        const rows = [
          WorksheetRow(label: 'kelvin', expression: 'K', kind: UnitRow()),
          WorksheetRow(
            label: 'celsius',
            expression: 'tempC',
            kind: FunctionRow(),
          ),
        ];
        final result = computeWorksheet(
          rows: rows,
          sourceIndex: 0,
          sourceText: '-1',
          parser: parser,
          settings: settings,
        );
        expect(result.values[1]!.isError, isTrue);
        expect(result.values[1]!.text, 'out of bounds');
      });

      test('no-inverse FunctionRow produces "no inverse" error', () {
        // abs has no inverse.
        const rows = [
          WorksheetRow(
            label: 'celsius',
            expression: 'tempC',
            kind: FunctionRow(),
          ),
          WorksheetRow(label: 'abs', expression: 'abs', kind: FunctionRow()),
        ];
        final result = computeWorksheet(
          rows: rows,
          sourceIndex: 0,
          sourceText: '20',
          parser: parser,
          settings: settings,
        );
        expect(result.values[1]!.isError, isTrue);
        expect(result.values[1]!.text, 'no inverse');
      });
    });

    test('negative source value converts correctly', () {
      const tempRows = [
        WorksheetRow(
          label: 'celsius',
          expression: 'tempC',
          kind: FunctionRow(),
        ),
        WorksheetRow(
          label: 'fahrenheit',
          expression: 'tempF',
          kind: FunctionRow(),
        ),
      ];
      final result = computeWorksheet(
        rows: tempRows,
        sourceIndex: 0,
        sourceText: '-40',
        parser: parser,
        settings: settings,
      );
      // -40 C = -40 F
      expect(double.parse(result.values[1]!.text), closeTo(-40.0, 0.01));
    });
  });
}
