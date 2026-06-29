## 1. Persistence layer

- [ ] 1.1 Update `WorksheetRepository` tests: `load()` returns a null active id
  for no stored data, malformed data, and an unrecognised stored id (no longer
  falls back to `'length'`); a valid stored id still restores correctly
- [ ] 1.2 Make `WorksheetPersistState.activeWorksheetId` nullable (`String?`);
  set `defaults` to `null`; omit/serialize the key correctly in
  `toJson`/`fromJson`
- [ ] 1.3 Update `WorksheetRepository.load()` to return `null` for the active id
  on missing/malformed/unrecognised values instead of substituting `'length'`

## 2. State and provider

- [ ] 2.1 Update `WorksheetState` / `WorksheetNotifier` tests: build starts with
  a null `worksheetId` when nothing is persisted; `selectWorksheet` transitions
  from null to a chosen id and persists it; per-template seeded values still
  load regardless of active id
- [ ] 2.2 Make `WorksheetState.worksheetId` nullable (`String?`); adjust
  `copyWith`, equality, and `hashCode`
- [ ] 2.3 Update `WorksheetNotifier.build()` and `selectWorksheet()` for a
  nullable active id (no `length` fallback)

## 3. Screen UI

- [ ] 3.1 Update / add `WorksheetScreen` widget tests: no-selection shows a
  full-screen template list at compact width and a "Select a worksheet"
  placeholder in the right pane at medium/expanded width; AppBar shows static
  "Worksheet" title when nothing is selected; selecting a template (list tap at
  any width, dropdown when active at compact) renders that worksheet's rows
- [ ] 3.2 Branch `WorksheetScreen.build()` on a null active id: skip the
  `firstWhere` template resolution when none is active
- [ ] 3.3 Add an `_EmptyWorksheetPane` placeholder ("Select a worksheet")
  analogous to Browse's `_EmptyDetailPane`; render it as the right pane when no
  template is active
- [ ] 3.4 Adapt the AppBar title: static `Text('Worksheet')` when none active;
  active-template name (wide) or `WorksheetDropdown` (compact) when active
- [ ] 3.5 Set `TwoPaneLayout.compactPrimary` to `PaneSide.left` (list) when no
  worksheet is active and `PaneSide.right` (worksheet) when one is active, so
  compact width shows the list first and the worksheet after selection

## 4. Verification

- [ ] 4.1 Run `flutter test --reporter failures-only` and confirm all tests pass
- [ ] 4.2 Run `flutter analyze` and confirm no new lint errors
- [ ] 4.3 Update `README.md` / `doc/` progress notes to reflect the new
  no-default-worksheet behavior
