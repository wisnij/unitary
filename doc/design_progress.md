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
- **Document**: [phase4_plan.md](phase4_plan.md)

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

The following areas have been identified but need deeper design work:

### 1. Worksheet System — **COMPLETE (Phase 6)**

Core worksheet mode is implemented.  See Phase 6 design notes above.

**Still needs design for later phases**:

- Custom worksheet creation and editing (Phase 12)
- Sidebar pinning of worksheets (future)
- Unit list rows (`ft;in` multi-field display, future)

### 2. GNU Units Database Import

**Current State**: Identified as data source for units

**Needs Detail On**:

- GNU Units file format
  - Structure and syntax of the definitions file
  - How units, prefixes, and constants are represented
- Parsing strategy
  - Parser implementation approach
  - Handling of different definition types
  - Mapping GNU Units syntax to our internal format
- Data transformation
  - Converting to our Unit/UnitDefinition structure
  - Handling of special cases or GNU-specific features
  - Validation of imported data
- Import process
  - One-time import vs. periodic updates
  - How to bundle with app
  - Versioning of unit database
- Incompatibilities and special cases
  - GNU Units features we won't support
  - Workarounds for differences in architecture

### 3. Currency Rate Management — **COMPLETE (Phase 8)**

- **API**: Frankfurter v2 (`https://api.frankfurter.dev/v2/rates?base=USD`); no API key; NDJSON list of `{date, base, quote, rate}` objects; rates inverted (`1.0 / frankfurterRate`); includes precious metals (XAU, XAG, XPT)
- **Dynamic unit layer**: `UnitRepository` has `_dynamicUnits`/`_dynamicLookup` maps that shadow the compiled static layer; `registerDynamic()` / `unregisterDynamic()` + cache invalidation
- **Currency detection**: `buildCurrencyDescriptors()` evaluates all `[A-Z]{3}` names, keeps those resolving to `{US$: 1}`; precious metals use hardcoded overrides that update intermediate price units (e.g. `goldprice` for `XAU`)
- **Storage**: `CurrencyRates` in SharedPreferences (`currencyRates` key); per-currency `{rate, date}` entries + top-level `updatedAt`; will migrate to sqflite in Phase 12
- **Startup**: stored rates loaded synchronously before first frame; `maybeRefresh()` fired fire-and-forget in `UnitaryApp.initState()` post-frame callback; 24-hour staleness threshold
- **Settings UI**: "Currency rates" section with last-updated timestamp or "Using built-in rates"; manual refresh button with 60-second cooldown; spinner while fetching
- **Design artifacts**: `openspec/changes/currency-support/`

### 4. User Preferences & State Management

**Current State**: Basic settings model designed for Phase 4 (precision, notation, darkMode, evaluationMode).  Riverpod chosen for state management; SharedPreferences for persistence.  See [phase4_plan.md](phase4_plan.md).

**Needs Detail On** (for later phases):

- Data migration
  - Strategy for schema changes between versions
  - Backwards compatibility
  - Migration testing approach
- State restoration
  - Handling corrupted preferences
  - Reset to defaults functionality
- Additional preferences for worksheet mode, currency, custom units

### 5. UI/UX Design

**Current State**: Freeform mode UI fully designed for Phase 4 (screen layouts, navigation, input/output fields, result display, settings screen).  See [phase4_plan.md](phase4_plan.md).

**Needs Detail On**:

- Worksheet UI
  - Multi-field layout
  - Unit selector per field
  - Active field indication
  - Worksheet switcher
  - Add/remove fields UI
- Unit picker design
  - Category organization
  - Search/filter functionality
  - Favorites display
  - Recent units
  - Preview/description display
- Settings screen
  - Organization of settings
  - Precision controls
  - Notation selector
  - Theme controls
  - About/help sections
- Responsive design
  - Phone layouts
  - Tablet layouts
  - Landscape mode
- Accessibility
  - Screen reader support
  - Contrast requirements
  - Touch target sizes

### 6. Testing Strategy (Not Yet Discussed)

**Needs Detail On**:

- Unit test approach
  - What to test at unit level
  - Coverage targets
  - Mock strategies
- Integration test approach
  - Key integration points
  - Test scenarios
- Widget/UI test approach
  - Which UI flows to test
  - Testing tools and frameworks
- Performance testing
  - Benchmarks for parser/evaluator
  - UI responsiveness targets

