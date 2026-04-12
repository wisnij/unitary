## Why

The alphabetical view on the browse page currently opens with all letter groups
expanded, immediately flooding the user with hundreds of rows.  Starting
collapsed — consistent with the dimension view — gives users a lighter first
impression and lets them drill into the letters they care about.

## What Changes

- The alphabetical view default collapse state changes from **all expanded** to
  **all collapsed**, matching the dimension view's existing default behaviour.

## Capabilities

### New Capabilities

_(none)_

### Modified Capabilities

- `unit-browser`: The alphabetical view default state changes from all-expanded
  to all-collapsed.

## Impact

- `BrowserNotifier` (state management) — default for alphabetical view changes.
- `unit-browser` spec — one requirement and one scenario updated.
- No API, dependency, or data-format changes.
