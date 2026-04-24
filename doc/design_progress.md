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

### 3. Currency Rate Management

**Current State**: Requirements defined (auto-update, offline support, manual refresh)

**Needs Detail On**:

- API selection and integration
  - Which currency rate API to use (e.g., exchangerate-api.io, ECB, etc.)
  - API request/response format
  - Rate limiting considerations
  - API key management (if required)
- Rate storage schema
  - Database structure for rates
  - How to store timestamps
  - Which currencies to include
- Update scheduling
  - Exact logic for 24-hour check
  - Background vs. foreground updates
  - Retry logic on failure
  - Exponential backoff strategy
- Offline behavior
  - Fallback to last known rates
  - UI indication of stale rates
  - Warning thresholds (e.g., rates older than 7 days)
- Initial rates
  - How to bundle default rates with app releases
  - Update frequency for bundled rates

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
9. **Currency Rate Management** - Can be added after core features work
10. **Testing Strategy** - Define before/during implementation
11. **Error Handling Details** - Refine during implementation

---


Open Questions
--------------

Questions that arose during design but haven't been resolved:

1. ~~Should we support variable-precision arithmetic, or is fixed precision acceptable?~~ → **RESOLVED**: Use `double` for MVP, rational numbers in Phase 15+
2. How should we handle very long expressions in the UI (scrolling, wrapping, etc.)?
3. Should worksheet field reordering be supported?
4. Do we need undo/redo functionality?
5. Should conversion history be searchable/filterable?
6. ~~How many decimal places should be shown by default?~~ → **RESOLVED**: 6 decimal places, configurable 2-10 (Phase 4)
7. Should the app support landscape orientation?
8. Do we need tutorial/onboarding screens for first-time users?

---

*Last Updated: April 24, 2026*
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
  - `FreeformRepository` in `lib/features/freeform/data/`; persists "Convert from" and "Convert to" strings as two separate SharedPreferences keys
  - `freeformRepositoryProvider` (must-override) in `freeform_provider.dart`; `FreeformScreen.initState()` restores controller text and defers evaluation to post-frame callback via `addPostFrameCallback`
  - `main()` constructs all three repositories after `SharedPreferences.getInstance()` and injects them via `ProviderScope` overrides
  - No new package dependencies; `sqflite` deferred to Phase 12
  - Design artifacts: `openspec/changes/user-data-persistence/`
