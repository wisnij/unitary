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
  Quantity getQuantity(double value, UnitRepository repo);

  /// Whether this is a primitive (base) unit definition.
  bool get isPrimitive;
}

/// A primitive (base) unit that defines a fundamental dimension.
///
/// The unit's ID becomes its own dimension key.  For example, the meter
/// unit (id: 'm') has dimension {m: 1}.  getQuantity returns the value
/// unchanged with dimension {unitId: 1}.
class PrimitiveUnitDefinition extends UnitDefinition {
  /// The unit ID, used as the dimension key.  Set during registration.
  late final String _unitId;

  PrimitiveUnitDefinition();

  /// Called by UnitRepository during registration to bind the unit ID.
  void bind(String unitId) => _unitId = unitId;

  @override
  Quantity getQuantity(double value, UnitRepository repo) =>
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
  Quantity getQuantity(double value, UnitRepository repo) {
    final baseUnit = repo.getUnit(baseUnitId);
    return baseUnit.definition.getQuantity(value * factor, repo);
  }

  @override
  bool get isPrimitive => false;
}
