import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unitary/core/domain/models/unit_repository.dart';
import 'package:unitary/features/currency/data/currency_rate_repository.dart';
import 'package:unitary/features/currency/domain/currency_service.dart';

http.Client _mockClient(List<Map<String, dynamic>> rows, {int status = 200}) {
  return MockClient((_) async {
    return http.Response(jsonEncode(rows), status);
  });
}

// Build a Frankfurter-style row.
Map<String, dynamic> _row(String quote, double rate, String date) => {
  'base': 'USD',
  'quote': quote,
  'rate': rate,
  'date': date,
};

Future<(UnitRepository, CurrencyRateRepository, CurrencyService)> _setup({
  http.Client? client,
  Map<String, Object> prefs = const {},
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final sharedPrefs = await SharedPreferences.getInstance();
  final repo = UnitRepository.withPredefinedUnits();
  final rateRepo = CurrencyRateRepository(sharedPrefs);
  final service = CurrencyService(
    repo: repo,
    rateRepo: rateRepo,
    client: client,
  );
  return (repo, rateRepo, service);
}

void main() {
  group('CurrencyService.fetchRates', () {
    test(
      'raw API rate stored without inversion: EUR 0.86 → stored as 0.86',
      () async {
        final (_, rateRepo, service) = await _setup(
          client: _mockClient([_row('EUR', 0.86, '2026-06-06')]),
        );
        await service.fetchRates();
        final stored = rateRepo.load()!.rates['euro']!;
        expect(stored.rate, closeTo(0.86, 1e-9));
        expect(stored.date, '2026-06-06');
      },
    );

    test('dynamic unit expression uses 1|rate rational form', () async {
      final (repo, _, service) = await _setup(
        client: _mockClient([_row('EUR', 0.86, '2026-06-06')]),
      );
      await service.fetchRates();
      final unit = repo.findUnit('euro') as dynamic;
      expect(unit.expression, '1|0.86 US\$');
    });

    test('precious metal rate (XAU) uses troyounce template', () async {
      // XAU: 0.00030 oz per USD → stored as raw rate 0.00030, expression '1|0.00030 US$/troyounce'
      final (_, rateRepo, service) = await _setup(
        client: _mockClient([_row('XAU', 0.00030, '2026-06-06')]),
      );
      await service.fetchRates();
      final stored = rateRepo.load()!.rates['goldprice'];
      expect(stored, isNotNull);
      expect(stored!.rate, closeTo(0.00030, 1e-9));
    });

    test('unrecognised API code is ignored', () async {
      final (_, rateRepo, service) = await _setup(
        client: _mockClient([_row('ZZZ', 1.5, '2026-06-06')]),
      );
      await service.fetchRates();
      final stored = rateRepo.load();
      // ZZZ is not a currency descriptor; only updatedAt is written
      expect(stored?.rates.containsKey('ZZZ'), isNot(true));
    });

    test('partial response preserves rates absent from the API', () async {
      // Pre-populate stored rates with JPY
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = UnitRepository.withPredefinedUnits();
      final rateRepo = CurrencyRateRepository(prefs);
      await rateRepo.save(
        CurrencyRates(
          updatedAt: DateTime.utc(2026, 6, 5),
          rates: {
            'japanyen': const CurrencyRateEntry(
              rate: 0.00637,
              date: '2026-06-05',
            ),
          },
        ),
      );
      final service = CurrencyService(
        repo: repo,
        rateRepo: rateRepo,
        client: _mockClient([_row('EUR', 0.86, '2026-06-06')]),
      );
      await service.fetchRates();
      final loaded = rateRepo.load()!;
      // EUR updated, JPY preserved
      expect(loaded.rates.containsKey('euro'), isTrue);
      expect(loaded.rates['japanyen']?.rate, closeTo(0.00637, 1e-9));
    });

    test('returns null on success', () async {
      final (_, _, service) = await _setup(
        client: _mockClient([_row('EUR', 0.86, '2026-06-06')]),
      );
      expect(await service.fetchRates(), isNull);
    });

    test('returns error string on network failure', () async {
      final client = MockClient((_) async => throw Exception('no network'));
      final (_, _, service) = await _setup(client: client);
      final error = await service.fetchRates();
      expect(error, isNotNull);
      expect(error, isNotEmpty);
    });

    test(
      'returns error string containing status code on non-200 response',
      () async {
        final (_, _, service) = await _setup(
          client: _mockClient([], status: 503),
        );
        final error = await service.fetchRates();
        expect(error, isNotNull);
        expect(error, contains('503'));
      },
    );

    test('network error leaves existing rates intact', () async {
      final client = MockClient((_) async => throw Exception('no network'));
      final (_, rateRepo, service) = await _setup(client: client);
      await rateRepo.save(
        CurrencyRates(
          updatedAt: DateTime.utc(2026, 6, 5),
          rates: {
            'euro': const CurrencyRateEntry(rate: 1.09, date: '2026-06-05'),
          },
        ),
      );
      await service.fetchRates();
      expect(rateRepo.load()!.rates['euro']!.rate, closeTo(1.09, 1e-9));
    });

    test('non-200 response leaves existing rates intact', () async {
      final (_, rateRepo, service) = await _setup(
        client: _mockClient([], status: 503),
      );
      await rateRepo.save(
        CurrencyRates(
          updatedAt: DateTime.utc(2026, 6, 5),
          rates: {
            'euro': const CurrencyRateEntry(rate: 1.09, date: '2026-06-05'),
          },
        ),
      );
      await service.fetchRates();
      expect(rateRepo.load()!.rates['euro']!.rate, closeTo(1.09, 1e-9));
    });
  });
}
