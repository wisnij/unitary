## Context

The freeform screen already has a two-tier display for bare function names:
a small muted label line (`sin(x) =`) above a larger primary-colored
expression line.  A bare unit name such as `cal` currently bypasses this
path entirely — `parseQuery()` only detects function names, so the unit
falls through to `parseExpression()`, evaluates to `1 cal`, and renders
as a plain `EvaluationSuccess`.

A stub class `DefinitionRequestNode` exists in `ast.dart` with a comment
noting it is "not yet implemented".  The full lookup machinery is already
in `UnitRepository`: `findUnitWithPrefix(name)` returns a `UnitMatch`
containing an optional `PrefixUnit` and an optional base `Unit`, resolving
aliases and plural forms automatically.  Prefix-only lookup is not yet
exposed publicly; a new `findPrefix(name)` method must be added to
`UnitRepository` to support bare-prefix detection in `parseQuery()`.

## Goals / Non-Goals

**Goals:**

- Bare unit name input (no output field) renders a definition block
  showing canonical ID / alias resolution, definition expression, and
  resolved quantity.
- Prefix+unit input (e.g. `kmeters`) shows the decomposed canonical form
  (`= kilo m`) as the header line.
- Bare prefix input (e.g. `kilo`, `M`) with no following unit shows the
  canonical prefix ID (if the input is an alias) and its scalar value.
- Unit names take priority over prefix names: if an identifier resolves as
  both a unit and a prefix, the unit definition is shown.
- The feature is gated to the "no output" case: if the output field is
  non-empty, the input is treated as a plain expression as before.

**Non-Goals:**

- Showing unit definitions when the input is not a bare single-token
  identifier (e.g. `5 cal` continues to evaluate normally).
- Modifying the convert-to output field path.
- Displaying any additional metadata beyond what the proposal specifies
  (description, aliases list, etc.).

## Decisions

### 1. Keep `DefinitionRequestNode` as a thin wrapper

`DefinitionRequestNode` stores only the raw input string.  All resolution
(alias lookup, prefix splitting, expression retrieval, quantity evaluation)
happens in the provider's `_handleUnitNameInput()`, which already has
access to the parser and repository.  This keeps the AST node a pure
syntactic marker with no runtime dependencies.

**Alternative considered**: enrich the node at parse time by storing the
resolved `UnitMatch` directly.  Rejected because it couples the parser
(domain layer) to runtime repository state and creates a heavier object in
what should be a lightweight AST.

### 2. Detection order in `parseQuery()`: functions → units → prefixes

The existing function-name detection block stays unchanged.  Two new
checks are appended in the same `if (_repo != null)` guard, in priority
order:

1. **Unit check** (via `findUnitWithPrefix`): if the identifier resolves
   to a unit — with or without a prefix — emit `DefinitionRequestNode`.
   The guard condition is `match.unit != null`.
2. **Prefix check** (via `_prefixLookup` / a new `findPrefix(name)`
   method on `UnitRepository`): if the identifier resolves to a known
   prefix with no following base unit, emit `DefinitionRequestNode`.

Because units are checked before prefixes, an identifier that is
registered as both a unit name and a prefix name (which is possible —
e.g. a hypothetical unit `M` that also exists as the mega prefix) shows
the unit definition.  The repository does not prevent such overlaps
between the unit and prefix namespaces, so the explicit ordering here
is the tie-breaker.

A bare identifier that resolves to neither a function, unit, nor prefix
continues to fall through to `parseExpression()`, which will produce an
`EvalException('Unknown unit: …')` as before.

### 3. `UnitDefinitionResult` carries pre-formatted strings

```dart
class UnitDefinitionResult extends EvaluationResult {
  final String? aliasLine;       // e.g. "= calorie_th" or "= kilo m"; null if not needed
  final String? definitionLine;  // e.g. "= 4.184 J"; null for primitives and prefix+unit
  final String formattedResult;  // e.g. "= 4.184 kg m² / s²"
}
```

The provider formats all strings before writing to state, consistent with
how `FunctionDefinitionResult` stores a pre-built label string.  The
widget receives only display-ready data and has no business logic.

**Alias line rules** (set by `_handleUnitNameInput()`):

| Input resolves as                         | `aliasLine`                 | `definitionLine`                   |
|-------------------------------------------|-----------------------------|------------------------------------|
| Prefix + unit (any input)                 | `"= <prefix.id> <unit.id>"` | `null`                             |
| Plain unit, input == `unit.id`            | `null`                      | `DerivedUnit.expression` or `null` |
| Plain unit, input != `unit.id` (alias)    | `"= <unit.id>"`             | `DerivedUnit.expression` or `null` |
| Bare prefix, input == `prefix.id`         | `null`                      | `null`                             |
| Bare prefix, input != `prefix.id` (alias) | `"= <prefix.id>"`           | `null`                             |

`definitionLine` is `null` for `PrimitiveUnit` (no expression), for all
prefix+unit matches (the alias line already explains the composition), and
for bare prefixes (the `formattedResult` scalar is the only meaningful
output).

### 4. `DefinitionRequestNode` with non-empty output → fall back to expression

If the user types `cal` in input and `J` in output, the intent is
conversion, not definition display.  In `evaluate()`, when
`inputNode is DefinitionRequestNode && outputNode != null`, re-parse the
raw input string as a plain expression via `parser.parseExpression()` and
proceed through the normal conversion path.

Similarly, if `outputNode is DefinitionRequestNode` (user types a bare
unit name only in the output field), re-parse it as a plain expression
before dispatching to `_evaluateConversion`.  This is consistent with the
existing behaviour where a unit name in the output field is treated as a
conversion target expression.

### 5. `formattedResult` uses the user's current precision and notation

The resolved quantity is obtained by evaluating the raw unit name as a
plain expression (`parser.evaluate(unitName)`), then calling
`formatQuantity(result, precision: …, notation: …)` with the current
settings.  This mirrors `_evaluateSingle()` exactly, so the final line
looks identical to what the plain evaluation currently shows — just moved
to the bottom of the definition block.

### 6. Widget layout mirrors `FunctionDefinitionResult`

```
aliasLine      (fontSize 14, onSurfaceVariant)   — if present
definitionLine (fontSize 14, onSurfaceVariant)   — if present
formattedResult (fontSize 20, w500, primary)
```

Each present header line is separated from the next by a 4 px `SizedBox`,
matching the existing function definition spacing.  Border color is
`colorScheme.primary` (same as `EvaluationSuccess`).

## Risks / Trade-offs

**Identifier that is both a valid unit and something else** → Only a
theoretical risk; the repository enforces collision-free registration for
units and functions.  No mitigation needed beyond the existing registry
checks.

**Unit/prefix namespace overlap** → The repository allows a name to exist
in both the unit namespace and the prefix namespace (they use separate
lookup maps).  The detection order (units before prefixes) is the explicit
tie-breaker.  No additional mitigation needed.

**Plural-only match with no canonical ID** → Plural stripping in
`findUnitWithPrefix` always produces a `Unit` with a canonical `id`, so
the alias line correctly shows that ID even for irregular plurals.

## Open Questions

None.
