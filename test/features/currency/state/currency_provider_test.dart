import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:unitary/core/domain/models/unit_repository.dart';
import 'package:unitary/core/domain/models/unit_repository_provider.dart';
import 'package:unitary/features/currency/data/currency_rate_repository.dart';
import 'package:unitary/features/currency/domain/currency_service.dart';
import 'package:unitary/features/currency/state/currency_provider.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Map<String, dynamic> _row(String quote, double rate, String date) => {
  'base': 'USD',
  'quote': quote,
  'rate': rate,
  'date': date,
};

/// Creates a [ProviderContainer] with [unitRepositoryProvider] and
/// [currencyRateRepositoryProvider] wired to fresh instances, and
/// [currencyServiceProvider] wired to [client].  Registers teardown.
Future<ProviderContainer> _makeContainer(
  http.Client client, {
  CurrencyRates? storedRates,
}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final unitRepo = UnitRepository.withPredefinedUnits();
  final rateRepo = CurrencyRateRepository(prefs);

  if (storedRates != null) {
    await rateRepo.save(storedRates);
  }

  final container = ProviderContainer(
    overrides: [
      unitRepositoryProvider.overrideWithValue(unitRepo),
      currencyRateRepositoryProvider.overrideWithValue(rateRepo),
      currencyServiceProvider.overrideWith(
        (ref) => CurrencyService(
          repo: ref.watch(unitRepositoryProvider),
          rateRepo: ref.watch(currencyRateRepositoryProvider),
          client: client,
        ),
      ),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

http.Client _emptyClient() => MockClient((_) async => http.Response('[]', 200));

http.Client _eurClient() => MockClient(
  (_) async =>
      http.Response(jsonEncode([_row('EUR', 0.86, '2026-06-06')]), 200),
);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('CurrencyStatusNotifier.maybeRefresh', () {
    test('does not fetch when stored rates are fresh (< 24h)', () async {
      var fetchCount = 0;
      final client = MockClient((_) async {
        fetchCount++;
        return http.Response('[]', 200);
      });

      final freshRates = CurrencyRates(
        updatedAt: DateTime.now().toUtc().subtract(const Duration(hours: 1)),
        rates: {},
      );
      final container = await _makeContainer(client, storedRates: freshRates);

      container.read(currencyStatusProvider.notifier).maybeRefresh();
      await Future<void>.delayed(Duration.zero);

      expect(fetchCount, 0);
    });

    test('fetches when stored rates are stale (>= 24h)', () async {
      var fetchCount = 0;
      final client = MockClient((_) async {
        fetchCount++;
        return http.Response('[]', 200);
      });

      final staleRates = CurrencyRates(
        updatedAt: DateTime.now().toUtc().subtract(const Duration(hours: 25)),
        rates: {},
      );
      final container = await _makeContainer(client, storedRates: staleRates);

      container.read(currencyStatusProvider.notifier).maybeRefresh();
      await Future<void>.delayed(Duration.zero);

      expect(fetchCount, 1);
    });

    test('fetches when no rates are stored', () async {
      var fetchCount = 0;
      final client = MockClient((_) async {
        fetchCount++;
        return http.Response('[]', 200);
      });

      final container = await _makeContainer(client);

      container.read(currencyStatusProvider.notifier).maybeRefresh();
      await Future<void>.delayed(Duration.zero);

      expect(fetchCount, 1);
    });

    test(
      'increments unitRepositoryVersionProvider after a stale fetch',
      () async {
        final container = await _makeContainer(_eurClient());
        final versionBefore = container.read(unitRepositoryVersionProvider);

        container.read(currencyStatusProvider.notifier).maybeRefresh();
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(
          container.read(unitRepositoryVersionProvider),
          greaterThan(versionBefore),
        );
      },
    );

    test('updates lastUpdatedAt in state after a successful fetch', () async {
      final container = await _makeContainer(_emptyClient());
      expect(container.read(currencyStatusProvider).lastUpdatedAt, isNull);

      container.read(currencyStatusProvider.notifier).maybeRefresh();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(
        container.read(currencyStatusProvider).lastUpdatedAt,
        isNotNull,
      );
    });
  });

  group('CurrencyStatusNotifier.refresh', () {
    test(
      'increments unitRepositoryVersionProvider after a successful fetch',
      () async {
        final container = await _makeContainer(_eurClient());
        final versionBefore = container.read(unitRepositoryVersionProvider);

        await container.read(currencyStatusProvider.notifier).refresh();

        expect(
          container.read(unitRepositoryVersionProvider),
          greaterThan(versionBefore),
        );
      },
    );

    test('does not increment version when fetch fails', () async {
      final failClient = MockClient(
        (_) async => throw Exception('network error'),
      );
      final container = await _makeContainer(failClient);
      final versionBefore = container.read(unitRepositoryVersionProvider);

      await container.read(currencyStatusProvider.notifier).refresh();

      expect(container.read(unitRepositoryVersionProvider), versionBefore);
    });

    test('returns null when fetch succeeds', () async {
      final container = await _makeContainer(_eurClient());
      final result = await container
          .read(currencyStatusProvider.notifier)
          .refresh();
      expect(result, isNull);
    });

    test('returns error string when network fails', () async {
      final failClient = MockClient(
        (_) async => throw Exception('connection refused'),
      );
      final container = await _makeContainer(failClient);
      final result = await container
          .read(currencyStatusProvider.notifier)
          .refresh();
      expect(result, isNotNull);
      expect(result, isNotEmpty);
    });

    test('returns error string when server returns error status', () async {
      final errorClient = MockClient(
        (_) async => http.Response('', 503),
      );
      final container = await _makeContainer(errorClient);
      final result = await container
          .read(currencyStatusProvider.notifier)
          .refresh();
      expect(result, isNotNull);
      expect(result, contains('503'));
    });
  });
}
