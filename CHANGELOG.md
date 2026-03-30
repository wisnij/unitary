Changelog
=========

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


[Unreleased]
------------

### Added

- Show more specific error messages in worksheets
- Add "Torr" as an alias of the torr unit

### Fixed

- Don't display redundant unit definition lines
- Use singular labels on worksheet rows


[0.6.1] - 2026-03-28
--------------------

### Added

- Include more units in default worksheets

### Fixed

- Clarify behavior settings heading
- Display worksheet mode as a top-level page


[0.6.0] - 2026-03-27
--------------------

### Added

- Add worksheet mode and initial predefined worksheets


[0.5.12] - 2026-03-23
---------------------

### Fixed

- Require input to be an expression when converting
- Don't display redundant definitions


[0.5.11] - 2026-03-19
---------------------

### Added

- Display unit definitions


[0.5.10] - 2026-03-15
---------------------

### Added

- Add an About screen to the left-hand drawer menu
- Display function name when converting to a function


[0.5.9] - 2026-03-14
--------------------

### Added

- Handle function definition requests and conversion output

### Documentation

- Standardize header style in Openspec artifacts


[0.5.8] - 2026-03-12
--------------------

### Added

- Implement defined functions

### Changed

- Remove affine units


[0.5.7] - 2026-03-07
--------------------

### Added

- Implement inverse function operator `~`

### Fixed

- Parse piecewise linear functions with parens in the range unit


[0.5.6] - 2026-03-07
--------------------

### Fixed

- Update release workflow to fix tag fetching bug


[0.5.5] - 2026-03-07
--------------------

### Added

- Implement and import piecewise linear functions


[0.5.4] - 2026-03-04
--------------------

### Added

- Support logB(x) as a shorthand for log(x)/log(B)


[0.5.3] - 2026-03-03
--------------------

### Added

- add function types and proper builtin functions

### Changed

- rename builtin units to predefined units


[0.5.2] - 2026-03-01
--------------------

### Added

- allow more characters in identifiers

### Fixed

- improve display of 1/x dimensions

### Documentation

- free software statement


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
--------------------

Phase 2: Unit System Foundation.

- Dimension, UnitDefinition, Quantity, and Prefix domain classes
- Unit repository with builtin definitions for length, mass, and time
- Unit conversion support integrated into the expression evaluator
- Dimension.dimensionless and Quantity.unity constants
- Chained unit definitions for cleaner builtin unit specs


[0.1.0] - 2026-02-01
------------------

Phase 1: Core Domain.

- Expression lexer and parser with full operator precedence
- Expression evaluator with dimensional analysis
- Support for implicit multiplication
- Mathematical operator support (+, -, *, /, ^, unary negation)
- Parenthesized sub-expressions
- Numeric literals with decimal point support
- 373 passing tests

[Unreleased]: https://github.com/wisnij/unitary/compare/v0.6.1...HEAD
[0.6.1]: https://github.com/wisnij/unitary/compare/v0.6.0...v0.6.1
[0.6.0]: https://github.com/wisnij/unitary/compare/v0.5.12...v0.6.0
[0.5.12]: https://github.com/wisnij/unitary/compare/v0.5.11...v0.5.12
[0.5.11]: https://github.com/wisnij/unitary/compare/v0.5.10...v0.5.11
[0.5.10]: https://github.com/wisnij/unitary/compare/v0.5.9...v0.5.10
[0.5.9]: https://github.com/wisnij/unitary/compare/v0.5.8...v0.5.9
[0.5.8]: https://github.com/wisnij/unitary/compare/v0.5.7...v0.5.8
[0.5.7]: https://github.com/wisnij/unitary/compare/v0.5.6...v0.5.7
[0.5.6]: https://github.com/wisnij/unitary/compare/v0.5.5...v0.5.6
[0.5.5]: https://github.com/wisnij/unitary/compare/v0.5.4...v0.5.5
[0.5.4]: https://github.com/wisnij/unitary/compare/v0.5.3...v0.5.4
[0.5.3]: https://github.com/wisnij/unitary/compare/v0.5.2...v0.5.3
[0.5.2]: https://github.com/wisnij/unitary/compare/v0.5.1...v0.5.2
[0.5.1]: https://github.com/wisnij/unitary/compare/v0.5.0...v0.5.1
[0.5.0]: https://github.com/wisnij/unitary/compare/v0.4.0...v0.5.0
[0.4.0]: https://github.com/wisnij/unitary/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/wisnij/unitary/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/wisnij/unitary/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/wisnij/unitary/releases/tag/v0.1.0
