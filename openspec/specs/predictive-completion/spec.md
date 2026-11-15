# Predictive Completion

## Purpose

Provide inline unit, function, and prefix suggestions in freeform expression fields as the user types, allowing tap-to-insert completion of partial identifiers.

## Requirements

### Requirement: Token detection
The system SHALL detect a completion token only when the cursor is positioned
immediately at the end of an identifier.  It does this by running the existing
`Lexer` on the full expression text, finding the `identifier` token (if any)
whose character range spans the cursor offset, and checking that the cursor
offset equals the token's end position.  What constitutes a valid identifier
character is defined solely by the lexer; the completion feature SHALL NOT
duplicate that logic.  If the cursor is mid-identifier, in whitespace, in an
operator, or in a number (including scientific-notation letters such as the `e`
in `1e10`), no token is detected and no suggestions SHALL be shown.  Tokens
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
primary IDs and aliases.  Matching is case-insensitive: a candidate matches when
its name **contains** the query as a substring (case-insensitive).  Results SHALL
be returned in two ordered tiers:

1. **Prefix matches**: candidates whose name starts with the query, sorted alphabetically (case-insensitive)
2. **Infix matches**: candidates whose name contains (but does not start with) the query, sorted alphabetically (case-insensitive)

Primary IDs and aliases are interleaved within each tier (alphabetical order only; no primary-before-alias sub-sorting).

#### Scenario: Prefix matches primary IDs and aliases
- **WHEN** `suggestCompletions("kil")` is called
- **THEN** the result includes both `"kilo"` (a prefix primary ID) and `"kilogram"` (a unit alias for `kg`) in the prefix-match tier, sorted alphabetically
- **NOTE** `"kilometer"` is not a registered unit primary ID — it is synthesised at lookup time from the prefix `kilo` and unit `m` and does not appear in `_unitLookup`

#### Scenario: Infix matches appear after prefix matches
- **WHEN** `suggestCompletions("ring")` is called
- **THEN** the result includes `"ringsize"` (prefix match, starts with `"ring"`) before `"euringsize"` and `"jpringsize"` (infix matches, contain `"ring"` but do not start with it)

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

### Requirement: Tap-to-insert
The system SHALL replace the currently detected token in the focused expression
field with a kind-specific insertion string when the user taps a suggestion
chip.  The insertion string differs by entry kind:

- **Unit**: `name` followed by a single space (e.g. `"km "`) so the cursor
  clears the token and the user can immediately type the next part of the
  expression.
- **Prefix**: the plain `name` with no trailing character (e.g. `"kilo"`); the
  display dash is not inserted.
- **Function**: `name` followed by `(` (e.g. `"tempC("`); the cursor lands
  inside the call so the user can type the argument.

After insertion the text cursor SHALL be placed immediately after the last
inserted character.  The completion area SHALL then show the suggestions for
the new text and cursor position, which for a unit insertion means none.
Evaluation SHALL be re-triggered according to the current evaluation mode
settings (real-time or on-submit) as if the user had typed the completed text.
Focus SHALL be restored to the text field after a suggestion is selected.

#### Scenario: Unit token replaced — trailing space appended
- **WHEN** the expression is `"5 kilo"`, the cursor is after `"kilo"`, and the user taps the unit suggestion `"kilogram"`
- **THEN** the expression becomes `"5 kilogram "` (with a trailing space) and the cursor is placed at offset 12

#### Scenario: Partial token mid-expression replaced
- **WHEN** the expression is `"3 kg + 2 gra"` and the cursor is after `"gra"`, and the user taps the unit suggestion `"gram"`
- **THEN** the expression becomes `"3 kg + 2 gram "` (trailing space) and the cursor is at offset 14

#### Scenario: Suggestions cleared after a unit insertion
- **WHEN** the user taps a unit suggestion
- **THEN** the completion area shows no suggestions

#### Scenario: Evaluation triggered after insertion (real-time mode)
- **WHEN** the evaluation mode is real-time and the user taps a suggestion
- **THEN** evaluation is scheduled (with the normal debounce) using the updated expression text

#### Scenario: Focus returns to the field
- **WHEN** the user taps a suggestion for the focused field
- **THEN** that field has focus afterwards and the cursor is after the inserted text

### Requirement: Both freeform fields support completion
The system SHALL provide predictive completion for both the "Convert from" and
"Convert to" freeform expression fields.  The two fields share one completion
area, which SHALL show the suggestions for the currently focused field only,
and a tapped suggestion SHALL be inserted into that field.

#### Scenario: Convert-from field shows completions
- **WHEN** the user types `"kilo"` in the "Convert from" field
- **THEN** matching suggestions appear in the completion area

