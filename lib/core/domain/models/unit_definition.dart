import 'dimension.dart';
import 'quantity.dart';
import 'unit_repository.dart';

/// Base class for unit definitions.
///
/// Provides the conversion contract: every definition can convert a value
/// to a [Quantity] expressed in primitive base units.
abstract class UnitDefinition {
  const UnitDefinition();

  /// Convert [value] in this unit to an equivalent [Quantity] in primitive
  /// base units.  May recurse through [repo] for chained definitions.
  Quantity toQuantity(double value, UnitRepository repo);

  /// Whether this is a primitive (base) unit definition.
  bool get isPrimitive;

  /// Whether this is an affine (temperature-style offset) unit definition.
  /// Affine units require function-call syntax: `tempF(212)` not `212 tempF`.
  bool get isAffine => false;
}

/// A primitive (base) unit that defines a fundamental dimension.
///
/// The unit's ID becomes its own dimension key.  For example, the meter
/// unit (id: 'm') has dimension {m: 1}.  toQuantity returns the value
/// unchanged with dimension {unitId: 1}.
class PrimitiveUnitDefinition extends UnitDefinition {
  /// The unit ID, used as the dimension key.  Set during registration.
  late final String _unitId;

  PrimitiveUnitDefinition();

  /// Called by UnitRepository during registration to bind the unit ID.
  void bind(String unitId) => _unitId = unitId;

  @override
  Quantity toQuantity(double value, UnitRepository repo) =>
      Quantity(value, Dimension({_unitId: 1}));

  @override
  bool get isPrimitive => true;
}

/// A unit defined as a linear multiple of another unit.
///
/// For example: 1 foot = 0.3048 meters, so feet has
/// LinearDefinition(factor: 0.3048, baseUnitId: 'm').
///
/// Chains are supported: 1 yard = 3 feet could be
/// LinearDefinition(factor: 3, baseUnitId: 'ft'), and resolution
/// recurses through feet to meters.
class LinearDefinition extends UnitDefinition {
  /// How many of [baseUnitId] equal one of this unit.
  /// i.e., `1 <this unit> = [factor] <baseUnit>`
  final double factor;

  /// The ID of the unit this is defined in terms of.
  final String baseUnitId;

  const LinearDefinition({required this.factor, required this.baseUnitId});

  @override
  Quantity toQuantity(double value, UnitRepository repo) {
    final baseUnit = repo.getUnit(baseUnitId);
    return baseUnit.definition.toQuantity(value * factor, repo);
  }

  @override
  bool get isPrimitive => false;
}

/// A unit defined by an affine transformation of another unit.
///
/// Computes `(value + offset) * factor` and passes the result through the
/// base unit.  Used for temperature scales where zero points differ.
///
/// For example: tempC has factor=1.0, offset=273.15, baseUnitId='K',
/// so tempC(100) = (100 + 273.15) * 1.0 = 373.15 K.
class AffineDefinition extends UnitDefinition {
  /// Multiplicative factor applied after adding the offset.
  final double factor;

  /// Additive offset applied to the input value before scaling.
  final double offset;

  /// The ID of the base unit to resolve through.
  final String baseUnitId;

  const AffineDefinition({
    required this.factor,
    required this.offset,
    required this.baseUnitId,
  });

  @override
  Quantity toQuantity(double value, UnitRepository repo) {
    final baseUnit = repo.getUnit(baseUnitId);
    return baseUnit.definition.toQuantity((value + offset) * factor, repo);
  }

  @override
  bool get isPrimitive => false;

  @override
  bool get isAffine => true;
}

/// A named constant with a fixed value and dimension.
///
/// For example: pi = ConstantDefinition(constantValue: 3.14159...,
/// dimension: dimensionless).  `toQuantity(2.0, repo)` returns 6.28318...
class ConstantDefinition extends UnitDefinition {
  /// The constant's numeric value.
  final double constantValue;

  /// The constant's fixed dimension.
  final Dimension _dimension;

  ConstantDefinition({
    required this.constantValue,
    required Dimension dimension,
  }) : _dimension = dimension;

  @override
  Quantity toQuantity(double value, UnitRepository repo) =>
      Quantity(value * constantValue, _dimension);

  @override
  bool get isPrimitive => false;
}

/// A unit defined by an expression in terms of other units.
///
/// The expression string is stored for reference.  Before use, `resolve()`
/// must be called with the pre-computed base [Quantity] (parsed and evaluated
/// by the caller).  `toQuantity()` then scales that cached quantity.
class CompoundDefinition extends UnitDefinition {
  /// The expression string (e.g., 'kg m / s^2').
  final String expression;

  Quantity? _baseQuantity;

  CompoundDefinition({required this.expression});

  /// Whether this definition has been resolved.
  bool get isResolved => _baseQuantity != null;

  /// Cache the pre-computed base quantity.  Must be called exactly once.
  void resolve(Quantity baseQuantity) {
    if (_baseQuantity != null) {
      throw StateError('CompoundDefinition already resolved: $expression');
    }
    _baseQuantity = baseQuantity;
  }

  @override
  Quantity toQuantity(double value, UnitRepository repo) {
    final base = _baseQuantity;
    if (base == null) {
      throw StateError('CompoundDefinition not yet resolved: $expression');
    }
    return Quantity(value * base.value, base.dimension);
  }

  @override
  bool get isPrimitive => false;
}
