import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:unitary/features/settings/models/user_settings.dart';
import 'package:unitary/features/settings/presentation/settings_screen.dart';
import 'package:unitary/features/settings/state/settings_provider.dart';
import 'package:unitary/main.dart' as app;

import 'helpers/real_prefs.dart';

/// Simulates an app restart: tears down and reconstructs the entire widget
/// tree and provider graph by calling `app.main()` again, while the real
/// (non-mocked) `SharedPreferences` store underneath is left untouched — the
/// same technique `main.dart` itself uses on a genuine cold launch.
///
/// Re-seeds a fresh currency-rate timestamp first, since `UnitaryApp` fires a
/// background staleness check on every launch and this suite must never
/// contact the real network.
Future<void> restart(WidgetTester tester) async {
  await RealPrefs.seedFreshCurrencyTimestamp();
  await app.main();
  await tester.pumpAndSettle();
  // Replacing a live tree in place subjects the incoming tree — including
  // the offstage pages AppShell keeps alive in its IndexedStack — to a
  // transient degenerate-constraint layout pass that no real cold launch
  // performs (the same artifact that surfaced the FastScrollBar zero-height
  // clamp bug when this suite was built).  Fixed-height layouts can report
  // benign RenderFlex overflows during that pass, so absorb exactly those;
  // any other captured exception still fails the test.
  final exception = tester.takeException();
  if (exception is FlutterError &&
      exception.message.contains('RenderFlex overflowed')) {
    return;
  }
  if (exception != null) {
    throw exception;
  }
}

Future<void> openDrawerAndTap(WidgetTester tester, String tileText) async {
  await tester.tap(find.byIcon(Icons.menu));
  await tester.pumpAndSettle();
  await tester.tap(find.text(tileText));
  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Force compact width (drawer navigation, AppBar history button) so the
  // interaction patterns match the well-covered compact-width widget tests
  // rather than the medium/expanded two-pane layouts.
  void useCompact(WidgetTester tester) {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  group('Restart persistence', () {
    testWidgets(
      'worksheet source value survives a restart',
      (tester) async {
        useCompact(tester);
        await RealPrefs.clear();
        await RealPrefs.seedFreshCurrencyTimestamp();

        await app.main();
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        await openDrawerAndTap(tester, 'Worksheet');
        await tester.tap(find.text('Length'));
        await tester.pumpAndSettle();

        // The "micron" row — the first row of the Length template.
        await tester.enterText(find.byType(TextField).first, '3');
        await tester.pumpAndSettle();

        await restart(tester);
        expect(tester.takeException(), isNull);

        await openDrawerAndTap(tester, 'Worksheet');

        // The active template is restored directly (no template picker),
        // and its source value is restored with it.
        expect(find.text('Length'), findsOneWidget);
        expect(
          tester
              .widget<TextField>(find.byType(TextField).first)
              .controller!
              .text,
          '3',
        );
      },
    );

    testWidgets(
      'a changed setting survives a restart',
      (tester) async {
        useCompact(tester);
        await RealPrefs.clear();
        await RealPrefs.seedFreshCurrencyTimestamp();

        await app.main();
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        await openDrawerAndTap(tester, 'Settings');
        await tester.tap(find.text('Dark mode'));
        await tester.pumpAndSettle();

        // Return to the base app (Settings is a pushed route) before
        // restarting, so the app is on the same tabbed-page footing every
        // other restart scenario restarts from.
        await tester.pageBack();
        await tester.pumpAndSettle();

        await restart(tester);
        expect(tester.takeException(), isNull);

        await openDrawerAndTap(tester, 'Settings');

        final container = ProviderScope.containerOf(
          tester.element(find.byType(SettingsScreen)),
        );
        expect(
          container.read(settingsProvider).themeMode,
          ThemePreference.dark,
        );
      },
    );

    testWidgets(
      'a freeform history entry survives a restart',
      (tester) async {
        useCompact(tester);
        await RealPrefs.clear();
        await RealPrefs.seedFreshCurrencyTimestamp();

        await app.main();
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        await tester.enterText(
          find.widgetWithText(TextField, 'Convert from'),
          '5 miles',
        );
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        await restart(tester);
        expect(tester.takeException(), isNull);

        await tester.tap(find.byIcon(Icons.history));
        await tester.pumpAndSettle();

        // Scope to the history modal's own content: the Convert-from field
        // is a different (real, if surprising) survivor of the app.main()
        // restart technique — see design.md's "restart" Non-Goal — and also
        // matches a broad "5 miles" substring search.
        expect(
          find.descendant(
            of: find.byType(DraggableScrollableSheet),
            matching: find.textContaining('5 miles'),
          ),
          findsOneWidget,
        );
      },
    );
  });
}
