Unitary - Core Architecture
===========================

This document describes the core technical architecture of Unitary, including data models, the expression parser/evaluator, and key subsystems.

For terminology definitions, see [Terminology](terminology.md).
For implementation planning, see [Implementation Plan](implementation_plan.md).
For development practices, see [Development Best Practices](dev_best_practices.md).

---


Technology Stack Recommendation
-------------------------------

### Framework: Flutter

**Rationale:**

- Single codebase for Android and iOS
- Dart language similar to Kotlin (easier learning curve)
- Excellent performance (compiled to native code)
- Material Design built-in with regular updates
- Strong state management options
- Good offline-first capabilities
- Active community and extensive packages

**Alternatives Considered:**

- Native Kotlin (Android only) - limits iOS support
- React Native - ruled out per preference to avoid JS/TS
- Kotlin Multiplatform Mobile - still maturing, more complex setup

### Core Dependencies

- **Flutter SDK** (latest stable)
- **sqflite** or **hive** - local database for persistence
- **shared_preferences** - simple key-value storage
- **http** or **dio** - HTTP client for currency rates
- **intl** - internationalization and number formatting
- **provider** or **riverpod** - state management


Architecture Overview
---------------------

### Layered Architecture

~~~~
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│  (UI Widgets, Screens, View Models)     │
└─────────────────────────────────────────┘
              ↕
┌─────────────────────────────────────────┐
│        Business Logic Layer             │
│  (Services, Use Cases, Validators)      │
└─────────────────────────────────────────┘
              ↕
┌─────────────────────────────────────────┐
│           Core Domain Layer             │
│  (Models, Expression Parser, Calculator)│
└─────────────────────────────────────────┘
              ↕
┌─────────────────────────────────────────┐
│           Data Layer                    │
│  (Repositories, Local DB, Preferences)  │
└─────────────────────────────────────────┘
~~~~


Core Components Design
----------------------

### 1. Expression Parser & Evaluator

**Component Structure:**

~~~~
Lexer → Parser → AST Builder → Evaluator
  ↓       ↓          ↓            ↓
Token   AST      Validated     Result
Stream  Nodes    Expression   + Units
~~~~

**Token Types:**

Token types include: `number` (3.14, 1.5e-10, .5), `identifier` (unit names
and constants), operators (`plus`, `minus`, `times`, `divide`, `divideNum`,
`exponent`), grouping (`leftParen`, `rightParen`, `comma`), and `eof`.  Each
token carries its type, lexeme text, optional parsed literal value, and
line/column for error reporting.

**Lexer (Tokenizer):**

- Converts input string into token stream
- Recognizes: numbers, units, operators, functions, parentheses
- Handles various multiplication/division symbols
- Tracks line and column numbers for detailed error reporting
- Support for unit aliases with automatic plural handling:
  - Try exact match with unit id and aliases first
  - If no match, try removing common plural suffixes ("s", "es") and check again
  - This allows "meter", "meters", "metre", "metres" to all match without storing each variant
- Support for unit prefixes:
  - When parsing a potential unit name, try to split it into prefix + unit name
  - Check all possible prefix positions (e.g., "km" → "k" + "m", "mega" + "meter")
  - Prefixes can be attached with no space: "km", "megameter", "MHz"
  - Examples: "km" → kilo *meter, "MW" → mega* watt, "ns" → nano * second
- Implicit multiplication handling:
  - "5m" (no space) treated as "5 * m"
  - Space between number/unit and number/unit also implies multiplication
  - After closing paren before opening paren: ")()" implies multiplication
- Number parsing:
  - Supports integers: 5, 42
  - Supports decimals: 3.14, 0.5
  - Supports leading decimal point: .5, .25
  - Supports scientific notation: 1.5e-10, 3e8
- Physical constants are just defined units (e.g., "c" = 299792458 m/s)

**Parser:**

- Builds Abstract Syntax Tree (AST) from tokens
- Implements operator precedence (lowest to highest):
  1. Addition/Subtraction (+, -)
  2. Low-precedence multiplication and division (*, ×, ⋅, /, ÷)
  3. High-precedence multiplication (space, or implicit multiplication with no space)
  4. Exponentiation (^) - right-associative
  5. High-precedence division (|) - operands are numeric literals only, no units allowed
  6. Unary (+, -)
  7. Function calls
  8. Primary (numbers, units, parentheses)
