## Why

When the user enters a bare unit name with no convert-to value, the freeform
screen currently shows a plain evaluation result (`1 meter`, `1 cal`) that
conveys no useful information about the unit.  Function-name inputs already
show a richer definition display; unit inputs should match that richness by
exposing the unit's canonical ID (when the input is an alias), its definition
expression, and its fully-resolved base-unit quantity.

## What Changes

- A bare unit name entered in the input field (with no convert-to value) now
  displays a multi-line definition block instead of a plain evaluation result.
- **Plain unit** (no prefix): if the entered name is an alias (not the
  canonical unit ID), the first line shows the canonical ID the alias resolves
  to, in smaller muted text.  The next line shows the unit's definition
  expression in smaller muted text — the right-hand side of how the unit is
  defined (e.g., `4.184 J` for `calorie_th`).  Primitive units have no
  definition expression, so that line is omitted for them.
- **Prefix+unit**: if the entered name resolves as a prefix combined with a
  unit (e.g., `kmeters` → prefix `kilo`, unit `m`), after resolving all
  aliases and plural forms, the first line shows `<prefix-id> <unit-id>` in
  smaller muted text (e.g., `= kilo m`).  No definition expression line is
  shown in this case.
- The final line shows the fully-resolved quantity in base SI units at normal
  size, matching the existing `EvaluationSuccess` appearance.
- The existing plain evaluation behavior for a unit name (showing `1 <unit>`)
  is replaced entirely by the definition display when no convert-to is given.

## Capabilities

### New Capabilities

- `unit-definition-display`: Detect bare unit-name input in the freeform
  parser, look up the unit's canonical ID and definition expression, and render
  a multi-line definition block in the result area with appropriate text sizes
  and colors.

### Modified Capabilities

- `conversion-request-types`: The parser's `parseQuery()` path gains a new
  branch for bare unit names (analogous to the existing `FunctionNameNode`
  branch), returning a `DefinitionRequestNode`.

## Impact

- `lib/core/domain/parser/ast.dart` — `DefinitionRequestNode` stub is already
  present; no change required there.
- `lib/core/domain/parser/parser.dart` — `parseQuery()` extended to detect
  bare unit names (via `repo.findUnitWithPrefix`) and return
  `DefinitionRequestNode`.
- `lib/features/freeform/state/freeform_state.dart` — new
  `UnitDefinitionResult` subclass of `EvaluationResult`.
- `lib/features/freeform/state/freeform_provider.dart` — new
  `_handleUnitNameInput()` method, called when input parses as
  `DefinitionRequestNode`.
- `lib/features/freeform/presentation/widgets/result_display.dart` — new
  rendering branch for `UnitDefinitionResult`.
- No new dependencies.  No breaking changes to existing public APIs.
