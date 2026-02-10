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

~~~~ dart
class Quantity {
  final double value;           // Always stored as double
  final Dimension dimension;    // Dimensional information
  final Unit? displayUnit;      // Optional preferred display unit

  // Constructor
  Quantity(this.value, this.dimension, {this.displayUnit});

  // Convenience constructors
  Quantity.dimensionless(double value)
    : value = value, dimension = Dimension.dimensionless, displayUnit = null;

  Quantity.fromUnit(double value, Unit unit, UnitRepository repo)
    : value = value,
      dimension = unit.definition.toQuantity(1.0, repo).dimension,
      displayUnit = unit;
}
~~~~

### Precision Management

To minimize floating-point errors:

1. **Avoid intermediate conversions**: Perform calculations in a consistent unit system when possible
2. **Use epsilon comparisons**: When checking equality, use a small tolerance
3. **Round for display only**: Keep full precision internally, round only for UI
4. **Document limitations**: Make users aware that some operations may have small errors
5. **Rational recovery for exponents**: Use continued fractions to recover rational approximations from doubles

~~~~ dart
class Quantity {
  // Epsilon for floating-point comparisons (relative to magnitude)
  static const double epsilon = 1e-10;

  bool approximatelyEquals(Quantity other, {double tolerance = epsilon}) {
    if (dimension != other.dimension) return false;

    // Relative tolerance for large numbers, absolute for small
    final maxVal = max(value.abs(), other.value.abs());
    final effectiveTolerance = maxVal > 1.0 ? tolerance * maxVal : tolerance;

    return (value - other.value).abs() <= effectiveTolerance;
  }
}

// Utility for rational number recovery from doubles
class Rational {
  final int numerator;
  final int denominator;

  Rational(this.numerator, this.denominator);

  // Recover rational approximation using continued fractions
  // maxDenominator limits the complexity of the fraction
  static Rational fromDouble(double value, {int maxDenominator = 100}) {
    if (value.isNaN || value.isInfinite) {
      throw ArgumentException('Cannot convert NaN or Infinity to rational');
    }

    final sign = value < 0 ? -1 : 1;
    value = value.abs();

    // Handle integers directly
    if (value == value.truncate()) {
      return Rational((value * sign).toInt(), 1);
    }

    // Continued fraction algorithm
    int n0 = 0, d0 = 1;  // Previous convergent
    int n1 = 1, d1 = 0;  // Current convergent

    double remainder = value;

    for (int i = 0; i < 100; i++) {  // Limit iterations
      final a = remainder.floor();

      // Compute next convergent
      final n2 = a * n1 + n0;
      final d2 = a * d1 + d0;

      // Check if denominator exceeds limit
      if (d2 > maxDenominator) {
        // Return previous convergent
        return Rational(n1 * sign, d1);
      }

      // Check if we've converged sufficiently
      if ((n2 / d2 - value).abs() < 1e-10) {
        return Rational(n2 * sign, d2);
      }

      // Update for next iteration
      remainder = 1.0 / (remainder - a);
      n0 = n1; n1 = n2;
      d0 = d1; d1 = d2;

      // Check for convergence
      if (remainder.isInfinite || remainder.isNaN) {
        break;
      }
    }

    return Rational(n1 * sign, d1);
  }

  double toDouble() => numerator / denominator;

  @override
  String toString() => '$numerator/$denominator';

  @override
  bool operator ==(Object other) {
    if (other is! Rational) return false;
    return numerator * other.denominator == denominator * other.numerator;
  }

  @override
  int get hashCode => numerator.hashCode ^ denominator.hashCode;
}
~~~~

---


Quantity Class Design
---------------------

### Complete Class Structure

~~~~ dart
class Quantity {
  final double value;
  final Dimension dimension;
  final Unit? displayUnit;

  // Constructors
  Quantity(this.value, this.dimension, {this.displayUnit});

  Quantity.dimensionless(double value)
    : value = value, dimension = Dimension.dimensionless, displayUnit = null;

  Quantity.fromUnit(double value, Unit unit, UnitRepository repo)
    : value = value,
      dimension = unit.definition.toQuantity(1.0, repo).dimension,
      displayUnit = unit;

  // Arithmetic operations
  Quantity operator +(Quantity other) => add(other);
  Quantity operator -(Quantity other) => subtract(other);
  Quantity operator *(Quantity other) => multiply(other);
  Quantity operator /(Quantity other) => divide(other);
  Quantity operator -() => negate();

  Quantity add(Quantity other);
  Quantity subtract(Quantity other);
  Quantity multiply(Quantity other);
  Quantity divide(Quantity other);
  Quantity negate();
  Quantity power(num exponent);
  Quantity abs();

  // Conversion operations
  Quantity convertTo(Unit targetUnit, UnitRepository repo);
  Quantity reduceToPrimitives(UnitRepository repo);

  // Comparison operations
  bool isConformableWith(Quantity other);
  bool approximatelyEquals(Quantity other, {double tolerance = epsilon});
  int compareTo(Quantity other);  // throws if not conformable

  // Query operations
  bool get isDimensionless => dimension.isDimensionless;
  bool get isZero => value == 0.0;
  bool get isPositive => value > 0.0;
  bool get isNegative => value < 0.0;

  // Formatting
  String format(DisplaySettings settings);
  String toDebugString();

  // Equality and hashing
  @override
  bool operator ==(Object other);

  @override
  int get hashCode;

  // Constants
  static const double epsilon = 1e-10;
}
~~~~

### DisplaySettings

~~~~ dart
class DisplaySettings {
  final int precision;              // Number of decimal places (2-10)
  final NotationStyle notation;     // Plain, scientific, engineering
  final bool showDimension;         // Show dimension in output
  final bool useDisplayUnit;        // Use displayUnit if available

  DisplaySettings({
    this.precision = 6,
    this.notation = NotationStyle.plain,
    this.showDimension = false,
    this.useDisplayUnit = true,
  });
}

enum NotationStyle {
  plain,        // 1234.56
  scientific,   // 1.23456e3
  engineering,  // 1.23456k (with SI prefix if applicable)
}
~~~~

---


Arithmetic Operations
---------------------

### Addition and Subtraction

**Rule**: Only conformable quantities can be added or subtracted.

**Algorithm:**

1. Check that dimensions match (throw DimensionException if not)
2. Add/subtract the values
3. Keep the same dimension
4. Discard displayUnit (result is in primitive units)

~~~~ dart
Quantity add(Quantity other) {
  if (!dimension.isConformableWith(other.dimension)) {
    throw DimensionException(
      'Cannot add quantities with different dimensions: '
      '${dimension.canonicalRepresentation()} and '
      '${other.dimension.canonicalRepresentation()}'
    );
  }

  return Quantity(value + other.value, dimension);
}

Quantity subtract(Quantity other) {
  if (!dimension.isConformableWith(other.dimension)) {
    throw DimensionException(
      'Cannot subtract quantities with different dimensions: '
      '${dimension.canonicalRepresentation()} and '
      '${other.dimension.canonicalRepresentation()}'
    );
  }

  return Quantity(value - other.value, dimension);
}
~~~~

