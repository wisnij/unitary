# Content Max Width

## Purpose

Caps single-column screen content at a readable maximum width and centers it when
the available space is wider, so that on large windows (such as landscape tablets)
the Freeform, Worksheet, and Settings content does not stretch uncomfortably wide.

## Requirements

### Requirement: Single-column content is capped at a readable width

Screens whose primary content is a single column (the Freeform input/output/result
area, the Worksheet row table, and the Settings body) SHALL constrain that content
to a maximum width and center it horizontally when the available width exceeds the
maximum.  The maximum readable width SHALL be 600 logical pixels.

#### Scenario: Wide pane centers the content

- **WHEN** one of these screens is shown in a pane wider than the maximum readable
  width (e.g. a landscape tablet)
- **THEN** the content column is capped at the maximum width and centered
  horizontally, leaving equal margins on both sides

#### Scenario: Narrow pane is unchanged

- **WHEN** one of these screens is shown in a pane narrower than or equal to the
  maximum readable width (e.g. a phone)
- **THEN** the content fills the available width exactly as before, with the
  width cap having no visible effect

### Requirement: The readable-width cap is a shared, consistent value

The maximum readable width SHALL be defined once and shared across the screens
that use it, so the cap is consistent and adjustable from a single place.

#### Scenario: Consistent cap across screens

- **WHEN** the Freeform, Worksheet, and Settings screens are each shown wide
  enough to trigger the cap
- **THEN** all three constrain their content to the same maximum width
