# Tasks — Freeform Rebuild Scoping

## 1. Tighten rebuild-scope tests (red first)

- [x] 1.1 Update `test/features/freeform/presentation/freeform_rebuild_scope_test.dart`: keystroke + debounce → `FreeformScreen` records zero rebuilds; add positive-effect assertions (result display updates, clear button appears, swap button enables) so the bound cannot pass vacuously.  Confirm the tightened tests fail against current code (failed red: 2 and 3 rebuilds observed)

## 2. Scope the rebuilds

- [x] 2.1 Remove the `setState(() {})` calls from `_onInputChanged`/`_onOutputChanged`; wrap the swap button in a `ListenableBuilder` over `Listenable.merge([_inputController, _outputController])`; for the clear button, used design D2's geometry-identical fallback as the primary form — the `ListenableBuilder` wraps the whole input `CompletionField`, keeping the `suffixIcon: null`/non-null switch (an always-present suffix widget would reserve the 48 dp slot and change empty-field geometry)
- [x] 2.2 Push `ref.watch(freeformProvider)` into scoped `Consumer`s around `ResultDisplay` (+ idle-example `onTap`) and the AppBar conformable-browse button; push `ref.watch(freeformHistoryProvider)` into the history pane and the compact AppBar history button; keep the `settingsProvider` watch at screen level
- [x] 2.3 Remove the redundant `setState` in the idle-example tap handler; verify the tightened rebuild-scope tests now pass (both pass; all 285 freeform tests pass unchanged)

## 3. Verify

- [x] 3.1 Run the full suite (`flutter test --reporter failures-only`) — all existing freeform behavior tests must pass unchanged — and `flutter analyze` (2036 tests pass, no analyzer issues)
- [x] 3.2 Manual check of the empty-input field geometry (clear-button slot) — obviated by construction: the implemented form (design D2, revised) preserves the exact `suffixIcon: null`/non-null `InputDecoration` switch, so the empty-field geometry cannot have changed; the risk applied only to the discarded always-present-suffix form

## 4. On-device re-pass and docs

- [x] 4.1 DevTools re-pass on the 120 Hz device: rebuild counts for one keystroke (screen subtree absent from the list; only scoped dependents, each ×1) and typing frame times (normal typing entirely under the 8.3 ms threshold, over-budget bars only during very rapid typing); recorded in design.md Verification Results
- [x] 4.2 Update `doc/performance.md` (frame-behavior findings + follow-ups list) and `doc/implementation_plan.md` ("Performance Follow-ups": freeform item marked addressed, notifier/AppBar refactor noted as still deferred, no longer performance-motivated); `doc/design_progress.md` entry added, date bumped
