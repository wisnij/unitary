## Context

The app has three top-level pages (Freeform, Worksheet, Browse), each implemented as its own `Scaffold` with its own `AppBar` and a shared `AppDrawer`.  `HomeScreen` wraps the three in an `IndexedStack` (no Scaffold of its own) to preserve per-page widget state across navigation.  Navigation is drawer-only; the Browse detail page is reached via `Navigator.push`; the Worksheet template selector is an `AppBar` dropdown; the Freeform history is reached via an `AppBar` button that opens a modal bottom sheet.

Nothing in the app is width-aware except `worksheet_screen.dart`, which uses `LayoutBuilder` solely to size its label column.  On tablets and desktop-web browsers the single-column layouts stretch full-bleed and waste horizontal space.

The owner has stated a preference for an architecturally clean result over minimizing diff size; this is a pre-1.0 app and disruptive refactors are acceptable when they pay off.

## Goals / Non-Goals

**Goals:**

- Three responsive tiers from two width breakpoints: compact (`<600`, drawer + single pane), medium (`600–1040`, drawer + two panes), expanded (`>1040`, rail + two panes).
- One source of truth for the current tier (`WindowSizeClass`) and for top-level navigation chrome (`AppShell`).
- Centralize the rail-vs-drawer navigation decision in one shell, layered around the existing pages.
- Two-pane views: Browse (list | detail), Worksheet (template list | worksheet), Freeform (page | history).
- Preserve each page's existing compact behavior unchanged.
- No new package dependency.

**Non-Goals:**

- A draggable/resizable pane divider (fixed split for v1).
- A shared `ListDetailLayout` abstraction (deliberately deferred — see Decisions).
- Refactoring Freeform's field/evaluation state out of widget `State` into a notifier — Freeform is the only top-level page whose AppBar actions are coupled to widget `State` (its `TextEditingController`s), so the shell does **not** build its AppBar; this inconsistency is left for a separate follow-up change (see Decisions §2 and Open Questions).
- Changing persistence, the evaluation engine, the worksheet engine, or any data model.
- Re-theming, accessibility, or performance work (separate Phase 9 items).
- Seamless live-resize handoff of an already-pushed compact detail route into the embedded pane (see Risks).

## Decisions

### 1. Two breakpoints, one `WindowSizeClass`, derived from `MediaQuery`

A `WindowSizeClass { compact, medium, expanded }` enum is computed as a pure function of `MediaQuery.sizeOf(context).width` against two constants (`600`, `1040`, aligned with common Material window-size-class breakpoints).  It is the single definition of both breakpoints; `AppShell` reads it to pick drawer vs rail, `TwoPaneLayout` reads it to pick single vs split, and tier-aware AppBar bits read it where they adapt.

- **Why a derived helper, not Riverpod state:** window size is ephemeral UI state already owned by `MediaQuery`.  Mirroring it into a provider would mean watching `MediaQuery` from outside the widget tree.  A pure `WindowSizeClass.of(context)` is idiomatic and trivially testable — widget tests set the surface size and the enum follows.
- **Alternatives considered:** the `flutter_adaptive_scaffold` package (rejected: adds a dependency for ~10 lines of breakpoint logic and less control over the destination model); a single breakpoint (rejected: the requirement explicitly wants drawer + two-pane as a distinct middle tier).

### 2. App shell layers navigation around pages that keep their own AppBar

`HomeScreen` becomes `AppShell`, which owns the rail-vs-drawer decision and wraps the existing pages; each page keeps its own `Scaffold`, `AppBar`, and body.

```
class AppShell ... {
  // currentPage + onNavigate, as HomeScreen does today.
  Widget build(...) {
    final body = IndexedStack(index: currentPage.index, children: pages);
    if (WindowSizeClass.of(context).usesRail) {
      return Row([ NavigationRail(...), VerticalDivider(), Expanded(child: body) ]);
    }
    return body;   // pages own their drawer at compact/medium
  }
}
```

