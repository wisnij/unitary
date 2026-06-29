import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:unitary/features/settings/data/settings_repository.dart';
import 'package:unitary/features/settings/state/settings_provider.dart';
import 'package:unitary/features/worksheet/data/predefined_worksheets.dart';
import 'package:unitary/features/worksheet/data/worksheet_repository.dart';
import 'package:unitary/features/worksheet/presentation/worksheet_screen.dart';
import 'package:unitary/features/worksheet/state/worksheet_provider.dart';

// Note: the "Label and input column widths" requirement in the worksheet-ui
// spec (minimum 130 dp label column, 12 em input minimum, equal-width inputs)
// is enforced via Flutter's Table + IntrinsicColumnWidth layout.  Font metrics
// in the headless test environment do not match device rendering, so these
// constraints are verified through manual testing on device rather than
// automated widget tests.

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
      child: MaterialApp(
        home: WorksheetScreen(onNavigate: (_) {}),
      ),
    );
  }

  // Selects a worksheet template by id via the provider, so tests can assume
  // an active worksheet (none is selected on launch).
  void selectTemplate(WidgetTester tester, String id) {
    final container = ProviderScope.containerOf(
      tester.element(find.byType(WorksheetScreen)),
    );
    container.read(worksheetProvider.notifier).selectWorksheet(id);
  }

  group('WorksheetScreen', () {
    testWidgets('no worksheet is selected on launch', (tester) async {
      await tester.pumpWidget(buildApp());

      final container = ProviderScope.containerOf(
        tester.element(find.byType(WorksheetScreen)),
      );
      expect(container.read(worksheetProvider).worksheetId, isNull);
      // The placeholder is shown (default test window is the medium tier).
      expect(find.text('Select a worksheet'), findsOneWidget);
    });

    testWidgets('shows rows for the selected template', (tester) async {
      await tester.pumpWidget(buildApp());
      selectTemplate(tester, 'length');
      await tester.pumpAndSettle();

      final activeTemplate = predefinedWorksheets.firstWhere(
        (t) => t.id == 'length',
      );

      // All row labels for the active template should be visible.
      for (final row in activeTemplate.rows) {
        expect(
          find.text(row.label),
          findsAtLeastNWidgets(1),
          reason: '${row.label} label not found',
        );
      }
    });

    testWidgets('shows row expression as secondary label', (tester) async {
      await tester.pumpWidget(buildApp());
      selectTemplate(tester, 'length');
      await tester.pumpAndSettle();

      final activeTemplate = predefinedWorksheets.firstWhere(
        (t) => t.id == 'length',
      );
      final firstExpression = activeTemplate.rows.first.expression;

      expect(find.text(firstExpression), findsAtLeastNWidgets(1));
    });

    testWidgets('dropdown lists templates in alphabetical order', (
      tester,
    ) async {
      // The AppBar dropdown is the compact-width selector; at medium/expanded
      // the templates are listed in a left pane instead (see
      // worksheet_two_pane_test.dart).
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(590, 800);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(buildApp());
      // A worksheet must be active for the dropdown selector to appear.
      selectTemplate(tester, 'length');
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();

      final expectedOrder = predefinedWorksheets.map((t) => t.name).toList()
        ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

      // Verify items appear in alphabetical top-to-bottom order.
      // Use skipOffstage: false so items scrolled off-screen are still found.
      double prevBottom = double.negativeInfinity;
      for (final name in expectedOrder) {
        final itemFinder = find.text(name, skipOffstage: false).last;
        final itemTop = tester.getTopLeft(itemFinder).dy;
        expect(
          itemTop,
          greaterThan(prevBottom),
          reason: '$name should appear below the previous item',
        );
        prevBottom = tester.getBottomLeft(itemFinder).dy;
      }
    });

    testWidgets('active row is not overwritten when engine updates', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp());
      selectTemplate(tester, 'length');
      await tester.pumpAndSettle();

      // Find the meters text field (first row of length worksheet).
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.first, '1');
      // Wait for debounce.
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump();

      // The first field should still show '1' (the user's input).
      final firstController = tester
          .widget<TextField>(textFields.first)
          .controller!;
      expect(firstController.text, '1');
    });
  });
}
