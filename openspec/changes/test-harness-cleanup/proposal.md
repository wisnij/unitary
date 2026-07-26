## Why

Four repository providers (`settingsRepositoryProvider`, `worksheetRepositoryProvider`,
`freeformHistoryRepositoryProvider`, `currencyRateRepositoryProvider`) throw
`UnimplementedError` unless overridden, so every widget/provider test that
touches them must hand-roll the same `SharedPreferences.setMockInitialValues`
+ repository construction + override-list boilerplate. This pattern is
duplicated across 21 test files today (code review finding F10,
`doc/code_review_2026-07.md`) and has already grown four times as
must-override providers were added; Phase 11/12 will add more. Left
unconsolidated, every new must-override provider means editing dozens of
files, and the duplication itself makes each test file harder to scan for
what's actually being tested.

## What Changes

- Add a `test/helpers/repository_overrides.dart` helper that builds default
  in-memory instances of all four must-override repositories from a single
  mocked `SharedPreferences` instance and returns them as a Riverpod
  `List<Override>`, with per-test overrides layered on top.
- Add a `test/helpers/pump_app.dart` convenience,
  `pumpApp(WidgetTester tester, Widget child, {List<Override> overrides})`,
  that wraps `child` in `ProviderScope(overrides: defaults + overrides,
  child: MaterialApp(home: child))` and pumps it — for the widget-test half
  of the duplicated pattern.
- Migrate the 21 existing test files that hand-roll this pattern
  (widget tests using `ProviderScope` + `MaterialApp`, and provider tests
  using bare `ProviderContainer`) to use the new helpers, removing the
  duplicated setup from each.
- No behavior change to the app or to what any existing test verifies —
  this is test-infrastructure-only.

## Capabilities

### New Capabilities

- `widget-test-harness`: shared test helpers that supply default in-memory
  repositories for the must-override providers (`settings`, `worksheet`,
  `freeformHistory`, `currencyRate`) and a `pumpApp` convenience for widget
  tests, so new must-override providers or new tests don't require
  per-file boilerplate.

### Modified Capabilities

(none — no application-facing requirements change)

## Impact

- New files: `test/helpers/repository_overrides.dart`,
  `test/helpers/pump_app.dart`, plus tests for both.
- Modified files: the 21 test files currently duplicating this setup (see
  `design.md` for the full list), each losing its local
  `setUp`/override-list boilerplate in favor of the shared helper.
- No `lib/` changes — the must-override providers themselves are unchanged.
- No new package dependencies.
