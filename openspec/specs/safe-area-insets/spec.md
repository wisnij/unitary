# Safe Area Insets

## Purpose

Ensures that every top-level screen and the navigation rail keep their content
clear of device display cutouts, status bars, and navigation bars by using
platform-reported safe-area insets, and that the host platform is configured to
report those insets.

## Requirements

### Requirement: Screen content stays within the device safe area

Every top-level screen SHALL inset its body content within the device's safe
area so that no interactive control, text, or field is drawn behind a display
cutout, status bar, or navigation bar.  The safe-area insets SHALL be obtained
dynamically from the platform (via `MediaQuery` / `SafeArea`); no device- or
orientation-specific inset values SHALL be hard-coded.

#### Scenario: Landscape with an edge cutout

- **WHEN** the app is shown in landscape on a device whose display cutout
  intrudes on a screen edge
- **THEN** the visible content of every top-level screen (Freeform, Worksheet,
  Browse, Settings, About) is offset away from that edge by the reported cutout
  inset, so no field, list row, section header, or button is obscured by the
  cutout

#### Scenario: Device with no cutout

- **WHEN** the app is shown on a device or window with no display cutout and no
  overlapping system bars along a content edge
- **THEN** that edge receives no additional inset and the layout is unchanged
  from before this change

#### Scenario: Orientation change moves the cutout

- **WHEN** the device is rotated so the cutout moves to a different screen edge
- **THEN** the inset follows the cutout to the new edge automatically, without
  any code path selecting an inset per orientation

### Requirement: Navigation rail stays within the device safe area

At the expanded window size class, the persistent navigation rail SHALL keep its
destinations and controls clear of a display cutout or system bar on the rail's
edge, using the platform-reported safe-area insets.

#### Scenario: Cutout on the rail edge

- **WHEN** the app is shown at expanded width with a display cutout on the same
  edge as the navigation rail
- **THEN** the rail's icons and labels are offset clear of the cutout and remain
  fully visible and tappable

### Requirement: Platform reports display-cutout insets

The app SHALL be configured so the host platform reports non-zero safe-area
insets for display cutouts (for example, drawing edge-to-edge / into the cutout
region on Android), so that safe-area handling is driven by real platform insets
rather than silently having nothing to inset.

#### Scenario: Android cutout inset is reported

- **WHEN** the app runs on an Android device with a display cutout
- **THEN** `MediaQuery` reports a non-zero safe-area inset on the cutout's edge,
  and the safe-area handling insets content accordingly
