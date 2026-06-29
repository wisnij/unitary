import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:unitary/features/settings/data/settings_repository.dart';
import 'package:unitary/features/settings/state/settings_provider.dart';
import 'package:unitary/features/worksheet/data/worksheet_repository.dart';
import 'package:unitary/features/worksheet/presentation/worksheet_screen.dart';
import 'package:unitary/features/worksheet/state/worksheet_provider.dart';

void main() {
  late SettingsRepository settingsRepo;
  late WorksheetRepository worksheetRepo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    settingsRepo = SettingsRepository(prefs);
    worksheetRepo = WorksheetRepository(prefs);
  });

  Widget buildApp() {
    return ProviderScope(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(settingsRepo),
        worksheetRepositoryProvider.overrideWithValue(worksheetRepo),
      ],
      child: MaterialApp(home: WorksheetScreen(onNavigate: (_) {})),
    );
  }

  Future<void> pump(WidgetTester tester, Size size) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = size;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
  }

  // Just under the 600 medium breakpoint.  (A narrower AppBar can overflow the
  // template dropdown — a pre-existing issue unrelated to this change.)
  const compact = Size(590, 800);
  const expanded = Size(1300, 900);

  group('Wide-width no selection', () {
    testWidgets('shows a placeholder and the static "Worksheet" title', (
      tester,
    ) async {
      await pump(tester, expanded);

      // No worksheet is selected on first launch.
      expect(find.widgetWithText(AppBar, 'Worksheet'), findsOneWidget);
      expect(find.text('Select a worksheet'), findsOneWidget);
      // No dropdown selector at wide width.
      expect(find.byType(DropdownButton<String>), findsNothing);
      // The left-pane list still shows template names as list tiles.
      expect(find.widgetWithText(ListTile, 'Length'), findsOneWidget);
      expect(find.widgetWithText(ListTile, 'Speed'), findsOneWidget);
    });

    testWidgets('no tile is highlighted before selection', (tester) async {
      await pump(tester, expanded);

      final tile = tester.widget<ListTile>(
        find.widgetWithText(ListTile, 'Length'),
      );
      expect(tile.selected, isFalse);
    });
  });

  group('Wide-width template list', () {
    testWidgets(
      'selecting a template shows it and a static AppBar title',
      (tester) async {
        await pump(tester, expanded);

        await tester.tap(find.widgetWithText(ListTile, 'Speed'));
        await tester.pumpAndSettle();

        // Placeholder is gone; the active template name is the AppBar title.
        expect(find.text('Select a worksheet'), findsNothing);
        expect(find.widgetWithText(AppBar, 'Speed'), findsOneWidget);
        // Still no dropdown at wide width.
        expect(find.byType(DropdownButton<String>), findsNothing);
      },
    );

    testWidgets('highlights the active template after selection', (
      tester,
    ) async {
      await pump(tester, expanded);

      await tester.tap(find.widgetWithText(ListTile, 'Length'));
      await tester.pumpAndSettle();

      final tile = tester.widget<ListTile>(
        find.widgetWithText(ListTile, 'Length'),
      );
      expect(tile.selected, isTrue);

      final other = tester.widget<ListTile>(
        find.widgetWithText(ListTile, 'Speed'),
      );
      expect(other.selected, isFalse);
    });

    testWidgets('tapping a template switches the worksheet and title', (
      tester,
    ) async {
      await pump(tester, expanded);

      await tester.tap(find.widgetWithText(ListTile, 'Length'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ListTile, 'Speed'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(AppBar, 'Speed'), findsOneWidget);
      final tile = tester.widget<ListTile>(
        find.widgetWithText(ListTile, 'Speed'),
      );
      expect(tile.selected, isTrue);
    });
  });

  group('Compact-width no selection', () {
    testWidgets('shows a full-screen template list and "Worksheet" title', (
      tester,
    ) async {
      await pump(tester, compact);

      expect(find.widgetWithText(AppBar, 'Worksheet'), findsOneWidget);
      // No dropdown until a worksheet is selected.
      expect(find.byType(DropdownButton<String>), findsNothing);
      // The full-screen template list is shown.
      expect(find.widgetWithText(ListTile, 'Speed'), findsOneWidget);
      // No placeholder at compact width — the list fills the screen instead.
      expect(find.text('Select a worksheet'), findsNothing);
    });

    testWidgets('selecting a template shows the dropdown selector', (
      tester,
    ) async {
      await pump(tester, compact);

      await tester.tap(find.widgetWithText(ListTile, 'Speed'));
      await tester.pumpAndSettle();

      // The AppBar dropdown selector appears once a worksheet is active.
      expect(find.byType(DropdownButton<String>), findsOneWidget);
      // The full-screen list is replaced by the worksheet (no list tile).
      expect(find.widgetWithText(ListTile, 'Length'), findsNothing);
    });
  });
}
