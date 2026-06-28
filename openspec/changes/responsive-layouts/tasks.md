## 1. WindowSizeClass primitive

- [ ] 1.1 Write tests for `WindowSizeClass` covering the breakpoint boundaries (`<600` compact; `600` and `1040` medium; `>1040` expanded) and recompute-on-resize
- [ ] 1.2 Implement `WindowSizeClass` enum + a `WindowSizeClass.of(BuildContext)` helper deriving the tier from `MediaQuery.sizeOf`, with the two breakpoints as named constants
- [ ] 1.3 Run `flutter test --reporter failures-only` and `flutter analyze`; confirm green

## 2. App shell + destination model (navigation refactor)

- [ ] 2.1 Write widget tests for the shell: drawer + hamburger at compact/medium, persistent rail (no hamburger) at expanded, active-destination highlight in both surfaces, and page-state preservation across rail navigation and across the rail breakpoint
- [ ] 2.2 Define `AppDestination` (icon, label, `buildTitle`, `buildActions`, `buildBody`, all tier-aware) and the three destinations (Freeform, Worksheet, Browse)
- [ ] 2.3 Convert `HomeScreen` into `AppShell`: single `Scaffold` that builds the AppBar from the active destination, hosts bodies in an `IndexedStack`, and switches drawer ↔ `NavigationRail` by `WindowSizeClass`; add Settings/About to the rail trailing slot
- [ ] 2.4 Remove the per-page `Scaffold`/`AppBar`/`Drawer` from Freeform, Worksheet, and Browse; each page now exposes its AppBar title/actions and body via its destination (pages still single-pane in this step)
- [ ] 2.5 Update existing navigation/drawer tests and `app_drawer.dart` usage to the new shell; confirm `page-state-preservation` scenarios still pass
- [ ] 2.6 Run `flutter test --reporter failures-only` and `flutter analyze`; confirm green

## 3. TwoPaneLayout primitive

- [ ] 3.1 Write tests for `TwoPaneLayout`: both panes + divider at medium/expanded, single designated pane at compact, independent scrolling, and each `PaneSize` mode (fixed width; fit-content with min/max clamping; two fill panes splitting by ratio)
- [ ] 3.2 Implement `PaneSize` (`fixed`/`fitContent`/`fill`) and `TwoPaneLayout({left, right, leftSize, rightSize, compactPrimary})` reading `WindowSizeClass`; map modes to `SizedBox`/`ConstrainedBox`/`Expanded` (no drag handle)
- [ ] 3.3 Run `flutter test --reporter failures-only` and `flutter analyze`; confirm green

## 4. Freeform two-pane (history pane)

- [ ] 4.1 Write tests: history shown in a right pane at medium/expanded, AppBar history button hidden at wide widths and shown/enabled-disabled at compact, tapping a pane entry restores both fields and evaluates, same entries/order as the modal
- [ ] 4.2 Adopt `TwoPaneLayout` in the Freeform body: left = input/result column, right = history list; keep the AppBar history button + modal at compact only
- [ ] 4.3 Run `flutter test --reporter failures-only` and `flutter analyze`; confirm green

## 5. Worksheet two-pane (template list)

- [ ] 5.1 Write tests: AppBar dropdown at compact (alphabetical, switches worksheet); left-pane template list at medium/expanded with active highlight and static AppBar title; selecting in the list switches the right pane
- [ ] 5.2 Adopt `TwoPaneLayout` in the Worksheet body: left = template list (drives the active template already in `WorksheetNotifier`), right = active worksheet rows; AppBar shows the dropdown at compact and a static title at wide widths
- [ ] 5.3 Run `flutter test --reporter failures-only` and `flutter analyze`; confirm green

## 6. Browse two-pane (selection lift + embedded detail)

- [ ] 6.1 Write tests: selection lifted to `BrowserState` (primary + alias resolve to same selection), compact push vs wide embedded detail, selecting another entry updates the pane in place, empty "select a unit" placeholder before/after first selection
- [ ] 6.2 Add `selectedPrimaryId`/`selectedKind` (or `BrowseEntry?`) to `BrowserState`/`BrowserNotifier`; row taps set selection
- [ ] 6.3 Extract a Scaffold-less `UnitEntryDetailBody` from `UnitEntryDetailScreen`; the pushed screen (compact) and the embedded pane (wide) both render it
- [ ] 6.4 Adopt `TwoPaneLayout` in the Browse body: left = catalog list, right = detail body or empty placeholder; compact taps push the detail route reading the lifted selection
- [ ] 6.5 Run `flutter test --reporter failures-only` and `flutter analyze`; confirm green

## 7. Documentation & wrap-up

- [ ] 7.1 Update `doc/implementation_plan.md` and `doc/design_progress.md` to mark the responsive-layouts work and record the shell/destination + two-pane architecture
- [ ] 7.2 Final full run: `flutter test --reporter failures-only` and `flutter analyze` clean
