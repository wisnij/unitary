import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:unitary/core/domain/models/dimension.dart';
import 'package:unitary/core/domain/models/quantity.dart';
import 'package:unitary/features/freeform/data/freeform_history_repository.dart';
import 'package:unitary/features/freeform/data/idle_examples.dart';
import 'package:unitary/features/freeform/presentation/freeform_screen.dart';
import 'package:unitary/features/freeform/state/freeform_history_provider.dart';
import 'package:unitary/features/freeform/state/freeform_provider.dart';
import 'package:unitary/features/freeform/state/freeform_state.dart';
import 'package:unitary/features/settings/data/settings_repository.dart';
import 'package:unitary/features/settings/models/user_settings.dart';
import 'package:unitary/features/settings/state/settings_provider.dart';

void main() {
  late SettingsRepository settingsRepo;
  late FreeformHistoryRepository historyRepo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    settingsRepo = SettingsRepository(prefs);
    historyRepo = FreeformHistoryRepository(prefs);
  });

  Widget buildApp({
    EvaluationMode evaluationMode = EvaluationMode.realtime,
    EvaluationResult? freeformState,
  }) {
    return ProviderScope(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(settingsRepo),
        freeformHistoryRepositoryProvider.overrideWithValue(historyRepo),
        if (freeformState != null)
          freeformProvider.overrideWith(
            () => _StubFreeformNotifier(freeformState),
          ),
      ],
      child: MaterialApp(
        home: FreeformScreen(onNavigate: (_) {}),
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
      expect(find.text('Enter an expression above.'), findsOneWidget);
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
      expect(find.text('Enter an expression above.'), findsOneWidget);

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

      expect(find.text('Enter an expression above.'), findsOneWidget);
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
      expect(find.text('Enter an expression above.'), findsNothing);
    });

    testWidgets('on-submit mode shows evaluate button', (tester) async {
      SharedPreferences.setMockInitialValues({
        'evaluationMode': 'onSubmit',
      });
      final prefs = await SharedPreferences.getInstance();
      final repo = SettingsRepository(prefs);
      final history = FreeformHistoryRepository(prefs);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsRepositoryProvider.overrideWithValue(repo),
            freeformHistoryRepositoryProvider.overrideWithValue(history),
          ],
          child: MaterialApp(home: FreeformScreen(onNavigate: (_) {})),
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
      final history = FreeformHistoryRepository(prefs);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsRepositoryProvider.overrideWithValue(repo),
            freeformHistoryRepositoryProvider.overrideWithValue(history),
          ],
          child: MaterialApp(home: FreeformScreen(onNavigate: (_) {})),
        ),
      );

      await tester.enterText(
        find.widgetWithText(TextField, 'Convert from'),
        '5',
      );
      await tester.pump(const Duration(milliseconds: 600));

      // Should still show idle — no auto-evaluation.
      expect(find.text('Enter an expression above.'), findsOneWidget);
    });

    testWidgets('evaluate button triggers evaluation in on-submit mode', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'evaluationMode': 'onSubmit',
      });
      final prefs = await SharedPreferences.getInstance();
      final repo = SettingsRepository(prefs);
      final history = FreeformHistoryRepository(prefs);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsRepositoryProvider.overrideWithValue(repo),
            freeformHistoryRepositoryProvider.overrideWithValue(history),
          ],
          child: MaterialApp(home: FreeformScreen(onNavigate: (_) {})),
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

  group('FreeformScreen — Enter navigation', () {
    bool fieldHasFocus(WidgetTester tester, String label) {
      final field = tester.widget<TextField>(
        find.widgetWithText(TextField, label),
      );
      return field.focusNode?.hasFocus ?? false;
    }

    testWidgets(
      'Enter in Convert-from moves focus to Convert-to',
      (tester) async {
        await tester.pumpWidget(buildApp());

        await tester.tap(find.widgetWithText(TextField, 'Convert from'));
        await tester.pump();
        await tester.enterText(
          find.widgetWithText(TextField, 'Convert from'),
          '5 m',
        );
        await tester.pump();

        await tester.testTextInput.receiveAction(TextInputAction.next);
        await tester.pump();

        expect(fieldHasFocus(tester, 'Convert from'), isFalse);
        expect(fieldHasFocus(tester, 'Convert to (optional)'), isTrue);
      },
    );

    testWidgets(
      'Enter in Convert-from still evaluates in on-submit mode',
      (tester) async {
        SharedPreferences.setMockInitialValues({
          'evaluationMode': 'onSubmit',
        });
        final prefs = await SharedPreferences.getInstance();
        final repo = SettingsRepository(prefs);
        final history = FreeformHistoryRepository(prefs);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              settingsRepositoryProvider.overrideWithValue(repo),
              freeformHistoryRepositoryProvider.overrideWithValue(history),
            ],
            child: MaterialApp(home: FreeformScreen(onNavigate: (_) {})),
          ),
        );

        await tester.enterText(
          find.widgetWithText(TextField, 'Convert from'),
          '2 + 3',
        );
        await tester.pump();

        await tester.testTextInput.receiveAction(TextInputAction.next);
        await tester.pump();

        expect(find.text('5'), findsWidgets);
      },
    );

    testWidgets(
      'Enter in Convert-to dismisses focus from both fields and evaluates',
      (tester) async {
        await tester.pumpWidget(buildApp());

        await tester.enterText(
          find.widgetWithText(TextField, 'Convert from'),
          '5 miles',
        );
        await tester.tap(
          find.widgetWithText(TextField, 'Convert to (optional)'),
        );
        await tester.pump();
        await tester.enterText(
          find.widgetWithText(TextField, 'Convert to (optional)'),
          'km',
        );
        await tester.pump();

        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();

        expect(fieldHasFocus(tester, 'Convert from'), isFalse);
        expect(fieldHasFocus(tester, 'Convert to (optional)'), isFalse);
        // Evaluation occurred — no longer showing the idle placeholder.
        expect(find.text('Enter an expression above.'), findsNothing);
      },
    );
  });

  group('FreeformScreen — swap button', () {
    testWidgets('swap button is always visible between the two fields', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp());
      expect(find.byIcon(Icons.swap_vert), findsOneWidget);
    });

    Finder findSwapButton() => find.ancestor(
      of: find.byIcon(Icons.swap_vert),
      matching: find.byType(IconButton),
    );

    testWidgets('swap button is disabled when both fields are empty', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp());
      final btn = tester.widget<IconButton>(findSwapButton());
      expect(btn.onPressed, isNull);
    });

    testWidgets('swap button is disabled when only input field has text', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp());
      await tester.enterText(
        find.widgetWithText(TextField, 'Convert from'),
        '5 miles',
      );
      await tester.pump();
      final btn = tester.widget<IconButton>(findSwapButton());
      expect(btn.onPressed, isNull);
    });

    testWidgets('swap button is disabled when only output field has text', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp());
      await tester.enterText(
        find.widgetWithText(TextField, 'Convert to (optional)'),
        'km',
      );
      await tester.pump();
      final btn = tester.widget<IconButton>(findSwapButton());
      expect(btn.onPressed, isNull);
    });

    testWidgets('swap button is enabled when both fields have text', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp());
      await tester.enterText(
        find.widgetWithText(TextField, 'Convert from'),
        '5 miles',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Convert to (optional)'),
        'km',
      );
      await tester.pump();
      final btn = tester.widget<IconButton>(findSwapButton());
      expect(btn.onPressed, isNotNull);
    });

    testWidgets('tapping swap exchanges field contents', (tester) async {
      await tester.pumpWidget(buildApp());

      await tester.enterText(
        find.widgetWithText(TextField, 'Convert from'),
        '5 miles',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Convert to (optional)'),
        'km',
      );
      await tester.pump();

      await tester.tap(find.byIcon(Icons.swap_vert));
      await tester.pump();

      final inputField = tester.widget<TextField>(
        find.widgetWithText(TextField, 'km'),
      );
      final outputField = tester.widget<TextField>(
        find.widgetWithText(TextField, '5 miles'),
      );
      expect(inputField.controller?.text, 'km');
      expect(outputField.controller?.text, '5 miles');
    });

    testWidgets('tapping swap triggers immediate evaluation', (tester) async {
      await tester.pumpWidget(buildApp());

      await tester.enterText(
        find.widgetWithText(TextField, 'Convert from'),
        '5 miles',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Convert to (optional)'),
        'km',
      );
      await tester.pump();

      // Tap swap without waiting for debounce.
      await tester.tap(find.byIcon(Icons.swap_vert));
      await tester.pump(); // No debounce wait — should evaluate immediately.

      // After swap, km is now the input; should not be showing idle state.
      expect(find.text('Enter an expression above.'), findsNothing);
    });
  });

  group('FreeformScreen — conformable-units button', () {
    final browseButtonFinder = find.byIcon(Icons.balance);

    testWidgets('button is present in AppBar', (tester) async {
      await tester.pumpWidget(buildApp());
      expect(browseButtonFinder, findsOneWidget);
    });

    testWidgets('button is disabled when freeformProvider is idle', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildApp(freeformState: const EvaluationIdle()),
      );
      await tester.pump();
      final btn = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.balance),
      );
      expect(btn.onPressed, isNull);
    });

    testWidgets(
      'button is enabled when freeformProvider is EvaluationSuccess',
      (tester) async {
        await tester.pumpWidget(
          buildApp(
            freeformState: EvaluationSuccess(
              result: _stubQty,
              formattedResult: '= 5',
            ),
          ),
        );
        await tester.pump();
        final btn = tester.widget<IconButton>(
          find.widgetWithIcon(IconButton, Icons.balance),
        );
        expect(btn.onPressed, isNotNull);
      },
    );

    testWidgets(
      'button is enabled when freeformProvider is ConversionSuccess',
      (tester) async {
        await tester.pumpWidget(
          buildApp(
            freeformState: const ConversionSuccess(
              convertedValue: 2.0,
              formattedResult: '= 2 ft',
              formattedReciprocal: '= (1 / 0.5) ft',
              outputUnit: 'ft',
            ),
          ),
        );
        await tester.pump();
        final btn = tester.widget<IconButton>(
          find.widgetWithIcon(IconButton, Icons.balance),
        );
        expect(btn.onPressed, isNotNull);
      },
    );

    testWidgets(
      'button is enabled when freeformProvider is UnitDefinitionResult',
      (tester) async {
        await tester.pumpWidget(
          buildApp(
            freeformState: const UnitDefinitionResult(
              aliasLine: null,
              definitionLine: null,
              formattedResult: '= 8 bit',
            ),
          ),
        );
        await tester.pump();
        final btn = tester.widget<IconButton>(
          find.widgetWithIcon(IconButton, Icons.balance),
        );
        expect(btn.onPressed, isNotNull);
      },
    );

    testWidgets(
      'button is enabled when freeformProvider is FunctionConversionResult',
      (tester) async {
        await tester.pumpWidget(
          buildApp(
            freeformState: const FunctionConversionResult(
              functionName: 'tempC',
              formattedValue: '26.85',
            ),
          ),
        );
        await tester.pump();
        final btn = tester.widget<IconButton>(
          find.widgetWithIcon(IconButton, Icons.balance),
        );
        expect(btn.onPressed, isNotNull);
      },
    );

    testWidgets(
      'button is disabled when freeformProvider is FunctionDefinitionResult',
      (tester) async {
        await tester.pumpWidget(
          buildApp(
            freeformState: const FunctionDefinitionResult(
              label: 'tempC(x) =',
              expression: 'x + 273.15',
            ),
          ),
        );
        await tester.pump();
        final btn = tester.widget<IconButton>(
          find.widgetWithIcon(IconButton, Icons.balance),
        );
        expect(btn.onPressed, isNull);
      },
    );

    testWidgets(
      'button is enabled when freeformProvider is ReciprocalConversionSuccess',
      (tester) async {
        await tester.pumpWidget(
          buildApp(
            freeformState: const ReciprocalConversionSuccess(
              reciprocalInputLabel: '1 / mph',
              formattedResult: '= 2.2369363 s/m',
              formattedReciprocal: '= 0.44704 m/s',
              outputUnit: 's/m',
            ),
          ),
        );
        await tester.pump();
        final btn = tester.widget<IconButton>(
          find.widgetWithIcon(IconButton, Icons.balance),
        );
        expect(btn.onPressed, isNotNull);
      },
    );

    testWidgets(
      'button is disabled when freeformProvider is EvaluationError',
      (tester) async {
        await tester.pumpWidget(
          buildApp(
            freeformState: const EvaluationError(message: 'oops'),
          ),
        );
        await tester.pump();
        final btn = tester.widget<IconButton>(
          find.widgetWithIcon(IconButton, Icons.balance),
        );
        expect(btn.onPressed, isNull);
      },
    );
  });

  group('FreeformScreen — conformable-units modal', () {
    /// Evaluate [expression] and tap the balance button to open the modal.
    Future<void> openModal(WidgetTester tester, String expression) async {
      await tester.enterText(
        find.widgetWithText(TextField, 'Convert from'),
        expression,
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      // Button is now enabled — tap it.
      await tester.tap(find.byIcon(Icons.balance));
      await tester.pumpAndSettle();
    }

    testWidgets('button opens conformable-units modal when state is valid', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp());
      await openModal(tester, '5 m');
      expect(find.byType(DraggableScrollableSheet), findsOneWidget);
    });

    testWidgets(
      'modal opens after evaluation produces ReciprocalConversionSuccess',
      (tester) async {
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
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();

        await tester.tap(find.byIcon(Icons.balance));
        await tester.pumpAndSettle();

        // Reciprocal conversion succeeded — modal should open.
        expect(find.byType(DraggableScrollableSheet), findsOneWidget);
      },
    );

    testWidgets('modal does not open when evaluation errors', (tester) async {
      await tester.pumpWidget(buildApp());

      // Evaluate a valid expression first so the button becomes enabled.
      await tester.enterText(
        find.widgetWithText(TextField, 'Convert from'),
        '5 m',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      // Now change input to invalid — debounce hasn't fired so state is still valid.
      await tester.enterText(
        find.widgetWithText(TextField, 'Convert from'),
        '5 +',
      );
      // Do NOT wait for debounce — button is still enabled from previous state.

      await tester.tap(find.byIcon(Icons.balance));
      await tester.pumpAndSettle();

      // _showConformableModal evaluates current text ('5 +') → parse error → no modal.
      expect(find.byType(DraggableScrollableSheet), findsNothing);
    });

    testWidgets('modal opens for unit definition input (e.g. "byte")', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp());
      await openModal(tester, 'byte');

      // Modal should open — 'byte' resolves to the digital-storage dimension.
      expect(find.byType(DraggableScrollableSheet), findsOneWidget);
      expect(find.text('bit'), findsOneWidget);
    });

    testWidgets('modal shows conformable entries for evaluated dimension', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp());
      await openModal(tester, '5 bit');

      // Modal opened — 'bit' and 'byte' are visible digital-storage units.
      expect(find.byType(DraggableScrollableSheet), findsOneWidget);
      expect(find.text('bit'), findsOneWidget);
      expect(find.text('byte'), findsOneWidget);
    });

    testWidgets('primitive unit item shows [primitive unit] subtitle', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp());
      await openModal(tester, '5 bit');
      expect(find.text('[primitive unit]'), findsWidgets);
    });

    testWidgets(
      'alias item shows "name = target" in title and target expression as subtitle',
      (tester) async {
        await tester.pumpWidget(buildApp());
        await openModal(tester, '5 bit');

        // 'B = byte' should appear as a title in the modal.
        expect(find.text('B = byte'), findsOneWidget);
        // The subtitle shows byte's definition expression.
        expect(find.text('8 bit'), findsWidgets);
      },
    );

    testWidgets('tapping entry fills empty Convert-to field', (tester) async {
      await tester.pumpWidget(buildApp());
      await openModal(tester, '5 bit');

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

      await tester.tap(find.byIcon(Icons.balance));
      await tester.pumpAndSettle();

      await tester.tap(find.text('bit'));
      await tester.pumpAndSettle();

      final outputField = tester.widget<TextField>(
        find.widgetWithText(TextField, 'bit'),
      );
      expect(outputField.controller?.text, 'bit');
    });
  });

  group('FreeformScreen — history button', () {
    Finder findHistoryButton() => find.ancestor(
      of: find.byIcon(Icons.history),
      matching: find.byType(IconButton),
    );

    testWidgets('history button is present in AppBar', (tester) async {
      await tester.pumpWidget(buildApp());
      expect(find.byIcon(Icons.history), findsOneWidget);
    });

    testWidgets('history button is disabled when history is empty', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp());
      final btn = tester.widget<IconButton>(findHistoryButton());
      expect(btn.onPressed, isNull);
    });

    testWidgets('history button is enabled after a successful evaluation', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp());

      await tester.enterText(
        find.widgetWithText(TextField, 'Convert from'),
        '5 km',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      final btn = tester.widget<IconButton>(findHistoryButton());
      expect(btn.onPressed, isNotNull);
    });

    testWidgets(
      'history button is enabled after evaluation in on-submit mode',
      (tester) async {
        SharedPreferences.setMockInitialValues({
          'evaluationMode': 'onSubmit',
        });
        final prefs = await SharedPreferences.getInstance();
        final repo = SettingsRepository(prefs);
        final history = FreeformHistoryRepository(prefs);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              settingsRepositoryProvider.overrideWithValue(repo),
              freeformHistoryRepositoryProvider.overrideWithValue(history),
            ],
            child: MaterialApp(home: FreeformScreen(onNavigate: (_) {})),
          ),
        );

        await tester.enterText(
          find.widgetWithText(TextField, 'Convert from'),
          '5 km',
        );
        await tester.pump();

        // Debounce should NOT fire in on-submit mode — button still disabled.
        await tester.pump(const Duration(milliseconds: 600));
        expect(
          tester.widget<IconButton>(findHistoryButton()).onPressed,
          isNull,
        );

        // Tap Evaluate — should record entry.
        await tester.tap(find.widgetWithText(ElevatedButton, 'Evaluate'));
        await tester.pump();

        expect(
          tester.widget<IconButton>(findHistoryButton()).onPressed,
          isNotNull,
        );
      },
    );

    testWidgets('tapping history button opens modal', (tester) async {
      await tester.pumpWidget(buildApp());

      await tester.enterText(
        find.widgetWithText(TextField, 'Convert from'),
        '5 km',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      await tester.tap(find.byIcon(Icons.history));
      await tester.pumpAndSettle();

      expect(find.byType(DraggableScrollableSheet), findsOneWidget);
    });

    testWidgets('modal shows entry as "from = result" when result is set', (
      tester,
    ) async {
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

      await tester.tap(find.byIcon(Icons.history));
      await tester.pumpAndSettle();

      // Entry should show "5 miles = <result> km", not just "5 miles = km".
      expect(find.textContaining('5 miles = '), findsOneWidget);
      expect(find.text('5 miles = km'), findsNothing);
    });

    testWidgets('modal shows only from when result is empty', (tester) async {
      await tester.pumpWidget(buildApp());

      // tempF (bare function name) produces FunctionDefinitionResult with empty result.
      await tester.enterText(
        find.widgetWithText(TextField, 'Convert from'),
        'tempF',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      await tester.tap(find.byIcon(Icons.history));
      await tester.pumpAndSettle();

      expect(find.text('tempF'), findsWidgets);
      expect(find.textContaining('tempF = '), findsNothing);
    });

    testWidgets(
      'tapping a history entry restores both fields and closes modal',
      (tester) async {
        await tester.pumpWidget(buildApp());

        // Create a history entry.
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

        // Clear the fields.
        await tester.tap(find.byIcon(Icons.clear));
        await tester.pump();

        // Open the modal and tap the entry.
        await tester.tap(find.byIcon(Icons.history));
        await tester.pumpAndSettle();
        await tester.tap(find.textContaining('5 miles = '));
        await tester.pumpAndSettle();

        // Modal should be dismissed.
        expect(find.byType(DraggableScrollableSheet), findsNothing);

        final inputField = tester.widget<TextField>(
          find.widgetWithText(TextField, '5 miles'),
        );
        expect(inputField.controller?.text, '5 miles');

        final outputField = tester.widget<TextField>(
          find.widgetWithText(TextField, 'km'),
        );
        expect(outputField.controller?.text, 'km');
      },
    );

    testWidgets('tapping a history entry triggers evaluation', (tester) async {
      await tester.pumpWidget(buildApp());

      await tester.enterText(
        find.widgetWithText(TextField, 'Convert from'),
        '5 km',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      // Clear fields.
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      expect(find.text('Enter an expression above.'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.history));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('5 km = '));
      await tester.pumpAndSettle();

      expect(find.text('Enter an expression above.'), findsNothing);
    });
  });

  group('FreeformScreen — key panel', () {
    const symbols = freeformKeyPanelSymbols;

    testWidgets(
      'key panel contains all 9 symbols when Convert-from is focused',
      (tester) async {
        await tester.pumpWidget(buildApp());
        await tester.tap(find.widgetWithText(TextField, 'Convert from'));
        await tester
            .pump(); // postFrameCallback fires, setState marks tree dirty
        await tester.pump(); // rebuild renders panel
        for (final sym in symbols) {
          expect(
            find.widgetWithText(TextButton, sym),
            findsOneWidget,
            reason: 'Expected symbol button "$sym" in key panel',
          );
        }
      },
    );

    testWidgets(
      'key panel contains all 9 symbols when Convert-to is focused',
      (tester) async {
        await tester.pumpWidget(buildApp());
        await tester.tap(
          find.widgetWithText(TextField, 'Convert to (optional)'),
        );
        await tester.pump();
        await tester.pump();
        for (final sym in symbols) {
          expect(
            find.widgetWithText(TextButton, sym),
            findsOneWidget,
            reason: 'Expected symbol button "$sym" in key panel',
          );
        }
      },
    );

    testWidgets('key panel is not visible when neither field is focused', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp());
      for (final sym in symbols) {
        expect(find.widgetWithText(TextButton, sym), findsNothing);
      }
    });

    testWidgets(
      'key panel disappears when focus leaves both fields (mobile)',
      (tester) async {
        await tester.pumpWidget(buildApp());

        // Focus a field so the panel appears.
        await tester.tap(find.widgetWithText(TextField, 'Convert from'));
        await tester.pump();
        await tester.pump();
        expect(find.widgetWithText(TextButton, '^'), findsOneWidget);

        // Dismiss focus programmatically (equivalent to tapping outside).
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pump();
        await tester.pump();
        expect(find.widgetWithText(TextButton, '^'), findsNothing);
      },
      // Focus-based visibility only applies on mobile; the variant ensures
      // _showPanel uses _anyFieldFocused rather than always returning true.
      variant: TargetPlatformVariant.only(TargetPlatform.android),
    );

    testWidgets('tapping a symbol inserts it at cursor in Convert-from', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp());
      await tester.enterText(
        find.widgetWithText(TextField, 'Convert from'),
        '5 ft',
      );
      await tester.pump();

      await tester.tap(find.widgetWithText(TextButton, '^'));
      await tester.pump();

      final inputField = tester.widget<TextField>(
        find.widgetWithText(TextField, '5 ft^'),
      );
      expect(inputField.controller?.text, '5 ft^');
    });

    testWidgets('tapping a symbol inserts it at cursor in Convert-to', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp());
      await tester.enterText(
        find.widgetWithText(TextField, 'Convert to (optional)'),
        'km',
      );
      await tester.pump();

      await tester.tap(find.widgetWithText(TextButton, '('));
      await tester.pump();

      final outputField = tester.widget<TextField>(
        find.widgetWithText(TextField, 'km('),
      );
      expect(outputField.controller?.text, 'km(');
    });

    testWidgets('tapping a symbol replaces selected text', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.enterText(
        find.widgetWithText(TextField, 'Convert from'),
        '5 km',
      );
      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: '5 km',
          selection: TextSelection(baseOffset: 2, extentOffset: 4),
        ),
      );
      await tester.pump();

      await tester.tap(find.widgetWithText(TextButton, '*'));
      await tester.pump();

      final inputField = tester.widget<TextField>(
        find.widgetWithText(TextField, '5 *'),
      );
      expect(inputField.controller?.text, '5 *');
    });

    testWidgets(
      'insertion triggers debounced evaluation in real-time mode',
      (tester) async {
        await tester.pumpWidget(buildApp());
        await tester.tap(find.widgetWithText(TextField, 'Convert from'));
        await tester.pump();
        await tester.pump();

        await tester.tap(find.widgetWithText(TextButton, '+'));
        await tester.pump();

        // Before debounce fires: '+' has not been evaluated yet.
        expect(find.text('Enter an expression above.'), findsOneWidget);

        // After debounce (500 ms): evaluation runs; '+' alone is a parse
        // error so state becomes EvaluationError, not idle.
        await tester.pump(const Duration(milliseconds: 600));
        expect(find.text('Enter an expression above.'), findsNothing);
      },
    );

    testWidgets(
      'insertion does not trigger evaluation in on-submit mode',
      (tester) async {
        SharedPreferences.setMockInitialValues({'evaluationMode': 'onSubmit'});
        final prefs = await SharedPreferences.getInstance();
        final repo = SettingsRepository(prefs);
        final history = FreeformHistoryRepository(prefs);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              settingsRepositoryProvider.overrideWithValue(repo),
              freeformHistoryRepositoryProvider.overrideWithValue(history),
            ],
            child: MaterialApp(home: FreeformScreen(onNavigate: (_) {})),
          ),
        );

        await tester.tap(find.widgetWithText(TextField, 'Convert from'));
        await tester.pump();
        await tester.pump();

        await tester.tap(find.widgetWithText(TextButton, '+'));
        await tester.pump(const Duration(milliseconds: 600));

        // Still idle — no debounced evaluation in on-submit mode.
        expect(find.text('Enter an expression above.'), findsOneWidget);
      },
    );
  });

  group('FreeformScreen — idle example focus dismissal', () {
    // Helper: finds the "Try: <example>" text in the idle result area.
    Finder findIdleExample() => find.textContaining('Try:');

    // After unfocus(), Flutter returns focus to the nearest ancestor
    // FocusScopeNode (e.g., the Navigator scope) rather than null.
    // "No text field focused" means primaryFocus is null or a FocusScopeNode.
    bool noTextFieldFocused() {
      final focus = FocusManager.instance.primaryFocus;
      return focus == null || focus is FocusScopeNode;
    }

    testWidgets(
      'tapping idle example leaves no text field focused when no prior focus',
      (tester) async {
        await tester.pumpWidget(buildApp());

        // Verify idle display is visible with no prior focus.
        expect(findIdleExample(), findsOneWidget);

        await tester.tap(findIdleExample());
        await tester.pump();

        expect(noTextFieldFocused(), isTrue);
      },
    );

    testWidgets(
      'tapping idle example dismisses focus when Convert-from was focused',
      (tester) async {
        await tester.pumpWidget(buildApp());

        // Focus the Convert-from field without typing (state stays idle).
        await tester.tap(find.widgetWithText(TextField, 'Convert from'));
        await tester.pump();
        await tester.pump();
        expect(findIdleExample(), findsOneWidget);
        // A text field is now focused.
        expect(FocusManager.instance.primaryFocus, isNotNull);
        expect(
          FocusManager.instance.primaryFocus,
          isNot(isA<FocusScopeNode>()),
        );

        await tester.tap(findIdleExample());
        await tester.pump();

        expect(noTextFieldFocused(), isTrue);
      },
      variant: TargetPlatformVariant.only(TargetPlatform.android),
    );

    testWidgets(
      'tapping idle example dismisses focus when Convert-to was focused',
      (tester) async {
        await tester.pumpWidget(buildApp());

        // Focus the Convert-to field without typing (state stays idle).
        await tester.tap(
          find.widgetWithText(TextField, 'Convert to (optional)'),
        );
        await tester.pump();
        await tester.pump();
        expect(findIdleExample(), findsOneWidget);
        // A text field is now focused.
        expect(FocusManager.instance.primaryFocus, isNotNull);
        expect(
          FocusManager.instance.primaryFocus,
          isNot(isA<FocusScopeNode>()),
        );

        await tester.tap(findIdleExample());
        await tester.pump();

        expect(noTextFieldFocused(), isTrue);
      },
      variant: TargetPlatformVariant.only(TargetPlatform.android),
    );
  });

  group('FreeformScreen — predictive completion', () {
    testWidgets('Convert-from field shows completion overlay when typing', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp());

      await tester.tap(find.widgetWithText(TextField, 'Convert from'));
      await tester.pump();

      // Enter a 2-char prefix that matches a known unit primary ID.
      await tester.enterText(
        find.widgetWithText(TextField, 'Convert from'),
        'kg',
      );
      // Post-frame callbacks + overlay render.
      for (var i = 0; i < 4; i++) {
        await tester.pump();
      }

      // "kg" should appear at least twice: once in the field, once in overlay.
      expect(find.text('kg'), findsWidgets);
    });

    testWidgets('Convert-to field shows completion overlay when typing', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp());

      await tester.tap(
        find.widgetWithText(TextField, 'Convert to (optional)'),
      );
      await tester.pump();

      await tester.enterText(
        find.widgetWithText(TextField, 'Convert to (optional)'),
        'kg',
      );
      for (var i = 0; i < 4; i++) {
        await tester.pump();
      }

      expect(find.text('kg'), findsWidgets);
    });

    testWidgets('overlay dismissed when field loses focus', (tester) async {
      await tester.pumpWidget(buildApp());

      // Focus Convert-from and type a matching prefix.
      await tester.tap(find.widgetWithText(TextField, 'Convert from'));
      await tester.pump();
      await tester.enterText(
        find.widgetWithText(TextField, 'Convert from'),
        'kg',
      );
      for (var i = 0; i < 4; i++) {
        await tester.pump();
      }
      // Overlay visible — "kg" appears at least twice (field + suggestion row).
      expect(find.text('kg'), findsWidgets);

      // Unfocus programmatically (avoids tapping through the overlay, which
      // can cover the "Convert to" field in the test viewport).
      FocusManager.instance.primaryFocus?.unfocus();
      for (var i = 0; i < 4; i++) {
        await tester.pump();
      }
      // Overlay dismissed; "kg" appears only once (in the text field itself).
      expect(find.text('kg'), findsOneWidget);
    });

    testWidgets('tapping suggestion updates expression', (tester) async {
      await tester.pumpWidget(buildApp());

      await tester.tap(find.widgetWithText(TextField, 'Convert from'));
      await tester.pump();

      await tester.enterText(
        find.widgetWithText(TextField, 'Convert from'),
        'kilo',
      );
      for (var i = 0; i < 4; i++) {
        await tester.pump();
      }

      // Tap a completion suggestion (the "kilo-" prefix entry).
      final sugg = find.text('kilo-');
      expect(sugg, findsOneWidget);
      await tester.tap(sugg);
      for (var i = 0; i < 4; i++) {
        await tester.pump();
      }

      // Text field should now contain the selected identifier.
      expect(
        find.widgetWithText(TextField, 'kilo'),
        findsOneWidget,
      );
    });

    testWidgets('tapping suggestion triggers evaluation in real-time mode', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp());

      await tester.tap(find.widgetWithText(TextField, 'Convert from'));
      await tester.pump();

      await tester.enterText(
        find.widgetWithText(TextField, 'Convert from'),
        'kilo',
      );
      for (var i = 0; i < 4; i++) {
        await tester.pump();
      }

      // Tap the "kilo-" prefix suggestion.
      await tester.tap(find.text('kilo-'));
      // Allow debounce to fire.
      await tester.pump(const Duration(milliseconds: 600));

      // "kilo" is a valid prefix — result should not be the idle placeholder.
      expect(find.text('Enter an expression above.'), findsNothing);
    });

    testWidgets('only the focused field shows its completion overlay', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp());

      // Focus Convert-from and type a matching prefix → overlay appears.
      await tester.tap(find.widgetWithText(TextField, 'Convert from'));
      await tester.pump();
      await tester.enterText(
        find.widgetWithText(TextField, 'Convert from'),
        'kg',
      );
      for (var i = 0; i < 4; i++) {
        await tester.pump();
      }
      // "kg" appears at least twice: text field + overlay suggestion row.
      expect(find.text('kg'), findsWidgets);

      // Now focus Convert-to and type a different prefix.
      await tester.tap(
        find.widgetWithText(TextField, 'Convert to (optional)'),
      );
      await tester.pump();
      await tester.enterText(
        find.widgetWithText(TextField, 'Convert to (optional)'),
        'met',
      );
      for (var i = 0; i < 4; i++) {
        await tester.pump();
      }

      // Convert-from overlay is gone: "kg" appears only once (in the field).
      expect(find.text('kg'), findsOneWidget);

      // Convert-to overlay is visible: 'met'-prefix suggestions are shown.
      // "meter" is a registered unit alias — it should appear in the overlay.
      expect(find.text('meter'), findsWidgets);
    });
  });

  group('FreeformScreen — idle example tap-to-fill', () {
    testWidgets(
      'tapping example without output fills only Convert-from field',
      (tester) async {
        await tester.pumpWidget(
          buildApp(
            freeformState: const EvaluationIdle(
              example: FreeformExample(inputExpression: '60 mph'),
            ),
          ),
        );

        await tester.tap(find.textContaining('Try:'));
        await tester.pump();

        // Convert-from is filled with the example expression.
        final inputField = tester.widget<TextField>(
          find.widgetWithText(TextField, '60 mph'),
        );
        expect(inputField.controller?.text, '60 mph');

        // Convert-to is not modified — the label placeholder is still visible.
        expect(
          find.widgetWithText(TextField, 'Convert to (optional)'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'tapping example with output fills both Convert-from and Convert-to',
      (tester) async {
        await tester.pumpWidget(
          buildApp(
            freeformState: const EvaluationIdle(
              example: FreeformExample(
                inputExpression: '1|2 gallon',
                outputExpression: 'ml',
              ),
            ),
          ),
        );

        await tester.tap(find.textContaining('Try:'));
        await tester.pump();

        // Convert-from is filled.
        final inputField = tester.widget<TextField>(
          find.widgetWithText(TextField, '1|2 gallon'),
        );
        expect(inputField.controller?.text, '1|2 gallon');

        // Convert-to is filled with the output expression.
        final outputField = tester.widget<TextField>(
          find.widgetWithText(TextField, 'ml'),
        );
        expect(outputField.controller?.text, 'ml');
      },
    );
  });
}

// ---------------------------------------------------------------------------
// Test helpers
// ---------------------------------------------------------------------------

final _stubQty = Quantity(1.0, Dimension.dimensionless);

class _StubFreeformNotifier extends FreeformNotifier {
  final EvaluationResult _initial;
  _StubFreeformNotifier(this._initial);

  @override
  EvaluationResult build() => _initial;
}