- Handles implicit multiplication
- Error recovery and reporting with line/column information
- Unit tests for parsing

**AST Node Types:**

- `NumberNode` — numeric literal
- `UnitNode` — unit identifier (resolved via UnitRepository at evaluation time)
- `BinaryOpNode` — binary operators (+, -, *, /, ^) including implicit multiplication
- `UnaryOpNode` — unary minus
- `FunctionNode` — built-in functions (sin, cos, sqrt, etc.) and affine units (tempF, tempC)

**Evaluator:**

- Traverses AST and computes result
- Performs dimensional analysis
- Returns `Quantity` objects with value and dimension

### 2. Unit System & Dimensional Analysis

**Dimension Model:**

`Dimension` represents a physical dimension as a map from primitive unit IDs to
integer exponents.  For example, velocity is `{m: 1, s: -1}` and force is
`{kg: 1, m: 1, s: -2}`.  A dimensionless quantity has an empty map.

Operations:

- `multiply(other)` — adds exponents (for multiplication)
- `divide(other)` — subtracts exponents (for division)
- `power(n)` — multiplies all exponents by n
- `powerRational(r)` — multiplies by rational exponent, validates divisibility
- `isConformableWith(other)` — checks dimensional equality
- `canonicalRepresentation()` — human-readable string like `kg m / s^2`

Zero exponents are stripped automatically.  Two dimensions are equal iff they
have the same unit-exponent pairs.

**DimensionRegistry** (planned for UI) maps dimensions to human-readable
category names (e.g., `{m: 1, s: -2}` → "Acceleration").

**Prefix Support:**

Unit prefixes (kilo, mega, milli, etc.) are implemented as `PrefixUnit`
instances, a subclass of `CompoundUnit` with `isPrefix => true`.  Prefixes are
stored separately in `UnitRepository` via `registerPrefix()`, so prefix symbols
(like `m` for milli) can coexist with regular unit IDs (like `m` for meter).

The `findUnitWithPrefix(name)` method resolves names using this priority order:

1. Exact match in regular units (including plural stripping)
2. Prefix splitting — longest prefix first, remainder looked up as a regular
   unit (with plural stripping)
3. Standalone prefix match (prefix name with no remainder)
4. No match → returns empty `UnitMatch`

This means standalone `"m"` resolves to meter (step 1), while `"mm"` splits
into milli + meter (step 2).  All 24 SI prefixes from quecto (10^-30) to
quetta (10^30) are registered.

**Unit Model:**

Each `Unit` has a primary `id`, a list of `aliases`, and a `description`.
The `allNames` getter returns id + aliases.  Plural forms (trailing "s", "es",
"ies") are handled automatically by the repository's plural stripping, so only
irregular plurals (like "feet" for "foot") need to be listed as explicit aliases.

Unit subclasses define how units convert to primitive base units:

- **`PrimitiveUnit`** — fundamental units that define their own dimension
  (e.g., meter → `{m: 1}`).  Optionally `isDimensionless` for units like
  radian and steradian.
- **`AffineUnit`** — units with a scale factor and offset relative to a base
  unit (e.g., tempC: `(value + 273.15) * 1.0` → kelvin).  Used for absolute
  temperature conversions.
- **`CompoundUnit`** — units defined by an expression string that is parsed
  and evaluated through the full pipeline (e.g., newton: `"kg m/s^2"`,
  mile: `"5280 ft"`).
- **`PrefixUnit`** — a `CompoundUnit` subclass for SI prefixes
  (e.g., kilo: `"1000"`, milli: `"0.001"`).

Unit resolution is handled by `resolveUnit(unit, repo)`, which returns a
`Quantity` representing 1 of that unit in primitive base units.  For compound
units, resolution evaluates the expression string through the full
lexer/parser/evaluator pipeline, which may recurse through other unit
definitions.

Examples of unit definitions:

