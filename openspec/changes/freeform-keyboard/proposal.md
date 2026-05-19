## Why

On mobile devices, expression syntax characters such as `*`, `/`, `|`, and `^` are
buried one or more taps deep on the system keyboard, making it awkward to type
expressions like `5 ft^2` or `100 | km`.  A supplementary key panel surfaced above
the system keyboard removes this friction without replacing normal text input.

## What Changes

- A fixed row of 8 symbol buttons (`+`, `-`, `*`, `/`, `|`, `^`, `(`, `)`) appears
  above the system keyboard whenever either freeform input field is focused.
- The panel dismisses automatically when neither field is focused.
- Tapping a button inserts the symbol at the current cursor position in the active
  field and triggers the normal debounced re-evaluation pipeline.
- No changes to expression syntax, parsing, evaluation, or persistence.

## Capabilities

### New Capabilities

- `freeform-keyboard`: Supplementary symbol key panel for freeform expression input.

### Modified Capabilities

## Impact

- `lib/features/freeform/presentation/freeform_screen.dart` — primary change: layout
  restructured, focus tracking added, key panel widget added.
- No new package dependencies.
- No API, persistence, or data format changes.
