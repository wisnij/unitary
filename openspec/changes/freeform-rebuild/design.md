# Design — Freeform Rebuild Scoping

## Context

`FreeformScreen` (`lib/features/freeform/presentation/freeform_screen.dart`) is a `ConsumerStatefulWidget` owning the two `TextEditingController`s, two `FocusNode`s, the debounce `Timer`, and the key-panel visibility flag.  Its `build()` watches three providers at the top (`freeformProvider`, `freeformHistoryProvider`, `settingsProvider`, lines ~235-237) and its text-change handlers call `setState(() {})` on every keystroke (lines ~99/107) purely so two derived values recompute:

- `_inputController.text.isNotEmpty` → the clear `suffixIcon` on the input field
- `canSwap` (both fields non-empty) → the swap button's `onPressed`

Measured consequence (see `doc/performance.md` and `openspec/changes/archive/2026-07-13-performance-measurement/measurements.md`): one keystroke = two full-subtree rebuilds (immediate `setState` + debounced result arriving at the screen-level watch, coalesced with the history-record update), producing 13–16 ms frames against an 8.3 ms/120 Hz budget.

Consumer map of the screen-level state (from reading `build()`):

| State | Consumers in build() |
|---|---|
| `freeformProvider` result | `ResultDisplay` (+ its idle-example `onTap`), AppBar balance button (`conformableBrowseEnabled`) |
| `freeformHistoryProvider` | `_HistoryPane(entries:)`, compact-width AppBar history button enablement |
| `settingsProvider` | `isOnSubmit` (shows the Evaluate button) |
| controllers (text) | clear `suffixIcon`, swap `onPressed` |

## Goals / Non-Goals

**Goals:**

- Zero `FreeformScreen`-subtree rebuilds per keystroke and per arriving evaluation result; only the widgets that depend on the changed state rebuild
- No behavior or visual change; all existing freeform widget tests pass unchanged
- Tightened rebuild-scope tests pinning the new bounds

**Non-Goals:**

- The freeform-notifier refactor (lifting field/eval state out of widget `State`) and AppShell-owned AppBar construction — still deferred; this change works entirely within the existing widget-state architecture
- Guaranteeing sub-8.3 ms typing frames on 120 Hz devices — some frame cost is `TextField`-internal/IME work outside our control; the re-pass records the outcome but does not gate the change
- Touching the focus-change `setState` (key-panel show/hide) or the `settingsProvider` screen-level watch — both rare, legitimate whole-layout changes

## Decisions

### D1: Buttons listen to controllers via `ListenableBuilder`; the per-keystroke `setState` is deleted

`TextEditingController` is a `ChangeNotifier`, so the two derived button states can rebuild locally:

- Swap button: `ListenableBuilder(listenable: Listenable.merge([_inputController, _outputController]), builder: ...)` computing `canSwap` inside the builder.
- Clear button: the input field's `suffixIcon` becomes `ListenableBuilder(listenable: _inputController, builder: ...)` returning the clear `IconButton` when non-empty.

Alternative considered: keeping `setState` but splitting the screen into smaller stateful widgets — more invasive for the same effect; `ListenableBuilder` is the idiomatic minimal tool.

### D2: Clear-button listener wraps the whole input `CompletionField` (geometry-identical form)

Today `suffixIcon` switches between `null` and an `IconButton` at screen-rebuild time, and `InputDecorator` reserves the 48 dp suffix slot whenever `suffixIcon` is non-null.  That makes any "always-present suffix widget that hides itself" form (`SizedBox.shrink()`, `Visibility`) a guaranteed empty-state geometry change — so the implementation uses what an earlier draft of this decision listed as the fallback: the `ListenableBuilder` wraps the input `CompletionField` itself, and the `suffixIcon: null`/non-null switch is preserved verbatim, just re-evaluated by the controller listener instead of a screen `setState`.  Scope per keystroke: one field widget rebuild (which already happened under the old whole-screen rebuild) — still far below the old scope, and the empty-field geometry is unchanged by construction, so no manual geometry check is needed.