**Example:**

~~~~ dart
// 5 m + 3 m = 8 m
final a = Quantity(5, Dimension({m: 1}));
final b = Quantity(3, Dimension({m: 1}));
final c = a + b;  // Quantity(8, Dimension({m: 1}))

// 5 m + 3 s = ERROR
final d = Quantity(3, Dimension({s: 1}));
final e = a + d;  // throws DimensionException
~~~~

### Multiplication

**Rule**: Multiply values and multiply dimensions (add exponents).

**Algorithm:**

1. Multiply the values
2. Multiply the dimensions (add exponents for each primitive)
3. Discard displayUnit

~~~~ dart
Quantity multiply(Quantity other) {
  return Quantity(
    value * other.value,
    dimension.multiply(other.dimension),
  );
}
~~~~

**Example:**

~~~~ dart
// 5 m * 3 m = 15 m^2
final a = Quantity(5, Dimension({m: 1}));
final b = Quantity(3, Dimension({m: 1}));
final c = a * b;  // Quantity(15, Dimension({m: 2}))

// 5 m * 2 s = 10 m*s
final d = Quantity(2, Dimension({s: 1}));
final e = a * d;  // Quantity(10, Dimension({m: 1, s: 1}))

// 5 m * 3 (dimensionless) = 15 m
final f = Quantity.dimensionless(3);
final g = a * f;  // Quantity(15, Dimension({m: 1}))
~~~~

### Division

**Rule**: Divide values and divide dimensions (subtract exponents).

**Algorithm:**

1. Check for division by zero (throw EvalException if zero)
2. Divide the values
3. Divide the dimensions (subtract exponents for each primitive)
4. Discard displayUnit

~~~~ dart
Quantity divide(Quantity other) {
  if (other.value == 0.0) {
    throw EvalException('Division by zero');
  }

  return Quantity(
    value / other.value,
    dimension.divide(other.dimension),
  );
}
~~~~

**Example:**

~~~~ dart
// 10 m / 2 s = 5 m/s
final a = Quantity(10, Dimension({m: 1}));
final b = Quantity(2, Dimension({s: 1}));
final c = a / b;  // Quantity(5, Dimension({m: 1, s: -1}))

// 10 m / 2 m = 5 (dimensionless)
final d = Quantity(2, Dimension({m: 1}));
final e = a / d;  // Quantity(5, Dimension.dimensionless)

// 10 m / 0 = ERROR
final f = Quantity(0, Dimension({m: 1}));
final g = a / f;  // throws EvalException
~~~~

### Negation and Absolute Value

~~~~ dart
Quantity negate() {
  return Quantity(-value, dimension, displayUnit: displayUnit);
}

Quantity abs() {
  return Quantity(value.abs(), dimension, displayUnit: displayUnit);
}
~~~~

### Exponentiation

**Rule**: Raise value to power and raise dimension to power (multiply all exponents).

**Dimensional Analysis Constraint**: For dimensioned quantities, the exponent must be rational, and all dimension exponents must be divisible by the exponent's denominator.

**Algorithm:**

1. Handle special cases (zero, one)
2. If base has dimensions, recover rational approximation of exponent
3. Validate that dimension exponents are compatible with the rational exponent
4. Compute `value ^ exponent`
5. Multiply all dimension exponents by the power exponent

~~~~ dart
Quantity power(num exponent) {
  // Special cases
  if (exponent == 0) {
    return Quantity.dimensionless(1.0);
  }

  if (exponent == 1) {
    return this;
  }

  // For dimensionless quantities, any exponent is allowed
  if (dimension.isDimensionless) {
    // Check for negative base with fractional exponent
    if (value < 0 && exponent is double && exponent != exponent.truncate()) {
      throw EvalException(
        'Cannot raise negative number to fractional power: $value ^ $exponent'
      );
    }

    return Quantity(
      pow(value, exponent).toDouble(),
      Dimension.dimensionless,
    );
  }

  // For dimensioned quantities, exponent must be rational
  // and all dimension exponents must be divisible by the denominator

  Rational rationalExponent;

  if (exponent is int) {
    rationalExponent = Rational(exponent, 1);
  } else {
    // Recover rational approximation from double
    rationalExponent = Rational.fromDouble(exponent.toDouble());

    // Verify the recovered rational is close enough to the original
    final recovered = rationalExponent.toDouble();
    if ((recovered - exponent).abs() > 1e-10) {
      throw EvalException(
        'Cannot determine rational approximation for exponent: $exponent'
      );
    }
  }

  // Check that all dimension exponents are divisible by the denominator
  // For example: (m^2)^(1/2) is valid because 2 is divisible by 2
  // But (m^3)^(1/2) is invalid because 3 is not divisible by 2
  for (var entry in dimension.units.entries) {
    final dimExp = entry.value;

    // Check if dimExp * numerator is divisible by denominator
    // (dimExp * p/q should give an integer result when multiplied)
    final resultNumerator = (dimExp * rationalExponent.numerator);

    if (resultNumerator % rationalExponent.denominator != 0) {
      throw DimensionException(
        'Cannot raise dimension ${entry.key}^$dimExp to power $exponent: '
        'result would be ${entry.key}^${dimExp * exponent} which is not integral'
      );
    }
  }

  // Check for negative base with fractional exponent
  if (value < 0 && rationalExponent.denominator != 1) {
    throw EvalException(
      'Cannot raise negative number to fractional power: $value ^ $exponent'
    );
  }

  return Quantity(
    pow(value, exponent).toDouble(),
    dimension.power(exponent),
  );
}
~~~~

**Example:**

~~~~ dart
// (3 m)^2 = 9 m^2
final a = Quantity(3, Dimension({m: 1}));
final b = a.power(2);  // Quantity(9, Dimension({m: 2}))

// (4 m^2)^0.5 = 2 m
// 0.5 recovers as 1/2, and 2 is divisible by 2 ✓
final c = Quantity(4, Dimension({m: 2}));
final d = c.power(0.5);  // Quantity(2, Dimension({m: 1}))

// (5 m/s)^3 = 125 m^3/s^3
final e = Quantity(5, Dimension({m: 1, s: -1}));
final f = e.power(3);  // Quantity(125, Dimension({m: 3, s: -3}))

// (8 m^3)^(1/3) = 2 m
// 1/3 as rational, 3 is divisible by 3 ✓
final g = Quantity(8, Dimension({m: 3}));
final h = g.power(1.0/3.0);  // Quantity(2, Dimension({m: 1}))

// (5 m^3)^0.5 = ERROR
// 0.5 recovers as 1/2, but 3 is not divisible by 2 ✗
final i = Quantity(5, Dimension({m: 3}));
final j = i.power(0.5);  // throws DimensionException
~~~~

---


Unit Conversion Algorithm
-------------------------

### Overview

Converting from one unit to another requires:

1. Verifying the units are conformable (same dimension)
2. Finding the conversion factor between them
3. Applying the conversion factor

### Conversion Factor Calculation

The conversion factor is the ratio of the two units when expressed in primitive units.

**Algorithm: `getConversionFactor(fromUnit, toUnit, repo)`**

