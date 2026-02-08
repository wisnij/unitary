import 'dart:math' as math;

import '../errors.dart';
import '../models/dimension.dart';
import '../models/quantity.dart';
import '../models/unit.dart';
import '../models/unit_repository.dart';

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
    final baseFactor = unit.definition.toBase(1.0, repo);
    value *= math.pow(baseFactor, exponent);

    // Replace with primitive dimension entries.
    final baseDimension = unit.definition.getDimension(repo);
    for (final baseEntry in baseDimension.units.entries) {
      newDimension[baseEntry.key] =
          (newDimension[baseEntry.key] ?? 0) + baseEntry.value * exponent;
    }
  }

  return Quantity(value, Dimension(newDimension));
}

/// Convert a quantity to the specified target unit.
///
/// The quantity is first reduced to primitive base units, then converted
/// to the target unit using fromBase().
///
/// Throws [DimensionException] if the quantity's dimension is not
/// conformable with the target unit's dimension.
///
/// The returned Quantity has the target unit's primitive dimension
/// and a value expressed in the target unit.
Quantity convert(Quantity quantity, Unit targetUnit, UnitRepository repo) {
  final reduced = reduce(quantity, repo);

  final targetDimension = targetUnit.definition.getDimension(repo);
  if (!reduced.dimension.isConformableWith(targetDimension)) {
    throw DimensionException(
      'Cannot convert '
      '${reduced.dimension.canonicalRepresentation()} '
      'to ${targetUnit.id} '
      '(${targetDimension.canonicalRepresentation()})',
    );
  }

  final convertedValue = targetUnit.definition.fromBase(reduced.value, repo);
  return Quantity(convertedValue, targetDimension);
}
