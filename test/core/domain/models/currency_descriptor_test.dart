import 'package:flutter_test/flutter_test.dart';
import 'package:unitary/core/domain/models/currency_descriptor.dart';
import 'package:unitary/core/domain/models/unit_repository.dart';

void main() {
  late UnitRepository repo;

  setUpAll(() {
    repo = UnitRepository.withPredefinedUnits();
  });

  group('buildCurrencyDescriptors', () {
    late List<CurrencyDescriptor> descriptors;

    setUpAll(() {
      descriptors = repo.buildCurrencyDescriptors();
    });

    test('returns a non-empty list', () {
      expect(descriptors, isNotEmpty);
    });

    test('EUR maps to euro with standard template', () {
      final d = descriptors.firstWhere((d) => d.isoCode == 'EUR');
      expect(d.unitId, 'euro');
      expect(d.expressionTemplate, '{rate} US\$');
    });

    test('GBP maps to ukpound with standard template', () {
      final d = descriptors.firstWhere((d) => d.isoCode == 'GBP');
      expect(d.unitId, 'ukpound');
      expect(d.expressionTemplate, '{rate} US\$');
    });

    test('JPY maps to japanyen with standard template', () {
      final d = descriptors.firstWhere((d) => d.isoCode == 'JPY');
      expect(d.unitId, 'japanyen');
      expect(d.expressionTemplate, '{rate} US\$');
    });

    test('XAU maps to goldprice with troyounce template', () {
      final d = descriptors.firstWhere((d) => d.isoCode == 'XAU');
      expect(d.unitId, 'goldprice');
      expect(d.expressionTemplate, '{rate} US\$/troyounce');
    });

    test('XAG maps to silverprice with troyounce template', () {
      final d = descriptors.firstWhere((d) => d.isoCode == 'XAG');
      expect(d.unitId, 'silverprice');
      expect(d.expressionTemplate, '{rate} US\$/troyounce');
    });

    test('XPT maps to platinumprice with troyounce template', () {
      final d = descriptors.firstWhere((d) => d.isoCode == 'XPT');
      expect(d.unitId, 'platinumprice');
      expect(d.expressionTemplate, '{rate} US\$/troyounce');
    });

    test('USD is excluded (it is the base currency)', () {
      expect(descriptors.any((d) => d.isoCode == 'USD'), isFalse);
    });

    test('RSI is excluded (thermal resistance, not currency)', () {
      expect(descriptors.any((d) => d.isoCode == 'RSI'), isFalse);
    });

    test('FIT is excluded (failure rate, not currency)', () {
      expect(descriptors.any((d) => d.isoCode == 'FIT'), isFalse);
    });

    test('MCM is excluded (circular mils, not currency)', () {
      expect(descriptors.any((d) => d.isoCode == 'MCM'), isFalse);
    });

    test('originalUnit is populated', () {
      final d = descriptors.firstWhere((d) => d.isoCode == 'EUR');
      expect(d.originalUnit, isNotNull);
    });

    test('result is cached: second call returns identical list', () {
      final second = repo.buildCurrencyDescriptors();
      expect(identical(descriptors, second), isTrue);
    });

    test(
      'all descriptors have non-empty isoCode, unitId, and expressionTemplate',
      () {
        for (final d in descriptors) {
          expect(
            d.isoCode,
            isNotEmpty,
            reason: 'isoCode empty for ${d.unitId}',
          );
          expect(d.unitId, isNotEmpty, reason: 'unitId empty for ${d.isoCode}');
          expect(
            d.expressionTemplate,
            isNotEmpty,
            reason: 'template empty for ${d.isoCode}',
          );
        }
      },
    );
  });
}
