# Proposal: Worksheet Errors

## Why

Worksheet rows that fail to compute currently display the generic string
"error", giving the user no indication of why the conversion failed.  Specific
error messages (e.g. "out of bounds" when a value falls outside a function's
domain) make the worksheet meaningfully more usable for technical users.
Additionally, there is no visual distinction between an error value and a
normal one, so errors are easy to overlook.

## What Changes

- The worksheet engine produces structured error results instead of a bare
  `"error"` string, carrying a short human-readable message.
- Error messages are categorized: domain violations report "out of bounds",
  dimension mismatches report "wrong unit type", missing inverse reports "no
  inverse", and a generic fallback covers unexpected failures.
- The worksheet row widget renders error text in the theme's warning/error
  color (`colorScheme.error`) so the user immediately sees which rows failed.

## Capabilities

### New Capabilities

_(none — all changes are modifications to existing capabilities)_

### Modified Capabilities

- `worksheet-engine`: Error results now carry specific messages instead of a
  single generic string; the engine distinguishes domain violations, dimension
  mismatches, and missing-inverse failures.
- `worksheet-ui`: Rows displaying an error value render their text in
  `colorScheme.error` instead of the normal value color.

## Impact

- `lib/features/worksheet/worksheet_engine.dart` — error result type/message
  changes
- `lib/features/worksheet/worksheet_screen.dart` (or equivalent row widget) —
  conditional color on error text
- `test/features/worksheet/` — updated/new engine and widget tests
