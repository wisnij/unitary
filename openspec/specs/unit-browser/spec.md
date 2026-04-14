# Unit Browser Spec

## Purpose

Define the requirements for the browse page, which displays the full catalog of
registered units, prefixes, and functions in both alphabetical and
dimension-grouped views, with search filtering and navigation to detail pages.

## Requirements

### Requirement: Browse catalog contents
The browser SHALL display every registered unit, prefix, and function from the
`UnitRepository`, including all aliases.  Each alias SHALL appear as its own
separate row, visually distinguished from primary entries.  The catalog SHALL
be built from `UnitRepository.buildBrowseCatalog()`.

#### Scenario: Primary unit appears in list
- **WHEN** the browser is open
- **THEN** every primary unit ID registered in the repository has a
  corresponding row in the list

#### Scenario: Alias appears as its own row
- **WHEN** a unit has one or more aliases
- **THEN** each alias is rendered as a separate row showing
  `"<decorated alias> = <primaryId>"` as the title

#### Scenario: Prefix name has trailing dash
- **WHEN** a prefix entry is rendered
- **THEN** the displayed name has a trailing dash (e.g. `"kilo-"`, `"milli-"`)

#### Scenario: Function name includes parameter list
- **WHEN** a function entry with one or more parameters is rendered
- **THEN** the displayed name includes the parameter names in parentheses
  (e.g. `"circlearea(r)"`)

#### Scenario: Functions and prefixes are included
- **WHEN** the browser is open
- **THEN** registered functions and prefixes (including their aliases) also
  appear in the list

---

### Requirement: Entry row display
Each row SHALL display a title and a one-line summary matching the style of
the conformable-units modal.

The displayed name SHALL be decorated based on entry kind:
- **Prefix entries** — name followed by a trailing dash (e.g. `"kilo-"`)
- **Function entries with parameters** — name followed by a parenthesized
  parameter list (e.g. `"circlearea(r)"`, `"interp(x, x0, x1, y0, y1)"`)
- **All other entries** — name unchanged

The title SHALL be:
- The decorated name for non-alias entries
- `"<decorated name> = <primaryId>"` for alias entries
  (e.g. `"a- = atto"` for the atto alias, `"Np(x) = neper"` for a function alias)

The summary line SHALL be:
- The definition expression for derived units and prefixes (e.g. `4.184 J`)
- `[primitive unit]` for primitive units
- `[function]` for non-piecewise functions
- `[piecewise linear function]` for `PiecewiseFunction` instances

#### Scenario: Derived unit row
- **WHEN** a derived unit entry is rendered
- **THEN** the summary line shows the unit's definition expression

#### Scenario: Primitive unit row
- **WHEN** a primitive unit entry is rendered
- **THEN** the summary line shows `[primitive unit]`

#### Scenario: Function row
- **WHEN** a non-piecewise function entry is rendered
- **THEN** the summary line shows `[function]`

#### Scenario: Piecewise function row
- **WHEN** a `PiecewiseFunction` entry is rendered
- **THEN** the summary line shows `[piecewise linear function]`

---

### Requirement: Alphabetical view
In the alphabetical view the catalog SHALL be displayed as a grouped list
keyed by the case-insensitive first character of the entry name.

- Groups A through Z contain entries whose name begins with the corresponding
  letter (case-insensitive).
- A final `#` group contains entries whose name begins with any non-letter
  character.
- Groups SHALL be sorted A → Z with `#` last.
- Entries within each group SHALL be sorted case-insensitively by name.
- All groups SHALL start collapsed when the alphabetical view is first entered.

#### Scenario: Letter group contains correct entries
- **WHEN** the alphabetical view is active
- **THEN** an entry whose name begins with `"f"` or `"F"` appears in the `F`
  group

#### Scenario: Non-letter entries in # group
- **WHEN** the alphabetical view is active
- **THEN** an entry whose name begins with a digit or symbol appears in the
  `#` group

#### Scenario: Groups start collapsed in alphabetical view
- **WHEN** the browser is navigated to for the first time in a session with
  the alphabetical view active
- **THEN** all letter groups are collapsed

---

### Requirement: Dimension view
In the dimension view the catalog SHALL be displayed as a grouped list keyed
by the resolved output dimension of each entry.

- Each distinct `Dimension` value forms one group.
- The group label SHALL be determined as follows:
  - If `units.json` defines a label for the canonical representation: the label
    followed by the canonical representation in parentheses, separated by a
    space (e.g. `"Acceleration (m / s^2)"`).
  - If no matching key exists: the canonical representation alone
    (e.g. `"m / s^2"`).
