Changelog
=========

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


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
