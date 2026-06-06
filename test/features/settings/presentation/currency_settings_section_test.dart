import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:unitary/features/currency/presentation/currency_settings_section.dart';
import 'package:unitary/features/currency/state/currency_provider.dart';

class _FixedStatusNotifier extends CurrencyStatusNotifier {
  _FixedStatusNotifier(this._initial);

  final CurrencyStatus _initial;

  @override
  CurrencyStatus build() => _initial;
}

void main() {
  Widget buildApp(CurrencyStatus status) {
    return ProviderScope(
      overrides: [
        currencyStatusProvider.overrideWith(() => _FixedStatusNotifier(status)),
      ],
      child: const MaterialApp(
        home: Scaffold(body: CurrencySettingsSection()),
      ),
    );
  }

  group('CurrencySettingsSection', () {
    testWidgets('shows "Using built-in rates" when no rates fetched yet', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp(const CurrencyStatus()));
      expect(find.text('Using built-in rates'), findsOneWidget);
    });

    testWidgets('shows last-updated timestamp when rates are available', (
      tester,
    ) async {
      final lastUpdated = DateTime.utc(2026, 6, 6, 10, 30);
      await tester.pumpWidget(
        buildApp(CurrencyStatus(lastUpdatedAt: lastUpdated)),
      );
      expect(find.textContaining('Jun 6, 2026'), findsOneWidget);
    });

    testWidgets('shows refresh icon button when idle', (tester) async {
      await tester.pumpWidget(buildApp(const CurrencyStatus()));
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('shows spinner and hides refresh icon while fetching', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp(const CurrencyStatus(isFetching: true)));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsNothing);
    });

    testWidgets('shows "Wait Xs" and hides refresh icon during cooldown', (
      tester,
    ) async {
      final expiry = DateTime.now().toUtc().add(const Duration(seconds: 45));
      await tester.pumpWidget(buildApp(CurrencyStatus(cooldownExpiry: expiry)));
      expect(find.textContaining('Wait'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsNothing);
    });

    testWidgets('shows refresh icon once cooldown has expired', (tester) async {
      final past = DateTime.now().toUtc().subtract(const Duration(seconds: 5));
      await tester.pumpWidget(buildApp(CurrencyStatus(cooldownExpiry: past)));
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });
  });
}
