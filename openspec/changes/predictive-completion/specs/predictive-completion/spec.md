## ADDED Requirements

### Requirement: Token detection
The system SHALL detect a completion token only when the cursor is positioned
immediately at the end of an identifier.  It does this by running the existing
`Lexer` on the full expression text, finding the `identifier` token (if any)
whose character range spans the cursor offset, and checking that the cursor
offset equals the token's end position.  What constitutes a valid identifier
character is defined solely by the lexer; the completion feature SHALL NOT
duplicate that logic.  If the cursor is mid-identifier, in whitespace, in an
operator, or in a number (including scientific-notation letters such as the `e`
in `1e10`), no token is detected and the overlay SHALL NOT appear.  Tokens
shorter than 2 characters SHALL also be suppressed to avoid excessive visual
noise.  If the expression cannot be lexed at all, no token is detected.

#### Scenario: Cursor at end of a partial identifier
- **WHEN** the expression text is `"5 kilo"` and the cursor is at offset 6 (after `kilo`)
- **THEN** the detected token has prefix `"kilo"` and start=3

#### Scenario: Cursor mid-identifier — no token detected
- **WHEN** the expression text is `"kilogram"` and the cursor is at offset 4 (after `kilo`)
- **THEN** no token is detected (the cursor is not at the end of the identifier)

#### Scenario: Cursor in whitespace
- **WHEN** the expression text is `"5 km"` and the cursor is at offset 1 (the space)
- **THEN** no token is detected

#### Scenario: Cursor after an operator
- **WHEN** the expression text is `"5*km"` and the cursor is at offset 1 (after `*`)
- **THEN** no token is detected

#### Scenario: Scientific-notation exponent not treated as identifier
- **WHEN** the expression text is `"1e10"` and the cursor is at offset 2 (after `e`)
- **THEN** no token is detected (the lexer produces a single `number` token for `1e10`)

#### Scenario: Cursor at start of identifier — no token detected
- **WHEN** the expression text is `"km"` and the cursor is at offset 0
- **THEN** no token is detected (the cursor is not at the end of any identifier)

#### Scenario: Single-character token suppressed
- **WHEN** the expression text is `"5 k"` and the cursor is at offset 3 (after `k`)
- **THEN** no token is detected (token is shorter than 2 characters)

### Requirement: Suggestion computation
The system SHALL compute a ranked list of identifier completions for a given
prefix string by searching the unit repository.  Candidates are drawn from unit
primary IDs and aliases, function primary IDs and aliases, and named prefix
primary IDs and aliases.  Matching is case-insensitive prefix matching (the
candidate name starts with the query prefix).  Results SHALL be ranked with
primary-ID matches before alias-only matches; within each group, candidates are
sorted alphabetically (case-insensitive) by matched name.

#### Scenario: Prefix matches primary IDs and aliases
- **WHEN** `suggestCompletions("kil")` is called
- **THEN** the result includes `"kilo"` (a prefix primary ID) and `"kilometer"` (a unit primary ID) in the primary-ID group, before any alias-only matches

#### Scenario: Case-insensitive matching
- **WHEN** `suggestCompletions("KM")` is called
- **THEN** the result includes `"km"` (matched case-insensitively)

#### Scenario: Empty prefix returns empty list
- **WHEN** `suggestCompletions("")` is called
- **THEN** the result is empty

#### Scenario: No matches returns empty list
- **WHEN** `suggestCompletions("zzz")` is called
- **THEN** the result is empty

#### Scenario: Functions appear in results
- **WHEN** `suggestCompletions("tem")` is called
- **THEN** the result includes `"tempC"`, `"tempF"`, and `"tempK"` (function IDs)

### Requirement: Completion overlay display
The system SHALL display a completion suggestion overlay below (or above, if
near the bottom of the viewport) the focused freeform expression field whenever
a non-empty token is detected under the cursor and at least one suggestion
exists.  The overlay SHALL show up to 8 suggestions at a time in a scrollable
list.  Each row in the list SHALL show the matched identifier name.  The overlay
SHALL be dismissed immediately when: (a) the field loses focus, (b) the token
becomes empty, (c) no suggestions match, or (d) the cursor moves outside any
identifier.

#### Scenario: Overlay appears while typing
- **WHEN** the user types `"km"` in a focused freeform field
- **THEN** a suggestion overlay is displayed below (or above) that field containing matching unit names

#### Scenario: Overlay does not appear when there are no matches
- **WHEN** the user types a token that matches no unit, function, or prefix (e.g. `"zzz"`)
- **THEN** no suggestion overlay is shown

#### Scenario: Overlay dismissed on focus loss
- **WHEN** the user taps outside the freeform field
- **THEN** the suggestion overlay is dismissed

#### Scenario: Overlay dismissed when token clears
- **WHEN** the user deletes all characters of the partial identifier
- **THEN** the suggestion overlay is dismissed

#### Scenario: At most 8 suggestions visible at once
- **WHEN** more than 8 suggestions match the current token
- **THEN** only 8 suggestion rows are visible and the list is scrollable

#### Scenario: Overlay appears above field near screen bottom
- **WHEN** the focused field is in the lower half of the viewport
- **THEN** the suggestion overlay is rendered above the field rather than below it

### Requirement: Tap-to-insert
The system SHALL replace the currently detected token in the expression field
with the tapped suggestion name when the user taps a suggestion row.  After
insertion the text cursor SHALL be placed immediately after the inserted name.
The suggestion overlay SHALL be dismissed after insertion.  Evaluation SHALL be
re-triggered according to the current evaluation mode settings (real-time or
on-submit) as if the user had typed the completed text.

#### Scenario: Token replaced with suggestion
- **WHEN** the expression is `"5 kilo"`, the cursor is after `"kilo"`, and the user taps the suggestion `"kilometer"`
- **THEN** the expression becomes `"5 kilometer"` and the cursor is placed at offset 11

#### Scenario: Partial token mid-expression replaced
- **WHEN** the expression is `"3 kg + 2 gra"` and the cursor is after `"gra"`, and the user taps `"gram"`
- **THEN** the expression becomes `"3 kg + 2 gram"` and the cursor is at offset 13

#### Scenario: Overlay dismissed after insertion
- **WHEN** the user taps a suggestion
- **THEN** the suggestion overlay is dismissed

#### Scenario: Evaluation triggered after insertion (real-time mode)
- **WHEN** the evaluation mode is real-time and the user taps a suggestion
- **THEN** evaluation is scheduled (with the normal debounce) using the updated expression text

### Requirement: Both freeform fields support completion
The system SHALL provide predictive completion for both the "Convert from" and
"Convert to" freeform expression fields independently.  Each field maintains its
own overlay, and only the currently focused field shows a suggestion list.

#### Scenario: Convert-from field shows completions
- **WHEN** the user types `"kilo"` in the "Convert from" field
- **THEN** matching suggestions appear below (or above) the "Convert from" field

#### Scenario: Convert-to field shows completions
- **WHEN** the user types `"kilo"` in the "Convert to" field
- **THEN** matching suggestions appear below (or above) the "Convert to" field

#### Scenario: Only the focused field shows completions
- **WHEN** the "Convert from" field contains `"km"` and is not focused, and the "Convert to" field is focused and contains `"met"`
- **THEN** only the "Convert to" field's suggestion overlay is visible
