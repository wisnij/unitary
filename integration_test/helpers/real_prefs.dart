import 'package:shared_preferences/shared_preferences.dart';

import 'package:unitary/features/currency/data/currency_rate_repository.dart';

/// Seeds and clears the real, platform-channel-backed [SharedPreferences]
/// instance used under [IntegrationTestWidgetsFlutterBinding].
///
/// This is distinct from `test/helpers/repository_overrides.dart`'s
/// `TestRepositories`, which is built on the mocked
/// `SharedPreferences.setMockInitialValues` plugin used by ordinary
/// `flutter_test` widget tests. Integration tests run against the real
/// plugin (backed by browser `localStorage` on the `chrome` target), so
/// seeding state before calling `app.main()` must go through the real
/// `SharedPreferences.getInstance()` API instead.
class RealPrefs {
  RealPrefs._();

  /// Clears all stored preferences, leaving the app with no prior state.
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /// Seeds a currency-rates entry with `updatedAt` set to now, so that
  /// `CurrencyStatusNotifier.maybeRefresh()`'s 24-hour staleness check
  /// short-circuits on the next `app.main()` call and no real network
  /// request is made.
  ///
  /// Every integration test that calls `app.main()` must call this first —
  /// `UnitaryApp` unconditionally triggers a background refresh check on
  /// launch, and without a fresh stored timestamp that check would attempt
  /// a real HTTP request to the Frankfurter API. Pass [rates] to also seed
  /// specific per-currency entries (e.g. to test boot-time rehydration of
  /// the unit repository).
  static Future<void> seedFreshCurrencyTimestamp({
    Map<String, CurrencyRateEntry> rates = const {},
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await CurrencyRateRepository(
      prefs,
    ).save(CurrencyRates(updatedAt: DateTime.now().toUtc(), rates: rates));
  }
}
