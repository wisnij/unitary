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
- **Derived Units**: Affine and compound definitions
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
- **Unit Conversion**: Algorithm for converting between conformable units, handling chains and compound units
- **Unit Reduction**: Algorithm to express quantities in primitive units
- **Temperature Handling**: GNU Units approach with separate absolute (tempF/tempC) and difference (degF/degC) units
- **Function/Affine Syntax**: Parentheses required for functions and affine units except when standalone (definition lookup/conversion target)
- **Prefix Restrictions**: No prefixes allowed on functions or affine units
- **Error Handling**: Fail-fast approach - throw immediately on NaN-producing operations with clear messages
- **Edge Cases**: Division by zero, very large/small numbers, negative bases with fractional exponents, precision loss
- **Testing Strategy**: Comprehensive unit tests, integration tests, and property-based tests documented
- **Document**: [quantity_arithmetic_design.md](quantity_arithmetic_design.md)

### Terminology

- Comprehensive definitions of all key terms
- Consistent vocabulary established for codebase
- Clear distinctions between values, quantities, units, dimensions, etc.

---


Areas That Need More Detail
---------------------------

The following areas have been identified but need deeper design work:

### 1. Worksheet System

**Current State**: High-level requirements defined

**Needs Detail On**:

- Detailed data model for worksheets
  - Worksheet structure and fields
  - How to represent "last used values"
  - Storage format
- State update mechanism
  - When user types in one field, how do others update?
  - Handling of invalid input during typing
  - Debouncing strategy if needed
- Pre-defined worksheet templates
  - Which templates to include by default
  - Structure of template definitions
  - How users select/switch between worksheets
- User customization
  - Adding/removing units from worksheets
  - Creating new worksheets from scratch
  - Saving and loading custom worksheets
  - UI for worksheet management

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

**Current State**: List of what needs to persist, state management framework chosen (Provider/Riverpod)

**Needs Detail On**:

- Complete preference model
  - All user settings and their data types
  - Default values
  - Validation rules
- State management architecture
  - Provider/Riverpod structure and patterns
  - Which state is global vs. local
  - State update flow diagrams
- Persistence implementation
  - Storage mechanism (SharedPreferences, SQLite, Hive, etc.)
  - Serialization format
  - Read/write patterns
- Data migration
  - Strategy for schema changes between versions
  - Backwards compatibility
  - Migration testing approach
- State restoration
  - What happens on app restart
  - Handling corrupted preferences
  - Reset to defaults functionality

### 5. UI/UX Design

**Current State**: Minimalist interface, Material Design, dark mode support identified

**Needs Detail On**:

- Screen layouts and navigation
  - Main screen structure
  - Navigation between freeform and worksheet modes
  - Category/dimension browsing
  - Settings screen layout
- Freeform input UI
  - Input field design
  - Output field design
  - Error display
  - Result formatting options
  - History/suggestions
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
3. ✅ ~~**Advanced Unit Features**~~ - **COMPLETE** — Temperature, constants, compound units implemented (Phase 3)
4. **Worksheet System** - Major user-facing feature
5. **GNU Units Database Import** - Needed before implementation can begin
6. **UI/UX Design** - Should be fleshed out before coding UI
7. **State Management Details** - Needed early in implementation
8. **Currency Rate Management** - Can be added after core features work
9. **Testing Strategy** - Define before/during implementation
10. **Error Handling Details** - Refine during implementation

---


Open Questions
--------------

Questions that arose during design but haven't been resolved:

1. ~~Should we support variable-precision arithmetic, or is fixed precision acceptable?~~ → **RESOLVED**: Use `double` for MVP, rational numbers in Phase 15+
2. How should we handle very long expressions in the UI (scrolling, wrapping, etc.)?
3. Should worksheet field reordering be supported?
4. Do we need undo/redo functionality?
5. Should conversion history be searchable/filterable?
6. How many decimal places should be shown by default?
7. Should the app support landscape orientation?
8. Do we need tutorial/onboarding screens for first-time users?

---

*Last Updated: February 13, 2026*
*Design Sessions:*

- *Initial requirements gathering and core architecture*
- *Quantity Class & Arithmetic (January 30, 2026)*
- *Lexer/Parser Grammar Redesign (February 1, 2026)*
- *Phase 2: Unit System Foundation (February 6, 2026)*

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
  - AffineDefinition, CompoundDefinition (unified from Linear/Constant/Compound), SI base units, temperature, constants, affine syntax
- *Phase 3 cleanup: Removed UnitDefinition.toQuantity, decoupled models from UnitRepository (February 14, 2026)*
  - 618 tests passing (removed 25 redundant toQuantity-based tests now covered through parser/resolveUnit paths)
  - All UnitDefinition subclasses now pure const data classes; unit resolution centralized in resolveUnit()
