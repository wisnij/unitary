Unitary - Quantity Class & Arithmetic Design
============================================

This document provides detailed design for the Quantity class, including arithmetic operations, unit conversion algorithms, and edge case handling.

**Status:** Design Document
**Created:** January 2026
**Related Documents:** [Architecture](architecture.md), [Terminology](terminology.md)

---


Table of Contents
-----------------

1. [Overview](#overview)
2. [Number Representation Strategy](#number-representation-strategy)
3. [Quantity Class Design](#quantity-class-design)
4. [Arithmetic Operations](#arithmetic-operations)
5. [Unit Conversion Algorithm](#unit-conversion-algorithm)
6. [Unit Reduction Algorithm](#unit-reduction-algorithm)
7. [Edge Cases and Error Handling](#edge-cases-and-error-handling)
8. [Performance Considerations](#performance-considerations)
9. [Testing Strategy](#testing-strategy)

---


Overview
--------

The Quantity class is the core data structure representing a physical quantity with both a numeric value and dimensional information. It must support:

- Arithmetic operations (+, -, *, /, ^) with proper dimensional analysis
- Conversion between conformable units
- Reduction to primitive units
- Formatting for display
- High precision where needed
- Graceful handling of edge cases

**Design Goals:**

- **Correctness**: All operations maintain dimensional consistency
- **Precision**: Minimize floating-point errors where possible
- **Performance**: Fast enough for real-time UI updates
- **Simplicity**: Clear, maintainable code
- **Extensibility**: Easy to add new operations

---


Number Representation Strategy
------------------------------

### Decision: Use Double (Decimal) for MVP

**Rationale:**

For the MVP, we'll use Dart's `double` type (IEEE 754 double-precision floating-point) for all numeric values. However, we need rational number support specifically for **exponent operations** to properly handle dimensional analysis.

**Pros of Double:**

- Native Dart type with excellent performance
- Sufficient precision for most use cases (~15-17 decimal digits)
- Simple implementation
- No additional dependencies
- Works seamlessly with mathematical functions (sin, cos, sqrt, etc.)
- Dart's `num` type allows seamless mixing of `int` and `double`

**Cons of Double:**

- Precision loss in repeated operations
- Cannot exactly represent some fractions (e.g., 1/3)
- Rounding errors in decimal representations

**Rational Number Recovery for Exponents:**

When an exponent is provided as a `double`, we can recover a rational approximation using continued fractions. This is essential for dimensional analysis in expressions like `(m^2)^0.5 = m`.

**When Rational Recovery is Needed:**

- Exponent operations on dimensioned quantities
- Example: `(9 m^2)^0.5` requires knowing that 0.5 = 1/2 to compute dimension correctly

**Future Enhancement Path:**

- Phase 15+ can add full rational number support throughout
- Use a library like `rational` or implement custom rational type
- Allow users to choose representation mode (decimal vs. rational)
- Display both representations when helpful

### Internal Representation

`Quantity` stores a `double` value and a `Dimension`.  Convenience constructors
include `Quantity.dimensionless(value)` for dimensionless quantities.

### Precision Management

To minimize floating-point errors:

1. **Avoid intermediate conversions**: Perform calculations in a consistent unit system when possible
2. **Use epsilon comparisons**: When checking equality, use a small tolerance
3. **Round for display only**: Keep full precision internally, round only for UI
4. **Document limitations**: Make users aware that some operations may have small errors
5. **Rational recovery for exponents**: Use continued fractions to recover rational approximations from doubles

`Quantity.approximatelyEquals` uses relative tolerance for large values and
absolute tolerance for small values (threshold at magnitude 1.0).

`Rational` recovers rational approximations from doubles using a continued
fraction algorithm with configurable `maxDenominator` (default 100).  This is
used for dimensional analysis in exponent operations — e.g., recognizing that
0.5 = 1/2 so `(m^2)^0.5 = m`.  Always stored in lowest terms with positive
denominator.

---


Quantity Class Design
---------------------

### Class Structure

`Quantity` provides:

- **Arithmetic:** `add`, `subtract`, `multiply`, `divide`, `negate`, `abs`,
  `power` — with operator overloads (+, -, *, /, unary -)
- **Query:** `isDimensionless`, `isZero`, `isPositive`, `isNegative`,
  `isConformableWith`
- **Comparison:** `approximatelyEquals` with configurable tolerance (default
  epsilon = 1e-10)
- **Constants:** `Quantity.unity` (dimensionless 1.0)

NaN values are rejected at construction time (fail-fast).

### DisplaySettings (planned)

`DisplaySettings` will control output formatting: precision (decimal places),
notation style (plain, scientific, engineering), and whether to show dimensions.

---


Arithmetic Operations
---------------------

### Addition and Subtraction

**Rule**: Only conformable quantities can be added or subtracted.

**Algorithm:**

1. Check that dimensions match (throw DimensionException if not)
2. Add/subtract the values
3. Keep the same dimension

Check dimensions match (throw `DimensionException` if not), then add/subtract
the values and keep the same dimension.

Examples: `5 m + 3 m = 8 m`; `5 m + 3 s` → DimensionException.

### Multiplication

**Rule**: Multiply values and multiply dimensions (add exponents).

**Algorithm:**

1. Multiply the values
2. Multiply the dimensions (add exponents for each primitive)

Multiply values and multiply dimensions (add exponents).

Examples: `5 m * 3 m = 15 m^2`; `5 m * 2 s = 10 m·s`;
`5 m * 3 = 15 m`.

### Division

**Rule**: Divide values and divide dimensions (subtract exponents).

**Algorithm:**

1. Check for division by zero (throw EvalException if zero)
2. Divide the values
3. Divide the dimensions (subtract exponents for each primitive)

Check for division by zero (throw `EvalException`), then divide values and
divide dimensions (subtract exponents).

Examples: `10 m / 2 s = 5 m/s`; `10 m / 2 m = 5` (dimensionless);
`10 m / 0` → EvalException.

### Negation and Absolute Value

`negate()` returns the quantity with negated value; `abs()` returns with
absolute value.  Both preserve dimension.

### Exponentiation

**Rule**: Raise value to power and raise dimension to power (multiply all exponents).

**Dimensional Analysis Constraint**: For dimensioned quantities, the exponent must be rational, and all dimension exponents must be divisible by the exponent's denominator.

**Algorithm:**

1. Handle special cases (zero, one)
2. If base has dimensions, recover rational approximation of exponent
3. Validate that dimension exponents are compatible with the rational exponent
4. Compute `value ^ exponent`
5. Multiply all dimension exponents by the power exponent

**Algorithm:**

1. Special cases: exponent 0 → dimensionless 1.0; exponent 1 → identity.
2. For dimensionless quantities, any exponent is allowed (but negative base
   with fractional exponent throws `EvalException`).
3. For dimensioned quantities, recover a rational approximation from the double
   exponent using continued fractions.  Validate that each dimension exponent
   multiplied by the rational numerator is divisible by the denominator.  If
   not, throw `DimensionException`.
4. Compute `value^exponent` and multiply all dimension exponents by the
   rational exponent.

**Examples:**

- `(3 m)^2 = 9 m^2`
- `(4 m^2)^0.5 = 2 m` — 0.5 recovers as 1/2, and 2 is divisible by 2
- `(8 m^3)^(1/3) = 2 m` — 1/3 as rational, 3 is divisible by 3
- `(5 m^3)^0.5` → DimensionException (3 is not divisible by 2)
- `(-4)^0.5` → EvalException (negative base, fractional exponent)

---


Unit Conversion Algorithm
-------------------------

### Overview

Converting from one unit to another requires:

1. Verifying the units are conformable (same dimension)
2. Finding the conversion factor between them
3. Applying the conversion factor

### Conversion Factor Calculation

The conversion factor between two units is the ratio of their base-unit values.
Reduce both units to primitives via `resolveUnit`, check conformability, and
divide: `factor = fromUnit.value / toUnit.value`.

Examples: mile→meter factor = 1609.344/1.0 = 1609.344;
mile→foot factor = 1609.344/0.3048 = 5280.

### Quantity Conversion

To convert a quantity to a target unit: check conformability, then divide the
quantity's value by the target unit's base value.  For quantities already in
primitive units, this is simply `value / resolveUnit(target).value`.

### Handling Affine Conversions (Temperature)

Temperature units with offsets (like Celsius/Fahrenheit) require special handling:

Affine conversions apply `(value + offset) * factor` and are only valid for
absolute temperature values, not for differences or in derived units.  This is
handled by using separate `degC`/`degF` (linear, no offset) units for
differences and rates vs. `tempC`/`tempF` (affine, function syntax required)
for absolute temperatures.

---


Unit Reduction Algorithm
------------------------

### Purpose

Reduce a quantity to its representation in primitive units only. This is useful for:

- Displaying results in canonical form
- Comparing quantities from different unit systems
- Debugging dimensional analysis

### Algorithm

For each non-primitive unit in the dimension, resolve it through the repository
to primitive base units.  The evaluator does this eagerly at UnitNode evaluation
time, so quantities are typically already in primitive form by the time
arithmetic operations run.

Derived units (e.g., newton = `"kg m/s^2"`) are resolved by parsing and
evaluating their expression string through the full pipeline.

Examples: 5 miles → 8046.72 m; 10 newtons → 10 {kg: 1, m: 1, s: -2}.

---


Edge Cases and Error Handling
-----------------------------

### 1. Division by Zero

**Scenario**: `quantity / Quantity(0, ...)`

**Handling**: Throw `EvalException('Division by zero')`.

### 2. Very Large Numbers

**Scenario**: Values approaching `double.maxFinite` (~1.8e308)

**Handling**:

- Allow operations to proceed
- Result may be `double.infinity` if overflow occurs
- Display as "∞" in UI with appropriate unit
- Document limitation in user guide

### 3. Very Small Numbers (Underflow)

**Scenario**: Values approaching zero (~1e-308)

**Handling**:

- Result may become exactly 0.0
- This is generally acceptable (no special handling needed)
- Comparisons should use epsilon tolerance

### 4. NaN (Not a Number)

**Decision: Throw Immediately (Fail-Fast Approach)**

Rather than propagating NaN through calculations, we throw exceptions as soon as invalid operations are detected. This provides better user experience with clear error messages.

**Rationale:**

For an interactive calculator where users need immediate, clear feedback:

**Throw immediately because:**

- ✓ **Clear error messages** with location and cause
- ✓ **Stops invalid computation early** (fail-fast principle)
- ✓ **Better user experience** - users know exactly what went wrong
- ✓ Easier to debug
- ✓ Prevents NaN from spreading through calculation

**Propagating NaN would cause:**

- ✗ Error location is obscured (where did NaN originate?)
- ✗ Wastes computation on invalid values
- ✗ User sees "undefined" but doesn't know why
- ✗ Harder to debug for users
- ✗ NaN can "infect" unrelated parts of calculation

**Implementation:** The Quantity constructor validates that the value is not NaN
(throwing `EvalException` immediately).  Infinity is allowed as it's
mathematically meaningful.  Mathematical functions (sqrt, log, asin, etc.)
validate their inputs and throw with descriptive messages before any invalid
computation can produce NaN.

**Error Messages for Common Cases:**

| Operation   | Error Message                                        |
|-------------|------------------------------------------------------|
| `sqrt(-4)`  | "Cannot take square root of negative number: -4.0"   |
| `log(0)`    | "Cannot take logarithm of non-positive number: 0.0"  |
| `log(-5)`   | "Cannot take logarithm of non-positive number: -5.0" |
| `asin(2)`   | "asin requires argument in range [-1, 1], got 2.0"   |
| `0 / 0`     | "Division by zero"                                   |
| `tan(pi/2)` | Allow infinity (mathematically valid limit)          |

### 5. Temperature: Absolute vs. Difference (GNU Units Approach)

**Problem**: Temperature has two distinct meanings:

1. **Absolute temperature**: A point on the temperature scale (affine conversion with offset)
2. **Temperature difference**: The size of a temperature interval (linear conversion, no offset)

**GNU Units Solution**: Define separate units for each concept:

- `tempF`, `tempC`: Absolute temperature with affine conversion (includes offset)
- `degF`, `degC`: Temperature difference, the "size" of one degree (linear, no offset)

**Example:**

~~~~
// Absolute temperature conversion (with offset)
100 tempF = 37.78 tempC  (affine: (100-32)×5/9)

// Temperature difference conversion (no offset)
100 degF = 55.56 degC    (linear: 100×5/9)

// Temperature rate (uses degF/degC, not tempF/tempC)
10 degF/hour = 5.56 degC/hour
~~~~

**Implementation:**

Two types of temperature units are defined for each scale:

- Absolute (affine): `tempF` uses `AffineUnit` with factor 5/9, offset -32,
  base K.  `tempC` uses factor 1, offset 273.15, base K.
- Difference (linear): `degF` and `degC` are `DerivedUnit`s with no offset,
  just the scale factor relative to K.
- Similar pairs for Rankine (tempR/degR).

**Key Insight**: Both `tempK` and `degK` share dimension {K: 1}.  The
distinction (absolute vs. difference) is semantic, in which unit name is used.

**Usage Rules:**

1. **Absolute temperature**: Use `tempF`, `tempC`, `tempK` for single temperature values
2. **Temperature differences**: Use `degF`, `degC`, `degK` when subtracting temperatures or in rates
3. **Derived units**: Always use degree units (degF, degC) not absolute (tempF, tempC)
   - `10 degC/s` (temperature rate) — correct
   - `10 tempC/s` (meaningless) — incorrect

**Temperature Subtraction:**

When subtracting absolute temperatures, the result is semantically a temperature
difference.  For MVP, the subtraction returns the same dimension since tempF and
degF both have dimension {K: 1}.

**Future Enhancement**: Track provenance of quantities to automatically convert
result to degree units when subtracting absolutes.

---

### 6. Function and Affine Unit Syntax

**The Affine Ambiguity Problem:**

Affine conversions don't distribute over multiplication. Consider `2 60 tempF`:

- Parse as `2 * (60 tempF)`: Convert 60°F → 288.71 K, multiply by 2 → 577.42 K
- Parse as `(2 * 60) tempF` = `120 tempF`: Convert 120°F → 322.04 K
- Parse as `(2 tempF) * 60`: Convert 2°F → 256.48 K, multiply by 60 → 15,388.8 K

**Three completely different results!** This is because `tempF(x) = (x - 32) × 5/9 + 273.15` includes that offset.

**Solution: Function Syntax for Functions and Affine Units**

**General Rule**: Any identifier can be followed by `(expr)` which is normally implicit multiplication.

**Special Rule**: For **functions** and **affine units**, the parenthesized expression is **required** (not optional).

**Exception**: A function or affine unit MAY appear without parentheses if it is the **only non-whitespace token** in the entire input string (for definition lookup or conversion targets).

### Syntax Rules

#### Functions (sin, cos, sqrt, etc.)

**In expressions (multiple tokens):**

- ✓ `sin(0.5)` - function call
- ✓ `sqrt(9 m^2)` - function call
- ✓ `cos(pi/4)` - function call
- ✗ `sin 0.5` → Error: "Function 'sin' requires arguments: sin(...)"
- ✗ `sqrt 9` → Error: "Function 'sqrt' requires arguments: sqrt(...)"

**As standalone input (single token):**

- ✓ `sin` → Definition: "Function: sin(x) - sine of x (radians)"
- ✓ `sqrt` → Definition: "Function: sqrt(x) - square root of x"

#### Affine Units (tempF, tempC)

**In expressions (multiple tokens):**

- ✓ `tempF(60)` - affine conversion
- ✓ `tempF(32) + 10 degF` - affine conversion in expression
- ✓ `2 * tempF(100)` - multiply result of conversion
- ✗ `tempF 60` → Error: "Affine unit 'tempF' requires function syntax: tempF(...)"
- ✗ `60 tempF` → Error (same)
- ✗ `2 tempF` → Error (same)

**As standalone input (single token):**

- ✓ `tempF` → Definition: "tempF(x) = (x - 32) × 5/9 + 273.15 K"
- ✓ `tempC` → Definition: "tempC(x) = x + 273.15 K"

**As conversion target:**

- ✓ Input: `tempF(68)`, Target: `tempC` → Result: `20`
- ✓ Input: `tempF(32)`, Target: `tempK` → Result: `273.15`

#### Linear Units (degF, meter, kg, all others)

**Normal unit syntax (parentheses = multiplication):**

- ✓ `60 degF` - normal unit application
- ✓ `5 m` - normal unit application
- ✓ `degF(60)` - parsed as `degF * 60` (multiplication, same as above)
- ✓ `2 60 degF` - parsed as `2 * 60 * degF = 120 degF`

**As standalone or conversion target:**

- ✓ `degF` → Definition or conversion target
- ✓ `meter` → Definition or conversion target

### Prefix Restrictions

**Functions and affine units CANNOT have prefixes:**

- ✗ `millicos(2)` → Error: "Cannot attach prefix 'milli' to function 'cos'"
- ✗ `kilosin(0.5)` → Error: "Cannot attach prefix 'kilo' to function 'sin'"
- ✗ `megatempF(60)` → Error: "Cannot attach prefix 'mega' to affine unit 'tempF'"
- ✗ `millitempC(20)` → Error: "Cannot attach prefix 'milli' to affine unit 'tempC'"

**Linear units CAN have prefixes:**

- ✓ `kilometer` - parsed as prefix 'kilo' + unit 'meter'
- ✓ `5 km` - valid
- ✓ `millidegF` - parsed as prefix 'milli' + unit 'degF' (if useful)

### Implementation

Validation happens in two stages:

1. **Lexer:** Identifies functions and units (with optional prefix).  Enforces
   prefix restrictions — prefixes on functions or affine units produce a
   `LexException`.  Marks standalone tokens (single non-EOF token in input).

2. **Parser:** Validates parenthesis requirements.  For non-standalone functions
   and affine units, the next token must be `(` or a `ParseException` is thrown.
   Standalone functions produce a `FunctionDefinitionRequestNode`; standalone
   affine units produce a `DefinitionRequestNode`.  Affine units with `(` are
   parsed as `AffineUnitNode` with the parenthesized expression as argument.

3. **AffineUnitNode evaluation:** Evaluates the argument, verifies it is
   dimensionless, and applies the affine conversion.  Throws
   `DimensionException` if the argument has dimensions.

### Examples

**Valid expressions:**

| Input                 | Result                                 |
|-----------------------|----------------------------------------|
| `sin(0.5)`            | FunctionNode                           |
| `tempF(60)`           | AffineUnitNode                         |
| `tempF(32) + 10 degF` | BinaryOpNode (add)                     |
| `60 degF`             | BinaryOpNode (implicit multiplication) |
| `kilometer`           | UnitNode                               |

**Valid standalone (definition requests):**

| Input   | Result                        |
|---------|-------------------------------|
| `sin`   | FunctionDefinitionRequestNode |
| `tempF` | DefinitionRequestNode         |
| `meter` | DefinitionRequestNode         |

**Valid conversion targets:** `tempF(68)` → `tempC` = 20; `5 m` → `ft` = 16.404

**Invalid expressions (errors):**

| Input                   | Error                                          |
|-------------------------|------------------------------------------------|
| `sin 0.5`               | "Function 'sin' requires arguments"            |
| `tempF 60` / `60 tempF` | "Affine unit 'tempF' requires function syntax" |
| `millicos(2)`           | "Cannot attach prefix to function"             |
| `megatempF(60)`         | "Cannot attach prefix to affine unit"          |

**Edge cases:** `5` → NumberNode (not standalone special case); `(tempF)` →
expression (parens = multiple tokens, not standalone).

### Testing

Key test cases for function/affine syntax:

- Functions require parentheses in expressions (`sin 0.5` → error)
- Affine units require function syntax (`tempF 60`, `60 tempF` → error)
- Standalone functions → definition request
- Standalone affine units → definition request
- Affine unit as conversion target works
- Linear units allow both postfix (`60 degF`) and call (`degF(60)`) syntax
- Prefixes rejected on functions (`millicos`) and affine units (`megatempF`)
- Prefixes allowed on linear units (`kilometer`)
- Affine argument must be dimensionless (`tempF(60 m)` → DimensionException)

### Warning About Temperature in Compound Expressions

When parsing expressions, detect if `tempF` or `tempC` appears in the numerator
of a compound expression (e.g., `tempC/hour`) and issue a warning suggesting the
user may have meant the degree unit (`degC/hour`) instead.

**Implementation Notes:**

1. No special token types needed - use existing `TokenType.function` and `TokenType.unit`
2. Validation happens in two stages: prefix restrictions in lexer, parenthesis requirements in parser
3. Standalone detection happens after full tokenization
4. AffineUnitNode is a distinct AST node type requiring dimensionless argument
5. Temperature usage warnings can be added as a linting/validation pass

This section is a duplicate of Section 5 above; see [Temperature: Absolute vs.
Difference](#5-temperature-absolute-vs-difference-gnu-units-approach) for the
full discussion.

### 6. Negative Bases with Fractional Exponents

**Scenario**: `(-4)^0.5` is complex, not real

**Handling**: Throw `EvalException('Cannot raise negative number to fractional power')`.

### 7. Dimension Mismatch Errors

**Scenario**: Operations on non-conformable quantities

**Handling**: Throw `DimensionException` with helpful message including canonical
representations of the left and right dimensions when available.

### 7. Precision Loss in Floating-Point Operations

**Scenario**: Accumulated errors from repeated arithmetic operations

**Handling**:

- Accept that some precision loss is inevitable with `double`
- Document limitations in user guide
- For critical applications, users can verify with external tools
- Future enhancement: Add rational number support (Phase 15+)

**Mitigation Strategies:**

- Avoid intermediate conversions when possible
- Use epsilon tolerance for comparisons
- Keep full precision internally, round only for display
- Warn users that some complex calculations may have small errors

**Example of Precision Loss:** Repeated operations accumulate error — e.g.,
`(1/3) * 3` may produce 0.999... instead of 1.0.  Use
`approximatelyEquals` for comparisons.

**Not Implemented for MVP**: Operation depth tracking. This adds complexity without clear benefit for most users. If precision becomes a concern in practice, we can add it later.

---


Performance Considerations
--------------------------

### Optimization Strategies

1. **Lazy Dimension Computation**: For derived units, cache the computed dimension
2. **Conversion Factor Caching**: Cache frequently-used conversion factors
3. **Avoid Repeated Lookups**: Pass `UnitRepository` once, cache needed units
4. **Efficient Dimension Operations**: Dimension multiplication/division are simple map operations

### Potential Bottlenecks

1. **Unit Definition Chain Traversal**: For deeply nested unit definitions (e.g., mile → km → m)
   - Mitigation: Flatten definitions during database load
   - Cache base conversion factors

2. **Expression Parsing for Derived Units**: Parsing happens on first use
   - Mitigation: Pre-parse during unit database initialization

3. **Repeated Conversions in UI**: Worksheet mode may trigger many conversions
   - Mitigation: Debounce input, cache results when possible

### Benchmarking Targets (MVP)

- Single arithmetic operation: < 1 microsecond
- Unit conversion: < 10 microseconds
- Expression evaluation: < 100 microseconds for typical expressions
- UI update latency: < 16ms (60 FPS)

These should be easily achievable with the proposed design.

---


Testing Strategy
----------------

### Unit Tests

**Arithmetic operations:** Conformable addition/subtraction, non-conformable
rejection, multiplication with dimension combining, division with dimension
subtraction, power with dimensional exponent validation, division by zero.

**Conversion:** Linear conversions (miles → meters), affine conversions
(temperature with offset), non-conformable rejection.

**Edge cases:** Very large numbers (overflow → infinity), negative base with
fractional exponent, dimensional exponent validation (`(m^2)^0.5` valid vs.
`(m^3)^0.5` invalid), rational recovery from doubles (0.5 → 1/2, 0.333... →
1/3), NaN rejection at construction time.

### Integration Tests

- Complex expression evaluation: `sqrt(9 m^2) + 5 ft` ≈ 4.524 m
- Unit chain conversion: mile → km → m with no precision loss

### Property-Based Tests

Verify mathematical properties with random values:

- Commutativity of addition: `a + b == b + a`
- Associativity of multiplication: `(a * b) * c == a * (b * c)`
- Conversion round-trip: A → B → A gives original value (within epsilon)

---


Summary
-------

This design provides:

1. **Simple, efficient numeric representation** using `double` for MVP with rational recovery for exponents
2. **Complete arithmetic operations** with proper dimensional analysis including rational exponent validation
3. **Robust conversion algorithm** handling unit chains and derived units
4. **GNU Units-compatible temperature handling** with separate absolute (tempF/tempC) and difference (degF/degC) units
5. **Unambiguous function and affine syntax** with special handling for standalone tokens
6. **Fail-fast error handling** that throws immediately with clear messages
7. **Strong testing strategy** ensuring correctness

The design balances:

- **Correctness**: Proper dimensional analysis with rational exponent handling
- **Performance**: Fast enough for real-time UI
- **Simplicity**: Clean rules for syntax and validation
- **Compatibility**: Follows GNU Units conventions for temperature
- **User Experience**: Clear error messages, unambiguous syntax
- **Extensibility**: Can add full rational numbers later

**Key Decisions:**

1. ✅ Use `double` with rational recovery via continued fractions (maxDenominator = 100)
2. ✅ Separate temperature units: `tempF/tempC` (absolute) vs `degF/degC` (difference)
3. ✅ Dimensional exponent validation: base dimensions must be divisible by rational denominator
4. ✅ Function/affine syntax: Parentheses required except when standalone (definition lookup/conversion target)
5. ✅ No prefixes on functions or affine units
6. ✅ Throw immediately on NaN-producing operations (fail-fast)
7. ✅ Warn when affine temperature units appear in compound expressions (tempF/hour → should be degF/hour)

**Next Steps:**

1. ✅ Review this design document
2. Implement `Rational` utility class with continued fractions algorithm
3. Implement `Quantity` class with:
   - All arithmetic operations
   - Dimensional exponent validation
   - NaN validation (throw immediately)
   - Conversion methods
4. Update lexer/parser for:
   - Function and affine syntax validation
   - Prefix restriction enforcement
   - Standalone token detection
   - Definition request node types
5. Implement both `tempX` and `degX` temperature units in unit database
6. Add `AffineUnitNode` and `DefinitionRequestNode` AST node types
7. Add comprehensive tests for:
   - Rational recovery
   - Dimensional validation
   - Temperature conversions
   - Function/affine syntax
   - NaN handling
8. Document temperature unit distinction for users
9. Integrate with expression evaluator

---

**Completed Design Areas:**

- ✅ Quantity Class & Arithmetic (this document)

**Remaining Design Areas** (from design_progress.md):

1. Worksheet System - Data model, state updates, templates
2. GNU Units Database Import - Parsing strategy, data transformation
3. Currency Rate Management - API selection, update scheduling
4. User Preferences & State Management - Complete model, persistence
5. UI/UX Design - Screen layouts, navigation, responsive design
6. Testing Strategy - Unit/integration/widget test approaches
7. Error Handling & User Feedback - Message wording, error recovery

**Next Recommended Design Area**: **Worksheet System** (major user-facing feature)
