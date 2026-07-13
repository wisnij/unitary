import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:unitary/features/freeform/data/freeform_history_repository.dart';
import 'package:unitary/features/freeform/presentation/freeform_screen.dart';
import 'package:unitary/features/freeform/state/freeform_history_provider.dart';
import 'package:unitary/features/settings/data/settings_repository.dart';
import 'package:unitary/features/settings/state/settings_provider.dart';

import '../../../shared/rebuild_counter.dart';

// Pins the freeform rebuild bound observed in the July 13, 2026 DevTools
// rebuild-tracking pass (see openspec/changes/performance-measurement/
// measurements.md): one keystroke triggers at most two rebuilds of the
// FreeformScreen subtree — one immediate (button-state setState) and one when
// the debounced evaluation result arrives.  The whole-subtree scope itself is
// a recorded follow-up finding (freeform-notifier refactor), so these tests
// assert only the upper bound, which a narrowing refactor would still pass.

void main() {
  late SettingsRepository settingsRepo;
  late FreeformHistoryRepository historyRepo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    settingsRepo = SettingsRepository(prefs);
    historyRepo = FreeformHistoryRepository(prefs);
  });

  Widget buildApp() {
    return ProviderScope(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(settingsRepo),
        freeformHistoryRepositoryProvider.overrideWithValue(historyRepo),
      ],
      child: MaterialApp(
        home: FreeformScreen(onNavigate: (_) {}),
      ),
    );
  }

  testWidgets('one keystroke rebuilds the freeform screen at most twice '
      '(immediate + debounced evaluation)', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    // Focus the field first so focus changes are not part of the count.
    final inputField = find.widgetWithText(TextField, 'Convert from');
    await tester.tap(inputField);
    await tester.pumpAndSettle();

    final counter = RebuildCounter()..install(tester);
    addTearDown(() => counter.uninstall(tester));

    // One text-change event, then let the debounce fire and settle.
    await tester.enterText(inputField, '5 ft');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    expect(
      counter.of('FreeformScreen'),
      lessThanOrEqualTo(2),
      reason:
          'a keystroke must not trigger rebuild storms; '
          'observed bound is one immediate + one debounced rebuild',
    );
  });

  testWidgets(
    'the debounced evaluation causes at most one additional rebuild',
    (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      final inputField = find.widgetWithText(TextField, 'Convert from');
      await tester.tap(inputField);
      await tester.pumpAndSettle();

      final counter = RebuildCounter()..install(tester);
      addTearDown(() => counter.uninstall(tester));

      await tester.enterText(inputField, '5 ft');
      await tester.pump();
      final buildsBeforeDebounce = counter.of('FreeformScreen');

      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      expect(
        counter.of('FreeformScreen') - buildsBeforeDebounce,
        lessThanOrEqualTo(1),
        reason:
            'the arriving evaluation result rebuilds the screen at most once',
      );
    },
  );
}
