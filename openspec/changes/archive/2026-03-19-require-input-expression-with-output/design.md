## Context

`FreeformNotifier.evaluate(String input, String output)` currently calls
`parseQuery(input)` unconditionally, then fixes up any `DefinitionRequestNode`
(or rejects any `FunctionNameNode`) after the fact when the output field is
non-empty.  The workaround exists because `parseQuery` was the sole entry point
before `parseExpression` was separated out.  Now that both entry points exist,
the right fix is to choose the correct one upfront.

The relevant code is entirely in `freeform_provider.dart`, in the `evaluate()`
method.

## Goals / Non-Goals

**Goals:**
- Use `parseExpression(input)` instead of `parseQuery(input)` when output is non-empty.
- Delete the `DefinitionRequestNode`-in-input fallback block (lines 72–74 in the current provider).
- Ensure the `"stdtemp"` + `"tempF"` case (bare unit name input, function name output) works correctly as a side-effect of this change.

**Non-Goals:**
- Changing how the output field is parsed (still uses `parseQuery`).
- Changing any other evaluation paths.

## Decisions

### Decision: switch parse method at the call site, not inside `parseQuery`

`evaluate()` selects between `parseQuery(input)` and `parseExpression(input)`
based on `output.trim().isEmpty` before any dispatch logic runs.  This
keeps the two entry points semantically clean and removes the need for any
post-parse fixup.

**Alternative considered:** add a `bool expressionOnly` flag to `parseQuery`
itself.  Rejected — it would conflate two distinct methods and add dead-code
branches inside the parser.

### Decision: remove the DefinitionRequestNode fallback block entirely

The block at lines 72–74 (`parser.parseExpression(inputNode.unitName)`) is
only reached when output is non-empty.  Once `parseExpression` is used at
the call site for that case, `DefinitionRequestNode` can never appear there,
making the block dead code.  It is deleted rather than left as a safety net.

### Decision: no explicit handling needed for the bare-unit + function-output case

When input is a bare unit name (e.g. `"stdtemp"`) and output is a function
name (e.g. `"tempF"`):

- `parseExpression("stdtemp")` → `UnitNode("stdtemp")` (an `ExpressionNode`)
- `parseQuery("tempF")` → `FunctionNameNode("tempF", inverse: false)`
- Existing `_handleFunctionNameOutput` path applies inverse → result displayed

No new code path is required; the change makes an already-correct path
reachable for the first time.

## Risks / Trade-offs

**Bare function name in input with non-empty output changes error message.**
Previously: `"Input must be an expression"` (caught by the `FunctionNameNode`
guard).  After: `"Unknown unit: \"tempF\""` (thrown during evaluation of
`UnitNode("tempF")`).  Both are errors; the new message is arguably less clear.
→ Mitigation: acceptable for now; a dedicated "not a valid expression" message
can be added in a follow-up if the UX is found confusing.

## Open Questions

(none)
