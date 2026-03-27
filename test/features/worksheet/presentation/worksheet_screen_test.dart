import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:unitary/features/settings/data/settings_repository.dart';
import 'package:unitary/features/settings/state/settings_provider.dart';
import 'package:unitary/features/worksheet/data/predefined_worksheets.dart';
import 'package:unitary/features/worksheet/presentation/worksheet_screen.dart';

void main() {
  late SettingsRepository settingsRepo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    settingsRepo = SettingsRepository(prefs);
  });

  Widget buildApp() {
    return ProviderScope(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(settingsRepo),
      ],
      child: const MaterialApp(home: WorksheetScreen()),
    );
  }

  group('WorksheetScreen', () {
    testWidgets('shows rows for the default (length) template', (tester) async {
      await tester.pumpWidget(buildApp());

      final lengthTemplate = predefinedWorksheets.firstWhere(
        (t) => t.id == 'length',
      );

      // All row labels should appear.
      for (final row in lengthTemplate.rows) {
        expect(
          find.text(row.label),
          findsOneWidget,
          reason: '${row.label} label not found',
        );
      }
    });

    testWidgets('shows row expression as secondary label', (tester) async {
      await tester.pumpWidget(buildApp());
      expect(find.text('ft'), findsOneWidget);
    });

    testWidgets('dropdown lists all template names', (tester) async {
      await tester.pumpWidget(buildApp());

      // Open the dropdown.
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();

      for (final template in predefinedWorksheets) {
        expect(
          find.text(template.name),
          findsWidgets, // may appear in button + list
          reason: '${template.name} not in dropdown',
        );
      }
    });

    testWidgets('selecting a template from dropdown switches worksheet', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp());

      // Open dropdown and select Speed.
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Speed').last);
      await tester.pumpAndSettle();

      final speedTemplate = predefinedWorksheets.firstWhere(
        (t) => t.id == 'speed',
      );
      expect(find.text(speedTemplate.rows.first.label), findsOneWidget);
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
