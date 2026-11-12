## MODIFIED Requirements

### Requirement: Freeform expression fields disable autocorrect and IME suggestions

The freeform expression fields SHALL disable platform autocorrect
(`autocorrect: false`) and IME word suggestions (`enableSuggestions: false`).
Expression content consists of unit identifiers, numbers, and operators — not
dictionary words — and the application provides its own domain-aware predictive
completion area.

#### Scenario: Inner text field disables autocorrect and suggestions

- **WHEN** a `CompletionField` builds its inner `TextField`
- **THEN** `TextField.autocorrect` is `false`
- **AND** `TextField.enableSuggestions` is `false`

#### Scenario: Predictive completion area is unaffected

- **WHEN** the user types a partial identifier of at least 2 characters in a
  freeform expression field
- **THEN** the app's own completion area still shows suggestions
