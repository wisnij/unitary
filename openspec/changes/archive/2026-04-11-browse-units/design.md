## Context

The app currently has no way to discover available units, prefixes, or
functions.  The conformable-units modal surfaces entries for a specific
dimension, but there is no global catalog view.

The unit database contains ~7,294 primary units, ~125 prefixes, and ~147
functions — each with one or more aliases.  Expanding all aliases, the full
browse list will likely exceed 15,000 entries.  Any design must account for
this scale at every layer (data building, grouping, rendering, search).

The existing `UnitRepository` provides `allUnits`, `allPrefixes`, and
`allFunctions` iterables (primary IDs only) plus the `_resolvedQuantityCache`
that lazily stores each unit's reduced `Quantity`.  There is currently no
`DimensionRegistry` or dimension-to-label mapping.


## Goals / Non-Goals

**Goals:**

- Alphabetical list of all entries (units + prefixes + functions + aliases),
  with each alias as its own row; entries grouped by case-insensitive first
  letter (A, B, … Z) with a final `#` group for entries whose name begins with
  a non-letter character
- Dimension-grouped list view as an alternative; groups sorted by label;
  entries within each group sorted case-insensitively by name
- AppBar search bar that filters the active view by name/alias substring
- Tapping an entry navigates to a detail page with full metadata and (for
  units and prefixes) the resolved base-unit quantity
- Performance: flat list builds instantly; grouped index built once lazily
  and cached; `ListView.builder` used throughout so only visible rows are
  rendered

**Non-Goals:**

- Persisting browse state (scroll position, last-used view) across sessions
- Tapping a browse entry to auto-fill the freeform input field (that is the
  job of the conformable modal)
- Persisting collapsed/expanded group state across sessions


## Decisions

### 1. Unified `BrowseEntry` model

**Decision:** Introduce a `BrowseEntry` value class in
`lib/features/browser/models/browse_entry.dart`.

**Fields:**
- `name` — display name (primary id **or** alias)
- `primaryId` — primary registration id of the underlying object
- `kind` — `BrowseEntryKind` enum: `unit`, `prefix`, `function`
- `aliasFor` — non-null iff this entry is an alias; equals `primaryId` then
- `summaryLine` — the second display line, matching conformable-modal style:
  - Derived unit: definition expression (e.g. `4.184 J`)
  - Primitive unit: `[primitive unit]`
  - Prefix: definition expression
  - Function: `[function]` or `[piecewise linear function]`
- `dimension` — the resolved `Dimension` of this entry; `null` if resolution
  failed (entry still appears in the flat list; excluded from grouped view)
- `params` — `List<String>?`; formal parameter names for function entries;
  `null` for units and prefixes.  Used to render function names as
  `"name(p1, p2)"` in the browse list.

Rather than holding a reference to the underlying domain object, `BrowseEntry`
is a plain data class.  The detail screen re-looks up the domain object by
`primaryId` + `kind` from the singleton `UnitRepository`.

Tapping an alias entry navigates to the same detail page as tapping its
primary — i.e. the detail screen always receives `primaryId`, never the alias
name.  The detail page shows the primary name and all its aliases together.

**Rationale:** Keeping the model flat avoids the need to encode a tagged union
(`Unit | PrefixUnit | UnitaryFunction`) in a Dart class without sealed types.
Re-lookup on the detail screen is instant (hash-map lookup).

---

### 2. Catalog building in `UnitRepository`

**Decision:** Add a `List<BrowseEntry> buildBrowseCatalog()` method to
`UnitRepository`.

This method iterates `allUnits` (excluding `PrefixUnit`), `allPrefixes`,
and `allFunctions`, expands aliases, resolves each primary entry's dimension
(reusing `_resolvedQuantityCache`), and returns the full flat list.

**Rationale:** Dimension resolution is domain logic that belongs in the domain
layer.  Centralising the catalog build in the repository keeps the feature
provider thin and makes the catalog independently testable.

The method is synchronous (no async I/O); dimension resolution is
CPU-bound Dart arithmetic and completes in one microtask.

---

### 3. Eager index building, two view modes

**Decision:** Both views are grouped; they differ only in what key is used:

- **Alphabetical view** — groups by case-insensitive first letter of the
  entry name; non-letter-initial entries go in a trailing `#` group.
- **Dimension view** — maps `Dimension` → sorted `List<BrowseEntry>`; group
  label derived (see Decision 4 below).

