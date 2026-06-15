import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unitary/core/domain/models/currency_descriptor.dart';
import 'package:unitary/core/domain/models/unit.dart';
import 'package:unitary/features/currency/data/currency_rate_repository.dart';

// Minimal compiled unit stubs used by descriptor tests.
const _euro = DerivedUnit(id: 'euro', aliases: ['EUR'], expression: '1 US\$');
const _goldounce = DerivedUnit(
  id: 'goldounce',
  aliases: ['XAU'],
  expression: 'goldprice troyounce',
);
const _goldprice = DerivedUnit(
  id: 'goldprice',
  expression: '4616.49 US\$/troyounce',
);
const _meter = PrimitiveUnit(id: 'meter');

const _eurDescriptor = CurrencyDescriptor(
  isoCode: 'EUR',
  unitId: 'euro',
  expressionTemplate: '1|{rate} US\$',
  originalUnit: _euro,
);

// Matches the real shape produced by `_buildCurrencyDescriptors()`: the
// metal descriptor's `originalUnit` is the intermediate `goldprice` unit,
// not the `goldounce` unit itself.
const _xauDescriptor = CurrencyDescriptor(
  isoCode: 'XAU',
  unitId: 'goldprice',
  expressionTemplate: '1|{rate} US\$/troyounce',
  originalUnit: _goldprice,
);

const _descriptors = [_eurDescriptor, _xauDescriptor];

CurrencyRates _makeRates({
  DateTime? updatedAt,
  Map<String, CurrencyRateEntry>? rates,
}) {
  return CurrencyRates(
    updatedAt: updatedAt ?? DateTime.utc(2026, 6, 6, 12),
    rates:
        rates ??
        {
          'euro': const CurrencyRateEntry(rate: 1.09, date: '2026-06-06'),
          'goldprice': const CurrencyRateEntry(
            rate: 3312.5,
            date: '2026-06-05',
          ),
        },
  );
}

void main() {
  late CurrencyRateRepository repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    repo = CurrencyRateRepository(prefs);
  });

  group('CurrencyRateRepository.load', () {
    test('returns null when nothing has been saved', () {
      expect(repo.load(), isNull);
    });

    test('returns null for malformed JSON', () async {
      SharedPreferences.setMockInitialValues({'currencyRates': 'not-json{'});
      final prefs = await SharedPreferences.getInstance();
      final r = CurrencyRateRepository(prefs);
      expect(r.load(), isNull);
    });
  });

  group('CurrencyRateRepository.save / load round-trip', () {
    test('restores updatedAt timestamp', () async {
      final ts = DateTime.utc(2026, 6, 6, 14, 30);
      await repo.save(_makeRates(updatedAt: ts));
      expect(repo.load()!.updatedAt, ts);
    });

    test('restores all rate entries', () async {
      await repo.save(_makeRates());
      final loaded = repo.load()!;
      expect(loaded.rates['euro']!.rate, closeTo(1.09, 1e-9));
      expect(loaded.rates['euro']!.date, '2026-06-06');
      expect(loaded.rates['goldprice']!.rate, closeTo(3312.5, 1e-9));
      expect(loaded.rates['goldprice']!.date, '2026-06-05');
    });

    test('second save replaces first', () async {
      await repo.save(
        _makeRates(
          rates: {
            'euro': const CurrencyRateEntry(rate: 1.09, date: '2026-06-06'),
          },
        ),
      );
      await repo.save(
        _makeRates(
          rates: {
            'euro': const CurrencyRateEntry(rate: 1.10, date: '2026-06-07'),
          },
        ),
      );
      expect(repo.load()!.rates['euro']!.rate, closeTo(1.10, 1e-9));
    });
  });

  group('CurrencyRateRepository.descriptorForUnit', () {
    test('matches a standard currency via originalUnit.id', () {
      expect(
        CurrencyRateRepository.descriptorForUnit(_euro, _descriptors),
        _eurDescriptor,
      );
    });

    test('matches a precious metal price unit via originalUnit.id', () {
      expect(
        CurrencyRateRepository.descriptorForUnit(_goldprice, _descriptors),
        _xauDescriptor,
      );
    });

    test('matches a precious metal ounce unit via ISO-code alias', () {
      expect(
        CurrencyRateRepository.descriptorForUnit(_goldounce, _descriptors),
        _xauDescriptor,
      );
    });

    test('returns null for a non-currency unit', () {
      expect(
        CurrencyRateRepository.descriptorForUnit(_meter, _descriptors),
        isNull,
      );
    });
  });

  group('CurrencyRateRepository.lastUpdatedForUnit', () {
    setUp(() async {
      await repo.save(_makeRates());
    });

    test('direct lookup for a standard currency', () {
      expect(repo.lastUpdatedForUnit(_euro, _descriptors), '2026-06-06');
    });

    test('direct lookup for a precious metal price unit', () {
      expect(repo.lastUpdatedForUnit(_goldprice, _descriptors), '2026-06-05');
    });

    test('indirect lookup for a precious metal ounce unit', () {
      // goldounce is not a direct key; resolves via XAU descriptor's alias
      expect(repo.lastUpdatedForUnit(_goldounce, _descriptors), '2026-06-05');
    });

    test('returns null for a non-currency unit', () {
      expect(repo.lastUpdatedForUnit(_meter, _descriptors), isNull);
    });

    test('returns null when no rates have been saved', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final fresh = CurrencyRateRepository(prefs);
      expect(fresh.lastUpdatedForUnit(_euro, _descriptors), isNull);
    });
  });
}
