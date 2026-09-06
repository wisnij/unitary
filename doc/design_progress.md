Unitary - Design Progress Tracker
=================================

This document tracks which aspects of the design have been completed and which still need work.


Already Discussed in Detail ✓
-----------------------------

The following areas have been thoroughly designed and documented:

### Requirements and Feature Set

- Complete requirements document with all feature specifications
- Target platforms (Android primary, iOS secondary via Flutter)
- User preferences and customization options
- Offline-first design with currency rate updates
- Complete list of unit categories to support

### Core Domain Models

- **Dimension**: Representation as map of primitive unit IDs to exponents
- **Unit**: Structure with id, aliases, description, and definition
- **Primitive Units**: Units that cannot be reduced further (dimensioned and dimensionless)
- **Derived Units**: Compound definitions
- **Prefixes**: SI and other prefixes with multiplication factors
- **DimensionRegistry**: Mapping dimensions to human-readable names for UI

### Expression Parser and Evaluator

- **Lexer**: Token types, number parsing (including leading decimals), implicit multiplication, prefix handling
- **Parser**: Operator precedence, AST construction, function call parsing
- **AST Nodes**: Number, Unit, BinaryOp, UnaryOp, Function nodes
- **Evaluator**: Dimensional analysis during evaluation
- **Functions**: Mathematical and trigonometric functions with proper dimension handling
- **Error Handling**: Separate error types with line/column tracking for debugging, user-friendly messages

### Quantity Class & Arithmetic

- **Number Representation**: Use `double` for MVP with rational recovery via continued fractions (maxDenominator = 100)
- **Arithmetic Operations**: Complete design for +, -, *, /, ^, abs, negate with dimensional analysis
- **Dimensional Exponentiation**: Validation that base dimensions are divisible by rational denominator
- **Unit Conversion**: Algorithm for converting between conformable units, handling chains and derived units
- **Unit Reduction**: Algorithm to express quantities in primitive units
- **Temperature Handling**: GNU Units approach with separate absolute (tempF/tempC) and difference (degF/degC) units
- **Function Syntax**: Parentheses required for functions except when standalone (definition lookup/conversion target)
- **Prefix Restrictions**: No prefixes allowed on functions
- **Error Handling**: Fail-fast approach - throw immediately on NaN-producing operations with clear messages
- **Edge Cases**: Division by zero, very large/small numbers, negative bases with fractional exponents, precision loss
- **Testing Strategy**: Comprehensive unit tests, integration tests, and property-based tests documented
- **Document**: [quantity_arithmetic_design.md](quantity_arithmetic_design.md)

### Terminology

- Comprehensive definitions of all key terms
- Consistent vocabulary established for codebase
- Clear distinctions between values, quantities, units, dimensions, etc.

### Phase 4: Basic UI - Freeform Mode

- **State management**: Riverpod with StateNotifierProvider for mutable state, Provider for singletons
- **Persistence**: SharedPreferences for user settings (precision, notation, dark mode, evaluation mode)
- **Navigation**: Drawer-based with Freeform (active), Worksheet (disabled), Settings
- **Two-field conversion**: Input expression + output expression field; result = converted value with output expression label
- **Evaluation modes**: Real-time (500ms debounce) and on-submit; user-configurable
- **Result formatting**: Value + canonical unit string; decimal/scientific/engineering notation
- **Dark mode**: Three-state (system/dark/light) mapping to Flutter ThemeMode
- **Settings model**: precision (2-10, default 6), notation, darkMode, evaluationMode
- **Document**: [phase4_plan.md](archive/phase4_plan.md)

### Phase 6: Worksheet Mode

- **Row model**: `WorksheetRowKind` sealed class with `UnitRow` (ratio-based) and `FunctionRow` (function forward/inverse) variants; rows store expression strings, supporting compound expressions (`m/s`, `km/hr`, `ft^2`)
- **Temperature**: `K` and `degR` are `UnitRow`s (absolute scales starting at 0); `tempC` and `tempF` are `FunctionRow`s (non-zero origin require functions)
- **Predefined templates**: 10 worksheets — Length, Mass, Time, Temperature, Volume, Area, Speed, Pressure, Energy, Digital Storage (binary IEC units)
- **Conversion engine**: `computeWorksheet()` in `worksheet_engine.dart`; handles both row kinds, per-row error strings on dimension mismatch, clears all on invalid input
- **State**: `WorksheetState` + non-`autoDispose` `WorksheetNotifier`; "last keystroke wins" source semantics; focus alone does not transfer source; per-template display value maps for in-session memory
- **Navigation**: AppBar `DropdownButton` listing all templates; sidebar pinning deferred to future phase
- **Persistence**: Cross-session via SharedPreferences (`WorksheetRepository`); `WorksheetNotifier` restores last-active template and per-template source values on launch
- **Design artifacts**: `openspec/changes/worksheet-mode/`

---


Areas That Need More Detail
---------------------------

Status of the areas originally flagged as needing deeper design work.  Most
are now implemented; each entry notes what (if anything) still needs design
for later phases:

### 1. Worksheet System — **COMPLETE (Phase 6)**

Core worksheet mode is implemented.  See Phase 6 design notes above.

**Still needs design for later phases**:

- Custom worksheet creation and editing (Phase 12)
- Sidebar pinning of worksheets (future)
- Unit list rows (`ft;in` multi-field display, future)

### 2. GNU Units Database Import — **COMPLETE (Phase 5 + Defined Functions)**

- **Import pipeline**: `tool/import_gnu_units.dart` (+ testable `_lib`) parses `assets/units/definitions.units` with a two-pass parser (conditional directive evaluation, alias detection via known-ID membership) and merges project-owned overrides from `assets/units/units-supplementary.json` into `assets/units/units.json` (7471 units, 125 prefixes, 88 dimension labels)
- **Codegen**: `tool/generate_predefined_units.dart` (+ `_lib`) emits `lib/core/domain/data/predefined_units.dart` — registration is plain generated Dart, so app startup involves no JSON parsing or asset I/O for units
- **Definition types**: primitive, derived, prefix, alias, and defined functions (GNU `name(x)` nonlinear definitions with domain/range and inverses; 101 functions + 46 aliases)
- **Import process**: development-time, not runtime; `import-gnu-units` and `generate-predefined-units` pre-commit hooks keep the generated files in sync with the sources
- **Incompatibilities**: tracked explicitly in the importer's "unsupported" output section — now empty (early Phase 5 had 177 unsupported entries; defined-function support and supplementary-file fixes cleared them)
- **Documentation**: architecture.md "Unit Database"; 164 tool tests under `test/tool/`

### 3. Currency Rate Management — **COMPLETE (Phase 8)**

- **API**: Frankfurter v2 (`https://api.frankfurter.dev/v2/rates?base=USD`); no API key; NDJSON list of `{date, base, quote, rate}` objects; rates inverted (`1.0 / frankfurterRate`); includes precious metals (XAU, XAG, XPT)
- **Dynamic unit layer**: `UnitRepository` has `_dynamicUnits`/`_dynamicLookup` maps that shadow the compiled static layer; `registerDynamic()` / `unregisterDynamic()` + cache invalidation
- **Currency detection**: `buildCurrencyDescriptors()` evaluates all `[A-Z]{3}` names, keeps those resolving to `{US$: 1}`; precious metals use hardcoded overrides that update intermediate price units (e.g. `goldprice` for `XAU`)
- **Storage**: `CurrencyRates` in SharedPreferences (`currencyRates` key); per-currency `{rate, date}` entries + top-level `updatedAt`; will migrate to sqflite in Phase 12
- **Startup**: stored rates loaded synchronously before first frame; `maybeRefresh()` fired fire-and-forget in `UnitaryApp.initState()` post-frame callback; 24-hour staleness threshold
- **Settings UI**: "Currency rates" section with last-updated timestamp or "Using built-in rates"; manual refresh button with 60-second cooldown; spinner while fetching
- **Design artifacts**: `openspec/changes/currency-support/`

### 4. User Preferences & State Management

**Current State**: All shipped user data persists through small repository classes over SharedPreferences (`SettingsRepository`, `WorksheetRepository`, `FreeformHistoryRepository`, `CurrencyRateRepository`), each behind a must-override Riverpod provider wired in `main.dart` (and supplied by the shared `test/helpers/` harness in tests).  Repositories tolerate missing or malformed stored data by falling back to defaults, which covers the "corrupted preferences" concern in practice.  Settings model: precision (2-10, default 8), notation (automatic/scientific/engineering), theme (project-owned `ThemePreference`), evaluation mode (real-time/on-submit).

**Needs Detail On** (for later phases):

- Data migration
  - Strategy for schema changes between versions (so far all changes have been additive, plus one-off orphaned-key cleanup as in the freeform-persistence removal; no versioned migration mechanism exists)
  - Backwards compatibility and migration testing approach
- Explicit "reset to defaults" functionality
- Custom-unit persistence (Phase 11) and the sqflite migration planned alongside custom worksheets (Phase 12)

### 5. UI/UX Design — **mostly complete (Phases 4-9)**

**Current State**: All the majors are shipped.  Freeform UI (Phase 4, plus completion, history, soft-wrap, keyboard hints); worksheet UI with multi-row layout, source-row indication, template switcher, and no-default picker (Phase 6 + Phase 9 refinements); the unit browser fills the "unit picker" role with dimension/alphabetical grouping, search, and detail pages (Phase 7); Settings organized into Display/Appearance/Freeform behavior/Currency rates/About sections; responsive design with three width tiers, safe areas, and tablet spacing (Phase 9); accessibility with screen-reader support, a WCAG contrast audit pinned by regression test, and 48 dp touch targets (Phase 9).

**Still needs design for later phases**:

- Worksheet customization UI (Phase 12): add/remove/reorder rows, per-row unit selection, editing existing templates
- Favorites and recent units in the browser (deferred with favorite-unit persistence, Phase 12)
- First-run onboarding/tutorial (deferred as nice-to-have, Phase 14; the idle-state tappable example covers lightweight onboarding)

### 6. Testing Strategy — **established in practice**

**Current State** (documented in best_practices.md "Testing Strategy"):

- Unit tests: 2088 passing across parser, core domain, tools, and features; the `test/` tree mirrors `lib/` directory-for-directory; MVP criterion is >80% coverage for parser/core domain, and CI now *enforces* a stricter 90% floor over all of `lib/` (currently ~95.9%) via `tool/check_coverage.dart` — F11 closed August 13, 2026
- Widget tests: shared harness in `test/helpers/` (`TestRepositories` + `pumpApp`) supplies all must-override repository providers; rebuild-scope tests use the `RebuildCounter` probe to pin per-keystroke rebuild bounds
- Integration tests: `integration_test/` suite (boot, simulated restart, mocked currency refresh) against a real Android emulator, run unconditionally in CI with a timeout-and-retry-only-on-timeout wrapper
- Performance testing: `tool/benchmark.dart` (with `--baseline` diffing) and `tool/memory_report.dart`; baselines, on-device procedures, and action thresholds (interaction >100 ms, memory >~50 MB) recorded in performance.md

