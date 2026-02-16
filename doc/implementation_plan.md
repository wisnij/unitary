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
- [x] Create new Flutter project (`flutter create`, org `com.wisnij`, version 0.1.0+1)
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

**Detailed Plan:** See [Phase 2 Plan](phase2_plan.md)

---

### Phase 3: Advanced Unit Features (Weeks 8-9) — COMPLETE

**Goals:** Complex conversions and functions

**Tasks:**

- [x] Implement AffineDefinition for offset conversions (temperature)
- [x] Implement ConstantDefinition for physical constants
- [x] Implement CompoundDefinition for derived units
- [x] Add all 7 SI base unit primitives (m, kg, s, K, A, mol, cd)
- [x] Add temperature units (degK/tempK, degC/tempC, degF/tempF, degR/tempR)
- [x] Add physical constants (pi, euler, tau, c, gravity, h, N_A, k_B, e, R)
- [x] Add compound units (N, Pa, J, W, Hz, C, V, ohm, F, Wb, T, H)
- [x] Integrate affine syntax with parser (tempF(212) required, 212 tempF rejected)
- [x] Add AffineUnitNode evaluation
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
   - Dimension navigation

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
3. Organize into dimensions
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

### Phase 15: Rational Number Support

- Implement exact rational arithmetic
- Convert from decimal to rational where beneficial
- UI for displaying rational results

### Future: Unit Resolution Caching

- Cache the resulting base-unit Quantity the first time a unit is fully reduced
  during evaluation, so subsequent evaluations skip the resolution chain
- Invalidate the cache whenever unit definitions are added or edited (expected
  to be infrequent, so the cache should remain valid for long periods)
- Explore pre-warming the cache for all registered units as a background task
  at initial app startup and after definition edits, to minimize user-visible
  processing time

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
- ✓ App size <50MB

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
- Play Store publication (optional)

**Code Quality:**

- Refactoring of technical debt from MVP
- Performance optimizations based on profiling
- Accessibility improvements
- Comprehensive test coverage (>90%)

---

*This plan is a living document and will be updated as the project progresses and priorities shift.*
