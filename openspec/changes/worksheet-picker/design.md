## Context

Worksheet mode hard-codes `length` as the active template wherever a selection
is missing: `WorksheetPersistState.defaults.activeWorksheetId == 'length'`,
`WorksheetRepository.load()` falls back to `'length'` for missing or
unrecognised data, and `WorksheetState.worksheetId` is a non-nullable `String`.
The screen always resolves `predefinedWorksheets.firstWhere((t) => t.id ==
activeId)` and renders that template's rows.

Browse mode already solves the analogous "nothing selected yet" problem: its
state holds a nullable `selectedPrimaryId`, the right pane renders an
`_EmptyDetailPane` ("Select a unit to view details") when it is null, and at
compact width the detail is a pushed route rather than an embedded pane.  This
change brings worksheet mode in line with that pattern.

## Goals / Non-Goals

**Goals:**

- No worksheet is active on first launch; the user explicitly picks one.
- A selected worksheet is still persisted and restored exactly as today.
- Compact width: show the template list full-screen until a worksheet is
  selected, then show the worksheet.
- Medium/expanded width: keep the left-pane list and show a "Select a worksheet"
  placeholder in the right pane until one is selected.

**Non-Goals:**

- No change to the conversion engine, row widget, per-template value retention,
  or persisted per-template source values.
- No new way to return to a "nothing selected" state once a worksheet is chosen
  (the dropdown / left-pane list remain the switchers, as today).
- No change to drawer/rail navigation behavior.

## Decisions

### Make the active worksheet id nullable end-to-end

`WorksheetState.worksheetId` becomes `String?`; `WorksheetPersistState.activeWorksheetId`
becomes `String?`.  `WorksheetPersistState.defaults` uses `null`.
`WorksheetRepository.load()` returns `null` for the active id when there is no
stored value, the JSON is malformed, or the stored id is not a known template
(instead of substituting `'length'`).  This mirrors Browse's nullable
`selectedPrimaryId`.

*Alternative considered:* a sentinel value or a separate `hasSelection` flag.
Rejected — a nullable id is the same idiom Browse already uses and keeps the
serialized shape simple (the key is simply absent when unset).

### Provider build with no active worksheet

`WorksheetNotifier.build()` already seeds per-template display values from
persisted sources independently of the active id, so it needs no change there.
It sets `worksheetId` from the (now nullable) persisted active id.
`selectWorksheet(id)` continues to set the active id and persist it; selecting
from the null state simply transitions `null → id`.

### Screen rendering branches on null active id

`WorksheetScreen.build()` stops doing an unconditional `firstWhere` on the
active id.  Instead:

- If `worksheetId == null`, there is no `template`; render the no-selection UI.
- Otherwise resolve the template and render as today.

Concretely:

- **AppBar title**: when no worksheet is active, show `Text('Worksheet')`.  When
  active and `twoPane`, show `Text(template.name)` (today's behavior); when
  active and compact, show the existing `WorksheetDropdown`.
- **Body**: reuse the existing `TwoPaneLayout`.  The left pane is always the
  `_TemplateList` (already built from the sorted templates).  The right pane is
  the worksheet content when a template is active, else an
  `_EmptyWorksheetPane` placeholder analogous to Browse's `_EmptyDetailPane`
  ("Select a worksheet").
- **Compact width**: `TwoPaneLayout` collapses to a single pane via
  `compactPrimary`.  Set `compactPrimary` so that, with no selection, the
  visible pane is the template list, and with a selection, it is the worksheet
  content.  Because `compactPrimary` chooses one side, the screen picks
  `PaneSide.left` (list) when `worksheetId == null` and `PaneSide.right`
  (worksheet) when a template is active.  This yields "list first, then
  worksheet" at compact width with no extra routing.

*Alternative considered:* a pushed route for the worksheet at compact width
(closer to Browse's pushed detail).  Rejected — switching `compactPrimary` keeps
all worksheet state in one screen and avoids a navigation stack entry, and the
AppBar dropdown already provides switching once a worksheet is shown.

### Controller / value plumbing guards against null

`_syncControllers`, `_controllersFor`, and `_buildTableRow` are only reached when
a template is resolved, so they stay unchanged; the null branch returns before
touching them.

## Risks / Trade-offs

- **Tests asserting the Length default** → several worksheet-ui and
  worksheet-persistence tests assert that Length is active by default; these
  must be updated to assert the no-selection state.  Mitigation: spec scenarios
  are updated in lockstep, and the delta specs make the new expectations
  explicit.
- **Compact has no explicit "back to list" control** → once a worksheet is
  picked at compact width, the user switches via the dropdown rather than
  returning to the full list.  Accepted: matches the proposal's described
  behavior and the dropdown already lists every template.
- **Persisted state from older versions** → an existing install may have
  `activeWorksheetId: 'length'` saved; it will simply restore Length, which is
  correct (a real prior selection is honored).  Only genuinely-absent selections
  now yield the no-selection state.

## Open Questions

None.
