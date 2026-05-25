/// The kind of repository entry a [CompletionEntry] represents.
enum CompletionEntryKind {
  /// A registered unit (primitive or derived).
  unit,

  /// A registered SI or other named prefix.
  prefix,

  /// A registered function (builtin or defined).
  function,
}

/// A single entry in a predictive-completion suggestion list.
///
/// Returned by [UnitRepository.suggestCompletions].
class CompletionEntry {
  const CompletionEntry({
    required this.name,
    required this.isPrimaryId,
    required this.entryKind,
  });

  /// The identifier name that matched the completion prefix (may be a primary
  /// ID or an alias).
  final String name;

  /// Whether [name] is the primary ID of its entry (as opposed to an alias).
  ///
  /// Primary-ID matches are ranked before alias-only matches in the suggestion
  /// list.
  final bool isPrimaryId;

  /// The kind of repository entry this suggestion comes from.
  final CompletionEntryKind entryKind;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompletionEntry &&
          other.name == name &&
          other.isPrimaryId == isPrimaryId &&
          other.entryKind == entryKind;

  @override
  int get hashCode => Object.hash(name, isPrimaryId, entryKind);

  @override
  String toString() =>
      'CompletionEntry(name: $name, isPrimaryId: $isPrimaryId, '
      'entryKind: $entryKind)';
}