- Groups with a defined label SHALL sort before groups whose label is the
  canonical fallback.  Within each tier groups SHALL be sorted
  case-insensitively by their final label.
- Entries within each group SHALL be sorted case-insensitively by name.
- Entries whose dimension could not be resolved SHALL be excluded from the
  dimension view.
- All groups SHALL start collapsed when the dimension view is first entered or
  when the view toggle returns to dimension after visiting another view.
- The dimension view is the default view when the browse page is first opened
  in a session.

#### Scenario: Labeled dimension group shows label and canonical representation
- **WHEN** the dimension view is active and `units.json` defines a label for
  dimension `"m"`
- **THEN** all entries that resolve to `Dimension({m: 1})` appear in a group
  whose header reads `"<label> (m)"` (e.g. `"Length (m)"`)

#### Scenario: Unlabeled dimension falls back to canonical representation
- **WHEN** the dimension view is active and a dimension has no entry in the
  `"dimensions"` map
- **THEN** the group label equals the output of
  `dimension.canonicalRepresentation()` with no parenthesized suffix

#### Scenario: Labeled groups sort above unlabeled groups
- **WHEN** the dimension view is active and both labeled and unlabeled
  dimension groups are present
- **THEN** all labeled groups appear before all unlabeled groups in the list

#### Scenario: Unresolvable entry excluded from dimension view
- **WHEN** a unit's dimension cannot be resolved (e.g. circular definition)
- **THEN** that entry does not appear in any dimension group

#### Scenario: Dimension view groups start collapsed
- **WHEN** the dimension view is first shown
- **THEN** all group headers are visible but no entry rows are visible

#### Scenario: Dimension view is default on first open
- **WHEN** the browse page is opened for the first time in a session
- **THEN** the dimension view is active

---

### Requirement: Collapsible groups
Group headers in both views SHALL be tappable to toggle the expanded/collapsed
state of that group.

- A trailing chevron icon SHALL indicate the current state: pointing down when
  expanded, pointing right when collapsed.  This applies at all times, including
  while a search query is active.
- Collapsed groups show only their header row; entry rows are hidden.
- Switching between views SHALL reset each view to its default collapsed/
  expanded state (alphabetical: all collapsed; dimension: all collapsed).
- The AppBar SHALL contain an **Expand All** button (tooltip "Expand all") that
  expands every group in the current view by clearing the collapsed set.
- The AppBar SHALL contain a **Collapse All** button (tooltip "Collapse all")
  that collapses every group in the current view by adding all group labels to
  the collapsed set.
- Both buttons SHALL remain enabled and functional while a search query is
  active.

#### Scenario: Tapping an expanded group header collapses it
- **WHEN** a group is expanded and the user taps its header
- **THEN** the group's entry rows are hidden and the chevron points right

#### Scenario: Tapping a collapsed group header expands it
- **WHEN** a group is collapsed and the user taps its header
- **THEN** the group's entry rows become visible and the chevron points down

#### Scenario: Switching views resets collapse state
- **WHEN** the user expands some groups in the alphabetical view and then
  switches to the dimension view and back
- **THEN** the alphabetical view's groups are all collapsed again

#### Scenario: Expand All expands every group
- **WHEN** some groups are collapsed and the user taps the Expand All button
- **THEN** all group headers show the expanded chevron and all entry rows are
  visible

#### Scenario: Collapse All collapses every group
- **WHEN** some groups are expanded and the user taps the Collapse All button
- **THEN** all group headers show the collapsed chevron and no entry rows are
  visible

#### Scenario: Expand All and Collapse All are enabled during search
- **WHEN** a non-empty search query is active
- **THEN** the Expand All and Collapse All buttons are enabled and functional

#### Scenario: Tapping a group header during search shows correct chevron
- **WHEN** a non-empty search query is active and the user taps a group header
- **THEN** the chevron icon reflects the new collapsed/expanded state of that group

#### Scenario: Expand All during search expands all visible groups
- **WHEN** a non-empty search query is active and some groups are collapsed
- **THEN** tapping Expand All expands all groups and shows the expanded chevron
  for each

#### Scenario: Collapse All during search collapses all visible groups
- **WHEN** a non-empty search query is active and some groups are expanded
- **THEN** tapping Collapse All collapses all groups and shows the collapsed
  chevron for each

---

### Requirement: Search filtering
The browse page SHALL provide a search bar that filters the displayed list to
entries matching a query.

- An icon button in the AppBar SHALL toggle the search bar's visibility.
- While the search bar is visible, the user SHALL be able to type a query
  string.
