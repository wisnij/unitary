# Unitary - Core Architecture

This document describes the core technical architecture of Unitary, including data models, the expression parser/evaluator, and key subsystems.

For terminology definitions, see [Terminology](terminology.md).
For implementation planning, see [Implementation Plan](implementation_plan.md).
For development practices, see [Development Best Practices](dev_best_practices.md).

---

## Technology Stack Recommendation

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

## Architecture Overview

### Layered Architecture

```
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
```

## Core Components Design

### 1. Expression Parser & Evaluator

**Component Structure:**
```
Lexer → Parser → AST Builder → Evaluator
  ↓       ↓          ↓            ↓
Token   AST      Validated     Result
Stream  Nodes    Expression   + Units
```

**Token Types:**
```dart
enum TokenType {
  // Literals
  number,        // 3.14, 1.5e-10, .5
  unit,          // meter, kg, newton (includes constants like pi, c)

  // Operators
  plus,          // +
  minus,         // -
  multiply,      // *, ×, ⋅
  divide,        // /, ÷
  divideHigh,    // | (high precedence division)
  power,         // ^

  // Grouping
  leftParen,     // (
  rightParen,    // )
  comma,         // , (for function arguments)

  // Functions
  function,      // sin, cos, sqrt, etc.

  // Special
  eof,           // End of input
}

class Token {
  final TokenType type;
  final String lexeme;     // Original text
  final Object? literal;   // Parsed value (for numbers, UnitMatch for units, etc.)
  final int line;          // Line number (for error reporting)
  final int column;        // Column number (for error reporting)

  Token(this.type, this.lexeme, this.literal, this.line, this.column);
}
```

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
  - Examples: "km" → kilo * meter, "MW" → mega * watt, "ns" → nano * second
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

**Lexer Implementation Notes:**
```dart
void scanNumber() {
  // Handle leading decimal point (.5)
  if (previous() == '.' && isDigit(peek())) {
    // Already consumed '.', now get digits
    while (isDigit(peek())) advance();
  } else {
    // Regular number (integer or decimal)
    while (isDigit(peek())) advance();

    // Decimal part
    if (peek() == '.' && isDigit(peekNext())) {
      advance(); // consume '.'
      while (isDigit(peek())) advance();
    }
  }

  // Scientific notation (e.g., 1.5e-10)
  if (peek() == 'e' || peek() == 'E') {
    advance();
    if (peek() == '+' || peek() == '-') advance();
    if (!isDigit(peek())) throw LexError("Invalid scientific notation");
    while (isDigit(peek())) advance();
  }

  String numberStr = source.substring(start, current);
  addToken(TokenType.number, double.parse(numberStr));
}

void scanIdentifier() {
  // Read alphanumeric characters
  while (isAlphaNumeric(peek())) advance();

  String text = source.substring(start, current);

  // Check if it's a function
  if (isFunction(text)) {
    addToken(TokenType.function, text);
    return;
  }

  // Everything else is a unit (including physical constants)
  var unitMatch = tryParseUnit(text);
  if (unitMatch != null) {
    addToken(TokenType.unit, unitMatch);
    return;
  }

  throw LexError("Unknown identifier: $text", line, column);
}

void handleImplicitMultiply() {
  // Insert implicit multiply token when appropriate
  if (tokens.isNotEmpty) {
    var last = tokens.last;

    // Cases where we insert implicit multiply:
    // - number followed by unit: "5m"
    // - number followed by identifier: "5 x"
    // - closing paren followed by number/unit/paren: ")5", ")(", ")x"
    // - unit followed by number/unit/paren: "m 5", "m kg", "m("

    if ((last.type == TokenType.number ||
         last.type == TokenType.rightParen ||
         last.type == TokenType.unit) &&
        !isAtEnd() &&
        (isDigit(peek()) || peek() == '.' || isAlpha(peek()) || peek() == '(')) {
      // Don't insert multiply if next char starts a function call
      // (handled separately in parser)
      if (last.type == TokenType.unit && peek() == '(') {
        return; // This might be a function call, let parser handle it
      }
      addToken(TokenType.multiply);
    }
  }
}
```

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
```dart
abstract class ASTNode {
  Quantity evaluate(Context context);
}

class NumberNode extends ASTNode
class UnitNode extends ASTNode
class BinaryOpNode extends ASTNode  // +, -, *, /, ^
class UnaryOpNode extends ASTNode   // -, sqrt, etc.
class FunctionNode extends ASTNode  // sin, cos, etc.
```

