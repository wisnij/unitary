import 'package:unitary/core/domain/models/unit.dart';
import 'package:unitary/core/domain/models/unit_repository.dart';

/// A [UnitRepository] that accepts any identifier and returns a synthetic
/// [PrimitiveUnit] for it.
///
/// Used in tests that exercise the parser/evaluator without a real unit
/// database.  Previously these tests used a null repo (Phase 1 mode); after
/// [EvalContext.repo] became non-nullable, this class preserves the same
/// observable behaviour: unknown names produce raw dimensions rather than
/// throwing [EvalException].
class PassthroughUnitRepository extends UnitRepository {
  @override
  Unit? findUnit(String name) => PrimitiveUnit(id: name);

  @override
  UnitMatch findUnitWithPrefix(String name) =>
      UnitMatch(unit: PrimitiveUnit(id: name));
}
