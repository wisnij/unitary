## Context

The app has three top-level pages (Freeform, Worksheet, Browse), each implemented as its own `Scaffold` with its own `AppBar` and a shared `AppDrawer`.  `HomeScreen` wraps the three in an `IndexedStack` (no Scaffold of its own) to preserve per-page widget state across navigation.  Navigation is drawer-only; the Browse detail page is reached via `Navigator.push`; the Worksheet template selector is an `AppBar` dropdown; the Freeform history is reached via an `AppBar` button that opens a modal bottom sheet.

Nothing in the app is width-aware except `worksheet_screen.dart`, which uses `LayoutBuilder` solely to size its label column.  On tablets and desktop-web browsers the single-column layouts stretch full-bleed and waste horizontal space.

The owner has stated a preference for an architecturally clean result over minimizing diff size; this is a pre-1.0 app and disruptive refactors are acceptable when they pay off.

## Goals / Non-Goals

**Goals:**

- Three responsive tiers from two width breakpoints: compact (`<600`, drawer + single pane), medium (`600–1040`, drawer + two panes), expanded (`>1040`, rail + two panes).
- One source of truth for the current tier (`WindowSizeClass`) and for top-level navigation (`AppShell` + `AppDestination`).
- Eliminate the per-page `Scaffold`/`AppBar`/`Drawer` duplication.
- Two-pane views: Browse (list | detail), Worksheet (template list | worksheet), Freeform (page | history).
- Preserve each page's existing compact behavior unchanged.
- No new package dependency.

**Non-Goals:**

- A draggable/resizable pane divider (fixed split for v1).
- A shared `ListDetailLayout` abstraction (deliberately deferred — see Decisions).
- Changing persistence, the evaluation engine, the worksheet engine, or any data model.
- Re-theming, accessibility, or performance work (separate Phase 9 items).
- Seamless live-resize handoff of an already-pushed compact detail route into the embedded pane (see Risks).

## Decisions

### 1. Two breakpoints, one `WindowSizeClass`, derived from `MediaQuery`

A `WindowSizeClass { compact, medium, expanded }` enum is computed as a pure function of `MediaQuery.sizeOf(context).width` against two constants (`600`, `1040`, aligned with common Material window-size-class breakpoints).  It is the single definition of both breakpoints; `AppShell` reads it to pick drawer vs rail, `TwoPaneLayout` reads it to pick single vs split, and tier-aware AppBar bits read it where they adapt.

- **Why a derived helper, not Riverpod state:** window size is ephemeral UI state already owned by `MediaQuery`.  Mirroring it into a provider would mean watching `MediaQuery` from outside the widget tree.  A pure `WindowSizeClass.of(context)` is idiomatic and trivially testable — widget tests set the surface size and the enum follows.
- **Alternatives considered:** the `flutter_adaptive_scaffold` package (rejected: adds a dependency for ~10 lines of breakpoint logic and less control over the destination model); a single breakpoint (rejected: the requirement explicitly wants drawer + two-pane as a distinct middle tier).

### 2. App shell with a destination model (replaces per-page chrome)

`HomeScreen` becomes `AppShell`: a single `Scaffold` that owns navigation chrome and builds the `AppBar` and body from the **active** `AppDestination`.

```
abstract class AppDestination {
  IconData get icon;
  String get label;
  Widget buildTitle(BuildContext, WindowSizeClass);      // e.g. Worksheet: dropdown (compact) vs name (wide)
  List<Widget> buildActions(BuildContext, WindowSizeClass);
  Widget buildBody(BuildContext, WindowSizeClass);        // internally uses TwoPaneLayout when wide
}
```

`AppShell` keeps a `const destinations = [Freeform, Worksheet, Browse]` list — the rail items, drawer tiles, and active AppBar all derive from it.  At expanded width it renders `Scaffold(appBar:…, body: Row[NavigationRail, VerticalDivider, Expanded(IndexedStack)])` with no drawer; below expanded it renders `Scaffold(appBar:…, drawer: AppDrawer, body: IndexedStack)`.  The `IndexedStack` over the destination bodies is retained, so per-page state preservation is unchanged.

- **Why the shell owns the AppBar:** the leading icon (hamburger vs none) and the rail/drawer choice are navigation concerns, not page concerns.  Centralizing them removes three near-identical `Scaffold`/`AppBar`/`Drawer` blocks and makes "hamburger at compact/medium, rail at expanded" a single decision.  AppBar actions remain Riverpod `Consumer` widgets, so Worksheet's refresh button and Browse's search/expand controls work regardless of where the shell mounts them.
- **Alternative considered — keep per-page Scaffolds, inject a rail into each page body** (the minimal-diff option): rejected per the clean-architecture preference; it triplicates the rail and leaves navigation logic smeared across three pages.

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

- **Worksheet** — template list `fitContent()` (short, bounded names like "Digital Storage"), worksheet `fill()`.
- **Browse** — catalog list `fixed(~320)` (or `fitContent(max:)`), detail/placeholder `fill()`.
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

- **Large blast radius across navigation + all three pages** → Land it in ordered steps that each keep tests green: (1) `WindowSizeClass`, (2) `AppShell`/`AppDestination` (pages still single-pane), (3) `TwoPaneLayout`, (4) adopt per page (Freeform → Worksheet → Browse).  The disruptive shell step is isolated and independently reviewable.

- **Browse selection-lift touches `BrowserState` + detail extraction** → Keep the existing pushed-route path working at compact width using the same lifted selection, so compact behavior is provably unchanged before the embedded pane is added.

- **AppBar content becomes tier-dependent** (Worksheet title, Freeform history button) → Encapsulate the tier branch inside each destination's `buildTitle`/`buildActions`, driven by the single `WindowSizeClass`, so there is no second breakpoint definition.

- **Live-resize of an already-pushed compact detail route** (web/foldables) → Out of scope; the pushed route simply remains on top until popped.  Acceptable because resize-during-detail is rare and selection state keeps the panes consistent once the route is dismissed.

- **Three rail instances alive in the `IndexedStack`** (one per destination body) is avoided: the rail is built once by `AppShell` outside the `IndexedStack`, not inside each page.

- **`fitContent` panes require finite intrinsic width** → A vertical scrolling `ListView` has no intrinsic width and, as a non-flex `Row` child, receives an unbounded width constraint and throws.  So `fitContent` is safe only for content that sizes itself (e.g. a `Column`/`Wrap` like the Worksheet template list).  For the Browse catalog and Freeform history (scrolling lists) use `fixed`, or `fitContent` **with a `max`** — the `max` supplies the bounded constraint that makes the pane legal.  This constraint is called out so per-page sizing choices don't accidentally pick unbounded `fitContent` for a list.