~~~~
Primitive:  m (meter)           → Quantity(1.0, {m: 1})
Compound:   mi (mile)           → "5280 ft" → Quantity(1609.344, {m: 1})
Compound:   N (newton)          → "kg m/s^2" → Quantity(1.0, {kg: 1, m: 1, s: -2})
Affine:     tempF (Fahrenheit)  → (value - 32) * 5/9 + 273.15 K
Prefix:     kilo                → "1000" → Quantity(1000.0, dimensionless)
~~~~

**Quantity Model:**

`Quantity` represents a physical quantity: a numeric `value` (double) combined
with a `Dimension`.  All arithmetic operations maintain dimensional consistency:

- `add`/`subtract` — requires conformable dimensions, throws `DimensionException` if not
- `multiply`/`divide` — combines dimensions (adds/subtracts exponents)
- `power(exponent)` — for dimensioned quantities, requires rational exponent with
  integer-valued result dimensions; uses continued fractions to recover rational
  approximation from double exponents
- `negate`/`abs` — preserves dimension

NaN values are rejected at construction time (fail-fast).  Division by zero
throws `EvalException`.

### 3. Unit Database

**Data Source:**

- Import GNU Units database definitions
- Parse into internal format
- Store in embedded database (asset bundle)

**Database Schema (planned):**

Currently units are registered via hand-curated Dart code in
`registerBuiltinUnits()`.  For future persistence, the database would include
tables for units (with definition type and parameters), unit aliases, prefixes,
prefix aliases, dimension metadata (for UI category names), constants, and
custom user-defined units.  Plurals are handled automatically at parse time and
not stored.

### 4. Worksheet System

**Worksheet Model (planned):**

A `Worksheet` has a name, category, and list of `WorksheetField`s.  Each field
references a unit and stores the last entered value.  Worksheets can be built-in
or user-customized.

**Worksheet State Management:**

- Use reactive state management (Provider/Riverpod)
- When any field changes, recalculate all others
- Persist last values to local storage
- Load on app startup

### 5. Currency Rate Management

**Currency Service (planned):**

A `CurrencyService` will handle fetching exchange rates, storing them locally,
and providing rate lookups.  It tracks last update time and auto-refreshes when
stale.

**Rate Storage:**

- Store in local database with timestamp
- Ship with initial rates in assets
- Background refresh on app launch
- Manual refresh trigger in UI

**API Integration:**

- Configurable endpoint (future)
- Retry logic with exponential backoff
- Graceful failure handling
- Rate limiting respect


State Management Strategy
-------------------------

### Global State (Provider/Riverpod)

- User preferences (precision, notation, theme)
- Current conversion mode (freeform/worksheet)
- Active worksheet
- Currency rates
- Custom unit definitions

### Local State

- Individual field values
- Input validation errors
- UI ephemeral state (dropdowns, dialogs)

### Persistence Layer (planned)

Repositories for preferences (key-value), worksheets (load/save with field
values), and custom units (user-defined units with persistence).  Currently
the unit repository is in-memory only.


Implementation Phases
---------------------

### Phase 0: Project Setup (Week 1)

**Goals:** Development environment and project scaffolding

**Tasks:**

- Install Flutter SDK and Android Studio
- Create new Flutter project
- Set up version control (Git/GitHub)
- Configure project structure
- Set up linting and code formatting
- Create README with project overview

**Deliverable:** Empty Flutter app that runs on Android emulator

---

### Phase 1: Core Domain - Expression Parser (Weeks 2-4)

**Goals:** Build the expression parsing and evaluation engine

**Tasks:**

1. Implement Lexer
   - Token types definition
   - Character-by-character scanning
   - Number parsing (decimals, scientific notation)
   - Operator recognition
   - Unit name recognition
   - Test with various inputs

2. Implement Parser
   - AST node classes
   - Recursive descent parser
   - Operator precedence handling
   - Error recovery and reporting
   - Unit tests for parsing

3. Implement basic Evaluator
   - Number arithmetic
   - Basic operators (+, -, *, /, ^)
   - Unit tests for evaluation

**Deliverable:** Parser that converts "5 * 3 + 2" → correct result

---

### Phase 2: Unit System Foundation (Weeks 5-7)

**Goals:** Dimension system and unit definitions

**Tasks:**

