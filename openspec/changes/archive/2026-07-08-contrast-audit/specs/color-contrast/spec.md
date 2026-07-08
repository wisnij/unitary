# Color Contrast

Defines WCAG 2.x contrast requirements for color pairings the app composes
itself (custom roles-on-nonstandard-backgrounds and alpha blends).  Standard
Material 3 role pairings used unmodified (e.g. `onSurface` on `surface`) are
covered by the M3 tonal system's own guarantees and are outside this spec.

## ADDED Requirements

### Requirement: Custom text pairings meet WCAG 4.5:1
Every custom-composed text coloring (a text color placed on a background other
than its standard Material 3 role pairing, or involving an alpha blend) SHALL
have a WCAG 2.x contrast ratio of at least 4.5:1 against its effective
background, in both the light and dark color schemes.  Alpha-blended colors
SHALL be evaluated after compositing over their actual opaque background.

#### Scenario: Muted text on tinted banner passes
- **WHEN** `onSurfaceVariant` body text is rendered on the
  `surfaceContainerHighest` currency banner in either theme
- **THEN** its contrast ratio against the banner background is at least 4.5:1

#### Scenario: Fast-scroll neighbour labels pass
- **WHEN** the de-emphasised neighbour labels are rendered in the fast-scroll
  group label panel in either theme
- **THEN** their composited color has a contrast ratio of at least 4.5:1
  against the panel's `primary` background

### Requirement: Custom non-text indicators meet WCAG 3:1
Every custom-drawn UI component or state indicator whose recognition depends
on its color (e.g. the fast-scroll thumb, the worksheet source-row indicator)
SHALL have a WCAG 2.x contrast ratio of at least 3:1 against adjacent colors,
in both the light and dark color schemes.

#### Scenario: Source-row indicator perceivable in light mode
- **WHEN** a worksheet row is the active source row in the light theme
- **THEN** the visual indicator marking it has a contrast ratio of at least
  3:1 against the surrounding surface

#### Scenario: Scroll thumb perceivable in light mode
- **WHEN** the fast-scroll thumb is rendered over the light-theme surface
- **THEN** its composited fill has a contrast ratio of at least 3:1 against
  that surface

### Requirement: Contrast thresholds are enforced by an automated test
An automated test SHALL compute WCAG 2.x relative-luminance contrast ratios
for the app's custom-composed color pairings, using the same
`ColorScheme.fromSeed` light and dark schemes the app constructs, compositing
alpha-blended colors over their actual backgrounds, and SHALL fail if any
pairing drops below its required threshold (4.5:1 text, 3:1 non-text).

#### Scenario: Regression detected
- **WHEN** a code or Flutter-upgrade change causes a listed pairing to fall
  below its threshold
- **THEN** the contrast test fails, identifying the pairing

#### Scenario: Both themes covered
- **WHEN** the contrast test runs
- **THEN** every listed pairing is checked in both the light and dark schemes

### Requirement: Decorative usages are exempt and recorded
Purely decorative visual elements — those not required to identify a
component, its state, or its boundary — are exempt from the 3:1 non-text
threshold, consistent with WCAG 1.4.11.  The accepted decorative usages are:

- `outlineVariant` borders on the completion overlay (also delineated by
  elevation and a filled surface) and on unit-detail tables.
- The `surfaceContainerHighest`-derived background tints of the currency
  banner and the browse sticky group headers (supplementary grouping cues;
  the text they carry meets 4.5:1 on the tinted background).

New decorative exemptions SHALL be added to this list rather than silently
skipped by the contrast test.

#### Scenario: Decorative border unchanged
- **WHEN** the completion overlay renders its `outlineVariant` border at below
  3:1 against the surface
- **THEN** this is conformant, because the overlay is identified by its
  elevation and filled surface rather than the border
