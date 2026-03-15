## Context

The freeform screen dispatches evaluation through two methods on `FreeformNotifier`
(`evaluateSingle`, `evaluateConversion`) with no abstraction for input
classification.  The AST (`ast.dart`) has a flat `ASTNode` hierarchy where
`evaluate() → Quantity` is the universal contract, making it impossible to
represent "this node is not evaluatable" at the type level.  Two stub types
(`DefinitionRequestNode`, `FunctionDefinitionRequestNode`) exist but are never
emitted by the parser.  `ExpressionParser` exposes a single `parse()` method
that always returns `ASTNode`.

`DefinedFunction` already stores `forward` and `inverse` as public string
fields.  `BuiltinFunction` and `PiecewiseFunction` have no expression strings.
`callInverse()` is already defined on `UnitaryFunction`.

## Goals / Non-Goals

**Goals:**

- Introduce `ExpressionNode` as a sealed abstract layer so `evaluate()` is only
  callable on expression nodes at compile time.
- Add `FunctionNameNode` as a syntactic, context-free node for bare function
  names (with or without `~`).
- Rename `parseExpression()` / add `parseQuery()` / remove `parse()`.
- Rename `FunctionNode` → `FunctionCallNode`.
- Wire the parser to emit `FunctionNameNode` for bare function names.
- Add definition/inverse string exposure on `UnitaryFunction`.
- Refactor `FreeformNotifier` to a single `evaluate()` entry point that
  dispatches on parsed AST type.
- Add new `EvaluationResult` subtypes for definition and inverse display.

**Non-Goals:**

- Unit definition display (`DefinitionRequestNode`) — stub is retained but not
  implemented here.
- Worksheet mode or any other screen.
- Changes to how expression evaluation works (no behavioral change to the
  expression path).

## Decisions

### 1. `ASTNode` and `ExpressionNode` as sealed classes; leaf classes unmarked

`ASTNode` and `ExpressionNode` are both `sealed`.  This enables exhaustive
`switch` statements at both levels of the hierarchy.  Leaf classes (`NumberNode`,
`UnitNode`, etc.) are left unmarked to allow future subclassing.

```
sealed class ASTNode
  sealed class ExpressionNode extends ASTNode
    class NumberNode extends ExpressionNode
    class UnitNode extends ExpressionNode
    class BinaryOpNode extends ExpressionNode
    class UnaryOpNode extends ExpressionNode
    class FunctionCallNode extends ExpressionNode   // renamed from FunctionNode
  class FunctionNameNode extends ASTNode            // new
  class DefinitionRequestNode extends ASTNode       // existing stub, retained
```

`FunctionDefinitionRequestNode` is removed; `FunctionNameNode` supersedes it.

### 2. `evaluate()` moves from `ASTNode` to `ExpressionNode`

`ASTNode.evaluate()` is removed.  `ExpressionNode` declares `evaluate()` as an
abstract method.  This makes it a compile-time type error to call `evaluate()`
on a `FunctionNameNode` or `DefinitionRequestNode`.

`ExpressionParser.evaluate()` calls `parseExpression()` internally and invokes
`evaluate()` on the returned `ExpressionNode`; its signature is unchanged.

### 3. `FunctionNameNode` carries name and inverse flag only

```dart
class FunctionNameNode extends ASTNode {
  final String name;
  final bool inverse;
}
```

The node is purely syntactic.  Contextual meaning (show definition, show
inverse, apply inverse conversion) is determined by the calling code.  The
freeform provider looks up `repo.findFunction(name)` to obtain the
`UnitaryFunction` and acts accordingly.

### 4. `parseQuery()` as the general entry point; `parseExpression()` replaces `parse()`

`parseExpression()` replaces `parse()`, with return type changed from `ASTNode`
to `ExpressionNode`.  This is a breaking change; all call sites are updated
before `parse()` is removed.

`parseQuery()` is the new general entry point:
1. Lex the input.
2. If the token stream is exactly one identifier that is a known function,
   consume it and return `FunctionNameNode(name, inverse: false)`.
3. If the token stream is `~` followed by exactly one identifier that is a
   known function, consume both and return `FunctionNameNode(name, inverse: true)`.
4. Otherwise delegate to `parseExpression()`.

Both entry points are on `ExpressionParser`.  The parser itself (`parser.dart`)
continues to implement the expression grammar only; `parseQuery()`'s prefix
check lives in `ExpressionParser`.

