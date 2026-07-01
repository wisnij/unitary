## Context

Every top-level screen is a `Scaffold` whose `body` draws full-bleed to the
physical screen edge; there is no `SafeArea` anywhere in `lib/`.  On a device
with a display cutout, only content that physically aligns with the cutout is
obscured, so the symptom varies by screen and scroll position (e.g. a left-edge
camera hole in landscape hides part of the Freeform "Convert to" field and Browse
rows, while About — which has few rows near the top — looks clean).  The
variation is accidental alignment, not any per-widget code difference: the
affected and unaffected widgets share identical insets (all list rows and the
Settings section headers use a 16px left inset).

Flutter surfaces the platform's safe-area geometry through
`MediaQuery.of(context).padding`, populated from Android `WindowInsets` /
display-cutout insets and iOS `safeAreaInsets`.  `SafeArea` consumes that padding
and zeroes it for descendants, so the fix is structural and device-agnostic.

## Goals / Non-Goals

**Goals:**

- No content on any top-level screen (or the navigation rail) is ever drawn
  behind a display cutout or system bar, in any orientation.
- Insets are driven entirely by platform-reported `MediaQuery` values; nothing is
  hard-coded.
- Confirm the Android side actually reports cutout insets, so `SafeArea` has
  something to act on rather than silently no-op'ing.

**Non-Goals:**

- 48dp minimum touch targets on the Freeform operator-key panel (accessibility
  item, tracked separately).
- Tablet content-max-width / spacing polish (verification item, tracked
  separately).
- Flowing content *around* the cutout (e.g. via `displayFeatures`); we only
  inset.

## Decisions

### Wrap each `Scaffold` body in `SafeArea`, not the whole app

Place `SafeArea` **inside** each `Scaffold`, wrapping `body:`.  Wrapping outside
the `Scaffold` (or centrally in `AppShell` around the page stack) would push the
`AppBar` down and fight Material's own inset handling; the `AppBar` already insets
its content, so only the body needs it.  A single central wrapper is also wrong
because at compact/medium widths `AppShell` returns each page directly and each
page owns its `Scaffold` — the natural, uniform seam is each `Scaffold.body`.

Alternatives considered: a shared `SafeScaffold` wrapper widget.  Deferred — with
only five screens plus two pushed sub-screens, a direct `SafeArea` wrap is
clearer and avoids a new abstraction; a wrapper can be extracted later if the
count grows.

### Rail wrapped at the `AppShell` level

At expanded width `AppShell` builds the rail `Row` itself (outside the pages'
`Scaffold`s), so the rail is wrapped there.  Because `SafeArea` zeroes padding for
descendants, a rail-level `SafeArea` plus each page's body-level `SafeArea` do not
double-inset — nesting is safe and idempotent.

### Simple whole-pane inset for scrolling lists (first pass)

For the full-height lists (Browse, Worksheet template list, Settings, About) use
the plain `SafeArea(child: ListView)` form: the list is inset as a whole, leaving
a thin blank strip on the cutout side, and rows never sit under the hole.  The
"scroll-under" alternative (rows pass behind the cutout but list `padding` is fed
from `MediaQuery.padding` so content clears it at rest) is more native-feeling but
more code; defer it and revisit only if the blank strip looks wrong.

### Verify Android edge-to-edge / cutout mode

`SafeArea` only helps if the platform reports a non-zero inset.  On Android the
app must draw into the cutout region (edge-to-edge / `layoutInDisplayCutoutMode`)
for `MediaQuery.padding` to include the cutout.  Recent Flutter on Android 15+ is
edge-to-edge by default; confirm on the actual device that the left-edge cutout
now yields a non-zero `padding.left`, and add the manifest/theme setting if not.
This is the one step that can't be validated purely in code review.

## Risks / Trade-offs

- **`SafeArea` no-ops because the platform reports no cutout inset** → Verify on a
  real cutout device that `MediaQuery.padding` is non-zero; add Android
  edge-to-edge / cutout-mode config if needed.  This is an explicit task.
- **Double insets / visible gaps from nested `SafeArea`s** → `SafeArea` zeroes
  padding for descendants, so nesting is idempotent; body + rail wrapping is
  safe.
- **Blank strip on the cutout side of scrolling lists looks unpolished** → accept
  for the first pass; the scroll-under refinement remains available if needed.
- **Widget-test coverage** → safe-area behavior depends on ambient
  `MediaQuery.padding`; tests can pump a widget under a `MediaQuery` with a
  non-zero `padding` and assert content is offset, without a real device.
