import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:unitary/features/currency/presentation/currency_refresh_button.dart';
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

/// Notifier whose [refresh] enters the 60-second cooldown, mimicking the real
/// notifier's effect on shared state without performing a network fetch.
class _CooldownOnRefreshNotifier extends CurrencyStatusNotifier {
  @override
  CurrencyStatus build() => const CurrencyStatus();

  @override
  Future<String?> refresh() async {
    state = CurrencyStatus(
      cooldownExpiry: DateTime.now().toUtc().add(const Duration(seconds: 60)),
    );
    return null;
  }
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

    // Note: the per-second tick-down of the "Wait Ns" label is not asserted
    // here.  The remaining seconds come from CurrencyStatus.cooldownSecondsRemaining,
    // which is derived from the real wall clock (DateTime.now()).  Widget tests
    // run under fake-async — tester.pump(duration) advances the fake clock and
    // fires the widget's periodic timer, but it does not move DateTime.now(), so
    // the displayed value would not change deterministically between pumps.  The
    // static cooldown rendering (below) and the wall-clock-based re-enable once
    // the cooldown has elapsed ("shows refresh icon once cooldown has expired")
    // are covered instead; the live countdown is verified manually on device.
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

  group('CurrencyRefreshButton — shared cooldown across locations', () {
    // Two controls sharing one currencyStatusProvider stand in for the Settings
    // section and the worksheet AppBar.  Triggering a refresh from one must put
    // the other into the cooldown state too, since they read the same state.
    testWidgets('refreshing from one location disables the other', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currencyStatusProvider.overrideWith(_CooldownOnRefreshNotifier.new),
          ],
          child: const MaterialApp(
            home: Scaffold(
              // CurrencySettingsSection renders its own CurrencyRefreshButton
              // (the "Settings" location); the standalone button stands in for
              // the worksheet AppBar location.
              body: Column(
                children: [
                  CurrencySettingsSection(),
                  CurrencyRefreshButton(),
                ],
              ),
            ),
          ),
        ),
      );

      // Both locations start idle: two enabled refresh icons, no wait labels.
      expect(find.byIcon(Icons.refresh), findsNWidgets(2));
      expect(find.textContaining('Wait'), findsNothing);

      // Trigger a refresh from one location.
      await tester.tap(find.byIcon(Icons.refresh).first);
      await tester.pump();

      // Both controls are now in cooldown (disabled wait buttons).
      expect(find.textContaining('Wait'), findsNWidgets(2));
      expect(find.byType(IconButton), findsNothing);

      // Dispose the ticking widgets so their periodic timers are cancelled.
      await tester.pumpWidget(const SizedBox());
    });
  });
}
