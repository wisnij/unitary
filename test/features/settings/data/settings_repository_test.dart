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
        darkMode: true,
        evaluationMode: EvaluationMode.onSubmit,
      );
      await repository.save(settings);
      final loaded = repository.load();
      expect(loaded, equals(settings));
    });

    test('save and load preserves darkMode false', () async {
      repository = await createRepository();
      final settings = UserSettings(darkMode: false);
      await repository.save(settings);
      final loaded = repository.load();
      expect(loaded.darkMode, false);
    });

    test('save and load preserves darkMode null', () async {
      repository = await createRepository();
      final settings = UserSettings(darkMode: null);
      await repository.save(settings);
      final loaded = repository.load();
      expect(loaded.darkMode, isNull);
    });

    test('load with partial data fills in defaults for missing keys', () async {
      SharedPreferences.setMockInitialValues({'precision': 8});
      repository = await createRepository();
      final settings = repository.load();
      expect(settings.precision, 8);
      expect(settings.notation, Notation.decimal);
      expect(settings.darkMode, isNull);
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
      expect(settings.notation, Notation.decimal);
    });

    test('load with invalid evaluationMode falls back to default', () async {
      SharedPreferences.setMockInitialValues({'evaluationMode': 'invalid'});
      repository = await createRepository();
      final settings = repository.load();
      expect(settings.evaluationMode, EvaluationMode.realtime);
    });
  });
}
