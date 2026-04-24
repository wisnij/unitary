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

  group('WorksheetScreen', () {
    testWidgets('shows rows for the initial template', (tester) async {
      await tester.pumpWidget(buildApp());

      // Derive the active template from the provider without assuming which
      // template is the default.
      final container = ProviderScope.containerOf(
        tester.element(find.byType(WorksheetScreen)),
      );
      final activeId = container.read(worksheetProvider).worksheetId;
      final activeTemplate = predefinedWorksheets.firstWhere(
        (t) => t.id == activeId,
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

      // Use the first row's expression from whatever template is active.
      final container = ProviderScope.containerOf(
        tester.element(find.byType(WorksheetScreen)),
      );
      final activeId = container.read(worksheetProvider).worksheetId;
      final activeTemplate = predefinedWorksheets.firstWhere(
        (t) => t.id == activeId,
      );
      final firstExpression = activeTemplate.rows.first.expression;

      expect(find.text(firstExpression), findsAtLeastNWidgets(1));
    });

    testWidgets('dropdown lists templates in alphabetical order', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp());

      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();

      final expectedOrder = predefinedWorksheets.map((t) => t.name).toList()
        ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

      // Verify items appear in alphabetical top-to-bottom order.
      double prevBottom = double.negativeInfinity;
      for (final name in expectedOrder) {
        final itemFinder = find.text(name).last;
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