**Evaluator:**
- Traverses AST and computes result
- Performs dimensional analysis
- Returns `Quantity` objects with value and dimension

### 2. Unit System & Dimensional Analysis

**Dimension Model:**
```dart
// Represents a dimension as a product of primitive units with exponents
class Dimension {
  // Map from primitive unit ID to exponent
  // e.g., {m: 1, s: -1} represents velocity
  // e.g., {m: 1, s: -2} represents acceleration
  final Map<String, num> primitiveExponents;

  // Constructor for dimensionless quantities
  Dimension.dimensionless() : primitiveExponents = {};

  // Constructor from primitive exponents
  Dimension(this.primitiveExponents);

  // Check if two dimensions are the same (for conformability check)
  bool isCompatibleWith(Dimension other) {
    if (primitiveExponents.length != other.primitiveExponents.length) return false;
    for (var entry in primitiveExponents.entries) {
      if (other.primitiveExponents[entry.key] != entry.value) return false;
    }
    return true;
  }

  // Multiply dimensions: add exponents
  Dimension multiply(Dimension other) {
    final result = Map<String, num>.from(primitiveExponents);
    for (var entry in other.primitiveExponents.entries) {
      result[entry.key] = (result[entry.key] ?? 0) + entry.value;
    }
    // Remove zero exponents
    result.removeWhere((key, value) => value == 0);
    return Dimension(result);
  }

  // Divide dimensions: subtract exponents
  Dimension divide(Dimension other) {
    final result = Map<String, num>.from(primitiveExponents);
    for (var entry in other.primitiveExponents.entries) {
      result[entry.key] = (result[entry.key] ?? 0) - entry.value;
    }
    result.removeWhere((key, value) => value == 0);
    return Dimension(result);
  }

  // Raise dimension to a power: multiply all exponents
  Dimension power(num exponent) {
    final result = <String, num>{};
    for (var entry in primitiveExponents.entries) {
      result[entry.key] = entry.value * exponent;
    }
    return Dimension(result);
  }

  bool get isDimensionless => primitiveExponents.isEmpty;

  // Canonical string representation: primitives with positive exponents / primitives with negative exponents
  // e.g., "m / s^2" for acceleration, "kg * m / s^2" for force, "1 / s" for frequency
  String canonicalRepresentation() {
    if (isDimensionless) return "1";

    final positive = <String>[];
    final negative = <String>[];

    // Sort primitives alphabetically by their ID
    final sortedEntries = primitiveExponents.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    for (var entry in sortedEntries) {
      if (entry.value > 0) {
        if (entry.value == 1) {
          positive.add(entry.key);
        } else {
          positive.add('${entry.key}^${entry.value}');
        }
      } else if (entry.value < 0) {
        final posExp = -entry.value;
        if (posExp == 1) {
          negative.add(entry.key);
        } else {
          negative.add('${entry.key}^$posExp');
        }
      }
    }

    // Build the representation
    String numerator = positive.isEmpty ? "1" : positive.join(' * ');

    if (negative.isEmpty) {
      return numerator;
    } else {
      String denominator = negative.join(' * ');
      return '$numerator / $denominator';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Dimension) return false;

    if (primitiveExponents.length != other.primitiveExponents.length) return false;

    for (var entry in primitiveExponents.entries) {
      if (other.primitiveExponents[entry.key] != entry.value) return false;
    }
    return true;
  }

  @override
  int get hashCode {
    // Combine hashes of all entries
    int hash = 0;
    for (var entry in primitiveExponents.entries) {
      hash ^= entry.key.hashCode ^ entry.value.hashCode;
    }
    return hash;
  }
}

// Registry mapping dimensions to human-readable category names (for UI)
class DimensionRegistry {
  // Map from canonical dimension to metadata
  final Map<Dimension, DimensionInfo> _dimensions = {};

  void registerDimension(Dimension dimension, String name, String? description) {
    _dimensions[dimension] = DimensionInfo(dimension, name, description);
  }

  DimensionInfo? getDimensionInfo(Dimension dimension) => _dimensions[dimension];

  // Get category name for UI display
  String getCategoryName(Dimension dimension) {
    return _dimensions[dimension]?.name ?? dimension.canonicalRepresentation();
  }
}

class DimensionInfo {
  final Dimension dimension;
  final String name;          // e.g., "Acceleration", "Force", "Energy"
  final String? description;  // optional longer description

  DimensionInfo(this.dimension, this.name, this.description);
}

// Unit prefixes (e.g., kilo, mega, milli)
class UnitPrefix {
  final String id;             // Primary symbol (e.g., "k", "M", "m")
  final List<String> aliases;  // Alternative names (e.g., ["kilo"], ["mega"], ["milli"])
  final double factor;         // Multiplication factor (e.g., 1000, 1000000, 0.001)
  final String? description;   // Human-readable details

  UnitPrefix({
    required this.id,
    required this.aliases,
    required this.factor,
    this.description,
  });

  // All recognized names for this prefix (id + aliases)
  List<String> get allNames => [id, ...aliases];
}

// Registry of unit prefixes
class PrefixRegistry {
  final Map<String, UnitPrefix> _prefixes = {};

  void registerPrefix(UnitPrefix prefix) {
    _prefixes[prefix.id] = prefix;
    for (var alias in prefix.aliases) {
      _prefixes[alias] = prefix;
    }
  }

  UnitPrefix? findPrefix(String name) => _prefixes[name];

  List<UnitPrefix> getAllPrefixes() => _prefixes.values.toSet().toList();
}
```

