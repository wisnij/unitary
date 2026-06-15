import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:unitary/features/currency/state/currency_provider.dart';
import 'package:unitary/features/worksheet/models/worksheet.dart';
import 'package:unitary/features/worksheet/presentation/widgets/worksheet_banner.dart';

class _FixedStatusNotifier extends CurrencyStatusNotifier {
  _FixedStatusNotifier(this._initial);

  final CurrencyStatus _initial;

  @override
  CurrencyStatus build() => _initial;

  /// Test hook to drive a state change as a refresh would.
  void update(CurrencyStatus next) => state = next;
}

void main() {
  Widget buildBanner(CurrencyStatus status, {WorksheetBanner? banner}) {
    return ProviderScope(
      overrides: [
        currencyStatusProvider.overrideWith(() => _FixedStatusNotifier(status)),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: WorksheetBannerWidget(
            banner: banner ?? const CurrencyRatesBanner(),
          ),
        ),
      ),
    );
  }

  group('WorksheetBannerWidget — currency rates', () {
    testWidgets('shows last sync time when rates are available', (
      tester,
    ) async {
      final lastUpdated = DateTime.utc(2026, 6, 6, 10, 30);
      await tester.pumpWidget(
        buildBanner(CurrencyStatus(lastUpdatedAt: lastUpdated)),
      );
      expect(find.textContaining('Jun 6, 2026'), findsOneWidget);
    });

    testWidgets('shows built-in-rates wording when never fetched', (
      tester,
    ) async {
      await tester.pumpWidget(buildBanner(const CurrencyStatus()));
      expect(find.text('Using built-in rates'), findsOneWidget);
    });

    testWidgets('updates when the status provider changes', (tester) async {
      // A notifier whose state can be mutated to simulate a refresh.
      final container = ProviderContainer(
        overrides: [
          currencyStatusProvider.overrideWith(
            () => _FixedStatusNotifier(const CurrencyStatus()),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: WorksheetBannerWidget(banner: CurrencyRatesBanner()),
            ),
          ),
        ),
      );
      expect(find.text('Using built-in rates'), findsOneWidget);

      // Drive a state change as a refresh would.
      final notifier =
          container.read(currencyStatusProvider.notifier)
              as _FixedStatusNotifier;
      notifier.update(
        CurrencyStatus(lastUpdatedAt: DateTime.utc(2026, 6, 7, 9, 0)),
      );
      await tester.pump();

      expect(find.text('Using built-in rates'), findsNothing);
      expect(find.textContaining('Jun 7, 2026'), findsOneWidget);
    });
  });
}
