## Why

Users frequently know the dimension they're working in but don't know which
unit names are available for the "Convert to" field.  A discoverable list of
conformable units — filterable by the actual dimension of the current expression
— makes it easy to pick a target unit without memorizing unit identifiers.

## What Changes

- Add a "browse conformable units" icon button to the freeform screen's AppBar.
- When pressed, evaluate the "Convert from" expression and collect every
  registered unit and function whose dimension is conformable with the result.
- Display the conformable entries in a modal bottom sheet or dialog, sorted
  case-insensitively by name, showing each entry's name and either its
  definition expression (for units) or its function type label ("function" or
  "piecewise linear function").
- Tapping an entry dismisses the modal and fills the "Convert to" field:
  if the field is empty, the entry name is written directly; if it already
  contains text, the entry name is appended, preceded by a single space unless
  the existing text already ends in whitespace.
- Add a `UnitRepository` method that returns all conformable units and functions
  for a given `Dimension`.

## Capabilities

### New Capabilities

- `conformable-units-query`: `UnitRepository` API to enumerate all registered
  units and functions conformable with a given `Dimension`, returning them as an
  ordered list of descriptor objects (name, definition string, function-type
  label).
- `conformable-units-ui`: Freeform screen UI additions — AppBar icon button
  trigger, modal list widget, tap-to-fill/append behavior for the "Convert to"
  field, and error state when the "Convert from" expression is empty or invalid.

### Modified Capabilities

<!-- No existing spec-level requirements change. -->

## Impact

- `lib/core/domain/models/unit_repository.dart` — new `findConformable()` method
- `lib/features/freeform/` — trigger widget added to the screen, new modal widget, provider updates to expose evaluated dimension
- `test/core/domain/models/unit_repository_test.dart` — new tests for `findConformable()`
- `test/features/freeform/` — new widget tests for the modal and trigger
