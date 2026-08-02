import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:integration_test/integration_test.dart';

import 'package:unitary/core/domain/models/unit_repository_provider.dart';
import 'package:unitary/features/currency/domain/currency_service.dart';
import 'package:unitary/features/currency/presentation/currency_refresh_button.dart';
import 'package:unitary/features/currency/state/currency_provider.dart';
import 'package:unitary/features/worksheet/presentation/worksheet_screen.dart';
import 'package:unitary/features/worksheet/state/worksheet_provider.dart';

import '../test/helpers/pump_app.dart';
import '../test/helpers/repository_overrides.dart';

// Row order in the "currency" template (predefined_worksheets.dart): the
// Euro row is index 4, United States dollar is the last row (index 11).
const _euroRowIndex = 4;
const _usdRowIndex = 11;

Map<String, dynamic> _row(String quote, double rate, String date) => {
  'base': 'USD',
  'quote': quote,
  'rate': rate,
  'date': date,
};

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late TestRepositories repos;

  setUp(() async {
    repos = await TestRepositories.create();
  });

  Future<void> pumpCurrencyWorksheet(
    WidgetTester tester,
    http.Client client,
  ) async {
    await pumpApp(
      tester,
      WorksheetScreen(onNavigate: (_) {}),
      repos: repos,
      overrides: [
        currencyServiceProvider.overrideWith(
          (ref) => CurrencyService(
            repo: ref.watch(unitRepositoryProvider),
            rateRepo: ref.watch(currencyRateRepositoryProvider),
            client: client,
          ),
        ),
      ],
    );
    final container = ProviderScope.containerOf(
      tester.element(find.byType(WorksheetScreen)),
    );
    container.read(worksheetProvider.notifier).selectWorksheet('currency');
    await tester.pumpAndSettle();
  }

  group('Currency refresh flow', () {
    testWidgets(
      'successful mocked refresh updates status and a conversion',
      (tester) async {
        final client = MockClient(
          (_) async =>
              http.Response(jsonEncode([_row('EUR', 2.0, '2026-01-01')]), 200),
        );
        await pumpCurrencyWorksheet(tester, client);

        // Enter a source value in USD before refreshing, so the Euro row has
        // something to recompute once the rate changes.
        await tester.enterText(
          find.byType(TextField).at(_usdRowIndex),
          '1',
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byType(CurrencyRefreshButton));
        await tester.pumpAndSettle();

        // 1 USD at a seeded rate of 2.0 (EUR per USD) is 2 EUR.
        expect(
          tester
              .widget<TextField>(find.byType(TextField).at(_euroRowIndex))
              .controller!
              .text,
          '2',
        );
      },
    );

    testWidgets(
      'failed mocked refresh (non-200) surfaces an error, rates unchanged',
      (tester) async {
        final client = MockClient(
          (_) async => http.Response('Service Unavailable', 503),
        );
        await pumpCurrencyWorksheet(tester, client);

        expect(repos.currencyRate.load(), isNull);

        await tester.tap(find.byType(CurrencyRefreshButton));
        await tester.pumpAndSettle();

        expect(find.text('Error during rate update'), findsOneWidget);
        expect(repos.currencyRate.load(), isNull);
      },
    );

    testWidgets(
      'failed mocked refresh (thrown exception) surfaces an error, rates unchanged',
      (tester) async {
        final client = MockClient((_) async => throw Exception('offline'));
        await pumpCurrencyWorksheet(tester, client);

        expect(repos.currencyRate.load(), isNull);

        await tester.tap(find.byType(CurrencyRefreshButton));
        await tester.pumpAndSettle();

        expect(find.text('Error during rate update'), findsOneWidget);
        expect(repos.currencyRate.load(), isNull);
      },
    );
  });
}
