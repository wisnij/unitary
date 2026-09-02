Unitary - Implementation Plan
=============================

This document outlines the phased approach to implementing Unitary, along with future enhancements, risk mitigation strategies, and success criteria.

---


Implementation Phases
---------------------

### Phase 0: Project Setup (Week 1) — COMPLETE

**Goals:** Development environment and project scaffolding

**Tasks:**

- [x] Install Flutter SDK (3.38.9) and Dart SDK (3.10.8)
- [x] Create new Flutter project (`flutter create`, org `dev.wisnij`, version 0.1.0+1)
- [x] Set up version control (Git/GitHub)
- [x] Configure project structure (layered architecture: core/domain, core/data, features, shared)
- [x] Set up linting and code formatting (`flutter_lints` + project-specific rules in `analysis_options.yaml`)
- [x] Create README with project overview
- [x] Minimal app scaffolding with Material 3 and light/dark theme support
- [x] Matching test/ directory structure

**Deliverable:** Empty Flutter app that builds, passes `dart analyze` with no issues, and passes `flutter test`

**Completed:** January 31, 2026

---

### Phase 1: Core Domain - Expression Parser (Weeks 2-4) — COMPLETE

**Goals:** Build the expression parsing and evaluation engine

**Tasks:**

- [x] Implement Lexer
  - [x] Token types definition
  - [x] Character-by-character scanning
  - [x] Number parsing (decimals, scientific notation, leading decimal point)
  - [x] Operator recognition
  - [x] Unit name recognition (as identifiers)
  - [x] Test with various inputs

- [x] Implement Parser
  - [x] AST node classes
  - [x] Recursive descent parser
  - [x] Operator precedence handling (6 levels including implicit multiplication)
  - [x] Error recovery and reporting
  - [x] Unit tests for parsing

- [x] Implement basic Evaluator
  - [x] Number arithmetic
  - [x] Basic operators (+, -, *, /, ^, |)
  - [x] Reciprocal syntax (/x = 1/x)
  - [x] Built-in functions (sin, cos, tan, asin, acos, atan, sqrt, cbrt, ln, log, exp, abs)
  - [x] Unit tests for evaluation

- [x] Supporting infrastructure
  - [x] Exception hierarchy (UnitaryException, LexException, ParseException, EvalException, DimensionException)
  - [x] Rational class with continued fractions for exponent recovery
  - [x] Dimension class with arithmetic and conformability checking
  - [x] Quantity class with dimensional analysis

**Deliverable:** Parser that converts "5 * 3 + 2" → correct result ✓

**Test Coverage:** 372 tests passing

**Completed:** February 4, 2026

---

### Phase 2: Unit System Foundation (Weeks 5-7) — COMPLETE

**Goals:** Build the unit definition system and integrate it with the evaluator

**Tasks:**

- [x] Implement Unit class and UnitDefinition hierarchy
  - [x] Unit class with id, aliases, description, definition
  - [x] UnitDefinition base class with toQuantity contract
  - [x] PrimitiveUnitDefinition (identity conversion, self-referencing dimension)
  - [x] LinearDefinition (factor-based conversion with recursive resolution)
  - [x] Unit tests for all definition types

- [x] Implement UnitRepository
  - [x] Registration with alias mapping and collision detection
  - [x] Lookup by name/alias with plural stripping fallback
  - [x] Factory constructor with built-in units
  - [x] Unit tests for registration, lookup, and plural stripping

- [x] Implement built-in unit definitions
  - [x] Length units (10): m, km, cm, mm, um, in, ft, yd, mi, nmi
  - [x] Mass units (6): kg, g, mg, lb, oz, t
  - [x] Time units (6): s, ms, min, hr, day, week
  - [x] Unit tests for conversion factors, aliases, and dimensions

- [x] Implement reduce() utility
  - [x] reduce(): resolve non-primitive dimensions to primitives
  - [x] Unit tests for reduction and edge cases

- [x] Integrate with evaluator
  - [x] Add nullable repo field to EvalContext (backward compatible)
  - [x] UnitNode resolves to base units when repo is present
  - [x] Fallback to raw dimension for null repo or unknown units
  - [x] Unit tests for unit-aware evaluation
  - [x] Verify all Phase 1 tests still pass

- [x] Integrate with ExpressionParser
  - [x] Add optional repo parameter to ExpressionParser
  - [x] Wire repo through to EvalContext
  - [x] Deliverable test: parse "5 ft" → evaluate → convert
  - [x] End-to-end unit tests

- [x] Update documentation

**Deliverable:** Can convert "5 feet" to meters programmatically ✓

**Test Coverage:** 506 tests passing

**Completed:** February 7, 2026

**Detailed Plan:** See [Phase 2 Plan](archive/phase2_plan.md)

---

### Phase 3: Advanced Unit Features (Weeks 8-9) — COMPLETE

**Goals:** Complex conversions and functions

**Tasks:**

- [x] Implement ConstantDefinition for physical constants
- [x] Implement CompoundDefinition for derived units
- [x] Add all 7 SI base unit primitives (m, kg, s, K, A, mol, cd)
- [x] Add temperature units (degK/tempK, degC/tempC, degF/tempF, degR/tempR)
- [x] Add physical constants (pi, euler, tau, c, gravity, h, N_A, k_B, e, R)
- [x] Add derived units (N, Pa, J, W, Hz, C, V, ohm, F, Wb, T, H)
- [x] Add dimensionless primitive units (radian, steradian)
- [x] Implement SI prefix support (24 prefixes from quecto to quetta)
- [x] Implement PrefixUnit subclass and prefix-aware unit lookup
- [x] Comprehensive testing

**Deliverables:**

- `tempF(212)` evaluates to 373.15 K ✓
- `5 N + 3 kg*m/s^2` evaluates to 8 kg*m/s^2 ✓
- `3e4 kilometers/week` evaluates to ~49.6 m/s ✓

**Test Coverage:** 703 tests passing

**Completed:** February 15, 2026

---

### Phase 4: Basic UI - Freeform Mode (Weeks 10-12) — COMPLETE

**Goals:** First working UI for expression evaluation

**Tasks:**

1. Create app structure
   - [x] Main navigation (drawer-based)
   - [x] Freeform input screen
   - [x] Material Design theme
   - [x] Dark mode support (three-state: system/dark/light)

2. Build freeform input UI
   - [x] Input text field (expression)
   - [x] Output text field (optional, for conversion target)
   - [x] Result display widget (idle/success/conversion/error states)
   - [x] Real-time evaluation with 500ms debounce (configurable)

3. Integrate parser with UI
   - [x] Riverpod state management
   - [x] Connect input to ExpressionParser
   - [x] Two-expression conversion support
   - [x] Quantity formatting (decimal/scientific/engineering notation)
   - [x] Handle errors gracefully

4. Settings screen
   - [x] Precision selector (2-10, default 6)
   - [x] Notation selector (decimal/scientific/engineering)
   - [x] Dark mode toggle
   - [x] Evaluation mode (real-time / on-submit)