~~~~ dart
double getConversionFactor(Unit fromUnit, Unit toUnit, UnitRepository repo) {
  // 1. Check conformability
  final fromQuantity = fromUnit.definition.toQuantity(1.0, repo);
  final toQuantity = toUnit.definition.toQuantity(1.0, repo);

  if (!fromQuantity.dimension.isConformableWith(toQuantity.dimension)) {
    throw DimensionException(
      'Cannot convert between non-conformable units: '
      '${fromUnit.id} (${fromQuantity.dimension.canonicalRepresentation()}) and '
      '${toUnit.id} (${toQuantity.dimension.canonicalRepresentation()})'
    );
  }

  // 2. Both units reduced to primitives, compute conversion factor by division
  // fromQuantity.value represents "1 fromUnit" in primitive units
  // toQuantity.value represents "1 toUnit" in primitive units
  // To convert from fromUnit to toUnit: multiply by (fromQuantity.value / toQuantity.value)
  return fromQuantity.value / toQuantity.value;
}
~~~~

**Example:**

~~~~ dart
// Convert miles to meters
// miles.toQuantity(1.0, repo) = Quantity(1609.344, {m: 1})
// meters.toQuantity(1.0, repo) = Quantity(1.0, {m: 1})
// factor = 1609.344 / 1.0 = 1609.344

// Convert feet to meters
// feet.toQuantity(1.0, repo) = Quantity(0.3048, {m: 1})
// meters.toQuantity(1.0, repo) = Quantity(1.0, {m: 1})
// factor = 0.3048 / 1.0 = 0.3048

// Convert miles to feet
// miles.toQuantity(1.0, repo) = Quantity(1609.344, {m: 1})
// feet.toQuantity(1.0, repo) = Quantity(0.3048, {m: 1})
// factor = 1609.344 / 0.3048 = 5280
~~~~

### Quantity Conversion

~~~~ dart
Quantity convertTo(Unit targetUnit, UnitRepository repo) {
  // Handle case where we don't have a displayUnit
  if (displayUnit == null) {
    // Quantity is already in primitive units
    // We need to convert from primitives to targetUnit

    // Check conformability
    final targetQuantity = targetUnit.definition.toQuantity(1.0, repo);
    if (!dimension.isConformableWith(targetQuantity.dimension)) {
      throw DimensionException(
        'Cannot convert to non-conformable unit: '
        '${dimension.canonicalRepresentation()} to ${targetUnit.id}'
      );
    }

    // Convert from base primitives to target
    // this.value is in primitives, targetQuantity.value is "1 targetUnit" in primitives
    // So to convert: divide by targetQuantity.value
    final convertedValue = value / targetQuantity.value;

    return Quantity(
      convertedValue,
      targetQuantity.dimension,
      displayUnit: targetUnit,
    );
  }

  // We have a displayUnit, so convert from it to targetUnit
  final factor = getConversionFactor(displayUnit!, targetUnit, repo);

  return Quantity(
    value * factor,
    targetUnit.definition.toQuantity(1.0, repo).dimension,
    displayUnit: targetUnit,
  );
}
~~~~

**Example Usage:**

~~~~ dart
// Convert 5 miles to meters
final miles = repo.getUnit('mi')!;
final meters = repo.getUnit('m')!;
final distance = Quantity.fromUnit(5, miles, repo);
final distanceInMeters = distance.convertTo(meters, repo);
// distanceInMeters.value = 8046.72
// distanceInMeters.displayUnit = meters

// Convert 100 Fahrenheit to Celsius
final fahrenheit = repo.getUnit('degF')!;
final celsius = repo.getUnit('degC')!;
final temp = Quantity.fromUnit(100, fahrenheit, repo);
final tempInCelsius = temp.convertTo(celsius, repo);
// tempInCelsius.value ≈ 37.78
~~~~

### Handling Affine Conversions (Temperature)

Temperature units with offsets (like Celsius/Fahrenheit) require special handling:

**Key Insight**: Affine conversions (with offset) are only valid for absolute values, not for differences or in compound units.

~~~~ dart
// In AffineDefinition:
@override
Quantity toQuantity(double value, UnitRepository repo) {
  // Convert from this unit to base (e.g., Celsius to Kelvin)
  // value_kelvin = (value_celsius + offset) * factor + base_offset
  var baseUnit = repo.getUnit(baseUnitId);
  var baseQuantity = baseUnit.definition.toQuantity((value + offset) * factor, repo);
  return baseQuantity;
}
~~~~

**Important**: When temperature appears in compound units (e.g., °C/s), the offset should NOT be applied. This is a complex edge case that may need additional validation.

For MVP, we can document this limitation and handle it in future versions.

---


Unit Reduction Algorithm
------------------------

### Purpose

Reduce a quantity to its representation in primitive units only. This is useful for:

- Displaying results in canonical form
- Comparing quantities from different unit systems
- Debugging dimensional analysis

### Algorithm: `reduceToPrimitives(repo)`

~~~~ dart
Quantity reduceToPrimitives(UnitRepository repo) {
  if (displayUnit == null) {
    // Already in primitive units
    return this;
  }

  // Convert to base primitives using the unit's definition
  // toQuantity(value, repo) gives us the value in primitive units
  final baseQuantity = displayUnit!.definition.toQuantity(value, repo);

  // Return with no displayUnit (in primitive form)
  return Quantity(baseQuantity.value, baseQuantity.dimension);
}
~~~~

**Example:**

~~~~ dart
// 5 miles -> ~8046.72 meters
final miles = repo.getUnit('mi')!;
final distance = Quantity.fromUnit(5, miles, repo);
final reduced = distance.reduceToPrimitives(repo);
// reduced.value = 8046.72
// reduced.dimension = {m: 1}
// reduced.displayUnit = null

// 10 newtons -> 10 kg*m/s^2
final newtons = repo.getUnit('N')!;
final force = Quantity.fromUnit(10, newtons, repo);
final reduced = force.reduceToPrimitives(repo);
// reduced.value = 10
// reduced.dimension = {kg: 1, m: 1, s: -2}
// reduced.displayUnit = null
~~~~

### Compound Unit Reduction

For compound units defined as expressions:

~~~~ dart
// CompoundDefinition needs evaluator access
class CompoundDefinition extends UnitDefinition {
  final String expr;  // e.g., "kg*m/s^2" for Newton

  // Cache the parsed expression result
  Quantity? _baseQuantity;

  @override
  Quantity toQuantity(double value, UnitRepository repo) {
    if (_baseQuantity == null) {
      // Parse and evaluate the expression to get the base quantity
      final parser = ExpressionParser(repo);
      _baseQuantity = parser.parse(expr).evaluate(Context(repo));
    }

    // The compound unit is defined as: 1 unitId = _baseQuantity
    // So value unitId = value * _baseQuantity in base units
    return Quantity(
      value * _baseQuantity!.value,
      _baseQuantity!.dimension,
    );
  }
}
~~~~

---


Edge Cases and Error Handling
-----------------------------

### 1. Division by Zero

**Scenario**: `quantity / Quantity(0, ...)`

**Handling**: Throw `EvalException` with clear message

