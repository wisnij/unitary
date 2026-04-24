import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:unitary/core/domain/models/dimension.dart';
import 'package:unitary/core/domain/models/quantity.dart';
import 'package:unitary/features/freeform/data/freeform_repository.dart';
import 'package:unitary/features/freeform/presentation/freeform_screen.dart';
import 'package:unitary/features/freeform/state/freeform_provider.dart';
import 'package:unitary/features/freeform/state/freeform_state.dart';
import 'package:unitary/features/settings/data/settings_repository.dart';
import 'package:unitary/features/settings/models/user_settings.dart';
import 'package:unitary/features/settings/state/settings_provider.dart';

void main() {
  late SettingsRepository settingsRepo;
  late FreeformRepository freeformRepo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    settingsRepo = SettingsRepository(prefs);
    freeformRepo = FreeformRepository(prefs);
  });

  Widget buildApp({
    EvaluationMode evaluationMode = EvaluationMode.realtime,
    EvaluationResult? freeformState,
    FreeformRepository? freeformRepository,
  }) {
    return ProviderScope(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(settingsRepo),
        freeformRepositoryProvider.overrideWithValue(
          freeformRepository ?? freeformRepo,
        ),
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
      final freeformRepoLocal = FreeformRepository(prefs);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsRepositoryProvider.overrideWithValue(repo),
            freeformRepositoryProvider.overrideWithValue(freeformRepoLocal),
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
      final freeformRepoLocal = FreeformRepository(prefs);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsRepositoryProvider.overrideWithValue(repo),
            freeformRepositoryProvider.overrideWithValue(freeformRepoLocal),
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
      final freeformRepoLocal = FreeformRepository(prefs);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsRepositoryProvider.overrideWithValue(repo),
            freeformRepositoryProvider.overrideWithValue(freeformRepoLocal),
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

  group('FreeformScreen — persistence restore', () {
    testWidgets('controllers are empty when repository has no saved data', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp());
      await tester.pump();

      final inputField = tester.widget<TextField>(
        find.widgetWithText(TextField, 'Convert from'),
      );
      final outputField = tester.widget<TextField>(
        find.widgetWithText(TextField, 'Convert to (optional)'),
      );
      expect(inputField.controller?.text, '');
      expect(outputField.controller?.text, '');
    });

    testWidgets('input controller is pre-populated from saved data', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = FreeformRepository(prefs);
      await repo.save('5 ft', '');

      await tester.pumpWidget(buildApp(freeformRepository: repo));
      await tester.pump();

      final inputFields = find.byType(TextField);
      final firstController = tester
          .widget<TextField>(inputFields.first)
          .controller!;
      expect(firstController.text, '5 ft');
    });

    testWidgets('both controllers are pre-populated from saved data', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = FreeformRepository(prefs);
      await repo.save('5 ft', 'm');

      await tester.pumpWidget(buildApp(freeformRepository: repo));
      await tester.pump();

      final textFields = tester.widgetList<TextField>(find.byType(TextField));
      final texts = textFields.map((f) => f.controller?.text ?? '').toList();
      expect(texts, containsAll(['5 ft', 'm']));
    });

    testWidgets('result display is populated without user interaction when '
        'input is non-empty on restore', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = FreeformRepository(prefs);
      await repo.save('2 + 3', '');

      await tester.pumpWidget(buildApp(freeformRepository: repo));
      await tester.pump();

      // Should show the evaluated result, not idle text.
      expect(find.text('Enter an expression above.'), findsNothing);
    });
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
