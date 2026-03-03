## Why

Built-in functions like `sin`, `sqrt`, and `ln` are currently hardcoded as a
`const Set<String>` in `ast.dart` with evaluation logic in a monolithic switch
statement. There is no registry, no inverse support, and no extensibility
path — making it impossible to add user-defined functions, migrate affine units
into the same abstraction, or support GNU Units piecewise functions in the
future.

## What Changes

- Introduce a `UnitaryFunction` abstract base class with: required arity;
  optional domain specification (units/constraints per argument); optional
  range specification (output units); forward evaluation; and optional inverse
  evaluation (with a defined error when inverse is attempted on a
  `UnitaryFunction` that does not support it)
- Introduce a `BuiltinFunction` concrete subclass that wraps the current
  `_builtinFunctions` / `_evaluateBuiltin` logic
- Extend `UnitRepository` with a parallel function registry
  (`registerFunction` / `findFunction`)
- Replace the static `_builtinFunctions` set and `_evaluateBuiltin()` switch in
  `ast.dart` with registry-based lookup via `UnitRepository`
- Update `EvalContext` so `FunctionNode` can reach the function registry
- Update the parser's function-detection logic to query the registry instead of
  calling the static `isBuiltinFunction()`
- Design the `UnitaryFunction` class hierarchy with forward compatibility for
  future subclasses: `AffineFunction` (replacing `AffineUnit`/`AffineUnitNode`)
  and `PiecewiseFunction` (GNU Units piecewise definitions)

## Capabilities

### New Capabilities

- `function-class`: `UnitaryFunction` abstract base class and
  `BuiltinFunction` subclass — arity, optional domain/range metadata,
  forward/inverse protocol, inverse-undefined error handling, class hierarchy
  shaped for future `AffineFunction` and `PiecewiseFunction` extensions
- `function-registry`: `UnitaryFunction` storage and lookup inside
  `UnitRepository`; integration with `EvalContext` and the parser's
  identifier-resolution logic

### Modified Capabilities

<!-- No existing specs are affected at the spec-behavior level.
     Evaluator and parser changes are implementation details covered by the
     new capabilities above. -->

## Impact

- `lib/core/domain/parser/ast.dart` — remove `_builtinFunctions`,
  `isBuiltinFunction()`, `_evaluateBuiltin()`; rewrite `FunctionNode.evaluate`
  to use registry lookup; collapse `FunctionNode` and `AffineUnitNode` into a
  unified call node (or keep separate with shared lookup path — TBD in design)
- `lib/core/domain/parser/parser.dart` — replace `isBuiltinFunction()` check
  with registry lookup
- `lib/core/domain/models/unit_repository.dart` — add `_functions` map,
  `registerFunction()`, `findFunction()`, and default-registration of all
  built-in functions
- `lib/core/domain/models/function.dart` — new file: `UnitaryFunction` and
  `BuiltinFunction`
- `lib/core/domain/parser/eval_context.dart` — ensure `FunctionNode` can reach
  `UnitRepository` (already present as `repo`; may only need minor wiring)
- No changes to `Unit`, `UnitDefinition`, or the unit resolver
