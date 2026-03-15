## Why

The freeform screen currently dispatches to one of two hardcoded paths (single
expression or two-expression conversion), with no room to grow.  New input
patterns — bare function name lookup, inverse expression display, function-as-
conversion-target — each need their own evaluation behavior, and more patterns
are expected in future phases (e.g. unit lists).  The AST needs a cleaner type
hierarchy to make the distinction between "something that evaluates to a
Quantity" and "a name reference" explicit in the type system, and the parser
needs a general entry point that can return either.

## What Changes

- Mark `ASTNode` and `ExpressionNode` as `sealed`.  Leaf classes are left
  unmarked (not `final`) to allow future extension.
- Introduce `ExpressionNode` as a sealed abstract subtype of `ASTNode`.  All
  current expression node types (`NumberNode`, `UnitNode`, `BinaryOpNode`,
  `UnaryOpNode`, `FunctionCallNode`) become subtypes of `ExpressionNode`.
  `evaluate() → Quantity` moves from `ASTNode` to `ExpressionNode`, making it
  a type error to evaluate a non-expression node.  Both levels of the hierarchy
  support exhaustive `switch` statements.
- Rename `FunctionNode` → `FunctionCallNode` for clarity (it represents a
  function call with arguments, not a bare function reference).
- Add `FunctionNameNode(name: String, inverse: bool)` as a direct `ASTNode`
  subtype (not `ExpressionNode`).  Represents a bare function name (`funcName`
  or `~funcName`) with no argument list.  Carries only the syntactic facts the
  parser knows; contextual meaning is determined by the calling code.
- Add `parseExpression()` to `ExpressionParser`, returning `ExpressionNode`.
  This is the renamed form of the current `parse()`, restricted to expression
  inputs.
- Add `parseQuery()` to `ExpressionParser`, returning `ASTNode`.  This is the
  general entry point: it recognizes a bare known-function name (or
  `~funcName`) and returns a `FunctionNameNode`; otherwise it delegates to
  `parseExpression()`.
- Remove the old `parse()` method once all call sites are updated.
- In the parser, a bare known-function identifier with no following `(` emits
  `FunctionNameNode(name, inverse: false)` instead of falling through to
  `UnitNode`.  A `~funcName` with no following `(` emits
  `FunctionNameNode(name, inverse: true)` instead of throwing `ParseException`.
- Refactor `FreeformNotifier` to a single `evaluate(input, output)` entry
  point.  It calls `parseQuery()` on each field and dispatches on the result
  types:
  - Input `FunctionNameNode(f, false)`, output empty → look up
    `repo.findFunction(f)`, display forward definition.
  - Input `FunctionNameNode(f, true)`, output empty → look up
    `repo.findFunction(f)`, display inverse expression.
  - Output `FunctionNameNode(f, false)` → evaluate input to `Quantity`, call
    `repo.findFunction(f).callInverse(inputQty)`, display result.
  - Output `FunctionNameNode(f, true)` → error (not a meaningful combination).
  - Otherwise → existing expression evaluation / conversion behavior.
- Add new `EvaluationResult` subtypes for the two display-only cases
  (`FunctionDefinitionResult`, `InverseExpressionResult`).
- Extend `UnitaryFunction` / `DefinedFunction` to expose the forward
  definition expression string and inverse expression string for display.
  `BuiltinFunction` returns a suitable placeholder (e.g. `"<built-in>"`).
- Extend the result display widget to render the new result subtypes.

## Capabilities

### New Capabilities

- `conversion-request-types`: `ExpressionNode` layer in the AST; `FunctionCallNode`
  rename; `FunctionNameNode`; `parseExpression()` / `parseQuery()` parser
  entry points; unified freeform dispatch; new `EvaluationResult` subtypes for
  definition and inverse display; `UnitaryFunction` definition string exposure.

### Modified Capabilities

<!-- No existing spec-level requirements change; this is purely additive. -->

## Impact

- `lib/core/domain/parser/ast.dart` — mark `ASTNode` sealed; add
  `ExpressionNode` (sealed abstract); move `evaluate()` there; rename
  `FunctionNode` → `FunctionCallNode`; add `FunctionNameNode`.
- `lib/core/domain/parser/parser.dart` — emit `FunctionNameNode` for bare
  known-function identifiers; relax `~` to allow bare function names.
- `lib/core/domain/parser/expression_parser.dart` — add `parseExpression()`
  and `parseQuery()`; remove `parse()` after call-site migration.
- `lib/core/domain/models/function.dart` — expose `definitionExpression` and
  `inverseExpression` on `UnitaryFunction`.
- `lib/features/freeform/state/freeform_state.dart` — add
  `FunctionDefinitionResult` and `InverseExpressionResult`.
- `lib/features/freeform/state/freeform_provider.dart` — unified `evaluate()`
  entry point dispatching on parsed AST type.
- `lib/features/freeform/presentation/widgets/result_display.dart` — render
  new result subtypes.
- All existing call sites of `parse()` updated to `parseExpression()` or
  `parseQuery()` as appropriate before `parse()` is removed.
- No new package dependencies.
