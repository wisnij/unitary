## Why

A WCAG 2.x contrast audit of the app's custom-styled widgets (Phase 9
accessibility item) found that all standard Material 3 role pairings pass, but
three custom alpha-blended colorings fail: the worksheet source-row fill is
nearly invisible (1.06:1 light / 1.17:1 dark) and is the *only* indicator of
which row drives the conversion; the fast-scroll preview's de-emphasised
neighbour labels fail the 4.5:1 text threshold (3.77 / 3.50); and the
fast-scroll thumb fails the 3:1 non-text threshold against the light surface
(2.64).  Nothing pins these ratios today, so future styling changes could
silently regress them.

## What Changes

- Replace the worksheet source-row indicator (currently a `primaryContainer`
  alpha-0.3 fill) with a perceivable indicator that meets 3:1 non-text contrast
  and does not rely on color alone (border-based cue; fill retained only as a
  supplementary tint).
- Raise the fast-scroll preview neighbour-label contrast to ≥4.5:1 (adjust the
  `onPrimary` alpha).
- Raise the fast-scroll thumb's contrast against the page background to ≥3:1 in
  both themes (adjust the `primary` alpha), and derive the grip-line color from
  `onPrimary` so it measurably contrasts with the thumb in both themes.
- Add an automated contrast regression test that computes WCAG relative
  luminance / contrast ratios for the app's custom-composed color pairings
  (including alpha blends) in both light and dark schemes and asserts the
  required thresholds.
- Document the audit's reviewed-and-accepted decorative usages
  (`outlineVariant` borders, banner / sticky-header background tints) so they
  are not re-flagged later.

## Capabilities

### New Capabilities

- `color-contrast`: WCAG 2.x contrast requirements for the app's
  custom-composed color pairings (text ≥4.5:1, non-text UI indicators ≥3:1, in
  both light and dark themes), enforced by an automated test; records which
  decorative usages are exempt and why.

### Modified Capabilities

- `worksheet-ui`: adds a requirement that the active (source) row is visually
  identifiable via an indicator meeting 3:1 non-text contrast that does not
  rely on color alone.  (No such requirement exists today; the fill was an
  unspecified implementation detail.)
- `fast-scroll-bar`: the qualitative "contrasts / legible" wording in the
  drag-handle and group-label-bubble requirements becomes measurable — thumb
  ≥3:1 against the page background, neighbour labels ≥4.5:1 against the panel,
  grip lines ≥3:1 against the thumb — in both themes.

## Impact

- `lib/features/worksheet/presentation/worksheet_screen.dart` — source-row
  indicator styling.
- `lib/shared/widgets/fast_scroll_bar.dart` — thumb, grip-line, and preview
  label colors.
- New test (e.g. `test/shared/color_contrast_test.dart`) computing contrast
  ratios from `ColorScheme.fromSeed(Colors.blue)` light/dark schemes.
- Existing worksheet and fast-scroll-bar widget tests may need updated color
  expectations.
- No new dependencies; no behavior changes outside visual styling.