1. Implement Dimension class
   - Base dimension representation
   - Dimensional arithmetic
   - Compatibility checking
   - Comprehensive unit tests

2. Implement Unit and Quantity classes
   - Linear conversion definitions
   - Quantity arithmetic with dimensional analysis
   - Unit tests for conversions

3. Parse GNU Units database
   - Write parser for GNU Units format
   - Extract basic units (length, mass, time)
   - Convert to internal JSON format
   - Store as asset

4. Implement UnitRepository
   - Load units from assets
   - Unit lookup by name/alias
   - Category filtering

**Deliverable:** Can convert "5 feet" to meters programmatically

---

### Phase 3: Advanced Unit Features (Weeks 8-9)

**Goals:** Complex conversions and functions

**Tasks:**

1. Implement offset conversions (temperature)
2. Implement compound units (Newton, Pascal, etc.)
3. Add mathematical functions (sqrt, etc.)
4. Add trigonometric functions
5. Add constants (pi, e, c, etc.)
6. Integrate with parser/evaluator
7. Comprehensive testing

**Deliverable:** Can evaluate "sqrt(9 m^2) + 5 ft" correctly

---

### Phase 4: Basic UI - Freeform Mode (Weeks 10-12)

**Goals:** First working UI for expression evaluation

**Tasks:**

1. Create app structure
   - Main navigation
   - Freeform input screen
   - Material Design theme
   - Dark mode support

2. Build freeform input UI
   - Input text field
   - Output text field (optional)
   - Result display
   - Error display
   - Real-time evaluation

3. Integrate parser with UI
   - Connect input to parser
   - Display results
   - Handle errors gracefully

4. Settings screen (basic)
   - Precision selector
   - Notation selector
   - Dark mode toggle

**Deliverable:** Working app that evaluates expressions in freeform mode

---

### Phase 5: Worksheet Mode (Weeks 13-15)

**Goals:** Multi-unit worksheet interface

**Tasks:**

1. Implement Worksheet domain model
2. Create worksheet UI components
   - Multi-field input grid
   - Unit selectors per field
   - Real-time updates

3. Build worksheet management
   - Load pre-defined worksheets
   - Switch between worksheets
   - Category navigation

4. Implement state management
   - Reactive updates across fields
   - Input validation
   - Error handling

**Deliverable:** Worksheet mode functional with pre-defined worksheets

---

### Phase 6: Persistence (Weeks 16-17)

**Goals:** Save user data and preferences

**Tasks:**

1. Set up local database (sqflite)
2. Implement PreferencesRepository
3. Implement WorksheetRepository
4. Add persistence for:
   - User preferences
   - Worksheet last values
   - Favorite units

5. Restore state on app launch
6. Test save/load cycle

**Deliverable:** App remembers settings and worksheet values between sessions

---

### Phase 7: Currency Support (Weeks 18-19)

**Goals:** Currency conversion with live rates

**Tasks:**

1. Choose and integrate currency rate API
2. Implement CurrencyService
3. Add currency rate storage
4. Ship default rates in assets
5. Auto-update logic (24hr check)
6. Manual refresh UI
7. Display last update timestamp
8. Handle offline gracefully

**Deliverable:** Currency conversions work with auto-updating rates

---

### Phase 8: Complete Unit Database (Week 20-21)

**Goals:** Import all unit categories

**Tasks:**

1. Complete GNU Units database import
   - All categories from requirements
   - Verify accuracy of conversions

2. Add unit aliases and plurals
3. Organize into categories
4. Test coverage for all categories

**Deliverable:** All required unit categories available

---

### Phase 9: Polish & Testing (Weeks 22-24)

**Goals:** Production-ready quality

**Tasks:**

1. UI/UX refinement
   - Responsive layouts
   - Tablet support
   - Accessibility improvements

2. Performance optimization
   - Parser performance tuning
   - UI rendering optimization
   - Memory usage analysis

3. Comprehensive testing
   - Integration tests
   - Widget tests
   - Manual testing on real devices

4. Bug fixes
5. Documentation
   - Code documentation
   - User guide (README)
   - Contributing guidelines

**Deliverable:** MVP ready for release

---

### Phase 10: Release (Week 25)

**Goals:** Publish to GitHub and Play Store

**Tasks:**

