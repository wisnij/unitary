import '../models/dimension.dart';
import '../models/quantity.dart';
import '../models/unit.dart';
import '../models/unit_repository.dart';
import '../parser/expression_parser.dart';

/// Resolve a unit to its base-unit Quantity representation.
///
/// Returns the Quantity equivalent to 1 of the given [unit] expressed
/// in primitive base units.
Quantity resolveUnit(Unit unit, UnitRepository repo) {
  if (unit is PrimitiveUnit) {
    return Quantity(1.0, Dimension({unit.id: 1}));
  } else if (unit is AffineUnit) {
    final baseUnit = repo.getUnit(unit.baseUnitId);
    final baseQuantity = resolveUnit(baseUnit, repo);
    return Quantity(unit.factor * baseQuantity.value, baseQuantity.dimension);
  } else if (unit is CompoundUnit) {
    return ExpressionParser(repo: repo).evaluate(unit.expression);
  }
  throw UnsupportedError('Unknown Unit type: ${unit.runtimeType}');
}
