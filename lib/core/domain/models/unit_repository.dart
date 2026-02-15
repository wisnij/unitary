import '../data/builtin_units.dart';
import 'unit.dart';

/// Registry for unit definitions.  Provides lookup by name/alias with
/// automatic plural stripping fallback.
class UnitRepository {
  /// Maps every recognized name (id + aliases) to its Unit.
  final Map<String, Unit> _lookup = {};

  /// All registered units by their primary ID.
  final Map<String, Unit> _units = {};

  /// IDs of all dimensionless primitive units (radian, steradian, etc.).
  final Set<String> _dimensionlessIds = {};

  /// Creates an empty repository.
  UnitRepository();

  /// Creates a repository pre-loaded with the built-in unit set.
  factory UnitRepository.withBuiltinUnits() {
    final repo = UnitRepository();
    registerBuiltinUnits(repo);
    return repo;
  }

  /// Register a unit.  Adds the unit's id and all aliases to the
  /// lookup map.  Throws [ArgumentError] if any name collides with
  /// an existing entry.
  void register(Unit unit) {
    _units[unit.id] = unit;
    if (unit is PrimitiveUnit && unit.isDimensionless) {
      _dimensionlessIds.add(unit.id);
    }

    for (final name in unit.allNames) {
      if (_lookup.containsKey(name)) {
        throw ArgumentError(
          "Unit name '$name' is already registered "
          "(for unit '${_lookup[name]!.id}')",
        );
      }
      _lookup[name] = unit;
    }
  }

  /// Look up a unit by any recognized name.
  ///
  /// Tries exact match first, then falls back to plural stripping
  /// (removes trailing 'es' or 's').  Returns null if not found.
  Unit? findUnit(String name) {
    // Exact match.
    final exact = _lookup[name];
    if (exact != null) return exact;

    // Plural stripping: try 'es' first, then 's'.
    if (name.length > 2 && name.endsWith('es')) {
      final stripped = name.substring(0, name.length - 2);
      final found = _lookup[stripped];
      if (found != null) return found;
    }
    if (name.length > 1 && name.endsWith('s')) {
      final stripped = name.substring(0, name.length - 1);
      final found = _lookup[stripped];
      if (found != null) return found;
    }

    return null;
  }

  /// Look up a unit by any recognized name, throwing if not found.
  Unit getUnit(String name) {
    final unit = findUnit(name);
    if (unit == null) {
      throw ArgumentError("Unknown unit: '$name'");
    }
    return unit;
  }

  /// All registered units (by primary ID).
  Iterable<Unit> get allUnits => _units.values;

  /// IDs of all registered dimensionless primitive units.
  Set<String> get dimensionlessIds => Set.unmodifiable(_dimensionlessIds);
}