**Unit Definition:**
```dart
class Unit {
  final String id;          // Primary symbol/name (e.g., "m", "meter", "kg")
  final List<String> aliases;  // Alternative names (e.g., ["metre"])
  final String? description;   // Human-readable details about the unit
  final UnitDefinition definition;

  // All recognized names for this unit (id + aliases)
  // Parser will also check plural forms automatically
  List<String> get allNames => [id, ...aliases];

  // Lazy-computed dimension based on definition
  Dimension getDimension(UnitRepository repo) => definition.getDimension(repo, id);
}

abstract class UnitDefinition {
  double toBase(double value, UnitRepository repo, String unitId);
  double fromBase(double value, UnitRepository repo, String unitId);
  Dimension getDimension(UnitRepository repo, String unitId);
}

// For primitive units - these define fundamental dimensions
class PrimitiveUnitDefinition extends UnitDefinition {
  final bool isDimensionless;

  PrimitiveUnitDefinition({this.isDimensionless = false});

  @override
  double toBase(double value, UnitRepository repo, String unitId) => value;  // identity

  @override
  double fromBase(double value, UnitRepository repo, String unitId) => value;  // identity

  @override
  Dimension getDimension(UnitRepository repo, String unitId) {
    // The unit's ID becomes the dimension identifier
    return isDimensionless
      ? Dimension.dimensionless()
      : Dimension({unitId: 1});
  }
}

// For units defined as linear multiples of another unit
class LinearDefinition extends UnitDefinition {
  final double factor;      // e.g., 1 mile = 1609.344 meters
  final String baseUnitId;  // ID of unit this is defined in terms of (e.g., "meter")

  LinearDefinition(this.factor, this.baseUnitId);

  @override
  double toBase(double value, UnitRepository repo, String unitId) {
    // Recursively convert through the chain
    var baseUnit = repo.getUnit(baseUnitId);
    return baseUnit.definition.toBase(value * factor, repo, baseUnitId);
  }

  @override
  double fromBase(double value, UnitRepository repo, String unitId) {
    var baseUnit = repo.getUnit(baseUnitId);
    return baseUnit.definition.fromBase(value, repo, baseUnitId) / factor;
  }

  @override
  Dimension getDimension(UnitRepository repo, String unitId) {
    // Get dimension from the unit we're based on
    var baseUnit = repo.getUnit(baseUnitId);
    return baseUnit.getDimension(repo);
  }
}

// For units with offset (like temperature)
class AffineDefinition extends UnitDefinition {
  final double factor;
  final double offset;      // e.g., Celsius = Kelvin - 273.15
  final String baseUnitId;

  AffineDefinition(this.factor, this.offset, this.baseUnitId);

  @override
  double toBase(double value, UnitRepository repo, String unitId) {
    var baseUnit = repo.getUnit(baseUnitId);
    return baseUnit.definition.toBase((value + offset) * factor, repo, baseUnitId);
  }

  @override
  double fromBase(double value, UnitRepository repo, String unitId) {
    var baseUnit = repo.getUnit(baseUnitId);
    return (baseUnit.definition.fromBase(value, repo, baseUnitId) / factor) - offset;
  }

  @override
  Dimension getDimension(UnitRepository repo, String unitId) {
    var baseUnit = repo.getUnit(baseUnitId);
    return baseUnit.getDimension(repo);
  }
}

// For compound units defined as expressions
class CompoundDefinition extends UnitDefinition {
  final String expr;  // e.g., "kg*m/s^2" for Newton

  CompoundDefinition(this.expr);

  @override
  double toBase(double value, UnitRepository repo, String unitId) {
    // Parse and evaluate the expression to get conversion factor
    // This requires the expression parser/evaluator
    throw UnimplementedError("Requires expression evaluator");
  }

  @override
  double fromBase(double value, UnitRepository repo, String unitId) {
    throw UnimplementedError("Requires expression evaluator");
  }

  @override
  Dimension getDimension(UnitRepository repo, String unitId) {
    // Parse and evaluate the expression to get dimension
    // This requires the expression parser/evaluator
    throw UnimplementedError("Requires expression evaluator");
  }
}

// Examples of unit definitions:
//
// Primitive unit (meter):
//   Unit(id: "m", aliases: ["meter", "meters", "metre", "metres"],
//        definition: PrimitiveUnitDefinition())
//   dimension: {m: 1}
//
// Derived unit referencing base (kilometer):
//   Unit(id: "km", aliases: ["kilometer", "kilometers", "kilometre", "kilometres"],
//        definition: LinearDefinition(1000, "m"))
//   dimension: {m: 1}
//
// Derived unit referencing derived (mile):
//   Unit(id: "mi", aliases: ["mile", "miles"],
//        definition: LinearDefinition(1.609344, "km"))
//   dimension: {m: 1} (calculated through km → m)
//
// Compound unit (newton):
//   Unit(id: "N", aliases: ["newton", "newtons"],
//        definition: CompoundDefinition("kg*m/s^2"))
//   dimension: {kg: 1, m: 1, s: -2}
```

