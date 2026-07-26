import 'package:flutter_test/flutter_test.dart';

import 'package:unitary/features/currency/state/currency_provider.dart';
import 'package:unitary/features/freeform/state/freeform_history_provider.dart';
import 'package:unitary/features/settings/models/user_settings.dart';
import 'package:unitary/features/settings/state/settings_provider.dart';
import 'package:unitary/features/worksheet/state/worksheet_provider.dart';

import 'repository_overrides.dart';

void main() {
  group('TestRepositories', () {
    test('default construction exposes all four repositories', () async {
      final repos = await TestRepositories.create();

      expect(repos.settings, isNotNull);
      expect(repos.worksheet, isNotNull);
      expect(repos.freeformHistory, isNotNull);
      expect(repos.currencyRate, isNotNull);
    });

    test('overrides contains exactly one Override per must-override '
        'provider, keyed to the right provider', () async {
      final repos = await TestRepositories.create();

      expect(repos.overrides, hasLength(4));
      final origins = repos.overrides.map((o) => o.origin).toSet();
      expect(
        origins,
        equals({
          settingsRepositoryProvider,
          worksheetRepositoryProvider,
          freeformHistoryRepositoryProvider,
          currencyRateRepositoryProvider,
        }),
      );
    });

    test('initialPrefs seeds the underlying SharedPreferences', () async {
      final repos = await TestRepositories.create(
        initialPrefs: {'precision': 5},
      );

      expect(repos.settings.load().precision, 5);
    });

    test('default construction uses UserSettings defaults', () async {
      final repos = await TestRepositories.create();

      expect(repos.settings.load(), UserSettings.defaults());
    });

    test('prefs exposes the same underlying SharedPreferences instance '
        'the repositories were built from', () async {
      final repos = await TestRepositories.create();

      await repos.prefs.setString('someKey', 'someValue');
      expect(repos.prefs.getString('someKey'), 'someValue');
    });
  });
}
