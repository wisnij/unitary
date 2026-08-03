# freeform-ime-config Specification

## Purpose

Defines the IME/keyboard configuration of the freeform expression fields
("Convert from" and "Convert to"): a plain-text keyboard type so the
soft-wrapping multiline layout does not invite prose treatment (Android IME
auto-capitalization), and no platform autocorrect or word suggestions, since
expression content is case-sensitive unit identifiers served by the app's own
predictive-completion overlay.

## Requirements

### Requirement: Freeform expression fields request a plain-text keyboard

The freeform expression fields ("Convert from" and "Convert to") SHALL declare
an explicit plain-text keyboard type (`TextInputType.text`) on their inner text
field, so that the soft-wrapping configuration (`maxLines: null`) does not
cause the platform to infer a multiline keyboard type.  Android IMEs treat
multiline fields as prose and apply their own auto-capitalization regardless of
the capitalization hint; the plain-text keyboard type is what makes the
keyboard open in lowercase.

#### Scenario: Inner text field declares a plain-text keyboard type

- **WHEN** a `CompletionField` builds its inner `TextField`
- **THEN** the `TextField.keyboardType` is `TextInputType.text`
- **AND** `TextField.maxLines` remains `null` (soft-wrap preserved)

#### Scenario: Keyboard opens without auto-capitalization on Android

- **WHEN** the user focuses a freeform expression field on an Android device
- **THEN** the soft keyboard opens with shift disengaged (lowercase entry)

### Requirement: Freeform expression fields disable autocorrect and IME suggestions

The freeform expression fields SHALL disable platform autocorrect
(`autocorrect: false`) and IME word suggestions (`enableSuggestions: false`).
Expression content consists of unit identifiers, numbers, and operators — not
dictionary words — and the application provides its own domain-aware predictive
completion overlay.

#### Scenario: Inner text field disables autocorrect and suggestions

- **WHEN** a `CompletionField` builds its inner `TextField`
- **THEN** `TextField.autocorrect` is `false`
- **AND** `TextField.enableSuggestions` is `false`

#### Scenario: Predictive completion overlay is unaffected

- **WHEN** the user types a partial identifier of at least 2 characters in a
  freeform expression field
- **THEN** the app's own completion overlay still appears with suggestions
