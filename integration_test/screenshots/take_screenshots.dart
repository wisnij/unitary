// Captures screenshots of the major interface pages for the Google Play
// listing, from which the README screenshots are also derived.
//
// Not part of the regular integration-test suite (tool/run_integration_tests.sh
// and CI glob `integration_test/*.dart`, which does not match this
// subdirectory).  Run via the wrapper script, which boots the right emulator,
// runs this test through `flutter drive`, and post-processes the images:
//
//   tool/take_screenshots.sh [phone|seven-inch|ten-inch|store]
//
// Every set captures the same pages, ending with Settings in the dark theme
// and again in the light theme.  `--dart-define=SCREENSHOT_SET=tablet` adapts
// the sequence to the two-pane layouts: freeform first gets a few earlier
// conversions so its history pane is not empty, and the unit browser is
// captured with a unit's detail beside the list instead of as two pages.
//
// The flow adapts to the layout it finds: it navigates with the navigation
// rail when there is one and the drawer otherwise, picks worksheets from the
// AppBar dropdown or the template list, and only pops the unit detail when it
// was pushed as a route.
//
// Screenshots are written by the driver (test_driver/screenshots_driver.dart)
// at the device's native resolution, to the directory in SCREENSHOT_DIR.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:unitary/features/browser/presentation/browser_screen.dart';
import 'package:unitary/features/browser/presentation/unit_entry_detail_screen.dart';
import 'package:unitary/features/worksheet/presentation/worksheet_screen.dart';
import 'package:unitary/main.dart' as app;

import '../helpers/real_prefs.dart';

const bool _isTablet =
    String.fromEnvironment('SCREENSHOT_SET', defaultValue: 'phone') == 'tablet';

/// Opens a top-level page or Settings, through the navigation rail if the
/// layout has one and through the drawer otherwise.
Future<void> _openPage(WidgetTester tester, String title) async {
  final rail = find.byType(NavigationRail);
  if (rail.evaluate().isNotEmpty) {
    if (title == 'Settings') {
      await tester.tap(find.byTooltip('Settings'));
    } else {
      await tester.tap(find.descendant(of: rail, matching: find.text(title)));
    }
  } else {
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(title).last);
  }
  await tester.pumpAndSettle();
}

/// Selects a worksheet template from the AppBar dropdown when there is one
/// (compact layout, once a template is active), and from the template list
/// otherwise.
Future<void> _selectWorksheet(WidgetTester tester, String name) async {
  final dropdown = find.byType(DropdownButton<String>);
  if (dropdown.evaluate().isNotEmpty) {
    await tester.tap(dropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text(name).last);
  } else {
    await tester.tap(
      find
          .descendant(
            of: find.byType(WorksheetScreen),
            matching: find.widgetWithText(ListTile, name),
          )
          .first,
    );
  }
  await tester.pumpAndSettle();
}

/// Enters a conversion in the freeform fields and waits for it to evaluate.
Future<void> _convert(WidgetTester tester, String from, String to) async {
  await tester.enterText(find.widgetWithText(TextField, 'Convert from'), from);
  await tester.pump();
  await tester.enterText(
    find.widgetWithText(TextField, 'Convert to (optional)'),
    to,
  );
  // Real-time evaluation debounce is 500 ms.
  await tester.pump(const Duration(milliseconds: 700));
  await tester.pumpAndSettle();
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  /// Takes a screenshot once animations have finished.  pumpAndSettle alone
  /// is not always enough on a slow emulator: the 10-inch tablet once captured
  /// the Settings route halfway through its page transition.  Waiting a moment
  /// in real time and settling again lets the last frame land first.
  Future<void> capture(WidgetTester tester, String name) async {
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    await binding.takeScreenshot(name);
  }

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

    // -- Freeform: enter an example conversion and let it evaluate.  The
    // tablet layouts show the history beside the fields, so a few earlier
    // conversions go in first to fill it.
    if (_isTablet) {
      await _convert(tester, '3e4 kilometers/week', 'mph');
      await _convert(tester, 'tempF(212)', 'tempC');
      await _convert(tester, 'sqrt(9 m^2) + sin(45 degrees) * 5 ft', 'm');
    }
    await _convert(tester, '5 ft + 3 in', 'cm');
    // Dismiss the completion overlay (typing "cm" opens it over the result).
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await capture(tester, 'freeform');

    // -- Worksheet: pick the Length template and enter a source value into
    // the meter row (index 6: micron, mm, cm, inch, foot, yard, meter, ...).
    await _openPage(tester, 'Worksheet');
    await _selectWorksheet(tester, 'Length');
    await tester.enterText(worksheetFields.at(6), '100');
    await tester.pumpAndSettle();
    await capture(tester, 'worksheet');

    // -- Currency worksheet.
    await _selectWorksheet(tester, 'Currency');
    await tester.enterText(worksheetFields.first, '100');
    await tester.pumpAndSettle();
    await capture(tester, 'currency');

    // -- Browse: expand a single group partway down the list ("Area" is the
    // seventh alphabetically), so the capture shows collapsed headers above
    // an expanded one.  On tablets the unit detail sits beside the list, so
    // the browser capture waits until a unit is selected.
    await _openPage(tester, 'Browse');
    await tester.tap(find.textContaining('Area ('));
    await tester.pumpAndSettle();
    if (!_isTablet) {
      await capture(tester, 'browser');
    }

    // -- Unit detail: search for a well-known unit and open its detail.  The
    // search-result tap is scoped to a ListTile because the search field's
    // own text also matches find.text('hbar').
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
    // At compact width the detail is a pushed route; wider layouts embed it.
    final pushed = find.byType(UnitEntryDetailScreen).evaluate().isNotEmpty;
    if (pushed) {
      await capture(tester, 'unit-detail');
      await tester.pageBack();
      await tester.pumpAndSettle();
    } else {
      // The search field stays on screen beside the detail; drop its cursor.
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await capture(tester, 'browser');
    }

    // -- Settings, in the device's dark theme, then again after switching the
    // app to light mode.
    await _openPage(tester, 'Settings');
    await capture(tester, 'settings-dark');
    await tester.tap(find.text('Light mode'));
    await tester.pumpAndSettle();
    await capture(tester, 'settings-light');
  });
}
