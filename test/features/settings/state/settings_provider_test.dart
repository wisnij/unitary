import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:unitary/features/settings/data/settings_repository.dart';
import 'package:unitary/features/settings/models/user_settings.dart';
import 'package:unitary/features/settings/state/settings_provider.dart';

void main() {
  group('SettingsNotifier', () {
    late ProviderContainer container;
    late SettingsRepository repository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      repository = SettingsRepository(prefs);

      container = ProviderContainer(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(repository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is defaults', () {
      final settings = container.read(settingsProvider);
      expect(settings, equals(UserSettings.defaults()));
    });

    test('initial state loads from repository', () async {
      SharedPreferences.setMockInitialValues({'precision': 8});
      final prefs = await SharedPreferences.getInstance();
      final repo = SettingsRepository(prefs);
      final c = ProviderContainer(
        overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(c.dispose);

      final settings = c.read(settingsProvider);
      expect(settings.precision, 8);
    });

    test('updatePrecision changes state', () {
      final notifier = container.read(settingsProvider.notifier);
      notifier.updatePrecision(4);
      expect(container.read(settingsProvider).precision, 4);
    });

    test('updateNotation changes state', () {
      final notifier = container.read(settingsProvider.notifier);
      notifier.updateNotation(Notation.scientific);
      expect(container.read(settingsProvider).notation, Notation.scientific);
    });

    test('updateDarkMode changes state to true', () {
      final notifier = container.read(settingsProvider.notifier);
      notifier.updateDarkMode(true);
      expect(container.read(settingsProvider).darkMode, true);
    });

    test('updateDarkMode changes state to null', () {
      final notifier = container.read(settingsProvider.notifier);
      notifier.updateDarkMode(true);
      notifier.updateDarkMode(null);
      expect(container.read(settingsProvider).darkMode, isNull);
    });

    test('updateEvaluationMode changes state', () {
      final notifier = container.read(settingsProvider.notifier);
      notifier.updateEvaluationMode(EvaluationMode.onSubmit);
      expect(
        container.read(settingsProvider).evaluationMode,
        EvaluationMode.onSubmit,
      );
    });

    test('updates persist to repository', () async {
      final notifier = container.read(settingsProvider.notifier);
      notifier.updatePrecision(3);

      // Allow async save to complete.
      await Future<void>.delayed(Duration.zero);

      final loaded = repository.load();
      expect(loaded.precision, 3);
    });
  });
}
