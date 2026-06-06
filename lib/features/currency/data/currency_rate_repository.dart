import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/domain/models/currency_descriptor.dart';

const _kPrefsKey = 'currencyRates';

/// A single stored rate entry: the USD value of one unit and the source date.
class CurrencyRateEntry {
  /// USD value of 1 unit (or USD per troy ounce for precious metals).
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

  /// Returns the source date string for [unitId], or null if no rate data is
  /// available for it.
  ///
  /// First checks for a direct key match in the stored rates.  If not found,
  /// walks [descriptors] to find any entry whose [CurrencyDescriptor.originalUnit]
  /// primary ID matches [unitId] and returns the date for that descriptor's
  /// [CurrencyDescriptor.unitId].
  String? lastUpdatedForUnit(
    String unitId,
    List<CurrencyDescriptor> descriptors,
  ) {
    final stored = load();
    if (stored == null) {
      return null;
    }

    final direct = stored.rates[unitId];
    if (direct != null) {
      return direct.date;
    }

    for (final d in descriptors) {
      if (d.originalUnit.id == unitId) {
        return stored.rates[d.unitId]?.date;
      }
    }
    return null;
  }
}
