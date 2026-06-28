# Window Size Class

## Purpose

Defines the `WindowSizeClass` abstraction that derives a coarse layout category
(compact, medium, expanded) from the current layout width, providing a single
source of truth for all width-adaptive UI in the app.

## Requirements

### Requirement: Window size class derived from width
The application SHALL provide a `WindowSizeClass` value with exactly three
cases — `compact`, `medium`, and `expanded` — derived purely from the current
layout width as reported by `MediaQuery`.  The thresholds SHALL be:

- `compact`: width `< 600`
- `medium`: width `>= 600` and `<= 1040`
- `expanded`: width `> 1040`

These two breakpoints SHALL be the single source of truth used by all
width-adaptive UI in the app.  The size class SHALL recompute whenever the
layout width changes (e.g. window resize, orientation change).

#### Scenario: Narrow width is compact
- **WHEN** the available width is `500`
- **THEN** the window size class is `compact`

#### Scenario: Lower boundary is medium
- **WHEN** the available width is exactly `600`
- **THEN** the window size class is `medium`

#### Scenario: Mid width is medium
- **WHEN** the available width is `800`
- **THEN** the window size class is `medium`

#### Scenario: Upper boundary is medium
- **WHEN** the available width is exactly `1040`
- **THEN** the window size class is `medium`

#### Scenario: Wide width is expanded
- **WHEN** the available width is `1400`
- **THEN** the window size class is `expanded`

#### Scenario: Size class follows a resize
- **WHEN** the available width changes from `500` to `1400`
- **THEN** the window size class changes from `compact` to `expanded`
