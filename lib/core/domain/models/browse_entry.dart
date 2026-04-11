import 'dimension.dart';

/// The kind of entity a [BrowseEntry] represents.
enum BrowseEntryKind { unit, prefix, function }

/// A single row in the unit browser catalog.
///
/// Both primary entries and aliases produce a [BrowseEntry]; alias entries
/// have a non-null [aliasFor].  Tapping any entry navigates to the detail page
/// for [primaryId], so alias entries and their primary share the same detail
/// page.
class BrowseEntry {
  /// Display name for this row — either the primary ID or an alias name.
  final String name;

  /// Primary registration ID of the underlying unit, prefix, or function.
  final String primaryId;

  /// Whether this entry represents a unit, prefix, or function.
  final BrowseEntryKind kind;

  /// If non-null, this entry is an alias and [aliasFor] equals [primaryId].
  final String? aliasFor;

  /// One-line summary shown as the subtitle in the browse list.
  ///
  /// - Derived unit / prefix: definition expression (e.g. `4.184 J`)
  /// - Primitive unit: `[primitive unit]`
  /// - Non-piecewise function: `[function]`
  /// - Piecewise function: `[piecewise linear function]`
  final String summaryLine;

  /// Resolved output dimension of this entry; null if resolution failed.
  ///
  /// Entries with null [dimension] appear in the alphabetical view but are
  /// excluded from the dimension-grouped view.
  final Dimension? dimension;

  /// Formal parameter names for function entries; null for units and prefixes.
  ///
  /// Used to display function entries as `name(p1, p2)` in the browse list.
  final List<String>? params;

  const BrowseEntry({
    required this.name,
    required this.primaryId,
    required this.kind,
    this.aliasFor,
    required this.summaryLine,
    this.dimension,
    this.params,
  });

  /// Whether this entry is an alias of another entry.
  bool get isAlias => aliasFor != null;
}
