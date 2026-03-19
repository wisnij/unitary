## 1. Repository: add findPrefix()

- [x] 1.1 Add `findPrefix(String name) → PrefixUnit?` method to `UnitRepository` with plural-stripping fallback
- [x] 1.2 Write unit tests for `findPrefix`: by canonical id, by alias, unknown name, unit-but-not-prefix name

## 2. Parser: extend parseQuery() with DefinitionRequestNode detection

- [x] 2.1 Add unit detection branch to `parseQuery()` in `parser.dart`: call `findUnitWithPrefix(name)` and return `DefinitionRequestNode(name)` when `match.unit != null`
- [x] 2.2 Add prefix detection branch to `parseQuery()` after the unit check: call `findPrefix(name)` and return `DefinitionRequestNode(name)` when non-null
- [x] 2.3 Remove the stub comment from `DefinitionRequestNode` in `ast.dart`
- [x] 2.4 Write parser tests: bare unit alias → `DefinitionRequestNode`, bare canonical unit id → `DefinitionRequestNode`, bare prefix+unit → `DefinitionRequestNode`, bare prefix alias → `DefinitionRequestNode`, bare canonical prefix id → `DefinitionRequestNode`
- [x] 2.5 Write parser tests: function beats unit (priority), unit beats prefix (priority), no-repo path still delegates to `parseExpression`
- [x] 2.6 Update existing parser test: scenario "parseQuery treats a bare unknown identifier as a unit expression" now returns `DefinitionRequestNode` → update or replace as appropriate

## 3. State: add UnitDefinitionResult

- [x] 3.1 Add `UnitDefinitionResult` class to `freeform_state.dart` with fields `String? aliasLine`, `String? definitionLine`, `String formattedResult`
- [x] 3.2 Write unit tests for `UnitDefinitionResult` construction (all fields, null header fields)

## 4. Provider: handle DefinitionRequestNode

- [x] 4.1 Add `DefinitionRequestNode` input + empty output branch to `evaluate()` in `freeform_provider.dart`, calling a new `_handleUnitNameInput()` method
- [x] 4.2 Implement `_handleUnitNameInput()`: call `findUnitWithPrefix`; if prefix+unit set `aliasLine = "= <prefix.id> <unit.id>"`; if plain unit set `aliasLine` when input ≠ `unit.id`, set `definitionLine` for `DerivedUnit`; evaluate the unit name as a plain expression for `formattedResult`
- [x] 4.3 Extend `_handleUnitNameInput()` to handle bare prefix (no unit): call `findPrefix`, set `aliasLine` when input ≠ `prefix.id`, evaluate for scalar `formattedResult`
- [x] 4.4 Add fallback in `evaluate()`: when `inputNode is DefinitionRequestNode && outputNode != null`, re-parse input via `parseExpression()` and proceed through the existing conversion path
- [x] 4.5 Add fallback in `evaluate()`: when `outputNode is DefinitionRequestNode`, re-parse output via `parseExpression()` before dispatching to `_evaluateConversion`
- [x] 4.6 Write provider tests: alias for derived unit, alias for primitive unit, canonical derived unit, canonical primitive unit
- [x] 4.7 Write provider tests: prefix+unit alias input, canonical prefix+unit input
- [x] 4.8 Write provider tests: bare prefix alias input, bare canonical prefix id input
- [x] 4.9 Write provider tests: unit-wins-over-prefix priority
- [x] 4.10 Write provider tests: `DefinitionRequestNode` input with non-empty output falls back to conversion; `DefinitionRequestNode` output falls back to conversion

## 5. Widget: render UnitDefinitionResult

- [x] 5.1 Add `UnitDefinitionResult` branch to the `switch` in `result_display.dart`: render `aliasLine` (fontSize 14, `onSurfaceVariant`) and `definitionLine` (fontSize 14, `onSurfaceVariant`) when non-null, each followed by a 4 px spacer, then `formattedResult` (fontSize 20, `w500`, `primary`); border color `colorScheme.primary`
- [x] 5.2 Write widget tests: all three lines present, alias line + result only, definition line + result only, result only (both headers null)

## 6. Final checks

- [x] 6.1 Run `flutter test --reporter failures-only` and confirm all tests pass
- [x] 6.2 Run `flutter analyze` and confirm no linting errors