~~~~ dart
Quantity divide(Quantity other) {
  if (other.value == 0.0) {
    throw EvalException('Division by zero');
  }
  // ... rest of division logic
}
~~~~

### 2. Very Large Numbers

**Scenario**: Values approaching `double.maxFinite` (~1.8e308)

**Handling**:

- Allow operations to proceed
- Result may be `double.infinity` if overflow occurs
- Display as "∞" in UI with appropriate unit
- Document limitation in user guide

~~~~ dart
Quantity multiply(Quantity other) {
  final result = value * other.value;

  if (result.isInfinite && !value.isInfinite && !other.value.isInfinite) {
    // Log warning about overflow (optional)
    // Continue with infinity result
  }

  return Quantity(result, dimension.multiply(other.dimension));
}

// In format method:
String format(DisplaySettings settings) {
  if (value.isInfinite) {
    return value > 0 ? '∞' : '-∞';
  }
  // ... normal formatting
}
~~~~

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

**Implementation:**

~~~~ dart
class Quantity {
  final double value;
  final Dimension dimension;
  final Unit? displayUnit;

  // Constructor validates value
  Quantity(double value, this.dimension, {this.displayUnit})
    : value = _validateValue(value);

  static double _validateValue(double value) {
    if (value.isNaN) {
      throw EvalException('Invalid computation resulted in undefined value (NaN)');
    }
    // Allow infinity - it's mathematically meaningful
    return value;
  }

  // Operations check for NaN before returning
  Quantity multiply(Quantity other) {
    final result = value * other.value;
    if (result.isNaN && !value.isNaN && !other.isNaN) {
      throw EvalException('Multiplication resulted in undefined value');
    }
    return Quantity(result, dimension.multiply(other.dimension));
  }

  Quantity divide(Quantity other) {
    if (other.value == 0.0) {
      throw EvalException('Division by zero');
    }

    final result = value / other.value;
    if (result.isNaN && !value.isNaN && !other.isNaN) {
      throw EvalException('Division resulted in undefined value');
    }
    return Quantity(result, dimension.divide(other.dimension));
  }
}

// In mathematical functions:
Quantity sqrt(Quantity q) {
  if (!q.dimension.isDimensionless) {
    throw DimensionException('sqrt requires dimensionless argument or even powers');
  }

  if (q.value < 0) {
    throw EvalException('Cannot take square root of negative number: ${q.value}');
  }

  return Quantity(math.sqrt(q.value), Dimension.dimensionless);
}

Quantity log(Quantity q) {
  if (!q.dimension.isDimensionless) {
    throw DimensionException('log requires dimensionless argument');
  }

  if (q.value <= 0) {
    throw EvalException('Cannot take logarithm of non-positive number: ${q.value}');
  }

  return Quantity(math.log(q.value), Dimension.dimensionless);
}

Quantity asin(Quantity q) {
  if (!q.dimension.isDimensionless) {
    throw DimensionException('asin requires dimensionless argument');
  }

  if (q.value < -1 || q.value > 1) {
    throw EvalException('asin requires argument in range [-1, 1], got ${q.value}');
  }

  return Quantity(math.asin(q.value), Dimension.dimensionless);
}
~~~~

**Error Messages for Common Cases:**

| Operation   | Error Message                                        |
|-------------|------------------------------------------------------|
| `sqrt(-4)`  | "Cannot take square root of negative number: -4.0"   |
| `log(0)`    | "Cannot take logarithm of non-positive number: 0.0"  |
| `log(-5)`   | "Cannot take logarithm of non-positive number: -5.0" |
| `asin(2)`   | "asin requires argument in range [-1, 1], got 2.0"   |
| `0 / 0`     | "Division by zero"                                   |
| `tan(pi/2)` | Allow infinity (mathematically valid limit)          |

**Testing:**

~~~~ dart
group('NaN handling', () {
  test('sqrt of negative throws error', () {
    final neg = Quantity(-4, Dimension.dimensionless);
    expect(() => sqrt(neg),
           throwsA(isA<EvalException>().having(
             (e) => e.message, 'message', contains('square root of negative')
           )));
  });

  test('log of zero throws error', () {
    final zero = Quantity(0, Dimension.dimensionless);
    expect(() => log(zero),
           throwsA(isA<EvalException>().having(
             (e) => e.message, 'message', contains('logarithm of non-positive')
           )));
  });

  test('asin out of range throws error', () {
    final outOfRange = Quantity(2, Dimension.dimensionless);
    expect(() => asin(outOfRange),
           throwsA(isA<EvalException>().having(
             (e) => e.message, 'message', contains('range [-1, 1]')
           )));
  });

  test('division by zero throws error', () {
    final a = Quantity(10, Dimension({'m': 1}));
    final zero = Quantity(0, Dimension({'s': 1}));
    expect(() => a / zero,
           throwsA(isA<EvalException>().having(
             (e) => e.message, 'message', contains('Division by zero')
           )));
  });

  test('infinity is allowed in results', () {
    final big = Quantity(1e308, Dimension.dimensionless);
    final result = big * big;
    expect(result.value.isInfinite, true);
  });
});
~~~~

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

Define two types of temperature units for each scale:

~~~~ dart
// Absolute Fahrenheit (with offset to Kelvin)
Unit(
  id: "tempF",
  aliases: ["degreeF", "fahrenheit"],
  description: "Absolute temperature in Fahrenheit",
  definition: AffineDefinition(
    factor: 5.0/9.0,           // Conversion factor
    offset: -32.0,             // Subtract 32 before multiplying
    baseUnitId: "tempK"        // Base is absolute Kelvin
  )
)

// Fahrenheit degree size (no offset)
Unit(
  id: "degF",
  aliases: ["deltaF", "fahrenheitDegree"],
  description: "Fahrenheit temperature difference (degree size)",
  definition: LinearDefinition(
    factor: 5.0/9.0,           // Only the conversion factor
    baseUnitId: "degK"         // Base is Kelvin degree size
  )
)

// Similar for Celsius:
// tempC: affine with offset to tempK
// degC: linear to degK
~~~~

**Key Insight**:

- `tempK` (absolute Kelvin) has dimension {K: 1}
- `degK` (Kelvin degree size) also has dimension {K: 1} but different semantics
- For MVP, both can share the same dimension since they're conformable
- The distinction is in which unit is used in expressions

**Usage Rules:**