5. Persistence
   - [x] SharedPreferences for user settings

**Deliverable:** Working app that evaluates expressions in freeform mode ✓

**Test Coverage:** 845 tests passing

**Completed:** February 16, 2026

**Detailed Plan:** See [Phase 4 Plan](archive/phase4_plan.md)

---

### Phase 5: Complete Unit Database (Weeks 13-14) — COMPLETE

**Goals:** Import all unit categories

**Tasks:**

- [x] Create GNU Units import pipeline
  - [x] `tool/import_gnu_units_lib.dart` — two-pass parser with conditional directive evaluation
  - [x] `tool/import_gnu_units.dart` — executable that reads definitions.units, merges into units.json
  - [x] `tool/generate_predefined_units_lib.dart` — alias resolution, Dart codegen per unit type
  - [x] `tool/generate_predefined_units.dart` — executable that reads units.json, writes predefined_units.dart
- [x] Create `lib/core/domain/data/units.json` (full merged GNU Units database: 7294 units, 125 prefixes, 177 unsupported)
- [x] Add Phase 5 units: digital storage (6), volume (8), area (2), speed (1), pressure (4), energy (5)
- [x] Regenerate `lib/core/domain/data/predefined_units.dart` from units.json
- [x] Test coverage for all new categories
- [x] Tool tests: 164 tests for importer, codegen, and release libraries

**Deliverable:** All required unit categories available ✓

**Test Coverage:** 844 tests passing

**Completed:** February 23, 2026

---

### Phase 6: Worksheet Mode (Weeks 15-17) — COMPLETE

**Goals:** Multi-unit worksheet interface

**Tasks:**

1. Implement Worksheet domain model
   - [x] `WorksheetRowKind` sealed class: `UnitRow` (ratio-based) and `FunctionRow` (function forward/inverse)
   - [x] `WorksheetRow` and `WorksheetTemplate` data models
   - [x] Row expressions support compound units (`m/s`, `km/hr`, `ft^2`)

2. Create worksheet UI components
   - [x] Multi-row input grid with label, expression, and numeric value fields
   - [x] Real-time cross-row updates (synchronous per-keystroke recompute; no debounce)
   - [x] Per-row error display on dimension mismatch

3. Build worksheet management
   - [x] 11 predefined templates: Length (9), Mass (6), Time (6), Temperature (4), Volume (9), Area (8), Speed (5), Pressure (6), Energy (7), Digital Storage (6), Angle (8)
   - [x] AppBar `DropdownButton` for template switching, sorted alphabetically
   - [x] More specific error messages in worksheets

4. Implement state management
   - [x] `WorksheetNotifier` (non-`autoDispose`) with per-template in-session value maps
   - [x] "Last keystroke wins" source semantics; focus alone does not transfer source
   - [x] Reactive updates across all rows when source value changes
   - [x] Clears all rows on invalid source input

5. Conversion engine
   - [x] `computeWorksheet()` in `worksheet_engine.dart`
   - [x] Ratio-based conversion for `UnitRow`s
   - [x] `func.call()`/`callInverse()` for `FunctionRow`s (e.g., temperature)
   - [x] Per-row error strings on dimension mismatch

**Deliverable:** Worksheet mode functional with pre-defined worksheets ✓

**Test Coverage:** 1309 tests passing (163 new)

**Completed:** March 27, 2026

**Design Artifacts:** `openspec/changes/worksheet-mode/`

---

### Phase 7: Persistence (Weeks 18-19) — COMPLETE

**Goals:** Save user data and preferences

**Tasks:**

1. ~~Set up local database (sqflite)~~ → **Deferred to Phase 12** — SharedPreferences
   is sufficient for current data; sqflite reserved for custom worksheets
2. ~~Implement PreferencesRepository~~ → **Already done in Phase 4** (settings persist
   via `SettingsRepository` + SharedPreferences)
3. [x] Implement `WorksheetRepository` — persists active template ID and per-template
   source `(rowIndex, text)` as a single JSON key in SharedPreferences
4. Add persistence for:
   - [x] User preferences — done (Phase 4)
   - [x] Worksheet last values — active template + per-template source row restored on launch
   - [x] Freeform input fields — "Convert from" / "Convert to" text restored on launch
   - ~~Favorite units~~ → deferred to Phase 12
5. [x] Restore state on app launch — `WorksheetNotifier.build()` re-runs engine per
   persisted source; `FreeformScreen.initState()` restores controller text and
   defers re-evaluation to post-frame callback
6. [x] Test save/load cycle — repository tests + notifier/screen persistence tests

**Deliverable:** App remembers settings, worksheet values, and freeform inputs between sessions ✓

**Test Coverage:** 1593 tests passing (157 new)

**Completed:** April 24, 2026

**Design Artifacts:** `openspec/changes/user-data-persistence/`

---

### Phase 8: Currency Support (Weeks 20-21) — COMPLETE

**Goals:** Currency conversion with live rates

**Tasks:**

1. [x] Choose and integrate currency rate API — Frankfurter v2
   (`https://api.frankfurter.dev/v2/rates?base=USD`), no API key
2. [x] Implement CurrencyService — `CurrencyRateRepository` + dynamic-unit layer in
   `UnitRepository` (`registerDynamic`/`unregisterDynamic`); `buildCurrencyDescriptors()`
   detects currency units, including precious metals (XAU/XAG/XPT)
3. [x] Add currency rate storage — `CurrencyRates` in SharedPreferences (`currencyRates`
   key); per-currency `{rate, date}` + top-level `updatedAt`
4. [x] Ship default rates in assets — built-in rates compiled into the unit database
   (`units.json` → `predefined_units.dart`); dynamic layer shadows them at runtime; UI
   shows "Using built-in rates" until a live rate is fetched
5. [x] Auto-update logic (24hr check) — `maybeRefresh()` fired fire-and-forget from
   `UnitaryApp.initState()` post-frame callback; 24-hour staleness threshold
6. [x] Manual refresh UI — reusable `CurrencyRefreshButton` with 60-second cooldown,
   shared by Settings and the Currency worksheet AppBar
7. [x] Display last update timestamp — Settings "Currency rates" section, worksheet
   banner, and unit browser detail page (`formatDateTime`/`formatShortDate`)
8. [x] Handle offline gracefully — stored/built-in rates load synchronously before first
   frame; refresh failures surface via `_RefreshErrorDialog`; conversions work offline

**Deliverable:** Currency conversions work with auto-updating rates ✓

**Test Coverage:** 1838 tests passing

**Completed:** June 15, 2026

**Design Artifacts:** `openspec/changes/currency-support/` (plus follow-ups:
`fix-currency-worksheet/`, `show-refresh-times/`, `currency-worksheet-banner/`)

---

### Phase 9: Polish & Testing (Weeks 22-24) — COMPLETE

**Goals:** Production-ready quality

**Tasks:**

1. Branding
   - [x] Application icon — custom launcher/favicon icon applied to Android, iOS,
     and web from `assets/icon/unitary.svg` (moved here from Phase 10)

