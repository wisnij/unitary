import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/domain/models/currency_descriptor.dart';
import '../../../core/domain/models/unit.dart';

const _kPrefsKey = 'currencyRates';

/// A single stored rate entry: the USD value of one unit and the source date.
class CurrencyRateEntry {
  /// The raw API rate as returned by Frankfurter (units per USD, or troy ounces per USD for precious metals).
  final double rate;

  /// Source date string from the Frankfurter API (e.g. '2026-06-06').
  final String date;

  const CurrencyRateEntry({required this.rate, required this.date});

  Map<String, Object> toJson() => {'rate': rate, 'date': date};

  static CurrencyRateEntry fromJson(Map<Object?, Object?> json) {
    return CurrencyRateEntry(
      rate: (json['rate'] as num).toDouble(),
      date: json['date'] as String,
    );
  }
}

/// The full set of persisted currency rates.
class CurrencyRates {
  /// When the last successful fetch was performed (UTC).
  final DateTime updatedAt;

  /// Stored rates keyed by unit ID (e.g. 'euro', 'goldprice').
  final Map<String, CurrencyRateEntry> rates;

  const CurrencyRates({required this.updatedAt, required this.rates});

  Map<String, Object> toJson() => {
    'updatedAt': updatedAt.toUtc().toIso8601String(),
    'rates': {for (final e in rates.entries) e.key: e.value.toJson()},
  };

  static CurrencyRates fromJson(Map<Object?, Object?> json) {
    final updatedAt = DateTime.parse(json['updatedAt'] as String).toUtc();
    final rawRates = json['rates'] as Map<Object?, Object?>;
    final rates = {
      for (final e in rawRates.entries)
        e.key as String: CurrencyRateEntry.fromJson(
          e.value as Map<Object?, Object?>,
        ),
    };
    return CurrencyRates(updatedAt: updatedAt, rates: rates);
  }
}

/// Persists and loads currency exchange rates from [SharedPreferences].
///
/// Rates are stored as a single JSON blob under the key [_kPrefsKey].
/// The [load] method returns null if no rates have been saved or if the stored
/// data is malformed.  [save] writes a complete [CurrencyRates] snapshot,
/// replacing any previous value.
class CurrencyRateRepository {
  final SharedPreferences _prefs;

  CurrencyRateRepository(this._prefs);

  /// Loads stored rates.  Returns null if none are available or the data is
  /// malformed.
  CurrencyRates? load() {
    final raw = _prefs.getString(_kPrefsKey);
    if (raw == null) {
      return null;
    }
    try {
      final json = jsonDecode(raw) as Map<Object?, Object?>;
      return CurrencyRates.fromJson(json);
    } on Exception {
      return null;
    }
  }

  /// Persists [rates] to SharedPreferences.
  Future<void> save(CurrencyRates rates) async {
    await _prefs.setString(_kPrefsKey, jsonEncode(rates.toJson()));
  }

  /// Returns the [CurrencyDescriptor] in [descriptors] that corresponds to
  /// [unit], or null if [unit] does not represent a live currency rate.
  ///
  /// A descriptor matches when either its [CurrencyDescriptor.originalUnit]
  /// has the same primary ID as [unit], or [unit]'s aliases contain the
  /// descriptor's [CurrencyDescriptor.isoCode].  The latter case covers
  /// precious-metal "ounce" units (e.g. `goldounce`/`XAU`), whose stored rate
  /// lives under an intermediate price unit (`goldprice`).
  ///
  /// Performs no I/O; does not require any rates to have been loaded.
  static CurrencyDescriptor? descriptorForUnit(
    Unit unit,
    List<CurrencyDescriptor> descriptors,
  ) {
    for (final d in descriptors) {
      if (d.originalUnit.id == unit.id || unit.aliases.contains(d.isoCode)) {
        return d;
      }
    }
    return null;
  }

  /// Returns the source date string for [unit], or null if no rate data is
  /// available for it.
  ///
  /// Uses [descriptorForUnit] to find the matching descriptor, then returns
  /// the stored date for that descriptor's [CurrencyDescriptor.unitId].
  String? lastUpdatedForUnit(Unit unit, List<CurrencyDescriptor> descriptors) {
    final descriptor = descriptorForUnit(unit, descriptors);
    if (descriptor == null) {
      return null;
    }
    return load()?.rates[descriptor.unitId]?.date;
  }
}
