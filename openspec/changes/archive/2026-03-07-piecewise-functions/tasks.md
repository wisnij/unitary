## 1. Import Pipeline — Parsing

- [x] 1.1 Add `outputUnit`, `noerror`, `yMin`, `yMax`, and `points` fields to `GnuEntry` in `import_gnu_units_lib.dart`
- [x] 1.2 Write tests in `test/tool/import_gnu_units_lib_test.dart` for piecewise parsing: id/outputUnit extraction, noerror detection, control-point pairs, yMin/yMax computation
- [x] 1.3 Replace the piecewise `unsupported` branch in `import_gnu_units_lib.dart` with a parser that extracts `id` (before `[`), `outputUnit` (between `[` and `]`), `noerror` flag, control points, and computes `yMin`/`yMax`

## 2. Import Pipeline — Serialization

- [x] 2.1 Write tests verifying piecewise entries are routed to the `"units"` JSON section (not `"unsupported"`) and serialized with the correct fields (`outputUnit`, `noerror`, `yMin`, `yMax`, `points`)
- [x] 2.2 Update `entriesToJson()` in `import_gnu_units_lib.dart` to emit `outputUnit`, `noerror`, `yMin`, `yMax`, and `points` for `type: "piecewise"` entries and route them to the `"units"` section

## 3. Regenerate units.json

- [x] 3.1 Run `dart run tool/import_gnu_units.dart` and verify the 28 formerly-unsupported piecewise entries now appear as `type: "piecewise"` in `units.json` with correct fields

## 4. PiecewiseFunction Model

- [x] 4.1 Write tests in `test/core/domain/models/function_test.dart` for `PiecewiseFunction`: `arity`, `hasInverse`, `range` spec, forward evaluation (exact points, interpolation, lower/upper boundary), out-of-range forward input
- [x] 4.2 Write tests for `PiecewiseFunction` inverse evaluation: monotonic case, non-monotonic smallest-x case, early throw for y below `yMin`, early throw for y above `yMax`, dimensionless return
- [x] 4.3 Implement `PiecewiseFunction` in `lib/core/domain/models/function.dart` with fields `points`, `outputFactor`, `outputDimension`, `yMin`, `yMax`, `noerror`; set `range` to `QuantitySpec(dimension: outputDimension, min: Bound(yMin * outputFactor, closed: true), max: Bound(yMax * outputFactor, closed: true))`
- [x] 4.4 Implement `evaluate()`: validate x ∈ `[points.first.$1, points.last.$1]`, binary-search for the enclosing segment, lerp, return `Quantity(y * outputFactor, outputDimension)`
- [x] 4.5 Implement `evaluateInverse()`: compute `yRaw = arg.value / outputFactor`, check `yRaw ∈ [yMin, yMax]` (throw early if not), scan all segments for containing segments, collect candidate x values, return smallest as a dimensionless `Quantity`

## 5. Codegen — Piecewise Emitter

- [x] 5.1 Write tests in `test/tool/generate_predefined_units_lib_test.dart` for piecewise codegen: verify a `type: "piecewise"` entry produces a `registerPiecewiseFunctions` function with a `PiecewiseFunction(...)` call registered via `repo.registerFunction()`, and does not emit a `repo.register()` call
- [x] 5.2 Implement the piecewise emitter in `tool/generate_predefined_units_lib.dart` that generates `registerPiecewiseFunctions(UnitRepository repo)` with `ExpressionParser(repo: repo).evaluate(outputUnit)` resolution and `PiecewiseFunction(...)` construction for each `type: "piecewise"` entry
- [x] 5.3 Call the piecewise emitter from `generateDartCode()` to include `registerPiecewiseFunctions` in the generated output

## 6. Regenerate predefined_units.dart and Wire Repository

- [x] 6.1 Add `import '../parser/parser.dart'` to the header imports emitted by `generateDartCode()` (needed by `registerPiecewiseFunctions` for `ExpressionParser`)
- [x] 6.2 Run `dart run tool/generate_predefined_units.dart` to regenerate `lib/core/domain/data/predefined_units.dart` with the new `registerPiecewiseFunctions` function
- [x] 6.3 Update `UnitRepository.withPredefinedUnits()` in `unit_repository.dart` to call `registerPiecewiseFunctions(repo)` after `registerBuiltinFunctions(repo)`

## 7. Integration Tests and Cleanup

- [x] 7.1 Remove all 28 piecewise entries from `_knownEvalFailures` in `test/core/domain/data/predefined_units_test.dart`
- [x] 7.2 Add an integration test verifying `gasmark` is registered as a `PiecewiseFunction` in `UnitRepository.withPredefinedUnits()` and produces the correct output for a known input (e.g. `gasmark(5)` ≈ 834.67 degR in kelvin)
- [x] 7.3 Run the full test suite (`flutter test --reporter failures-only`) and confirm all tests pass
