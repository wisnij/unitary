## 1. Shared Infrastructure

- [x] 1.1 Create `lib/core/domain/models/unit_repository_provider.dart` with `unitRepositoryProvider` (`Provider<UnitRepository>` calling `UnitRepository.withPredefinedUnits()`)
- [x] 1.2 Update `lib/features/freeform/state/parser_provider.dart` to read `unitRepositoryProvider` instead of creating its own `UnitRepository`
- [x] 1.3 Update `lib/features/browser/state/browser_provider.dart`: remove the `createData()` override pattern; have `BrowserNotifier.build()` read `unitRepositoryProvider` via `ref.read`; update the startup-cost comment
- [x] 1.4 Add tests for `unitRepositoryProvider`: verify both `parserProvider` and `browserProvider` receive the same `UnitRepository` instance

## 2. Shared Navigation Widgets

- [x] 2.1 Create `lib/shared/top_level_page.dart` with public `TopLevelPage` enum (`freeform`, `worksheet`, `browser`)
- [x] 2.2 Create `lib/shared/widgets/app_drawer.dart` with `AppDrawer` widget: accepts `currentPage` (`TopLevelPage`) and `onNavigate` (`void Function(TopLevelPage)`) callback; renders drawer header, Freeform/Worksheet/Browse tiles with selected-state highlighting, divider, Settings tile (`Navigator.push`), About tile (`Navigator.push`)
- [x] 2.3 Add tests in `test/shared/widgets/app_drawer_test.dart`: drawer renders all tiles; correct tile is selected per page; tapping Freeform/Worksheet/Browse calls `onNavigate` with the right value; tapping Settings/About navigates to the correct screen

## 3. HomeScreen Refactor

- [x] 3.1 Move `lib/features/freeform/presentation/home_screen.dart` → `lib/shared/home_screen.dart`; update all imports
- [x] 3.2 Replace the `switch`-based body and single `Scaffold` with an `IndexedStack` over `[FreeformScreen(), WorksheetScreen(), BrowserScreen()]`; keep `_currentPage` as local `StatefulWidget` state; remove the `AppBar`, `Drawer`, all `ref.watch` calls, and the `_TopLevelPage` private enum
- [x] 3.3 Update `lib/main.dart` (or wherever `HomeScreen` is instantiated) to import from the new location
- [x] 3.4 Update `home_screen_test.dart` import path; verify existing navigation tests still pass

## 4. FreeformScreen Scaffold

- [x] 4.1 Move `conformableBrowseEnabled` from `conformable_browse_provider.dart` into `freeform_state.dart` as a top-level function; update imports in any remaining callers
- [x] 4.2 Add `Scaffold` + `AppBar` to `FreeformScreen.build()`: title `Text('Unitary')`, action `IconButton(Icons.balance)` with `onPressed` wired directly to `_showConformableModal` (enabled/disabled via `conformableBrowseEnabled(ref.watch(freeformProvider))`), drawer `AppDrawer(currentPage: TopLevelPage.freeform, onNavigate: ...)`
- [x] 4.3 Remove `_browseSubscription`, `ref.listenManual`, and all `conformableBrowseRequestProvider` references from `FreeformScreen`
- [x] 4.4 Delete `lib/features/freeform/state/conformable_browse_provider.dart`
- [x] 4.5 Move conformable-browse button tests from `home_screen_test.dart` → `freeform_screen_test.dart` (button present, enabled/disabled states per `EvaluationResult` subtype)

## 5. WorksheetScreen Scaffold

- [x] 5.1 Add `Scaffold` + `AppBar` to `WorksheetScreen.build()`: title `WorksheetDropdown(...)` reading from `worksheetState`, drawer `AppDrawer(currentPage: TopLevelPage.worksheet, onNavigate: ...)`
- [x] 5.2 Verify `home_screen_test.dart` worksheet AppBar tests (dropdown renders, selecting a template switches worksheet) pass after the move; migrate them to `worksheet_screen_test.dart` if they now test screen-level behaviour

## 6. BrowserScreen Scaffold

- [x] 6.1 Add `Scaffold` + `AppBar` to `BrowserScreen.build()`: title `Text('Browse')`, actions `[search toggle, expand all, collapse all, view-mode toggle]` as direct `ref.read`/`ref.watch` calls (no `Consumer` wrappers), drawer `AppDrawer(currentPage: TopLevelPage.browser, onNavigate: ...)`
- [x] 6.2 Move browser AppBar button tests from `home_screen_test.dart` → `browser_screen_test.dart` (Expand All present, Collapse All present, buttons enabled during search)

## 7. Verification

- [x] 7.1 Run `flutter test --reporter failures-only` and confirm all tests pass with no regressions
- [x] 7.2 Run `flutter analyze` and confirm no linting errors
- [x] 7.3 Manually verify page-state-preservation spec scenarios: Freeform text survives navigation to Worksheet and Browse and back; Worksheet row values survive navigation; Browse search state survives navigation
