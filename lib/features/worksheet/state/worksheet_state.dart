/// The in-memory state for the worksheet feature.
///
/// [worksheetId] is the currently displayed template.
/// [activeRowIndex] is the row the user most recently typed in (null = no
/// keystroke yet since the app started or since the last [clear]).
/// [worksheetValues] maps each template id to its list of display strings.
/// Entries are lazy: a missing key means all rows for that template are blank.
class WorksheetState {
  final String worksheetId;
  final int? activeRowIndex;
  final Map<String, List<String>> worksheetValues;

  const WorksheetState({
    required this.worksheetId,
    required this.activeRowIndex,
    required this.worksheetValues,
  });

  /// Returns the display values for the current worksheet, or an empty list if
  /// [rowCount] is 0 or the worksheet has never been edited.
  List<String> valuesFor(String id, int rowCount) {
    return worksheetValues[id] ?? List.filled(rowCount, '');
  }

  WorksheetState copyWith({
    String? worksheetId,
    int? activeRowIndex,
    bool clearActiveRow = false,
    Map<String, List<String>>? worksheetValues,
  }) {
    return WorksheetState(
      worksheetId: worksheetId ?? this.worksheetId,
      activeRowIndex: clearActiveRow
          ? null
          : (activeRowIndex ?? this.activeRowIndex),
      worksheetValues: worksheetValues ?? this.worksheetValues,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorksheetState &&
          worksheetId == other.worksheetId &&
          activeRowIndex == other.activeRowIndex &&
          _mapsEqual(worksheetValues, other.worksheetValues);

  @override
  int get hashCode => Object.hash(
    worksheetId,
    activeRowIndex,
    Object.hashAll(
      worksheetValues.entries.map(
        (e) => Object.hash(e.key, Object.hashAll(e.value)),
      ),
    ),
  );

  static bool _mapsEqual(
    Map<String, List<String>> a,
    Map<String, List<String>> b,
  ) {
    if (a.length != b.length) {
      return false;
    }
    for (final key in a.keys) {
      if (!b.containsKey(key)) {
        return false;
      }
      final av = a[key]!;
      final bv = b[key]!;
      if (av.length != bv.length) {
        return false;
      }
      for (var i = 0; i < av.length; i++) {
        if (av[i] != bv[i]) {
          return false;
        }
      }
    }
    return true;
  }
}
