Phase 4: Basic UI - Freeform Mode
==================================


Overview
--------

**Goal:** Build the first working UI for Unitary — a freeform expression
evaluator screen with two-expression conversion support, a settings screen,
and drawer-based navigation.

**Deliverable:** A working app where users can type `5 miles` in the input
field and `km` in the output field, and see `8.04672 km` displayed as the
result.

**Scope boundaries:**

- Freeform mode only — no worksheet mode (Phase 5).
- Basic settings only — precision, notation, dark mode, evaluation mode.
- No persistence of conversion history.
- No unit picker or category browser — users type unit names directly.
- No conversion syntax in the grammar (`5 ft to m`) — two-field approach only.
- Drawer navigation scaffolded for future modes; worksheet entry present but
  disabled.

**Prerequisites:** Phases 0-3 complete (703 tests passing). ExpressionParser,
UnitRepository, Quantity, and Dimension APIs are stable.

---


Design Decisions
----------------

These decisions were made during the Phase 4 design review:

1. **State management: Riverpod.** Use `flutter_riverpod` for all app state.
   `StateNotifierProvider` for mutable state (settings, evaluation results),
   plain `Provider` for singletons (parser instance).  Riverpod's
   `ProviderScope` overrides make widget testing straightforward.

2. **Persistence: SharedPreferences.** Use `shared_preferences` for user
   settings (precision, notation, dark mode, evaluation mode).  Simple
   key-value storage is sufficient for this phase.  No database needed yet.

3. **Navigation: Drawer.** Hamburger menu with entries for Freeform (active),
   Worksheet (disabled/grayed, Phase 5), and Settings (navigates to settings
   screen).  Provides room for future modes without cluttering the UI.

4. **Evaluation mode: Configurable.** Both real-time (as-you-type with 500ms
   debounce) and on-submit (Enter key or button) modes.  User selects in
   settings.  Default: real-time.

5. **Two-field conversion.** Input expression field and output unit field.
   When only input is provided, result displays in base SI units.  When both
   are provided and conformable, result displays the converted value in the
   output units.

6. **Result display: Converted value only.** For two-expression conversion,
   show the converted value with the output unit label (e.g., `8.04672 km`).
   Future enhancement: configurable display modes (GNU Units-style factor +
   reciprocal, etc.).

7. **Result formatting: Value + canonical unit string.** Use
   `Dimension.canonicalRepresentation()` for the unit portion.  Respect
   precision and notation settings.  For conversions, use the user's output
   expression text as the unit label instead of the canonical representation.

8. **Dark mode: Three-state.** `null` = follow system (default), `true` =
   always dark, `false` = always light.  Maps to Flutter's `ThemeMode.system`,
   `.dark`, `.light`.

9. **Default precision: 6 decimal places.** Configurable from 2 to 10.

10. **No new dependencies beyond Riverpod and SharedPreferences.** Keep the
    dependency footprint minimal.

---


Freeform Mode Behavior
-----------------------

### Single Expression Evaluation

When the user enters an expression in the input field with no output
expression:

1. Parse and evaluate the input expression via `ExpressionParser.evaluate()`.
2. The result is a `Quantity` with a value and dimension in base SI units.
3. Format the value according to precision and notation settings.
4. Append the canonical dimension representation.
5. Display: e.g., `1609.344 m` for input `1 mile`.

### Two-Expression Conversion

When the user enters expressions in both input and output fields:

1. Parse and evaluate both expressions.
2. Check conformability: both must have the same dimension.
3. If conformable: converted value = `inputQty.value / outputQty.value`.
4. Display the converted value followed by the output expression text as the
   unit label: e.g., input `5 miles`, output `km` → `8.04672 km`.
5. If not conformable: display a dimension mismatch error.

### Error Handling

- Empty input: show idle/placeholder state ("Enter an expression").
- Parse/evaluation errors: show the exception message with an error indicator.
- Dimension mismatch in conversion: show a specific error message.
- Errors are non-blocking: they don't clear the previous valid result until
  the user types something new.

### Debouncing (Real-time Mode)

- On each keystroke, cancel any pending evaluation timer.
- Start a new 500ms timer.
- When the timer fires, evaluate the current input.
- This prevents evaluating incomplete expressions mid-typing.

---


Settings
--------

### User Settings Model

