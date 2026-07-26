import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:unitary/features/settings/models/user_settings.dart';
import 'package:unitary/features/settings/state/settings_provider.dart';

import '../../../helpers/repository_overrides.dart';

void main() {
  group('SettingsNotifier', () {
    late TestRepositories repos;
    late ProviderContainer container;

    setUp(() async {
      repos = await TestRepositories.create();
      container = ProviderContainer(overrides: repos.overrides);
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is defaults', () {
      final settings = container.read(settingsProvider);
      expect(settings, equals(UserSettings.defaults()));
    });

    test('initial state loads from repository', () async {
      final seeded = await TestRepositories.create(
        initialPrefs: {'precision': 8},
      );
      final c = ProviderContainer(overrides: seeded.overrides);
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

    test('updateThemeMode changes state to dark', () {
      final notifier = container.read(settingsProvider.notifier);
      notifier.updateThemeMode(ThemePreference.dark);
      expect(container.read(settingsProvider).themeMode, ThemePreference.dark);
    });

    test('updateThemeMode changes state to light', () {
      final notifier = container.read(settingsProvider.notifier);
      notifier.updateThemeMode(ThemePreference.light);
      expect(
        container.read(settingsProvider).themeMode,
        ThemePreference.light,
      );
    });

    test('updateThemeMode changes state to system', () {
      final notifier = container.read(settingsProvider.notifier);
      notifier.updateThemeMode(ThemePreference.dark);
      notifier.updateThemeMode(ThemePreference.system);
      expect(
        container.read(settingsProvider).themeMode,
        ThemePreference.system,
      );
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

      final loaded = repos.settings.load();
      expect(loaded.precision, 3);
    });
  });
}
