## 1. CompletionField support

- [x] 1.1 Add an optional `TextInputAction? textInputAction` parameter to
  `CompletionField` and forward it to the inner `TextField`.

## 2. Freeform field wiring

- [x] 2.1 In `freeform_screen.dart`, set `textInputAction: TextInputAction.next`
  on the "Convert from" `CompletionField` and change its `onSubmitted` to
  evaluate and then call `_outputFocus.requestFocus()`.
- [x] 2.2 Set `textInputAction: TextInputAction.done` on the "Convert to"
  `CompletionField`, leaving its `onSubmitted` evaluating and dismissing focus
  (current behaviour).
- [x] 2.3 Verify default editing-complete traversal does not conflict with the
  explicit focus move; if it does, override `onEditingComplete` on the input
  field to no-op so only the intended focus move runs.

## 3. Tests

- [x] 3.1 Write a widget test: focusing "Convert from", submitting, asserts
  "Convert to" gains focus.
- [x] 3.2 Write a widget test: submitting "Convert from" still evaluates
  (result is displayed) in on-submit mode.
- [x] 3.3 Write a widget test: submitting "Convert to" dismisses focus from both
  fields and still evaluates.

## 4. Verification

- [x] 4.1 Run `flutter test --reporter failures-only`; all tests pass.
- [x] 4.2 Run `flutter analyze`; no new lint errors.
- [x] 4.3 Manually verify on web/device that Enter advances/dismisses focus
  correctly with no select-all or cursor glitches.
