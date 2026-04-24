import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'predefined_worksheets.dart';

/// A single template's last-entered source row.
class WorksheetSourceEntry {
  final int rowIndex;
  final String text;

  const WorksheetSourceEntry({required this.rowIndex, required this.text});

  Map<String, Object> toJson() => {'rowIndex': rowIndex, 'text': text};

  static WorksheetSourceEntry fromJson(Map<Object?, Object?> json) {
    return WorksheetSourceEntry(
      rowIndex: (json['rowIndex'] as num).toInt(),
      text: json['text'] as String,
    );
  }
}

/// The data persisted for the worksheet feature across sessions.
class WorksheetPersistState {
  /// The ID of the active worksheet template.
  final String activeWorksheetId;

  /// Per-template last source row, keyed by template ID.
  final Map<String, WorksheetSourceEntry> sources;

  const WorksheetPersistState({
    required this.activeWorksheetId,
    required this.sources,
  });

  static WorksheetPersistState get defaults => const WorksheetPersistState(
    activeWorksheetId: 'length',
    sources: {},
  );

  Map<String, Object> toJson() => {
    'activeWorksheetId': activeWorksheetId,
    'sources': {
      for (final e in sources.entries) e.key: e.value.toJson(),
    },
  };

  static WorksheetPersistState fromJson(Map<Object?, Object?> json) {
    final activeId = json['activeWorksheetId'] as String? ?? 'length';
    final rawSources = json['sources'] as Map<Object?, Object?>? ?? {};
    final sources = <String, WorksheetSourceEntry>{};
    for (final e in rawSources.entries) {
      final key = e.key as String;
      final value = e.value as Map<Object?, Object?>;
      sources[key] = WorksheetSourceEntry.fromJson(value);
    }
    return WorksheetPersistState(
      activeWorksheetId: activeId,
      sources: sources,
    );
  }
}

/// Persists [WorksheetPersistState] to [SharedPreferences] as a single
/// JSON-encoded key.
class WorksheetRepository {
  final SharedPreferences _prefs;

  static const prefsKey = 'worksheetState';

  static final _knownTemplateIds = predefinedWorksheets
      .map((t) => t.id)
      .toSet();

  WorksheetRepository(this._prefs);

  /// Loads worksheet persist state from storage.
  ///
  /// Falls back to [WorksheetPersistState.defaults] if no data is stored,
  /// the data is malformed, or the saved active ID is not a known template.
  WorksheetPersistState load() {
    final json = _prefs.getString(prefsKey);
    if (json == null) {
      return WorksheetPersistState.defaults;
    }
    try {
      final decoded = jsonDecode(json) as Map<Object?, Object?>;
      final state = WorksheetPersistState.fromJson(decoded);
      if (!_knownTemplateIds.contains(state.activeWorksheetId)) {
        return WorksheetPersistState(
          activeWorksheetId: 'length',
          sources: state.sources,
        );
      }
      return state;
    } catch (_) {
      return WorksheetPersistState.defaults;
    }
  }

  /// Saves worksheet persist state to storage.
  Future<void> save(WorksheetPersistState state) async {
    await _prefs.setString(prefsKey, jsonEncode(state.toJson()));
  }
}