- At **expanded**: the shell renders a persistent `NavigationRail` (with the three destinations plus Settings/About) beside the page; the rail is built **once**, outside the `IndexedStack`. The active page's `Scaffold` provides the `AppBar` to the right of the rail, with no hamburger and no drawer.
- At **compact/medium**: the shell renders the page directly; the page's own `Scaffold` supplies its `AppBar` (with hamburger) and the shared `AppDrawer`, exactly as today.

Each page becomes width-aware in two small ways: `drawer: sizeClass.usesRail ? null : AppDrawer(...)` and `appBar: AppBar(automaticallyImplyLeading: !sizeClass.usesRail, …)`. A lightweight destination descriptor (`{icon, label, page}`) drives the rail items and drawer tiles; it does **not** build AppBars.

- **Why pages keep their AppBar (approach B):** Freeform's AppBar history/conformable actions and its history-restore mutate the `TextEditingController`s that live in `_FreeformScreenState`, so unlike Worksheet and Browse (whose AppBar controls are notifier-driven), the shell cannot build Freeform's AppBar without first lifting that state into a notifier. Bundling that rewrite — which touches Freeform's debounce, focus handling, and the web select-all workaround — into a layout change risks a behavior regression in the trickiest code. Keeping pages' AppBars intact makes the layout change small, low-risk, and reviewable.
- **Trade-off accepted:** the per-page `Scaffold`/`AppBar` wrappers remain (the `AppDrawer` is already a shared widget, so the residual duplication is small). Full AppBar centralization would require the Freeform state lift; it is deferred to its own change where it can be tested in isolation (see Open Questions). This sequencing keeps each change coherent and is reversible — the shell can absorb AppBar construction later without redoing the rail.
- **Alternative considered — single shell `Scaffold` that builds every AppBar from a rich `AppDestination`** (`buildTitle`/`buildActions`/`buildBody`): rejected for this change because it forces the Freeform state rewrite; revisit once Freeform is notifier-backed.

### 3. `TwoPaneLayout` is pure geometry; pages own their selection logic

`TwoPaneLayout` reads `WindowSizeClass`: at medium/expanded it renders a `Row` of the two panes separated by a `VerticalDivider`; at compact it renders only the page's designated primary pane.  It knows nothing about units, templates, or history.

Each pane takes an explicit `PaneSize` so callers control the relative widths:

```dart
sealed class PaneSize {
  const PaneSize.fixed(double width);                     // exact dp
  const PaneSize.fitContent({double? min, double? max});  // shrink-wrap, clamped
  const PaneSize.fill({int flex = 1});                    // absorb remaining space
}

TwoPaneLayout({
  required Widget left,
  required Widget right,
  PaneSize leftSize  = const PaneSize.fitContent(),
  PaneSize rightSize = const PaneSize.fill(),
  required PaneSide compactPrimary,   // which pane survives at compact width
})
```

Each mode is a thin wrapper over a `Row` child: `fixed` → `SizedBox(width:)`; `fitContent` → a non-flex child under a `ConstrainedBox(min/max)` (sizes to its content); `fill` → `Expanded(flex:)`.  Non-fill panes lay out first at their fixed/intrinsic width, then fill panes split the remainder by flex.  A ratio split is just both panes in `fill` mode with the desired flex factors (e.g. `1` and `2`).

Per-page choices:

- **Worksheet** — template list `fixed(220)` (the list is a scrolling `ListView`, which has no finite intrinsic width, so `fitContent` is not viable here), worksheet `fill()`.
- **Browse** — catalog list and detail/placeholder both `fill()` (equal 1:1 split).
- **Freeform** — input/result column `fill()`, history `fixed`/`fitContent(max:)`.

Each page composes its own selection wiring on top:

- **Freeform** — left = the existing input/result column; right = the history list (the data already lives in `freeformHistoryProvider`; tap-to-restore already exists).  Compact keeps the AppBar history button + modal.
- **Worksheet** — left = a template list; right = the active worksheet rows.  Selecting a template is the same action the dropdown fires today (`WorksheetNotifier` already holds the active template).  Compact keeps the AppBar dropdown.
- **Browse** — left = the existing catalog list; right = the detail body, or an empty "select a unit" placeholder.  Compact keeps push navigation.