2. UI/UX refinement
   - [x] Responsive layouts — three responsive tiers driven by a single
     `WindowSizeClass` (compact `<600` drawer + single pane; medium `600–1040`
     drawer + two panes; expanded `>1040` persistent navigation rail + two
     panes). `AppShell` (formerly `HomeScreen`) owns the drawer↔rail decision
     and wraps the existing pages; a shared `TwoPaneLayout` with per-pane
     `PaneSize` (fixed / fit-content / fill) provides the split. Per page:
     Freeform shows input history in a right pane; Worksheet shows a left-pane
     template list (dropdown at compact); Browse shows the unit detail in an
     embedded right pane (selection lifted into `BrowserState`; pushed route at
     compact). See `openspec/changes/responsive-layouts/`.
     - Deferred follow-up: lift Freeform's field/eval state out of widget
       `State` into a notifier so AppBar construction can also be centralized in
       the shell (Freeform is the only page still coupled to widget state).
     - Discovered: the Worksheet AppBar template dropdown can overflow at very
       narrow widths (~≤410 dp) because of the long "Digital Storage" label in
       `titleLarge` — pre-existing, not addressed here.
   - [x] Tablet support
     - [x] Persistent navigation rail at expanded width (replaces the drawer)
     - [x] Landscape handling across all screens
       - Display safe areas — every top-level screen body (plus the pushed
         detail/license sub-screens) and the navigation rail inset their content
         within the device-reported safe area (`MediaQuery.padding` via
         `SafeArea`), so display cutouts and system bars no longer obscure
         fields, list rows, or section headers in any orientation.  Insets are
         read dynamically from the platform (no hard-coded values); Android
         already reports cutout insets, so no manifest change was needed.
         Verified on-device with a left-edge camera cutout in landscape.  See
         `openspec/changes/archive/2026-07-01-safe-area/`.
       - Short-height landscape (phone + keyboard) accepted as a device
         limitation, not planned: Freeform stays rotatable (consistent with the
         other screens, and still useful in landscape for keyboard-free history
         and result interaction), but active text entry in the sliver above the
         keyboard is inherently cramped and won't be specially compacted or
         locked to portrait.
     - [x] Verify touch targets and spacing at tablet sizes
       - Touch targets — verified on-device (phone + tablet); the operator keys,
         though narrower than 48 dp at phone width, are comfortable to tap, so no
         change was made.  (The 48 dp concern is shared with the Accessibility
         item below.)
       - Spacing — single-column content on Freeform, Worksheet, and Settings was
         over-wide on landscape tablets.  A shared `ReadableWidth` wrapper
         (`Align(topCenter)` + `ConstrainedBox`, `kReadableMaxWidth = 600`) now
         caps and centers that content on wide layouts while staying inert at
         phone width.  Verified on-device.  See
         `openspec/changes/archive/2026-07-03-tablet-spacing/`.
   - [x] Accessibility improvements
     - [x] Semantic labels on the operator key panel and completion overlay
       — every operator key exposes an accessible action label (a glyph→word
       map: `*`→"multiply", `|`→"numeric divide", `~`→"inverse", …) via
       `Semantics` + `ExcludeSemantics`; every completion suggestion exposes a
       `"<name>, <kind>"` label (unit/prefix/function) so the kind shown only
       by the trailing `-`/`(` is available to a screen reader.  Labels are
       inert without assistive tech and cause no visual change.  Coverage tests
       guard against new keys/kinds shipping unlabelled (iterate
       `freeformKeyPanelSymbols` / `CompletionEntryKind.values`, plus an
       exhaustive `switch`).  See
       `openspec/changes/archive/2026-07-03-semantic-labels/`.
     - [x] Screen-reader announcement of evaluation results and per-row worksheet errors
       — the freeform result display is an unconditional polite live region
       (WCAG 4.1.3): every settled evaluation state is announced from a
       speech-friendly label built by `formatSpeech` (`=`→"equals", `/`→"per",
       `^`→"to the power", `×`/`*`→"times", `|`→"over",
       `1.5e+3`→"1.5 times 10 to the 3")
       with an "Error: " prefix on errors; an exhaustive `switch` over the
       sealed `EvaluationResult` keeps new variants from shipping without a
       spoken form.  Worksheet cell errors keep the red in-field message and
       gain a freeform-style `error_outline` prefix icon with an "Error"
       semantic label (non-color indicator fixing WCAG 1.4.1); the erroring
       field's semantics node is marked `SemanticsValidationResult.invalid`,
       so screen readers get native invalid-field state with field heights
       unchanged.  The idle-example hint
       exposes `button` semantics, and every long-press-to-copy gesture
       (worksheet cells, About rows, unit detail) exposes a labeled
       `CustomSemanticsAction` discoverable in TalkBack's actions menu /
       VoiceOver's rotor.  Per-row worksheet error *announcements* deferred to
       Phase 12 (predefined templates can't produce row-level dimension
       mismatches); on-device TalkBack pass completed July 7, 2026.  See
       `openspec/changes/archive/2026-07-07-screen-reader/`.
     - [x] Contrast audit — computed WCAG 2.x ratios for every custom-composed
       color pairing in both `fromSeed(Colors.blue)` schemes.  The suspected
       candidates (muted currency banner, `onSurfaceVariant` text) all pass
       (≥7.2:1); every real failure was a custom alpha blend.  Fixed: the
       worksheet source-row indicator (fill was 1.06:1 and the only cue; now a
       2 dp `primary` border ≥6.1:1, width difference as the non-color cue,
       tint retained as supplement), fast-scroll preview neighbour labels
       (`onPrimary` alpha 0.65→0.85, now ≥4.8:1), and the fast-scroll thumb
       (`primary` alpha 0.6→0.8, now ≥3.9:1; grip lines switched to
       `onPrimary`@0.9).  Accepted as decorative (WCAG 1.4.11 exempt):
       `outlineVariant` borders on the completion overlay and unit-detail
       tables, and the banner / browse sticky-header background tints.  All
       pairings and exemptions are pinned by
       `test/shared/color_contrast_test.dart`, which recomputes ratios from
       the real color schemes and fails on regression.  See
       `openspec/changes/archive/2026-07-08-contrast-audit/`.
     - [x] Minimum 48dp touch targets throughout
   - [x] Resolve outstanding UX open questions (see design_progress.md):
     - [x] Long-expression handling in the input fields (scroll/wrap) — #2 →
       resolved as soft-wrap: the freeform fields wrap and grow vertically
       without bound, Enter still submits (never inserts a newline), and the
       completion overlay tracks the field's grown edges.  See
       `openspec/changes/long-expressions/`.
     - [x] Worksheet field reordering — #3 → deferred to Phase 12 (worksheet
       customization); reordering only makes sense once worksheets are
       user-editable
     - [x] Undo/redo — #4 → won't do for now; freeform history covers
       recalling past inputs, and no need has come up in practice
     - [x] Searchable/filterable freeform history — #5 → deferred as a
       nice-to-have future enhancement (see Phase 14); the 100-entry cap
       keeps the plain list manageable
     - [x] Landscape orientation support — #7 → resolved yes; shipped via the
       responsive-layouts, safe-area, and tablet-spacing work above
     - [x] First-run onboarding / tutorial — #8 → deferred as a nice-to-have
       future enhancement (see Phase 14); the idle-state tappable example
       already provides lightweight onboarding

