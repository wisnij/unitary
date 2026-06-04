## 1. Model

- [ ] 1.1 Define `FreeformExample` class in `lib/features/freeform/data/idle_examples.dart` with `inputExpression` (required `String`) and `outputExpression` (nullable `String`) fields
- [ ] 1.2 Convert `idleExamples` from `List<String>` to `List<FreeformExample>`, wrapping all existing entries as `FreeformExample(inputExpression: '...')` and adding at least one entry with a non-null `outputExpression` (e.g., `FreeformExample(inputExpression: '1|2 gallon', outputExpression: 'ml')`)

## 2. State Layer

- [ ] 2.1 Change `EvaluationIdle.example` type from `String?` to `FreeformExample?` in `lib/features/freeform/state/freeform_state.dart`
- [ ] 2.2 Update `FreeformNotifier` (or wherever `EvaluationIdle` is constructed with an example) to pass a `FreeformExample` instead of a `String`

## 3. Display

- [ ] 3.1 Update `ResultDisplay` to render the hint as `Try: <inputExpression> → <outputExpression>` when `outputExpression` is non-null, and `Try: <inputExpression>` otherwise

## 4. Tap Handler

- [ ] 4.1 Update the tap handler in `FreeformScreen` to also set `_outputController.text = result.example!.outputExpression!` (and call `_onOutputChanged`) when the tapped example has an output expression; leave `_outputController` unchanged when it does not

## 5. Tests

- [ ] 5.1 Update existing `FreeformExample`/`EvaluationIdle` unit tests that pass a `String` to pass a `FreeformExample` instead
- [ ] 5.2 Add unit tests for `ResultDisplay` idle hint rendering: example without output shows `Try: <inputExpression>`; example with output shows `Try: <inputExpression> → <outputExpression>`
- [ ] 5.3 Add widget/integration tests for the tap handler: tapping an example with output fills both fields; tapping one without output leaves the "Convert to" field unchanged
- [ ] 5.4 Verify the existing `idleExamples` evaluability test still passes (all `inputExpression` fields parse and evaluate without error)
