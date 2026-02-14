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

/// A unit defined by an expression in terms of other units.
///
/// The expression string is evaluated lazily via ExpressionParser when the
/// unit is referenced during evaluation.  This class is immutable and
/// const-constructible.
class CompoundDefinition extends UnitDefinition {
  /// The expression string (e.g., 'kg m / s^2', '1000 m', '3.141592653589793').
  final String expression;

  const CompoundDefinition({required this.expression});

  @override
  Quantity toQuantity(double value, UnitRepository repo) {
    throw UnsupportedError(
      'CompoundDefinition.toQuantity() is not supported. '
      'Use ExpressionParser to evaluate the expression instead.',
    );
  }

  @override
  bool get isPrimitive => false;
}
