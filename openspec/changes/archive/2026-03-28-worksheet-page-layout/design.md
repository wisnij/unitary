# Design: worksheet-page-layout

## Context

`HomeScreen` owns the single app-level `Scaffold` (with drawer and AppBar) and
embeds `FreeformScreen` as a body-only widget — no Scaffold of its own.
Worksheet is a pushed route: `Navigator.push(MaterialPageRoute(WorksheetScreen))`.
Because `WorksheetScreen` is pushed, Flutter automatically places a back-arrow
in the AppBar leading position and creates its own `Scaffold` with no drawer.

The fix is to bring worksheet in-line with how freeform works: both are body
widgets embedded in the shared shell, selected via the drawer.

## Goals / Non-Goals

**Goals:**

- Worksheet screen shows hamburger menu icon (drawer toggle) in AppBar leading
  position, identical to freeform.
- The drawer's `selected` highlight tracks the currently active page.
- No regressions to worksheet functionality (template dropdown, row editing,
  in-session state retention, etc.).

**Non-Goals:**

- Animated page transitions between freeform and worksheet.
- Any other navigation destinations (settings, about) are unchanged — they
  remain as pushed secondary routes.
- Persistent storage of the last-active top-level page across sessions.

## Decisions

### Decision 1: shared Scaffold in `HomeScreen`, not duplicated drawers

**Choice:** Add a `_TopLevelPage` enum (`freeform`, `worksheet`) as state on
`HomeScreen`.  The drawer switches the active page; the body and AppBar title
are derived from the active value.

**Rejected alternative:** Add a duplicate `drawer:` to `WorksheetScreen`'s own
`Scaffold`.  This avoids refactoring the Scaffold hierarchy but duplicates all
drawer code and still requires keeping both copies in sync.  Discarded.

**Rejected alternative:** Named routes / `Router`.  Over-engineered for two
peer destinations; would require touching `main.dart` and the route table for
no user-visible gain.

### Decision 2: `WorksheetScreen` becomes body-only (no `Scaffold`)

`WorksheetScreen` currently returns a `Scaffold`.  Strip the `Scaffold` wrapper
and have it return its `ListView` body directly, exactly like `FreeformScreen`.

The template-selector dropdown — currently the `Scaffold`'s `appBar title` —
must be hoisted into `HomeScreen`'s AppBar.  `HomeScreen` conditionally renders
`Text('Unitary')` (freeform) or the dropdown widget (worksheet) as the AppBar
title.

To keep the dropdown widget accessible from `HomeScreen`, rename
`_WorksheetDropdown` (private) to `WorksheetDropdown` (exported).  It lives in
the worksheet feature directory; `HomeScreen` imports it.

### Decision 3: drawer tap replaces `Navigator.push` with `setState`

For the two peer top-level destinations, the drawer taps call `setState` on
`HomeScreen` (switching `_currentPage`) rather than pushing a route.  Settings
and About remain as pushed secondary routes unchanged.

## Risks / Trade-offs

- **Back-button behavior:** Removing the pushed route means the Android back
  button will exit the app from worksheet mode rather than returning to freeform.
  This is the correct behavior for peer top-level destinations (mirrors how
  every app with bottom-nav or a drawer works).  No mitigation needed.

- **`WorksheetScreen` controller lifecycle:** Controllers are currently disposed
  in `WorksheetScreen.dispose()`.  As a persistent body widget (never fully
  disposed while the app runs), controllers will live for the app's lifetime —
  which is the intended behavior for in-session retention.  No change needed.

- **`HomeScreen` rebuild on page switch:** Switching pages calls `setState` on
  `HomeScreen`, which rebuilds the AppBar and swaps the body widget.
  `FreeformScreen` and `WorksheetScreen` are both `ConsumerStatefulWidget`s;
  their internal state is preserved across rebuilds as long as their widget
  subtree stays mounted.  Using an `IndexedStack` (keep both mounted) vs
  conditional rendering (unmount the inactive one) is a choice:

  - `IndexedStack`: in-session state always preserved even if Riverpod notifier
    were ever cleared; slightly higher memory use.
  - Conditional rendering: slightly simpler; Riverpod `non-autoDispose` notifiers
    already guarantee in-session retention independent of widget lifetime.

  **Choice:** Conditional rendering (`if (_page == Page.freeform) FreeformScreen() else WorksheetScreen()`).  Simpler; Riverpod already owns the retention guarantee.

## Open Questions

None.
