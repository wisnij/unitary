## Why

Worksheet mode currently defaults to the Length template on first launch, an
arbitrary choice that presents the user with a populated worksheet they may not
want.  Browse mode already handles the analogous situation gracefully by showing
nothing until the user picks a unit.  Worksheet mode should behave the same way:
start with no worksheet selected and let the user choose one.

## What Changes

- On first launch (no persisted selection), no worksheet is active.  Once the
  user selects a worksheet, the choice is remembered across sessions exactly as
  today.
- At `compact` width with no worksheet selected, the screen shows the worksheet
  template list (the same list used in the left pane at wider widths).
  Selecting a template replaces the list with that worksheet.
- At `medium` and `expanded` width with no worksheet selected, the left-pane
  template list is shown as usual and the right pane displays a centered
  "Select a worksheet" placeholder, mirroring Browse mode's empty detail pane.
- The persisted active-worksheet value becomes optional; the old hard-coded
  fall-back to `length` is removed.

## Capabilities

### New Capabilities

(none)

### Modified Capabilities

- `worksheet-ui`: the worksheet screen gains a no-selection state — a full-screen
  template list at compact width and a "Select a worksheet" placeholder in the
  right pane at medium/expanded width; the AppBar adapts when nothing is
  selected.
- `worksheet-persistence`: the active worksheet is no longer defaulted to
  `length`; absence of a persisted (or recognised) selection means no worksheet
  is active rather than falling back to Length.

## Impact

- `lib/features/worksheet/state/worksheet_state.dart` — `worksheetId` becomes
  nullable.
- `lib/features/worksheet/state/worksheet_provider.dart` — build/selection logic
  for a null active worksheet.
- `lib/features/worksheet/data/worksheet_repository.dart` —
  `activeWorksheetId` becomes nullable; default and unrecognised-ID handling
  updated.
- `lib/features/worksheet/presentation/worksheet_screen.dart` — render the
  template-list / placeholder states and adapt the AppBar.
- Existing worksheet UI and persistence tests updated accordingly.
