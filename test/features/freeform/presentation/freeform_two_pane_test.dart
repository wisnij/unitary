import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:unitary/features/freeform/data/freeform_history_repository.dart';
import 'package:unitary/features/freeform/presentation/freeform_screen.dart';
import 'package:unitary/features/freeform/state/freeform_history_provider.dart';
import 'package:unitary/features/settings/data/settings_repository.dart';
import 'package:unitary/features/settings/state/settings_provider.dart';

void main() {
  late SettingsRepository settingsRepo;
  late FreeformHistoryRepository historyRepo;

  const entry0 = FreeformHistoryEntry(
    from: '5 miles',
    to: 'km',
    result: '8.04672 km',
  );
  // No result → its history label is just the "from" text.
  const entry1 = FreeformHistoryEntry(from: '1 ft', to: '');

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    settingsRepo = SettingsRepository(prefs);
    historyRepo = FreeformHistoryRepository(prefs);
  });

  Future<void> seed(List<FreeformHistoryEntry> entries) =>
      historyRepo.save(entries);

  Widget buildApp() {
    return ProviderScope(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(settingsRepo),
        freeformHistoryRepositoryProvider.overrideWithValue(historyRepo),
      ],
      child: MaterialApp(home: FreeformScreen(onNavigate: (_) {})),
    );
  }

  Future<void> pump(WidgetTester tester, Size size) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = size;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
  }

  const compact = Size(400, 800);
  const expanded = Size(1200, 800);

  group('History pane at wide widths', () {
    testWidgets('history is shown in a side pane, not the AppBar button', (
      tester,
    ) async {
      await seed([entry0, entry1]);
      await pump(tester, expanded);

      expect(find.text('History'), findsOneWidget); // pane header
      expect(find.text('5 miles = 8.04672 km'), findsOneWidget);
      expect(
        find.widgetWithIcon(IconButton, Icons.history),
        findsNothing,
      );
    });

    testWidgets('pane lists entries in order', (tester) async {
      await seed([entry0, entry1]);
      await pump(tester, expanded);

      final y0 = tester.getTopLeft(find.text('5 miles = 8.04672 km')).dy;
      final y1 = tester.getTopLeft(find.text('1 ft')).dy;
      expect(y0, lessThan(y1));
    });

    testWidgets('empty history shows an empty-state message', (tester) async {
      await pump(tester, expanded);
      expect(find.text('No history yet'), findsOneWidget);
    });

    testWidgets('tapping a pane entry restores both fields', (tester) async {
      await seed([entry0]);
      await pump(tester, expanded);

      await tester.tap(find.text('5 miles = 8.04672 km'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(TextField, '5 miles'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'km'), findsOneWidget);
    });
  });

  group('History button at compact width', () {
    testWidgets('AppBar history button is shown and enabled when non-empty', (
      tester,
    ) async {
      await seed([entry0]);
      await pump(tester, compact);

      final button = find.widgetWithIcon(IconButton, Icons.history);
      expect(button, findsOneWidget);
      expect(find.text('History'), findsNothing); // no pane at compact
      expect(tester.widget<IconButton>(button).onPressed, isNotNull);
    });

    testWidgets('AppBar history button is disabled when history empty', (
      tester,
    ) async {
      await pump(tester, compact);

      final iconButton = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.history),
      );
      expect(iconButton.onPressed, isNull);
    });

    testWidgets('tapping the button opens a modal with the same entries', (
      tester,
    ) async {
      await seed([entry0, entry1]);
      await pump(tester, compact);

      await tester.tap(find.widgetWithIcon(IconButton, Icons.history));
      await tester.pumpAndSettle();

      expect(find.text('5 miles = 8.04672 km'), findsOneWidget);
      expect(find.text('1 ft'), findsOneWidget);
    });
  });
}
