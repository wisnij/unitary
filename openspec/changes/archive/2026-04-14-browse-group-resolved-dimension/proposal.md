## Why

In the dimension-grouped browse view, labeled groups currently show only the
human-readable label (e.g. "Acceleration"), giving no indication of the
underlying SI dimension.  Showing the canonical dimension string alongside the
label (e.g. "Acceleration (m / s^2)") makes the grouping immediately useful to
technically-minded users who think in terms of base units.

## What Changes

- Dimension-group headers that have a defined label SHALL display the label
  followed by the canonical dimension in parentheses (e.g.
  `"Acceleration (m / s^2)"`).
- Dimension-group headers that have **no** defined label continue to display
  only the canonical representation, unchanged.

## Capabilities

### New Capabilities

_(none)_

### Modified Capabilities

- `unit-browser`: The requirement for how labeled dimension-group headers are
  rendered is changing — the header text must now include the canonical
  dimension in addition to the human-readable label.

## Impact

- `lib/features/browse/` — group header rendering logic (widget and/or
  notifier) needs to include the canonical dimension string when a label is
  defined.
- No data-model, repository, or persistence changes required.
- No new dependencies.
