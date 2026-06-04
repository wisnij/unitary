## Why

When a user taps the idle example hint to load a sample expression, the "Convert from" field gains focus and the on-screen keyboard appears.  This is disruptive: the user just wanted to see the result, not start editing.  The expected behaviour matches pressing Enter — the expression is submitted and the keyboard dismisses.

## What Changes

- After tapping the idle example hint, both freeform text fields are unfocused immediately after the expression is inserted and evaluation is triggered, so the keyboard dismisses — regardless of which field (if any) was focused beforehand.

## Capabilities

### New Capabilities

(none)

### Modified Capabilities

- `idle-example-hint`: Add a new requirement that tapping the idle display leaves both freeform fields unfocused after insertion, regardless of which field was focused beforehand.

## Impact

- `lib/features/freeform/presentation/freeform_screen.dart` — the tap handler that inserts the example expression must also unfocus all fields after insertion.
- No new dependencies.
- No breaking changes.
