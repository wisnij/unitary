## Context

The app uses stock `ColorScheme.fromSeed(Colors.blue)` in both light and dark
mode (`lib/app.dart`), so every color is deterministic and WCAG 2.x contrast
ratios can be computed exactly.  The audit (July 7, 2026) computed ratios for
every color pairing the app composes itself, including alpha blends composited
over their actual backgrounds.

Audit results (light / dark, WCAG 2.x relative-luminance contrast):

| #  | Pairing                                                                       | Light     | Dark      | Threshold | Verdict          |
|----|-------------------------------------------------------------------------------|-----------|-----------|-----------|------------------|
| —  | `onSurfaceVariant` on `surface` (hints, muted text)                           | 8.88      | 10.90     | 4.5       | pass             |
| —  | Currency banner: `onSurfaceVariant` on `surfaceContainerHighest`              | 7.22      | 7.26      | 4.5       | pass             |
| —  | `primary` result text, error text, browse group headers on their backgrounds  | 5.54–10.9 | ≥9.1      | 4.5       | pass             |
| 1  | Worksheet source-row fill: `primaryContainer`@0.3 over `surface` vs `surface` | 1.06      | 1.17      | 3.0       | **fail**         |
| 2  | Fast-scroll preview neighbour labels: `onPrimary`@0.65 on `primary`           | 3.77      | 3.50      | 4.5       | **fail**         |
| 3  | Fast-scroll thumb: `primary`@0.6 over `surface` vs `surface`                  | 2.64      | 4.61      | 3.0       | **fail (light)** |
| 3a | Grip lines: `onSurface`@0.4 over thumb vs thumb                               | 2.00      | 1.65      | 3.0       | fail, but see D4 |
| 4  | `outlineVariant` borders vs `surface` (completion overlay, detail tables)     | 1.61      | 1.98      | 3.0       | accepted (D5)    |
| 4  | Banner / sticky-header background tints vs `surface`                          | 1.06–1.23 | 1.17–1.50 | 3.0       | accepted (D5)    |

Finding 1 is the most serious: since focus alone does not transfer source
ownership ("last keystroke wins"), the alpha-0.3 fill is the *only* visual cue
for which row drives the conversion, and at 1.06:1 it is effectively invisible
in light mode.  This fails WCAG 1.4.11 (non-text contrast for state
indicators) and 1.4.1 (use of color), and is a plain usability bug.

The two candidates named in the implementation plan (the muted currency banner
and `onSurfaceVariant` text) pass comfortably — Material 3's tonal system
guarantees its standard role pairings, and every failure involves a custom
alpha blend.

## Goals / Non-Goals

**Goals:**

- Make the worksheet source row identifiable with an indicator meeting 3:1
  non-text contrast in both themes, not relying on color alone.
- Bring the fast-scroll preview neighbour labels to ≥4.5:1 and the thumb to
  ≥3:1 in both themes.
- Pin all custom-composed pairings with an automated contrast regression test
  so styling changes cannot silently regress them.
- Record the accepted decorative usages so they are not re-flagged by future
  audits.

**Non-Goals:**

- Restyling default Material components (Settings, drawer, AppBars,
  snackbars): they use M3's guaranteed role pairings unmodified.
- Changing the visual design language (the source-row cue should stay
  unobtrusive, just perceivable).
- APCA / WCAG 3 contrast metrics; the audit and test use WCAG 2.x.
- Runtime contrast checking or dynamic-color support (the schemes are static).
- The 48 dp touch-target audit (separate Phase 9 item).

## Decisions

### D1: Source-row indicator = thicker `primary` border + retained tint

The active (source) row's `TextField` gets a visible border cue: its enabled
outline border uses `colorScheme.primary` at increased width (2 dp vs the
default 1 dp), while inactive rows keep the default `outline` border.  The
existing `primaryContainer` alpha-0.3 fill is retained as a supplementary
tint.

Rationale:

- **A fill alone cannot pass.**  Even solid `primaryContainer` is only ~1.2:1
  against the light surface; a fill dark enough to reach 3:1 (tone ≈ 60)
  would be visually heavy and would wreck the field's own text contrast.
- `primary` is 6.14:1 (light) / 10.87:1 (dark) against `surface`, clearing
  the 3:1 indicator threshold with a wide margin in both themes.
- The width difference (2 dp vs 1 dp) is a shape cue, satisfying WCAG 1.4.1's
  "not color alone" requirement without adding new UI elements.