- **Why no `ListDetailLayout`:** only Browse and Worksheet are list-detail, and they diverge materially — Browse has an empty state, a searchable/grouped list, and a new selection source; Worksheet always has an active item and a compact dropdown affordance.  Freeform is not list-detail at all.  A super-widget spanning two divergent cases would need enough flags (`hasEmptyState`, `compactMode: push|dropdown`, custom list builders) to be more tangled than ~15 lines of per-page wiring.  Extract it later if a third genuine instance appears.

### 4. Browse selection lifted into `BrowserState`

Today the selected entry has no home — it is a `Navigator.push` argument (`browser_screen.dart:297`).  For an embedded pane it must be state, so `selectedPrimaryId` + `selectedKind` (or a `BrowseEntry?`) move into `BrowserState`/`BrowserNotifier`.  Both forms then read one source of truth: at compact, tapping sets selection and pushes a route that reads it; at wide, tapping sets selection and the embedded pane re-renders.  The detail body is extracted from `UnitEntryDetailScreen` into a Scaffold-less `UnitEntryDetailBody` used by both the pushed screen (compact) and the embedded pane (wide).

- **Bonus:** because selection is now state, widening the window simply makes the embedded pane show the same `selectedEntry`, so the live-resize edge largely dissolves.

### 5. Pane sizing modes, no drag handle in v1

Pane widths are set per-pane via `PaneSize` (decision #3): fixed dp, fit-to-content (clamped), or proportional fill.  This covers a fixed ratio (both panes `fill` with flex factors) and the "one pane hugs its content, the other fills" case (`fitContent` + `fill`).  A draggable divider is deferred — the clean layout makes adding one later straightforward (it becomes internal `TwoPaneLayout` state, with the drag offset overriding the static `PaneSize`).

## Risks / Trade-offs

- **Large blast radius across navigation + all three pages** → Land it in ordered steps that each keep tests green: (1) `WindowSizeClass`, (2) `AppShell` wrapping pages (pages still single-pane), (3) `TwoPaneLayout`, (4) adopt per page (Freeform → Worksheet → Browse).  The shell step is isolated and independently reviewable.

- **Browse selection-lift touches `BrowserState` + detail extraction** → Keep the existing pushed-route path working at compact width using the same lifted selection, so compact behavior is provably unchanged before the embedded pane is added.

- **AppBar content becomes tier-dependent** (Worksheet dropdown vs static title, Freeform history button shown only at compact) → Each page reads the single `WindowSizeClass` inside its own `AppBar` build, so there is no second breakpoint definition.

- **Live-resize of an already-pushed compact detail route** (web/foldables) → Out of scope; the pushed route simply remains on top until popped.  Acceptable because resize-during-detail is rare and selection state keeps the panes consistent once the route is dismissed.

- **Rail must not be duplicated per page** → The rail is built once by `AppShell` outside the `IndexedStack`; pages never render it, so there is exactly one rail instance.

## Open Questions

- **Freeform state lift (deferred follow-up).** Freeform is the only top-level page holding significant logic in widget `State` (its input/output `TextEditingController`s and the evaluate/restore/swap/clear flow) rather than a notifier.  A future change should move this into a keepAlive notifier to match Worksheet/Browse, which would also let a later iteration centralize AppBar construction in `AppShell`.  Intentionally out of scope here to avoid regressions in Freeform's debounce/focus/web-select-all handling.

- **`fitContent` panes require finite intrinsic width** → A vertical scrolling `ListView` has no intrinsic width and, as a non-flex `Row` child, receives an unbounded width constraint and throws.  So `fitContent` is safe only for content that sizes itself (e.g. a `Column`/`Wrap` like the Worksheet template list).  For the Browse catalog and Freeform history (scrolling lists) use `fixed`, or `fitContent` **with a `max`** — the `max` supplies the bounded constraint that makes the pane legal.  This constraint is called out so per-page sizing choices don't accidentally pick unbounded `fitContent` for a list.
