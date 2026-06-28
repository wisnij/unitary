## MODIFIED Requirements

### Requirement: Navigation to detail page
Tapping any entry row SHALL select that entry's primary as the browse
selection.  Both primary and alias rows SHALL resolve to the same selection,
keyed by `BrowseEntry.primaryId` and `BrowseEntry.kind`.  The selected entry
SHALL be held in browser state (not passed as a navigation argument), so that
both the compact and wide presentations read a single source of truth.

Presentation of the selected entry's detail SHALL depend on the window size
class:

- At `compact` width: selecting an entry SHALL navigate to the
  `UnitEntryDetailScreen` for the selection using `Navigator.push`.
- At `medium` and `expanded` width: the browse page SHALL display the selected
  entry's detail in an embedded right pane beside the list, without pushing a
  route, and selecting a different entry SHALL update that pane in place.

#### Scenario: Tapping primary entry selects it
- **WHEN** the user taps an entry whose `aliasFor` is null
- **THEN** that entry's primary becomes the browse selection

#### Scenario: Tapping alias entry selects its primary
- **WHEN** the user taps an entry that is an alias
- **THEN** the alias's primary becomes the browse selection (the same selection
  as if the primary row had been tapped)

#### Scenario: Compact width pushes the detail screen
- **WHEN** the window size class is `compact` and the user taps an entry
- **THEN** the `UnitEntryDetailScreen` for that entry's primary is pushed

#### Scenario: Wide width shows detail in an embedded pane
- **WHEN** the window size class is `medium` or `expanded` and the user taps an
  entry
- **THEN** the entry's detail is shown in the embedded right pane and no route
  is pushed

#### Scenario: Selecting another entry updates the embedded pane
- **WHEN** the window size class is `medium` or `expanded`, an entry is already
  selected, and the user taps a different entry
- **THEN** the embedded right pane updates in place to show the newly selected
  entry's detail

### Requirement: Drawer integration
The browse page SHALL be accessible as a top-level destination from the app's
top-level navigation.

- The navigation surface SHALL include a "Browse" destination with an
  appropriate icon (a drawer tile at compact/medium widths, a rail destination
  at expanded width).
- Selecting "Browse" SHALL make `BrowserScreen` the active top-level page,
  following the same pattern as Freeform and Worksheet.

#### Scenario: Browse destination opens browser via drawer
- **WHEN** the window size class is `compact` or `medium` and the user opens the
  drawer and taps "Browse"
- **THEN** the `BrowserScreen` is displayed and the drawer closes

#### Scenario: Browse destination opens browser via rail
- **WHEN** the window size class is `expanded` and the user taps the "Browse"
  rail destination
- **THEN** the `BrowserScreen` is displayed

## ADDED Requirements

### Requirement: Empty detail pane when nothing is selected
The browse page's right pane SHALL show a "select a unit" placeholder, rather
than detail content, at `medium` and `expanded` widths whenever no entry is
currently selected.

#### Scenario: Placeholder shown before any selection
- **WHEN** the window size class is `medium` or `expanded` and no entry has been
  selected yet
- **THEN** the right pane shows a "select a unit" placeholder instead of a
  detail body

#### Scenario: Placeholder replaced once an entry is selected
- **WHEN** the right pane is showing the placeholder and the user taps an entry
- **THEN** the placeholder is replaced by that entry's detail body
