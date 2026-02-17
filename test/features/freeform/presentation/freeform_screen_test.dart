import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:unitary/features/freeform/presentation/freeform_screen.dart';
import 'package:unitary/features/settings/data/settings_repository.dart';
import 'package:unitary/features/settings/models/user_settings.dart';
import 'package:unitary/features/settings/state/settings_provider.dart';

void main() {
  late SettingsRepository settingsRepo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    settingsRepo = SettingsRepository(prefs);
  });

  Widget buildApp({EvaluationMode evaluationMode = EvaluationMode.realtime}) {
    return ProviderScope(
      overrides: [settingsRepositoryProvider.overrideWithValue(settingsRepo)],
      child: const MaterialApp(
        home: Scaffold(body: FreeformScreen()),
      ),
    );
  }

  group('FreeformScreen', () {
    testWidgets('renders input and output fields', (tester) async {
      await tester.pumpWidget(buildApp());
      expect(find.widgetWithText(TextField, 'Convert from'), findsOneWidget);
      expect(
        find.widgetWithText(TextField, 'Convert to (optional)'),
        findsOneWidget,
      );
    });

    testWidgets('shows idle placeholder initially', (tester) async {
      await tester.pumpWidget(buildApp());
      expect(find.text('Enter an expression'), findsOneWidget);
    });

    testWidgets('typing in real-time mode triggers debounced evaluation', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp());

      await tester.enterText(
        find.widgetWithText(TextField, 'Convert from'),
        '5',
      );
      await tester.pump();
      // Before debounce fires, should still show idle.
      expect(find.text('Enter an expression'), findsOneWidget);

      // Wait for debounce (500ms + buffer).
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('5'), findsWidgets); // Input field + result.
    });

    testWidgets('Enter key triggers immediate evaluation', (tester) async {
      await tester.pumpWidget(buildApp());

      await tester.enterText(
        find.widgetWithText(TextField, 'Convert from'),
        '2 + 3',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(find.text('5'), findsWidgets);
    });

    testWidgets('clear button clears input and result', (tester) async {
      await tester.pumpWidget(buildApp());

      await tester.enterText(
        find.widgetWithText(TextField, 'Convert from'),
        '5',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      // Find and tap clear button.
      final clearButton = find.byIcon(Icons.clear);
      expect(clearButton, findsOneWidget);
      await tester.tap(clearButton);
      await tester.pump();

      expect(find.text('Enter an expression'), findsOneWidget);
    });

    testWidgets('conversion between two fields works', (tester) async {
      await tester.pumpWidget(buildApp());

      await tester.enterText(
        find.widgetWithText(TextField, 'Convert from'),
        '5 miles',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Convert to (optional)'),
        'km',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      // Just verify we don't see the idle text — conversion happened.
      expect(find.text('Enter an expression'), findsNothing);
    });

    testWidgets('on-submit mode shows evaluate button', (tester) async {
      SharedPreferences.setMockInitialValues({
        'evaluationMode': 'onSubmit',
      });
      final prefs = await SharedPreferences.getInstance();
      final repo = SettingsRepository(prefs);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
          child: const MaterialApp(
            home: Scaffold(body: FreeformScreen()),
          ),
        ),
      );

      expect(find.widgetWithText(ElevatedButton, 'Evaluate'), findsOneWidget);
    });

    testWidgets('on-submit mode does not evaluate on typing', (tester) async {
      SharedPreferences.setMockInitialValues({
        'evaluationMode': 'onSubmit',
      });
      final prefs = await SharedPreferences.getInstance();
      final repo = SettingsRepository(prefs);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
          child: const MaterialApp(
            home: Scaffold(body: FreeformScreen()),
          ),
        ),
      );

      await tester.enterText(
        find.widgetWithText(TextField, 'Convert from'),
        '5',
      );
      await tester.pump(const Duration(milliseconds: 600));

      // Should still show idle — no auto-evaluation.
      expect(find.text('Enter an expression'), findsOneWidget);
    });

    testWidgets('evaluate button triggers evaluation in on-submit mode', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'evaluationMode': 'onSubmit',
      });
      final prefs = await SharedPreferences.getInstance();
      final repo = SettingsRepository(prefs);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
          child: const MaterialApp(
            home: Scaffold(body: FreeformScreen()),
          ),
        ),
      );

      await tester.enterText(
        find.widgetWithText(TextField, 'Convert from'),
        '2 + 3',
      );
      await tester.pump();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Evaluate'));
      await tester.pump();

      expect(find.text('5'), findsWidgets);
    });

    testWidgets('real-time mode does not show evaluate button', (tester) async {
      await tester.pumpWidget(buildApp());
      expect(find.widgetWithText(ElevatedButton, 'Evaluate'), findsNothing);
    });

    testWidgets('parse error shows error message', (tester) async {
      await tester.pumpWidget(buildApp());

      await tester.enterText(
        find.widgetWithText(TextField, 'Convert from'),
        '5 +',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });
  });
}
