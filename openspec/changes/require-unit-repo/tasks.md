## 1. Test Helper

- [ ] 1.1 Create `test/helpers/passthrough_unit_repository.dart` with a `PassthroughUnitRepository` class that extends `UnitRepository` and overrides `findUnit` and `findUnitWithPrefix` to return a synthetic `PrimitiveUnit` for any identifier
- [ ] 1.2 Add tests for `PassthroughUnitRepository` itself: any name returns a non-null `PrimitiveUnit`; evaluating `'5 wakalixes'` with it produces `Quantity(5.0, {'wakalixes': 1})`

## 2. Core Domain Changes

- [ ] 2.1 In `lib/core/domain/parser/ast.dart`, change `EvalContext.repo` from `UnitRepository?` to `UnitRepository` (non-nullable); remove the default value and update the constructor
- [ ] 2.2 In `lib/core/domain/parser/ast.dart`, remove the `if (repo == null)` branch from `UnitNode.evaluate()`, leaving only the repo-lookup path
- [ ] 2.3 In `lib/core/domain/parser/parser.dart`, make `repo` a required named parameter in `ExpressionParser`; remove the `?` from the field type and update the constructor signature
- [ ] 2.4 Update `EvalContext` and `UnitNode` doc comments to remove all references to null-repo / Phase 1 mode

## 3. Test Updates

- [ ] 3.1 Update the `eval()` test helper in `test/core/domain/parser/evaluator_test.dart` to pass `PassthroughUnitRepository()` as the repo (so pure arithmetic tests continue to work unchanged)
- [ ] 3.2 Delete the "null repo preserves Phase 1 behavior" test; add a replacement test "passthrough repo produces raw dimension" that uses `PassthroughUnitRepository` to document the same observable behavior
- [ ] 3.3 Update `test/core/domain/parser/expression_parser_test.dart`: replace the "evaluate without repo uses raw dimension (Phase 1 behavior)" test with a `PassthroughUnitRepository`-based equivalent
- [ ] 3.4 Find and update any remaining test sites that construct `EvalContext(...)` or `ExpressionParser()` without a repo

## 4. Verification

- [ ] 4.1 Run `flutter test --reporter failures-only` and confirm all tests pass with no regressions
