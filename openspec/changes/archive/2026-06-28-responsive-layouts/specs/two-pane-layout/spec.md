## ADDED Requirements

### Requirement: Two-pane layout collapses by window size class
The application SHALL provide a reusable two-pane layout that accepts a left
pane and a right pane and chooses its presentation from the current
`WindowSizeClass`:

- At `medium` and `expanded`: both panes SHALL be displayed side by side,
  separated by a visible vertical divider.
- At `compact`: only the page's designated single pane SHALL be displayed; the
  other pane SHALL NOT occupy layout space.

The layout SHALL contain no page-specific logic about units, templates, or
history.

#### Scenario: Both panes shown at medium width
- **WHEN** a two-pane layout is built at `medium` width
- **THEN** both the left and right panes are visible side by side with a
  divider between them

#### Scenario: Both panes shown at expanded width
- **WHEN** a two-pane layout is built at `expanded` width
- **THEN** both the left and right panes are visible side by side with a
  divider between them

#### Scenario: Single pane at compact width
- **WHEN** a two-pane layout is built at `compact` width
- **THEN** only the designated single pane is displayed and the other pane
  occupies no layout space

#### Scenario: Panes scroll independently
- **WHEN** both panes are displayed and each contains scrollable content
- **THEN** scrolling one pane does not move the other

### Requirement: Configurable per-pane sizing
The two-pane layout SHALL accept an independent size specification for each pane
with exactly three modes:

- **fixed** — the pane SHALL occupy an exact width in logical pixels.
- **fit-content** — the pane SHALL size to its content's natural width, clamped
  to optional minimum and maximum widths when provided.
- **fill** — the pane SHALL expand to absorb the remaining horizontal space,
  divided among multiple fill panes in proportion to an integer flex factor.

The layout SHALL lay out non-fill panes first at their fixed or fit-content
width and then distribute the remaining width among fill panes by flex.  A
proportional (ratio) split SHALL be expressed by giving both panes the fill mode
with the desired flex factors (e.g. left flex `1`, right flex `2` for a 1:2
split).  Per-pane sizing applies only when both panes are shown (medium and
expanded); it has no effect at compact width.

#### Scenario: Fixed pane uses its exact width
- **WHEN** the left pane is configured as fixed at `320`
- **THEN** the left pane is `320` wide and the right pane fills the remaining
  width

#### Scenario: Fit-content pane sizes to its content
- **WHEN** the left pane is configured as fit-content and its content has a
  natural width of `180`
- **THEN** the left pane is `180` wide and the right pane fills the remaining
  width

#### Scenario: Fit-content respects its maximum
- **WHEN** a pane is configured as fit-content with a maximum of `360` and its
  content would naturally be wider than `360`
- **THEN** the pane is `360` wide

#### Scenario: Fit-content respects its minimum
- **WHEN** a pane is configured as fit-content with a minimum of `130` and its
  content would naturally be narrower than `130`
- **THEN** the pane is `130` wide

#### Scenario: Two fill panes split by ratio
- **WHEN** the left pane is fill with flex `1` and the right pane is fill with
  flex `2`
- **THEN** the left pane occupies one third and the right pane two thirds of the
  available width
