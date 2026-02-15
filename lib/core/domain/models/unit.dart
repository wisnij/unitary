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

  const Unit({required this.id, this.aliases = const [], this.description});

  /// Whether this is a primitive (base) unit.
  bool get isPrimitive => false;

  /// Whether this is an affine (temperature-style offset) unit.
  /// Affine units require function-call syntax: `tempF(212)` not `212 tempF`.
  bool get isAffine => false;

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

/// A unit defined by an affine transformation of another unit.
///
/// Computes `(value + offset) * factor` and passes the result through the
/// base unit.  Used for temperature scales where zero points differ.
///
/// For example: tempC has factor=1.0, offset=273.15, baseUnitId='K',
/// so tempC(100) = (100 + 273.15) * 1.0 = 373.15 K.
class AffineUnit extends Unit {
  /// Multiplicative factor applied after adding the offset.
  final double factor;

  /// Additive offset applied to the input value before scaling.
  final double offset;

  /// The ID of the base unit to resolve through.
  final String baseUnitId;

  const AffineUnit({
    required super.id,
    super.aliases,
    super.description,
    required this.factor,
    required this.offset,
    required this.baseUnitId,
  });

  @override
  bool get isAffine => true;
}

/// A unit defined by an expression in terms of other units.
///
/// The expression string is evaluated lazily via ExpressionParser when the
/// unit is referenced during evaluation.  This class is immutable and
/// const-constructible.
class CompoundUnit extends Unit {
  /// The expression string (e.g., 'kg m / s^2', '1000 m', '3.141592653589793').
  final String expression;

  const CompoundUnit({
    required super.id,
    super.aliases,
    super.description,
    required this.expression,
  });
}
