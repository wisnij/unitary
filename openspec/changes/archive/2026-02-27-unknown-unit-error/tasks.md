## 1. Production Code

- [x] 1.1 In `lib/core/domain/parser/ast.dart`, change `UnitNode.evaluate()`: when `repo != null` and `findUnitWithPrefix` returns `unit == null`, throw `EvalException('Unknown unit: "$unitName"')` instead of returning `Quantity(1.0, Dimension({unitName: 1}))`
- [x] 1.2 Update the `UnitNode` class doc comment to remove the mention of raw-dimension fallback for unknown units

## 2. Tests

- [x] 2.1 In `test/core/domain/parser/evaluator_test.dart`, replace the test "unknown unit with repo falls back to raw dimension" with a test asserting that `EvalException` is thrown for an unrecognized unit name when a repo is provided
- [x] 2.2 Add a test asserting that `repo == null` mode still produces raw dimensions (Phase 1 behavior), if not already covered
- [x] 2.3 Run `flutter test --reporter failures-only` and confirm all 848 tests pass (or that any new failures in `builtin_units_test.dart` are investigated and `_knownEvalFailures` updated with a comment explaining the root cause)
