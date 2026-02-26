import '../data/builtin_units.dart';
import 'unit.dart';

/// Result of a unit lookup that may include a prefix.
class UnitMatch {
  /// The prefix unit, if the name was split into prefix + base.
  final PrefixUnit? prefix;

  /// The matched unit.
  final Unit? unit;

  const UnitMatch({this.prefix, this.unit});
}

/// Registry for unit definitions.  Provides lookup by name/alias with
/// automatic plural stripping fallback.
class UnitRepository {
  /// All registered units by their primary ID.
  final Map<String, Unit> _units = {};

  /// Maps every recognized name (id + aliases) to its Unit.
  final Map<String, Unit> _unitLookup = {};

  /// Prefix units by their primary ID.
  final Map<String, PrefixUnit> _prefixes = {};

  /// All prefix names (ids + aliases) mapped to the prefix.
  final Map<String, PrefixUnit> _prefixLookup = {};

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
      if (_unitLookup.containsKey(name)) {
        throw ArgumentError(
          "Unit name '$name' is already registered "
          "(for unit '${_unitLookup[name]!.id}')",
        );
      }
      _unitLookup[name] = unit;
    }
  }

  /// Register a prefix unit.  Prefixes are stored separately from regular
  /// units so that prefix symbols (like 'm' for milli) can coexist with
  /// regular unit IDs (like 'm' for meter).
  void registerPrefix(PrefixUnit prefix) {
    _prefixes[prefix.id] = prefix;
    for (final name in prefix.allNames) {
      if (_prefixLookup.containsKey(name)) {
        throw ArgumentError(
          "Prefix name '$name' is already registered "
          "(for prefix '${_prefixLookup[name]!.id}')",
        );
      }
      _prefixLookup[name] = prefix;
    }
  }

  /// Exact lookup in regular units only.
  Unit? _findExact(String name) => _unitLookup[name];

  /// Plural-stripping lookup in regular units only.
  ///
  /// Tries shorter suffixes before longer ones: `s` before `es` before
  /// `ies→y`. This avoids false matches like `miles` → `mil` (0.001 inch)
  /// when the correct result is `mile` (statute mile) via simple `s` removal.
  Unit? _findPlural(String name) {
    if (name.length > 2 && name.endsWith('s')) {
      final found = _findExact(name.substring(0, name.length - 1));
      if (found != null) {
        return found;
      }
    }
    if (name.length > 3 && name.endsWith('es')) {
      final found = _findExact(name.substring(0, name.length - 2));
      if (found != null) {
        return found;
      }
    }
    if (name.length > 4 && name.endsWith('ies')) {
      final found = _findExact('${name.substring(0, name.length - 3)}y');
      if (found != null) {
        return found;
      }
    }
    return null;
  }

  /// Look up a unit by any recognized name.
  ///
  /// Tries exact match first, then falls back to plural stripping
  /// (removes trailing 'ies', 'es', or 's').  Returns null if not found.
  Unit? findUnit(String name) {
    return _findExact(name) ?? _findPlural(name);
  }

  /// Look up a unit by name, with automatic prefix splitting.
  ///
  /// 1. Exact match in regular units → UnitMatch(unit: found)
  /// 2. Try each prefix (longest first): if name starts with prefix and
  ///    the remainder matches a regular unit, return both.
  /// 3. Standalone prefix match → UnitMatch(unit: prefix)
  /// 4. Plural stripping fallback → UnitMatch(unit: found)
  /// 5. No match → UnitMatch() (both null)
  ///
  /// Prefix splitting is tried before plural stripping so that names like
  /// "ms" resolve as milli + second rather than plural-stripping to "m".
  UnitMatch findUnitWithPrefix(String name) {
    // Try exact or plural match first.
    final found = findUnit(name);
    if (found != null) {
      return UnitMatch(unit: found);
    }

    // Try prefix splitting (longest prefix first).
    // Uses findUnit for the remainder so that plurals of the base unit
    // still work (e.g., "kilometers" → kilo + meters → kilo + meter).
    for (var len = name.length; len > 0; --len) {
      final prefixName = name.substring(0, len);
      final prefix = _prefixLookup[prefixName];
      if (prefix != null) {
        if (len == name.length) {
          // If the prefix is the entire name, return just the prefix
          return UnitMatch(unit: prefix);
        } else {
          // Otherwise, only return successfully if the remainder of the name
          // matches a unit
          final baseName = name.substring(prefixName.length);
          final baseUnit = findUnit(baseName);
          if (baseUnit != null) {
            return UnitMatch(prefix: prefix, unit: baseUnit);
          }
        }
      }
    }

    return const UnitMatch();
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

  /// All registered prefix units (by primary ID).
  Iterable<PrefixUnit> get allPrefixes => _prefixes.values;

  /// IDs of all registered dimensionless primitive units.
  Set<String> get dimensionlessIds => Set.unmodifiable(_dimensionlessIds);
}
