## Why

When the output field is non-empty the interaction is always a conversion
request, so the input must be an expression.  Currently the provider reaches
this by parsing the input with `parseQuery` and then falling back from a
`DefinitionRequestNode` (or `FunctionNameNode`) to `parseExpression` — an
implicit post-hoc fixup rather than an upfront constraint.  Using
`parseExpression` directly when output is non-empty removes the workaround,
simplifies the dispatch logic, and makes the invariant explicit in code.

## What Changes

- `FreeformNotifier.evaluate()` SHALL call `parseExpression(input)` instead of
  `parseQuery(input)` when the output field is non-empty.
- The `DefinitionRequestNode`-in-input fallback (`parser.parseExpression(inputNode.unitName)`)
  SHALL be removed; it is no longer reachable when output is non-empty.
- The `FunctionNameNode`-in-input-with-non-empty-output path is also no longer
  reachable (the parser never returns `FunctionNameNode` from `parseExpression`).

## Capabilities

### New Capabilities

(none)

### Modified Capabilities

- `conversion-request-types`: The requirement governing how input is parsed when
  output is non-empty changes — `parseExpression` is used directly rather than
  `parseQuery` with a `DefinitionRequestNode` fallback.  The "DefinitionRequestNode
  in input with non-empty output falls back to conversion" scenario is removed
  (the behavior is unchanged: `"cal"` still converts as `1 cal`, but via
  `UnitNode` from `parseExpression`, not via a `DefinitionRequestNode` fallback).

## Impact

- `lib/features/freeform/state/freeform_provider.dart` — simplify `evaluate()`.
- `test/features/freeform/` — update/add scenarios covering the new parse path.
- `openspec/specs/conversion-request-types/spec.md` — remove the
  `DefinitionRequestNode`-in-input-with-non-empty-output scenario.
