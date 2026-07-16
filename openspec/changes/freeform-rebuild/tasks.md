# Tasks — Freeform Rebuild Scoping

## 1. Tighten rebuild-scope tests (red first)

- [ ] 1.1 Update `test/features/freeform/presentation/freeform_rebuild_scope_test.dart`: keystroke + debounce → `FreeformScreen` records zero rebuilds; add positive-effect assertions (result display updates, clear button appears, swap button enables) so the bound cannot pass vacuously.  Confirm the tightened tests fail against current code

## 2. Scope the rebuilds

- [ ] 2.1 Remove the `setState(() {})` calls from `_onInputChanged`/`_onOutputChanged`; wrap the swap button in a `ListenableBuilder` over `Listenable.merge([_inputController, _outputController])` and the clear `suffixIcon` in a `ListenableBuilder` over `_inputController` (visibility inside the builder per design D2, watching the empty-state field geometry)
- [ ] 2.2 Push `ref.watch(freeformProvider)` into scoped `Consumer`s around `ResultDisplay` (+ idle-example `onTap`) and the AppBar conformable-browse button; push `ref.watch(freeformHistoryProvider)` into the history pane and the compact AppBar history button; keep the `settingsProvider` watch at screen level
- [ ] 2.3 Remove the redundant `setState` in the idle-example tap handler; verify the tightened rebuild-scope tests now pass

## 3. Verify

- [ ] 3.1 Run the full suite (`flutter test --reporter failures-only`) — all existing freeform behavior tests must pass unchanged — and `flutter analyze`
- [ ] 3.2 Manual check of the empty-input field geometry (clear-button slot) against the current release build, per design D2's risk note

## 4. On-device re-pass and docs

- [ ] 4.1 DevTools re-pass on the 120 Hz device: rebuild counts for one keystroke (expect the screen subtree absent from the list) and typing frame times; recorded, not gated
- [ ] 4.2 Update `doc/performance.md` (frame-behavior findings + follow-ups list) and `doc/implementation_plan.md` ("Performance Follow-ups": mark the freeform item addressed, note the notifier/AppBar refactor remains deferred); add a `doc/design_progress.md` entry