### 7. Error Handling & User Feedback (Partially Discussed)

**Current State**: Error types defined for parser/evaluator

**Needs Detail On**:

- User-facing error messages
  - Exact wording for common errors
  - Helpful suggestions for fixes
  - When to show errors vs. warnings
- Error recovery
  - How to handle partial input
  - Graceful degradation strategies
- Loading states and feedback
  - Indicators for background operations
  - Progress for long operations
- Success feedback
  - Confirmation for user actions
  - Subtle vs. prominent feedback

---


Next Steps
----------

When resuming design work, recommended order of priority:

1. ✅ ~~**Quantity Class & Arithmetic**~~ - **COMPLETED** (see quantity_arithmetic_design.md)
2. ✅ ~~**Unit System Foundation**~~ - **COMPLETE** (see phase2_plan.md) — design and implementation done
3. ✅ ~~**Advanced Unit Features**~~ - **COMPLETE** — Temperature, constants, derived units implemented (Phase 3)
4. ✅ ~~**Basic UI - Freeform Mode**~~ - **COMPLETE** (see phase4_plan.md) — design and implementation done
5. ✅ ~~**GNU Units Database Import**~~ - **COMPLETE** — Phase 5, full pipeline implemented
6. ✅ ~~**Worksheet System**~~ - **COMPLETE** — Phase 6, see openspec/changes/worksheet-mode/
7. ✅ ~~**Browse Mode**~~ - **COMPLETE** — Phase 7, see openspec/changes/browse-units/
8. ✅ ~~**User Data Persistence**~~ - **COMPLETE** — Phase 7 (persistence), see openspec/changes/user-data-persistence/
9. ✅ ~~**Currency Rate Management**~~ - **COMPLETE** — Phase 8, see openspec/changes/currency-support/
10. **Phase 9: Polish & Testing** - **IN PROGRESS** — application icon done (see openspec/changes/archive/2026-06-18-app-icon/); remaining: UI/UX refinement, performance, comprehensive testing, and documentation cleanup (audit/keep-vs-archive the `doc/` design documents, rewrite the README)
11. **Testing Strategy** - Define before/during implementation
12. **Error Handling Details** - Refine during implementation

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

