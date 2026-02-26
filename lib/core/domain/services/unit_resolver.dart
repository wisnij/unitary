import '../errors.dart';
import '../models/dimension.dart';
import '../models/quantity.dart';
import '../models/unit.dart';
import '../models/unit_repository.dart';
import '../parser/expression_parser.dart';

/// Resolve a unit to its base-unit Quantity representation.
///
/// Returns the Quantity equivalent to 1 of the given [unit] expressed
/// in primitive base units.
///
/// [visited] is the set of unit IDs currently on the resolution stack.
/// It is threaded through recursive calls (and through [ExpressionParser])
/// so that any cycle is detected immediately and reported as an
/// [EvalException] rather than causing a stack overflow.
Quantity resolveUnit(Unit unit, UnitRepository repo, [Set<String>? visited]) {
  // Create a fresh mutable set when visited is null or empty (the latter may
  // be an unmodifiable const set from EvalContext's default).  Non-empty sets
  // are always mutable because they were created by a prior resolveUnit call.
  final seen = (visited == null || visited.isEmpty) ? <String>{} : visited;

  // Namespace-qualify the key so that a prefix and a regular unit that share
  // the same ID (e.g. PrefixUnit "US" and DerivedUnit "US") don't collide in
  // the visited set.  A prefix is defined in terms of the regular unit, not
  // itself, so they must be tracked independently.
  final key = unit is PrefixUnit ? '${unit.id}-' : unit.id;

  if (seen.contains(key)) {
    throw EvalException('Circular unit definition detected for "${unit.id}"');
  }

  seen.add(key);
  try {
    if (unit is PrimitiveUnit) {
      return Quantity(1.0, Dimension({unit.id: 1}));
    } else if (unit is AffineUnit) {
      final baseUnit = repo.getUnit(unit.baseUnitId);
      final baseQuantity = resolveUnit(baseUnit, repo, seen);
      return Quantity(unit.factor * baseQuantity.value, baseQuantity.dimension);
    } else if (unit is DerivedUnit) {
      return ExpressionParser(
        repo: repo,
        visited: seen,
      ).evaluate(unit.expression);
    }
    throw UnsupportedError('Unknown Unit type: ${unit.runtimeType}');
  } finally {
    seen.remove(key);
  }
}