Both indices are built eagerly inside `BrowserNotifier.build()`.  This
incurs a one-time cost when the `browserProvider` is first read (i.e. when
the user opens the browse page for the first time in a session), but avoids
any additional delay on subsequent view switches.  Both indices are stored as
non-nullable fields in `BrowserNotifier` after `build()` completes.

**Rationale:** Building eagerly simplifies state management: the dimension
view's initial collapsed state (all groups collapsed) is derived from the
group labels, which are available immediately.  The browse page is opened
lazily (provider is not initialized until navigation), so there is no
app-startup penalty.  Grouping by first letter makes the long list navigable
without a separate A–Z fast-scroll widget.

---

### 3a. Collapsible groups

**Decision:** Groups in both views are collapsible.  Tapping a group header
toggles it.

**Default view:** The dimension view is shown when the page is first opened
in a session.  The toggle starts in the "dimension" position.

**Default expanded state:**
- Alphabetical view — all groups start **expanded**
- Dimension view — all groups start **collapsed**

**Collapsed state storage:** A `Set<String> _collapsedGroups` in
`BrowserNotifier`, keyed by group label.  When a view is first entered its
default state is applied by pre-populating `_collapsedGroups` with either the
full group-label set (dimension view) or the empty set (alphabetical view).
Switching between views resets to the defaults for that view.

**During search:** Every change to the query that produces a non-empty string
clears `_collapsedGroups` to empty (all groups expanded).  The user may still
tap group headers to collapse individual groups while searching; `toggleGroup`
modifies `_collapsedGroups` as normal.  However, the next keystroke that
produces a non-empty query will again clear `_collapsedGroups`.

When the query first transitions from empty to non-empty, the current
`_collapsedGroups` is saved to `_preSearchCollapsedGroups`.  When the query is
cleared back to empty, `_preSearchCollapsedGroups` is restored into
`_collapsedGroups` and the saved snapshot is discarded.

**Rendering:** The flat item list passed to `ListView.builder` simply omits
entry rows for groups whose label is in `_collapsedGroups` (and the search
override is not active).  Group header rows always appear.  Each header row
shows a trailing chevron (down when expanded, right when collapsed).

---

### 4. Dimension group labelling

**Decision:** `lib/core/domain/data/units.json` gains a top-level
`"dimensions"` key: a map from canonical dimension representation string to a
label object:

```json
"dimensions": {
  "1":          {"label": "Dimensionless"},
  "m":          {"label": "Length"},
  "kg":         {"label": "Mass"},
  "s":          {"label": "Time"},
  "K":          {"label": "Temperature"},
  "m^2":        {"label": "Area"},
  "m^3":        {"label": "Volume"},
  "m / s":      {"label": "Speed"},
  "radian":     {"label": "Angle"},
  "steradian":  {"label": "Solid Angle"},
  ...
}
```

The key is exactly the string returned by `Dimension.canonicalRepresentation()`
(e.g. `"1"` for dimensionless, `"m"` for length, `"kg m / s^2"` for force).

Label lookup: `dimensionLabels[dim.canonicalRepresentation()]?.label ?? dim.canonicalRepresentation()`.

**Sorting in the dimension view:** groups with a defined label sort before
groups whose label fell back to the canonical representation.  Within each
tier, groups sort case-insensitively by their final label.

**Authoring and pipeline flow:**

1. Hand-authored in `units-supplementary.json` as a top-level `"dimensions"`
   key alongside the existing `"units"` and `"prefixes"` keys.
2. `generate_predefined_units` merges `units-supplementary.json` into
   `units.json` via the existing `recursiveMerge` / `mergeSupplementary`
   function — the new key is carried through without any changes to the merge
   logic.
3. `generate_predefined_units_lib` reads the `"dimensions"` map from the
   merged data and emits a `Map<String, String>` constant (canonical rep →
   label) into `predefined_units.dart`, alongside the existing unit and
   function registration code.
4. `UnitRepository.withPredefinedUnits()` receives the map and stores it for
   use by `buildBrowseCatalog()`.

The GNU Units import tool (`import_gnu_units`) does not touch `units-supplementary.json` and requires no changes.

**Rationale:** A data-driven label map is explicit and easy to extend with no
heuristics.  Routing it through the existing supplementary-merge pipeline
avoids a new data-loading path and keeps `units-supplementary.json` as the
single place for all hand-authored overrides.

---

### 5. Detail page content by entry kind

**Decision:** The `UnitEntryDetailScreen` renders different sections based on
`BrowseEntry.kind`:

