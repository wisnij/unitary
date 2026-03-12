## MODIFIED Requirements

### Requirement: UnitaryFunction abstract base class
The system SHALL provide a `UnitaryFunction` abstract class as the base for all
named callable identifiers.  It SHALL expose:
- `id: String` — primary registration name
- `aliases: List<String>` — alternative names (may be empty)
- `arity: int` — required number of arguments
- `domain: List<QuantitySpec>?` — optional per-argument constraint specs
- `range: QuantitySpec?` — optional constraint on the return value
- `allNames: List<String>` getter returning `[id, ...aliases]`
- `hasInverse: bool` getter
- `call(List<Quantity> args, [EvalContext? context]) → Quantity` — validates
  args, evaluates, validates result; `context` is optional and may be `null`
  for subclasses that do not require it
- `callInverse(List<Quantity> args, [EvalContext? context]) → Quantity` — throws
  if `hasInverse` is false; `context` is optional
- `evaluate(List<Quantity> args) → Quantity` — subclass-implemented forward logic
- `evaluateInverse(List<Quantity> args) → Quantity` — subclass-implemented
  inverse logic

#### Scenario: allNames includes id and all aliases
- **WHEN** a `UnitaryFunction` is created with id `"foo"` and aliases `["bar", "baz"]`
- **THEN** `allNames` returns `["foo", "bar", "baz"]`

#### Scenario: allNames with no aliases
- **WHEN** a `UnitaryFunction` is created with id `"foo"` and no aliases
- **THEN** `allNames` returns `["foo"]`

#### Scenario: call with no context succeeds for non-DefinedFunction subclasses
- **WHEN** `call(args)` is invoked on a `BuiltinFunction` or `PiecewiseFunction`
  (omitting the optional context)
- **THEN** evaluation proceeds normally; the null context is ignored
