# Proposal: worksheet-page-layout

## Why

Worksheet mode currently behaves as a sub-page pushed onto the navigation
stack, so the AppBar shows a back-arrow that returns to freeform mode.  This
implies a hierarchical parent/child relationship that does not exist — worksheet
and freeform are sibling top-level modes, and the UI should reflect that by
showing the hamburger menu icon instead of a back arrow.

## What Changes

- Worksheet screen is rendered as a top-level destination (hamburger icon in
  AppBar leading position) rather than a pushed route (back-arrow icon).
- Navigation between freeform and worksheet uses the drawer as the sole
  switching mechanism, consistent with how all top-level pages work.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `worksheet-ui`: The worksheet screen's AppBar leading widget changes from an
  implicit back-arrow (pushed route) to a hamburger menu icon (drawer toggle),
  matching the freeform screen's navigation chrome.

## Impact

- `lib/features/worksheet/` — screen/navigation wiring
- `lib/features/freeform/` or `lib/shared/` — wherever the drawer scaffold is
  defined and routes are registered
- No new dependencies; no API or data model changes
