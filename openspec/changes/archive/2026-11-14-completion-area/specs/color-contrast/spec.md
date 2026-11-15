## MODIFIED Requirements

### Requirement: Decorative usages are exempt and recorded
Purely decorative visual elements SHALL be exempt from the 3:1 non-text
threshold, consistent with WCAG 1.4.11.  An element is decorative when it is
not required to identify a component, its state, or its boundary.  The accepted decorative usages are:

- `outlineVariant` borders on unit-detail tables (the tables are identified by
  their layout).
- The `surfaceContainerHighest`-derived background tints of the currency
  banner and the browse sticky group headers (supplementary grouping cues;
  the text they carry meets 4.5:1 on the tinted background).

New decorative exemptions SHALL be added to this list rather than silently
skipped by the contrast test.

#### Scenario: Decorative border unchanged
- **WHEN** a unit-detail table renders its `outlineVariant` border at below
  3:1 against the surface
- **THEN** this is conformant, because the table is identified by its layout
  rather than the border
