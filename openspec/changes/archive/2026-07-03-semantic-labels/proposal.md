## Why

Two custom-built interactive surfaces in Freeform mode are opaque to screen
readers.  The operator key panel renders bare glyphs (`^`, `*`, `/`, `|`, `~`,
`(`, `)`) that TalkBack/VoiceOver either mispronounce or skip, and the
predictive-completion overlay announces only the visual display text (e.g.
`kilo-`, `tempC(`), with no indication of what kind of entry — unit, prefix, or
function — each suggestion is.  A blind or low-vision user cannot reliably tell
what a key does or what a suggestion represents.

This is the first of the Phase 9 accessibility items; it covers only the static
semantic labelling of these two surfaces.  Live-region announcements of results
and worksheet errors, the contrast audit, and touch-target sizing are tracked
separately.

## What Changes

- Give every operator key in the Freeform key panel an explicit accessible label
  describing the operation it performs (e.g. `*` → "multiply", `^` → "power",
  `~` → "inverse") rather than exposing the raw glyph to assistive technology.
- Give every predictive-completion suggestion an accessible label that includes
  both the suggestion name and its kind (unit / prefix / function), so the kind
  conveyed visually by the trailing `-` or `(` is also available to a screen
  reader.
- No visual change on screen: labels are exposed only through the semantics
  tree; the rendered glyphs and display text are unchanged.

## Capabilities

### New Capabilities

- `semantic-labels`: Custom-drawn interactive controls in Freeform mode (the
  operator key panel and the predictive-completion suggestion overlay) expose
  accessible labels through the semantics tree that describe their action and
  kind, independent of the visual glyph or display text.

### Modified Capabilities

<!-- None: this is additive semantics; no existing spec requirement changes.
     The freeform-keyboard and predictive-completion specs describe visual/
     behavioral requirements that are unaffected. -->

## Impact

- **Affected code**: `freeform_screen.dart` (the `_KeyPanel` operator keys) and
  `completion_field.dart` (the suggestion rows in `_buildSuggestions`).
- **No new dependencies**; uses Flutter's built-in `Semantics` widget.
- **No visual or behavioral change** — only the semantics tree gains labels;
  tap behavior, layout, and appearance are untouched.
- **Out of scope / deferred**: live-region announcement of evaluation results
  and per-row worksheet errors; the `onSurfaceVariant` contrast audit; 48 dp
  touch-target sizing.  Each is a separate Phase 9 accessibility change.
