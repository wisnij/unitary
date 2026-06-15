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

class _RefreshResultNotifier extends CurrencyStatusNotifier {
  _RefreshResultNotifier({required this.refreshResult});

  final String? refreshResult;

  @override
  CurrencyStatus build() => const CurrencyStatus();

  @override
  Future<String?> refresh() async => refreshResult;
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

  Widget buildAppWithRefreshResult(String? refreshResult) {
    return ProviderScope(
      overrides: [
        currencyStatusProvider.overrideWith(
          () => _RefreshResultNotifier(refreshResult: refreshResult),
        ),
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

    testWidgets(
      'shows a grayed refresh icon with a wait label during cooldown',
      (
        tester,
      ) async {
        final expiry = DateTime.now().toUtc().add(const Duration(seconds: 45));
        await tester.pumpWidget(
          buildApp(CurrencyStatus(cooldownExpiry: expiry)),
        );
        expect(find.textContaining('Wait'), findsOneWidget);
        // The refresh icon remains visible (grayed) to indicate purpose.
        expect(find.byIcon(Icons.refresh), findsOneWidget);

        // Dispose the ticking widget so its periodic timer is cancelled.
        await tester.pumpWidget(const SizedBox());
      },
    );

    testWidgets('shows refresh icon once cooldown has expired', (tester) async {
      final past = DateTime.now().toUtc().subtract(const Duration(seconds: 5));
      await tester.pumpWidget(buildApp(CurrencyStatus(cooldownExpiry: past)));
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });
  });

  group('CurrencySettingsSection — refresh error dialog', () {
    testWidgets('no dialog when refresh succeeds (returns null)', (
      tester,
    ) async {
      await tester.pumpWidget(buildAppWithRefreshResult(null));
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('shows AlertDialog when refresh returns an error', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildAppWithRefreshResult('Exception: connection refused'),
      );
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('dialog title says rates could not be updated', (tester) async {
      await tester.pumpWidget(
        buildAppWithRefreshResult('Exception: connection refused'),
      );
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();
      expect(find.text('Error during rate update'), findsOneWidget);
    });

    testWidgets('error detail is hidden inside collapsed ExpansionTile', (
      tester,
    ) async {
      const errorMsg = 'Exception: connection refused';
      await tester.pumpWidget(buildAppWithRefreshResult(errorMsg));
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();
      // The error text should not be visible until the details section is expanded.
      expect(find.text(errorMsg), findsNothing);
    });

    testWidgets('error detail becomes visible after expanding Details', (
      tester,
    ) async {
      const errorMsg = 'Exception: connection refused';
      await tester.pumpWidget(buildAppWithRefreshResult(errorMsg));
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Details'));
      await tester.pumpAndSettle();
      expect(find.text(errorMsg), findsOneWidget);
    });

    testWidgets('dialog is dismissed by OK button', (tester) async {
      await tester.pumpWidget(
        buildAppWithRefreshResult('Exception: connection refused'),
      );
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
    });
  });
}
