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
      child: MaterialApp(
        home: WorksheetScreen(onNavigate: (_) {}),
      ),
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