**Remaining**: none blocking — both Phase 9 testing tasks were closed September 1, 2026.  The widget-test coverage-gap audit is subsumed by the CI gate (which measures UI at 96.23% against core's 95.16%, contradicting the "largely unit-level" premise the task was written on), and device testing was done throughout the phase without a written checklist.  The one known weakness an aggregate gate cannot catch is `worksheet_engine.dart` at 87.30%; raising it is a Phase 12 candidate.

### 7. Error Handling & User Feedback — **largely settled in implementation**

**Current State**:

- Exception hierarchy: all domain errors are `UnitaryException` subclasses (lex/parse/eval/dimension/bounds) with line/column positions on lex/parse errors; fail-fast with no partial-result recovery, and NaN-producing operations throw immediately — the "warnings" concept was never needed
- Freeform: errors render in the result display and are announced via a polite live region with an "Error: " prefix; unknown units, circular definitions, and dimension mismatches have specific messages
- Worksheets: per-cell red error text with an `error_outline` icon (non-color indicator) and native invalid-field semantics; worksheet-specific dimension-mismatch phrasing
- Background operations: currency refresh shows a spinner, enforces a 60-second cooldown, and surfaces failures in a dialog without disturbing stored rates
- Success feedback: copy actions confirm via SnackBar; evaluation results are announced to screen readers

**Remaining**: no systematic pass over error-message *wording* (exact phrasing, actionable fix suggestions) has been done; treat as release-polish if user testing surfaces confusing messages.

---


Next Steps
----------

When resuming design work, recommended order of priority:

1. ✅ ~~**Quantity Class & Arithmetic**~~ - **COMPLETED** (see quantity_arithmetic_design.md)
2. ✅ ~~**Unit System Foundation**~~ - **COMPLETE** (see archive/phase2_plan.md) — design and implementation done
3. ✅ ~~**Advanced Unit Features**~~ - **COMPLETE** — Temperature, constants, derived units implemented (Phase 3)
4. ✅ ~~**Basic UI - Freeform Mode**~~ - **COMPLETE** (see archive/phase4_plan.md) — design and implementation done
5. ✅ ~~**GNU Units Database Import**~~ - **COMPLETE** — Phase 5, full pipeline implemented
6. ✅ ~~**Worksheet System**~~ - **COMPLETE** — Phase 6, see openspec/changes/worksheet-mode/
7. ✅ ~~**Browse Mode**~~ - **COMPLETE** — Phase 7, see openspec/changes/browse-units/
8. ✅ ~~**User Data Persistence**~~ - **COMPLETE** — Phase 7 (persistence), see openspec/changes/user-data-persistence/
9. ✅ ~~**Currency Rate Management**~~ - **COMPLETE** — Phase 8, see openspec/changes/currency-support/
10. ✅ ~~**Phase 9: Polish & Testing**~~ - **COMPLETE** (September 1, 2026) — application icon, UI/UX refinement (responsive layouts, tablet support, accessibility, contrast audit, long expressions), performance measurement, integration tests, documentation cleanup (doc audit, README rewrite, CONTRIBUTING.md), CI coverage enforcement, and the dartdoc pass.  The widget-test coverage audit was closed as subsumed by the CI coverage gate (all of `lib/` at a 90% floor, ~95.9% actual, UI covered slightly better than core), and the manual device-testing checklist as done-in-practice-but-unwritten (safe areas, touch targets, TalkBack, on-device profiling, and the Android IME bug were all real-device findings).  See the [Implementation Plan](implementation_plan.md) for the per-item closing reasoning
11. **Phase 10: Release** - **IN PROGRESS** — task list re-derived from the actual shipped state on September 1, 2026 (see the [Implementation Plan](implementation_plan.md)).  Most of what the phase originally listed was already done incrementally: the repo is public and AGPL-licensed, the README and screenshots are current, and the tag-driven pipeline has published 38 releases plus an auto-deployed web build.  Three items blocked a published 1.0.0, all verified against the real build rather than assumed: **release signing** (the release build type used the debug key — `apksigner` reported `CN=Android Debug` — so anyone installing a debug-signed 1.0.0 could never update in place; **resolved September 5, 2026**, with v0.9.8 the first properly signed release, though the Play App Signing enrolment that makes both channels share one certificate is still ahead), **version code** (`pubspec.yaml` had no `+build` suffix, so every release APK reported `versionCode='1'`, which Play cannot accept twice — **resolved September 2, 2026**, see the dated entry below), and a **privacy policy**.  Worth a decision alongside them: code-review finding **F8** (worksheet AppBar dropdown overflows at ≲410 dp), the only user-visible item among the deferred findings.  **Play Store submission is an active goal of this phase**, not an optional extra: it is the largest single group of work and the long pole for the phase, since account verification and any mandatory closed-testing period are gated by Google's timelines rather than by work on this end, so those steps should start in parallel with the engineering tasks.  It also sharpens the signing decision — Play App Signing re-signs uploads with a Google-held key, so unless the same key backs both channels, a GitHub-installed APK and a Play-installed build of the same version have different signatures and cannot update over each other
12. **Testing Strategy** - established in practice; see the Testing Strategy section above
13. **Error Handling Details** - settled in implementation; the one open item is a wording pass, see the Error Handling section above

---


Open Questions
--------------

Questions that arose during design but haven't been resolved:

1. ~~Should we support variable-precision arithmetic, or is fixed precision acceptable?~~ → **RESOLVED**: Use `double` for MVP, rational numbers in Phase 15+
2. ~~How should we handle very long expressions in the UI (scrolling, wrapping, etc.)?~~ → **RESOLVED**: Soft-wrap — the freeform expression fields wrap visually and grow vertically without bound; Enter keeps its submit semantics and never inserts a newline (Phase 9, see `openspec/changes/long-expressions/`)
3. ~~Should worksheet field reordering be supported?~~ → **RESOLVED**: Yes, but as part of worksheet customization (Phase 12) — reordering only makes sense once worksheets are user-editable
4. ~~Do we need undo/redo functionality?~~ → **RESOLVED**: Won't do for now — freeform history covers recalling past inputs, and no need for it has come up in practice
5. ~~Should conversion history be searchable/filterable?~~ → **RESOLVED**: Deferred as a nice-to-have future enhancement (post-MVP); the 100-entry cap keeps the plain list manageable for now
6. ~~How many decimal places should be shown by default?~~ → **RESOLVED**: 6 decimal places, configurable 2-10 (Phase 4)
7. ~~Should the app support landscape orientation?~~ → **RESOLVED**: Yes — shipped in Phase 9 (responsive layouts, safe areas, tablet spacing; short-height phone landscape accepted as a device limitation)
8. ~~Do we need tutorial/onboarding screens for first-time users?~~ → **RESOLVED**: Deferred as a nice-to-have future enhancement (post-MVP); the idle-state tappable example already provides lightweight onboarding

---

*Last Updated: September 6, 2026*
*Design Sessions:*

- *Initial requirements gathering and core architecture*
- *Quantity Class & Arithmetic (January 30, 2026)*
- *Lexer/Parser Grammar Redesign (February 1, 2026)*
- *Phase 2: Unit System Foundation (February 6, 2026)*
- *Phase 4: Basic UI - Freeform Mode (February 16, 2026)*

*Implementation Progress:*

- *Phase 0: Project Setup completed (January 31, 2026)*
- *Phase 1: Core Domain - Expression Parser completed (February 4, 2026)*
  - 373 tests passing
  - Lexer, Parser, Evaluator, Dimension, Quantity, Rational all implemented
- *Phase 2: Unit System Foundation completed (February 7, 2026)*
  - 492 tests passing (119 new)
  - Unit, UnitDefinition, UnitRepository, built-in units, reduce, evaluator integration
- *Phase 3: Advanced Unit Features completed (February 13, 2026)*
  - 643 tests passing (151 new)
  - CompoundDefinition (unified from Linear/Constant/Compound), SI base units, temperature, constants
- *Phase 3 cleanup: Removed UnitDefinition.toQuantity, decoupled models from UnitRepository (February 14, 2026)*
  - 618 tests passing (removed 25 redundant toQuantity-based tests now covered through parser/resolveUnit paths)
  - All UnitDefinition subclasses now pure const data classes; unit resolution centralized in resolveUnit()
- *Dimensionless units: radian/steradian, PrimitiveUnit.isDimensionless, Dimension.removeDimensions (February 14, 2026)*
  - 643 tests passing (25 new)
  - Design document: dimensionless_units_design.md
- *SI prefix support: 24 prefixes from quecto (10^-30) to quetta (10^30) with prefix-aware unit lookup (February 15, 2026)*
  - 703 tests passing (60 new)
  - PrefixUnit subclass of DerivedUnit; prefixes stored separately in UnitRepository via registerPrefix()
  - findUnitWithPrefix() method with prefix-aware lookup ordering: exact match → prefix splitting (longest first) → standalone prefix → plural stripping
  - Prefix splitting: "kilometers" → kilo + meters → kilo + meter; "ms" → milli + second
- *Phase 4: Basic UI - Freeform Mode completed (February 16, 2026)*
  - 845 tests passing (142 new)
  - Freeform evaluation screen with two-field conversion, result display, drawer navigation
  - Settings screen with precision, notation, dark mode, evaluation mode
  - Riverpod state management with SharedPreferences persistence
  - Quantity formatting (decimal/scientific/engineering notation)
- *Build metadata in Settings version display (February 18, 2026)*
  - 847 tests passing (2 new)
  - package_info_plus dependency for reading app version from pubspec.yaml at runtime
  - packageInfoProvider (FutureProvider) wraps PackageInfo.fromPlatform()
  - Settings "About > Version" tile now shows dynamic version (e.g. "0.4.0")
  - Optional build suffix when `--dart-define=BUILD_METADATA=...` is set at build time (e.g. "0.4.0 (build 20260218-143022.abc1234)")
  - CI deploy-web job computes BUILD_METADATA (timestamp + short SHA) and passes it as dart-define
- *Notation rename and precision default increase (February 19, 2026)*
  - 851 tests passing (4 new)
  - Renamed `Notation.decimal` → `Notation.automatic` with label "Automatic"
  - Formatter now uses `toStringAsPrecision` (significant figures) instead of `toStringAsFixed` (decimal places)
  - Trailing-zero stripping splits on `'e'` to avoid corrupting exponent digits
  - Default precision raised from 6 to 8 significant figures
- *Output unit disambiguation in freeform conversion display (February 19, 2026)*
  - 859 tests passing (8 new)
  - Added `formatOutputUnit()` helper in `quantity_formatter.dart`
  - Units containing `+` or `-` are wrapped in parentheses (e.g. `(5ft + 1in)`)
  - Units starting with a digit or `.` are prefixed with `×` (e.g. `× 5 km`)
  - Used in `freeform_provider.dart` for both `formattedResult` and `formattedReciprocal`
- *Replace `bool? darkMode` with `ThemeMode themeMode` in settings (February 19, 2026)*
  - 868 tests passing (9 new)
  - `UserSettings.darkMode: bool?` → `themeMode: ThemeMode` (default `ThemeMode.system`)
  - Removed `clearDarkMode` hack from `copyWith`; standard nullable override now suffices
  - `SettingsRepository`: key renamed `'darkMode'` → `'themeMode'`; stored as string `"system"/"dark"/"light"`
  - `SettingsNotifier.updateDarkMode(bool?)` → `updateThemeMode(ThemeMode)`
  - `app.dart`: removed three-case bool switch; passes `settings.themeMode` directly to `MaterialApp.themeMode`
  - Settings UI: replaced `CheckboxListTile` + `SwitchListTile` with `RadioGroup<ThemeMode>` containing three `RadioListTile` widgets
- *Phase 5: Complete Unit Database (February 23, 2026)*
  - 844 tests passing (after phase + cleanup)
  - GNU Units import pipeline: `tool/import_gnu_units_lib.dart` (two-pass parser, conditional directives, alias detection via known-ID membership), `tool/import_gnu_units.dart`
  - Codegen pipeline: `tool/generate_predefined_units_lib.dart` (alias chain resolution, per-type Dart emitters, category grouping), `tool/generate_predefined_units.dart`
  - `lib/core/domain/data/units.json` — full merged GNU Units database (7294 units, 125 prefixes, 177 unsupported); importer-owned vs. pass-through field split; supports primitive/derived/prefix/alias/unsupported types
  - `lib/core/domain/data/predefined_units.dart` — regenerated from units.json; flat `_registerUnits` + `_registerPrefixes` structure
  - 26 new Phase 5 units: digital storage (bit primitive, byte, kibibyte, mebibyte, gibibyte, tebibyte), volume (liter, gallon, quart, pint, cup, floz, tbsp, tsp), area (hectare, acre), speed (knot), pressure (bar, atm, psi, mmHg), energy (cal, kcal, BTU, kWh, eV)
  - 164 tool tests (`test/tool/`): 63 importer + 54 codegen + 47 release_lib
- *Unit evaluation regression test (February 26, 2026)*
  - 845 tests passing (1 new)
  - Added `Evaluation` group to `test/core/domain/data/predefined_units_test.dart`: iterates all registered units, calls `resolveUnit` on each, fails on unexpected errors or unexpected passes
  - `_knownEvalFailures` set documents 37 units with unsupported expression features (angle-in-trig, `$` lexer, `%` lexer, Unicode identifiers), grouped by root cause with fix guidance
  - Fixed `basispoint` definition in `units-supplementary.json`: `0.01 %` → `0.01 percent` (the `%` alias is not a lexer-recognized token); regenerated `units.json` and `predefined_units.dart`
- *Circular unit definition detection (February 26, 2026)*
  - 848 tests passing (3 new)
  - `resolveUnit` in `unit_resolver.dart` now accepts optional `Set<String>? visited` parameter (the active resolution stack); throws `EvalException` immediately on re-entry for the same unit instead of stack-overflowing
  - Keys are namespace-qualified (`"<id>-"` for a `PrefixUnit` vs `"<id>"` for a unit; see `_cacheKey` in `unit_repository.dart`) so a `PrefixUnit` and a same-named `DerivedUnit` (e.g. prefix `US` and unit `US`) are tracked independently
  - `EvalContext` gains an optional `visited` field (defaults to `const <String>{}` for backward compat with `const EvalContext()`); `UnitNode.evaluate` threads `context.visited` into both `resolveUnit` calls
  - `ExpressionParser` gains an optional `visited` field, forwarded to `EvalContext`, so the resolution stack is shared across the full `resolveUnit` → `ExpressionParser` → `UnitNode` → `resolveUnit` call chain
  - `EvalException` propagates through `ExpressionParser.evaluate` → `freeform_provider` `on UnitaryException` handler — no UI changes required
  - 5 new tests in `test/core/domain/models/unit_test.dart`: self-reference, mutual `DerivedUnit` cycle, mutual cycle via defined functions, diamond dependency (no false positive), linear chain (no false positive)
- *Unknown unit error (February 27, 2026)*
  - 852 tests passing (4 new)
  - `UnitNode.evaluate()` in `ast.dart` now throws `EvalException('Unknown unit: "$unitName"')` when `repo != null` and `findUnitWithPrefix` returns no match; raw-dimension fallback removed for the repo path
  - `repo == null` (Phase 1 / parser-isolation mode) continues to produce raw dimensions unchanged
  - New/updated tests in `evaluator_test.dart`: EvalException thrown for unknown unit (with message-content assertion), unknown unit mid-expression, null-repo raw-dimension fallback
- *First-class builtin functions (March 2, 2026)*
  - 990 tests passing (138 new)
  - `lib/core/domain/models/function.dart`: `Bound` (value + closed flag), `QuantitySpec` (dimension, min/max bounds, `acceptDimensionless`), `UnitaryFunction` abstract class (id, aliases, arity, domain/range, `call()` with full validation, `callInverse()` default), `BuiltinFunction` concrete subclass (wraps `_impl` function pointer, `hasInverse == false`)
  - `lib/core/domain/data/builtin_functions.dart`: 12 `BuiltinFunction` instances (sin, cos, tan, asin, acos, atan, ln, log, exp, sqrt, cbrt, abs) + `registerBuiltinFunctions(UnitRepository repo)`
  - `log` changed from natural log to base-10 (`math.log(x) / math.ln10`); `ln` retains natural log behavior
  - `asin`/`acos`/`atan` return `Quantity` with `{radian: 1}` dimension; sin/cos/tan domain uses `acceptDimensionless: true` (accepts both `{radian: 1}` and pure `{}`)
  - `UnitRepository` extended: `_functions`/`_functionLookup` maps, `registerFunction()`, `findFunction()`, collision detection in `register()`, `withPredefinedUnits()` calls `registerBuiltinFunctions()`
  - `parser.dart`: `isBuiltinFunction(name)` check replaced with `_repo?.findFunction(name) != null`; no-repo parser no longer recognizes function calls
  - `ast.dart`: removed `_builtinFunctions`, `isBuiltinFunction()`, `_evaluateBuiltin()` switch; `FunctionNode.evaluate()` now dispatches via `context.repo?.findFunction(name)`
  - `parsec` and `hubble` now evaluate successfully (previously failed because trig rejected radian-dimension arguments; `acceptDimensionless: true` on trig domain now allows them)
  - New test files: `test/core/domain/models/function_test.dart`, `test/core/domain/data/builtin_functions_test.dart`
- *Defined functions (March 11, 2026)*
  - 1146 tests passing (156 new)
  - `EvalContext` gains `Map<String, Quantity>? variables` field; `UnitNode.evaluate()` checks variables before repo lookup so function parameter bindings shadow unit names
  - `ExpressionParser` gains `Map<String, Quantity>? variables` parameter, threaded into `EvalContext`
  - `UnitaryFunction.call()` and `callInverse()` gain `[Object? context]` optional parameter; `FunctionNode.evaluate()` passes its `EvalContext` through
  - New `lib/core/domain/models/defined_function.dart`: `DefinedFunction` class evaluates a forward expression string with parameter bindings; supports inverse evaluation for single-parameter functions; detects direct and mutual circular recursion via `"$id()"` keys in `EvalContext.visited`; lives in its own file to avoid a circular import (`function.dart` → `ast.dart` → `unit_repository.dart` → `function.dart`)
  - `tool/import_gnu_units_lib.dart`: `_classifyLine` routes nonlinear definitions (`name(params)`) to `_parseNonlinearDefinition()`; extracts params, `units=`, `domain=`, `range=`, `noerror`; parses domain interval lists (`[a,b]`, `(a,b)`, `[a,)`, mixed bracket types); splits expression body on `;` for forward/inverse; zero-arg form emits `function_alias`; `entriesToJson()` serializes `defined_function` and `function_alias` entries
  - `tool/generate_predefined_units_lib.dart`: `_emitDefinedFunction()` emits `DefinedFunction(...)` constructor calls with domain/range units resolved via `ExpressionParser` at registration time; `_builtinFunctionIds` skips defined functions whose names conflict with registered builtins (e.g. `abs`); `registerDefinedFunctions(UnitRepository repo)` top-level function emitted; `function_alias` entries folded into target function's aliases list
  - `lib/core/domain/data/units.json` regenerated: 7471 units, 125 prefixes, 0 nonlinear_definition entries in unsupported section
  - `lib/core/domain/data/predefined_units.dart` regenerated: contains `registerDefinedFunctions` registering 101 defined functions and 46 function aliases
  - `_knownEvalFailures` in `predefined_units_test.dart` cleared to empty set (normaltemp, S10, ipv4classA/B/C and others now resolve via defined functions)
- *Phase 6: Worksheet Mode (March 27, 2026)*
  - 1309 tests passing (163 new)
  - `WorksheetRowKind` sealed class (`UnitRow` | `FunctionRow`); `WorksheetRow` and `WorksheetTemplate` models
  - 10 predefined templates: Length (9), Mass (6), Time (6), Temperature (4), Volume (9), Area (8), Speed (5), Pressure (6), Energy (7), Digital Storage (6)
  - `computeWorksheet()` engine in `worksheet_engine.dart`: ratio-based for `UnitRow`, `func.call()`/`callInverse()` for `FunctionRow`, per-row error strings on dimension mismatch
  - `WorksheetNotifier` (non-`autoDispose`): synchronous per-keystroke recompute (no debounce — the engine runs in ~150–190 µs), "last keystroke wins" source, per-template in-session value maps
  - `WorksheetScreen` with `WorksheetRowWidget` (label + expression + numeric `TextField`) and AppBar `DropdownButton` for template selection
  - Drawer "Worksheet" tile enabled; navigates to `WorksheetScreen`
  - Design artifacts: `openspec/changes/worksheet-mode/`
  - Notable: `h` in codebase is Planck's constant; `degR`/`tempR` is Rankine (works as absolute scale since 0 °R = 0 K)
- *Phase 7: Browse Mode (April 7, 2026)*
  - 1436 tests passing (127 new)
  - `BrowseEntry` value class in `lib/core/domain/models/` (kind, name, primaryId, aliasFor, summaryLine, dimension)
  - `"dimensions"` key in `units-supplementary.json`: map of canonical representation → `{"label": "…"}`; merged by codegen into `units.json`; emitted as `const Map<String, String> predefinedDimensionLabels` in `predefined_units.dart`
  - `UnitRepository.buildBrowseCatalog()`: builds flat `List<BrowseEntry>` from all units (excl. PrefixUnit), prefixes, and functions; aliases as separate entries; dimension resolved via `_resolvedQuantityCache`
  - `BrowserNotifier` (non-`autoDispose`): both alphabetical and dimension indices built eagerly in `build()`; dimension view default (all collapsed); alphabetical view default (all expanded); search filtering with auto-expand; collapse state preserved across searches; `BrowserState.searchVisible` toggles search bar
  - `BrowserScreen`: body-only `Column` widget (no Scaffold); `HomeScreen` provides AppBar with search and view-mode toggle buttons via `Consumer` widgets
  - `UnitEntryDetailScreen`: dispatches by `BrowseEntryKind`; shows name, aliases, description, definition, resolved quantity (units only), domain/range (functions only), piecewise control-point table (`PiecewiseFunction` only); accepts optional `UnitRepository` for testing
  - Drawer "Browse" tile added between Worksheet and the divider; navigates to `BrowserScreen`
  - Design artifacts: `openspec/changes/browse-units/`
- *User Data Persistence (April 24, 2026)*
  - 1593 tests passing (157 new)
  - `WorksheetRepository` + `WorksheetPersistState` + `WorksheetSourceEntry` in `lib/features/worksheet/data/`; persists active template ID and per-template source `(rowIndex, text)` as a single JSON key in SharedPreferences
  - `worksheetRepositoryProvider` (must-override) in `worksheet_provider.dart`; `WorksheetNotifier.build()` restores state and re-runs engine for each persisted source; `onRowChanged` and `selectWorksheet` write-through on every change
  - Freeform input persistence was also added here but later removed (see below)
  - No new package dependencies; `sqflite` deferred to Phase 12
  - Design artifacts: `openspec/changes/user-data-persistence/`
- *Remove freeform persistence (May 2026)*
  - 1583 tests passing (10 removed)
  - Freeform "Convert from" / "Convert to" fields no longer persist across sessions — restoring stale expressions proved more awkward than helpful in practice
  - `FreeformRepository` deleted; `freeformRepositoryProvider` removed; `FreeformScreen.initState()` restore logic removed
  - Orphaned SharedPreferences keys (`freeformInput`, `freeformOutput`) cleaned up on first launch after upgrade
  - Worksheet persistence (active template + per-template source values) is unchanged
  - Design artifacts: `openspec/changes/remove-freeform-persistence/`
- *Freeform History (May 2026)*
  - 1619 tests passing (36 new)
  - Persistent history of successful freeform conversions — records (from, to) pairs after every non-idle, non-error evaluation result
  - `FreeformHistoryEntry` + `FreeformHistoryRepository` (SharedPreferences key `'freeformHistory'`, cap 100 entries, deduplication)
  - `FreeformHistoryNotifier` + `freeformHistoryProvider`; `FreeformNotifier.evaluate()` calls `record()` after any success state assignment
  - `_HistorySection` widget in `FreeformScreen`: always-visible when non-empty, tapping entry restores both fields and evaluates immediately
  - `freeformHistoryRepositoryProvider` must-override wired in `main.dart` and all tests
  - Design artifacts: `openspec/changes/freeform-history/`
- *Predictive Completion (May 2026)*
  - 1683 tests passing (64 new)
  - Inline unit/function/prefix suggestions in both freeform expression fields; only fires when cursor is at the end of a ≥2-char identifier token
  - `tokenAtCursor()` in `lib/core/domain/completion/token_at_cursor.dart` — uses the existing `Lexer` to find the identifier token ending at the cursor; suppresses tokens < 2 chars; returns null on `LexException`
  - `CompletionEntry` value class + `CompletionEntryKind` enum in `lib/core/domain/models/completion_entry.dart`
  - `UnitRepository.suggestCompletions(prefix, {limit})` — searches `_unitLookup`, `_prefixLookup`, `_functionLookup` with case-insensitive prefix match; ranks primary-ID matches before aliases; alphabetical within each group
  - `CompletionQuery` + `completionsProvider` (synchronous `Provider.family`) in `lib/features/freeform/state/completion_provider.dart`
  - `CompletionField` (`ConsumerStatefulWidget`) in `lib/features/freeform/presentation/widgets/completion_field.dart` — wraps `TextField` with `OverlayPortal` + `CompositedTransformFollower`; above/below positioning based on viewport center; `applyCompletion()` pure function for tap-to-insert
  - Both `TextField` widgets in `FreeformScreen` replaced with `CompletionField`; each has its own `OverlayPortalController` — overlays are fully independent
  - Design artifacts: `openspec/changes/predictive-completion/`
- *Completion overlay refinements (May 2026)*
  - 1688 tests passing (5 new)
  - **Border**: overlay `Material` uses `shape: RoundedRectangleBorder(side: BorderSide(color: outlineVariant))` for a thin themed border
  - **Width**: `ConstrainedBox(maxWidth: fieldWidth) + IntrinsicWidth` shrinks the overlay to the widest row; field width read from render object at build time (no stored state); `ListView` replaced with `SingleChildScrollView + Column` so `IntrinsicWidth` can measure row widths
  - **Scrolling**: `SizedBox` height capped at `_kMaxVisibleRows` (8) × row height; `SingleChildScrollView` renders all suggestions (up to the `suggestCompletions` limit of 50) and scrolls within the fixed height box
  - **Kind-specific display and insertion** (`_displayName` / `_insertText`):
    - Unit — displayed and inserted as plain name, with a trailing space appended on insertion so the cursor clears the token
    - Prefix — displayed with a trailing `-` (e.g. `kilo-`) to signal that a unit name follows; dash is NOT inserted
    - Function — displayed and inserted with a trailing `(` (e.g. `tempC(`) matching call-site convention
  - **Web tap fix**: on web the browser fires `focusout` on the text field at pointer-down, which hides the overlay before `onTap` fires; fixed with `onTapDown` on web and `onTap` on mobile (where `onTapDown` would interfere with scroll gestures); `kIsWeb` branch in `_buildSuggestions`
  - **Focus restoration**: `_insertCompletion` calls `focusNode.requestFocus()` after insertion (matching the operator key panel's `_insertSymbol`); a post-frame callback re-applies the cursor position because web's `requestFocus` can trigger a browser select-all
- *Infix completion matching (May 2026)*
  - 1692 tests passing (4 new)
  - `suggestCompletions` now uses `contains` rather than `startsWith` for matching, returning entries where the query appears anywhere in the name
  - Results are placed into four ordered tiers: prefix-primary (starts with, primary ID), prefix-alias (starts with, alias), infix-primary (contains but not starts with, primary ID), infix-alias (contains but not starts with, alias); each tier is sorted alphabetically
  - Updated spec.md Suggestion computation requirement and design.md §3 to document the four-tier ranking and infix matching
  - Updated `test/core/domain/models/unit_repository_suggest_test.dart` with new infix-specific tests (`ring` → `ringsize` before `euringsize`/`jpringsize`, prefix before infix ordering, four-group alpha sort, within-infix primary-before-alias)
- *Fix currency worksheet stale rates (June 11, 2026)*
  - 1797 tests passing (4 new)
  - `_worksheetParserProvider` in `lib/features/worksheet/state/worksheet_provider.dart` now builds its `ExpressionParser` from the shared `unitRepositoryProvider` instead of constructing an independent `UnitRepository.withPredefinedUnits()`; worksheet conversions (notably the Currency worksheet) now reflect stored exchange rates from launch
  - `WorksheetNotifier.build()`'s persisted-source seeding loop extracted into `_computeAllFromSources(WorksheetPersistState)`; a new `ref.listen<int>(unitRepositoryVersionProvider, ...)` recomputes display values for every persisted-source template after a currency rate refresh, matching the pattern already used by `BrowserNotifier`
  - Design artifacts: `openspec/changes/fix-currency-worksheet/`
- *Show currency rate refresh times in unit browser (June 14, 2026)*
  - 1811 tests passing (14 new)
  - `CurrencyRateRepository.descriptorForUnit(Unit, descriptors)` (static): matches a unit to its `CurrencyDescriptor` via `originalUnit.id == unit.id` or `unit.aliases.contains(descriptor.isoCode)`; fixes a latent bug where precious-metal ounce units (e.g. `goldounce`, alias `XAU`) never matched their `goldprice`-keyed descriptor
  - `lastUpdatedForUnit(Unit unit, List<CurrencyDescriptor> descriptors)` signature changed from a bare unit-ID string to a `Unit`, implemented via `descriptorForUnit`
  - New `lib/shared/utils/date_formatter.dart`: `formatShortDate(DateTime)` → `"Mmm D, YYYY"` (e.g. `"Jun 6, 2026"`)
  - `UnitEntryDetailScreen` now watches `currencyRateRepositoryProvider` and threads the repository through `_DetailBody` to `_UnitDetailBody`
  - `_UnitDetailBody` adds a "Last updated" section after "Value" for any unit/prefix matching a `CurrencyDescriptor` (via `repo.buildCurrencyDescriptors()` + `descriptorForUnit`): shows the formatted stored rate date when available, or "Using built-in rates" when the unit is a currency unit but no live rate has been fetched yet; section is omitted entirely for non-currency units
  - Design artifacts: `openspec/changes/show-refresh-times/`
- *Currency worksheet banner and AppBar refresh (June 15, 2026)*
  - 1838 tests passing (27 new)
  - General worksheet banner mechanism: `WorksheetBanner` sealed class (variant `CurrencyRatesBanner`) + optional `WorksheetTemplate.banner` field (default `null`); a template with no banner renders exactly as before
  - `WorksheetBannerWidget` (`lib/features/worksheet/presentation/widgets/worksheet_banner.dart`) switches on the banner variant; the `CurrencyRatesBanner` branch is a `ConsumerWidget` watching `currencyStatusProvider`, rendering a thin muted `surfaceContainerHighest` bar (`bodySmall`/`onSurfaceVariant`, schedule icon) showing the last sync time via shared `formatDateTime`, or "Using built-in rates"
  - `WorksheetScreen` renders the banner above the rows (body is now `Column` → banner + `Expanded` table) when `template.banner != null`, and adds a `CurrencyRefreshButton` to `AppBar.actions` when `template.banner is CurrencyRatesBanner`
  - Reusable `CurrencyRefreshButton` (`lib/features/currency/presentation/currency_refresh_button.dart`) extracted from `CurrencySettingsSection` along with the `_RefreshErrorDialog`; both Settings and the worksheet AppBar share it, so cooldown/in-progress state stays consistent (same `currencyStatusProvider`)
  - `formatDateTime(DateTime)` added to `lib/shared/utils/date_formatter.dart` (`"Mmm D, YYYY, h:mm AM/PM"`, local time), replacing the private `_formatDateTime` in `CurrencySettingsSection`; banner and Settings now show an identical timestamp
  - Currency template (`predefined_worksheets.dart`) declares `banner: _currencyRatesBanner`
  - Design artifacts: `openspec/changes/currency-worksheet-banner/`
- *Application icon (June 18, 2026)* — first change of Phase 9 (Polish & Testing); app icon moved here from Phase 10
  - 1839 tests passing (no test changes; build/asset-only)
  - Custom launcher/favicon icon applied to Android, iOS, and web, replacing the default Flutter icons
  - `assets/icon/unitary.svg` is the source of truth (embeds DejaVu Sans Mono Bold); `tool/generate_icons.sh` rasterizes it to `assets/icon/unitary.png` (1024×1024, via `inkscape`) and runs `flutter_launcher_icons`
  - Added `flutter_launcher_icons: ^0.14.4` dev dependency and its config block in `pubspec.yaml`: Android adaptive icon over `#060d18`, iOS with `remove_alpha_ios`, web with `#060d18` background/theme
  - Generated assets committed (Android mipmaps + adaptive `ic_launcher.xml`/`colors.xml`, iOS `AppIcon.appiconset`, web `favicon.png`/`icons/*`); web `manifest.json` colors updated to `#060d18`
  - `generate-icons` local hook added to `.pre-commit-config.yaml` (`pass_filenames: false`): runs `tool/generate_icons.sh` when `assets/icon/unitary.svg`, its bundled font, or the script changes, keeping committed assets in sync with the source
  - Design artifacts: `openspec/changes/app-icon/`
- *Responsive layouts (June 27, 2026)* — Phase 9 UI/UX refinement
  - 1886 tests passing (47 new)
  - Three responsive tiers from a single `WindowSizeClass` (`lib/shared/window_size_class.dart`): compact `<600` (drawer + single pane), medium `600–1040` (drawer + two panes), expanded `>1040` (persistent `NavigationRail` + two panes); derived from `MediaQuery.sizeOf`
  - `AppShell` (renamed from `HomeScreen`, `lib/shared/app_shell.dart`) owns the drawer↔rail decision and wraps the existing pages in an `IndexedStack` (with a `GlobalKey` so page state survives reparenting across the rail breakpoint); pages keep their own `Scaffold`/`AppBar` and become width-aware (`drawer: usesRail ? null : AppDrawer`, `automaticallyImplyLeading: !usesRail`) — "approach B", chosen over centralizing AppBar construction to avoid a risky Freeform state rewrite (deferred)
  - `TwoPaneLayout` + `PaneSize` (`lib/shared/two_pane_layout.dart`): pure geometry; per-pane sizing `fixed` / `fitContent({min,max})` / `fill({flex})`, collapsing to the `compactPrimary` pane below medium
  - Freeform: input history in a right pane at medium/expanded (AppBar history button + modal at compact only); shared `_HistoryList` between modal and pane
  - Worksheet: left-pane template list with static AppBar title at medium/expanded; AppBar dropdown at compact
  - Browse: selection lifted into `BrowserState` (`selectedPrimaryId`/`selectedKind` + `selectEntry`); embedded detail right pane via the extracted Scaffold-less `UnitEntryDetailBody`; pushed `UnitEntryDetailScreen` at compact; empty "Select a unit" placeholder
  - No new dependencies
  - Deferred: lift Freeform field/eval state into a notifier (only top-level page still coupled to widget `State`); pre-existing Worksheet dropdown overflow at very narrow widths
  - Design artifacts: `openspec/changes/responsive-layouts/`
- *Worksheet picker — no default selection (June 28, 2026)* — Phase 9 UI/UX refinement
  - 1894 tests passing
  - Worksheet mode no longer defaults to the Length template; no worksheet is active until the user picks one (the choice is then persisted/restored as before)
  - `WorksheetState.worksheetId` and `WorksheetPersistState.activeWorksheetId` are now nullable; `WorksheetRepository.load()` returns a null active id for missing/malformed data and drops an unrecognised id to null (preserving stored sources) instead of falling back to `'length'`
  - `WorksheetScreen` branches on a null active id: compact width shows the full-screen template list (`_TemplateList`) until one is selected, then the worksheet (driven by `TwoPaneLayout.compactPrimary` switching left→right); medium/expanded shows the left-pane list plus a centered `_EmptyWorksheetPane` ("Select a worksheet") placeholder, mirroring Browse's empty detail pane; AppBar shows static "Worksheet" title when nothing is selected
  - No new dependencies
  - Design artifacts: `openspec/changes/worksheet-picker/`
- *Screen-reader support (July 4, 2026)* — Phase 9 accessibility improvement
  - 1954 tests passing (62 new; 2 removed with dead code)
  - Freeform result display is an unconditional polite live region (WCAG 4.1.3 status-message convention): `ResultDisplay` wraps its content in `Semantics(liveRegion: true, label: resultSpeechLabel(result))` + `ExcludeSemantics`, so every settled evaluation state (success, conversion, definition, error) is announced without moving focus, in both evaluation modes
  - `formatSpeech(String)` in `lib/shared/utils/quantity_formatter.dart`: pure string rewrite of formatted display strings into speech-friendly form — `=`→"equals", `/`→"per", `^`→"to the power", `×`/`*`→"times", `|`→"over", signed exponents (`1.5e+3`)→"1.5 times 10 to the 3" ("negative N" for `e-N`); unsigned `2e3` (never emitted by the formatters) is left alone.  The rewrite exists for meaning, not polish: at default screen-reader punctuation verbosity, symbols in a semantics label are skipped entirely, so a literal label would lose the division/exponent/fraction structure
  - `resultSpeechLabel(EvaluationResult)` in `result_display.dart`: exhaustive `switch` over the sealed type (a new variant without a spoken form is a compile error); "Result: " prefix on success-type states and "Error: " on `EvaluationError` (message verbatim) so announcements are distinguishable from TalkBack's echo of the typed input; idle speaks instruction + example (`→` spoken as "to"); multi-line variants joined as sentences
  - Worksheet cell errors keep the red in-field message and gain a freeform-style `error_outline` prefix icon (`size: 20`, `semanticLabel: 'Error'`, `prefixIconConstraints` overridden so erroring fields stay the same height as normal ones) — the icon is the non-color indicator (WCAG 1.4.1).  The erroring field's own semantics node is additionally marked `SemanticsValidationResult.invalid` via an inner `Semantics` wrapping the `TextField` directly (on a wrapper shared with the copy action the property stays on the wrapper's node instead of merging into the field's — verified by probe).  An initial `errorText`-based version was reverted: the assistive-text line grew only the erroring rows, making row spacing jump (a collapsed-`errorStyle` variant was spike-validated but set aside as a styling hack; see design.md D3)
  - Idle-example tap target exposes `button: true` semantics; long-press-to-copy gestures expose labeled `CustomSemanticsAction`s ("Copy value" on worksheet cells, "Copy version"/"Copy build" on About rows, "Copy" on unit detail `_DetailText`), discoverable in TalkBack's actions menu / VoiceOver's rotor
  - Deferred to Phase 12: per-row worksheet error announcements (unreachable with predefined templates) and a semantics action for the label-cell transfer long-press
  - Discovered: `WorksheetRowWidget` (`worksheet_row_widget.dart`) was orphaned dead code — only its own test referenced it; deleted along with its test (which encoded the superseded red-text error styling) during verification cleanup
  - Discovered (on-device TalkBack pass, July 7): `RenderTable` double-applies the cell offset to descendant semantics transforms when a cell's semantics child lacks the `cell` role, shifting AT focus rectangles sideways off the worksheet fields (latent since the worksheet moved to `Table`; visible only with assistive tech on).  Fixed by wrapping every worksheet cell in `TableCell` (which supplies `Semantics(role: SemanticsRole.cell)`); regression test asserts field semantics rects match render rects
  - On-device TalkBack pass completed July 7; its findings (focus-rect fix, `|` mapping, "Result: " prefix) are folded in above
  - Design artifacts: `openspec/changes/archive/2026-07-07-screen-reader/`
- *Contrast audit (July 8, 2026)* — Phase 9 accessibility improvement
  - 1988 tests passing (34 new)
  - Computed exact WCAG 2.x contrast ratios for every custom-composed color pairing (including alpha blends composited over their real backgrounds) in both `ColorScheme.fromSeed(Colors.blue)` schemes; the suspected candidates from the plan (muted currency banner, `onSurfaceVariant` text) all pass ≥7.2:1 — every genuine failure involved a custom alpha blend
  - Worksheet source-row indicator: the `primaryContainer`@0.3 fill was 1.06:1 (light) / 1.17:1 (dark) against unfilled cells and was the *only* cue for which row drives the conversion (focus alone doesn't transfer source).  Even a solid `primaryContainer` fill only reaches ~1.2:1 in light mode, so the fix is a 2 dp `colorScheme.primary` `enabledBorder` on the source row (6.14:1 light / 10.87:1 dark); the width difference vs the default 1 dp border is the non-color cue (WCAG 1.4.1), the border draws inward so field geometry is unchanged, and the tint is retained as a supplement
  - `FastScrollBar`: peek-panel neighbour labels `onPrimary` alpha 0.65→0.85 (3.77/3.50 → 4.81/5.56, passing the 4.5:1 text threshold); thumb `primary` alpha 0.6→0.8 (2.64 light → 3.93); grip lines switched from `onSurface`@0.4 (1.65–2.0:1, wrong role) to `onPrimary`@0.9 (≥3:1 against the composited thumb)
  - Accepted as decorative (WCAG 1.4.11 exempt), recorded in the `color-contrast` spec: `outlineVariant` borders on the completion overlay (delineated by elevation + filled surface) and unit-detail tables; `surfaceContainerHighest`-derived background tints of the currency banner and browse sticky headers (text on them passes 4.5:1)
  - New `test/shared/color_contrast_test.dart`: WCAG relative-luminance/contrast/compositing helpers + a case table mirroring each widget's role/alpha literals, asserted ≥4.5:1 (text) / ≥3:1 (non-text) in both schemes — a Flutter upgrade that shifts `fromSeed` tones or a styling change below threshold fails the test
  - Design artifacts: `openspec/changes/archive/2026-07-08-contrast-audit/`
- *Long-expression soft wrapping (July 9, 2026)* — Phase 9 UI/UX refinement; resolves open question #2
  - 1993 tests passing (5 new)
  - Both freeform expression fields now soft-wrap and grow vertically without bound: `maxLines: null` on the inner `TextField` in `CompletionField`; the explicit `textInputAction` (`next` / `done`) already passed by both call sites keeps Enter as submit instead of the multiline default of inserting a newline
  - Wrapping is purely visual — no newline characters enter the text; pasted newlines are already treated as whitespace by the lexer (`_skipWhitespace`), pinned by a new end-to-end test in `expression_parser_test.dart`
  - Completion overlay needed no changes: `CompositedTransformFollower` recomputes from the field's render box, so the overlay tracks the grown bottom edge (pinned by a new widget test)
  - No existing tests assumed single-line geometry; all passed unchanged
  - Design artifacts: `openspec/changes/long-expressions/`
- *Performance measurement (July 13, 2026)* — Phase 9 performance section closed measurement-first; no optimization crossed the action thresholds (interaction >100 ms; memory >~50 MB)
  - 2034 tests passing (41 new)
  - New reusable tools following the `tool/` lib/exe convention: `tool/benchmark.dart` + `benchmark_lib.dart` (7 pure-Dart hot-path cases, warmup + min/median/mean, `--filter`, `--json`, `--baseline` diff with ±20% flagging and machine-dependence caveat) and `tool/memory_report.dart` + `memory_report_lib.dart` (staged RSS deltas; must run AOT — the tool warns under JIT, where the in-process compiler inflates RSS ~246 MB vs. ~8 MB AOT)
  - Companion `test/tool/worksheet_benchmark_test.dart` times the real `computeWorksheet()` under `flutter test` because the engine's import chain reaches `package:flutter/material.dart` via `UserSettings` (decoupling refactor recorded as a future enhancement)
  - Key numbers (dev machine JIT): cold resolution of all ~6200 units ~11 ms total (pre-warming **rejected**); warm ~133 µs; `buildCurrencyDescriptors()` ~1.5 ms (stays on the pre-frame startup path); worksheet recompute ~150–190 µs; completions ~0.5 ms/keystroke; core-domain memory ~10.6 MB (AOT RSS)
  - On-device (120 Hz phone, profile mode): first frame ~650 ms cold clean install / ~380 ms warm relaunch with full stored-rate path; typing produces 13–16 ms frames (over the 8.3 ms/120 Hz budget) caused by the whole `FreeformScreen` rebuilding twice per keystroke; Browse fast-scroll thumb drags overrun the budget frequently (`FastScrollBar` + peek panel rebuild every drag frame) — both recorded as follow-up candidates, not fixed here
  - New `RebuildCounter` widget-test probe (`test/shared/rebuild_counter.dart`, via the framework's `debugOnRebuildDirtyWidget` hook — the same mechanism DevTools' build tracking uses) with rebuild-scope tests pinning freeform ≤2 builds/keystroke and worksheet ≤1 build/edit
  - Discovered: the worksheet recompute path is synchronous (`onRowChanged` runs the engine in the same turn) — the "500 ms debounce" in the Phase 6 notes is stale for worksheets; at ~150 µs per pass this is sound
  - New `doc/performance.md`: tool usage, baseline workflow, manual on-device procedures (startup trace, DevTools passes), decision rules, dated baselines, and findings
  - Design artifacts: `openspec/changes/performance-measurement/`
- *Freeform rebuild scoping (July 17, 2026)* — minimal fix for the whole-screen ×2 rebuild per keystroke found by the performance measurement; the notifier/AppBar refactor stays deferred
  - 2036 tests passing (rebuild-scope tests tightened, written red-first against the old code)
  - Removed the per-keystroke `setState(() {})` from `_onInputChanged`/`_onOutputChanged`; the clear button re-evaluates via a `ListenableBuilder` wrapping the input `CompletionField` (the `suffixIcon: null`/non-null switch is preserved verbatim, so empty-field geometry is unchanged by construction — an always-present suffix widget would have reserved `InputDecorator`'s 48 dp slot), and the swap button listens via `Listenable.merge` over both controllers
  - Screen-level `ref.watch`es for `freeformProvider`/`freeformHistoryProvider` pushed into four scoped `Consumer`s (result display + idle-example tap, AppBar conformable-browse button, history pane, compact AppBar history button); `settingsProvider` watch intentionally stays at screen level
  - `rebuild-scope` spec tightened (MODIFIED): a keystroke plus its debounced evaluation rebuilds the `FreeformScreen` subtree root zero times, with positive-effect assertions so the bound can't pass vacuously
  - On-device re-pass (120 Hz phone): rebuild list shows only the scoped dependents, each ×1; normal typing now entirely under the 8.3 ms budget (was 13–16 ms), over-budget frames only during very rapid typing
  - Design artifacts: `openspec/changes/freeform-rebuild/`
- *Remove conformable-modal debug instrumentation (July 19, 2026)* — code review finding F6 (see `doc/code_review_2026-07.md`)
  - Deleted the `kDebugMode`-gated `Stopwatch` + `debugPrint('findConformable took …')` block from `_showConformableModal` in `freeform_screen.dart`, leftover from the Phase 9 performance measurement (the durable measurement lives in `tool/benchmark.dart` / `doc/performance.md`)
- *Decouple `UserSettings` from Flutter (July 22, 2026)* — code review finding F1 (see `doc/code_review_2026-07.md`)
  - 2035 tests passing (net -1: the deleted companion benchmark test's single case)
  - `UserSettings.themeMode` retyped from Flutter's `ThemeMode` to a new project-owned `ThemePreference` enum (`system`/`dark`/`light`, colocated with `Notation`/`EvaluationMode` in `user_settings.dart`); `user_settings.dart` no longer imports `package:flutter/material.dart`
  - `SettingsRepository` and `SettingsNotifier` follow suit and each lose their own now-unneeded Flutter import; persisted string values (`"system"/"dark"/"light"`) are unchanged, so no migration and no effect on existing users' saved preference
  - `settings_screen.dart`'s `RadioGroup`/`RadioListTile` retyped to `ThemePreference` (still legitimately Flutter UI code)
  - New `ThemePreference` → `ThemeMode` mapping (`_toFlutterThemeMode`) added at the single UI consumption point, `lib/app.dart`, feeding `MaterialApp.themeMode`
  - The worksheet engine's import chain (`worksheet_engine.dart` → `user_settings.dart`) is now pure Dart, so `computeWorksheet()`'s benchmark cases (`worksheet-compute-length`, `worksheet-compute-temperature`) moved from the `flutter test`-hosted `test/tool/worksheet_benchmark_test.dart` (deleted) into `tool/benchmark.dart`'s `buildDefaultCases()`; correctness coverage for `computeWorksheet()` continues via the 14 existing tests in `test/features/worksheet/services/worksheet_engine_test.dart`
  - `benchmark-tool` spec's "Benchmark coverage of named hot paths" requirement updated: `computeWorksheet()` cases are now covered by the ordinary "Full run covers all cases" scenario rather than a separate companion-benchmark scenario
  - `doc/performance.md` updated: companion-benchmark section replaced with dated worksheet-case numbers folded into the main benchmark tool section; the "deferred refactor" follow-up item marked fixed
  - Design artifacts: `openspec/changes/decouple-usersettings-flutter/`
- *Shared widget-test harness (July 26, 2026)* — code review finding F10 (see `doc/code_review_2026-07.md`)
  - 2043 tests passing (8 new)
  - New `test/helpers/repository_overrides.dart`: `TestRepositories` bundles default in-memory instances of the four must-override repositories (`settings`, `worksheet`, `freeformHistory`, `currencyRate`), all built from one mocked `SharedPreferences` instance via an async `create({initialPrefs})` factory; exposes the repositories as fields (for pre-seeding via `.save()` before pumping, or reconstructing with specific stored values) plus a `prefs` field (for tests that write raw/malformed values directly) and a computed `overrides` getter
  - New `test/helpers/pump_app.dart`: `pumpApp(tester, child, {repos, overrides})` pumps `child` wrapped in `ProviderScope` + `MaterialApp`, merging a `TestRepositories` (built fresh via `create()` if not supplied) with caller `overrides` into a `Map<ProviderBase, Override>` keyed by `Override.origin`, so a caller-supplied override for an already-defaulted provider takes precedence deterministically
  - `Override` isn't re-exported by `flutter_riverpod` (its `show` list omits it); added `riverpod` as an explicit `dev_dependency` (already resolved transitively at 3.2.1) and imported `Override` from `package:riverpod/misc.dart`, the one public export surface that includes it
  - Migrated all 21 files matching the F10 pattern (confirmed via `grep -rl "settingsRepositoryProvider\.overrideWithValue" test/`) to use the shared helpers instead of hand-rolling `SharedPreferences.setMockInitialValues` + repository construction + override lists; files with a reusable local `buildApp()` widget-builder kept it, sourcing its overrides from `TestRepositories` instead of individually-constructed repos; files with a single pump site or ad-hoc per-test reseeding call `pumpApp` directly
  - Discovered mid-migration: `ProviderScope`/`ProviderContainer` don't resolve a duplicate-provider override by list order at all — verified directly against this project's resolved riverpod 3.2.1, they throw `AssertionError: Tried to override a provider twice within the same container` in `kDebugMode` the instant two overrides share an `origin`, which is exactly what `pumpApp`'s explicit origin-keyed merge exists to avoid ever constructing. `unit_entry_detail_screen_test.dart`'s `_buildScreen` helper initially spread `repos.overrides` then appended a conditional override for the same `currencyRateRepositoryProvider`, duplicating it and crashing `ProviderScope`'s construction for every test that passed a seeded rate; the crash's downstream symptom (an unbuilt widget tree) surfaced as ordinary `expect()` failures rather than a visible assertion, which is what made it easy to first misdiagnose as a silent wrong-default bug rather than a hard failure. Fixed by building that one helper's override list explicitly instead of spreading. Audited all other migrated files for the same shape — no other occurrence
  - Discovered at verification: `test/features/freeform/state/freeform_provider_test.dart` was in the original 21-file candidate list but had been missed by the task breakdown (20 of 21 files were assigned to task groups); caught by re-running the candidate-file grep during final verification and migrated then
  - Design artifacts: `openspec/changes/test-harness-cleanup/`
- *Integration test suite (July 27 – August 2, 2026)* — code review finding F9 and the Phase 9 "Comprehensive testing" task; see `openspec/changes/archive/2026-08-02-integration-tests/`
  - New `integration_test/`: `boot_test.dart` (drives the real `app.main()` entry point; confirms no must-override provider throws, and that a currency rate seeded into real `SharedPreferences` before launch is applied to the unit repository before the first frame — the pre-first-frame rehydration loop in `main.dart`), `restart_test.dart` (a shared `restart()` helper calls `app.main()` a second time within the same test session against the same real, non-mocked `SharedPreferences` backing store; scenarios cover worksheet source values, a changed theme setting, and freeform history all surviving), `currency_refresh_test.dart` (own `ProviderScope` with `currencyServiceProvider` overridden to a `package:http/testing.dart` `MockClient` — never the real Frankfurter API — covering a successful refresh updating a live conversion and two failure shapes)
  - New `integration_test/helpers/real_prefs.dart`: seeds/clears the *real* platform-channel `SharedPreferences` plugin (as opposed to `test/helpers/repository_overrides.dart`'s `TestRepositories`, which is built on the mocked plugin and doesn't apply once `IntegrationTestWidgetsFlutterBinding` is in effect); `seedFreshCurrencyTimestamp()` is called before every `app.main()` invocation in the suite so `CurrencyStatusNotifier.maybeRefresh()`'s background staleness check never fires a real network request
  - `integration_test` added as an SDK dev dependency
  - **Web path tried first, abandoned as an upstream dead end**: `flutter test integration_test/ -d chrome` doesn't exist in Flutter 3.44 ("Web devices are not supported for integration tests yet"); the `flutter drive`-based mechanism that replaced it needs `chromedriver` and `--web-run-headless` (without which a *visible* browser window launches — happened once, harmlessly but for-real, on a developer's screen before the flag was identified). Every attempt — locally, then in an isolated Docker container built specifically to rule out the local machine's networking — hit an identical `AppConnectionException` from DWDS's `_startLocalDebugService`. A web search confirmed this is a long-standing, currently-unresolved Flutter/DWDS bug (GitHub issues #178725, #181357, #153165, #89534, #84353, spanning 2021 through Flutter 3.38 as of January 2026) — not fixable in this project
  - **Pivoted to a local Android emulator**, which turned out to already be fully set up on the dev machine (`flutter doctor`: "No issues found" for the Android toolchain; an existing `Pixel_6_Pro_API_33_13.0_` AVD; confirmed KVM access via an explicit per-user ACL on `/dev/kvm`). Native `integration_test` on Android needs none of the web path's machinery — no `flutter drive`, no chromedriver, no driver entrypoint — just `flutter test integration_test/<file>.dart -d <device>` directly
  - **Found and fixed a real production bug along the way**: every restart-based test crashed with `ArgumentError: Invalid argument(s): 0.0` from an unguarded `.clamp()` call in `lib/shared/widgets/fast_scroll_bar.dart` — `AppShell` keeps every top-level page alive in an `IndexedStack` for page-state preservation, so `BrowserScreen`'s `FastScrollBar` gets laid out even while a different page is visible, and a transient *tight zero-height* constraint during the second `runApp()` call (confirmed via a temporary diagnostic print, since reverted) made the clamp's upper bound negative. Confirmed via a standalone single-boot diagnostic test that this is **not reachable through any real single-launch usage** — only through literally replacing an already-attached root widget tree, which no real user action does. Fixed by flooring the clamp's upper bound at `0.0` (`math.max`), applied to both the crash site and a structurally-identical unguarded clamp in `_peekPanelTop`, matching the defensive pattern already used elsewhere in the same file (`_onDragUpdate`'s `trackHeight <= 0` early return)
  - Two more restart-technique test fixes, not app bugs: popping back to the base app before restarting from a pushed route (`Settings`), and scoping a finder to the history modal after discovering — a second, non-crashing instance of the same same-process-restart leaking widget state — that the "Convert from" field's `TextEditingController` survived the simulated restart despite freeform input explicitly not persisting (see "Remove freeform persistence" above)
  - All 8 scenarios across the 3 files pass repeatedly against the real emulator. CI wiring (`reactivecircus/android-emulator-runner`) was gated off (`ENABLE_ANDROID_INTEGRATION_TESTS: 'false'`) until a real CI run could be observed — flipped to `'true'` on PR #1 and **confirmed passing**
  - Two CI-only issues, neither reproducible locally, found only by watching real CI runs and both fixed: (1) `reactivecircus/android-emulator-runner` runs each line of a multi-line `script:` as its own separate `sh -c` invocation (for per-line log grouping), so the original inline `for...do...done` loop split apart and failed with a shell syntax error — fixed by moving the loop into `tool/run_integration_tests.sh` and pointing `script:` at that single line instead; (2) the emulator itself hung for 50+ minutes on a later run (`bad window surface handle` looping, no hardware KVM acceleration on GitHub-hosted runners) — a known intermittent flakiness mode of that action, unrelated to this project's code. Composite-action steps don't support GitHub's `timeout-minutes` key (a confirmed, still-open limitation), so `tool/run_integration_tests.sh` instead wraps the test loop in the `timeout` shell command (30 min/attempt, `--kill-after=30s`), retrying up to 2 attempts *only* on an actual timeout (exit 124) — a genuine test failure is never retried, verified in both directions by pushing a deliberately-broken assertion and observing it fail the workflow without a retry
  - **Unrelated fix bundled into the same PR**: `.pre-commit-config.yaml`'s `import-gnu-units` and `generate-predefined-units` hooks gained `pass_filenames: false`, fixing a pre-existing race condition where pre-commit split matched files across parallel invocations of the same hook, racing on the shared generated output files (`units.json`, `predefined_units.dart`) — found while getting this PR's own lint job green in CI
  - Full existing suite unaffected throughout: 2043 tests passing, `flutter analyze` clean
  - Design artifacts: `openspec/changes/archive/2026-08-02-integration-tests/`
- *Remove the Android integration-test opt-in toggle (August 2, 2026)* — follow-up to the entry above; see `openspec/changes/archive/2026-08-02-default-enable-android-tests/`
  - The `ENABLE_ANDROID_INTEGRATION_TESTS` gate on `.github/actions/test/action.yml`'s Android step is removed entirely, not replaced with a different toggle — the step now runs unconditionally for every workflow that uses `./.github/actions/test`
  - Motivation: `ci.yml`'s `test` job set the toggle to `'true'`, but `release.yml`'s `test` job (which also uses the same composite action) never set it, so the release pipeline was silently skipping integration coverage; an unconditional step guarantees every current *and future* caller gets coverage without needing to remember to opt in
  - `ci.yml`'s now-unused `env: ENABLE_ANDROID_INTEGRATION_TESTS` block is removed; `release.yml` needed no changes at all — it automatically picked up the Android step the next time it ran
  - `run-tests.sh`'s own `ENABLE_ANDROID_INTEGRATION_TESTS` check (a local shell variable gating whether the *local* script boots an emulator) is untouched — confirmed to be an independent mechanism that only shared a variable name with the removed CI toggle by convention, not a real coupling
  - Considered and rejected converting the toggle into a formal composite-action `input` with `default: 'true'` (keeping an opt-out available via `with:`) — no current or anticipated caller wants to opt out, so that would have been speculative complexity; a future genuine need for one is a small, well-motivated change to add back
- *Freeform keyboard/IME configuration (August 3, 2026)* — Phase 9 bug fix from on-device use
  - 2045 tests passing (1 new)
  - On Android, tapping a freeform expression field opened the keyboard with auto-capitalization engaged — and unit lookup is case-sensitive, so an auto-capitalized `Ft` is an unknown-unit error.  Root cause (confirmed by a two-round on-device diagnostic): the long-expressions change's `maxLines: null` made Flutter infer `TextInputType.multiline`, which Android IMEs treat as prose and auto-capitalize even though `TextCapitalization.none` (the default) was already being sent
  - Fix in `CompletionField`'s inner `TextField`: explicit `keyboardType: TextInputType.text` (overrides the `maxLines`-derived multiline type; wrapping is purely a rendering concern, so soft-wrap and Enter-to-submit are unaffected — verified on-device), plus `autocorrect: false` and `enableSuggestions: false` (unit identifiers like `kWh`/`tempF`/`mmHg` aren't dictionary words; the app's completion overlay is the domain-aware replacement).  Trade-off accepted: no swipe-typing in these fields on most IMEs
  - Rejected alternatives: explicit `TextCapitalization.none` (already the default and already ignored in multiline mode) and `TextInputType.visiblePassword` (reliable but semantically a lie; the polite hint proved sufficient)
  - New widget test pins all three properties (plus `maxLines: null`) on the inner `TextField`; existing `freeform-field-wrapping` scenarios guard the soft-wrap/Enter behavior
  - Design artifacts: `openspec/changes/freeform-keyboard-type/`
- *Documentation cleanup (August 5, 2026)* — code review findings F12/F13/F14/F15 done as one direct-edit documentation change (no OpenSpec artifacts); most of the Phase 9 "Documentation" task
  - No code changes; test count unchanged (2045)
  - **F13 (doc audit)**: completed phase plans (`phase1_plan.md`, `phase2_plan.md`, `phase4_plan.md`, `quantity_implementation_plan.md`) moved to `doc/archive/`, live links updated (`openspec/` archives left as historical records); `architecture.md` rewritten against the shipped code — real dependency list, grammar/token/AST descriptions matching the parser source, shipped descriptions of the unit-database pipeline, functions, worksheets, currency, and UI shell, actual source tree, and removal of its duplicated pre-implementation phase list (which contradicted the maintained `implementation_plan.md` numbering); `best_practices.md` updated in place (structure pointer instead of a stale tree, Riverpod 3 `NotifierProvider`/must-override patterns, actual persistence repositories, shared test harness + integration suite, real `<user>/<yyyymmdd>-<topic>` branch naming, `performance.md` pointer); `evaluation_pipeline.md` verified against the code (lookup order incl. plural-stripping minimum-length guards, prefix splitting, the `week` → `day` → `hour` → `minute` → `s` chain) and kept unchanged
  - **F12 (README, expanded scope)**: rewritten from scratch, user-first — install options (release APK, hosted web app at wisnij.github.io/unitary, source), feature tour with example conversions verified against the real engine via a throwaway `dart run` script (`110.95914 mph`, `4.0776307 m`), then developer material (build/test instructions, curated `doc/` links, icon regeneration) and a brief prose status section; all design-phase framing (roadmap, "planned" features/dependencies, duplicated status) dropped; per explicit requirement, the two intro paragraphs and the License section (incl. Contributors) preserved verbatim
  - **F14 (stale statements)**: worksheet "500 ms debounce" corrected to synchronous per-keystroke recompute in both tracking docs; circular-definition visited-key description corrected from `"prefix:<id>"` to the actual trailing-`-` convention (`_cacheKey`, `unit_repository.dart`)
  - **F15**: new `CONTRIBUTING.md` distilled from `best_practices.md` — bug-report guidance, dev setup incl. pre-commit hooks, change workflow (tests first; `flutter test --reporter failures-only` + `flutter analyze` before a PR), PR guidelines (focused PRs, conventional commits, no new dependencies without discussion, never hand-edit generated files), AGPL terms for contributions
  - Noticed while fact-checking: `findUnitWithPrefix`'s doc comment in `unit_repository.dart` lists plural stripping as a separate step *after* standalone-prefix matching, but the implementation runs it inside `findUnit()` (exact → plural) *before* prefix splitting; behavior is correct (`_findPluralIn`'s minimum-length guards keep `"ms"` resolving as milli+second), only the comment's ordering is off — not fixed here (docs-only change)
  - Remaining from the Phase 9 Documentation task at the time: the dartdoc pass on public APIs (done September 1, 2026, below)
- *README screenshots (August 7, 2026)* — follow-up to the README rewrite
  - The "What It Does" section now embeds one screenshot per major page (freeform, worksheet, currency worksheet, browse, settings), captured on the Pixel 6 Pro emulator in profile mode (no debug banner) and downscaled to 480 px wide so plain markdown image syntax renders at a sane size (the repo's markdownlint config forbids inline HTML sizing)
  - New reusable capture harness: `test_driver/screenshots_driver.dart` (a `flutter drive` driver whose `onScreenshot` callback writes `doc/screenshots/<name>.png`; kept in the standard `test_driver/` location that `flutter drive` conventions expect, but named for its single purpose so it isn't mistaken for part of the real integration-test suite, which runs driverless via `flutter test`) + `integration_test/screenshots/take_screenshots.dart` (boots the real `app.main()`, drives all five pages, captures each; no `_test` suffix, to make clear it's a capture tool rather than a correctness test); the capture lives in a subdirectory deliberately so `tool/run_integration_tests.sh`/CI's `integration_test/*.dart` glob never runs it — it's a manual tool, invocation documented in its header comment
  - Two capture gotchas solved, both worth remembering: (1) `IntegrationTestWidgetsFlutterBinding` does not install the synthetic test keyboard, so `enterText()` silently entered nothing while focus popped the device's real IME (empty fields + a stale keyboard-inset gap in the captures) — fixed with `tester.testTextInput.register()`, which intercepts the platform channel so text lands and no real keyboard appears; (2) `AppShell`'s `IndexedStack` keeps every page's widgets alive, so unscoped finders (`find.byType(TextField).first`, `find.byType(Scrollable)`) match offstage pages — field finders must be scoped via `find.descendant(of: find.byType(WorksheetScreen), ...)`
  - Also: the freeform completion overlay opens over the result display when the target field's text is a valid completion prefix (`cm`) — dismissed via `FocusManager.instance.primaryFocus?.unfocus()` before capturing
  - Follow-up (August 7): the Browse capture now expands the "Area" group in place (seventh alphabetically), showing five collapsed headers above an expanded one; a sixth screenshot (`unit-detail.png`) opens the `newton` detail page via the search flow; and Settings is captured twice — `settings-dark.png` (emulator's dark system theme) and `settings-light.png` (after tapping the "Light mode" radio in-app) — embedded side by side in the README at 400 px so the pair fits GitHub's content width.  The whole procedure is wrapped in `tool/take_screenshots.sh`: boots the emulator if no device is connected (AVD/device overridable via `AVD_NAME`/`DEVICE_ID`), runs the capture via `flutter drive`, downscales the PNGs (requires ImageMagick), and shuts the emulator down again only if the script started it (EXIT trap, so cleanup also runs on failure).  Two more capture gotchas: `tester.drag` steps large enough to page a list exceed the fling velocity threshold and ballistic-scroll far past the target (use `timedDrag`, or avoid scrolling entirely — the search flow won here); and browse entries for alias units render as `"<name> = <primary>"` (e.g. `acre = intacre`), so exact-text finders for a plain unit name only work on non-alias entries like `newton`
- *Fix integration-test boot race (August 9, 2026)* — flaky CI failure in `boot_test.dart` ("Bad state: No element" from the first `enterText` after boot; failed 2 of 3 GitHub Actions runs, never reproduced locally); direct fix, no OpenSpec artifacts
  - Root cause: `lib/main.dart`'s `main()` was `void main() async` and awaits real `SharedPreferences` platform-channel round trips (`getInstance()` plus two `remove()` calls) *before* `runApp`; the integration tests called `app.main()` unawaited (a `void` return can't be awaited), and `pumpAndSettle()` only loops while `hasScheduledFrame` — so on a slow emulator it could return while `main()` was still suspended pre-`runApp`.  The tree at that point is the placeholder `Container` that flutter_test installs at the start of *every* `testWidgets` body (`_runTestBody`, "Reset the tree to a known state"), so the finder saw no app widgets at all and `WidgetController.state`'s `Iterable.single` threw "No element".  Fast machines win the race inside the first pump's real-time frame wait; loaded GitHub-hosted emulators (software rendering, no KVM) intermittently lose it
  - Fix: `main()` now returns `Future<void>` (identical runtime behavior — a Dart entrypoint may return a Future) and all seven `app.main()` call sites (`boot_test.dart` ×2, `restart_test.dart`'s `restart()` helper + 3 direct boots, `integration_test/screenshots/take_screenshots.dart`) now `await app.main()`, guaranteeing `runApp` has run and its warm-up frame is scheduled before `pumpAndSettle` starts
  - `tool/run_integration_tests.sh`'s timeout-retry wrapper correctly did *not* retry this failure (exit 1, not 124) — genuine-failure semantics working as designed; no script changes
  - Local verification surfaced a *second*, rarer flake mode (~1 in 3 emulator runs): `restart_test.dart` intermittently reported `A RenderFlex overflowed by N pixels` (N varied — 32, then 41).  Two theories were pursued and *both disproven* before instrumenting: the focus-driven operator `_KeyPanel` making the outgoing tree overflow-prone (unfocusing before the swap did not stop it), and the in-place `runApp` swap's transient degenerate-constraint layout pass (the artifact class that surfaced the `FastScrollBar` zero-height clamp bug when the suite was built).  A temporary `FlutterError.onError` dump with phase markers settled it: the overflow is reported during the **text-entry** phase, not the restart at all — it only *surfaced* after `restart()` because a recorded exception sits in the binding until the next `takeException()`
  - Real root cause: `IntegrationTestWidgetsFlutterBinding` leaves `registerTestTextInput` false (`integration_test.dart`), so focusing a field lets `TextInput.show` reach the platform and pop the emulator's **real IME** — the same trap the screenshot harness hit in August 2026.  Its inset arrives in the real screen's physical pixels, but `useCompact()` forces `devicePixelRatio` to 1.0, so `MediaQuery` scales a ~1000 px keyboard as ~1000 *logical* px against an 800 px-tall test view.  The freeform body is squeezed to `0<=h<=14`, `Expanded` collapses to zero, and the fixed-height `_KeyPanel` (~55 px) overflows by exactly the shortfall (55 − 14 = 41, matching the report).  Flaky because the keyboard's animation timing relative to `pumpAndSettle` varies per run.  Text still landed throughout because the framework grants client id `-1` a debug-only bypass (`text_input.dart`), which is why the tests mostly passed
  - Fix: a `useTestKeyboard(tester)` helper (`tester.testTextInput.register()` + an `unregister` tear-down) alongside the existing `useCompact`, called by all three restart scenarios and by `boot_test.dart`'s text-entry test.  Registering intercepts the text-input channel so no real IME ever appears, text still lands (now via a matching client id rather than the `-1` bypass), and the overflow cannot occur.  The earlier overflow-tolerating `FlutterError.onError` filter in `restart()` was **removed** — it was built on the disproven diagnosis, sat in the wrong window to catch this report anyway, and would have masked genuine layout errors; `restart()` is back to seed/boot/settle plus a single `expect(takeException(), isNull)`
  - 2045 tests passing, `flutter analyze` clean; `restart_test.dart` passed 10 consecutive local emulator runs with the real keyboard suppressed, plus a clean full-suite run
- *Enable KVM acceleration for the CI emulator (August 10, 2026)* — the Release workflow for commit 92e2821 failed (run 31445832242) while CI for the same commit passed; direct fix, no OpenSpec artifacts
  - Symptom: both attempts of `tool/run_integration_tests.sh` hung — attempt 1 on `boot_test.dart`, attempt 2 on `currency_refresh_test.dart` (a different file each time, so not test-specific).  Each hang began immediately after `Installing …app-debug.apk`, was accompanied by a single `ERROR | bad window surface handle 0x…` from the emulator, and then produced no further output until the 30-minute per-attempt `timeout` fired (exit 124, correctly *not* treated as a test failure).  Total job: 1h13m
  - Root cause: the emulator was running with **no hardware acceleration**.  The launch line the action emits is `emulator … -accel off`, preceded by `ProbeKVM: This user doesn't have permissions to use KVM (/dev/kvm)` and `The KVM line in /etc/group is: [kvm:x:993:]`.  So `/dev/kvm` *does* exist on GitHub-hosted x86_64 Ubuntu runners — the runner user simply isn't in the `kvm` group, `disable-linux-hw-accel: auto` detects that and falls back to full software emulation.  This corrects the assumption recorded in the August 2 entry above and in `openspec/changes/archive/2026-08-02-integration-tests/design.md` ("no hardware KVM acceleration on GitHub-hosted runners"): the acceleration is available, it was just permission-gated.  (GitHub enabled nested virtualization for Actions Linux runners in 2024; ARM runners still don't expose `/dev/kvm`, so this depends on staying on x86_64 `ubuntu-latest`.)
  - Fix: an `Enable KVM group permissions` step in `.github/actions/test/action.yml`, immediately before the emulator step — the `99-kvm4all.rules` udev rule (`KERNEL=="kvm", GROUP="kvm", MODE="0666"`) plus `udevadm control --reload-rules` / `udevadm trigger --name-match=kvm`, exactly as documented in the android-emulator-runner README.  No changes to `tool/run_integration_tests.sh`: its timeout/retry wrapper stays as the backstop, and its 30-minute per-attempt budget is now generously oversized (the *un*accelerated healthy run — CI 31445832186, same commit — took ~13 minutes for all three files)
  - Not changed, recorded as the obvious next step if flakes persist: the timeout/retry granularity is per *whole run*, so a hang in the last file re-runs the first two.  Moving it to per-file (with a retry budget per file) would cut recovery time and stop a late hang from redoing earlier work
  - Verification is by CI observation only — the mechanism doesn't exist locally (the dev machine already has a per-user ACL on `/dev/kvm`).  Confirm on the next run that the `-accel off` flag and the `ProbeKVM` permission warning are both gone from the emulator launch log
- *CI coverage threshold (August 13, 2026)* — code review finding F11 and the Phase 9 "Verify >80% coverage target" task; see `openspec/changes/ci-coverage-threshold/`
  - 2088 tests passing (43 new, of which 16 came from the post-implementation review pass below); coverage is now **enforced** in CI rather than merely measured.  The existing steps are untouched — `flutter test --coverage`, `cobertura convert`, the artifact upload, and `cobertura show` all still run exactly as before; a new `Check coverage threshold` step runs `dart run tool/check_coverage.dart` after them
  - New `tool/check_coverage.dart` + `tool/check_coverage_lib.dart` + `test/tool/check_coverage_lib_test.dart`, following the established tool lib/exe convention.  No new dependencies: the `cobertura` package exposes only `convert` and `show` (no threshold checking), and an `lcov`-based step would have needed an `apt-get install` plus untestable shell logic
  - **Scope is all of `lib/` at a 90% minimum**, not `lib/core/` at 80%.  The review's rationale for narrowing ("a repo-wide threshold would be dominated by UI files") was measured and found false: non-core code is covered slightly *better* than core — 96.23% vs 95.16% — so there was no dilution to avoid, and narrowing would only shrink what the gate protects.  Baseline at introduction: **~95.9%** (3332/3474 on the measured run), leaving ~205 lines of slack under the floor.  The MVP's >80% criterion is satisfied by construction, on a strictly larger body of code than it asks for
  - Notably, a `lib/core/`-only scope would have left `lib/features/worksheet/services/worksheet_engine.dart` unguarded — pure Dart conversion logic (deliberately decoupled from Flutter in the F1 work), and at **87.30%** the least-covered logic file in the project.  It is "core domain logic" by the criterion's intent but `features/` by directory
  - The generated `predefined_units.dart` is excluded by exact path (not by its directory, so hand-written `builtin_functions.dart` stays inside the gate).  At 7233 lines it is larger than all hand-written `lib/` code combined and is 100% covered as a side effect of registration: including it reports 98.66%, and hand-written coverage could fall to ~69% before that combined figure dropped below 90%
  - **Absence from an LCOV report is ambiguous**, and this cost a design iteration.  `flutter test --coverage` omits a file either because no test loads it *or* because it has no executable lines to instrument — and the report cannot distinguish the two.  The first draft treated every absent in-scope file as untested, counting it as one uncovered line; that premise is wrong.  `lib/features/worksheet/data/predefined_worksheets.dart` has its own dedicated test file plus four other test files importing it, and appears **zero** times in `lcov.info` — it is 224 lines of pure `const` data with nothing to instrument.  The same is true of `top_level_page.dart` (a bare enum) and `about_constants.dart`.  The draft would have printed "not covered by any test" for legitimately tested files
  - Resolved with an explicit `defaultExpectedAbsent` allowlist checked in **both** directions, the same pinned-expectation pattern as `_knownEvalFailures` in `predefined_units_test.dart`: an unlisted absence fails, an allowlisted file that *starts* reporting coverage fails as a stale entry, and an allowlist entry whose file no longer exists fails as a stale entry.  This removes the approximation entirely — an allowlisted file contributes an exact `0/0` rather than a fudged `0/1`.  It ships with four entries (`main.dart`, unreachable from the unit-test run; the three declaration-only files above), each carrying the reason it qualifies.  Under the originally-planned `lib/core/` scope the list would have been empty, since every declaration-only file in the project lives outside `lib/core`
  - Step placement in `.github/actions/test/action.yml` is deliberate: *after* the conversion and upload, so a threshold failure still leaves a downloadable report to diagnose it with; *before* the emulator steps, so a deterministic seconds-long check fails fast instead of after the ~13-minute integration run
  - Discovered while wiring CI: the separate `release.yml` referenced throughout these docs no longer exists — the pipelines were consolidated into `ci.yml` in commit 6e27a2e.  A single `test` job now gates the whole downstream chain (`lint → test → {deploy-web, prepare} → build-android-apk/build-web → release`), so one gate covers the web deploy, the APK build, and the release
  - Deliberately **not** done: a per-file floor.  It would fail on legitimately thin data classes (`completion_entry.dart` at 8.33%, `token.dart` at 33.33%, both covered indirectly and accepted in the July review).  The consequence is accepted knowingly — an aggregate gate cannot catch one weak file, so `worksheet_engine.dart` passes on the strength of the other 3411 lines.  It stays visible in the per-file output, and raising it is a natural candidate for Phase 12 (the widget-test coverage-gap audit this originally pointed at was closed September 1, 2026 as subsumed by the gate itself)
  - Also not done: detecting generated files by their `// GENERATED CODE` marker.  The exclusion is a path list that happens to contain a generated file, so a *second* generated file added under `lib/` would silently join the scope and (being registration code) inflate the aggregate.  Low risk with one generator and one output, recorded here rather than solved
  - Two `/opsx:verify` passes after implementation found three items, fixed one at a time.  **Both genuine defects were in argument-override paths that had no automated coverage**, which is the pattern worth remembering: (1) narrowing the scope via `--scope` made the on-disk enumeration skip allowlisted files elsewhere in the tree, so all four were reported as deleted — fixed by gating the staleness checks on `isInScope` (which subsumes the exclusion check) rather than `isExcluded`; (2) `--exclude` replaced the defaults instead of adding to them, so `--exclude lib/features/` silently readmitted the generated units file and reported 99.20% instead of 95.29% — the exact distortion the default exclusion exists to prevent, one flag away.  `--exclude` is now additive while `--scope` keeps replace semantics (narrowing is the whole point of passing it)
  - Prompted by those two, `parseArgs` moved out of the executable into `check_coverage_lib.dart` and gained 13 tests: option parsing encodes real behavior (recognised options, replace-vs-accumulate, value validation) and belongs where it can be tested.  `_report`/`_reportMismatches` (~100 lines of pure output formatting) stay in the executable, verified by invocation only — a deliberate boundary, not an oversight
  - Discovered by the second verify pass: **the suite's line coverage is not perfectly reproducible**, drifting by one line between runs.  `FreeformNotifier._pickExample()` draws from `idleExamples` with an unseeded `Random` in a `do { … } while (pick == _lastExample)` loop, and `FreeformExample.operator ==` short-circuits — its last comparison runs only when the picker happens to redraw the previous example somewhere in the suite, so `idle_examples.dart` reports 4/7 or 5/7.  Pre-existing; the gate merely made it visible.  At ±0.03 points against ~205 lines of headroom it cannot flip the verdict, so it is documented in the change's design Risks rather than engineered around — seeding production randomness to stabilise a metric would be the tail wagging the dog.  The practical consequence is that baseline figures are quoted approximately (~95.9%, not 95.88%)
- *Dartdoc pass on public APIs (September 1, 2026)* — the last of the Phase 9 "Documentation" tasks; direct edits, no OpenSpec artifacts
  - 2088 tests passing (no test changes — doc comments only), `flutter analyze` clean
  - **Measured before writing anything.**  `public_member_api_docs` is not in `analysis_options.yaml` and never has been; temporarily enabling it flags **224 members** across `lib/`.  The composition is what matters: 86 constructors + 81 fields (75% of the total) are leaf members of classes that *already* carry a class-level doc comment — e.g. `EvaluationIdle` in `freeform_state.dart` has a four-line doc explaining `example`, and the lint still flags the field and the constructor beneath it.  Remainder: 18 "other", 15 type-declaration hits, 13 enum values, 11 methods
  - **The 15 type-declaration hits were only 2 real ones.**  The first reading of the lint output took line numbers at face value and concluded seven declarations were undocumented; five of those (`BrowseEntryKind`, `BrowseViewMode`, `ThemePreference`, `TopLevelPage`, `PaneSide`) are in fact documented — because each is a *single-line* enum, the lint reports its undocumented **values** at the enum's own line, distinguishable only by column (e.g. `browse_entry.dart:4:24`, `:4:30`, `:4:38` are `unit`, `prefix`, `function`).  Confirmed independently with a scan for type declarations lacking a preceding `///`, which found exactly two in all of `lib/`.  Lesson for any future lint-driven sweep here: read the column, not just the line
  - Documented `UnitaryApp` (`lib/app.dart`) — root widget, owns the two seeded `ThemeData` variants and maps the persisted `UserSettings.themeMode`, holds nothing else (the shell is `AppShell`), and fires the post-frame currency staleness check
  - Documented `CurrencyStatusNotifier` (`lib/features/currency/state/currency_provider.dart`) — seeds `lastUpdatedAt` from stored rates in `build()` so the first frame is correct without the network, and the deliberate asymmetry of its two paths: `maybeRefresh` (silent, 24-hour staleness check, swallows errors) vs. `refresh` (always fetches, reports progress, returns an error string, 60-second cooldown), both incrementing `unitRepositoryVersionProvider` only when stored rates actually changed
  - `TokenType`'s 13 values carried real explanatory content in trailing `//` comments (`number, // 3.14, 1.5e-10, .5`) that neither IDE hover nor dartdoc can see; converted to `///` above each value, keeping the `// Literals` / `// Operators` section dividers as plain comments.  Expanded where the source said more than the comment did, each claim checked against `lexer.dart`/`parser.dart` first and then empirically via a throwaway `ExpressionParser` script: `times` also accepts `·`/`×`/`⋅`/`⨉` and is *lower* precedence than implicit multiplication; `divide` also spells as `÷` and the word `per` (`5 m per s` → 5 m/s); `divideNum` binds at the highest precedence level and requires bare numeric literals on both sides (`2|3 m` → 0.667 m, but `2|3 m|s` → `ParseException (1:6)`)
  - **Deliberately not done**, recorded so it isn't re-litigated: the 167 constructor/field comments (boilerplate beneath docs that already explain them); enabling `public_member_api_docs` — Unitary is an application, not a published package, so there is no external consumer of its API surface and the value of per-field docs accrues only to maintainers, who are better served by the class-level narrative that already exists; and publishing generated dartdoc
  - `doc/api/` was found on disk, **gitignored**, generated February 4–5 2026 and never regenerated — it covers only the Phase 1 libraries (`core_domain_{errors,models,parser}`, `app`, `main`) and nothing since.  Decision: not published, left as-is.  If it is ever wanted, GitHub Pages alongside the web app is the natural home and it needs a CI job
  - If the lint is ever wanted for the core layer alone, a nested `lib/core/analysis_options.yaml` (`include: ../../analysis_options.yaml` + the rule) was verified to scope it exactly: 70 hits, nothing outside `lib/core` flagged
- *Android version code (September 2, 2026)* — Phase 10 release blocker; see `openspec/changes/version-code/`
  - 2111 tests passing (23 new), `flutter analyze` clean
  - Every release through v0.9.7 shipped as `versionCode='1'`: `pubspec.yaml` carried a bare `version: 0.9.7` with no `+build` half, so Flutter substituted its default of 1.  Android orders builds by version *code*, not by version name, so all 38 published releases looked like the same build to the package manager, and Play — which requires each upload to strictly exceed the previous code — could have accepted such a build at most once.  No Gradle change was needed: `android/app/build.gradle.kts` already reads `versionCode = flutter.versionCode`; the entire defect was the missing suffix
  - Scheme: `MAJOR × 1000000 + MINOR × 1000 + PATCH`, so `1.2.3` → `1002003` and `0.9.7` → `9007`.  `Version.versionCode` in `tool/release_lib.dart` computes it and `Version.pubspecVersion` joins name and code; `tool/release.dart` writes `X.Y.Z+CODE` on every bump.  The version name stays the single source of truth — no second counter to bump or forget
  - Rejected: a hand-maintained counter (forgettable, and the failure surfaces at upload time), and git-derived or timestamp values (not reproducible — a clean checkout of a tag would not rebuild the same artifact).  Deriving from the name is the only option besides a hand counter that keeps a tagged build reproducible
  - **The step size was widened from 100 to 1000 per component during review.**  The original draft allocated two digits each to minor and patch, on a readability argument that does not survive scrutiny: `10203` must be paired from the right to read, while three-digit groups match the grouping numeric displays already apply, so a rendered `1,002,003` separates into exactly one group per component.  The decisive argument was reachability — a hundred patch releases in one minor line, or a hundred minors without a major bump, are unremarkable for a long-lived app, and hitting the ceiling would force an encoding migration in the middle of cutting a release.  Widening later is at least monotonic (`M × 10⁶ + m × 10³ + p ≥ M × 10⁴ + m × 10² + p` for all non-negative components), but a migration never needed beats one merely survivable.  The one thing the narrower scheme bought — room for a fourth build/hotfix component inside Android's ceiling, which three-digit groups cannot fit — was declined: a re-release is handled by bumping the patch
  - Also considered and rejected during review: a `YYYYMMDDbb` date stamp.  It clears the reproducibility objection if stamped at release time and committed (rather than computed at build time), and it removes the component ceiling — but it consumes 96.5% of the version-code namespace on day one, which makes the choice **irreversible**: every semver-derived value is smaller than a date stamp already shipped, so nothing else could ever follow it.  It also severs the name↔code bijection (the code no longer says which release it labels), deletes the consistency check outright (a date has nothing to be checked against), and would give a backported patch a *higher* code than the later minor it was backported from
  - Two ceilings throw rather than returning an unusable value, both `RangeError`: a minor or patch component ≥ 1000 (unencodable — `1.1000.0` and `2.0.0` would both yield `2000000`), and a code above Android's maximum of 2100000000 (major above 2100).  The second was added during review as well: it is the nearest of the three ceilings under the wider scheme, and unlike the component ceiling there is no widening available, since that limit belongs to the platform
  - Discovered while writing the monotonicity test: **monotonicity is conditional on encodability**.  `Version(9, 99, 999).bump(patch)` is `9.99.1000`, which throws — the guard doing its job, converting what would have been a silent collision into a loud failure.  The test fixture moved to `9.998.998` (near the top of the range, every bump still inside it) and a companion test now pins the interaction explicitly
  - `checkVersionCodeConsistency()` guards against hand edits: `pubspec.yaml` is hand-editable, so a recorded code can drift from the name it follows.  It returns null or a message, and `tool/release.dart` calls it immediately after reading the version — before any bump, commit, or tag, and before the dry-run branch, so `--dry-run` aborts too.  A *missing* code counts as a mismatch, which is exactly the bug being fixed.  Verified by hand in all three states: bare `0.9.7` aborts ("with no version code. Expected \"0.9.7+9007\""), seeded `0.9.7+9007` proceeds, corrupted `0.9.7+1234` aborts, each exiting 1 and leaving `CHANGELOG.md` untouched
  - `updatePubspecVersion` needed no change at all — its `^version:\s*\S+` regex already consumes an existing suffix, so the round trip leaves no duplicate `+` and no stale code (now pinned by tests).  The tag name, changelog heading, and link references all interpolate `'$newVersion'`, whose `toString` is the bare `X.Y.Z`, so no suffix leaks into them
  - `pubspec.yaml` seeded to `0.9.7+9007` rather than waiting for the next bump, so the tree is consistent immediately and release builds report a sensible code before 1.0.0 is cut.  Verified against a real artifact: `aapt2 dump badging` reports `versionCode='9007' versionName='0.9.7'` — the same command that originally exposed the permanent 1.  The About screen is unaffected; it reads `PackageInfo.version` (the name), and `buildNumber` appears nowhere in `lib/`
  - The published version-code-1 releases are not retroactively fixed and cannot be.  Since every new code exceeds 1, the transition needs no special handling — worth stating because the reverse, a scheme whose first value undercut the deployed one, would have been unrecoverable
- *Privacy policy and web-doc generation (September 6, 2026)* — Phase 10 release blocker; see `openspec/changes/privacy-policy/`
  - 2155 tests passing (67 new: 33 generator, 7 `PrivacyScreen`, 3 About-screen; the rest from refinements below), `flutter analyze` clean, coverage 95.91% over `lib/` (up from ~95.9%), `privacy_screen.dart` at 100%
  - `PRIVACY.md` at the repository root is the single source of truth.  It is **both** bundled as a Flutter asset (rendered in-app by `PrivacyScreen`, mirroring `LicenseScreen`) and generated into `web/privacy/index.html` for the hosted URL <https://wisnij.github.io/unitary/privacy/>
  - **The link-out-versus-bundle decision reversed during design, and the reversal is the more interesting half.**  The first design linked out only, on the argument that a policy compiled into an APK freezes while the hosted copy moves on, leaving two documents that disagree.  That framing was wrong: an installed APK's behaviour is *also* fixed at build time, so the policy shipped with it is the one that accurately describes the software the user is running — a later document, written about later code, would be the misleading one to show them.  The two copies answer different questions ("what does this app do?" vs. "what does the current version do?").  They are kept distinguishable by the document carrying an effective date and naming the canonical hosted URL, which `Markdown.onTapLink` renders as a working link, so one source document serves both channels with no special-casing.  It also closes an awkward gap: the policy of an offline-first app is now itself readable offline
  - **Three deployment facts were verified rather than assumed**, and each shaped the design.  (1) The `gh-pages` tree is *entirely* derived: `deploy-web` runs `git --work-tree build/web add --all` then force-pushes, so the branch tree is exactly `build/web` (42 files, all Flutter output) and nothing hand-maintained survives there.  (2) Everything under `web/` is copied verbatim into `build/web` — confirmed in the Flutter tool source (`build_system/targets/web.dart:625`, a `listSync(recursive: true)` + `copySync` loop skipping only `index.html` and `flutter_bootstrap.js`) — so a committed page reaches both the deployment and the release archive with **no CI change at all**.  (3) GitHub Pages 301-redirects directory paths lacking a trailing slash (`/unitary` → `/unitary/`, and `/unitary/icons` → `/unitary/icons/` even with no `index.html` there), so `…/unitary/privacy` is linkable while the trailing-slash form stays canonical
  - **Jekyll was investigated as a way to convert the Markdown, and rejected on three grounds** — all established empirically.  It only converts files carrying YAML front matter: `GET /unitary/assets/LICENSE.md` returns `200 text/markdown` with the raw source, proving front-matter-less Markdown is treated as a static file.  Front matter would then be actively harmful for any document that is *both* a Flutter asset and under `web/`, because it lands in `build/web` twice and Jekyll cannot tell the asset copy from the page copy — it would convert both and drop each source `.md`, breaking the runtime `loadString`.  (`PRIVACY.md` avoids this by living at the repository root, so it reaches `build/web` only as `assets/PRIVACY.md`.)  And with no `_config.yml` or `_layouts/`, Jekyll emits a bare fragment with no `<title>`, `charset`, or `viewport` — unusable on the phone a Play reviewer opens the URL on
  - **`web/.nojekyll` was added as a fix, not a precaution: Jekyll is already silently deleting a deployed file.**  `.last_build_id` is committed to `gh-pages` (it is among the 42) yet returns **404** on the live site, while `version.json` and `manifest.json` beside it return 200 — Jekyll excludes `.`- and `_`-prefixed paths from its output, with no error anywhere.  Harmless for that file, but it is the live form of a failure class that would not be: a future Flutter release or a package shipping assets under an `_`-prefixed directory would vanish from the site with no signal.  It also permanently retires a trap on `assets/LICENSE.md` — the web License screen works *only* because that file happens to carry no front matter, and no test would catch someone adding one.  With `PRIVACY.md` now a second Markdown asset, the protection covers two files.  Verified that the dotfile survives the build (`build/web/.nojekyll`) and that `git add --all` stages it, so it will reach the branch; the only observable change to the live site should be `.last_build_id` starting to return 200
  - `tool/generate_web_docs.dart` + `_lib.dart` is deliberately **general**, not privacy-specific, so publishing `doc/` later is a data change: the document set is a `const` list of source/output pairs; titles come from each document's first H1 (setext included, matching the project's Markdown convention); the back-link to the app is derived from the page's depth below `web/` rather than configured per document, and is never root-absolute (a standalone page gets no `--base-href` substitution, so `/` would resolve to the hosting domain); styling is inlined so a page renders from the release archive with no external fetch; and output is written only when it differs.  Content width is capped at `37.5rem`, echoing the app's own `kReadableMaxWidth` of 600 dp
  - **A link to a `.md` file outside the document set is a hard failure.**  Link *rewriting* is deliberately not built — the right rule depends on a `doc/` URL layout not yet chosen — but failing loudly turns "publish dead cross-links" into a build error on the day `doc/` is added, and guards `PRIVACY.md` today against a stray `[README](README.md)`.  Checking runs against the *rendered HTML* rather than the Markdown source, which catches reference-style links for free
  - Output is committed and kept in step by a `generate-web-docs` pre-commit hook naming its inputs individually.  **No new CI step was needed**: the lint job already runs `pre-commit/action@v3.0.1`, which fails when a hook modifies a file and defaults to `--all-files`, so the hook runs tree-wide in CI regardless of the `files:` pattern — a forgotten pattern entry degrades to "not regenerated locally, caught by lint" rather than a stale published page.  Verified in a throwaway repository in both directions: in sync → `Passed`; source edited without regenerating → `Failed` ("files were modified by this hook").  That verification had to be done in a scratch repo because pre-commit detects both file *selection* and *modification* through git, so neither half of the guard is observable while the files are still untracked
  - **The permission claim in the policy was wrong in the first draft, and the verification step caught it.**  The draft said "a single permission, `INTERNET`".  `aapt2 dump badging` on the real signed release APK (`versionCode='9007'`) reports `INTERNET` **and** `dev.wisnij.unitary.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION`, confirming what the implementation plan had said all along.  The second is Flutter-declared, namespaced to the app, and used for its own private broadcast receivers on newer Android versions; the policy now lists both and explains that neither grants access to anything about the user
  - Two disclosures are made deliberately, because a bare "we collect nothing" would overclaim: the exchange-rate request necessarily exposes the requester's **IP address** to the Frankfurter operator even though it carries no identifier, and the **web** build is served by GitHub Pages, which logs requests as any host does — a distinction that does not apply to the installed app
  - Rendering was verified headless in both colour schemes at phone (390 px) and desktop (1400 px) widths.  Two Chromium gotchas worth remembering: `--force-dark-mode` applies Chrome's auto-darkening rather than matching `prefers-color-scheme`, so the dark palette had to be exercised by unwrapping the media block in a temporary copy; and headless Chromium *reports* `prefers-color-scheme: dark`, so the unmodified page renders dark by default and the light palette needed the dark block stripped instead
  - Two test refinements during implementation, both loosening assertions that over-constrained rather than fitting tests to code: the rendered-H1 assertion moved from exact `<h1>…</h1>` markup to an attribute-tolerant regex, because the `gitHubWeb` extension set emits heading ids (deliberately kept — a published policy can deep-link to its own sections, now pinned by its own test); and the `PrivacyScreen` link-tap test's fixture put the link in its own paragraph, because tapping the centre of a mixed paragraph lands on prose rather than on the link's `TapGestureRecognizer`, so the test had been passing vacuously
  - No new runtime dependency: `markdown` was promoted from transitive (via `flutter_markdown_plus`) to a direct **`dev_dependency`** at the same resolved 7.3.1, since `tool/` never ships in the app
