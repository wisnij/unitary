import 'package:riverpod/misc.dart' show Override;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:unitary/features/currency/data/currency_rate_repository.dart';
import 'package:unitary/features/currency/state/currency_provider.dart';
import 'package:unitary/features/freeform/data/freeform_history_repository.dart';
import 'package:unitary/features/freeform/state/freeform_history_provider.dart';
import 'package:unitary/features/settings/data/settings_repository.dart';
import 'package:unitary/features/settings/state/settings_provider.dart';
import 'package:unitary/features/worksheet/data/worksheet_repository.dart';
import 'package:unitary/features/worksheet/state/worksheet_provider.dart';

/// Default in-memory instances of the four must-override repositories
/// (`settings`, `worksheet`, `freeformHistory`, `currencyRate`), all backed
/// by a single mocked [SharedPreferences] instance, plus the [Override]s
/// needed to wire them into a `ProviderScope`/`ProviderContainer`.
///
/// Removes the need for tests to hand-roll
/// `SharedPreferences.setMockInitialValues` + repository construction +
/// override lists for these must-override providers.
class TestRepositories {
  final SharedPreferences prefs;
  final SettingsRepository settings;
  final WorksheetRepository worksheet;
  final FreeformHistoryRepository freeformHistory;
  final CurrencyRateRepository currencyRate;

  TestRepositories._({
    required this.prefs,
    required this.settings,
    required this.worksheet,
    required this.freeformHistory,
    required this.currencyRate,
  });

  /// Builds a fresh mocked [SharedPreferences] instance (seeded with
  /// [initialPrefs], empty by default) and constructs a default repository
  /// for each must-override provider from it.  [prefs] is exposed for the
  /// rare test that needs to write raw, possibly-malformed values directly
  /// (e.g. to test error handling for corrupted stored data).
  static Future<TestRepositories> create({
    Map<String, Object> initialPrefs = const {},
  }) async {
    SharedPreferences.setMockInitialValues(initialPrefs);
    final prefs = await SharedPreferences.getInstance();
    return TestRepositories._(
      prefs: prefs,
      settings: SettingsRepository(prefs),
      worksheet: WorksheetRepository(prefs),
      freeformHistory: FreeformHistoryRepository(prefs),
      currencyRate: CurrencyRateRepository(prefs),
    );
  }

  /// The [Override] for each must-override provider, pointing at this
  /// instance's repositories.
  List<Override> get overrides => [
    settingsRepositoryProvider.overrideWithValue(settings),
    worksheetRepositoryProvider.overrideWithValue(worksheet),
    freeformHistoryRepositoryProvider.overrideWithValue(freeformHistory),
    currencyRateRepositoryProvider.overrideWithValue(currencyRate),
  ];
}
