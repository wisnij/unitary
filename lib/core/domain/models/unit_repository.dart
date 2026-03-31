import '../data/builtin_functions.dart';
import '../data/predefined_units.dart';
import '../services/unit_resolver.dart';
import 'dimension.dart';
import 'function.dart';
import 'quantity.dart';
import 'unit.dart';

/// Describes a unit or function whose dimension is conformable with a query.
///
/// Returned by [UnitRepository.findConformable].  Exactly one of
/// [definitionExpression], [functionLabel], and [aliasFor] may be non-null;
/// all are null for primitive units.
class ConformableEntry {
  /// Primary registration name of the unit or function.
  final String name;

  /// Definition expression of a [DerivedUnit] (e.g. `'4.184 J'`), or null
  /// for primitive units, functions, and aliases.
  final String? definitionExpression;

  /// Bracketed type label for function entries (`'[function]'` or
  /// `'[piecewise linear function]'`), or null for unit and alias entries.
  final String? functionLabel;

  /// Primary ID of the unit or function this name is an alias for, or null
  /// if this entry is not an alias.
  final String? aliasFor;

  const ConformableEntry({
    required this.name,
    this.definitionExpression,
    this.functionLabel,
    this.aliasFor,
  });
}

/// Result of a unit lookup that may include a prefix.
class UnitMatch {
  /// The prefix unit, if the name was split into prefix + base.
  final PrefixUnit? prefix;

  /// The matched unit.
  final Unit? unit;

  const UnitMatch({this.prefix, this.unit});
}