- Alternatives considered:
  - *Solid `primaryContainer` fill* — rejected: fails 3:1 in light mode (see
    above).
  - *Leading marker icon/dot* — rejected: adds a new element to every row,
    shifts the layout, and duplicates what the border communicates.
  - *Bold row label* — rejected: the label belongs to the row, not the field,
    and weight changes cause width jitter in the label column.

### D2: Preview neighbour labels use `onPrimary` at alpha 0.85

`fast_scroll_bar.dart:465` changes `withValues(alpha: 0.65)` → `0.85`.
Computed: 4.81:1 light / 5.56:1 dark — passes 4.5:1 in both.  The
current-vs-neighbour distinction is preserved because it is also carried by
size (titleMedium vs bodySmall) and weight (bold vs regular).

### D3: Thumb uses `primary` at alpha 0.8

`fast_scroll_bar.dart:390` changes `withValues(alpha: 0.6)` → `0.8`.
Computed: 3.93:1 light (up from 2.64) / ≥4.6 dark — passes 3:1 in both.  Some
translucency is kept so list content remains faintly visible through the
thumb.

### D4: Grip lines derive from `onPrimary`, not `onSurface`

`fast_scroll_bar.dart:385` changes `onSurface.withValues(alpha: 0.4)` →
`onPrimary.withValues(alpha: 0.9)`.  The grip lines sit on a `primary`-tinted
thumb, so `onPrimary` is the natural role; `onSurface` was a mismatch that
happened to look acceptable.  Strictly the grip lines are decorative texture
(the thumb is identified by its pill shape and fill) and thus exempt from
1.4.11, but the existing `fast-scroll-bar` spec already requires them to
"contrast with the pill background", and this makes that requirement
measurable and true (white-derived lines on a mid-blue thumb in light mode;
dark-navy lines on a light-blue thumb in dark mode, both ≥3:1 against the
composited thumb).

### D5: `outlineVariant` borders and background tints are accepted as decorative

The completion-overlay border, unit-detail table rules (`outlineVariant`,
1.6–2.0:1), the currency banner background, and the browse sticky-header
tint (1.06–1.5:1) stay as they are:

- Material 3's own guidance designates `outlineVariant` for decorative
  dividers; the completion overlay is additionally delineated by elevation
  and its filled surface, and the tables read fine without visible rules.
- The banner and sticky-header tints are supplementary grouping cues; the
  text they carry passes 4.5:1 on the tinted background, and nothing is
  communicated by the boundary itself.

WCAG 1.4.11 exempts visual information not required to identify the component,
so these are conformant as-is.  This decision is recorded in the
`color-contrast` spec so future audits do not re-litigate them.

### D6: Regression test computes ratios from the real schemes

A new test (`test/shared/color_contrast_test.dart`) instantiates the same
`ColorScheme.fromSeed(Colors.blue)` light/dark schemes as `app.dart`, contains
a small WCAG relative-luminance / contrast-ratio implementation plus an
alpha-compositing helper (`fg` over opaque `bg`), and asserts the threshold
for every custom pairing (the pass *and* fixed rows of the audit table, at
their post-fix values).

- The test intentionally duplicates the literal role/alpha choices from the
  widgets rather than reading them out of the widget tree: it is a design
  contract ("these composed colors must clear these ratios"), and a
  widget-tree probe would be far more brittle for no additional assurance.
  A comment on each entry names the widget/line it mirrors, so a styling
  change that forgets the test will still fail loudly (the old pairing no
  longer exists is not detectable, but the *thresholds* are what matter and
  new pairings should be added alongside).
- Alternative considered: golden-image tests — rejected: goldens detect any
  pixel change, not contrast specifically, and are platform-sensitive.

## Risks / Trade-offs

- [The 2 dp active border changes field geometry by 1 dp per edge] → use
  `BorderSide(width: 2)` inside the existing `OutlineInputBorder` so the
  field's overall size is unchanged (Flutter draws the border inward);
  verify no row-height jitter in widget tests.
- [Contrast test duplicates color/alpha literals from widgets] → accepted
  (see D6); each entry carries a file:line comment, and the widget tests
  assert the widgets use the expected roles/alphas where practical.
- [Thumb at alpha 0.8 darkens the fast-scroll thumb noticeably in light
  mode] → visual check on-device; the thumb is transient UI shown only
  during scrolling.
- [Future `fromSeed` algorithm changes in a Flutter upgrade could shift
  tones] → this is exactly what the regression test is for; it will flag
  the pairing that dipped below threshold.

## Open Questions

- None blocking.  On-device visual confirmation of the new source-row border
  and thumb alpha is part of verification.