### D3: Result and history watches move into scoped `Consumer`s

Four consumer sites, each getting its own `Consumer`:

1. `ResultDisplay` (+ idle-example `onTap` closure) — watches `freeformProvider`
2. AppBar balance button — watches `freeformProvider` for `conformableBrowseEnabled`
3. `_HistoryPane` — watches `freeformHistoryProvider` (or `_HistoryPane` becomes a `ConsumerWidget` reading it directly)
4. Compact-width AppBar history button — watches `freeformHistoryProvider` for `isNotEmpty`

`settingsProvider` stays watched at screen level: `isOnSubmit` toggles the Evaluate button and changes rarely (a settings-screen visit), so scoping it buys nothing.

The idle-example `onTap` currently also calls `setState(() {})` after writing the controllers; with D1 the controller listeners cover the button updates, so that call is removed.

### D4: Rebuild-scope spec and tests tighten to the new bounds

The `rebuild-scope` capability's freeform requirement changes (MODIFIED) from "at most two subtree rebuilds per keystroke" to: a keystroke plus its debounced evaluation rebuilds the `FreeformScreen` subtree root **zero** times, with only the scoped dependents rebuilding.  The tightened tests use the existing `RebuildCounter` probe:

- keystroke + debounce → `counter.of('FreeformScreen') == 0`
- the result still updates (assert on the displayed result) and the buttons still react (assert clear/swap state), proving the scoped rebuilds happen

The "assertions derived from verified behavior" requirement keeps its intent but its scenario stops hard-coding the superseded "two subtree builds" figure; verification for this change is the tightened tests plus a recorded (non-gating) DevTools re-pass.

### D5: Verification is tests-first, device re-pass after

Order: tighten the rebuild-scope tests first (they fail against current code — true red/green), implement D1–D3, confirm the full suite passes unchanged (the behavior pins), then a brief on-device DevTools re-pass records the new typing frame times in `doc/performance.md`.  The 120 Hz frame budget is explicitly not a gate (Non-Goals).

## Verification Results (July 17, 2026, on-device)

Debug-mode DevTools rebuild check after the fix, one keystroke (counts cleared first):

```
CompletionField 1, Consumer 1×3, Container 1, Icon 1, Icon 13, IconButton 1×4,
ListenableBuilder 1×2, OverlayPortal 1, ResultDisplay 1, Text 1, TextField 1
```

`FreeformScreen`, `Scaffold`, `AppBar`, `TwoPaneLayout`, and `_KeyPanel` are absent — the whole-screen ×2 rebuild is gone; only the scoped dependents rebuild, each exactly once.

Profile-mode frame times (tracking off, same 120 Hz device): typing one character at a time stays entirely under the 8.3 ms jank threshold (previously 13–16 ms per keystroke); over-budget bars appear only during very rapid typing.  Non-gating criterion met and exceeded.

## Risks / Trade-offs

- **Suffix-slot geometry change (D2)** → pinned by existing clear-button tests; explicit fallback forms named in D2; manual empty-state check during verification.
- **Idle-example tap regression** — removing its `setState` assumes the controller listeners and scoped consumers cover every UI update it triggered; the existing idle-example widget tests plus the evaluation flow tests cover this path.
- **Rebuild-scope tests could pass vacuously** (e.g. probing a widget name that no longer exists after refactoring) → tests also assert the *positive* effects (result shown, buttons enabled) so a silent no-op cannot pass.
- **Frame times may not clear 8.3 ms** even with correct scoping (IME/TextField internals) → explicitly a recorded outcome, not a gate; if the re-pass shows no improvement at all, that finding goes to `doc/performance.md` and the follow-ups list rather than expanding this change's scope.

## Open Questions

_None — the scope questions (minimal vs. full refactor, success criterion, test tightening) were settled in the pre-proposal discussion: minimal fix, non-gating re-pass, tighten to zero-subtree-rebuilds._