*Last Updated: July 26, 2026*
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
  - Keys are namespace-qualified (`"prefix:<id>"` vs `"<id>"`) so a `PrefixUnit` and a same-named `DerivedUnit` (e.g. prefix `US` and unit `US`) are tracked independently
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
  - `WorksheetNotifier` (non-`autoDispose`): 500 ms debounce, "last keystroke wins" source, per-template in-session value maps
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
- *Integration test suite (July 27 – August 2, 2026)* — code review finding F9 and the Phase 9 "Comprehensive testing" task; see `openspec/changes/integration-tests/`
  - New `integration_test/`: `boot_test.dart` (drives the real `app.main()` entry point; confirms no must-override provider throws, and that a currency rate seeded into real `SharedPreferences` before launch is applied to the unit repository before the first frame — the pre-first-frame rehydration loop in `main.dart`), `restart_test.dart` (a shared `restart()` helper calls `app.main()` a second time within the same test session against the same real, non-mocked `SharedPreferences` backing store; scenarios cover worksheet source values, a changed theme setting, and freeform history all surviving), `currency_refresh_test.dart` (own `ProviderScope` with `currencyServiceProvider` overridden to a `package:http/testing.dart` `MockClient` — never the real Frankfurter API — covering a successful refresh updating a live conversion and two failure shapes)
  - New `integration_test/helpers/real_prefs.dart`: seeds/clears the *real* platform-channel `SharedPreferences` plugin (as opposed to `test/helpers/repository_overrides.dart`'s `TestRepositories`, which is built on the mocked plugin and doesn't apply once `IntegrationTestWidgetsFlutterBinding` is in effect); `seedFreshCurrencyTimestamp()` is called before every `app.main()` invocation in the suite so `CurrencyStatusNotifier.maybeRefresh()`'s background staleness check never fires a real network request
  - `integration_test` added as an SDK dev dependency
  - **Web path tried first, abandoned as an upstream dead end**: `flutter test integration_test/ -d chrome` doesn't exist in Flutter 3.44 ("Web devices are not supported for integration tests yet"); the `flutter drive`-based mechanism that replaced it needs `chromedriver` and `--web-run-headless` (without which a *visible* browser window launches — happened once, harmlessly but for-real, on a developer's screen before the flag was identified). Every attempt — locally, then in an isolated Docker container built specifically to rule out the local machine's networking — hit an identical `AppConnectionException` from DWDS's `_startLocalDebugService`. A web search confirmed this is a long-standing, currently-unresolved Flutter/DWDS bug (GitHub issues #178725, #181357, #153165, #89534, #84353, spanning 2021 through Flutter 3.38 as of January 2026) — not fixable in this project
  - **Pivoted to a local Android emulator**, which turned out to already be fully set up on the dev machine (`flutter doctor`: "No issues found" for the Android toolchain; an existing `Pixel_6_Pro_API_33_13.0_` AVD; confirmed KVM access via an explicit per-user ACL on `/dev/kvm`). Native `integration_test` on Android needs none of the web path's machinery — no `flutter drive`, no chromedriver, no driver entrypoint — just `flutter test integration_test/<file>.dart -d <device>` directly
  - **Found and fixed a real production bug along the way**: every restart-based test crashed with `ArgumentError: Invalid argument(s): 0.0` from an unguarded `.clamp()` call in `lib/shared/widgets/fast_scroll_bar.dart` — `AppShell` keeps every top-level page alive in an `IndexedStack` for page-state preservation, so `BrowserScreen`'s `FastScrollBar` gets laid out even while a different page is visible, and a transient *tight zero-height* constraint during the second `runApp()` call (confirmed via a temporary diagnostic print, since reverted) made the clamp's upper bound negative. Confirmed via a standalone single-boot diagnostic test that this is **not reachable through any real single-launch usage** — only through literally replacing an already-attached root widget tree, which no real user action does. Fixed by flooring the clamp's upper bound at `0.0` (`math.max`), applied to both the crash site and a structurally-identical unguarded clamp in `_peekPanelTop`, matching the defensive pattern already used elsewhere in the same file (`_onDragUpdate`'s `trackHeight <= 0` early return)
  - Two more restart-technique test fixes, not app bugs: popping back to the base app before restarting from a pushed route (`Settings`), and scoping a finder to the history modal after discovering — a second, non-crashing instance of the same same-process-restart leaking widget state — that the "Convert from" field's `TextEditingController` survived the simulated restart despite freeform input explicitly not persisting (see "Remove freeform persistence" above)
  - All 8 scenarios across the 3 files pass repeatedly against the real emulator. CI wiring (`reactivecircus/android-emulator-runner`) was gated off (`ENABLE_ANDROID_INTEGRATION_TESTS: 'false'`) until a real CI run could be observed — flipped to `'true'` on PR #1 and **confirmed passing**
  - Two CI-only issues, neither reproducible locally, found only by watching real CI runs and both fixed: (1) `reactivecircus/android-emulator-runner` runs each line of a multi-line `script:` as its own separate `sh -c` invocation (for per-line log grouping), so the original inline `for...do...done` loop split apart and failed with a shell syntax error — fixed by moving the loop into `tool/run_integration_tests.sh` and pointing `script:` at that single line instead; (2) the emulator itself hung for 50+ minutes on a later run (`bad window surface handle` looping, no hardware KVM acceleration on GitHub-hosted runners) — a known intermittent flakiness mode of that action, unrelated to this project's code. Composite-action steps don't support GitHub's `timeout-minutes` key (a confirmed, still-open limitation), so `tool/run_integration_tests.sh` instead wraps the test loop in the `timeout` shell command (25 min/attempt, `--kill-after=30s`), retrying up to 2 attempts *only* on an actual timeout (exit 124) — a genuine test failure is never retried, verified in both directions by pushing a deliberately-broken assertion and observing it fail the workflow without a retry
  - **Unrelated fix bundled into the same PR**: `.pre-commit-config.yaml`'s `import-gnu-units` and `generate-predefined-units` hooks gained `pass_filenames: false`, fixing a pre-existing race condition where pre-commit split matched files across parallel invocations of the same hook, racing on the shared generated output files (`units.json`, `predefined_units.dart`) — found while getting this PR's own lint job green in CI
  - Full existing suite unaffected throughout: 2043 tests passing, `flutter analyze` clean
  - Design artifacts: `openspec/changes/integration-tests/`
