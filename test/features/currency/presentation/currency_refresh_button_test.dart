import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:unitary/features/currency/presentation/currency_refresh_button.dart';
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
  Widget buildButton(CurrencyStatus status) {
    return ProviderScope(
      overrides: [
        currencyStatusProvider.overrideWith(() => _FixedStatusNotifier(status)),
      ],
      child: const MaterialApp(
        home: Scaffold(body: Center(child: CurrencyRefreshButton())),
      ),
    );
  }

  Widget buildButtonWithRefreshResult(String? refreshResult) {
    return ProviderScope(
      overrides: [
        currencyStatusProvider.overrideWith(
          () => _RefreshResultNotifier(refreshResult: refreshResult),
        ),
      ],
      child: const MaterialApp(
        home: Scaffold(body: Center(child: CurrencyRefreshButton())),
      ),
    );
  }

  group('CurrencyRefreshButton — states', () {
    testWidgets('shows refresh icon when idle', (tester) async {
      await tester.pumpWidget(buildButton(const CurrencyStatus()));
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('shows spinner and hides refresh icon while fetching', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildButton(const CurrencyStatus(isFetching: true)),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsNothing);
    });

    testWidgets(
      'during cooldown shows a disabled, grayed refresh icon with a wait label',
      (tester) async {
        final expiry = DateTime.now().toUtc().add(const Duration(seconds: 45));
        await tester.pumpWidget(
          buildButton(CurrencyStatus(cooldownExpiry: expiry)),
        );

        // The refresh icon is still shown (purpose indicator) alongside the
        // countdown label.
        expect(find.byIcon(Icons.refresh), findsOneWidget);
        expect(find.textContaining('Wait'), findsOneWidget);

        // The control is disabled (grayed out).
        final button = tester.widget<TextButton>(find.byType(TextButton));
        expect(button.onPressed, isNull);

        // Dispose the ticking widget so its periodic timer is cancelled.
        await tester.pumpWidget(const SizedBox());
      },
    );

    testWidgets('shows refresh icon once cooldown has expired', (tester) async {
      final past = DateTime.now().toUtc().subtract(const Duration(seconds: 5));
      await tester.pumpWidget(
        buildButton(CurrencyStatus(cooldownExpiry: past)),
      );
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });
  });

  group('CurrencyRefreshButton — refresh error dialog', () {
    testWidgets('no dialog when refresh succeeds (returns null)', (
      tester,
    ) async {
      await tester.pumpWidget(buildButtonWithRefreshResult(null));
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('shows AlertDialog when refresh returns an error', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildButtonWithRefreshResult('Exception: connection refused'),
      );
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Error during rate update'), findsOneWidget);
    });

    testWidgets('error detail is hidden until Details is expanded', (
      tester,
    ) async {
      const errorMsg = 'Exception: connection refused';
      await tester.pumpWidget(buildButtonWithRefreshResult(errorMsg));
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();
      expect(find.text(errorMsg), findsNothing);

      await tester.tap(find.text('Details'));
      await tester.pumpAndSettle();
      expect(find.text(errorMsg), findsOneWidget);
    });

    testWidgets('dialog is dismissed by OK button', (tester) async {
      await tester.pumpWidget(
        buildButtonWithRefreshResult('Exception: connection refused'),
      );
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
    });
  });
}
