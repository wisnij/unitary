# Proposal: freeform-keyboard-type

## Why

On Android, tapping a freeform expression field brings up the soft keyboard with
initial-character auto-capitalization engaged, and IME autocorrect/word
suggestions active.  Unit lookup is case-sensitive, so an auto-capitalized
`Ft` or `Meters` is an unknown-unit error — the keyboard actively fights the
app's grammar.  Root cause (confirmed on-device): the soft-wrap change set
`maxLines: null` on the inner `TextField`, which silently switched the implicit
keyboard type from `TextInputType.text` to `TextInputType.multiline`; Android
IMEs treat multiline free-text fields as prose and apply their own
auto-capitalization regardless of the `TextCapitalization.none` hint already
being sent.

## What Changes

- The inner `TextField` in `CompletionField` declares an explicit
  `keyboardType: TextInputType.text`, overriding the multiline default implied
  by `maxLines: null`.  Validated on-device: the keyboard starts lowercase
  while soft-wrap and Enter-to-submit continue to work.
- The same `TextField` sets `autocorrect: false` and
  `enableSuggestions: false`: unit identifiers (`kWh`, `tempF`, `mmHg`) are not
  dictionary words, and the app supplies its own domain-aware completion
  overlay.
- The `TEMP DIAGNOSTIC` comment currently at the site is replaced with a proper
  comment explaining that the explicit keyboard type is load-bearing (removing
  it regresses Android capitalization behavior).

## Capabilities

### New Capabilities

- `freeform-ime-config`: IME/keyboard configuration of the freeform expression
  fields — plain-text keyboard type (no multiline prose treatment), no
  auto-capitalization, no autocorrect, no IME word suggestions.

### Modified Capabilities

<!-- none: freeform-field-wrapping requirements are unchanged — the fix must
     simply not regress them, which its existing scenarios already pin -->

## Impact

- `lib/features/freeform/presentation/widgets/completion_field.dart` — three
  properties added to the inner `TextField`; no structural changes.
- Both freeform fields ("Convert from" / "Convert to") are affected, since both
  are `CompletionField`s; worksheet numeric cells already use a numeric
  keyboard and are untouched.
- New widget tests pinning the inner `TextField`'s `keyboardType`,
  `autocorrect`, and `enableSuggestions`.
- No dependency, API, or persistence changes.  Existing
  `freeform-field-wrapping` scenarios guard against regression of soft-wrap and
  Enter-to-submit.
- Trade-off accepted: disabling suggestions also disables swipe-typing in these
  fields on most IMEs.
