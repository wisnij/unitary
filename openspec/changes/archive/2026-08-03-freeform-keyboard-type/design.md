# Design: freeform-keyboard-type

## Context

Both freeform expression fields are `CompletionField`s wrapping a single inner
`TextField` (`lib/features/freeform/presentation/widgets/completion_field.dart`).
The long-expressions change (July 9, 2026) set `maxLines: null` there for
soft-wrapping.  Flutter's `TextField` derives its keyboard type from `maxLines`
when no explicit `keyboardType` is given: `maxLines != 1` implies
`TextInputType.multiline`.  On Android, IMEs treat a multiline free-text field
as prose input and apply their own auto-capitalization (and
autocorrect/suggestion) heuristics, even though Flutter already sends the
default `TextCapitalization.none` hint.

Diagnosed empirically on the user's Android device (August 2026):

1. Current code (`maxLines: null`, implicit multiline) → keyboard opens with
   shift engaged.
2. Diagnostic revert to `maxLines: 1` (implicit `TextInputType.text`) →
   keyboard opens lowercase, proving the IME honors the no-caps hint in text
   mode and the multiline keyboard type is the trigger.
3. Candidate fix (`maxLines: null` + explicit `keyboardType:
   TextInputType.text`) → keyboard opens lowercase, soft-wrap still works,
   Enter still submits.

## Goals / Non-Goals

**Goals:**

- Freeform expression fields open the Android keyboard in lowercase.
- IME autocorrect and word suggestions are disabled in these fields (unit
  identifiers are not dictionary words; the app's completion overlay is the
  domain-aware replacement).
- Soft-wrap, vertical growth, and Enter-to-submit behavior are preserved
  exactly (the existing `freeform-field-wrapping` scenarios must keep passing).

**Non-Goals:**

- No change to worksheet fields (numeric keyboard already) or any other text
  input in the app.
- No change to the completion overlay or symbol key panel.
- No attempt to control third-party IME behavior beyond the standard platform
  hints; a keyboard that ignores `TYPE_TEXT_FLAG_NO_SUGGESTIONS` is out of
  scope.

## Decisions

**D1: Explicit `keyboardType: TextInputType.text` alongside `maxLines: null`.**
An explicit keyboard type overrides the `maxLines`-derived default, so the
field keeps visual wrapping (a rendering concern) while the IME sees a
plain-text field.  Enter-as-submit is already guaranteed by the explicit
`textInputAction` each call site passes.  Alternatives considered:

- *Explicit `textCapitalization: TextCapitalization.none`* — rejected as the
  fix: it is already the default and was already being sent while the keyboard
  capitalized; the IME ignores it in multiline mode.
- *`TextInputType.visiblePassword`* — rejected: reliably forces lowercase on
  virtually all IMEs, but is semantically a lie (password-manager and
  accessibility tooling may react), and the polite hint was proven sufficient
  on-device.
- *Reverting soft-wrap (`maxLines: 1`)* — rejected: regresses the
  long-expressions feature.

**D2: `autocorrect: false` and `enableSuggestions: false`.**  Expression
content is unit identifiers and operators, not prose; autocorrect can silently
mangle valid input, and the app ships its own completion overlay.  Both map to
`TYPE_TEXT_FLAG_NO_SUGGESTIONS` on Android and the equivalent on iOS.  Applied
inside `CompletionField` rather than as caller-passed parameters, since every
current and future `CompletionField` is by definition an expression field.

**D3: No new spec scenarios for wrapping/submit.**  The existing
`freeform-field-wrapping` spec already pins soft-wrap and Enter semantics; this
change relies on those scenarios as its regression guard rather than
duplicating them under the new capability.

## Risks / Trade-offs

- [Some IMEs ignore the no-suggestions hint] → Accepted; the capitalization
  fix (the actual reported bug) is proven on-device, and suggestion behavior
  on non-compliant keyboards is no worse than today.
- [Disabling suggestions disables swipe-typing on most IMEs] → Accepted
  deliberately (user decision, August 2026); expression input is
  short-token-oriented and served by the app's own completion overlay.
- [Future edit removes the "redundant-looking" explicit keyboard type] →
  Mitigated by a load-bearing code comment and widget tests pinning all three
  properties on the inner `TextField`.
