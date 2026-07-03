## Context

Two Freeform-mode surfaces are custom-built from primitive widgets and carry no
accessibility metadata:

- **Operator key panel** (`_KeyPanel` in `freeform_screen.dart`): a `Row` of
  `TextButton`s, one per glyph in
  `freeformKeyPanelSymbols = ['^', '*', '/', '|', '+', '-', '~', '(', ')']`.
  Each button's child is a bare `Text(sym)`.  A `TextButton` is natively a
  semantic button, but its label defaults to the child text — the glyph — so a
  screen reader announces "caret", "asterisk", "tilde", or nothing useful.
- **Completion overlay** (`_buildSuggestions` in `completion_field.dart`): an
  `InkWell` per suggestion whose child is `Text(_displayName(entry))`.
  `_displayName` returns the plain name for units, `name-` for prefixes, and
  `name(` for functions.  The kind is encoded purely in that trailing
  punctuation, which a screen reader reads literally ("kilo dash") or drops.

There is currently no `Semantics` usage anywhere in `lib/`, so this establishes
the pattern.

## Goals / Non-Goals

**Goals:**

- Each operator key announces the operation it performs.
- Each completion suggestion announces its name and kind.
- Zero visual change; zero behavioral change to tap/scroll/focus.

**Non-Goals:**

- Live-region announcement of evaluation results or worksheet errors (separate
  change).
- Contrast audit and touch-target sizing (separate changes).
- Relabeling the text fields themselves or other screens.

## Decisions

### Wrap each control in `Semantics(label: …)`

Wrap the `TextButton`'s child (or the button) so the accessible label is the
action word, and exclude the raw glyph from the semantics subtree so it is not
also announced.  Concretely, use `Semantics(label: <word>, child: ExcludeSemantics(child: Text(sym)))`
inside each key, and the analogous wrap around each suggestion's `Text`.

- **Why not `TextButton`'s own semantics?** Its label is derived from the child
  text; overriding requires a `Semantics`/`ExcludeSemantics` pair regardless.
- **Why `ExcludeSemantics` on the glyph?** Without it, Flutter may merge the
  child `Text` node's label with ours, producing "multiply asterisk".

### Operator label map

Add a `const Map<String, String>` from glyph to action word, colocated with
`freeformKeyPanelSymbols` in `freeform_screen.dart`.  Proposed wording:

| Glyph | Label              |
|-------|--------------------|
| `^`   | power              |
| `*`   | multiply           |
| `/`   | divide             |
| `\|`  | numeric divide     |
| `+`   | plus               |
| `-`   | minus              |
| `~`   | inverse            |
| `(`   | open parenthesis   |
| `)`   | close parenthesis  |

`|` is the high-precedence division operator ("numeric divide") and `~` is the
inverse-function operator, matching their meaning elsewhere in the parser.  A
lookup miss falls back to the glyph itself so a future added symbol is never
label-less (and a test asserts full coverage of `freeformKeyPanelSymbols`).

### Completion label format

Compose `"<name>, <kind>"` where kind is the lower-cased
`CompletionEntryKind` value ("unit" / "prefix" / "function").  Reuse
`entry.name` (not `_displayName`) so the spoken name has no trailing
punctuation.  A small `_semanticLabel(entry)` helper mirrors the existing
`_displayName` / `_insertText` switch.  Write the kind mapping as an
**exhaustive `switch` expression with no `default`** so that adding a new
`CompletionEntryKind` variant is a compile error until it is given a label —
a compile-time coverage guard.

### Coverage-style tests, not spot-checks

Wherever a set of UI elements is driven by an enumerable source, the guard test
SHALL assert the label over the *whole source*, not a hand-picked example, so
that adding a new element without a label fails a test.  This is the intent
behind the operator-key test iterating all of `freeformKeyPanelSymbols` rather
than checking one key.  The two coverage anchors here:

- **Operator keys**: iterate `freeformKeyPanelSymbols` and assert every glyph
  resolves to a non-empty, non-glyph label — a new symbol added to that list
  with no map entry fails.
- **Completion kinds**: iterate `CompletionEntryKind.values` and assert each
  yields a label containing its kind word.  Combined with the exhaustive
  `switch`, a new kind is caught at compile time *and* by an assertion.

Additionally, at the render level, assert that the *count* of semantics-labelled
rows/keys equals the count of source elements, so a rendering path that bypasses
the `Semantics` wrapper is caught even if the label helper itself is correct.

## Risks / Trade-offs

- **[Merged/duplicated announcements]** → Use `ExcludeSemantics` around the
  visible glyph/text so only our label is exposed; add widget tests asserting
  the semantics label via `find.bySemanticsLabel` / `matchesSemantics`.
- **[Wording bikeshedding]** ("power" vs "caret", "per" vs "pipe") → Chosen to
  match the operator's parser meaning, not its typographic name; centralized in
  one map so it is trivial to revise after on-device VoiceOver/TalkBack review.
- **[Web semantics]** Flutter web only builds the semantics tree once assistive
  tech is detected; this does not affect the widget-level tests, which enable
  semantics explicitly via `SemanticsTester` / `tester.ensureSemantics()`.

## Open Questions

- Should the label order be "kilo, prefix" or "prefix kilo"? Starting with
  name-first so the most-identifying token is spoken first; easy to flip.
- Do the operator keys also warrant `button` semantics hints beyond the label?
  `TextButton` already contributes the button role, so no extra hint is planned.
