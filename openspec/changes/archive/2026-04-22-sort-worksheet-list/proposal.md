## Why

The worksheet selector dropdown lists templates in insertion order, making it
harder to find a specific worksheet as the list grows.  Alphabetical ordering
gives users a predictable, scannable sequence.

## What Changes

- The worksheet selector dropdown SHALL list templates in case-insensitive
  alphabetical order by display name.

## Capabilities

### New Capabilities

*(none)*

### Modified Capabilities

- `worksheet-ui`: The "Worksheet selector" requirement gains an ordering
  constraint — the dropdown lists templates sorted alphabetically by name.

## Impact

- `lib/features/worksheet/presentation/worksheet_screen.dart` — sort the
  template list before building the dropdown items.
- `openspec/specs/worksheet-ui/spec.md` — update the "Worksheet selector"
  requirement to specify alphabetical ordering.