#### Scenario: Convert-to field shows completions
- **WHEN** the user types `"kilo"` in the "Convert to" field
- **THEN** matching suggestions appear in the completion area

#### Scenario: Only the focused field's completions are shown
- **WHEN** the "Convert from" field contains `"km"` and is not focused, and the "Convert to" field is focused and contains `"met"`
- **THEN** the completion area shows the suggestions for `"met"` only

#### Scenario: Suggestion is inserted into the focused field
- **WHEN** the "Convert to" field is focused and the user taps a suggestion
- **THEN** the "Convert to" field's text changes and the "Convert from" field's text does not

### Requirement: Completion area display
The system SHALL display completion suggestions in a completion area on the
freeform screen, located below the result display and above the operator key
panel, whenever a freeform expression field has focus, a token is detected at
its cursor, and at least one suggestion exists.  The area is part of the page
layout: it SHALL NOT cover either expression field or the result display.

Suggestions SHALL be shown as chips in rank order, flowing left to right and
wrapping onto further lines.  When the chips do not fit in the area's height,
the area SHALL scroll vertically so that every suggestion (up to the repository
limit of 50) can be reached.  The scroll position SHALL return to the top when
the suggestions change.  Each chip SHALL have a touch target at least 48 dp
high and 48 dp wide, and SHALL NOT be wider than the area; a name too long to
fit is truncated with an ellipsis.

Each chip SHALL show a kind-annotated label for the suggestion:

- **Unit** entries: the plain identifier name (e.g. `kg`)
- **Prefix** entries: the name followed by a `-` (e.g. `kilo-`) to signal that a
  unit name follows; the dash is for display only and is NOT inserted into the
  field on selection
- **Function** entries: the name followed by `(` (e.g. `tempC(`) matching
  call-site convention; the `(` IS inserted into the field on selection

The area SHALL show no suggestions as soon as: (a) no expression field has
focus, (b) the token becomes empty, (c) no suggestions match, or (d) the cursor
moves outside any identifier.

#### Scenario: Suggestions appear while typing
- **WHEN** the user types `"km"` in a focused freeform field
- **THEN** the completion area shows chips for the matching names, in rank order

#### Scenario: Fields and result stay visible
- **WHEN** suggestions are showing and the screen has room for the content and at least one chip line
- **THEN** both expression fields and the result display are fully visible and no chip overlaps them

#### Scenario: No suggestions when there are no matches
- **WHEN** the user types a token that matches no unit, function, or prefix (e.g. `"zzz"`)
- **THEN** the completion area shows no chips

#### Scenario: Suggestions cleared on focus loss
- **WHEN** the user taps outside the freeform fields
- **THEN** the completion area shows no chips

#### Scenario: Suggestions cleared when token clears
- **WHEN** the user deletes all characters of the partial identifier
- **THEN** the completion area shows no chips

#### Scenario: All suggestions reachable by scrolling
- **WHEN** more suggestions match than fit in the area
- **THEN** the area scrolls vertically and the last suggestion can be scrolled into view

#### Scenario: Scroll position resets when suggestions change
- **WHEN** the area has been scrolled and the user types another character
- **THEN** the area shows the new suggestions from the top

#### Scenario: Kind-annotated labels
- **WHEN** the suggestions include the unit `kg`, the prefix `kilo`, and the function `tempC`
- **THEN** their chips read `kg`, `kilo-`, and `tempC(`

#### Scenario: Touch target size
- **WHEN** a chip is rendered for a two-character name
- **THEN** its tappable region is at least 48 dp high and 48 dp wide

### Requirement: Completion area layout
The completion area SHALL occupy the vertical space that remains between the
bottom of the freeform content (expression fields and result display) and the
operator key panel, so that it grows on tall screens and when the content is
short.  While suggestions are showing, the area SHALL be at least one chip
line (48 dp) high: when less space than that remains, the area SHALL take the
difference from the scrolling content, which stays scrollable.  While no
suggestions are showing, the area SHALL NOT reserve any height from the
content.  The area SHALL follow the same maximum readable width as the
expression fields, and the same layout SHALL apply at every window width and
on every platform.

#### Scenario: Area fills the free space
- **WHEN** suggestions are showing and 160 dp remain between the result display and the key panel
- **THEN** the completion area is 160 dp high and the content above it does not move

#### Scenario: One-line floor on a short screen
- **WHEN** suggestions are showing and less than 48 dp remain below the content
- **THEN** the completion area is 48 dp high and the content above it scrolls

#### Scenario: No reserved height without suggestions
- **WHEN** no suggestions are showing on a screen where less than 48 dp remain below the content
- **THEN** the content has the full height available to it

#### Scenario: Width matches the fields on a wide layout
- **WHEN** the freeform pane is wider than the readable width
- **THEN** the completion area's left and right edges align with those of the expression fields
