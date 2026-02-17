Unitary
=======

[![CI](https://github.com/wisnij/unitary/actions/workflows/ci.yml/badge.svg)](https://github.com/wisnij/unitary/actions/workflows/ci.yml)
[![License: AGPL v3](https://img.shields.io/badge/License-AGPL_v3-blue.svg)](https://www.gnu.org/licenses/agpl-3.0)

A powerful, flexible unit conversion mobile application targeting scientific and
technically-minded users.  Features both freeform calculator-style expression
evaluation and worksheet-based conversion modes, with support for custom
user-defined units and dimensions.


Project Status
--------------

**Current Phase:** Phase 4 Complete (Basic UI - Freeform Mode)\
**Last Updated:** February 16, 2026

Phases 0-4 are complete with 845 passing tests.  The expression parser,
evaluator, unit system foundation, advanced unit features, and basic UI are
fully implemented.  Phase 4 added the first working UI: freeform expression
evaluation with two-field conversion, settings screen (precision, notation,
dark mode, evaluation mode), and drawer-based navigation.  State management
uses Riverpod with SharedPreferences for persistence.

---


Features (Planned)
------------------

### Core Functionality

- **Freeform Expression Mode**: GNU Units-style calculator supporting complex mathematical expressions with full dimensional analysis
- **Worksheet Mode**: Multi-unit conversion interface with real-time updates across all fields
- **Comprehensive Unit Support**: Length, mass, temperature, volume, area, speed, time, pressure, energy, digital storage, and currency
- **Custom Units**: Define your own units and dimensions
- **Offline-First**: All conversions work offline, with automatic currency rate updates when online
- **Dark Mode**: System-aware dark mode support

### Advanced Features

- Expression parsing with dimensional analysis
- Support for prefixes (kilo, mega, milli, etc.)
- Mathematical and trigonometric functions
- Physical constants (speed of light, pi, e, etc.)
- Rational number arithmetic (planned) for precision
- User preferences persistence
- Configurable precision and notation (decimal, scientific, engineering)

---


Documentation
-------------

### Design Documents

- **[Requirements](doc/requirements.md)** - Complete feature specifications and user requirements
- **[Terminology](doc/terminology.md)** - Definitions of key terms used throughout the project
- **[Core Architecture](doc/architecture.md)** - Technical design of data models, parser, and core systems
- **[Quantity Arithmetic Design](doc/quantity_arithmetic_design.md)** - Detailed design for Quantity class, arithmetic operations, and conversion algorithms
- **[Implementation Plan](doc/implementation_plan.md)** - Phased development roadmap, risks, and success metrics
- **[Development Best Practices](doc/best_practices.md)** - Coding standards and workflow guidelines
- **[Dimensionless Units Design](doc/dimensionless_units_design.md)** - Design for radian/steradian handling in conversions
- **[Design Progress](doc/design_progress.md)** - Tracker for completed and in-progress design work

### Quick Links

- [Technology Stack](#technology-stack)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Contributing](#contributing)

---


Technology Stack
----------------

**Framework:** Flutter (Dart)

- Chosen for cross-platform support (Android primary, iOS secondary)
- Native performance and UI
- Single codebase for both platforms

**Key Dependencies:**

- `flutter_riverpod` - State management
- `shared_preferences` - Simple key-value storage for user settings

**Planned Dependencies:**

- `sqflite` or `hive` - Local database for persistence (Phase 6)
- `http` or `dio` - HTTP client for currency rates (Phase 7)

**Data Source:**

- GNU Units database for comprehensive unit definitions

---


Project Structure
-----------------

~~~~
unitary/
├── doc/                           # All design documentation
│   ├── requirements.md
│   ├── terminology.md
│   ├── architecture.md
│   ├── quantity_arithmetic_design.md
│   ├── implementation_plan.md
│   ├── best_practices.md
│   └── design_progress.md
├── lib/                           # Flutter application code (not yet created)
│   ├── core/                      # Core domain logic
│   │   ├── domain/                # Models, parser, services
│   │   └── data/                  # Repositories, data sources
│   ├── features/                  # Feature-specific code
│   │   ├── freeform/
│   │   ├── worksheet/
│   │   └── settings/
│   └── shared/                    # Shared widgets and utilities
├── test/                          # Tests (not yet created)
├── assets/                        # Static assets (not yet created)
│   ├── units/
│   └── currency/
└── README.md                      # This file
~~~~

---


Architecture Highlights
-----------------------

### Expression Parser & Evaluator

- Lexer → Parser → AST → Evaluator pipeline
- Full dimensional analysis during evaluation
- Support for complex expressions: `sqrt(9 m^2) + sin(45 degrees) * 5 ft`

### Unit System

- **Primitive units**: Cannot be reduced further (e.g., meter, kilogram)
- **Derived units**: Defined in terms of other units (e.g., newton = kg⋅m/s²)
- **Dimensions**: Represented as maps of primitive units to exponents
- **Conformability**: Units are convertible if they share the same dimension

### Worksheet System

- Pre-defined templates for common conversions
- User-customizable worksheets
- Real-time updates across all fields
- Persistent state across sessions

---


Getting Started
---------------

### Prerequisites

- Flutter SDK (latest stable)
- Android Studio or VS Code
- Git

### Setup (When Implementation Begins)

~~~~ bash
# Clone the repository
git clone https://github.com/wisnij/unitary.git
cd unitary

# Install dependencies
flutter pub get

# Run the app
flutter run
~~~~

### Development Workflow

1. Read the design documentation thoroughly
2. Follow the phased implementation plan
3. Adhere to development best practices
4. Write tests for all new functionality
5. Submit pull requests for review

---


Current Progress
----------------

### Implementation

- ✅ **Phase 0: Project Setup** — Flutter project scaffolded, linting configured, directory structure in place
- ✅ **Phase 1: Core Domain** — Expression parser and evaluator with dimensional analysis (373 tests)
- ✅ **Phase 2: Unit System Foundation** — Unit definitions, repository, conversions, evaluator integration (492 tests)
- ✅ **Phase 3: Advanced Unit Features** — Temperature, constants, derived units, affine syntax, dimensionless units, SI prefixes (703 tests)
- ✅ **Phase 4: Basic UI - Freeform Mode** — Freeform evaluation UI, settings, drawer navigation, Riverpod state management (845 tests)

### Design (ready for implementation)

- ✅ Core domain models (Dimension, Unit, Quantity, Prefix)
- ✅ Expression parser and evaluator architecture
- ✅ Terminology and conventions
- ✅ **Quantity arithmetic and conversion algorithms** (see quantity_arithmetic_design.md)
- ✅ **Basic UI - Freeform Mode** (see phase4_plan.md)

### Design (still needs detail)

- ⏳ Worksheet system details
- ⏳ GNU Units database import strategy
- ⏳ Currency rate management

See [Design Progress](design_progress.md) for full details.

---


Contributing
------------

This is currently a personal project in the design phase.  Once implementation
begins, contributions will be welcome!

**Future Contribution Areas:**

- Bug reports and fixes
- Feature requests and implementations
- Documentation improvements
- Unit database enhancements
- Translations (future)

**Before Contributing:**

1. Review all design documentation
2. Check existing issues and pull requests
3. Follow the development best practices
4. Write tests for new features
5. Update documentation as needed

---


Roadmap
-------

### Phase 1: MVP (Weeks 1-25)

- Core expression parser and evaluator
- Basic unit system with major categories
- Freeform and worksheet modes
- Settings and persistence
- Currency support
- Polish and release

### Phase 2: Enhancements

- Custom unit definitions
- Worksheet customization
- iOS support
- Advanced mathematical functions

### Phase 3: Advanced Features

- Rational number arithmetic
- Equation solver
- Graphing capabilities
- Additional constants and functions

See [Implementation Plan](implementation_plan.md) for detailed timeline.

---


Design Philosophy
-----------------

### For Users

- **Utility over simplicity**: Powerful features for technical users
- **Flexibility**: Support for complex expressions and custom units
- **Precision**: Accurate conversions with configurable precision
- **Offline-first**: Core features work without internet

### For Developers

- **Clean architecture**: Clear separation of concerns
- **Testability**: High test coverage for core logic
- **Maintainability**: Well-documented, follows best practices
- **Extensibility**: Easy to add new units, functions, and features

---


License
-------

Copyright © 2026 Jim Wisniewski <wisnij@gmail.com>

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.

---


Acknowledgments
---------------

- GNU Units project for inspiration and unit database
- Flutter and Dart communities
- Contributors (future)

---

*This project is in active design phase. Star and watch for updates!*
