import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:unitary/features/currency/data/currency_rate_repository.dart';
import 'package:unitary/features/freeform/presentation/freeform_screen.dart';
import 'package:unitary/main.dart' as app;

import 'helpers/real_prefs.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App boot', () {
    testWidgets('boots to the Freeform screen with no provider errors', (
      tester,
    ) async {
      await RealPrefs.clear();
      // Avoid a real network call: the app fires a background staleness
      // check on every launch, and this seeds a fresh timestamp so it
      // short-circuits.
      await RealPrefs.seedFreshCurrencyTimestamp();

      app.main();
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(FreeformScreen), findsOneWidget);
    });

    testWidgets(
      'applies a stored currency rate to the unit repository before the '
      'first frame',
      (tester) async {
        await RealPrefs.clear();
        // A deliberately unrealistic rate (real EUR/USD rates are never
        // anywhere near 2.0) so the assertion can't accidentally pass
        // against the compiled-in built-in rate.
        await RealPrefs.seedFreshCurrencyTimestamp(
          rates: {
            'euro': const CurrencyRateEntry(rate: 2.0, date: '2026-01-01'),
          },
        );

        app.main();
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        await tester.enterText(
          find.widgetWithText(TextField, 'Convert from'),
          '1 euro',
        );
        await tester.enterText(
          find.widgetWithText(TextField, 'Convert to (optional)'),
          'USD',
        );
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        // DELIBERATE FAILURE (task 5.3): confirming CI actually fails the
        // workflow on a real integration-test failure. Revert this line
        // once observed.
        expect(find.textContaining('= 999'), findsOneWidget);
      },
    );
  });
}
