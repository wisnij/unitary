import 'package:flutter_test/flutter_test.dart';

import 'package:unitary/features/worksheet/models/worksheet.dart';

void main() {
  group('WorksheetRowKind', () {
    test('UnitRow is a WorksheetRowKind', () {
      const kind = UnitRow();
      expect(kind, isA<WorksheetRowKind>());
      expect(kind, isA<UnitRow>());
    });

    test('FunctionRow is a WorksheetRowKind', () {
      const kind = FunctionRow();
      expect(kind, isA<WorksheetRowKind>());
      expect(kind, isA<FunctionRow>());
    });

    test('UnitRow and FunctionRow are distinct', () {
      const a = UnitRow();
      const b = FunctionRow();
      expect(a, isNot(isA<FunctionRow>()));
      expect(b, isNot(isA<UnitRow>()));
    });

    test('sealed class switch is exhaustive', () {
      const WorksheetRowKind kind = UnitRow();
      final result = switch (kind) {
        UnitRow() => 'unit',
        FunctionRow() => 'function',
      };
      expect(result, 'unit');
    });
  });

  group('WorksheetRow', () {
    test('UnitRow construction stores all fields', () {
      const row = WorksheetRow(
        label: 'feet',
        expression: 'ft',
        kind: UnitRow(),
      );
      expect(row.label, 'feet');
      expect(row.expression, 'ft');
      expect(row.kind, isA<UnitRow>());
    });

    test('FunctionRow construction stores all fields', () {
      const row = WorksheetRow(
        label: 'celsius',
        expression: 'tempC',
        kind: FunctionRow(),
      );
      expect(row.label, 'celsius');
      expect(row.expression, 'tempC');
      expect(row.kind, isA<FunctionRow>());
    });

    test('compound expression stored as-is', () {
      const row = WorksheetRow(
        label: 'km/h',
        expression: 'km/h',
        kind: UnitRow(),
      );
      expect(row.expression, 'km/h');
    });
  });

  group('WorksheetTemplate', () {
    test('construction stores all fields', () {
      const template = WorksheetTemplate(
        id: 'length',
        name: 'Length',
        ordering: WorksheetOrdering.magnitude,
        rows: [
          WorksheetRow(label: 'meters', expression: 'm', kind: UnitRow()),
          WorksheetRow(label: 'feet', expression: 'ft', kind: UnitRow()),
        ],
      );
      expect(template.id, 'length');
      expect(template.name, 'Length');
      expect(template.ordering, WorksheetOrdering.magnitude);
      expect(template.rows, hasLength(2));
    });

    test('rows list is accessible', () {
      const template = WorksheetTemplate(
        id: 'temperature',
        name: 'Temperature',
        ordering: WorksheetOrdering.none,
        rows: [
          WorksheetRow(label: 'kelvin', expression: 'K', kind: UnitRow()),
          WorksheetRow(
            label: 'celsius',
            expression: 'tempC',
            kind: FunctionRow(),
          ),
        ],
      );
      expect(template.rows[0].kind, isA<UnitRow>());
      expect(template.rows[1].kind, isA<FunctionRow>());
    });

    test('banner defaults to null when not specified', () {
      const template = WorksheetTemplate(
        id: 'length',
        name: 'Length',
        ordering: WorksheetOrdering.magnitude,
        rows: [
          WorksheetRow(label: 'meters', expression: 'm', kind: UnitRow()),
        ],
      );
      expect(template.banner, isNull);
    });

    test('banner is exposed when provided', () {
      const template = WorksheetTemplate(
        id: 'currency',
        name: 'Currency',
        ordering: WorksheetOrdering.alphabetical,
        banner: CurrencyRatesBanner(),
        rows: [
          WorksheetRow(label: 'US dollar', expression: 'USD', kind: UnitRow()),
        ],
      );
      expect(template.banner, isA<CurrencyRatesBanner>());
    });
  });

  group('WorksheetBanner', () {
    test('CurrencyRatesBanner is a WorksheetBanner', () {
      const banner = CurrencyRatesBanner();
      expect(banner, isA<WorksheetBanner>());
      expect(banner, isA<CurrencyRatesBanner>());
    });

    test('sealed class switch is exhaustive', () {
      const WorksheetBanner banner = CurrencyRatesBanner();
      final result = switch (banner) {
        CurrencyRatesBanner() => 'currency',
      };
      expect(result, 'currency');
    });
  });
}
