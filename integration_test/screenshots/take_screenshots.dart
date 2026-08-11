// Captures README screenshots of the major interface pages.
//
// Not part of the regular integration-test suite (tool/run_integration_tests.sh
// and CI glob `integration_test/*.dart`, which does not match this
// subdirectory).  Run via the wrapper script, which boots the emulator, runs
// this test through `flutter drive`, and downscales the captured PNGs to the
// sizes the README embeds them at:
//
//   tool/take_screenshots.sh
//
// Screenshots are written to doc/screenshots/ by the driver
// (test_driver/screenshots_driver.dart) at the device's native resolution.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:unitary/features/browser/presentation/browser_screen.dart';
import 'package:unitary/features/worksheet/presentation/worksheet_screen.dart';
import 'package:unitary/main.dart' as app;

import '../helpers/real_prefs.dart';

Future<void> _openDrawerPage(WidgetTester tester, String title) async {
  await tester.tap(find.byTooltip('Open navigation menu'));
  await tester.pumpAndSettle();
  await tester.tap(find.text(title).last);
  await tester.pumpAndSettle();
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture screenshots of major pages', (tester) async {
    await binding.convertFlutterSurfaceToImage();

    // The integration-test binding does not install the synthetic test
    // keyboard by default, so without this, enterText() sends editing state
    // into the void while focus pops the device's real IME (which then
    // leaves a stale viewport inset in the captures).  Registering the test
    // input intercepts the platform channel: text lands in the fields and
    // the real keyboard never appears.
    tester.testTextInput.register();

    await RealPrefs.clear();
    await RealPrefs.seedFreshCurrencyTimestamp();

    await app.main();
    await tester.pumpAndSettle();

    // All top-level pages stay alive in AppShell's IndexedStack, so finders
    // for repeated widget types must be scoped to the page being captured.
    final worksheetFields = find.descendant(
      of: find.byType(WorksheetScreen),
      matching: find.byType(TextField),
    );

    // -- Freeform: enter an example conversion and let it evaluate.
    await tester.enterText(
      find.widgetWithText(TextField, 'Convert from'),
      '5 ft + 3 in',
    );
    await tester.pump();
    await tester.enterText(
      find.widgetWithText(TextField, 'Convert to (optional)'),
      'cm',
    );
    // Real-time evaluation debounce is 500 ms.
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();
    // Dismiss the completion overlay (typing "cm" opens it over the result).
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await binding.takeScreenshot('freeform');

    // -- Worksheet: pick the Length template and enter a source value into
    // the meter row (index 6: micron, mm, cm, inch, foot, yard, meter, ...).
    await _openDrawerPage(tester, 'Worksheet');
    await tester.tap(find.text('Length'));
    await tester.pumpAndSettle();
    await tester.enterText(worksheetFields.at(6), '100');
    await tester.pumpAndSettle();
    await binding.takeScreenshot('worksheet');

    // -- Currency worksheet: switch template via the AppBar dropdown.
    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Currency').last);
    await tester.pumpAndSettle();
    await tester.enterText(worksheetFields.first, '100');
    await tester.pumpAndSettle();
    await binding.takeScreenshot('currency');

    // -- Browse: expand a single group partway down the list ("Area" is the
    // seventh alphabetically), so the capture shows collapsed headers above
    // an expanded one.
    await _openDrawerPage(tester, 'Browse');
    await tester.tap(find.textContaining('Area ('));
    await tester.pumpAndSettle();
    await binding.takeScreenshot('browser');

    // -- Unit detail: search for a well-known unit and open its detail page.
    // The search-result tap is scoped to a ListTile because the search
    // field's own text also matches find.text('hbar').
    await tester.tap(find.byTooltip('Search'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.descendant(
        of: find.byType(BrowserScreen),
        matching: find.byType(TextField),
      ),
      'hbar',
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find
          .descendant(of: find.byType(ListTile), matching: find.text('hbar'))
          .first,
    );
    await tester.pumpAndSettle();
    await binding.takeScreenshot('unit-detail');
    await tester.pageBack();
    await tester.pumpAndSettle();

    // -- Settings: once in the emulator's dark system theme, then again
    // after switching the app to light mode.
    await _openDrawerPage(tester, 'Settings');
    await binding.takeScreenshot('settings-dark');
    await tester.tap(find.text('Light mode'));
    await tester.pumpAndSettle();
    await binding.takeScreenshot('settings-light');
  });
}
