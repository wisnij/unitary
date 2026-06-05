## Context

The idle freeform display shows a curated list of example expressions.  Each example is currently a plain `String`.  The feature is surfaced through three layers:

- `lib/features/freeform/data/idle_examples.dart` — `const List<String> idleExamples`
- `EvaluationIdle.example: String?` in `freeform_state.dart` — carries the selected example into state
- `ResultDisplay` + `FreeformScreen` — render the hint and handle tap-to-fill

The tap handler currently only fills `_inputController`; `_outputController` is untouched.

## Goals / Non-Goals

**Goals:**

- Allow individual examples to carry an optional "Convert to" expression alongside the existing "Convert from" expression.
- Display examples with an output as `<from> → <to>` in the idle hint.
- Tap-to-fill populates both fields when the example has an output expression.
- Keep the change minimal and backwards-compatible: examples without an output field behave exactly as before.

**Non-Goals:**

- Changing how examples are selected or rotated.
- Adding output expressions to every example; a handful of well-chosen entries is sufficient for the MVP.
- Adding a UI for users to add their own examples.

## Decisions

### Introduce a `FreeformExample` record class

**Decision**: Replace `List<String>` with `List<FreeformExample>` where `FreeformExample` is a simple immutable class with `inputExpression` (required) and `outputExpression` (nullable).

**Rationale**: A named class makes call-sites readable (`example.inputExpression`, `example.outputExpression`) and is easier to extend later (e.g., adding a description or category).  A Dart record `(String, String?)` would work but loses named fields and is harder to read across the codebase.

**Alternative considered**: Keep `List<String>` and encode the optional output with a delimiter (e.g., `"1|2 gallon|ml"`).  Rejected: fragile, hard to read, and conflicts with the rational-number `|` operator already used in expression syntax.

### Place `FreeformExample` in `idle_examples.dart`

**Decision**: Define the `FreeformExample` class in `lib/features/freeform/data/idle_examples.dart`, alongside the `idleExamples` list.

**Rationale**: The class is tightly coupled to the idle-examples feature and has no use elsewhere.  A separate file would be over-engineering for a two-field data class.

### Thread `FreeformExample` (not `String`) through state

**Decision**: Change `EvaluationIdle.example` from `String?` to `FreeformExample?`.

**Rationale**: The state layer already knows about `FreeformExample`; threading the full object avoids the need to reconstruct it later in the tap handler.  The display layer can access both fields directly.

## Risks / Trade-offs

- [Wider diff than a string change] → Mitigated: all affected sites are in the freeform feature folder; the change is localized.
- [Tests that construct `EvaluationIdle(example: 'foo')` break] → Update tests to use `EvaluationIdle(example: FreeformExample(inputExpression: 'foo'))`, or keep a `String`-accepting factory constructor.  Prefer direct migration to keep the type clean.
