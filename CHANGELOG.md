Changelog
=========

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


[0.5.1] - 2026-02-27
--------------------

### Added

- accept single-digit suffix as a shorthand for exponent
- raise an error when evaluating unrecognized units

### Fixed

- store parsed source files as relative paths

### Documentation

- add change spec for making the repo non-nullable in evals


[0.5.0] - 2026-02-26
--------------------

### Added

- initial import of GNU Units database
- improve parser EOF message
- format output unit expressions more clearly
- better default decimal display
- show build metadata in About widget

### Changed

- use themeMode setting instead of darkMode

### Fixed

- two blank spaces between changelog sections
- raw string lint
- update web page title

### Documentation

- move Phase 8 (complete unit database) up to be 5 instead


[0.4.0] - 2026-02-16
--------------------

Phase 4: Basic UI - Freeform Mode.

- Freeform expression evaluation screen with two-field input (expression +
    optional conversion target) and real-time result display
- Result display widget with four states: idle, success, conversion, and error
- Drawer-based navigation with Freeform and Settings destinations
- Settings screen: precision (2-10), notation
    (decimal/scientific/engineering), dark mode (system/dark/light), evaluation
    mode (real-time/on-submit)
- Riverpod state management with debounced evaluation (500ms, configurable)
- SharedPreferences persistence for user settings
- Quantity formatter supporting decimal, scientific, and engineering notation
- Dimensionless unit stripping in conversion factor computation
- Reciprocal display for unit conversions
- Web platform support
- 848 passing tests


[0.3.0] - 2026-02-16
--------------------

Phase 3: Advanced Unit Features.

- All 7 SI base unit primitives (m, kg, s, K, A, mol, cd)
- Temperature units with affine conversions (tempF, tempC, tempK, tempR) and
  linear degree units (degF, degC, degK, degR)
- Affine unit syntax: function-call form required (e.g., `tempF(212)`)
- 12 SI derived compound units (N, Pa, J, W, Hz, C, V, ohm, F, Wb, T, H)
- 10 physical and mathematical constants (pi, euler, tau, c, gravity, h, etc.)
- Dimensionless primitive units (radian, steradian) with conformability stripping
- SI prefix system: 24 prefixes from quecto to quetta, with prefix-aware unit
  lookup (longest-match-first, separate storage to avoid collisions)
- Refactored Unit hierarchy: Unit subclasses (`PrimitiveUnit`, `CompoundUnit`,
  `AffineUnit`, `PrefixUnit`) replace separate `UnitDefinition` classes
- Standalone `resolveUnit` helper replaces `UnitDefinition.toQuantity`
- Lexer recognizes additional operator characters (Unicode multiply/divide)
- 703 passing tests


[0.2.0] - 2026-02-11
---------------------

Phase 2: Unit System Foundation.

- Dimension, UnitDefinition, Quantity, and Prefix domain classes
- Unit repository with builtin definitions for length, mass, and time
- Unit conversion support integrated into the expression evaluator
- Dimension.dimensionless and Quantity.unity constants
- Chained unit definitions for cleaner builtin unit specs


[0.1.0] - 2026-02-01
---------------------

Phase 1: Core Domain.

- Expression lexer and parser with full operator precedence
- Expression evaluator with dimensional analysis
- Support for implicit multiplication
- Mathematical operator support (+, -, *, /, ^, unary negation)
- Parenthesized sub-expressions
- Numeric literals with decimal point support
- 373 passing tests
