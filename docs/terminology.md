# Unit Converter - Terminology

This document defines key terms used throughout the project documentation and codebase. All contributors should use these terms consistently.

---


## Core Concepts

**Value**: A pure number, which may be an integer, a decimal (floating-point), or a numerator/denominator ratio (rational number). Values have no dimensional information.

**Quantity**: Represents a physical quantity, combining a numeric value with a dimension. For example, "5 meters" is a quantity with value 5 and dimension {m: 1}.

**Unit**: A named quantity that is registered in the system and can be used in calculations. Examples: meter, kilogram, mile, newton.

**Primitive Unit** (or **Primitive**): A unit that is not defined in terms of other units and cannot be reduced further. These are the fundamental building blocks of the unit system. Primitives can be either:

- **Dimensioned primitives**: Define a new dimension (e.g., meter for length, kilogram for mass)
- **Dimensionless primitives**: Special units that don't create dimensions (e.g., radian for angles)

**Derived Unit**: Any unit that is not primitive. Its definition is an expression containing other values and/or units. Examples: kilometer (1000 meters), newton (kg m/s^2).

**Dimension**: A set of primitive units with associated exponents, represented as a map from primitive unit IDs to their exponents. For example:

- Length: {m: 1}
- Velocity: {m: 1, s: -1}
- Acceleration: {m: 1, s: -2}
- Dimensionless: {} (empty set)

---


## Operations and Expressions

**Expression**: A mathematical expression containing values, units, and/or functions, combined via operators (+, -, *, /, ^, etc.). Examples: "5 meters + 3 feet", "sqrt(9 m^2)", "sin(pi/4 radians)".

**Reducing** (an expression): The process of evaluating and expanding an expression until it is expressed in terms of primitive units only. All valid expressions can be fully reduced. For example, "5 newtons" reduces to "5 kg m / s^2".

**Conformable** (expressions): Two expressions are conformable if they have the same dimension, meaning they can be converted between each other. Examples: "5 meters" and "10 feet" are conformable (both have dimension {m: 1}).

**Dimensionless** (expression): An expression whose dimension is the empty set {}, regardless of whether it contains only numeric literals or also includes dimensionless units. Examples: "5", "pi", "3 radians", "sin(0.5)".

**Conversion**: The numeric ratio between two conformable expressions, or between a single expression and its fully reduced form. For example, the conversion from miles to meters is 1609.344.

---


## Modifiers and Components

**Prefix**: A multiplier that can be attached to a unit (e.g., kilo, mega, milli). SI prefixes are a particular subset of prefixes but are not treated differently in the system - they may be noted as coming from SI in their description text.

---


## Number Representations

**Decimal**: A floating-point number (as opposed to a rational number). Used to distinguish from exact rational representations.

**Rational Number**: An exact representation of a number as a numerator/denominator pair, avoiding precision loss from decimal representation.

---


## Usage Examples

### Primitives vs. Derived Units

- `meter` (m) is a **primitive unit** with dimension {m: 1}
- `kilometer` (km) is a **derived unit** defined as 1000 meters
- `mile` (mi) is a **derived unit** that could be defined in terms of kilometers or meters

### Dimensions

- A speed of "60 mph" has dimension {m: 1, s: -1} (after reduction)
- A force of "5 N" has dimension {kg: 1, m: 1, s: -2} (after reduction)
- An angle of "45 degrees" has dimension {} (dimensionless, since both degree and radian are dimensionless primitives)

### Conformability

- "5 meters" and "10 feet" are **conformable** because both have dimension {m: 1}
- "5 meters" and "10 seconds" are **not conformable** because they have different dimensions
- You can convert between conformable expressions but not between non-conformable ones

### Reducing Expressions

- "5 km" reduces to "5000 m" (expressing in terms of the primitive)
- "3 N" reduces to "3 kg m / s^2" (expanding the compound unit)
- "60 mph" reduces to approximately "26.8224 m / s"

---

*This terminology is used consistently throughout all project documentation and should be reflected in code comments, variable names, and user-facing text where appropriate.*
