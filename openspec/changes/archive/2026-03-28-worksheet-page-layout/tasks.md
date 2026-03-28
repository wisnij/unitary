## 1. Restructure WorksheetScreen

- [x] 1.1 Remove the `Scaffold` wrapper from `WorksheetScreen.build()`, returning the `ListView` body directly (matching the pattern of `FreeformScreen`)
- [x] 1.2 Make `_WorksheetDropdown` public by renaming it to `WorksheetDropdown` and exporting it from the worksheet feature

## 2. Update HomeScreen

- [x] 2.1 Add a `_TopLevelPage` enum (`freeform`, `worksheet`) in `home_screen.dart`
- [x] 2.2 Convert `HomeScreen` from `StatelessWidget` to `StatefulWidget` and add `_currentPage` state
- [x] 2.3 Replace the drawer's `Navigator.push` for Worksheet with a `setState` call that sets `_currentPage = _TopLevelPage.worksheet`
- [x] 2.4 Replace the drawer's Freeform tile `Navigator.pop` with a `setState` call that sets `_currentPage = _TopLevelPage.freeform`
- [x] 2.5 Drive the drawer tile `selected:` property from `_currentPage` for both Freeform and Worksheet tiles
- [x] 2.6 Switch the `Scaffold` body between `FreeformScreen()` and `WorksheetScreen()` based on `_currentPage`
- [x] 2.7 Switch the `AppBar` title between `Text('Unitary')` and `WorksheetDropdown(...)` based on `_currentPage`, wiring `WorksheetDropdown` to the worksheet provider

## 3. Tests

- [x] 3.1 Add widget test: worksheet screen shows a hamburger icon (not a back-arrow) in the AppBar
- [x] 3.2 Add widget test: tapping hamburger icon on worksheet screen opens the drawer
- [x] 3.3 Add widget test: Worksheet drawer tile is highlighted when on the worksheet screen, Freeform tile is not
- [x] 3.4 Add widget test: Freeform drawer tile is highlighted when on the freeform screen, Worksheet tile is not
- [x] 3.5 Verify existing worksheet and freeform widget tests still pass (`flutter test --reporter failures-only`)
- [x] 3.6 Run `flutter analyze` and fix any linting errors
