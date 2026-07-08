# Worksheet UI — contrast-audit delta

## ADDED Requirements

### Requirement: Source row visual indicator
The active (source) row — the row whose value drives the conversion — SHALL be
visually identifiable by an indicator that meets a WCAG 2.x contrast ratio of
at least 3:1 against adjacent colors in both light and dark themes, and that
does not rely on color alone.

- The source row's value field SHALL render its enabled border in
  `colorScheme.primary` at 2 dp width; non-source rows keep the default
  `outline` border at default width.  The width difference is the non-color
  cue.
- The source row's field MAY additionally carry a supplementary background
  tint; the tint is not required to meet any contrast threshold on its own.
- The border treatment SHALL NOT change the field's overall height or the
  row's layout relative to non-source rows.

#### Scenario: Source row border visible in light mode
- **WHEN** the user types into a worksheet row in the light theme
- **THEN** that row's field shows a `primary`-colored 2 dp border whose
  contrast against the surface is at least 3:1, and other rows show the
  default border

#### Scenario: Indicator does not rely on color alone
- **WHEN** the source row's border is compared to a non-source row's border
- **THEN** they differ in width (2 dp vs default), not only in color

#### Scenario: Row heights unchanged
- **WHEN** a row becomes the source row
- **THEN** its field height and the vertical spacing of the worksheet rows are
  unchanged

#### Scenario: Focus without keystroke does not move the indicator
- **WHEN** the user taps a different row without typing
- **THEN** the source-row indicator remains on the previous source row
