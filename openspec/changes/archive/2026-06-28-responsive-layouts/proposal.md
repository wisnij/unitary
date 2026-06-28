## Why

Every screen in the app is a single column with its own `Scaffold`/`AppBar`/`Drawer`, so on tablets and desktop-web browsers the input fields and rows stretch edge-to-edge and the generous horizontal space goes unused.  Wide aspect ratios are a first-class target (tablet and desktop web), and the natural layout there is two panes: a list/navigation pane beside a content pane.

## What Changes

- Introduce three responsive tiers driven by window width:
  - **compact** (`< 600`): navigation drawer, single pane (today's behavior)
  - **medium** (`600`–`1040`): navigation drawer, two panes
  - **expanded** (`> 1040`): persistent navigation rail, two panes
- Add a `WindowSizeClass` primitive that derives the current tier from `MediaQuery` as the single source of truth for both breakpoints.
- Add an app shell (`AppShell`, replacing `HomeScreen`) that owns the adaptive top-level navigation: a shared `AppDrawer` at compact/medium widths and a persistent `NavigationRail` at expanded width, built once around the existing pages.  Each page keeps its own `Scaffold`/`AppBar` and becomes width-aware (hides its hamburger/drawer when the rail is shown).  (Centralizing `AppBar` construction in the shell is deferred to a follow-up, since Freeform's AppBar is coupled to its widget state.)
- Add a reusable `TwoPaneLayout` primitive (pure geometry) that shows both panes at medium/expanded and a single pane below.
- Adopt two-pane views per page (each keeps its existing compact form):
  - **Freeform:** input history moves to a right pane on wide screens (a section below the body when compact).
  - **Worksheet:** the worksheet-template list becomes a left pane on wide screens (the AppBar dropdown when compact).
  - **Browse:** the unit detail renders in an embedded right pane on wide screens (a pushed route when compact); selected entry is lifted into state, with a "nothing selected" empty pane.
- No new package dependency — built on Flutter's `NavigationRail`/`Drawer` and `MediaQuery`.
- Explicitly **not** building a `ListDetailLayout` abstraction yet: Browse and Worksheet diverge enough (empty state, compact affordance, selection source) that a shared list-detail super-widget would be premature; each page composes selection logic on top of `TwoPaneLayout`.

## Capabilities

### New Capabilities

- `window-size-class`: A responsive size-class primitive (`compact` / `medium` / `expanded`) derived from `MediaQuery` width, defining the two breakpoints used app-wide.
- `adaptive-navigation`: An app shell with a destination model that presents the navigation drawer at compact/medium widths and a persistent navigation rail at expanded width, building each page's AppBar from its destination.
- `two-pane-layout`: A reusable two-pane layout widget that renders both panes side by side at medium and expanded widths and collapses to a single pane at compact width.

### Modified Capabilities

- `unit-browser`: On wide screens the browser shows the selected unit's detail in an embedded right pane (instead of pushing a route); selection is lifted into browser state, with an empty-pane state when nothing is selected.
- `worksheet-ui`: On wide screens the worksheet-template selector becomes a left-pane list and the active worksheet fills the right pane; the AppBar dropdown is used only at compact width.
- `freeform-history`: On wide screens the freeform input history is shown in a right pane; it remains accessible via the AppBar button + modal when compact.

(Top-level page-state preservation is unchanged for drawer navigation; preservation across the new rail navigation is covered by the `adaptive-navigation` capability.)

## Impact

- **Navigation/shell:** `lib/shared/home_screen.dart` (becomes `AppShell`), `lib/shared/top_level_page.dart`, `lib/shared/widgets/app_drawer.dart`; new `AppShell` (with a lightweight destination descriptor for rail/drawer items), `WindowSizeClass`, and `TwoPaneLayout` in `lib/shared/`.
- **Pages:** `lib/features/freeform/presentation/freeform_screen.dart`, `lib/features/worksheet/presentation/worksheet_screen.dart`, `lib/features/browser/presentation/browser_screen.dart` keep their own `Scaffold`/`AppBar`, become width-aware (drawer/hamburger suppressed when the rail is shown), and adopt `TwoPaneLayout` for their wide form.
- **Browse detail:** `lib/features/browser/presentation/unit_entry_detail_screen.dart` is split so its body renders both embedded (wide) and pushed (compact); selection state added to `BrowserNotifier`/`BrowserState`.
- **No dependency or data-model changes;** persistence and the evaluation/worksheet engines are untouched.
