# Proposal: screen-reader

## Why

The recently shipped semantic-labels change covered the static controls (operator keys, completion suggestions), but the app's *dynamic* content is still invisible to screen readers: the freeform evaluation result updates silently, worksheet cell errors are signaled by red text color alone (also a WCAG 1.4.1 use-of-color failure for sighted low-vision users), and several tap/long-press affordances are undiscoverable through assistive technology.  This is the "screen-reader announcement of evaluation results and per-row worksheet errors" item under Phase 9 accessibility improvements.

## What Changes

- The freeform result display becomes a polite live region (`Semantics(liveRegion: true)`), so every settled evaluation result — success, conversion, definition lookup, or error — is announced automatically by TalkBack/VoiceOver without moving focus.  This follows the WCAG 4.1.3 status-message convention and applies unconditionally in both evaluation modes (in on-submit mode it naturally behaves as announce-on-submit).
- Announcements use a speech-friendly rendering of the result rather than the raw display string: structural symbols are spoken (`=` → "equals", `/` → "per", `^` → "to the power"), scientific/engineering exponents are spoken as "times 10 to the N" instead of "e plus N", and error states are prefixed with "Error:".  Unit names are spoken as written (no abbreviation expansion — deferred as a possible later enhancement).
- Worksheet cells whose computation fails display the error through the `TextField`'s `errorText` decoration instead of red-colored field text, gaining native error semantics for screen readers and a visible non-color error indicator.  Per-row error *announcements* are explicitly deferred until user-editable worksheets exist (Phase 12), since predefined templates cannot produce row-level dimension mismatches in practice.
- The tappable idle-example hint on the freeform screen exposes `button` semantics so assistive technology reports it as actionable.
- Every long-press-to-copy gesture (worksheet value cells, About screen version/license rows, unit detail definition) exposes a labeled `CustomSemanticsAction` (e.g. "Copy value") so the action is discoverable in TalkBack's actions menu and VoiceOver's rotor.

## Capabilities

### New Capabilities

- `result-announcements`: the freeform result display as a polite live region, and the speech-friendly spoken form of each `EvaluationResult` variant (symbol wording, exponent wording, error prefix).

### Modified Capabilities

- `quantity-formatter`: gains a speech-form formatting function alongside `formatQuantity`, sharing the same mantissa/exponent computation, producing spoken exponents ("times 10 to the N") for scientific and engineering notation.
- `worksheet-ui`: erroring cells change from red-colored field text to `errorText`-based error display with native error semantics; long-press copy on value cells gains a labeled custom semantics action.
- `semantic-labels`: purpose widens from freeform-only controls to custom interactive controls generally; adds button semantics on the idle-example hint and labeled custom semantics actions on the remaining long-press copy gestures (About screen, unit entry detail).

## Impact

- `lib/shared/utils/quantity_formatter.dart` — new speech-form formatter sharing exponent computation with the display formatters.
- `lib/features/freeform/presentation/widgets/result_display.dart` — live-region wrapper and per-variant spoken labels (exhaustive `switch` over the sealed `EvaluationResult`); button semantics on the idle-example tap target.
- `lib/features/worksheet/presentation/worksheet_screen.dart` — `errorText`-based cell errors (check table row alignment tolerates the added helper-text line); custom semantics action on the value-cell copy gesture.  (`worksheet_row_widget.dart` was orphaned dead code — only its own test referenced it — and was deleted along with its test during verification cleanup.)
- `lib/features/about/presentation/about_screen.dart`, `lib/features/browser/presentation/unit_entry_detail_screen.dart` — labeled custom semantics actions on existing copy long-presses.
- Tests: coverage-style semantics tests in the pattern of the semantic-labels change (exhaustive over `EvaluationResult` variants); speech-formatter unit tests; worksheet error-semantics widget tests.
- No new dependencies; no behavior change for users without assistive technology except the worksheet error display (red in-field text → `errorText` helper line).
