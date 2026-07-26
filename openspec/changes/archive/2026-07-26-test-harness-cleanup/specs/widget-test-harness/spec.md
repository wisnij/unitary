## ADDED Requirements

### Requirement: Default must-override repository bundle

`test/helpers/repository_overrides.dart` SHALL provide a `TestRepositories`
class whose async factory constructs one mocked `SharedPreferences` instance
and, from it, one default in-memory instance of each repository backing a
must-override provider (`SettingsRepository`, `WorksheetRepository`,
`FreeformHistoryRepository`, `CurrencyRateRepository`), exposed as fields,
plus a computed `overrides` property containing the corresponding
`Override` for each provider (`settingsRepositoryProvider`,
`worksheetRepositoryProvider`, `freeformHistoryRepositoryProvider`,
`currencyRateRepositoryProvider`).

#### Scenario: Default construction

- **WHEN** `TestRepositories.create()` is awaited
- **THEN** the returned instance exposes non-null `settings`, `worksheet`,
  `freeformHistory`, and `currencyRate` repositories, all backed by the same
  mocked `SharedPreferences` instance, and an `overrides` list containing
  exactly one `Override` per must-override provider

#### Scenario: Seeded initial preferences

- **WHEN** `TestRepositories.create(initialPrefs: {'precision': 8})` is
  awaited
- **THEN** the returned `settings` repository loads a `UserSettings` with
  `precision` 8, reflecting the seeded `SharedPreferences` value

### Requirement: Widget-pumping convenience

`test/helpers/pump_app.dart` SHALL provide an async `pumpApp(WidgetTester
tester, Widget child, {TestRepositories? repos, List<Override> overrides})`
function that pumps `child` wrapped in `ProviderScope(overrides: merged,
child: MaterialApp(home: child))`, where `merged` combines a `TestRepositories`
(constructed via `TestRepositories.create()` when `repos` is not supplied)
with the caller-supplied `overrides`.

#### Scenario: Zero-argument call supplies working defaults

- **WHEN** `await pumpApp(tester, const SomeScreen())` is called for a screen
  that reads one or more must-override providers, with no prior
  `SharedPreferences` mocking or repository construction in the test
- **THEN** the widget builds without throwing `UnimplementedError` and
  renders using default in-memory repository state

#### Scenario: Caller overrides take precedence over defaults

- **WHEN** `pumpApp` is called with `overrides` containing an override for a
  provider that also has a default (e.g. a custom
  `settingsRepositoryProvider.overrideWithValue(customRepo)`)
- **THEN** the widget tree uses the caller-supplied override, not the
  default, for that provider

#### Scenario: Pre-seeded repository is visible after pumping

- **WHEN** a `TestRepositories` is constructed, one of its repositories is
  seeded via its own `save(...)` method, and then `pumpApp(tester, child,
  repos: repos)` is called
- **THEN** the pumped widget tree observes the seeded data through the
  corresponding provider

### Requirement: No hand-rolled must-override boilerplate in migrated tests

Test files that exercise a widget or provider depending on one or more
must-override providers SHALL obtain default repository instances via
`TestRepositories` (directly, or through `pumpApp`) rather than duplicating
the `SharedPreferences.setMockInitialValues` + repository-construction +
override-list sequence inline.

#### Scenario: Widget test uses the shared helper

- **WHEN** a widget test needs `settingsRepositoryProvider` and
  `worksheetRepositoryProvider` overridden with default in-memory
  repositories
- **THEN** the test obtains them via `TestRepositories`/`pumpApp` rather than
  constructing `SettingsRepository`/`WorksheetRepository` and an override
  list inline

#### Scenario: Provider-container test uses the shared helper

- **WHEN** a test constructs a bare `ProviderContainer` needing one or more
  must-override providers overridden with default repositories
- **THEN** the test builds the container's `overrides` from a
  `TestRepositories.overrides` list rather than constructing the
  repositories and override list inline
