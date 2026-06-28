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

  group('Wide-width template list', () {
    testWidgets('shows a left-pane list and a static AppBar title', (
      tester,
    ) async {
      await pump(tester, expanded);

      // No dropdown selector at wide width.
      expect(find.byType(DropdownButton<String>), findsNothing);
      // Static AppBar title for the active (default Length) template.
      expect(find.widgetWithText(AppBar, 'Length'), findsOneWidget);
      // The left-pane list shows template names as list tiles.
      expect(find.widgetWithText(ListTile, 'Length'), findsOneWidget);
      expect(find.widgetWithText(ListTile, 'Speed'), findsOneWidget);
    });

    testWidgets('highlights the active template', (tester) async {
      await pump(tester, expanded);

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

      await tester.tap(find.widgetWithText(ListTile, 'Speed'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(AppBar, 'Speed'), findsOneWidget);
      final tile = tester.widget<ListTile>(
        find.widgetWithText(ListTile, 'Speed'),
      );
      expect(tile.selected, isTrue);
    });
  });

  group('Compact-width selector', () {
    testWidgets('uses an AppBar dropdown, not a list pane', (tester) async {
      await pump(tester, compact);

      expect(find.byType(DropdownButton<String>), findsOneWidget);
      // No left-pane template list tile at compact width.
      expect(find.widgetWithText(ListTile, 'Speed'), findsNothing);
    });
  });
}