| Field          | Unit                     | Prefix                    | Function                        |
|----------------|--------------------------|---------------------------|---------------------------------|
| Primary name   | ✓ (long-press copies)    | ✓ (long-press copies)     | ✓ (long-press copies)           |
| Aliases        | ✓ sorted (if any)        | ✓ sorted (if any)         | ✓ sorted (if any)               |
| Type           | "Primitive unit" / "Derived unit" | "Prefix"         | "Function" / "Piecewise linear function" |
| Description    | ✓ (if set)               | ✓ (if set)                | ✓ (if set)                      |
| Definition     | expression only (omitted for primitive units) | expression | `name(params) = expr` (long-press copies) |
| Inverse        | —                        | —                         | inverse expr (if any)           |
| Value          | `<formatted base qty>`   | `<formatted base qty>`    | —                               |
| Domain / range | —                        | —                         | "Argument p: …" / "Range: …" (if constrained; not for `PiecewiseFunction`) |
| Points table   | —                        | —                         | `PiecewiseFunction` only (in Definition section) |

The Value field shows the formatted base-unit quantity only (e.g. `0.3048 m`
for `ft`), without the `1 <name> =` prefix.  Long-pressing Name, Definition,
or Value copies the field text to the clipboard and shows a snackbar.  Aliases
are displayed in case-insensitive lexicographic order.  The Type section
always appears immediately below Aliases (or Name when there are no aliases).

Functions do not show a value because a function maps a value, not a fixed
scale factor; showing the domain and range specifications is more informative.
For `PiecewiseFunction` entries the control-point table is placed directly in
the Definition section; the Domain/Range section is omitted entirely.

For `PiecewiseFunction` entries, the detail page additionally renders the full
table of control points from `PiecewiseFunction.points` — a two-column table
of (input, output) value pairs in the order they are stored.  The column
headers use the domain and range unit expressions where available (from
`func.domain` and `func.range`), falling back to generic "Input" / "Output"
labels.

---

### 6. Navigation and feature structure

**Decision:** Browser becomes a third top-level page alongside Freeform and
Worksheet, accessible from the drawer.  `_TopLevelPage` gains a `browser`
variant; the `HomeScreen` body renders `BrowserScreen` for that variant.

`BrowserScreen` is a body-only widget (no `Scaffold`).  `HomeScreen` provides
the AppBar for the browse page, including the search toggle and view-mode
toggle buttons (rendered via `Consumer` widgets to avoid initializing
`browserProvider` before the user navigates to the browse page).  This mirrors
how `HomeScreen` manages AppBar actions for Freeform and Worksheet.

**Directory layout:**
```
lib/core/domain/models/
  browse_entry.dart              # BrowseEntry, BrowseEntryKind  (domain layer)

lib/features/browser/
  state/
    browser_provider.dart        # BrowserNotifier + providers
  presentation/
    browser_screen.dart          # Main browse list screen
    unit_entry_detail_screen.dart  # Detail page (pushed)
```

`BrowseEntry` lives in `lib/core/domain/models/` rather than a feature-local
`models/` directory because it is built by `UnitRepository.buildBrowseCatalog()`
and shared across domain and presentation layers.

**Rationale:** Follows the existing feature-per-directory pattern used by
`freeform/` and `worksheet/`.  The detail screen is pushed imperatively with
`Navigator.push`, consistent with `SettingsScreen` and `AboutScreen`.


## Risks / Trade-offs

**Grouped-view build time on slow devices** → Both indices are built once when
the browse page is first opened (provider initialization), then cached for the
session.  The cost is paid at navigation time, not at app startup.

**Group label readability for compound dimensions** → Rule 3 falls back to
canonical representation (e.g. `"kg m / s^2"`), which is technically correct
but less friendly.  A future `DimensionRegistry` could improve this; the
labelling logic is isolated in one helper so it is easy to replace.

**Alias count inflating the list** → With aliases, the list may feel
overwhelming.  No mitigation is planned for MVP; search and grouping are
sufficient navigation aids.  Future work could add a toggle to hide aliases.

**Detail page re-lookup** → The detail screen always receives `primaryId` +
`kind`, whether the tapped entry was a primary or an alias.  The O(1)
hash-map lookup is trivial; the important invariant is that `BrowseEntry`
stores the primary ID, not the alias name, so alias taps land on the correct
detail page.


## Open Questions

_(none — all major decisions resolved above)_
