import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:unitary/features/freeform/presentation/freeform_screen.dart';
import 'package:unitary/features/freeform/state/conformable_browse_provider.dart';
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

  group('FreeformScreen — conformable-units modal', () {
    testWidgets('pressing button with pending debounce force-evaluates first', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp());

      // Type an expression — debounce has NOT fired yet.
      await tester.enterText(
        find.widgetWithText(TextField, 'Convert from'),
        '5 m',
      );
      await tester.pump(); // no 500ms wait

      // The debounce hasn't fired, so the modal is not yet open.
      expect(find.byType(DraggableScrollableSheet), findsNothing);

      // Trigger browse via provider (simulates AppBar button press).
      // FreeformScreen force-evaluates and attempts to open the modal.
      final container = ProviderScope.containerOf(
        tester.element(find.byType(FreeformScreen)),
      );
      container.read(conformableBrowseRequestProvider.notifier).trigger();
      await tester.pumpAndSettle();

      // After force-eval, evaluation succeeded and the modal is open.
      expect(find.byType(DraggableScrollableSheet), findsOneWidget);
    });

    testWidgets(
      'modal opens after force-evaluate produces ReciprocalConversionSuccess',
      (
        tester,
      ) async {
        await tester.pumpWidget(buildApp());

        // Enter an input whose dimension is the reciprocal of the output.
        await tester.enterText(
          find.widgetWithText(TextField, 'Convert from'),
          'm/s',
        );
        await tester.enterText(
          find.widgetWithText(TextField, 'Convert to (optional)'),
          's/m',
        );
        await tester.pump();

        final container = ProviderScope.containerOf(
          tester.element(find.byType(FreeformScreen)),
        );
        container.read(conformableBrowseRequestProvider.notifier).trigger();
        await tester.pumpAndSettle();

        // Reciprocal conversion succeeded — modal should open.
        expect(find.byType(DraggableScrollableSheet), findsOneWidget);
      },
    );

    testWidgets('modal does not open when force-evaluate errors', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp());

      await tester.enterText(
        find.widgetWithText(TextField, 'Convert from'),
        '5 +', // invalid expression
      );

      final container = ProviderScope.containerOf(
        tester.element(find.byType(FreeformScreen)),
      );
      container.read(conformableBrowseRequestProvider.notifier).trigger();
      await tester.pumpAndSettle();

      // No modal bottom sheet should appear.
      expect(find.byType(DraggableScrollableSheet), findsNothing);
    });

    testWidgets('modal opens for unit definition input (e.g. "byte")', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp());

      await tester.enterText(
        find.widgetWithText(TextField, 'Convert from'),
        'byte',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(FreeformScreen)),
      );
      container.read(conformableBrowseRequestProvider.notifier).trigger();
      await tester.pumpAndSettle();

      // Modal should open — 'byte' resolves to the digital-storage dimension.
      expect(find.byType(DraggableScrollableSheet), findsOneWidget);
      expect(find.text('bit'), findsOneWidget);
    });

    testWidgets('modal shows conformable entries for evaluated dimension', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp());

      // Use '5 bit' — digital storage has only ~6 conformable units, all
      // visible at once; 'bit' and 'byte' are near the top alphabetically.
      await tester.enterText(
        find.widgetWithText(TextField, 'Convert from'),
        '5 bit',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(FreeformScreen)),
      );
      container.read(conformableBrowseRequestProvider.notifier).trigger();
      await tester.pumpAndSettle();

      // Modal opened — 'bit' and 'byte' are visible digital-storage units.
      expect(find.byType(DraggableScrollableSheet), findsOneWidget);
      expect(find.text('bit'), findsOneWidget);
      expect(find.text('byte'), findsOneWidget);
    });

    testWidgets('primitive unit item shows [primitive unit] subtitle', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp());

      // 'bit' is the primitive digital-storage unit and sorts first
      // alphabetically, so it is immediately visible in the modal.
      await tester.enterText(
        find.widgetWithText(TextField, 'Convert from'),
        '5 bit',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(FreeformScreen)),
      );
      container.read(conformableBrowseRequestProvider.notifier).trigger();
      await tester.pumpAndSettle();

      expect(find.text('[primitive unit]'), findsWidgets);
    });

    testWidgets(
      'alias item shows "name = target" in title and target expression as subtitle',
      (tester) async {
        await tester.pumpWidget(buildApp());

        // 'byte' has alias 'B'; byte's expression is '8 bit'.
        await tester.enterText(
          find.widgetWithText(TextField, 'Convert from'),
          '5 bit',
        );
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();

        final container = ProviderScope.containerOf(
          tester.element(find.byType(FreeformScreen)),
        );
        container.read(conformableBrowseRequestProvider.notifier).trigger();
        await tester.pumpAndSettle();

        // 'B = byte' should appear as a title in the modal.
        expect(find.text('B = byte'), findsOneWidget);
        // The subtitle shows byte's definition expression.
        expect(find.text('8 bit'), findsWidgets);
      },
    );

    testWidgets('tapping entry fills empty Convert-to field', (tester) async {
      await tester.pumpWidget(buildApp());

      await tester.enterText(
        find.widgetWithText(TextField, 'Convert from'),
        '5 bit',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(FreeformScreen)),
      );
      container.read(conformableBrowseRequestProvider.notifier).trigger();
      await tester.pumpAndSettle();

      await tester.tap(find.text('byte'));
      await tester.pumpAndSettle();

      final outputField = tester.widget<TextField>(
        find.widgetWithText(TextField, 'byte'),
      );
      expect(outputField.controller?.text, 'byte');
    });

    testWidgets('tapping entry overwrites existing Convert-to text', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp());

      await tester.enterText(
        find.widgetWithText(TextField, 'Convert from'),
        '5 bit',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Convert to (optional)'),
        'byte',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(FreeformScreen)),
      );
      container.read(conformableBrowseRequestProvider.notifier).trigger();
      await tester.pumpAndSettle();

      await tester.tap(find.text('bit'));
      await tester.pumpAndSettle();

      final outputField = tester.widget<TextField>(
        find.widgetWithText(TextField, 'bit'),
      );
      expect(outputField.controller?.text, 'bit');
    });
  });
}
