import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:unitary/app.dart';
import 'package:unitary/features/settings/data/settings_repository.dart';
import 'package:unitary/features/settings/state/settings_provider.dart';

void main() {
  late SettingsRepository repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    repo = SettingsRepository(prefs);
  });

  Widget buildApp() {
    return ProviderScope(
      overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
      child: const UnitaryApp(),
    );
  }

  group('Freeform integration', () {
    testWidgets('type "5 ft" → result shows value in meters', (tester) async {
      await tester.pumpWidget(buildApp());

      await tester.enterText(
        find.widgetWithText(TextField, 'Convert from'),
        '5 ft',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      // 5 ft = 1.524 m
      expect(find.textContaining('1.524'), findsOneWidget);
      expect(find.textContaining('m'), findsWidgets);
    });

    testWidgets(
      'type "5 miles" in input, "km" in output → shows converted value',
      (tester) async {
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

        // 5 miles ≈ 8.04672 km
        expect(find.textContaining('8.04672'), findsOneWidget);
        expect(find.textContaining('km'), findsWidgets);
      },
    );

    testWidgets('type "5 ft + 3 kg" → shows dimension error', (tester) async {
      await tester.pumpWidget(buildApp());

      await tester.enterText(
        find.widgetWithText(TextField, 'Convert from'),
        '5 ft + 3 kg',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('type invalid syntax → shows parse error', (tester) async {
      await tester.pumpWidget(buildApp());

      await tester.enterText(
        find.widgetWithText(TextField, 'Convert from'),
        '5 * *',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('change precision in settings → result formatting updates', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp());

      // Evaluate something first.
      await tester.enterText(
        find.widgetWithText(TextField, 'Convert from'),
        '1 mile',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      // Default precision 8: 1609.344 m
      expect(find.textContaining('1609.344'), findsOneWidget);

      // Navigate to settings.
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Change precision to 2.
      await tester.tap(find.text('8'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('2').last);
      await tester.pumpAndSettle();

      // Go back to freeform.
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Re-evaluate.
      await tester.enterText(
        find.widgetWithText(TextField, 'Convert from'),
        '1 mile',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      // Precision 2 (sig figs): 1.6e+3 m
      expect(find.textContaining('1.6e+3'), findsOneWidget);
    });

    testWidgets('toggle dark mode → theme changes', (tester) async {
      await tester.pumpWidget(buildApp());

      // Navigate to settings.
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Select dark mode radio.
      await tester.tap(find.text('Dark mode'));
      await tester.pumpAndSettle();

      // Verify the MaterialApp has dark theme mode.
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.themeMode, ThemeMode.dark);
    });

    testWidgets('switch to on-submit mode → typing no longer auto-evaluates', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp());

      // Navigate to settings.
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Switch to on-submit mode.
      await tester.tap(find.text('On submit'));
      await tester.pumpAndSettle();

      // Go back.
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Type something.
      await tester.enterText(
        find.widgetWithText(TextField, 'Convert from'),
        '5',
      );
      await tester.pump(const Duration(milliseconds: 600));

      // Should still show idle.
      expect(find.text('Enter an expression'), findsOneWidget);

      // Evaluate button should be present.
      expect(find.widgetWithText(ElevatedButton, 'Evaluate'), findsOneWidget);
    });

    testWidgets('conversion with non-conformable units shows error', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp());

      await tester.enterText(
        find.widgetWithText(TextField, 'Convert from'),
        '5 ft',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Convert to (optional)'),
        'kg',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });
  });
}