1. **Absolute temperature**: Use `tempF`, `tempC`, `tempK` for single temperature values
2. **Temperature differences**: Use `degF`, `degC`, `degK` when subtracting temperatures or in rates
3. **Compound units**: Always use degree units (degF, degC) not absolute (tempF, tempC)
   - ✓ `10 degC/s` (temperature rate)
   - ✗ `10 tempC/s` (meaningless - can't have "absolute temperature per second")

**Database Schema:**

Store both variants:

~~~~ sql
-- Absolute Fahrenheit
INSERT INTO units VALUES ('tempF', 'Absolute temperature in Fahrenheit', 'affine',
  '{"factor": 0.5555556, "offset": -32, "baseUnitId": "tempK"}', 0);

-- Fahrenheit degree size
INSERT INTO units VALUES ('degF', 'Fahrenheit temperature difference', 'linear',
  '{"factor": 0.5555556, "baseUnitId": "degK"}', 0);

-- Similar for tempC/degC, and tempK/degK (where tempK = degK as both primitive)
~~~~

**Testing:**

~~~~ dart
group('Temperature units', () {
  test('absolute temperature conversion', () {
    final result = parse('tempF(100)').evaluate(context);
    final tempC = repo.getUnit('tempC')!;
    final converted = result.convertTo(tempC, repo);
    expect(converted.value, closeTo(37.78, 0.01));
  });

  test('temperature difference conversion', () {
    final result = parse('100 degF').evaluate(context);
    final degC = repo.getUnit('degC')!;
    final converted = result.convertTo(degC, repo);
    expect(converted.value, closeTo(55.56, 0.01));
  });

  test('temperature rate uses degree units', () {
    // 10 degF/hour in degC/hour
    final result = parse('10 degF / hour').evaluate(context);
    expect(result.dimension, Dimension({'K': 1, 'hour': -1}));
  });

  test('affine unit as conversion target', () {
    final input = parse('tempF(68)').evaluate(context);
    final tempC = repo.getUnit('tempC')!;
    final converted = input.convertTo(tempC, repo);
    expect(converted.value, closeTo(20, 0.1));
  });
});
~~~~

**Temperature Subtraction:**

When subtracting absolute temperatures, the result should be a temperature difference (degree unit), not an absolute temperature:

~~~~
100 tempF - 32 tempF = 68 degF  (difference in size, not absolute)
~~~~

For MVP, the subtraction operation returns the same dimension (since tempF and degF both have dimension {K: 1}). However, semantically the result is a difference.

**Future Enhancement**: Track provenance of quantities to know if they came from absolute temperature operations, and automatically convert result to degree units when subtracting absolutes.

**Documentation for Users:**

Include in help/docs:

~~~~
Temperature Units: Absolute vs. Difference

Unitary provides two types of temperature units following GNU Units convention:

Absolute Temperature (for single temperature values):
  - tempF, tempC, tempK (Kelvin is both absolute and difference)
  - Use for: "The water is 100 tempC"
  - Conversion includes offset: 100 tempF = 37.78 tempC
  - Syntax: tempF(value) in expressions

Temperature Difference (for intervals and rates):
  - degF, degC, degK
  - Use for: "The temperature increased by 10 degC"
  - Use for: "The reaction proceeds at 5 degC/min"
  - Conversion is linear: 100 degF = 55.56 degC (no offset)
  - Syntax: value degF (normal unit syntax)

Quick Guide:
  ✓ "tempF(100)"          (absolute temperature in expression)
  ✓ "10 degC/hour"        (temperature rate)
  ✓ "tempC"               (as conversion target or definition lookup)
  ✗ "100 tempF"           (error in expressions - use tempF(100))
  ✗ "10 tempC/hour"       (incorrect - use degC for rates)
~~~~

**Implementation Notes:**

1. Both `tempX` and `degX` share the same dimension {K: 1}
2. Both are conformable and can be converted between each other
3. The semantic distinction (absolute vs. difference) is in the unit name and user's intent
4. AffineDefinition handles the offset for absolute temperatures automatically
5. See next section for syntax rules on affine units

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

~~~~ dart
// Token class - track if standalone
class Token {
  final TokenType type;
  final String lexeme;
  final Object? literal;
  final int line;
  final int column;
  bool isStandalone = false;  // True if this is the only token

  Token(this.type, this.lexeme, this.literal, this.line, this.column);
}

// Lexer - identify but don't validate yet
class Lexer {
  List<Token> scanTokens() {
    while (!isAtEnd()) {
      start = current;
      scanToken();
    }

    addToken(TokenType.eof);

    // Mark standalone tokens
    var nonEofTokens = tokens.where((t) => t.type != TokenType.eof).toList();
    if (nonEofTokens.length == 1) {
      nonEofTokens[0].isStandalone = true;
    }

    return tokens;
  }

  void scanIdentifier() {
    while (isAlphaNumeric(peek())) advance();
    String text = source.substring(start, current);

    // Check if it's a function
    if (isFunction(text)) {
      addToken(TokenType.function, text);
      return;
    }

    // Try to parse as unit (with optional prefix)
    var unitMatch = tryParseUnit(text);
    if (unitMatch != null) {
      // Validate prefix restrictions
      if (unitMatch.prefix != null) {
        if (isFunction(unitMatch.unitName)) {
          throw LexException(
            "Cannot attach prefix '${unitMatch.prefix!.id}' to function '${unitMatch.unitName}'",
            line, column
          );
        }
        if (unitMatch.unit.isAffine) {
          throw LexException(
            "Cannot attach prefix '${unitMatch.prefix!.id}' to affine unit '${unitMatch.unitName}'",
            line, column
          );
        }
      }

      addToken(TokenType.unit, unitMatch);
      return;
    }

    throw LexException("Unknown identifier: $text", line, column);
  }
}

// Parser - validate function/affine syntax
class Parser {
  List<Token> tokens;
  int current = 0;

  Parser(this.tokens) {
    _validateFunctionAndAffineUnits();
  }

  void _validateFunctionAndAffineUnits() {
    for (int i = 0; i < tokens.length - 1; i++) {
      var token = tokens[i];
      var nextToken = tokens[i + 1];

      // Skip standalone tokens (definition requests)
      if (token.isStandalone) {
        continue;
      }

      // Check functions
      if (token.type == TokenType.function) {
        if (nextToken.type != TokenType.leftParen) {
          throw ParseException(
            "Function '${token.lexeme}' requires arguments: ${token.lexeme}(...)",
            token.line, token.column
          );
        }
      }

      // Check affine units
      if (token.type == TokenType.unit) {
        var unitMatch = token.literal as UnitMatch;
        if (unitMatch.unit.isAffine) {
          if (nextToken.type != TokenType.leftParen) {
            throw ParseException(
              "Affine unit '${token.lexeme}' requires function syntax: ${token.lexeme}(...)",
              token.line, token.column
            );
          }
        }
      }
    }
  }

  ASTNode parse() {
    // Special case: single token input (definition request)
    if (tokens.length == 2 && tokens[0].isStandalone) {
      var token = tokens[0];

      if (token.type == TokenType.unit) {
        return DefinitionRequestNode(token.literal as UnitMatch);
      }

      if (token.type == TokenType.function) {
        return FunctionDefinitionRequestNode(token.lexeme);
      }
    }

    // Normal expression parsing
    return expression();
  }

  ASTNode primary() {
    // ... number, paren cases ...

    if (match(TokenType.unit)) {
      var unitToken = previous();
      var unitMatch = unitToken.literal as UnitMatch;

      // If affine unit followed by '(', parse as function call
      if (unitMatch.unit.isAffine && check(TokenType.leftParen)) {
        consume(TokenType.leftParen, "Expected '('");
        var arg = expression();
        consume(TokenType.rightParen, "Expected ')' after affine unit argument");

        return AffineUnitNode(unitMatch, arg);
      }

      // Regular unit
      return UnitNode(unitMatch);
    }

    if (match(TokenType.function)) {
      return parseFunctionCall();
    }

    // ...
  }
}

// New AST nodes
class DefinitionRequestNode extends ASTNode {
  final UnitMatch unitMatch;

  DefinitionRequestNode(this.unitMatch);

  @override
  Quantity evaluate(Context context) {
    throw EvalException('Definition request nodes should not be evaluated');
  }

  String getDefinition(Context context) {
    var unit = unitMatch.unit;
    if (unit.isAffine) {
      var affine = unit.definition as AffineDefinition;
      return 'Definition: ${unit.id}(x) = (x + ${affine.offset}) × ${affine.factor} ${affine.baseUnitId}';
    }
    // ... other definition types
  }
}

class FunctionDefinitionRequestNode extends ASTNode {
  final String functionName;

  FunctionDefinitionRequestNode(this.functionName);

  @override
  Quantity evaluate(Context context) {
    throw EvalException('Function definition request should not be evaluated');
  }

  String getDefinition() {
    return 'Function: $functionName(x) - ...';
  }
}

class AffineUnitNode extends ASTNode {
  final UnitMatch unitMatch;
  final ASTNode argument;

  AffineUnitNode(this.unitMatch, this.argument);

  @override
  Quantity evaluate(Context context) {
    var argQuantity = argument.evaluate(context);

    // Argument must be dimensionless
    if (!argQuantity.dimension.isDimensionless) {
      throw DimensionException(
        'Affine unit ${unitMatch.unitName} requires dimensionless argument, '
        'got ${argQuantity.dimension.canonicalRepresentation()}'
      );
    }

    var unit = unitMatch.unit;
    var value = argQuantity.value;

    // Apply prefix if present (though we blocked this in lexer)
    if (unitMatch.prefix != null) {
      value *= unitMatch.prefix!.factor;
    }

    // Convert using affine definition
    var quantity = unit.definition.toQuantity(value, context.repo);

    return Quantity(
      quantity.value,
      quantity.dimension,
      displayUnit: unit
    );
  }
}
~~~~

### Examples

~~~~ dart
// Valid expressions:
parse('sin(0.5)')                    → FunctionNode ✓
parse('tempF(60)')                   → AffineUnitNode ✓
parse('tempF(32) + 10 degF')         → BinaryOpNode (add) ✓
parse('2 * tempF(100)')              → BinaryOpNode (multiply) ✓
parse('60 degF')                     → BinaryOpNode (implicit mult) ✓
parse('kilometer')                   → UnitNode ✓

// Valid standalone (definition requests):
parse('sin')                         → FunctionDefinitionRequestNode ✓
parse('tempF')                       → DefinitionRequestNode ✓
parse('tempC')                       → DefinitionRequestNode ✓
parse('meter')                       → DefinitionRequestNode ✓

// Valid conversion targets:
convert('tempF(68)', 'tempC')        → 20 ✓
convert('5 m', 'ft')                 → 16.404 ✓

// Invalid expressions (errors):
parse('sin 0.5')                     → Error: "Function 'sin' requires arguments" ✗
parse('tempF 60')                    → Error: "Affine unit 'tempF' requires function syntax" ✗
parse('60 tempF')                    → Error (same) ✗
parse('millicos(2)')                 → Error: "Cannot attach prefix to function" ✗
parse('megatempF(60)')               → Error: "Cannot attach prefix to affine unit" ✗

// Edge cases:
parse('5')                           → NumberNode (not standalone special case)
parse('(tempF)')                     → Counts as expression (parens = multiple tokens)
~~~~

### Testing

~~~~ dart
group('Function and affine syntax', () {
  test('function requires parentheses in expressions', () {
    expect(() => parse('sin 0.5'), throwsA(contains('requires arguments')));
    expect(() => parse('cos pi'), throwsA(contains('requires arguments')));
    expect(parse('sin(0.5)'), isA<FunctionNode>());
  });

  test('affine unit requires parentheses in expressions', () {
    expect(() => parse('tempF 60'), throwsA(contains('requires function syntax')));
    expect(() => parse('60 tempF'), throwsA(contains('requires function syntax')));
    expect(parse('tempF(60)'), isA<AffineUnitNode>());
  });

  test('function standalone is definition request', () {
    expect(parse('sin'), isA<FunctionDefinitionRequestNode>());
    expect(parse('sqrt'), isA<FunctionDefinitionRequestNode>());
  });

  test('affine unit standalone is definition request', () {
    expect(parse('tempF'), isA<DefinitionRequestNode>());
    expect(parse('tempC'), isA<DefinitionRequestNode>());
  });

  test('affine unit as conversion target', () {
    var result = convert('tempF(68)', 'tempC', repo);
    expect(result.value, closeTo(20, 0.1));
  });

  test('linear unit allows postfix syntax', () {
    var result1 = parse('60 degF').evaluate(context);
    var result2 = parse('degF(60)').evaluate(context);  // Also multiplication
    expect(result1.value, result2.value);
  });

  test('no prefixes on functions', () {
    expect(() => parse('millicos(2)'), throwsA(contains('Cannot attach prefix')));
    expect(() => parse('kilosin(2)'), throwsA(contains('Cannot attach prefix')));
  });

  test('no prefixes on affine units', () {
    expect(() => parse('megatempF(60)'), throwsA(contains('Cannot attach prefix')));
    expect(() => parse('millitempC(20)'), throwsA(contains('Cannot attach prefix')));
  });

  test('prefixes allowed on linear units', () {
    expect(parse('kilometer'), isA<UnitNode>());
    expect(parse('5 km').evaluate(context).value, 5);
  });

  test('affine argument must be dimensionless', () {
    expect(() => parse('tempF(60 m)').evaluate(context),
           throwsA(isA<DimensionException>()));
    expect(parse('tempF(60)').evaluate(context), isA<Quantity>());
  });
});
~~~~

### Warning About Temperature in Compound Units

When parsing expressions, detect if `tempF` or `tempC` appears in the numerator of a compound expression and issue a warning:

~~~~ dart
// In evaluator or validator:
void validateTemperatureUsage(ASTNode node) {
  if (node is BinaryOpNode && node.operator == TokenType.divide) {
    // Check if left side contains affine temperature units
    if (containsAffineUnit(node.left)) {
      warnings.add(
        'Warning: Using absolute temperature unit (tempF/tempC) in rate expression. '
        'Did you mean to use degree units (degF/degC)?'
      );
    }
  }
}

bool containsAffineUnit(ASTNode node) {
  if (node is AffineUnitNode) return true;
  if (node is BinaryOpNode) {
    return containsAffineUnit(node.left) || containsAffineUnit(node.right);
  }
  return false;
}
~~~~

**Implementation Notes:**

1. No special token types needed - use existing `TokenType.function` and `TokenType.unit`
2. Validation happens in two stages: prefix restrictions in lexer, parenthesis requirements in parser
3. Standalone detection happens after full tokenization
4. AffineUnitNode is a distinct AST node type requiring dimensionless argument
5. Temperature usage warnings can be added as a linting/validation pass

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

Define two types of temperature units for each scale:

~~~~ dart
// Absolute Fahrenheit (with offset to Kelvin)
Unit(
  id: "tempF",
  aliases: ["degreeF", "fahrenheit"],
  description: "Absolute temperature in Fahrenheit",
  definition: AffineDefinition(
    factor: 5.0/9.0,           // Conversion factor
    offset: -32.0,             // Subtract 32 before multiplying
    baseUnitId: "tempK"        // Base is absolute Kelvin
  )
)

// Fahrenheit degree size (no offset)
Unit(
  id: "degF",
  aliases: ["deltaF", "fahrenheitDegree"],
  description: "Fahrenheit temperature difference (degree size)",
  definition: LinearDefinition(
    factor: 5.0/9.0,           // Only the conversion factor
    baseUnitId: "degK"         // Base is Kelvin degree size
  )
)

// Similar for Celsius:
// tempC: affine with offset to tempK
// degC: linear to degK
~~~~

**Key Insight**:

- `tempK` (absolute Kelvin) has dimension {K: 1}
- `degK` (Kelvin degree size) also has dimension {K: 1} but different semantics
- For MVP, both can share the same dimension since they're conformable
- The distinction is in which unit is used in expressions

**Usage Rules:**

1. **Absolute temperature**: Use `tempF`, `tempC`, `tempK` for single temperature values
2. **Temperature differences**: Use `degF`, `degC`, `degK` when subtracting temperatures or in rates
3. **Compound units**: Always use degree units (degF, degC) not absolute (tempF, tempC)
   - ✓ `10 degC/s` (temperature rate)
   - ✗ `10 tempC/s` (meaningless - can't have "absolute temperature per second")

**Parser Considerations:**

The parser should guide users toward correct usage:

- When parsing compound units, if `tempF` or `tempC` appears, suggest using `degF` or `degC` instead
- In freeform mode, allow both but document the distinction

**Database Schema:**

Store both variants:

~~~~ sql
-- Absolute Fahrenheit
INSERT INTO units VALUES ('tempF', 'Absolute temperature in Fahrenheit', 'affine',
  '{"factor": 0.5555556, "offset": -32, "baseUnitId": "tempK"}', 0);

-- Fahrenheit degree size
INSERT INTO units VALUES ('degF', 'Fahrenheit temperature difference', 'linear',
  '{"factor": 0.5555556, "baseUnitId": "degK"}', 0);

-- Similar for tempC/degC, and tempK/degK (where tempK = degK as both primitive)
~~~~

**Testing:**

~~~~ dart
group('Temperature units', () {
  test('absolute temperature conversion', () {
    final tempF = repo.getUnit('tempF')!;
    final tempC = repo.getUnit('tempC')!;
    final temp = Quantity.fromUnit(100, tempF, repo);
    final converted = temp.convertTo(tempC, repo);
    expect(converted.value, closeTo(37.78, 0.01));
  });

  test('temperature difference conversion', () {
    final degF = repo.getUnit('degF')!;
    final degC = repo.getUnit('degC')!;
    final diff = Quantity.fromUnit(100, degF, repo);
    final converted = diff.convertTo(degC, repo);
    expect(converted.value, closeTo(55.56, 0.01));
  });

  test('temperature rate uses degree units', () {
    // 10 degF/hour = 5.56 degC/hour
    final parser = ExpressionParser(repo);
    final result = parser.parse('10 degF / hour').evaluate();
    final degCPerHour = parser.parse('degC / hour').evaluate();
    final converted = result.convertTo(degCPerHour, repo);
    expect(converted.value, closeTo(5.56, 0.01));
  });

  test('cannot use absolute temp in rates', () {
    // This should either error or warn (for MVP, may allow but document)
    final parser = ExpressionParser(repo);
    // "10 tempF / hour" - technically parseable but semantically wrong
    // For MVP: document that this is incorrect usage
    // Future: add validation to detect and warn
  });
});
~~~~

**Documentation for Users:**

Include in help/docs:

~~~~
Temperature Units: Absolute vs. Difference

Unitary provides two types of temperature units following GNU Units convention:

Absolute Temperature (for single temperature values):
  - tempF, tempC, tempK (Kelvin is both absolute and difference)
  - Use for: "The water is 100 tempC"
  - Conversion includes offset: 100 tempF = 37.78 tempC

Temperature Difference (for intervals and rates):
  - degF, degC, degK
  - Use for: "The temperature increased by 10 degC"
  - Use for: "The reaction proceeds at 5 degC/min"
  - Conversion is linear: 100 degF = 55.56 degC (no offset)

Quick Guide:
  ✓ "100 tempF"           (absolute temperature)
  ✓ "10 degC/hour"        (temperature rate)
  ✓ "(100 tempF - 32 tempF) = 68 degF"  (difference gives degree unit)
  ✗ "10 tempC/hour"       (incorrect - use degC for rates)
~~~~

**Temperature Subtraction:**

When subtracting absolute temperatures, the result should be a temperature difference (degree unit), not an absolute temperature:

~~~~
100 tempF - 32 tempF = 68 degF  (difference in size, not absolute)
~~~~

For MVP, the subtraction operation returns the same dimension (since tempF and degF both have dimension {K: 1}). However, semantically the result is a difference.

**Future Enhancement**: Track provenance of quantities to know if they came from absolute temperature operations, and automatically convert result to degree units when subtracting absolutes.

**Implementation Notes:**

1. For MVP, both `tempX` and `degX` can share the same dimension {K: 1}
2. Both are conformable and can be converted between each other
3. The semantic distinction (absolute vs. difference) is in the unit name and user's intent
4. Future enhancement: Track whether a quantity came from absolute or difference operation
5. AffineDefinition handles the offset for absolute temperatures automatically

### 6. Negative Bases with Fractional Exponents

**Scenario**: `(-4)^0.5` is complex, not real

**Handling**: Throw `EvalException`

~~~~ dart
Quantity power(num exponent) {
  if (value < 0 && exponent is double && exponent != exponent.truncate()) {
    throw EvalException(
      'Cannot raise negative number to fractional power: $value ^ $exponent'
    );
  }
  // ... rest of power logic
}
~~~~

### 7. Dimension Mismatch Errors

**Scenario**: Operations on non-conformable quantities

**Handling**: Throw `DimensionException` with helpful message

~~~~ dart
class DimensionException extends Exception {
  final String message;
  final Dimension? leftDimension;
  final Dimension? rightDimension;

  DimensionException(this.message, {this.leftDimension, this.rightDimension});

  @override
  String toString() {
    if (leftDimension != null && rightDimension != null) {
      return 'DimensionException: $message\n'
             'Left: ${leftDimension!.canonicalRepresentation()}\n'
             'Right: ${rightDimension!.canonicalRepresentation()}';
    }
    return 'DimensionException: $message';
  }
}
~~~~

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

**Example of Precision Loss:**

~~~~ dart
// Repeated operations may accumulate error
var x = Quantity(1.0/3.0, Dimension.dimensionless);  // 0.333333...
var y = x * 3;  // Should be 1.0, might be 0.999999...

// Use epsilon comparison:
expect(y.approximatelyEquals(Quantity(1.0, Dimension.dimensionless)), true);
~~~~

**Not Implemented for MVP**: Operation depth tracking. This adds complexity without clear benefit for most users. If precision becomes a concern in practice, we can add it later.

---


Performance Considerations
--------------------------

### Optimization Strategies

1. **Lazy Dimension Computation**: For compound units, cache the computed dimension
2. **Conversion Factor Caching**: Cache frequently-used conversion factors
3. **Avoid Repeated Lookups**: Pass `UnitRepository` once, cache needed units
4. **Efficient Dimension Operations**: Dimension multiplication/division are simple map operations

### Potential Bottlenecks

1. **Unit Definition Chain Traversal**: For deeply nested unit definitions (e.g., mile → km → m)
   - Mitigation: Flatten definitions during database load
   - Cache base conversion factors

2. **Expression Parsing for Compound Units**: Parsing happens on first use
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

**Arithmetic Operations:**

~~~~ dart
group('Quantity arithmetic', () {
  test('add conformable quantities', () {
    final a = Quantity(5, Dimension({'m': 1}));
    final b = Quantity(3, Dimension({'m': 1}));
    final result = a + b;
    expect(result.value, 8);
    expect(result.dimension, Dimension({'m': 1}));
  });

  test('cannot add non-conformable quantities', () {
    final a = Quantity(5, Dimension({'m': 1}));
    final b = Quantity(3, Dimension({'s': 1}));
    expect(() => a + b, throwsA(isA<DimensionException>()));
  });

  test('multiply quantities', () {
    final a = Quantity(5, Dimension({'m': 1}));
    final b = Quantity(3, Dimension({'s': 1}));
    final result = a * b;
    expect(result.value, 15);
    expect(result.dimension, Dimension({'m': 1, 's': 1}));
  });

  test('divide quantities', () {
    final a = Quantity(10, Dimension({'m': 1}));
    final b = Quantity(2, Dimension({'s': 1}));
    final result = a / b;
    expect(result.value, 5);
    expect(result.dimension, Dimension({'m': 1, 's': -1}));
  });

  test('power operation', () {
    final a = Quantity(3, Dimension({'m': 1}));
    final result = a.power(2);
    expect(result.value, 9);
    expect(result.dimension, Dimension({'m': 2}));
  });

  test('division by zero throws error', () {
    final a = Quantity(10, Dimension({'m': 1}));
    final b = Quantity(0, Dimension({'s': 1}));
    expect(() => a / b, throwsA(isA<EvalException>()));
  });
});
~~~~

**Conversion Tests:**

~~~~ dart
group('Quantity conversion', () {
  late UnitRepository repo;

  setUp(() {
    repo = UnitRepository();
    // Load test units
  });

  test('convert miles to meters', () {
    final miles = repo.getUnit('mi')!;
    final meters = repo.getUnit('m')!;
    final distance = Quantity.fromUnit(5, miles, repo);
    final converted = distance.convertTo(meters, repo);
    expect(converted.value, closeTo(8046.72, 0.01));
  });

  test('convert temperature with offset', () {
    final fahrenheit = repo.getUnit('degF')!;
    final celsius = repo.getUnit('degC')!;
    final temp = Quantity.fromUnit(100, fahrenheit, repo);
    final converted = temp.convertTo(celsius, repo);
    expect(converted.value, closeTo(37.78, 0.01));
  });

  test('cannot convert non-conformable units', () {
    final meters = repo.getUnit('m')!;
    final seconds = repo.getUnit('s')!;
    final distance = Quantity.fromUnit(5, meters, repo);
    expect(() => distance.convertTo(seconds, repo),
           throwsA(isA<DimensionException>()));
  });
});
~~~~

**Edge Case Tests:**

~~~~ dart
group('Quantity edge cases', () {
  test('very large numbers', () {
    final big = Quantity(1e308, Dimension.dimensionless);
    final result = big * big;
    expect(result.value.isInfinite, true);
  });

  test('negative base with fractional exponent', () {
    final neg = Quantity(-4, Dimension({'m': 1}));
    expect(() => neg.power(0.5), throwsA(isA<EvalException>()));
  });

  test('dimensional exponent validation', () {
    // Valid: (m^2)^0.5 = m (2 is divisible by 2)
    final valid = Quantity(9, Dimension({'m': 2}));
    final result = valid.power(0.5);
    expect(result.dimension, Dimension({'m': 1}));

    // Invalid: (m^3)^0.5 would give m^1.5 (not integral)
    final invalid = Quantity(8, Dimension({'m': 3}));
    expect(() => invalid.power(0.5), throwsA(isA<DimensionException>()));
  });

  test('rational recovery from double', () {
    final half = Rational.fromDouble(0.5);
    expect(half.numerator, 1);
    expect(half.denominator, 2);

    final third = Rational.fromDouble(0.333333);
    expect(third.numerator, 1);
    expect(third.denominator, 3);

    final twoThirds = Rational.fromDouble(0.666667);
    expect(twoThirds.numerator, 2);
    expect(twoThirds.denominator, 3);
  });

  test('NaN handling', () {
    final nan = Quantity(double.nan, Dimension.dimensionless);
    expect(nan.format(DisplaySettings()), 'undefined');
  });
});
~~~~

### Integration Tests

~~~~ dart
group('Quantity integration', () {
  test('complex expression evaluation', () {
    // Test: sqrt(9 m^2) + 5 ft
    // Should evaluate to approximately 4.524 m
    final parser = ExpressionParser(repo);
    final result = parser.parse('sqrt(9 m^2) + 5 ft').evaluate();
    expect(result.value, closeTo(4.524, 0.001));
    expect(result.dimension, Dimension({'m': 1}));
  });

  test('unit chain conversion', () {
    // Test: mile -> km -> m
    // Ensure no precision loss in chain
    final miles = repo.getUnit('mi')!;
    final km = repo.getUnit('km')!;
    final m = repo.getUnit('m')!;

    final distance = Quantity.fromUnit(1, miles, repo);
    final inKm = distance.convertTo(km, repo);
    final inM = inKm.convertTo(m, repo);

    expect(inM.value, closeTo(1609.344, 0.001));
  });
});
~~~~

### Property-Based Tests

Use property-based testing for mathematical properties:

~~~~ dart
group('Quantity properties', () {
  test('commutativity of addition', () {
    // For all conformable a, b: a + b == b + a
    final a = Quantity(randomValue(), someDimension);
    final b = Quantity(randomValue(), someDimension);
    expect((a + b).value, closeTo((b + a).value, epsilon));
  });

  test('associativity of multiplication', () {
    // For all a, b, c: (a * b) * c == a * (b * c)
    // (within floating-point precision)
  });

  test('conversion round-trip', () {
    // Convert unit A -> B -> A should give original value
    // (within floating-point precision)
  });
});
~~~~

---


Summary
-------

This design provides:

1. **Simple, efficient numeric representation** using `double` for MVP with rational recovery for exponents
2. **Complete arithmetic operations** with proper dimensional analysis including rational exponent validation
3. **Robust conversion algorithm** handling unit chains and compound units
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