1. Create app icon and branding
2. Prepare Play Store assets
   - Screenshots
   - Description
   - Privacy policy

3. Build release APK/AAB
4. Set up GitHub repository
   - Clean up code
   - Add license
   - Polish README

5. Publish to GitHub
6. Submit to Play Store (optional)

**Deliverable:** Public MVP release

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
- Worksheet sharing (export/import)

### Phase 13: iOS Support

- Test on iOS simulator
- iOS-specific UI adjustments
- Submit to App Store

### Phase 14: Advanced Features

- Equation solver
- Graphing
- Additional functions
- More mathematical constants

---


Development Best Practices
--------------------------

### Code Organization

~~~~
lib/
├── main.dart
├── app.dart
├── core/
│   ├── domain/
│   │   ├── models/
│   │   │   ├── dimension.dart
│   │   │   ├── unit.dart
│   │   │   ├── quantity.dart
│   │   │   └── worksheet.dart
│   │   ├── parser/
│   │   │   ├── lexer.dart
│   │   │   ├── parser.dart
│   │   │   ├── ast.dart
│   │   │   └── evaluator.dart
│   │   └── services/
│   │       ├── currency_service.dart
│   │       └── unit_service.dart
│   └── data/
│       ├── repositories/
│       ├── data_sources/
│       └── models/
├── features/
│   ├── freeform/
│   │   ├── presentation/
│   │   └── bloc/
│   ├── worksheet/
│   │   ├── presentation/
│   │   └── bloc/
│   └── settings/
│       ├── presentation/
│       └── bloc/
├── shared/
│   ├── widgets/
│   ├── themes/
│   └── utils/
└── assets/
    ├── units/
    └── currency/
~~~~

### Testing Strategy

- **Unit tests:** All parser, evaluator, and domain logic (>80% coverage)
- **Widget tests:** All UI components
- **Integration tests:** Key user flows
- **Manual testing:** Real devices, various screen sizes

### Version Control

- Feature branches for each phase
- Pull requests with code review (self-review)
- Semantic versioning (0.1.0 for MVP)
- Changelog maintenance

### Documentation

- Inline code comments for complex logic
- README with setup instructions
- Architecture decision records (ADRs)
- API documentation for public interfaces

---


Risk Mitigation
---------------

### Technical Risks

1. **Parser complexity too high**
   - Mitigation: Start simple, iterate, reference existing parsers

2. **Performance issues with real-time updates**
   - Mitigation: Profile early, optimize hot paths, add debouncing if needed

3. **GNU Units database parsing difficulties**
   - Mitigation: Start with subset, manual conversion if needed

### Learning Curve Risks

1. **Flutter/Dart unfamiliarity**
   - Mitigation: Official tutorials, small prototypes first, active community

2. **Mobile development patterns**
   - Mitigation: Follow official guidelines, study example apps

### Scope Creep Risks

1. **Feature bloat before MVP**
   - Mitigation: Strict phase adherence, defer enhancements

2. **Perfectionism delays**
   - Mitigation: "Good enough" for MVP, iterate post-release

---


Success Metrics
---------------

### MVP Success Criteria

- ✓ Accurate conversions for all categories
- ✓ Freeform mode handles complex expressions
- ✓ Worksheet mode supports 5+ worksheets
- ✓ Dark mode works correctly
- ✓ Settings persist across sessions
- ✓ Currency rates update automatically
- ✓ No critical bugs
- ✓ Runs smoothly on mid-range Android devices
- ✓ Published on GitHub with documentation

### Post-MVP Goals

- User feedback incorporation
- Additional worksheet templates
- Custom unit feature
- iOS support
- Play Store publication (optional)

---


Resources & References
----------------------

### Learning Resources

- Flutter documentation: <https://docs.flutter.dev>
- Dart language tour: <https://dart.dev/guides/language/language-tour>
- Material Design: <https://m3.material.io>
- GNU Units: <https://www.gnu.org/software/units/>

### Tools

- Flutter DevTools for debugging
- Android Studio / VS Code
- Git for version control
- GitHub for hosting

### Community

- Flutter Discord/Reddit for questions
- Stack Overflow for specific issues
- GitHub Issues for bug tracking
