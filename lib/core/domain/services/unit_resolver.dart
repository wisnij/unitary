import '../models/dimension.dart';
import '../models/quantity.dart';
import '../models/unit.dart';
import '../models/unit_definition.dart';
import '../models/unit_repository.dart';
import '../parser/expression_parser.dart';

/// Resolve a unit to its base-unit Quantity representation.
///
/// Returns the Quantity equivalent to 1 of the given [unit] expressed
/// in primitive base units.
Quantity resolveUnit(Unit unit, UnitRepository repo) {
  final def = unit.definition;
  if (def is PrimitiveUnitDefinition) {
    return Quantity(1.0, Dimension({unit.id: 1}));
  } else if (def is AffineDefinition) {
    final baseUnit = repo.getUnit(def.baseUnitId);
    final baseQuantity = resolveUnit(baseUnit, repo);
    return Quantity(def.factor * baseQuantity.value, baseQuantity.dimension);
  } else if (def is CompoundDefinition) {
    return ExpressionParser(repo: repo).evaluate(def.expression);
  }
  throw UnsupportedError('Unknown UnitDefinition type: ${def.runtimeType}');
}
