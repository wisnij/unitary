import 'unit_definition.dart';

/// Represents a unit of measurement.
///
/// Each unit has a unique [id] (its primary short name), a list of [aliases]
/// (alternative names), and a [definition] that describes how to convert
/// values of this unit to/from primitive base units.
class Unit {
  /// Primary identifier (e.g., 'm', 'ft', 'kg').
  final String id;

  /// Alternative names (e.g., ['meter', 'metre'] for 'm').
  /// Does NOT need to include regular plurals — those are handled by
  /// the repo's plural stripping fallback.  Irregular plurals (e.g.,
  /// 'feet' for 'foot') must be listed explicitly.
  final List<String> aliases;

  /// Human-readable description (e.g., 'SI base unit of length').
  final String? description;

  /// How this unit converts to/from base units.
  final UnitDefinition definition;

  const Unit({
    required this.id,
    this.aliases = const [],
    this.description,
    required this.definition,
  });

  /// All recognized names for this unit: id + aliases.
  List<String> get allNames => [id, ...aliases];
}
