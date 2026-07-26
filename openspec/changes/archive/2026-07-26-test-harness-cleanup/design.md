## Context

Four providers throw `UnimplementedError` unless overridden:
`settingsRepositoryProvider`, `worksheetRepositoryProvider`,
`freeformHistoryRepositoryProvider`, `currencyRateRepositoryProvider`. Each
wraps a repository with an identical `Repo(SharedPreferences)` constructor
shape. 21 test files currently repeat:

```dart
late SettingsRepository settingsRepo;
// ...other repo fields

setUp(() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  settingsRepo = SettingsRepository(prefs);
  // ...construct the other needed repos
});

Widget buildApp() => ProviderScope(
  overrides: [
    settingsRepositoryProvider.overrideWithValue(settingsRepo),
    // ...other overrides
  ],
  child: MaterialApp(home: /* ... */),
);
```

Two flavors of test currently duplicate this: widget tests (`ProviderScope`
+ `MaterialApp`, pumped via `tester.pumpWidget`) and provider/notifier tests
(bare `ProviderContainer`, no widget tree). A few files reassign a repo
variable mid-test (after re-mocking `SharedPreferences` with specific seed
values) to test restore-from-storage behavior
(`settings_screen_test.dart:143`), and a few pre-seed a repo by calling
`.save(...)` on it before pumping (`freeform_two_pane_test.dart:32`,
`worksheet_provider_test.dart`). Any replacement must support both.

## Goals / Non-Goals

**Goals:**

- One shared place that knows how to construct default in-memory instances
  of all four must-override repositories, usable from both `ProviderScope`
  (widget tests) and `ProviderContainer` (provider tests).
- A `pumpApp` convenience that removes the `ProviderScope` +
  `MaterialApp` + `pumpWidget` boilerplate for the common widget-test case.
- Callers can still: (a) override any individual provider with a custom
  instance or fake notifier, (b) get a handle to the constructed repository
  instances to pre-seed data before pumping, (c) seed specific
  `SharedPreferences` initial values instead of empty defaults.
- Migrate all 21 existing duplicating files so the codebase has one pattern,
  not two.

**Non-Goals:**

- Not touching `unitRepositoryProvider` — it has a real default
  (`UnitRepository.withPredefinedUnits()`), isn't must-override, and tests
  that need a lighter/synthetic repo already have `PassthroughUnitRepository`
  (`passthrough-unit-repo` spec) for that; out of scope here.