| Setting          | Type             | Default    | Range/Values                           |
|------------------|------------------|------------|----------------------------------------|
| `precision`      | `int`            | 6          | 2-10                                   |
| `notation`       | `Notation` enum  | `decimal`  | `decimal`, `scientific`, `engineering` |
| `darkMode`       | `bool?`          | `null`     | `null` (system), `true`, `false`       |
| `evaluationMode` | `EvaluationMode` | `realtime` | `realtime`, `onSubmit`                 |

### Settings Screen Layout

1. **Display** section:
   - Decimal precision: dropdown (2-10)
   - Number notation: dropdown (decimal, scientific, engineering)

2. **Appearance** section:
   - Dark mode: switch + "Use system theme" option

3. **Behavior** section:
   - Evaluation mode: radio buttons (real-time / on submit)

4. **About** section:
   - App version

### Persistence

Settings are saved to `SharedPreferences` as individual keys (not JSON blob)
for simplicity and forward compatibility.  On load, missing keys use defaults.

---


Result Formatting
-----------------

### Number Formatting

| Notation    | Example (value 1609.344, precision 6) | Example (value 0.000123, precision 4) |
|-------------|---------------------------------------|---------------------------------------|
| Decimal     | `1609.344`                            | `0.0001`                              |
| Scientific  | `1.609344e+3`                         | `1.2300e-4`                           |
| Engineering | `1.609344e+3`                         | `123.0000e-6`                         |

### Special Cases

