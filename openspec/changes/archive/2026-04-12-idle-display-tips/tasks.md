## 1. Example Data

- [x] 1.1 Create `lib/features/freeform/data/idle_examples.dart` with a `const List<String> kIdleExamples` covering unit conversions, SI prefixes, physical constants, defined functions, and compound expressions (at least 10 entries)

## 2. State

- [x] 2.1 Add an optional `String? example` field to `EvaluationIdle` in `lib/features/freeform/state/freeform_state.dart`
- [x] 2.2 In `FreeformNotifier` (`lib/features/freeform/state/freeform_provider.dart`), pick a random entry from `kIdleExamples` during construction and store it
- [x] 2.3 Emit `EvaluationIdle(example: _selectedExample)` wherever the notifier transitions to the idle state

## 3. UI

- [x] 3.1 Update the `EvaluationIdle` branch in `ResultDisplay` (`lib/features/freeform/presentation/widgets/result_display.dart`) to display two lines in muted colour: "Enter an expression above." and "Try: \<example\>" (when `example` is non-null); add an optional `VoidCallback? onTap` parameter and wrap the idle content in a `GestureDetector` (or `InkWell`) when `onTap` is provided
- [x] 3.2 In `FreeformScreen`, pass an `onTap` callback to `ResultDisplay` that sets `_inputController.text` to the example string, calls `setState`, and calls `_evaluate()`
- [x] 3.3 Remove the `hintText` from the "Convert from" and "Convert to" `TextField` widgets in `lib/features/freeform/presentation/freeform_screen.dart`

## 4. Tests

- [x] 4.1 Add a test in `test/core/domain/data/predefined_units_test.dart` (or a new file) that evaluates each entry in `kIdleExamples` against the production `UnitRepository` and asserts no parse or eval errors
- [x] 4.2 Add widget/unit tests for `EvaluationIdle` with a non-null `example` to verify both "Enter an expression above." and "Try: \<example\>" are rendered, and that tapping the display invokes the `onTap` callback
- [x] 4.3 Add a unit test for `FreeformNotifier` verifying the initial state carries a non-null, non-empty example string

## 5. Verification

- [x] 5.1 Run `flutter test --reporter failures-only` and confirm all tests pass
- [x] 5.2 Run `flutter analyze` and confirm no lint errors
