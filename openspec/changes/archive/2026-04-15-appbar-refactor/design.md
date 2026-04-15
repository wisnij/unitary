## Context

`HomeScreen` owns a single `Scaffold` whose `AppBar` is conditionally composed based on the active page.  After Phase 7 (Browse mode), the AppBar has three distinct configurations: a conformable-units button (Freeform), a worksheet template dropdown title (Worksheet), and four action buttons reading browser provider state (Browse).  Two structural workarounds exist because the AppBar owner (`HomeScreen`) and the action responders (`FreeformScreen`, `BrowserScreen`) are different widgets:

1. `conformableBrowseRequestProvider` — a `NotifierProvider<int>` used as a trigger signal; `HomeScreen` increments it on button press; `FreeformScreen` subscribes via `ref.listenManual` in `initState` and calls `_showConformableModal` in response.
2. Four `Consumer` wrappers in `HomeScreen`'s `actions` list — needed to avoid rebuilding all of `HomeScreen` when `browserProvider` state changes, since `HomeScreen` does not otherwise watch `browserProvider`.

A third problem: the `switch` expression in `HomeScreen`'s body renders exactly one page at a time.  Navigating away destroys the outgoing page's widget state (`TextEditingController` contents, `_controllers` map in `WorksheetScreen`, search controller in `BrowserScreen`).

A separate but related issue: `parserProvider` and `BrowserNotifier` each create their own `UnitRepository.withPredefinedUnits()` instance.  Both load the full 7 000+ unit database.  The `BrowserNotifier.build()` comment explicitly notes that its initialization is deferred to first browser visit, but an `IndexedStack` (needed for state preservation) would move both initializations to app startup.  Sharing a single repository eliminates the duplicate load.

## Goals / Non-Goals

**Goals:**

- Each top-level page (`FreeformScreen`, `WorksheetScreen`, `BrowserScreen`) owns its own `Scaffold` + `AppBar` + `AppDrawer`
- `HomeScreen` becomes a thin `IndexedStack` coordinator with no AppBar of its own; all page-switching logic stays in `HomeScreen` as local widget state
- Page-local widget state (text fields, active worksheet row) survives navigation and returns intact
- A single `unitRepositoryProvider` is shared by `parserProvider` and `BrowserNotifier`; the unit database is loaded once at startup
- `conformableBrowseRequestProvider` and its `listenManual` subscription are deleted; the browse button calls `_showConformableModal` directly
- `TopLevelPage` enum and `AppDrawer` widget live in `lib/shared/`; `HomeScreen` moves to `lib/shared/`

**Non-Goals:**

- Cross-session persistence of text field contents (that is Phase 7 work with sqflite)
- Changing any user-visible behaviour of the conformable-units button, worksheet dropdown, or browser actions
- Navigator-based routing (GoRouter, named routes)
- Any changes to `require-unit-repo` (a separate pending change)

## Decisions

### 1. Per-page Scaffold ownership

Each of `FreeformScreen`, `WorksheetScreen`, and `BrowserScreen` becomes a `ConsumerStatefulWidget` that returns a `Scaffold` as its root.  The `Scaffold` includes the page's `AppBar` and an `AppDrawer` instance.

**Rationale:** Eliminates both workarounds in one move.  `FreeformScreen` directly wires its button's `onPressed` to `_showConformableModal`; `BrowserScreen` reads `browserProvider` in its own `build` method with no `Consumer` wrappers.  `WorksheetScreen` watches `worksheetProvider` only in the one widget that needs it.

**Alternative considered:** Keep a single `Scaffold` in `HomeScreen` but have pages provide their `AppBar` via a callback or a Riverpod provider.  Rejected: Flutter's `AppBar` is not a `Widget` type that can be cleanly threaded through a provider; it is a `PreferredSizeWidget` that belongs to the `Scaffold` that renders it.  Any solution would require either global state (a provider holding an `AppBar`) or `GlobalKey`-based state access — both harder to test and reason about than widget ownership.

### 2. `IndexedStack` for page state preservation

`HomeScreen`'s body is an `IndexedStack` over the three page widgets.  `_currentPage` (a `TopLevelPage` enum value in `_HomeScreenState`) maps to the stack index.

**Rationale:** `IndexedStack` keeps all children in the widget tree simultaneously, so `State` objects are never destroyed during navigation.  Text controllers retain their content.  This is the standard Flutter idiom for tab-like navigation with preserved state.

**Alternative considered:** Lift text field contents into Riverpod providers (e.g., a `freeformInputProvider` storing the two controller strings).  Rejected: ephemeral UI state (what the user is currently typing) is more naturally represented in widget state than in the provider layer.  Providers in this project hold domain state, not text field contents.

