## Context

The freeform expression fields accept arbitrary expressions that include unit
identifiers drawn from a repository of ~7 000 entries.  There is currently no
in-app way to discover or search unit names while typing.  The unit browser
exists as a separate page but requires leaving the expression field to look
something up.

Dart/Flutter's `TextField` and `Overlay` APIs are the relevant building blocks.
The `UnitRepository` already exposes `allUnits`, `allPrefixes`, and
`allFunctions`, plus lookup maps keyed by every registered name (id + aliases).
No new external packages are required.

## Goals / Non-Goals

**Goals:**

- Show a scrollable suggestion list below the focused freeform field whenever
  the cursor is inside a partial identifier.
- Source suggestions from the unit repository: unit IDs and aliases, function
  IDs and aliases, and named prefix IDs and aliases.
- Filter suggestions case-insensitively to those whose name starts with the
  current token.
- Rank results: primary-ID matches before alias-only matches; within each group,
  alphabetical by the matched name.
- Tap a suggestion to replace the partial token with the full identifier and
  advance the cursor past it.
- Cap the visible list at 8 items; allow scrolling for longer matches.
- Dismiss the overlay on focus loss, blank token, or cursor outside an
  identifier.

**Non-Goals:**

- Fuzzy / substring matching (prefix matching only for now).
- Suggestions in the worksheet numeric value fields (numbers-only fields).
- Ranking by usage frequency or recency.
- Showing unit descriptions or dimensions inline in the suggestion row.
- Any change to the worksheet screen.

## Decisions

### 1. Overlay strategy: Flutter `OverlayPortal` (not `Autocomplete`)

Flutter ships an `Autocomplete` widget that combines a `TextField` with a
suggestions overlay, but it replaces the entire `TextField` — it cannot be
layered onto the existing `FreeformScreen` layout or honour its state (debounce,
focus tracking, evaluation, history recording).

**Decision**: use `OverlayPortal` (introduced in Flutter 3.7), which lets a
widget insert content into the ambient `Overlay` while still being part of the
widget tree.  A `CompletionOverlay` wraps a given `TextField` in a
`CompletionField`, holds an `OverlayController`, and rebuilds the suggestion
list via `Consumer` (Riverpod).

Alternative considered: plain `Overlay.of(context).insert` — lower-level,
requires manual lifecycle management (insert/remove pairs), error-prone.
`OverlayPortal` handles all of that declaratively.

### 2. Token extraction: use the existing lexer

The `Lexer` already encodes exactly which characters are valid identifier bodies
(via `_isIdentifierBody` / `_identifierExcludedChars`) and handles every edge
case: scientific-notation exponents (`1e10` produces a single `number` token so
the `e` is never an identifier), the `per` keyword (mapped to `divide`), and all
Unicode operator variants.  Re-implementing this logic with a regex or hand-
written scanner would duplicate it and risk divergence.

**Algorithm** in `tokenAtCursor(String text, int cursorOffset)`:

1. Run `Lexer(text).scanTokens()`, catching `LexException`.  If it throws,
   return `null` — lexing only a prefix would give false positives (e.g.,
   `"123 ident|ifier"` would appear to end on an identifier when it does not).
2. Iterate the token list.  For each `identifier` token, compute its character
   range as `start = token.column - 1` and `end = start + token.lexeme.length`
   (expressions are single-line, so column equals char offset + 1).
3. If a token satisfies `start <= cursorOffset <= end`, the cursor is within
   that identifier.  Return a result only if `cursorOffset == end` (cursor is
   at the end of the token) **and** `token.lexeme.length >= 2`; otherwise
   return `null`.
4. If no identifier token spans the cursor, return `null`.

### 3. Suggestion computation: `suggestCompletions` on `UnitRepository`

A new `suggestCompletions(String prefix, {int limit = 50})` method on
`UnitRepository` returns a ranked `List<CompletionEntry>` (value object: `name`,
`isPrimaryId`, `entryKind` enum).  It iterates `_unitLookup`,
`_prefixLookup`, and `_functionLookup`, collecting entries whose lowercased name
**contains** the lowercased query.  Results are placed into four ordered tiers:

| Tier | Name starts with query? | Is primary ID? |
|------|-------------------------|----------------|
| 1    | Yes                     | Yes            |
| 2    | Yes                     | No (alias)     |
| 3    | No (infix match)        | Yes            |
| 4    | No (infix match)        | No (alias)     |

Each tier is sorted alphabetically (case-insensitive).  This avoids exposing
the raw maps and keeps the ranking logic in one place.

Returning up to 50 candidates at the domain layer (not the display cap of 8) so
that the UI can scroll without repeatedly hitting the repo.

