# Freeform Rebuild Scoping

## Why

The performance-measurement change (July 2026) found that every keystroke in a freeform expression field rebuilds the *entire* `FreeformScreen` subtree twice (~30 widgets × 2), contributing to 13–16 ms typing frames that overrun a 120 Hz device's 8.3 ms budget.  Both causes are incidental: a `setState(() {})` run on every text change solely to refresh the clear/swap button states, and screen-level `ref.watch`es that rebuild the whole screen when the debounced evaluation result (and the history entry it records) arrives.  This is the minimal, evidence-backed fix — the larger freeform-notifier/AppBar-centralization refactor stays deferred.

## What Changes

- Remove the per-keystroke `setState(() {})` calls from `_onInputChanged`/`_onOutputChanged` in `FreeformScreen`; the clear and swap buttons instead listen directly to the `TextEditingController`s (which are already `Listenable`s), so a keystroke rebuilds only those buttons.
- Push the screen-level `ref.watch(freeformProvider)` down into scoped `Consumer`s: the `ResultDisplay` block and the AppBar "Browse conformable units" button (the only two consumers of the evaluation result).
- Push the screen-level `ref.watch(freeformHistoryProvider)` down into the history pane and the compact-width AppBar history button (the only two consumers of history).
- Remove the now-redundant `setState` in the idle-example tap handler (the controller listeners take over); the focus-change `setState` (key-panel show/hide) and the screen-level `settingsProvider` watch stay — both are legitimate, rare, whole-layout changes.
- Tighten the rebuild-scope guarantees: a keystroke (plus its debounced evaluation) rebuilds the `FreeformScreen` subtree root **zero** times; only the scoped dependents rebuild.  The existing rebuild-scope tests are tightened to pin the new bounds.
- No behavior or visual change intended: clear-button visibility, swap enablement, result display, history, and on-submit mode all behave exactly as before, pinned by the existing widget tests.
- After implementation: a brief DevTools re-pass on a real 120 Hz device to record (not gate) the new typing frame times, updating `doc/performance.md`.

## Capabilities

### New Capabilities

_None._

### Modified Capabilities

- `rebuild-scope`: the freeform keystroke requirement changes from an "at most two whole-subtree rebuilds" bound (which explicitly recorded the broad scope as a follow-up) to a scoped-rebuild requirement: zero `FreeformScreen`-subtree rebuilds per keystroke, with only the dependent widgets (field buttons, result display, history consumers) rebuilding.  The "assertions derived from verified behavior" requirement's scenario is updated to stop hard-coding the superseded freeform bound.

## Impact

- **Code**: `lib/features/freeform/presentation/freeform_screen.dart` only (widget-layer restructuring; no state-management or domain changes)
- **Tests**: `test/features/freeform/presentation/freeform_rebuild_scope_test.dart` tightened; existing freeform screen/two-pane tests must pass unchanged (they pin the behavior that must not change)
- **Docs**: `doc/performance.md` findings updated with the re-measured frame times; the "Performance Follow-ups" entry in `doc/implementation_plan.md` marked addressed; `doc/design_progress.md` entry
- **Dependencies**: none
