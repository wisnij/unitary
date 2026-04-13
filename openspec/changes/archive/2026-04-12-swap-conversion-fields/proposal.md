## Why

Users often want to invert a conversion (e.g., after converting miles → kilometers, they want to convert kilometers → miles).  Without a swap button, they must manually cut and paste between the two fields, which is tedious and error-prone.

## What Changes

- Add a swap button between the "Convert from" and "Convert to" fields on the freeform input screen.
- The button is enabled only when both fields contain text; it is disabled (and visually dimmed) when either field is empty.
- Tapping the button atomically exchanges the text content of the two fields and triggers re-evaluation.

## Capabilities

### New Capabilities

- `freeform-swap-button`: A swap action on the freeform screen that exchanges the input and output expressions.

### Modified Capabilities

<!-- No existing spec-level behavior changes. -->

## Impact

- `lib/features/freeform/` — UI and state changes to the freeform screen and its provider.
- No new dependencies required.