### 4. Riverpod provider: `completionsProvider(CompletionQuery)`

A `family` `Provider` keyed on a `CompletionQuery` value object `(text,
cursorOffset)`.  It:

1. Calls `tokenAtCursor` to extract the token.
2. Returns `[]` if token is empty or shorter than 1 character.
3. Calls `repo.suggestCompletions(token)` and returns the result.

This is synchronous (no async needed), so `Provider` (not `FutureProvider`).

### 5. Insertion: replace the token range in the `TextEditingController`

On suggestion tap: call `tokenAtCursor` again on the controller's current value
(cursor may have moved), replace `text[start..end]` with the selected name, set
`controller.selection` to a collapsed selection at `start + name.length`.  Then
dismiss the overlay and re-trigger evaluation.

### 6. Platform-specific tap handling and focus restoration

On web, the browser fires a native `focusout` event on the `<input>` element at
**pointer-down** time (not pointer-up).  Flutter's `FocusNode` listener fires
synchronously, `setState` marks the widget dirty, and the post-frame callback
calls `_syncOverlay(false)` — hiding the overlay **before** `onTap` is
delivered.  On mobile this race does not occur because the focus change does not
happen until the touch is lifted.

**Decision**: branch on `kIsWeb` (`package:flutter/foundation.dart`):

- **Web** — `InkWell.onTapDown` fires at pointer-down, before the `focusout`,
  so the insertion runs while the overlay is still present.  `onTap` is kept
  non-null but is a no-op (`() {}`) so the `InkWell` still renders its press
  ripple.
- **Mobile** — `InkWell.onTap` (pointer-up) fires the insertion.
  `onTapDown` is left `null` because setting it on mobile would cause the
  insertion to fire at the start of every scroll drag, not just on a completed
  tap.

After insertion, `focusNode.requestFocus()` restores focus to the text field,
matching the pattern used by the operator key panel (`_insertSymbol` in
`FreeformScreen`).  On web, `requestFocus()` can cause the browser to select
all text in the field, so a `WidgetsBinding.addPostFrameCallback` re-applies the
correct cursor position (the collapsed offset returned by `applyCompletion`).

### 7. Overlay appearance and insertion conventions

**Border**: the overlay `Material` uses `shape: RoundedRectangleBorder(side:
BorderSide(color: colorScheme.outlineVariant))` — a 1 dp themed border that
makes the overlay visually distinct from the page surface without requiring a
hard-coded colour.

**Width**: the overlay shrinks to the width of its widest row using
`ConstrainedBox(maxWidth: fieldWidth) + IntrinsicWidth`.  The field width is
read from `this.context.findRenderObject()` at build time (no stored state
needed).  `IntrinsicWidth` requires that children implement intrinsic-width
layout; `ListView` does not, so the bounded list uses `SingleChildScrollView +
Column` instead.

**Scrollability**: `SizedBox(height: visibleCount * rowHeight)` caps the visible
area at `_kMaxVisibleRows` (8) rows.  `SingleChildScrollView` renders all
suggestions inside that fixed box and scrolls when the list is longer.
`suggestCompletions` returns up to 50 entries so that the UI can scroll the
full result without re-querying the repository.

**Kind-specific insertion** (`_displayName` / `_insertText`):

| Kind | Displayed as | Inserted as | Rationale |
|---|---|---|---|
| Unit | `name` | `name ` (+ space) | Cursor clears the token; user types next term immediately |
| Prefix | `name-` | `name` | Dash signals "unit follows" visually; not valid syntax alone |
| Function | `name(` | `name(` | Cursor lands inside call; matches call-site convention |

## Risks / Trade-offs

- **Performance on large repos**: iterating 7 000 + entries on every keystroke
  in the UI thread.  Mitigation: `suggestCompletions` is O(n) but fast in
  practice (no allocation in the hot path beyond the result list); measure before
  adding a background isolate.
- **Overlay positioning**: the `OverlayPortal` content is rendered relative to
  the overlay, which may clip at screen edges on small phones.  Mitigation: use
  `CompositedTransformFollower` + `CompositedTransformTarget` to anchor the
  popup to the field's position; clamp to screen bounds using `Align`.
- **Token detection false positives**: numbers like `1e10` contain letters.
  Using the lexer eliminates this: `1e10` is a single `number` token, so the
  `e` is never classified as an identifier.
- **Keyboard overlap on mobile**: the overlay may appear behind the system
  keyboard.  Mitigation: render the overlay *above* the field rather than below
  it when the field is in the bottom half of the viewport (check
  `RenderBox.localToGlobal` vs. `MediaQuery.of(context).size.height / 2`).