**Quantity Model:**
```dart
class Quantity {
  final num value;
  final Dimension dimension;
  final Unit? displayUnit;  // preferred display unit

  Quantity convertTo(Unit targetUnit);
  Quantity add(Quantity other);      // requires same dimension
  Quantity multiply(Quantity other);
  Quantity power(num exponent);
  String format(DisplaySettings settings);
}
```

### 3. Unit Database

**Data Source:**
- Import GNU Units database definitions
- Parse into internal format
- Store in embedded database (asset bundle)

**Database Schema:**
```sql
-- Units table (includes both primitive and derived units)
CREATE TABLE units (
  id TEXT PRIMARY KEY,             -- Primary symbol/name (e.g., "m", "kg", "N")
  description TEXT,                 -- Human-readable details about the unit
  definition_type TEXT NOT NULL,   -- 'primitive', 'linear', 'affine', 'compound'
  definition_data TEXT,             -- JSON with conversion parameters
  is_dimensionless INTEGER DEFAULT 0  -- only relevant for primitive units
);

-- Unit aliases table (stores alternative names)
-- Plurals are handled automatically at parse time, not stored
CREATE TABLE unit_aliases (
  unit_id TEXT,
  alias TEXT,
  PRIMARY KEY (unit_id, alias),
  FOREIGN KEY (unit_id) REFERENCES units(id)
);

-- Unit prefixes table (e.g., kilo, mega, milli)
CREATE TABLE prefixes (
  id TEXT PRIMARY KEY,      -- Primary symbol (e.g., "k", "M", "m")
  description TEXT,          -- Human-readable details
  factor REAL NOT NULL       -- Multiplication factor (e.g., 1000, 1000000, 0.001)
);

-- Prefix aliases table
CREATE TABLE prefix_aliases (
  prefix_id TEXT,
  alias TEXT,
  PRIMARY KEY (prefix_id, alias),
  FOREIGN KEY (prefix_id) REFERENCES prefixes(id)
);

-- Dimension metadata (for UI display)
CREATE TABLE dimensions (
  dimension_key TEXT PRIMARY KEY,  -- JSON representation of dimension map
  name TEXT NOT NULL,              -- e.g., "Acceleration", "Force"
  description TEXT
);

-- Constants table
CREATE TABLE constants (
  name TEXT PRIMARY KEY,
  value REAL,
  definition TEXT  -- expression defining the constant with units
);

-- Custom user units
CREATE TABLE custom_units (
  id TEXT PRIMARY KEY,
  description TEXT,
  definition_type TEXT NOT NULL,
  definition_data TEXT,
  is_dimensionless INTEGER DEFAULT 0,
  created_at INTEGER
);

-- Custom user prefixes
CREATE TABLE custom_prefixes (
  id TEXT PRIMARY KEY,
  description TEXT,
  factor REAL NOT NULL,
  created_at INTEGER
);

-- Custom user dimension metadata
CREATE TABLE custom_dimensions (
  dimension_key TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  created_at INTEGER
);

-- Examples of stored data:
--
-- Meter (primitive unit):
--   units: {id: "m", description: "SI unit of length", definition_type: "primitive", is_dimensionless: 0}
--   unit_aliases: {unit_id: "m", alias: "meter"}, {unit_id: "m", alias: "metre"}
--   Parser will also recognize: "meters", "metres" (automatic plural handling)
--
-- Kilo prefix:
--   prefixes: {id: "k", description: "SI prefix meaning 1000", factor: 1000}
--   prefix_aliases: {prefix_id: "k", alias: "kilo"}
--   Parser will recognize: "km" → 1000 * m, "kilogram" → 1000 * gram (if gram exists)
--
-- Mega prefix:
--   prefixes: {id: "M", description: "SI prefix meaning 1,000,000", factor: 1000000}
--   prefix_aliases: {prefix_id: "M", alias: "mega"}
--   Parser will recognize: "MW" → 1000000 * W, "megawatt" → 1000000 * watt
--
-- Mile (derived):
--   units: {id: "mi", description: "Imperial unit of length, commonly used in the United States",
--           definition_type: "linear", definition_data: '{"factor": 1609.344, "baseUnitId": "m"}'}
--   unit_aliases: {unit_id: "mi", alias: "mile"}
--   Parser will also recognize: "miles" (automatic plural handling)
--
-- Examples of definition_data JSON:
--
-- PrimitiveUnitDefinition:
--   {"type": "primitive", "isDimensionless": false}
--
-- LinearDefinition (mile = 1609.344 meters):
--   {"type": "linear", "factor": 1609.344, "baseUnitId": "m"}
--
-- AffineDefinition (Celsius):
--   {"type": "affine", "factor": 1.0, "offset": 273.15, "baseUnitId": "K"}
--
-- CompoundDefinition (newton):
--   {"type": "compound", "expression": "kg*m/s^2"}
```