3. Performance optimization — **COMPLETE (as measurement; see [performance.md](performance.md))**
   Closed measurement-first: checked-in tools (`tool/benchmark.dart` with
   `--baseline` diffing, `tool/memory_report.dart`, a companion
   `computeWorksheet` benchmark under `flutter test`), rebuild-scope widget
   tests (`RebuildCounter` probe), and documented on-device procedures.  No
   optimization crossed the action thresholds (interaction >100 ms; memory
   >~50 MB); results and decisions recorded in `doc/performance.md`.
   - [x] Parser/evaluator tuning
     - [x] Pre-warm the resolution cache — **rejected**: cold resolution of all
       ~6200 units totals ~11 ms, so pre-warming buys nothing (see "Unit
       Resolution Caching" below)
     - [x] Benchmark cold-start evaluation vs. warmed-cache evaluation —
       `resolve-all-cold` ~11 ms vs. `resolve-all-warm` ~133 µs (~80×)
   - [x] UI rendering optimization
     - [x] Profile the completion overlay — suggestion computation ~0.5 ms per
       keystroke; the dominant cost is the whole `FreeformScreen` rebuilding
       twice per keystroke (13–16 ms frames, over budget on 120 Hz devices) →
       follow-up: lift freeform field/eval state into a notifier (the refactor
       already deferred from responsive-layouts, now evidence-backed)
     - [x] Profile worksheet cross-row recompute — ~150–190 µs per full
       recompute, one screen rebuild per edit (the path is synchronous; the
       "500 ms debounce" in the Phase 6 notes is stale for worksheets); fine
       as is
     - [x] Profile the eager Browse catalog build — ~12 ms on a cold repo;
       fine as is.  Discovered instead: the fast-scroll thumb drag overruns
       the 8.3 ms/120 Hz frame budget frequently (`FastScrollBar` + peek panel
       rebuild every drag frame) → follow-up candidate (see "Performance
       Follow-ups" under Future Enhancement Phases)
   - [x] Memory usage analysis — core domain totals ~10.6 MB (repository
     1.9 MB + resolution cache 8.6 MB + catalog ~0 + descriptors 0.1 MB);
     non-problem, threshold set at ~50 MB
   - [x] Startup time — first frame ~650 ms cold clean install / ~380 ms warm
     relaunch with the full stored-rate path (profile mode, real device);
     stored-rate cost bounded well under 100 ms → keep rates on the pre-frame
     path

4. Comprehensive testing
   - [x] Integration tests — `integration_test/` added (code review finding
     F9): `boot_test.dart` (the real `main()` entry point, including
     pre-first-frame currency-rate rehydration), `restart_test.dart`
     (worksheet/settings/history persistence across a simulated restart,
     against the real `SharedPreferences` plugin), `currency_refresh_test.dart`
     (manual refresh flow against a mocked HTTP client, never the real
     Frankfurter API) — all 8 scenarios pass repeatedly against a real
     local Android emulator. A web/Chrome path was tried first and
     abandoned as an unresolved upstream Flutter/DWDS bug (not fixable in
     this project); Android needed none of that path's machinery
     (`flutter drive`, chromedriver) and was already fully set up on the
     dev machine used. Along the way, found and fixed a real production
     bug (`FastScrollBar` crash on a degenerate zero-height layout pass,
     confirmed unreachable via real single-launch usage). **Enabled and
     confirmed passing in CI**, observed passing on a real GitHub Actions
     run (PR #1); the opt-in `ENABLE_ANDROID_INTEGRATION_TESTS` toggle was
     later removed entirely once proven — the step now runs
     unconditionally for every workflow that uses
     `./.github/actions/test`, so `release.yml` (which never set the
     toggle) picked up coverage it had silently been missing.
     Two CI-only issues surfaced only by watching real runs, both fixed:
     `reactivecircus/android-emulator-runner` splits a multi-line
     `script:` into separate `sh -c` invocations per line (fixed by moving
     the test loop into `tool/run_integration_tests.sh`), and the emulator
     itself is prone to intermittent boot/render hangs on GitHub-hosted
     runners (bounded with a `timeout`-and-retry-only-on-timeout wrapper in
     that same script, verified in both directions — a deliberately-broken
     test failed the workflow without being retried). iOS-emulator coverage
     remains deferred (not needed for this scope — see
     `openspec/changes/archive/2026-08-02-integration-tests/design.md`). See
     [Design Progress](design_progress.md) for the full account.
   - [x] Widget tests — audit coverage gaps — closed September 1, 2026 as
     **satisfied by the CI coverage gate** rather than by a separate audit.
     The task was written when coverage was merely measured; the August 13
     threshold work changed the premise.  Its scope is all of `lib/` — UI
     included — at a 90% floor against ~95.9% actual, and the measurement
     taken then showed the concern behind this task (a suite "largely
     unit-level", so UI thinly covered) is not borne out: non-core code is
     covered slightly *better* than core, 96.23% vs 95.16%.  A manual audit
     would re-derive what the gate now enforces continuously.  What the gate
     cannot catch is a single weak file hiding behind an aggregate, and one
     is known: `worksheet_engine.dart` at 87.30%, the least-covered logic
     file in the project — recorded in Phase 12 rather than fixed here, since
     a per-file floor would also fail legitimately thin data classes
     (`completion_entry.dart` 8.33%, `token.dart` 33.33%).
   - [x] Manual testing on real devices — closed September 1, 2026 as
     **done in practice, checklist deliberately not written.**  Real-device
     passes drove much of this phase and are individually recorded above:
     safe-area verification against a left-edge camera cutout in landscape;
     touch-target and tablet-spacing verification on both phone and tablet;
     a full TalkBack pass (July 7) that found the `RenderTable` semantics
     focus-rect bug; on-device profile-mode performance passes (startup
     trace, per-keystroke frame timing before and after the rebuild-scoping
     fix, fast-scroll drag); and the Android auto-capitalization bug (August
     3), found only by using the app on a real device.  The `integration_test`
     suite runs on a real Android emulator in CI on every workflow.  A
     written checklist was judged to add process rather than coverage for a
     single-maintainer project — revisit if contributors join, or ahead of a
     Play Store submission where a repeatable pre-submit pass earns its keep.
   - [x] Verify >80% coverage target for parser/core domain (MVP success
     criterion) — done August 13, 2026 (code review F11): coverage is now
     *enforced* in CI, not merely measured.  `tool/check_coverage.dart` (+
     `_lib` + 27 tests) parses `coverage/lcov.info` and fails the build below a
     minimum, wired into `.github/actions/test/action.yml` after the report
     upload (so a failure still leaves a downloadable artifact) and before the
     emulator steps (so it fails fast).  Scope is **all of `lib/`** at a **90%**
     minimum, not just `lib/core/` at 80%: measurement showed non-core code is
     covered slightly *better* than core (96.23% vs 95.16%), so the usual
     rationale for narrowing — dilution by UI code — does not hold here, and
     narrowing would only shrink what the gate protects (notably
     `worksheet_engine.dart`, pure conversion logic living under `features/`).
     The generated `predefined_units.dart` is excluded: at 7233 lines it is
     larger than all hand-written `lib/` code combined and 100% covered as a
     side effect of registration, so including it reports 98.66% and would mask
     almost any regression.  Baseline at introduction: **~95.9%** (3332/3474 on
     the measured run; the suite's line coverage drifts by about a line between
     runs, so the figure is approximate by nature).
     Files legitimately absent from the report are pinned by a bidirectionally
     checked allowlist (see `design_progress.md` for why absence is ambiguous).

5. [x] Bug fixes — reactive bucket, closed September 1, 2026: it was
   populated and drained continuously through the phase rather than at the
   end.  Real defects found and fixed here — each by the activity meant to
   surface it — were the `FastScrollBar` zero-height clamp crash
   (`ArgumentError` on a degenerate layout pass, found by the integration
   suite), Android IME auto-capitalization breaking case-sensitive unit
   lookup (found on-device), the `RenderTable` semantics focus-rect offset
   (found by the TalkBack pass), the stale-rate currency worksheet, and the
   contrast failures fixed by the audit.  No open bug is known at phase
   close; new ones go to Phase 10 or the post-MVP phases.

6. Documentation
   - [x] Code documentation — dartdoc pass on public APIs of the core domain
     and feature providers — done September 1, 2026, scoped deliberately to
     the *narrative* gap rather than to lint compliance.  Measurement first:
     temporarily enabling `public_member_api_docs` flags 224 members across
     `lib/`, but 167 of those (86 constructors + 81 fields) are leaf members
     of classes that already carry a class-level doc, and the five enums it
     appeared to flag turned out to be documented — the hits were their
     *values*, reported at the single-line enum's own line/column.  An
     independent scan for type declarations lacking a preceding `///` found
     exactly two in all of `lib/`: `UnitaryApp` (`app.dart`) and
     `CurrencyStatusNotifier` (`currency_provider.dart`); both now documented
     (theme wiring and post-frame refresh hook; the deliberate
     `maybeRefresh`/`refresh` split and the `unitRepositoryVersionProvider`
     bump).  `TokenType`'s 13 values had real explanatory content in trailing
     `//` comments, invisible to IDE hover and dartdoc — converted to `///`
     and expanded where the source disagreed with the comment (the `times`
     Unicode variants, `per` as a `divide` spelling, and `divideNum`'s
     highest-precedence/numeric-literals-only rule, each verified against
     `lexer.dart`/`parser.dart` and then empirically: `2|3 m` → 0.667 m,
     `2|3 m|s` → `ParseException`).  **Not done, by decision:** documenting
     the 167 constructors/fields, which would add boilerplate under docs that
     already explain them; enabling `public_member_api_docs` (Unitary is an
     application, not a published package, so there is no external consumer
     of its API surface); and publishing generated dartdoc — `doc/api/` is a
     gitignored February 2026 byproduct covering only Phase 1 libraries, left
     as-is.  A nested `lib/core/analysis_options.yaml` was verified to scope
     the lint to exactly the core domain (70 hits, nothing outside `lib/core`
     flagged) should that tradeoff ever be revisited.
   - [x] Audit the design documents under `doc/` and decide which to keep,
     update, or archive — done August 5, 2026 (code review F13): completed
     phase plans (`phase1_plan`, `phase2_plan`, `phase4_plan`,
     `quantity_implementation_plan`) moved to `doc/archive/`;
     `architecture.md` rewritten against the shipped code (real dependency
     list, shipped subsystem descriptions, actual source tree, duplicated
     stale phase list removed); `best_practices.md` updated to match actual
     practice (Riverpod 3 patterns, shared test harness, real branch
     strategy); `evaluation_pipeline.md` verified accurate and kept
   - [x] Rewrite the README to reflect the shipped app — done August 5, 2026
     (code review F12, expanded scope): full user-first rewrite — install
     options (release APK, hosted web app, source), feature tour with
     engine-verified example conversions, development/build/test
     instructions, curated doc links, brief status section; design-phase
     framing and duplicated roadmap dropped; intro paragraphs and License
     section preserved verbatim
   - [x] Contributing guidelines — `CONTRIBUTING.md` added August 5, 2026
     (code review F15): bug-report guidance, dev setup incl. pre-commit
     hooks, change workflow (tests first, full suite + analyze), PR
     guidelines, license terms; distilled from `best_practices.md`

**Deliverable:** MVP ready for release ✓

**Test Coverage:** 2088 tests passing; ~95.9% line coverage over `lib/`,
enforced in CI at a 90% floor

**Started:** June 18, 2026 (application icon)

**Completed:** September 1, 2026

**Closing note:** the phase ends with no known open bugs and every task
either done or explicitly closed with reasoning above.  Two items were
closed as satisfied-in-substance rather than performed — the widget-test
audit (subsumed by the CI coverage gate) and the device-testing checklist
(testing done, checklist not written).  Carried into Phase 10 as genuine
release blockers, neither of which is Phase 9 work: the Android release
build is still signed with the **debug** key
(`android/app/build.gradle.kts` — the `flutter create` TODO), which would
prevent in-place upgrades for anyone who installs the first published APK,
and there is no **privacy policy**, which Phase 10 already lists and which
the Play Store requires as a hosted URL.  Also outstanding but deferred by
decision: the deferred code-review findings (F2, F3, F4, F5, F7, F16 — all
architecture debt or latent-only), of which only **F8** (worksheet AppBar
dropdown overflow at ≲410 dp) is user-visible and worth a decision before
release.

---

### Phase 10: Release (Week 25) — IN PROGRESS

**Goals:** Cut a properly signed 1.0.0, publish it on GitHub, and submit it
to the Play Store

**Context at phase start (September 1, 2026):** this phase was written before
implementation and assumed nothing was published yet.  In fact most of it
already shipped incrementally — the repository has been public since early
on, and the tag-driven release pipeline has published 38 releases (v0.5.2
onward, against 47 tags going back to v0.1.0), with v0.9.7 in flight at the
time of writing.  What genuinely remains is release *engineering* that the
0.9.x stream never needed because it was pre-1.0 — a real signing key, a
meaningful version code, and a privacy policy — plus the Play Store
submission, which is an **active goal for this phase**, not the optional
extra the original list treated it as.  The task list below is re-derived
from the actual state rather than kept as originally written.

The "Week 25" estimate no longer reflects the scope.  Play Store onboarding
is gated by Google's timelines rather than by work on this end — identity
verification, and possibly a mandatory closed-testing period measured in
weeks — so the phase should be planned around that rather than around the
engineering tasks, which are small by comparison.

**Tasks:**

1. GitHub distribution — **already done**, verified September 1, 2026
   - [x] Set up GitHub repository — public at `github.com/wisnij/unitary`,
     description and homepage set, AGPL-3.0 detected by GitHub
   - [x] Add license — `LICENSE.md` (AGPL v3); the app also satisfies AGPL
     §13's network-use obligation in-app, since the About screen offers both
     "License terms" (full text via `LicenseScreen`) and "Project home"
     (source URL) — this matters because the web build is hosted, and §13
     obliges offering source to users who interact with it over a network
   - [x] Polish README — rewritten August 5, 2026 (F12) with eight
     device-captured screenshots added August 7
   - [x] Publish to GitHub — fully automated and proven: pushing a `vX.Y.Z`
     tag runs `prepare` → `build-android-apk` + `build-web` → `release`,
     which creates the GitHub release with the APK and web zip attached and
     the tag's annotation body as the release notes
   - [x] Web deployment — every push to `main` builds with `--wasm` and
     force-pushes to `gh-pages`; live at <https://wisnij.github.io/unitary/>
   - [x] Screenshots — eight captured via `tool/take_screenshots.sh`.  Note
     these are sized for the README; the Play Store needs its own set (see
     task 7)

2. Release signing — **BLOCKER for any published 1.0.0**
   - [ ] **Decide the two-channel signing strategy first** — this is the one
     decision in the phase that is effectively irreversible once anything is
     published, and shipping through both GitHub and Play makes it sharper
     than it would otherwise be.  Play App Signing has Google hold the app
     signing key while you upload with a separate upload key, and Play then
     re-signs; a GitHub APK signed with *your* key therefore carries a
     different signature from the Play build of the same version.  Android
     refuses to install an update whose signature differs, so the two
     channels become mutually exclusive for any given user: whichever one
     they install from first is the one they are stuck with, and switching
     means uninstalling and losing local data.  The usual way out is to
     enrol in Play App Signing by supplying the *existing* key rather than
     letting Google generate one, and to sign the GitHub APK with that same
     key, so both channels produce identical signatures.  Verify the current
     Play App Signing options before committing — this behaviour has changed
     before, and the choice cannot be revisited after the first upload
   - [ ] Generate a release keystore and store it somewhere durable, with a
     backup.  Losing it means no future update can ever install over an
     existing install, through either channel
   - [ ] Add keystore patterns to `.gitignore` **before** creating the key —
     `*.jks`, `*.keystore`, and `android/key.properties` are all currently
     unignored, so a stray `git add -A` would commit the signing key
   - [ ] Wire a real `signingConfig` into `android/app/build.gradle.kts`,
     replacing the `signingConfigs.getByName("debug")` line under
     `buildTypes.release` (the `flutter create` TODO immediately above it),
     reading credentials from an untracked `key.properties`
   - [ ] Supply the keystore to CI as encoded repository secrets so
     `build-android-apk` produces a properly signed artifact; keep the local
     path working for developer builds
   - [ ] Verify the output: `apksigner verify --print-certs` must no longer
     report `CN=Android Debug`
   - **Why this blocks:** verified against the current build config and the
     locally built release APK — the release build type is signed with the
     debug key, so `Signer #1 certificate DN: C=US, O=Android, CN=Android
     Debug`.  Anyone who installs a debug-signed 1.0.0 cannot later install a
     properly signed 1.0.1 over it (signature mismatch); they must uninstall
     first, losing settings, worksheet values, and history.  That makes this
     a fix-before-first-publish item, not a fix-later one.  The Play Store
     rejects debug-signed uploads outright

3. Version code — **RESOLVED** (September 2, 2026)
   - [x] Adopt a `version: X.Y.Z+N` scheme in `pubspec.yaml` and decide how
     `N` is derived (monotonic counter, or a CI-computed value) — derived from
     the semantic version as `MAJOR × 1000000 + MINOR × 1000 + PATCH`, so
     `1.2.3` → `1002003` and the current `0.9.7` → `9007`.  The version name
     stays the single source of truth: there is no second counter to bump or
     forget, and `tool/release_lib.dart` computes the code while
     `tool/release.dart` writes `X.Y.Z+CODE` into `pubspec.yaml` on every
     bump.  A hand-edited pubspec whose recorded code disagrees with its name
     aborts the release before anything is bumped, committed, or tagged.
     Rejected alternatives: a hand-maintained counter (forgettable), and
     git- or timestamp-derived values (not reproducible from a clean checkout
     of a tag).  Two ceilings throw at release time rather than surfacing at
     upload time — a minor or patch component of 1000 or more (unencodable in
     the three digits allocated it), and a code above Android's maximum of
     2100000000 (major above 2100)
   - [x] Confirm the built artifact reports the intended value — a local
     release APK reports `versionCode='9007' versionName='0.9.7'` via
     `aapt2 dump badging`, the same command that originally exposed the
     permanent 1
   - **Prior state:** `pubspec.yaml` carried a bare `version: 0.9.7` with
     no `+build` suffix, so every release build shipped with
     `versionCode='1'`.  Play requires each upload to strictly exceed the
     previous version code, so a permanent 1 cannot be uploaded twice;
     Android's own upgrade and downgrade-protection semantics also key off it
     for sideloaded APKs.  `versionName` was unaffected throughout — it
     tracked the pubspec version correctly.  The published releases keep their
     version code of 1 and are not retroactively fixed; since every new code
     exceeds 1, the transition needs no special handling.  See
     `openspec/changes/version-code/`

4. Privacy policy — **BLOCKER**
   - [ ] Write it.  The content is unusually simple and worth stating
     plainly: the app collects nothing, transmits no personal data, has no
     analytics, ads, or trackers, and stores everything locally via
     SharedPreferences.  Its only network request is an unauthenticated fetch
     of exchange rates from the Frankfurter API, which carries no user
     identifier; the declared permissions are `INTERNET` plus Flutter's own
     `DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION`
   - [ ] Host it at a stable URL — the existing `gh-pages` deployment is the
     natural home, and Play requires a URL rather than in-app text
   - [ ] Link it from the README and the in-app About screen

5. APK size — **deferred, decide before cutting 1.0.0**
   - [ ] Decide what the GitHub release APK should contain, and either bring it
     under the 50 MB MVP criterion or revise the criterion deliberately
   - **Finding (September 2, 2026):** the published APK is **53.8 MB**, and has
     been for every 0.9.x release (confirmed against the GitHub release assets,
     not a local build).  An earlier note in this plan put it at ~20 MB; that
     was measured from a stale single-ABI artifact left in `build/` and was
     wrong.  `flutter build apk` — which is exactly what CI runs — produces a
     fat APK carrying three ABIs:

     | slice | size |
     | --- | --- |
     | `arm64-v8a` | 17.7 MB |
     | `armeabi-v7a` | 15.6 MB |
     | `x86_64` | 19.1 MB |
     | everything else | 1.2 MB |

     Native libraries are 97.7% of the download.  They are stored uncompressed
     with `android:extractNativeLibs=false`, so they are mapped in place out of
     `base.apk` rather than unpacked — which means Android keeps the **entire**
     APK on disk and never discards the slices the device cannot use.  A typical
     arm64 phone therefore carries ~34.7 MB of dead weight, including an x86_64
     slice that only ever runs on emulators.  Play is unaffected: it serves
     splits from the AAB, so a Play install is roughly 19 MB.
   - **Options, cheapest first:** drop `x86_64` from the fat APK (one asset,
     ~35 MB, no effect on real phones — but the release APK would no longer run
     on an x86_64 emulator, which needs checking against the integration suite,
     though that builds debug); `--split-per-abi` (three assets at ~16–20 MB
     each, but users must know their architecture); or leave it and revise the
     criterion.
   - **Why it is its own change:** it is an independent question about what the
     release job builds, and folding it into release signing would muddy a
     change whose point is the signing key.  It touches the same
     `build-android-apk` job, so deciding it before that job is reworked twice
     is worth a little sequencing care.

6. Cut 1.0.0
   - [ ] Decide what 1.0.0 means here and whether any deferred item should
     land first — the open candidate is code-review **F8** (the worksheet
     AppBar dropdown overflows at ≲410 dp), the only user-visible item among
     the deferred findings; F2/F3/F4/F5/F7/F16 are architecture debt or
     latent-only and are fine to carry
   - [ ] Bump `pubspec.yaml` to 1.0.0 with its build number, update
     `CHANGELOG.md`, tag, and let the existing pipeline publish
   - [ ] Verify the published artifacts: signature, version code, and an
     install-over-previous test on a real device
   - [ ] Update the README's "Project status" section, which will no longer
     be describing a pre-release app

7. Play Store submission — the largest single group, and the long pole for
   the phase.  Start the account and testing-track steps **early**: they are
   gated by Google's timelines rather than by work on this end, so they can
   run in parallel with tasks 2–6 rather than waiting on them
   - [ ] Register a Google Play developer account (one-time fee) and complete
     identity verification.  **Verify current onboarding requirements before
     planning the timeline** — Google has previously required new personal
     developer accounts to run a closed test with a minimum number of testers
     for a minimum continuous period before production access is granted.  If
     that still applies it dominates the schedule and needs recruiting real
     testers, so establish it first rather than discovering it at submission
   - [ ] Build an AAB in CI — the release job currently runs `flutter build
     apk` only; Play needs `flutter build appbundle`.  Add it alongside the
     APK (which stays, for direct GitHub download) and attach it to the
     release, or upload it to Play directly from CI
   - [ ] Decide how uploads happen: manually through the Play Console at
     first, or automated from CI.  Manual is the right default for the first
     submission — the console surfaces policy warnings and pre-launch report
     findings that a scripted upload would hide.  Automating later is
     straightforward if the release cadence justifies it
   - [ ] Verify the AAB against the signing strategy chosen in task 2 —
     specifically that a Play-delivered build and a GitHub-downloaded APK of
     the same version carry the same signature, so users are not locked into
     whichever channel they installed from first
   - [ ] Store listing copy: short description ≤80 characters, full
     description ≤4000.  The README's feature tour is the obvious source, but
     Play descriptions are read cold by people who have never heard of the
     app, so lead with what it does rather than how it is built.  The "no
     ads, no tracking, no subscriptions, everything offline" angle is a
     genuine differentiator in this category and belongs near the top
   - [ ] Store listing graphics: app icon at 512×512 (derivable from
     `assets/icon/unitary.svg` via the existing `tool/generate_icons.sh`
     pipeline) and a feature graphic at 1024×500, which has no existing
     source and must be designed
   - [ ] Store listing screenshots — a separate set from the README's.  Play
     has its own count and aspect-ratio rules per form factor, and listing
     tablet screenshots is what makes the app eligible to be surfaced as
     tablet-capable.  The app genuinely earns that: the two-pane expanded
     layouts are worth showing.  `tool/take_screenshots.sh` already automates
     device capture and can be pointed at a tablet AVD, so extend it rather
     than capturing by hand
   - [ ] Complete the Data safety declaration — straightforward here: no data
     collected, none shared, none transmitted off-device except the
     unauthenticated exchange-rate fetch, which carries no user identifier.
     Keep it consistent with the privacy policy from task 4, since the two
     are cross-checked
   - [ ] Complete the content rating questionnaire (expected: rated for
     everyone) and the remaining declarations Play requires at submission —
     ads (none), target audience, and news/government/financial category
     questions
   - [ ] Confirm the target API level meets Play's current requirement.
     `targetSdk` is 36 and `minSdk` 24 as built, which is current today, but
     the requirement advances annually and is enforced on new uploads
   - [ ] Roll out through the testing tracks — internal, then closed if
     required by the account rules above, then production.  Read the
     pre-launch report at each stage: it runs the app on real devices and
     catches crashes, accessibility issues, and policy problems before users
     do
   - [ ] Accept the recurring obligations this channel brings, which the
     GitHub and web channels do not: annual target-API deadlines, periodic
     re-declaration of data safety and content rating, and policy compliance
     on an ongoing basis.  A published app that falls behind these is
     eventually removed from the store

8. Pre-release cleanup — small, opportunistic
   - [ ] Remove the stale `applicationId` TODO in
     `android/app/build.gradle.kts` — it advises specifying a unique
     application ID, which was already done (`dev.wisnij.unitary`); only the
     signing TODO beneath it is real
   - [ ] Decide on `doc/api/` — a gitignored February 2026 dartdoc byproduct
     covering only the Phase 1 libraries.  Either regenerate and publish it
     alongside the web app or delete it; leaving a stale copy on disk is the
     status quo and is also acceptable

**Deliverable:** Public MVP release — a signed, versioned 1.0.0 published on
GitHub and live on the Play Store, with the web app deployed and a privacy
policy hosted

**Non-goals:** iOS/App Store (Phase 13), and any feature work — Phase 9
closed with no known open bugs, and 1.0.0 should ship what is already tested

---


Future Enhancement Phases
-------------------------

### Phase 11: Custom Units

- UI for defining custom units
- Custom unit persistence
- Validation and testing

### Phase 12: Worksheet Customization

- Edit existing worksheets
- Create new worksheets
- Worksheet row reordering (open question #3, deferred from Phase 9)
- Worksheet sharing (export/import)
- Accessibility follow-ups deferred from the Phase 9 screen-reader change:
  - Screen-reader *announcement* of per-row worksheet errors (row errors become
    reachable once users can build mismatched rows; the error state itself is
    already exposed via `errorText` semantics)
  - A discoverable semantics action for the label-cell long-press gesture
    (transfer the active row's value into another row)

### Phase 13: iOS Support

- Test on iOS simulator
- iOS-specific UI adjustments
- Submit to App Store

### Phase 14: Advanced Features

- Equation solver
- Graphing
- Searchable/filterable freeform history (open question #5, deferred from
  Phase 9 as nice-to-have)
- First-run onboarding / tutorial screens (open question #8, deferred from
  Phase 9 as nice-to-have)
- ~~Additional functions~~ — substantially covered by the GNU Units import and
  defined-functions work (101 defined functions + 46 aliases); more can be added
  as needed
- ~~More mathematical constants~~ — covered by the full GNU Units database import
  (Phase 5)

### Phase 15: Rational Number Support

- Implement exact rational arithmetic
- Convert from decimal to rational where beneficial
- UI for displaying rational results

### Future: Performance Follow-ups (from the Phase 9 measurement, July 2026)

Candidates identified by `doc/performance.md`; none are urgent (nothing
crossed the action thresholds), roughly in value order:

- ~~**Freeform rebuild scope**~~ — **ADDRESSED (July 17, 2026)** by the
  `freeform-rebuild` change without the notifier refactor: the per-keystroke
  `setState` was replaced with controller `ListenableBuilder`s (clear/swap
  buttons) and the result/history watches moved into scoped `Consumer`s.
  Keystrokes now rebuild zero screen-subtree widgets (pinned by the tightened
  rebuild-scope tests) and normal typing runs under the 8.3 ms/120 Hz budget
  on-device.  The notifier/AppShell-AppBar refactor from responsive-layouts
  remains deferred as an architecture cleanup — it is no longer
  performance-motivated.
- **Fast-scroll thumb drag cost** — Browse's `FastScrollBar` + peek panel
  rebuild every frame during a thumb drag and frequently overrun the 120 Hz
  budget (unlike plain fling-scrolling).  Profile the UI vs. raster split,
  then consider RepaintBoundary isolation, transform-based repositioning, or
  cheaper peek-panel styling.  This change is also where an
  `integration_test` frame-timing harness (`traceAction`) would be built to
  verify the fix.
- **Decouple `UserSettings` from Flutter** — its `material.dart` import (for
  `ThemeMode`) drags Flutter into the pure-logic worksheet engine, which
  forces `computeWorksheet()`'s benchmark to run as a `flutter test`
  companion instead of inside `tool/benchmark.dart`.  Split the theme
  preference out (or narrow the engine's parameter) to make the engine pure
  Dart.

### Future: Unit Resolution Caching — COMPLETE (pre-warming rejected)

- [x] Cache the resulting base-unit Quantity the first time a unit is fully
  reduced during evaluation, so subsequent evaluations skip the resolution chain
  — `UnitRepository.resolveUnit()` caches into `_resolvedQuantityCache`; failed
  resolutions are intentionally not cached (the exception re-propagates)
- [x] Invalidate the cache whenever unit definitions are added or edited (expected
  to be infrequent, so the cache should remain valid for long periods) —
  `registerDynamic()` / `unregisterDynamic()` clear the cache (currently the
  currency dynamic-layer path; a general definition-edit feature does not exist
  yet but would hook in here)
- [x] Explore pre-warming the cache for all registered units as a background task
  at initial app startup and after definition edits, to minimize user-visible
  processing time — **rejected (July 2026)**: the Phase 9 performance
  measurement showed cold resolution of *all* ~6200 registered units totals
  ~11 ms (`tool/benchmark.dart` `resolve-all-cold`), so pre-warming would save
  a few milliseconds spread across first uses; not worth the complexity.  See
  [performance.md](performance.md).

---


Risk Mitigation
---------------

### Technical Risks

**Risk 1: Parser complexity too high**

- **Likelihood:** Medium
- **Impact:** High
- **Mitigation:** Start simple, iterate incrementally, reference existing parsers (GNU Units, other unit converters)
- **Contingency:** Fall back to simpler expression support initially, expand later

**Risk 2: Performance issues with real-time updates**

- **Likelihood:** Medium
- **Impact:** Medium
- **Mitigation:** Profile early, optimize hot paths, add debouncing if needed
- **Contingency:** Add toggle for real-time vs. on-demand evaluation

**Risk 3: GNU Units database parsing difficulties**

- **Likelihood:** Medium
- **Impact:** Medium
- **Mitigation:** Start with subset of units, manual conversion if needed, thorough testing
- **Contingency:** Manually curate unit definitions if automated parsing too difficult

**Risk 4: Floating-point precision issues**

- **Likelihood:** High
- **Impact:** Medium
- **Mitigation:** Use rational numbers where possible, document precision limitations
- **Contingency:** Add warnings for calculations that may lose precision

### Learning Curve Risks

**Risk 5: Flutter/Dart unfamiliarity**

- **Likelihood:** Medium
- **Impact:** Medium
- **Mitigation:** Official tutorials, small prototypes first, active community support
- **Contingency:** Allocate extra time for learning, consult documentation frequently

**Risk 6: Mobile development patterns**

- **Likelihood:** Medium
- **Impact:** Low
- **Mitigation:** Follow official guidelines, study example apps, use established patterns
- **Contingency:** Iterate on architecture as understanding improves

### Scope Creep Risks

**Risk 7: Feature bloat before MVP**

- **Likelihood:** Medium
- **Impact:** High
- **Mitigation:** Strict phase adherence, defer enhancements to post-MVP
- **Contingency:** Re-evaluate scope, cut non-essential features

**Risk 8: Perfectionism delays**

- **Likelihood:** Medium
- **Impact:** Medium
- **Mitigation:** "Good enough" for MVP, iterate post-release, set time limits
- **Contingency:** Timebox features, accept technical debt for MVP

---


Success Metrics
---------------

### MVP Success Criteria

The MVP will be considered successful when it meets these criteria:

**Functional Requirements:**

- ✓ Accurate conversions for all required unit categories
- ✓ Freeform mode handles complex expressions with proper dimensional analysis
- ✓ Worksheet mode supports at least 5 pre-defined worksheets per major dimension
- ✓ Dark mode works correctly and follows system preference
- ✓ Settings persist across sessions
- ✓ Currency rates update automatically (when online)
- ✓ All core features work offline

**Quality Requirements:**

- ✓ No critical bugs (crashes, data loss, incorrect conversions)
- ✓ Runs smoothly on mid-range Android devices (60 FPS UI)
- ✓ Parser handles malformed input gracefully with helpful error messages
- ✓ Unit test coverage >80% for parser and core domain logic
- ✗ App size <50MB — **not currently met**: the published APK is 53.8 MB
  because `flutter build apk` bundles three ABIs.  See Phase 10 task 5

**Documentation Requirements:**

- ✓ Published on GitHub with clear README
- ✓ Architecture documented
- ✓ Contributing guidelines available
- ✓ Code comments for complex logic

### Post-MVP Goals

**User Adoption:**

- 100+ GitHub stars within 6 months
- Active user feedback and feature requests
- Community contributions (bug reports, PRs)

**Feature Completeness:**

- User feedback incorporated
- Additional worksheet templates based on user requests
- Custom unit feature implemented
- iOS support added
- Play Store publication — now an active Phase 10 goal rather than a post-MVP option

**Code Quality:**

- Refactoring of technical debt from MVP
- Performance optimizations based on profiling
- Accessibility improvements
- Comprehensive test coverage (>90%)

---

*This plan is a living document and will be updated as the project progresses and priorities shift.*
