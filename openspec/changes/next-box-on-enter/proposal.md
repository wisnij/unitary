## Why

In freeform mode, pressing Enter in the "Convert from" field currently just
dismisses the keyboard, the same as the "Convert to" field.  After typing an
expression to convert, the natural next action is usually to type a conversion
target, so Enter in the input box should advance focus to the output box rather
than ending text entry.


## What Changes

- Pressing Enter (submitting) in the "Convert from" field moves keyboard/input
  focus to the "Convert to" field instead of dismissing the keyboard.
- Pressing Enter in the "Convert to" field continues to dismiss input focus, as
  it does today.
- Both fields continue to trigger evaluation on Enter, so on-submit evaluation
  mode is unaffected.


## Capabilities

### New Capabilities

- `freeform-enter-navigation`: Defines how the Enter/submit key advances focus
  between the freeform "Convert from" and "Convert to" fields.

### Modified Capabilities

<!-- None: no existing spec covers Enter/submit focus behavior. -->


## Impact

- `lib/features/freeform/presentation/freeform_screen.dart` — the two
  `CompletionField` widgets' `onSubmitted` handlers and the `TextInputAction`
  applied to each field.
- `lib/features/freeform/presentation/widgets/completion_field.dart` — may need
  to forward a `textInputAction` to its inner `TextField`.
- No changes to evaluation logic, providers, persistence, or dependencies.
