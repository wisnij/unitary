## Why

On wide layouts (landscape tablets, desktop web) the single-column content on
several screens stretches to fill the entire pane, producing uncomfortably wide
input fields and long line lengths.  The Freeform and Worksheet input areas and
the Settings page are the clearest offenders: their content sits in a full-width
pane with nothing capping its width.

## What Changes

- Introduce a shared "readable content width" wrapper that centers single-column
  content within a maximum width (600 dp to start).
- Apply it to the Freeform input/output/result column, the Worksheet row table,
  and the Settings body.
- The cap only takes effect when the available width exceeds it: at phone widths
  the constraint never binds, so those layouts are unchanged.

## Capabilities

### New Capabilities

- `content-max-width`: Single-column screen content is constrained to a maximum
  readable width and centered when the pane is wider than that maximum, while
  remaining full-width on narrow (phone) layouts.

### Modified Capabilities

<!-- None: this is additive layout behavior; no existing requirement changes. -->

## Impact

- **Affected code**: `freeform_screen.dart`, `worksheet_screen.dart`,
  `settings_screen.dart`; a small shared widget under `lib/shared/`.
- **No new dependencies**; uses Flutter's built-in `Center` / `ConstrainedBox`.
- **No behavior change at phone width** — the constraint is inert below the cap.
- **Out of scope / deferred**: applying the cap to the Browse detail pane and the
  About screen (can follow once 600 dp is validated on-device), and any change to
  padding scale or the fixed pane widths (220/320 dp).