/// Registry for unit definitions and function definitions.  Provides lookup
/// by name/alias with automatic plural stripping fallback for units.
///
/// Note: despite the name, this registry also holds [UnitaryFunction] objects
/// (see [registerFunction] / [findFunction]).  A rename to a broader name is
/// deferred to a future refactor.
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

  /// All registered functions by their primary ID.
  final Map<String, UnitaryFunction> _functions = {};

  /// Maps every function name (id + aliases) to its function.
  final Map<String, UnitaryFunction> _functionLookup = {};

  /// Lazy cache of resolved quantities keyed by unit primary ID.
  ///
  /// A `null` value means the unit failed to resolve (circular definition,
  /// unsupported expression, etc.) and should be excluded from conformable
  /// results.  The entry is absent until the unit has been resolved at least
  /// once.
  final Map<String, Quantity?> _resolvedQuantityCache = {};

  /// Creates an empty repository.
  UnitRepository();

  /// Creates a repository pre-loaded with the predefined unit set and all
  /// built-in functions.
  factory UnitRepository.withPredefinedUnits() {
    final repo = UnitRepository();
    registerBuiltinFunctions(repo);
    registerPredefinedUnits(repo);
    registerPiecewiseFunctions(repo);
    registerDefinedFunctions(repo);
    return repo;
  }

  /// Register a unit.  Adds the unit's id and all aliases to the
  /// lookup map.  Throws [ArgumentError] if any name collides with
  /// an existing unit, prefix, or function entry.
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
      if (_functionLookup.containsKey(name)) {
        throw ArgumentError(
          "Unit name '$name' conflicts with registered function "
          "'${_functionLookup[name]!.id}'",
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

  /// Register a function.  Adds the function's id and all aliases to the
  /// lookup map.  Throws [ArgumentError] if any name collides with an
  /// existing function, unit, or prefix entry.
  void registerFunction(UnitaryFunction f) {
    _functions[f.id] = f;
    for (final name in f.allNames) {
      if (_functionLookup.containsKey(name)) {
        throw ArgumentError(
          "Function name '$name' is already registered "
          "(for function '${_functionLookup[name]!.id}')",
        );
      }
      if (_unitLookup.containsKey(name)) {
        throw ArgumentError(
          "Function name '$name' conflicts with registered unit "
          "'${_unitLookup[name]!.id}'",
        );
      }
      if (_prefixLookup.containsKey(name)) {
        throw ArgumentError(
          "Function name '$name' conflicts with registered prefix "
          "'${_prefixLookup[name]!.id}'",
        );
      }
      _functionLookup[name] = f;
    }
  }

  /// Look up a function by exact name.
  ///
  /// Returns the function registered under [name], or null if no function
  /// is registered under that name.  No prefix splitting or plural stripping
  /// is performed.
  UnitaryFunction? findFunction(String name) => _functionLookup[name];

  /// Exact lookup in regular units only.
  Unit? _findExact(String name) => _unitLookup[name];

  /// Tries plural-stripped variants of [name] against [lookup].
  ///
  /// Tries shorter suffixes before longer ones: `s` before `es` before
  /// `ies→y`. This avoids false matches like `miles` → `mil` (0.001 inch)
  /// when the correct result is `mile` (statute mile) via simple `s` removal.
  static T? _findPluralIn<T>(String name, Map<String, T> lookup) {
    if (name.length > 2 && name.endsWith('s')) {
      final found = lookup[name.substring(0, name.length - 1)];
      if (found != null) {
        return found;
      }
    }
    if (name.length > 3 && name.endsWith('es')) {
      final found = lookup[name.substring(0, name.length - 2)];
      if (found != null) {
        return found;
      }
    }
    if (name.length > 4 && name.endsWith('ies')) {
      final found = lookup['${name.substring(0, name.length - 3)}y'];
      if (found != null) {
        return found;
      }
    }
    return null;
  }

  /// Plural-stripping lookup in regular units only.
  Unit? _findPlural(String name) => _findPluralIn(name, _unitLookup);

  /// Look up a prefix by any recognized name.
  ///
  /// Tries exact match first, then falls back to plural stripping
  /// (removes trailing 'ies', 'es', or 's').  Returns null if not found.
  PrefixUnit? findPrefix(String name) {
    return _prefixLookup[name] ?? _findPluralIn(name, _prefixLookup);
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

  /// All registered functions (by primary ID).
  Iterable<UnitaryFunction> get allFunctions => _functions.values;

  /// IDs of all registered dimensionless primitive units.
  Set<String> get dimensionlessIds => Set.unmodifiable(_dimensionlessIds);

  /// Returns all registered units and functions whose dimension is conformable
  /// with [target], sorted case-insensitively by name.
  ///
  /// Each registered primary unit (excluding [PrefixUnit]) is resolved to its
  /// base-unit [Quantity]; the result is cached for subsequent calls.  Units
  /// that throw during resolution are silently excluded.
  ///
  /// Functions are included when their [UnitaryFunction.range] has a
  /// [QuantitySpec.quantity] whose dimension equals [target].  Functions with
  /// no range constraint are excluded.
  List<ConformableEntry> findConformable(Dimension target) {
    final results = <ConformableEntry>[];

    for (final unit in _units.values) {
      if (unit is PrefixUnit) {
        continue;
      }

      final Quantity? resolved;
      if (_resolvedQuantityCache.containsKey(unit.id)) {
        resolved = _resolvedQuantityCache[unit.id];
      } else {
        Quantity? q;
        try {
          q = resolveUnit(unit, this);
        } catch (_) {
          q = null;
        }
        _resolvedQuantityCache[unit.id] = q;
        resolved = q;
      }

      if (resolved == null || resolved.dimension != target) {
        continue;
      }

      final expression = unit is DerivedUnit ? unit.expression : null;
      results.add(
        ConformableEntry(name: unit.id, definitionExpression: expression),
      );
      for (final alias in unit.aliases) {
        results.add(
          ConformableEntry(
            name: alias,
            definitionExpression: expression,
            aliasFor: unit.id,
          ),
        );
      }
    }

    for (final func in _functions.values) {
      final rangeDim = func.range?.quantity?.dimension;
      if (rangeDim == null || rangeDim != target) {
        continue;
      }

      final label = func is PiecewiseFunction
          ? '[piecewise linear function]'
          : '[function]';
      results.add(ConformableEntry(name: func.id, functionLabel: label));
      for (final alias in func.aliases) {
        results.add(
          ConformableEntry(
            name: alias,
            functionLabel: label,
            aliasFor: func.id,
          ),
        );
      }
    }

    results.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
    return results;
  }
}