**Alternative considered:** `AutomaticKeepAliveClientMixin` with a `PageView`.  Rejected: `PageView` adds swipe-to-navigate gesture semantics that are not desired; `IndexedStack` is simpler and has no unintended UX side effects.

### 3. Callback (not provider) for page navigation

`HomeScreen` holds `_currentPage` as `StatefulWidget` local state and passes an `onNavigate(_TopLevelPage)` callback to `AppDrawer`.  `AppDrawer` calls `onNavigate` when a drawer item is tapped; `HomeScreen`'s `setState` updates the index.

**Rationale:** Navigation is local UI state shared only between `HomeScreen` and `AppDrawer`.  A Riverpod provider would be appropriate if unrelated widgets needed to trigger navigation (e.g., a "go to freeform" button on a detail screen), but no such requirement exists.  The callback pattern matches the established `WorksheetDropdown(selectedId:, onChanged:)` precedent in this codebase.

**Alternative considered:** `StateProvider<TopLevelPage>` (or `NotifierProvider<PageNotifier, TopLevelPage>`).  Rejected for three reasons: (1) no existing `StateProvider` in the codebase — inconsistent; (2) Riverpod providers here hold domain/feature state, not routing state; (3) it opens a second navigation path in tests (direct provider override vs. simulating user drawer taps), which creates test discipline issues.

### 4. Shared `unitRepositoryProvider`

A new `Provider<UnitRepository>` in `lib/core/domain/models/unit_repository_provider.dart` calls `UnitRepository.withPredefinedUnits()` once.  Both `parserProvider` and `BrowserNotifier` read from it via `ref.read(unitRepositoryProvider)`.

```
unitRepositoryProvider  →  parserProvider (ExpressionParser)
                        →  BrowserNotifier.build() (catalog + indices)
```

**Rationale:** Without sharing, `IndexedStack` would call `UnitRepository.withPredefinedUnits()` twice at startup (once per provider).  Each load registers 7 000+ units; doing it twice doubles startup memory and CPU cost.  Sharing eliminates the duplicate.

**Side effect:** `BrowserNotifier`'s `createData()` override pattern (used in tests to inject a small repository) is replaced by overriding `unitRepositoryProvider` directly — cleaner, more standard Riverpod test practice.

### 5. `conformableBrowseEnabled` relocation

The `conformableBrowseEnabled(EvaluationResult)` helper function moves from `conformable_browse_provider.dart` into `freeform_state.dart` as a top-level function.  It is a predicate on `EvaluationResult` subtypes, which is exactly what `freeform_state.dart` defines.

**Rationale:** With the provider deleted, the file has no remaining reason to exist.  The function logically belongs alongside the types it discriminates.

### 6. File locations for shared types

`TopLevelPage` (public enum, renamed from `_TopLevelPage`) and `AppDrawer` live in `lib/shared/`.  `HomeScreen` moves from `lib/features/freeform/presentation/` to `lib/shared/`.

**Rationale:** After the refactor, `HomeScreen` is not freeform-specific; it is an app-level coordinator.  `AppDrawer` is used by all three page Scaffolds.  `lib/shared/` already contains cross-cutting widgets (`fast_scroll_bar.dart`) and is the conventional home for such artifacts in this project.

## Risks / Trade-offs

- **Startup cost increases slightly**: `unitRepositoryProvider` (one `withPredefinedUnits()` call) and `BrowserNotifier.build()` (catalog + index construction) both run at app startup rather than on first Browse visit.  `BrowserNotifier`'s existing comment ("no app-startup cost") becomes incorrect and should be updated.  The total cost is one repository load + one catalog build — the same work that was previously deferred.  On a mid-range Android device this is expected to be under 200 ms; if profiling shows otherwise, the fix is to move `BrowserNotifier.build()` to a background isolate (a separate future change).
  → Mitigation: update the comment; measure on device before release.

- **`IndexedStack` initialises all three screens at startup**: All three `ConsumerStatefulWidget.initState` methods run immediately.  After the refactor, `FreeformScreen.initState` no longer sets up a `listenManual` subscription, so it is trivial.  `WorksheetScreen` and `BrowserScreen` have no `initState` logic.
  → No mitigation needed.

- **Test file reorganisation**: Tests for the conformable-units button (currently in `home_screen_test.dart`) must move to `freeform_screen_test.dart`.  Browser AppBar button tests move to `browser_screen_test.dart`.  Drawer navigation tests move to a new `app_drawer_test.dart`.  This is mechanical work with no risk of behaviour change.
  → Mitigation: run full test suite after each move before proceeding.

## Open Questions

None — all decisions resolved during design exploration.
