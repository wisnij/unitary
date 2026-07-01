## Why

On devices with a display cutout (notch or camera hole), content in the app's
screens draws full-bleed to the physical screen edge and is obscured by the
cutout — for example, in landscape with a left-edge camera hole, part of the
Freeform "Convert to" field, the Browse unit list, and some Settings section
headers are hidden behind the hole.  No screen currently insets its body for the
device's safe area, so which content is obscured is a matter of accidental
alignment rather than deliberate layout.

## What Changes

- Every top-level screen insets its body content within the device-reported
  safe area (display cutouts, status/navigation bars), so no content is ever
  drawn behind a cutout or system bar, in any orientation.
- The persistent navigation rail (expanded width) is likewise kept clear of a
  cutout on its edge.
- Insets are read dynamically from the platform via `MediaQuery`; no
  device-specific values are hard-coded.
- The app is verified to actually opt into drawing under display cutouts on
  Android (edge-to-edge / cutout mode), so the platform reports non-zero cutout
  insets rather than silently letting `SafeArea` no-op.

## Capabilities

### New Capabilities

- `safe-area-insets`: All top-level screen bodies and the navigation rail keep
  their content within the device's safe area, using dynamically reported
  platform insets, across all supported orientations and cutout configurations.

### Modified Capabilities

<!-- None: the rail requirement is folded into the new capability to keep the
     safe-area concern cohesive; adaptive-navigation's existing requirements are
     unchanged. -->

## Impact

- **Affected code**: the five top-level screen `Scaffold` bodies
  (`freeform_screen.dart`, `worksheet_screen.dart`, `browser_screen.dart`,
  `settings_screen.dart`, `about_screen.dart`) and the navigation rail in
  `app_shell.dart`; pushed sub-screens with their own `Scaffold`
  (`UnitEntryDetailScreen`, `LicenseScreen`) as needed.
- **Platform config**: Android manifest / theme may need to confirm edge-to-edge
  or display-cutout mode so cutout insets are reported.
- **No new dependencies**; uses Flutter's built-in `SafeArea` / `MediaQuery`.
- **Out of scope**: enforcing 48dp minimum touch targets on the Freeform
  operator-key panel and tablet content-width/spacing polish — both belong to
  the Phase 9 accessibility / verification items and are tracked separately.
