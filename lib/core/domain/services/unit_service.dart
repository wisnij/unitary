import 'dart:math' as math;

import '../models/dimension.dart';
import '../models/quantity.dart';
import '../models/unit_definition.dart';
import '../models/unit_repository.dart';
import '../parser/expression_parser.dart';

/// Reduce a quantity to primitive base units.
///
/// Each non-primitive unit name in the quantity's dimension is resolved
/// through the repository, and the value is multiplied/divided by the
/// appropriate conversion factors.
///
/// If the dimension already contains only primitive unit names, the
/// quantity is returned unchanged.  Unknown unit names are kept as-is.
///
/// Example:
///   reduce(Quantity(5.0, Dimension({ft: 1})), repo)
///   → Quantity(1.524, Dimension({m: 1}))
Quantity reduce(Quantity quantity, UnitRepository repo) {
  double value = quantity.value;
  final newDimension = <String, int>{};

  for (final entry in quantity.dimension.units.entries) {
    final unitName = entry.key;
    final exponent = entry.value;

    final unit = repo.findUnit(unitName);
    if (unit == null || unit.definition.isPrimitive) {
      // Already primitive or unknown — keep as-is.
      newDimension[unitName] = (newDimension[unitName] ?? 0) + exponent;
      continue;
    }

    // Resolve to base units.
    final Quantity baseQuantity;
    if (unit.definition is CompoundDefinition) {
      final expr = (unit.definition as CompoundDefinition).expression;
      baseQuantity = ExpressionParser(repo: repo).evaluate(expr);
    } else {
      baseQuantity = unit.definition.toQuantity(1.0, repo);
    }
    value *= math.pow(baseQuantity.value, exponent);

    // Replace with primitive dimension entries.
    for (final baseEntry in baseQuantity.dimension.units.entries) {
      newDimension[baseEntry.key] =
          (newDimension[baseEntry.key] ?? 0) + baseEntry.value * exponent;
    }
  }

  return Quantity(value, Dimension(newDimension));
}