- Zero: always `0` regardless of notation.
- Infinity: display `Infinity` or `-Infinity`.
- Dimensionless: show value only, no unit string.
- Very small values in decimal notation: use full decimal representation
  (don't auto-switch to scientific).

### Unit String

- Single expression: `Dimension.canonicalRepresentation()` (e.g., `m`,
  `kg m / s^2`).
- Two-expression conversion: the user's output field text, trimmed.

---


App Structure
-------------

### Navigation

~~~~
HomeScreen (Scaffold)
├── AppBar: "Unitary"
├── Drawer
│   ├── DrawerHeader: app name/version
│   ├── Freeform (selected, current)
│   ├── Worksheet (disabled, Phase 5)
│   ├── Divider
│   └── Settings (navigates to SettingsScreen)
└── Body: FreeformScreen
~~~~

### Freeform Screen Layout

~~~~
FreeformScreen (Column, scrollable)
├── Input TextField
│   ├── Label: "Convert from"
│   ├── Hint: "5 miles + 3 km"
│   ├── OutlineInputBorder
│   └── onChanged / onSubmitted handlers
├── SizedBox(height: 16)
├── Output TextField
│   ├── Label: "Convert to (optional)"
│   ├── Hint: "feet"
│   ├── OutlineInputBorder
│   └── onChanged / onSubmitted handlers
├── SizedBox(height: 24)
├── ResultDisplay widget
│   ├── Idle: gray text "Enter an expression"
│   ├── Success: primary-colored result text
│   ├── Conversion: primary-colored converted value
│   └── Error: error-colored icon + message
├── SizedBox(height: 16)
└── [On-submit mode only] ElevatedButton "Evaluate"
~~~~

Clear button: in the input field's `suffixIcon`, not a separate button.

---


Implementation Steps
--------------------

### Step 1: Add Dependencies

**Modified file:** `pubspec.yaml`

Add `flutter_riverpod` and `shared_preferences` to dependencies.  Run
`flutter pub get`.

### Step 2: Settings Model

**New file:** `lib/features/settings/models/user_settings.dart`

`Notation` enum (`decimal`, `scientific`, `engineering`).
`EvaluationMode` enum (`realtime`, `onSubmit`).
`UserSettings` immutable class with `precision`, `notation`, `darkMode`,
`evaluationMode`.  Constructor validates precision is in 2-10 range.
`copyWith` method for immutable updates.  `defaults()` factory.

**Tests:** `test/features/settings/models/user_settings_test.dart`

- Default construction.
- copyWith produces new instance with changed field.
- Precision validation (rejects < 2 or > 10).
- Equality and toString.

### Step 3: Quantity Formatter

**New file:** `lib/shared/utils/quantity_formatter.dart`

`formatQuantity(Quantity, {int precision, Notation notation})` → `String`.
Formats the numeric value per notation and precision, appends canonical
dimension string if not dimensionless.

`formatValue(double, {int precision, Notation notation})` → `String`.
Formats just the number.  Handles zero, infinity, engineering notation
(exponent must be multiple of 3).

**Tests:** `test/shared/utils/quantity_formatter_test.dart`

- Decimal notation at various precisions.
- Scientific notation formatting.
- Engineering notation (exponent divisible by 3).
- Dimensionless quantities (no unit suffix).
- Various dimensions (m, kg m / s^2).
- Edge cases: zero, infinity, negative infinity.

**Reuses:** `Quantity` (`lib/core/domain/models/quantity.dart`),
`Dimension.canonicalRepresentation()` (`lib/core/domain/models/dimension.dart`)

### Step 4: Settings Repository

**New file:** `lib/features/settings/data/settings_repository.dart`

`SettingsRepository` with `SharedPreferences` dependency.  `load()` reads
individual keys with defaults for missing keys.  `save(UserSettings)` writes
all keys.

**Tests:** `test/features/settings/data/settings_repository_test.dart`

- Save and load round-trip.
- Load with no saved data returns defaults.
- Load with partial data fills in defaults for missing keys.

### Step 5: Settings Provider

**New file:** `lib/features/settings/state/settings_provider.dart`

`settingsRepositoryProvider` — `Provider<SettingsRepository>`.
`settingsProvider` — `StateNotifierProvider<SettingsNotifier, UserSettings>`.

`SettingsNotifier` extends `StateNotifier<UserSettings>`.  Loads from
repository on init.  Exposes typed update methods: `updatePrecision(int)`,
`updateNotation(Notation)`, `updateDarkMode(bool?)`,
`updateEvaluationMode(EvaluationMode)`.  Each method updates state and
persists.

**Tests:** `test/features/settings/state/settings_provider_test.dart`

- Initial state is defaults.
- Each update method changes state.
- Updates trigger persistence (mock repository).

### Step 6: Parser Provider

**New file:** `lib/features/freeform/state/parser_provider.dart`

`parserProvider` — `Provider<ExpressionParser>` that creates a singleton
`ExpressionParser(repo: UnitRepository.withBuiltinUnits())`.

**Tests:** `test/features/freeform/state/parser_provider_test.dart`

- Provider creates a functional parser.
- Parser can evaluate expressions with units.

**Reuses:** `ExpressionParser` (`lib/core/domain/parser/expression_parser.dart`),
`UnitRepository.withBuiltinUnits()` (`lib/core/domain/models/unit_repository.dart`)

### Step 7: Freeform State and Provider

**New file:** `lib/features/freeform/state/freeform_state.dart`

Sealed class `EvaluationResult` with variants:

- `EvaluationIdle` — no input yet.
- `EvaluationSuccess(Quantity result, String formattedResult)` — single
  expression evaluated successfully.
- `ConversionSuccess(double convertedValue, String formattedResult,
  String outputUnit)` — two-expression conversion succeeded.
- `EvaluationError(String message)` — evaluation failed.

**New file:** `lib/features/freeform/state/freeform_provider.dart`

`freeformProvider` — `StateNotifierProvider<FreeformNotifier, EvaluationResult>`.

`FreeformNotifier` methods:

- `evaluateSingle(String input)`: parse, evaluate, format, update state.
- `evaluateConversion(String input, String output)`: parse both, check
  conformability, compute converted value, format, update state.
- `clear()`: reset to `EvaluationIdle`.

Catches `UnitaryException` subtypes, extracts message for `EvaluationError`.

**Tests:** `test/features/freeform/state/freeform_provider_test.dart`

- Single expression success (`5 ft` → formatted result in meters).
- Conversion success (`5 miles` + `km` → converted value).
- Parse error → EvaluationError with message.
- Dimension mismatch → EvaluationError.
- Clear → EvaluationIdle.
- Empty input → EvaluationIdle.

**Reuses:** `UnitaryException` hierarchy (`lib/core/domain/errors.dart`)

### Step 8: Wire Riverpod into App

**Modified files:** `lib/main.dart`, `lib/app.dart`, `test/widget_test.dart`

`main.dart`: wrap `UnitaryApp` in `ProviderScope`.

`app.dart`: change `UnitaryApp` from `StatelessWidget` to `ConsumerWidget`.
Watch `settingsProvider` for `darkMode` to determine `themeMode`.  Set `home`
to `HomeScreen` (new, Step 11).

`widget_test.dart`: wrap in `ProviderScope` for existing test.

### Step 9: Result Display Widget

**New file:** `lib/features/freeform/presentation/widgets/result_display.dart`

`ResultDisplay` — `StatelessWidget` taking an `EvaluationResult`.  Uses
Dart 3 `switch` expression on the sealed class.  Visual states:

- Idle: muted text, neutral border.
- Success/Conversion: result text in primary color, primary border.
- Error: error icon + message in error color, error border.

Container with `OutlineInputBorder`-style decoration to match the text fields.

**Tests:** `test/features/freeform/presentation/widgets/result_display_test.dart`

- Renders idle placeholder text.
- Renders success result text.
- Renders conversion result.
- Renders error with icon.
- Correct color theming for each state.

### Step 10: Freeform Screen

**New file:** `lib/features/freeform/presentation/freeform_screen.dart`

`FreeformScreen` — `ConsumerStatefulWidget`.  Manages two
`TextEditingController`s and a debounce `Timer`.

- Input field: `onChanged` triggers debounced evaluation in real-time mode,
  `onSubmitted` triggers immediate evaluation.  `suffixIcon` clear button
  (visible when text is non-empty).
- Output field: same debounce/submit behavior.
- `ResultDisplay` widget below the fields.
- In on-submit mode: `ElevatedButton` "Evaluate" below the result display.

Evaluation logic:

- If input is empty → clear.
- If input non-empty, output empty → `evaluateSingle`.
- If both non-empty → `evaluateConversion`.

**Tests:** `test/features/freeform/presentation/freeform_screen_test.dart`

- Renders input and output fields.
- Typing in real-time mode triggers debounced evaluation.
- Typing in on-submit mode does not trigger evaluation.
- Submit button appears only in on-submit mode.
- Clear button clears fields and result.
- Enter key triggers evaluation in both modes.

### Step 11: Settings Screen

**New file:** `lib/features/settings/presentation/settings_screen.dart`

`SettingsScreen` — `ConsumerWidget`.  `Scaffold` with `AppBar` title
"Settings" and `ListView` body.  Sections:

- Display: precision dropdown, notation dropdown.
- Appearance: dark mode switch with "Use system theme" toggle.
- Behavior: evaluation mode radio buttons.
- About: app version.

**Tests:** `test/features/settings/presentation/settings_screen_test.dart`

- Renders all settings controls.
- Changing precision updates provider state.
- Changing notation updates provider state.
- Dark mode toggle works.
- System theme toggle works.
- Evaluation mode selection works.

### Step 12: Home Screen with Drawer

**New file:** `lib/features/freeform/presentation/home_screen.dart`

`HomeScreen` — `StatelessWidget`.  `Scaffold` with:

- `AppBar` titled "Unitary".
- `Drawer` with header, Freeform (selected), Worksheet (disabled), divider,
  Settings.
- Body: `FreeformScreen`.

Settings tap: close drawer, push `SettingsScreen` via `Navigator.push`.
Worksheet tap: no-op (disabled, visually grayed out).

**Tests:** `test/features/freeform/presentation/home_screen_test.dart`

- Renders app bar with title.
- Drawer opens with hamburger icon.
- Drawer contains Freeform, Worksheet, Settings entries.
- Worksheet entry is disabled.
- Settings tap navigates to SettingsScreen.

### Step 13: Integration Tests

**New file:** `test/features/freeform/freeform_integration_test.dart`

End-to-end widget tests using `ProviderScope` with mock repository:

- Type `5 ft` → result shows value in meters.
- Type `5 miles` in input, `km` in output → shows converted value.
- Type `5 ft + 3 kg` → shows dimension error.
- Type invalid syntax → shows parse error.
- Change precision in settings → result formatting updates.
- Toggle dark mode → theme changes.
- Switch to on-submit mode → typing no longer auto-evaluates.

### Step 14: Documentation Updates

- Update `README.md`: current phase, progress checklist.
- Update `doc/design_progress.md`: mark Phase 4 UI items as discussed.
- Update `doc/implementation_plan.md`: mark Phase 4 tasks with [x], add
  completion date and test count.

---


File Summary
------------

### New Production Files (12)

| File                                                             | Contents                                     |
|------------------------------------------------------------------|----------------------------------------------|
| `lib/features/settings/models/user_settings.dart`                | `UserSettings`, `Notation`, `EvaluationMode` |
| `lib/features/settings/data/settings_repository.dart`            | `SettingsRepository` (SharedPreferences)     |
| `lib/features/settings/state/settings_provider.dart`             | Riverpod providers for settings              |
| `lib/features/settings/presentation/settings_screen.dart`        | Settings UI                                  |
| `lib/features/freeform/state/parser_provider.dart`               | Parser singleton provider                    |
| `lib/features/freeform/state/freeform_state.dart`                | `EvaluationResult` sealed class              |
| `lib/features/freeform/state/freeform_provider.dart`             | `FreeformNotifier` provider                  |
| `lib/features/freeform/presentation/home_screen.dart`            | Home screen with drawer                      |
| `lib/features/freeform/presentation/freeform_screen.dart`        | Freeform evaluation UI                       |
| `lib/features/freeform/presentation/widgets/result_display.dart` | Result/error display widget                  |
| `lib/shared/utils/quantity_formatter.dart`                       | Quantity formatting utility                  |

### Modified Production Files (3)

| File            | Changes                                                           |
|-----------------|-------------------------------------------------------------------|
| `pubspec.yaml`  | Add `flutter_riverpod`, `shared_preferences`                      |
| `lib/main.dart` | Wrap in `ProviderScope`                                           |
| `lib/app.dart`  | `ConsumerWidget`, watch settings for theme, route to `HomeScreen` |

### New Test Files (11)

| File                                                                   | Contents              |
|------------------------------------------------------------------------|-----------------------|
| `test/features/settings/models/user_settings_test.dart`                | Settings model tests  |
| `test/features/settings/data/settings_repository_test.dart`            | Repository tests      |
| `test/features/settings/state/settings_provider_test.dart`             | Provider tests        |
| `test/features/settings/presentation/settings_screen_test.dart`        | Settings UI tests     |
| `test/features/freeform/state/parser_provider_test.dart`               | Parser provider tests |
| `test/features/freeform/state/freeform_state_test.dart`                | State class tests     |
| `test/features/freeform/state/freeform_provider_test.dart`             | Notifier tests        |
| `test/features/freeform/presentation/home_screen_test.dart`            | Home screen tests     |
| `test/features/freeform/presentation/freeform_screen_test.dart`        | Freeform screen tests |
| `test/features/freeform/presentation/widgets/result_display_test.dart` | Result widget tests   |
| `test/features/freeform/freeform_integration_test.dart`                | End-to-end tests      |

### Modified Test Files (1)

| File                    | Changes                 |
|-------------------------|-------------------------|
| `test/widget_test.dart` | Wrap in `ProviderScope` |

---


Implementation Order
--------------------

Each step's tests should be written and passing before proceeding to the next:

1. **Add dependencies** (foundation for everything else)
2. **Settings model** (no dependencies on other new code)
3. **Quantity formatter** (depends on settings model for types)
4. **Settings repository** (depends on settings model)
5. **Settings provider** (depends on model + repository)
6. **Parser provider** (no dependencies on other new code)
7. **Freeform state + provider** (depends on parser provider, formatter)
8. **Wire Riverpod into app** (depends on settings provider)
9. **Result display widget** (depends on freeform state)
10. **Freeform screen** (depends on freeform provider, result display)
11. **Settings screen** (depends on settings provider)
12. **Home screen with drawer** (depends on freeform screen, settings screen)
13. **Integration tests** (depends on all above)
14. **Documentation updates** (after everything works)

---


Risks and Mitigations
---------------------

### Risk 1: Riverpod learning curve

**Scenario:** Unfamiliarity with Riverpod patterns slows development.

**Mitigation:** Use simple patterns only (Provider, StateNotifierProvider).
No AsyncNotifierProvider, no family modifiers, no code generation.  Riverpod
2.x has good documentation and examples.

### Risk 2: SharedPreferences async initialization

**Scenario:** Settings aren't loaded before the first frame renders.

**Mitigation:** Initialize with defaults synchronously.  Load persisted
settings async and update state when ready.  The brief flash of defaults is
acceptable — the user likely won't notice since defaults are reasonable.

### Risk 3: Debounce timer and widget lifecycle

**Scenario:** Timer fires after widget disposal, causing errors.

**Mitigation:** Cancel timer in `dispose()`.  Check `mounted` before updating
state if using raw setState (not needed with Riverpod notifiers since they
handle this).

### Risk 4: Engineering notation implementation

**Scenario:** Engineering notation (exponent must be multiple of 3) is
non-trivial to implement correctly.

**Mitigation:** Implement as a separate utility function with thorough tests.
Use `log10` to determine the appropriate exponent, then adjust mantissa
accordingly.

---


Open Decisions for Phase 5
---------------------------

- Worksheet data model and state management.
- How worksheets interact with the same parser/unit infrastructure.
- Whether worksheets share settings (precision, notation) with freeform mode
  or have independent settings.
- Navigation state management (which mode is active).
- Whether to add conversion history in Phase 5 or later.

---

*This document captures all design decisions and implementation details for
Phase 4 as agreed during the design review session of February 16, 2026.*