- The list SHALL be filtered in real time to show only entries whose `name`
  contains the query string as a case-insensitive substring.
- Every change to the query that results in a non-empty string SHALL expand
  all groups (clear the collapsed set to empty).
- While the search bar is active, the user MAY still tap group headers to
  collapse individual groups.  However, any further change to the query string
  SHALL re-expand all groups again.
- The collapsed state before search was entered SHALL be saved when the query
  first transitions from empty to non-empty, and SHALL be restored when the
  query is cleared.
- Groups that contain no matching entries after filtering SHALL be hidden
  entirely.
- Dismissing the search bar or clearing the query SHALL restore the full list
  and the pre-search collapse state.

#### Scenario: Matching entries are shown
- **WHEN** the user types `"met"` in the search bar
- **THEN** only entries whose name contains `"met"` (case-insensitive) remain
  visible

#### Scenario: Non-matching entries are hidden
- **WHEN** the user types a query that matches no entry names
- **THEN** no entry rows are shown

#### Scenario: Empty groups are hidden during search
- **WHEN** a group contains no entries matching the current query
- **THEN** that group's header is also hidden

#### Scenario: Groups expand on every non-empty query change
- **WHEN** the user types any character into the search bar (resulting in a
  non-empty query)
- **THEN** all groups are expanded so their matching entries are visible

#### Scenario: Groups can be collapsed while search is active
- **WHEN** a non-empty query is active and the user taps a group header
- **THEN** that group collapses, hiding its entries

#### Scenario: Re-typing expands groups again
- **WHEN** the user has collapsed a group while a search is active and then
  modifies the query string
- **THEN** all groups are expanded again

#### Scenario: Collapse state restored after clearing search
- **WHEN** the user clears the search query
- **THEN** groups that were collapsed before the search was started are
  collapsed again, and groups that were expanded remain expanded

---

### Requirement: Navigation to detail page
Tapping any entry row SHALL navigate to the `UnitEntryDetailScreen` for the
entry's primary.

- Both primary and alias rows SHALL navigate to the same detail page, keyed
  by `BrowseEntry.primaryId` and `BrowseEntry.kind`.
- Navigation SHALL use `Navigator.push`.

#### Scenario: Tapping primary entry navigates to its detail page
- **WHEN** the user taps an entry whose `aliasFor` is null
- **THEN** the detail page opens showing that entry's primary information

#### Scenario: Tapping alias entry navigates to primary's detail page
- **WHEN** the user taps an entry that is an alias
- **THEN** the detail page opens for the alias's primary (same page as if the
  primary row had been tapped)

---

### Requirement: Fast-scroll bar in browse list
The browse list SHALL display a `FastScrollBar` overlay in both alphabetical
and dimension views.

- The `FastScrollBar` SHALL be supplied the `ScrollController` owned by the
  browse list widget, the total flat-list item count, and a `groupAnchors` list
  derived from the flat item list (one entry per group header, in order).
- The `FastScrollBar` SHALL be inactive (`active: false`) whenever the search
  query is non-empty, hiding the thumb and label bubble for the duration of
  the search.
- In alphabetical view the group anchor labels SHALL be the single-character
  letter (or `#`) of each group header.
- In dimension view the group anchor labels SHALL be the human-readable
  dimension name of each group header.

#### Scenario: Fast-scroll thumb visible on browse list
- **WHEN** the browse page is open with enough entries to scroll
- **THEN** scrolling the list causes the fast-scroll thumb to appear on the
  right edge

#### Scenario: Label shows letter group in alphabetical view
- **WHEN** the alphabetical view is active and the user drags the thumb
- **THEN** the label bubble shows the letter of the group at the current
  scroll position (e.g. `"M"`)

#### Scenario: Label shows dimension name in dimension view
- **WHEN** the dimension view is active and the user drags the thumb
- **THEN** the label bubble shows the human-readable dimension name of the
  group at the current scroll position (e.g. `"Length"`)

#### Scenario: Fast-scroll hidden during search
- **WHEN** the user has entered a non-empty search query
- **THEN** the fast-scroll thumb is not shown

---

### Requirement: Drawer integration
The browse page SHALL be accessible as a top-level destination from the
navigation drawer.

- The drawer SHALL include a "Browse" tile with an appropriate icon.
- Selecting "Browse" SHALL switch the home screen body to `BrowserScreen`,
  following the same pattern as Freeform and Worksheet.

#### Scenario: Browse tile opens browser
- **WHEN** the user opens the drawer and taps "Browse"
- **THEN** the `BrowserScreen` is displayed and the drawer closes
