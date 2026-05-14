import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// A single freeform history entry capturing the (from, to) field values at
/// the moment a successful evaluation was produced.
class FreeformHistoryEntry {
  final String from;
  final String to;

  const FreeformHistoryEntry({required this.from, required this.to});

  Map<String, Object> toJson() => {'from': from, 'to': to};

  static FreeformHistoryEntry fromJson(Map<Object?, Object?> json) {
    return FreeformHistoryEntry(
      from: json['from'] as String,
      to: json['to'] as String,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is FreeformHistoryEntry && other.from == from && other.to == to;

  @override
  int get hashCode => Object.hash(from, to);
}

/// Persists the freeform history list to [SharedPreferences] as a single
/// JSON-encoded key.
class FreeformHistoryRepository {
  final SharedPreferences _prefs;

  static const prefsKey = 'freeformHistory';
  static const maxEntries = 100;

  FreeformHistoryRepository(this._prefs);

  /// Loads the history list from storage.
  ///
  /// Returns an empty list if no data is stored or the data is malformed.
  /// Individual entries with invalid structure are silently dropped.
  List<FreeformHistoryEntry> load() {
    final json = _prefs.getString(prefsKey);
    if (json == null) {
      return [];
    }
    try {
      final decoded = jsonDecode(json) as List<Object?>;
      final entries = <FreeformHistoryEntry>[];
      for (final item in decoded) {
        if (item is Map<Object?, Object?>) {
          try {
            entries.add(FreeformHistoryEntry.fromJson(item));
          } catch (_) {
            // Skip malformed entries.
          }
        }
      }
      return entries;
    } catch (_) {
      return [];
    }
  }

  /// Saves the history list to storage.
  ///
  /// Truncates to [maxEntries] before saving.
  Future<void> save(List<FreeformHistoryEntry> entries) async {
    final capped = entries.length > maxEntries
        ? entries.sublist(0, maxEntries)
        : entries;
    await _prefs.setString(
      prefsKey,
      jsonEncode(capped.map((e) => e.toJson()).toList()),
    );
  }
}