- Not changing any provider's production default-throw behavior.
- Not adding an `integration_test/` harness (that's finding F9, tracked
  separately per the code review's suggested sequencing).

## Decisions

**Bundle repositories in a `TestRepositories` class, not bare overrides.**
A factory `TestRepositories.create({Map<String, Object> initialPrefs})`
builds one mocked `SharedPreferences` instance and constructs all four
repositories from it, exposing them as fields (`settings`, `worksheet`,
`freeformHistory`, `currencyRate`) plus a computed `overrides` getter
(`List<Override>`). Callers that need to pre-seed a repo
(`repos.worksheet.save(...)`) or reconstruct one with specific stored values
get a real handle, not just an opaque override list.
- *Alternative considered*: a bare function returning `List<Override>`
  directly. Rejected — several existing tests need the repository instances
  themselves (to call `.save()` before pumping, or to swap one repo for a
  freshly-seeded instance mid-test), so a bundle that exposes both the
  instances and the derived overrides is strictly more capable at no extra
  cost to the common case.

**`pumpApp` merges caller overrides over defaults by provider identity, not
list order.** `pumpApp(tester, child, {TestRepositories? repos, List<Override>
overrides = const []})` builds/accepts a `TestRepositories`, then merges
`repos.overrides` and the caller's `overrides` into a `Map<ProviderBase,
Override>` keyed by `Override.origin` before passing the values to
`ProviderScope`. A caller-supplied override for a provider that also has a
default (e.g. a custom `settingsRepositoryProvider.overrideWithValue(...)`)
replaces the default deterministically.
- *Alternative considered*: just concatenate `[...repos.overrides,
  ...overrides]` and rely on Riverpod resolving the duplicate. Rejected —
  verified directly that Riverpod does not resolve a duplicate-provider
  override by list order at all: `ProviderContainer`/`ProviderScope` throw
  `AssertionError: Tried to override a provider twice within the same
  container` in `kDebugMode` the moment two overrides share an `origin`,
  regardless of which one is "supposed" to win. A flat concatenation would
  crash on construction for any test that both gets a provider's default
  from `repos.overrides` and separately overrides that same provider.
  Keying explicitly by `origin` and merging into a `Map` avoids ever
  constructing a duplicate-provider list in the first place.

**Split into two files: `repository_overrides.dart` (the `TestRepositories`
class, no Flutter widget dependency beyond `flutter_riverpod`'s `Override`
type) and `pump_app.dart` (the widget-pumping convenience, depends on
`flutter_test`/`flutter`).** Provider-level tests (`ProviderContainer`) import
only the first; widget tests import both.
- *Alternative considered*: one file. Rejected — provider tests would gain an
  unused `flutter_test`/widget-pumping import for no benefit, and the split
  mirrors the project's existing `test/helpers/` convention
  (`passthrough_unit_repository.dart` is similarly narrow).

**`TestRepositories.create` is `async`** (it awaits
`SharedPreferences.getInstance()`), matching every existing call site's
`setUp(() async { ... })` shape. `pumpApp` is also `async` (it already must
be, since it calls `tester.pumpWidget`), and defaults to constructing its own
`TestRepositories` via `create()` when the caller doesn't supply one — the
common case (most files don't need pre-seeded data) becomes a single
`await pumpApp(tester, const MyScreen());` call with no `setUp` at all.

**Migrate all 21 files in this change, not opportunistically.** The code
review's suggested fix allowed opportunistic migration, but leaving two
coexisting patterns (some files using the new helper, most still hand-rolling
the old one) doesn't pay down the debt the finding identifies — new
contributors would still see 21 examples of the old pattern to copy from.
Since each migration is mechanical (delete the `setUp`/`buildApp` boilerplate,
call `pumpApp`/`TestRepositories.create` instead) and behavior-preserving (no
assertions change), doing all of them in one change is the effort the code
review rated "M (mechanical)".

## Risks / Trade-offs

- **Risk**: mechanically migrating 21 files is a large, low-density diff that's
  tedious to review carefully.
  → **Mitigation**: no test assertions change, only setup code; `flutter test
  --reporter failures-only` after each file (or small batch) confirms
  identical pass/fail behavior before moving to the next, so a mistake is
  caught immediately rather than surfacing as a silent behavior change.
- **Risk**: a future fifth must-override provider still requires editing
  `TestRepositories` (one file) plus every call site that needs the new
  provider overridden with non-default data — the helper reduces duplication,
  it doesn't eliminate all future touch points.
  → **Mitigation**: accepted; the finding's stated problem is N-files-times-M-
  edits, and this reduces it to one shared default plus only the call sites
  that actually care about non-default behavior for the new provider (most
  won't).
- **Trade-off**: `TestRepositories.create()` always mocks
  `SharedPreferences` fresh and constructs all four repositories even when a
  test only needs one or two. This is a constant, cheap in-memory
  construction (no I/O), matching what most of the 21 files already do
  (several already construct all four regardless of use).

## Migration Plan

1. Add `test/helpers/repository_overrides.dart` (`TestRepositories`) with its
   own test.
2. Add `test/helpers/pump_app.dart` (`pumpApp`) with its own test.
3. Migrate the 21 files, one at a time, running
   `flutter test --reporter failures-only <file>` after each:
   `test/widget_test.dart`,
   `test/features/settings/presentation/settings_screen_test.dart`,
   `test/features/settings/state/settings_provider_test.dart`,
   `test/features/worksheet/state/worksheet_provider_test.dart`,
   `test/features/worksheet/presentation/worksheet_screen_test.dart`,
   `test/features/worksheet/presentation/worksheet_screen_banner_test.dart`,
   `test/features/worksheet/presentation/worksheet_two_pane_test.dart`,
   `test/features/worksheet/presentation/worksheet_rebuild_scope_test.dart`,
   `test/features/freeform/presentation/freeform_screen_test.dart`,
   `test/features/freeform/presentation/freeform_rebuild_scope_test.dart`,
   `test/features/freeform/presentation/freeform_two_pane_test.dart`,
   `test/features/freeform/presentation/home_screen_test.dart`,
   `test/features/freeform/state/freeform_provider_test.dart`,
   `test/features/freeform/freeform_integration_test.dart`,
   `test/features/browser/presentation/browser_screen_test.dart`,
   `test/features/browser/presentation/browser_two_pane_test.dart`,
   `test/features/browser/presentation/unit_entry_detail_screen_test.dart`,
   `test/features/about/presentation/about_screen_test.dart`,
   `test/shared/app_shell_test.dart`,
   `test/shared/safe_area_test.dart`,
   `test/shared/widgets/app_drawer_test.dart`.
4. Full `flutter test --reporter failures-only` and `flutter analyze` at the
   end to confirm no regressions and no unused-import lint issues left behind
   by removed boilerplate.

No production code changes, so no rollback concerns beyond reverting the
commit.

## Open Questions

None — the four repositories' constructor shapes and the call sites' needs
were confirmed by reading all 21 files before writing this design.
