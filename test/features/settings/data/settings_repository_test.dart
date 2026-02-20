import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:unitary/features/settings/data/settings_repository.dart';
import 'package:unitary/features/settings/models/user_settings.dart';

void main() {
  group('SettingsRepository', () {
    late SettingsRepository repository;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    Future<SettingsRepository> createRepository() async {
      final prefs = await SharedPreferences.getInstance();
      return SettingsRepository(prefs);
    }

    test('load with no saved data returns defaults', () async {
      repository = await createRepository();
      final settings = repository.load();
      expect(settings, equals(UserSettings.defaults()));
    });

    test('save and load round-trip preserves all fields', () async {
      repository = await createRepository();
      final settings = UserSettings(
        precision: 4,
        notation: Notation.scientific,
        themeMode: ThemeMode.dark,
        evaluationMode: EvaluationMode.onSubmit,
      );
      await repository.save(settings);
      final loaded = repository.load();
      expect(loaded, equals(settings));
    });

    test('save and load preserves themeMode light', () async {
      repository = await createRepository();
      final settings = UserSettings(themeMode: ThemeMode.light);
      await repository.save(settings);
      final loaded = repository.load();
      expect(loaded.themeMode, ThemeMode.light);
    });

    test('save and load preserves themeMode system', () async {
      repository = await createRepository();
      final settings = UserSettings(themeMode: ThemeMode.system);
      await repository.save(settings);
      final loaded = repository.load();
      expect(loaded.themeMode, ThemeMode.system);
    });

    test('themeMode dark is stored as string "dark"', () async {
      repository = await createRepository();
      await repository.save(UserSettings(themeMode: ThemeMode.dark));
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('themeMode'), 'dark');
    });

    test('themeMode light is stored as string "light"', () async {
      repository = await createRepository();
      await repository.save(UserSettings(themeMode: ThemeMode.light));
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('themeMode'), 'light');
    });

    test('themeMode system is stored as string "system"', () async {
      repository = await createRepository();
      await repository.save(UserSettings(themeMode: ThemeMode.system));
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('themeMode'), 'system');
    });

    test('missing themeMode key falls back to ThemeMode.system', () async {
      SharedPreferences.setMockInitialValues({'precision': 4});
      repository = await createRepository();
      final settings = repository.load();
      expect(settings.themeMode, ThemeMode.system);
    });

    test('unknown themeMode string falls back to ThemeMode.system', () async {
      SharedPreferences.setMockInitialValues({'themeMode': 'invalid'});
      repository = await createRepository();
      final settings = repository.load();
      expect(settings.themeMode, ThemeMode.system);
    });

    test('load with partial data fills in defaults for missing keys', () async {
      SharedPreferences.setMockInitialValues({'precision': 4});
      repository = await createRepository();
      final settings = repository.load();
      expect(settings.precision, 4);
      expect(settings.notation, Notation.automatic);
      expect(settings.themeMode, ThemeMode.system);
      expect(settings.evaluationMode, EvaluationMode.realtime);
    });

    test('load with all notation values', () async {
      for (final notation in Notation.values) {
        SharedPreferences.setMockInitialValues({'notation': notation.name});
        repository = await createRepository();
        final settings = repository.load();
        expect(settings.notation, notation);
      }
    });

    test('load with all evaluationMode values', () async {
      for (final mode in EvaluationMode.values) {
        SharedPreferences.setMockInitialValues({'evaluationMode': mode.name});
        repository = await createRepository();
        final settings = repository.load();
        expect(settings.evaluationMode, mode);
      }
    });

    test('load with invalid notation falls back to default', () async {
      SharedPreferences.setMockInitialValues({'notation': 'invalid'});
      repository = await createRepository();
      final settings = repository.load();
      expect(settings.notation, Notation.automatic);
    });

    test('load with invalid evaluationMode falls back to default', () async {
      SharedPreferences.setMockInitialValues({'evaluationMode': 'invalid'});
      repository = await createRepository();
      final settings = repository.load();
      expect(settings.evaluationMode, EvaluationMode.realtime);
    });
  });
}
