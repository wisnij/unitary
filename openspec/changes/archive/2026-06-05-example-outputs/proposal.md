## Why

The idle example hints currently only show a single "Convert from" expression.  Adding an optional "Convert to" target to examples lets the app demonstrate two-field conversion workflows and gives users a clearer picture of what the app can do.

## What Changes

- Example entries gain an optional `outputExpression` field alongside the existing `inputExpression` field.
- Examples with an output expression display in the idle hint as `<from> → <to>` instead of just `<from>`.
- Tapping an example with an output expression fills both the "Convert from" field (with `inputExpression`) and the "Convert to" field (with `outputExpression`), then evaluates.
- The curated example list is updated to include at least a few entries with output expressions (e.g., `1|2 gallon → ml`).

## Capabilities

### New Capabilities

<!-- none -->

### Modified Capabilities

- `idle-example-hint`: Examples now carry an optional output expression; display and tap-to-fill behaviour changes when an output expression is present.

## Impact

- `lib/core/domain/models/` — `FreeformExample` (or equivalent) model gains `outputExpression` field.
- `lib/features/freeform/` — idle hint display and tap handler updated.
- `lib/core/domain/data/` — curated example list updated with new entries.
- No new dependencies.