**Alternative considered:** separate `parseConversionInput()` /
`parseConversionOutput()` methods that encode UI field semantics.  Rejected
because it couples the parser layer to the freeform screen's layout.
`parseQuery()` is context-free; callers decide what a `FunctionNameNode` means.

### 5. Definition/inverse string exposure via abstract getters on `UnitaryFunction`

Two abstract getters are added to `UnitaryFunction`:

```dart
/// Human-readable forward definition string, or null if not expressible
/// as a text expression (e.g. built-in or piecewise functions).
String? get definitionExpression;

/// Human-readable inverse expression string, or null if no inverse or
/// not expressible as text.
String? get inverseExpression;
```

Implementations:
- `DefinedFunction`: returns `forward` and `inverse` respectively.
- `BuiltinFunction`: returns `null` for both.
- `PiecewiseFunction`: returns `null` for both (piecewise-defined, not a
  closed-form expression).

The UI formats `null` as `"<built-in>"`.

### 6. `FreeformNotifier` unified dispatch

`evaluateSingle` and `evaluateConversion` are replaced by a single
`evaluate(String input, String output)` method.  It calls `parseQuery()` on
each non-empty field, then switches exhaustively on the result types:

| Input node | Output node | Action |
|---|---|---|
| `FunctionNameNode(f, false)` | — (empty) | look up `f`, show `definitionExpression` |
| `FunctionNameNode(f, true)` | — (empty) | look up `f`, show `inverseExpression` |
| `ExpressionNode` | `FunctionNameNode(f, false)` | evaluate input → `f.callInverse([qty])` → display result |
| `ExpressionNode` | `FunctionNameNode(f, true)` | error: `~funcName` not valid as output |
| `ExpressionNode` | — (empty) | existing single-expression path |
| `ExpressionNode` | `ExpressionNode` | existing conversion path |

### 7. New `EvaluationResult` subtypes

```dart
class FunctionDefinitionResult extends EvaluationResult {
  final String functionName;
  final String? definitionExpression;   // null → display "<built-in>"
}

class InverseExpressionResult extends EvaluationResult {
  final String functionName;
  final String? inverseExpression;      // null → display "no inverse defined"
}
```

`ResultDisplay` is extended to handle both via the existing exhaustive `switch`.

## Risks / Trade-offs

**`evaluate()` migration scope** → The change touches every `ASTNode` subclass
and every direct call to `ast.evaluate()` in tests and production code.  The
existing test suite (1146 tests) provides full regression coverage; the
migration is mechanical but broad.  Mitigation: do it as a single atomic commit
after all call sites are confirmed updated.

**`parse()` removal breaks external callers** → Any code calling
`ExpressionParser.parse()` will not compile after the rename.  Mitigation: this
is intentional at major version 0; grep confirms all call sites are in this
repo and updated in the same change.

**`BuiltinFunction.definitionExpression` returns null** → The UI must decide how
to display functions with no expression string.  Displaying `"<built-in>"` is
sufficient for now; a richer display (mathematical formula) is a future concern.

**`FunctionNameNode` in output field with `inverse: true`** → `~funcName` in the
output field has no defined meaning and produces an error result.  This is
intentional; the error message should be clear.

## Migration Plan

The change is structured in layers that each keep the test suite green:

1. **AST restructure** — Add `ExpressionNode` (sealed, abstract, with
   `evaluate()`); make all existing expression nodes extend it; move
   `evaluate()` off `ASTNode`; rename `FunctionNode` → `FunctionCallNode`; add
   `FunctionNameNode`; remove `FunctionDefinitionRequestNode`.

2. **`parse()` → `parseExpression()` migration** — Add `parseExpression()`
   (return type `ExpressionNode`) alongside `parse()`; update all call sites;
   remove `parse()`.

3. **Add `parseQuery()`** — Implement prefix-check logic in `ExpressionParser`;
   update `freeform_provider` call site.

4. **`UnitaryFunction` definition strings** — Add abstract getters;
   implement on all three subclasses.

5. **Freeform provider and UI** — Add new `EvaluationResult` subtypes; replace
   `evaluateSingle`/`evaluateConversion` with unified `evaluate()`; extend
   `ResultDisplay`.

## Open Questions

- Should `FunctionDefinitionResult` / `InverseExpressionResult` also show the
  function's domain and range for display?  Deferred; the string getters are
  sufficient for an initial implementation.
- Should `parseQuery()` also handle bare unit names and emit
  `DefinitionRequestNode`?  Not in this change; unit definition display is
  future work.
