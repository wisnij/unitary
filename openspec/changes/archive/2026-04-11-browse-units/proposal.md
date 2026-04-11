## Why

Users have no way to discover what units, prefixes, and functions the app
supports other than trial-and-error in the freeform input field.  A dedicated
browse page gives users an at-a-glance reference they can navigate and search
without needing to know a name in advance.

## What Changes

- Add a new top-level "Browse" page accessible from the navigation drawer
- Display all registered units, prefixes, and functions (including aliases) as
  a scrollable list, with each alias shown as its own entry (consistent with
  the conformable-units modal style)
- Toggle between two views (dimension view is the default on first open): an alphabetical view (entries grouped by
  case-insensitive first letter, A–Z, with a trailing `#` group for
  non-letter-initial entries; all groups start expanded) and a
  dimension-grouped view (every base dimension forms its own named group,
  including `isDimensionless` primitive units such as radian and steradian;
  units and prefixes placed by resolved output dimension, functions by range
  dimension; all groups start collapsed); groups in either view can be
  collapsed or expanded by tapping the group header; all groups auto-expand
  while a search query is active
- Search button in the AppBar activates a filter bar; typing narrows the list
  to entries whose name or any alias partially matches the query
- Tapping any list entry navigates to a detail page showing: primary name, all
  aliases, description (if present), definition expression or "[primitive
  unit]", and the fully resolved base-unit quantity (e.g. `1 ft = 0.3048 m`)

## Capabilities

### New Capabilities

- `unit-browser`: Top-level browse page — list display, flat/grouped toggle,
  search bar, entry rows (name + definition summary, alias annotation)
- `unit-entry-detail`: Detail page for a single unit, prefix, or function —
  full metadata, resolved quantity, and (for units/prefixes) a link to browse
  conformable entries

### Modified Capabilities

_(none — no existing spec-level requirements are changing)_

## Impact

- `lib/features/` — new `browser/` feature directory with presentation and
  state layers
- `lib/app.dart` / `home_screen.dart` — drawer gains a "Browse" tile;
  `_TopLevelPage` enum gains a `browser` variant
- `lib/core/domain/models/unit_repository.dart` — new `buildBrowseCatalog()`
  query method; receives the dimension-label map at construction time
- `lib/core/domain/data/units-supplementary.json` — new top-level
  `"dimensions"` key: a hand-authored map from canonical dimension
  representation to label object (e.g. `{"m": {"label": "Length"}}`)
- `lib/core/domain/data/units.json` — `"dimensions"` key added by
  `generate_predefined_units` during the existing supplementary-merge step
- `tool/generate_predefined_units_lib.dart` — emits the dimension-label map
  as a Dart constant in `predefined_units.dart`
- No new dependencies expected; uses existing `UnitRepository`, `resolveUnit`,
  and `Dimension.canonicalRepresentation()`