### 4. Worksheet System

**Worksheet Model:**
```dart
class Worksheet {
  final String id;
  final String name;
  final String category;
  final List<WorksheetField> fields;
  final bool isBuiltIn;
  final bool isModified;
}

class WorksheetField {
  final String id;
  final Unit unit;
  String? lastValue;     // persisted
  bool isInput;          // which field is currently being edited
}
```

**Worksheet State Management:**
- Use reactive state management (Provider/Riverpod)
- When any field changes, recalculate all others
- Persist last values to local storage
- Load on app startup

### 5. Currency Rate Management

**Currency Service:**
```dart
class CurrencyService {
  Future<void> fetchRates();
  Future<Map<String, double>> getRates();
  DateTime getLastUpdateTime();
  bool needsUpdate();
}
```

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

## State Management Strategy

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

### Persistence Layer
```dart
class PreferencesRepository {
  Future<void> savePreference(String key, dynamic value);
  Future<T?> getPreference<T>(String key);
}

class WorksheetRepository {
  Future<List<Worksheet>> getWorksheets();
  Future<void> saveWorksheet(Worksheet worksheet);
  Future<void> updateFieldValue(String worksheetId, String fieldId, String value);
}

class UnitRepository {
  Future<List<Unit>> getUnitsInCategory(String category);
  Future<Unit?> findUnit(String name);
  Future<void> saveCustomUnit(Unit unit);
}
```

## Implementation Phases

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

## Future Enhancement Phases

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

## Development Best Practices

### Code Organization
```
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
```

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

## Risk Mitigation

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

## Success Metrics

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

## Resources & References

### Learning Resources
- Flutter documentation: https://docs.flutter.dev
- Dart language tour: https://dart.dev/guides/language/language-tour
- Material Design: https://m3.material.io
- GNU Units: https://www.gnu.org/software/units/

### Tools
- Flutter DevTools for debugging
- Android Studio / VS Code
- Git for version control
- GitHub for hosting

### Community
- Flutter Discord/Reddit for questions
- Stack Overflow for specific issues
- GitHub Issues for bug tracking
