## 1. Repository wiring

- [ ] 1.1 Write a test demonstrating the bug: register a dynamic currency
      unit on `unitRepositoryProvider`'s repo, then show that
      `computeWorksheet` via the worksheet provider does NOT reflect it
      (red test capturing current broken behavior, to be flipped green by
      1.2)
- [ ] 1.2 Change `_worksheetParserProvider` in
      `lib/features/worksheet/state/worksheet_provider.dart` to build its
      `ExpressionParser` from `ref.read(unitRepositoryProvider)` instead of
      `UnitRepository.withPredefinedUnits()`; confirm the test from 1.1 now
      passes

## 2. Recompute on currency rate refresh

- [ ] 2.1 Write tests for `WorksheetNotifier`: after
      `unitRepositoryVersionProvider` is incremented, a template with a
      persisted source recomputes its display values using the updated
      repository; a template with no persisted source remains blank; a
      template whose recompute throws leaves other templates unaffected
- [ ] 2.2 Extract the `build()` seeding loop (persisted sources →
      `computeWorksheet` → `worksheetValues`) into a private helper
      `_computeAllFromSources(WorksheetPersistState persist)`, preserving
      the existing per-template try/catch
- [ ] 2.3 In `build()`, register
      `ref.listen<int>(unitRepositoryVersionProvider, (_, _) { ... })` that
      re-reads `worksheetRepositoryProvider.load()`, calls
      `_computeAllFromSources`, and replaces `state.worksheetValues`
- [ ] 2.4 Confirm tests from 2.1 pass

## 3. Documentation

- [ ] 3.1 Add an entry to `doc/design_progress.md`'s implementation
      progress log describing the fix and the new
      `unitRepositoryVersionProvider` listener in `WorksheetNotifier`

## 4. Verification

- [ ] 4.1 Run `flutter test --reporter failures-only` and confirm all
      tests pass
- [ ] 4.2 Run `flutter analyze` and confirm no issues
