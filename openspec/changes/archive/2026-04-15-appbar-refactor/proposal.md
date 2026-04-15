## Why

`HomeScreen` centralises the `AppBar` for all three top-level pages (Freeform, Worksheet, Browse), but each page has grown its own set of AppBar controls — a conformable-units button, a worksheet template dropdown, and four browser action buttons.  Keeping them in the parent requires workarounds: a Riverpod trigger provider (`conformableBrowseRequestProvider`) to bridge `HomeScreen` → `FreeformScreen`, four `Consumer` wrappers in `HomeScreen` to read browser state without rebuilding the whole screen, and `HomeScreen` watching `worksheetProvider` solely for the AppBar title.  A second problem has also emerged: navigating away from a page and back discards local widget state (text fields, scroll position), because the `switch` in `HomeScreen`'s body removes the inactive page from the tree.

## What Changes

- **New**: `unitRepositoryProvider` — a singleton `Provider<UnitRepository>` in `lib/core/domain/models/`; both `parserProvider` and `BrowserNotifier` read from it instead of each creating their own `UnitRepository.withPredefinedUnits()` instance
- **New**: `TopLevelPage` enum in `lib/shared/top_level_page.dart` (renamed from the private `_TopLevelPage` in `HomeScreen`)
- **New**: `AppDrawer` widget in `lib/shared/widgets/app_drawer.dart` — accepts `currentPage` and `onNavigate` callback; encapsulates drawer chrome, Settings push, About push
- **Move**: `HomeScreen` → `lib/shared/home_screen.dart`; body switches from a `switch` expression to an `IndexedStack`, preserving page state across navigation; `HomeScreen` owns no AppBar of its own
- `FreeformScreen` becomes a `Scaffold` with its own `AppBar`; the conformable-units button is wired directly to `_showConformableModal` without a trigger provider
- `WorksheetScreen` becomes a `Scaffold` with its own `AppBar`; the `WorksheetDropdown` title lives inside the screen
- `BrowserScreen` becomes a `Scaffold` with its own `AppBar`; the four action buttons are `ref.watch`/`ref.read` calls inside the screen rather than `Consumer` wrappers in `HomeScreen`
- **Delete**: `conformableBrowseRequestProvider`, `ConformableBrowseNotifier`; `conformableBrowseEnabled` moves to `freeform_state.dart`
- Page-local widget state (text fields in Freeform and Worksheet, search field in Browse) is preserved across navigation via `IndexedStack`

## Capabilities

### New Capabilities

- `page-state-preservation`: Top-level page state (text field contents, active rows) survives navigation to another page and back within a session

### Modified Capabilities

<!-- None: the user-visible behaviour of the conformable-units button, worksheet dropdown,
     and browser actions is unchanged; only their implementation location changes -->

## Impact

- `lib/shared/` — two new files (`top_level_page.dart`, `widgets/app_drawer.dart`); `home_screen.dart` moved here
- `lib/core/domain/models/unit_repository_provider.dart` — new file
- `lib/features/freeform/presentation/freeform_screen.dart` — gains `Scaffold`/`AppBar`; loses `listenManual` subscription
- `lib/features/freeform/presentation/home_screen.dart` — deleted (moved to `lib/shared/`)
- `lib/features/freeform/state/conformable_browse_provider.dart` — deleted
- `lib/features/freeform/state/parser_provider.dart` — reads `unitRepositoryProvider`
- `lib/features/worksheet/presentation/worksheet_screen.dart` — gains `Scaffold`/`AppBar`
- `lib/features/browser/presentation/browser_screen.dart` — gains `Scaffold`/`AppBar`; removes `Consumer` wrappers
- `lib/features/browser/state/browser_provider.dart` — reads `unitRepositoryProvider`; `createData()` override pattern removed
- Tests: conformable-browse button tests move to `freeform_screen_test.dart`; browser AppBar tests move to `browser_screen_test.dart`; new `app_drawer_test.dart`
