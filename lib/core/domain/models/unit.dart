/// Abstract base class for all units of measurement.
///
/// Each unit has a unique [id] (its primary short name), a list of [aliases]
/// (alternative names), and subclass-specific fields that describe how to
/// convert values of this unit to/from primitive base units.
abstract class Unit {
  /// Primary identifier (e.g., 'm', 'ft', 'kg').
  final String id;

  /// Alternative names (e.g., ['meter', 'metre'] for 'm').
  /// Does NOT need to include regular plurals — those are handled by
  /// the repo's plural stripping fallback.  Irregular plurals (e.g.,
  /// 'feet' for 'foot') must be listed explicitly.
  final List<String> aliases;

  /// Human-readable description (e.g., 'SI base unit of length').
  final String? description;

  const Unit({
    required this.id,
    this.aliases = const [],
    this.description,
  });

  /// Whether this is a primitive (base) unit.
  bool get isPrimitive => false;

  /// Whether this is a prefix (e.g., kilo, milli).
  bool get isPrefix => false;

  /// All recognized names for this unit: id + aliases.
  List<String> get allNames => [id, ...aliases];
}

/// A primitive (base) unit that defines a fundamental dimension.
///
/// The unit's ID becomes its own dimension key.  For example, the meter
/// unit (id: 'm') has dimension {m: 1}.
class PrimitiveUnit extends Unit {
  /// Whether this unit is dimensionless in the SI sense (e.g., radian,
  /// steradian).  Dimensionless units carry a dimension during evaluation
  /// but can be stripped for conversion conformability checking.
  final bool isDimensionless;

  const PrimitiveUnit({
    required super.id,
    super.aliases,
    super.description,
    this.isDimensionless = false,
  });

  @override
  bool get isPrimitive => true;
}

/// A unit defined by an expression in terms of other units.
///
/// The expression string is evaluated lazily via ExpressionParser when the
/// unit is referenced during evaluation.  This class is immutable and
/// const-constructible.
class DerivedUnit extends Unit {
  /// The expression string (e.g., 'kg m / s^2', '1000 m', '3.141592653589793').
  final String expression;

  const DerivedUnit({
    required super.id,
    super.aliases,
    super.description,
    required this.expression,
  });
}

/// A unit prefix defined by a numeric expression (e.g., kilo = 1000).
///
/// Prefixes are stored separately in the repository and combined with
/// base units during lookup. For example, "kilometer" splits into
/// prefix "kilo" (1000) + base unit "meter".
class PrefixUnit extends DerivedUnit {
  const PrefixUnit({
    required super.id,
    super.aliases,
    super.description,
    required super.expression,
  });

  @override
  bool get isPrefix => true;
}
