Unitary
=======

[![CI](https://github.com/wisnij/unitary/actions/workflows/ci.yml/badge.svg)](https://github.com/wisnij/unitary/actions/workflows/ci.yml)
[![License: AGPL v3](https://img.shields.io/badge/License-AGPL_v3-blue.svg)](https://www.gnu.org/licenses/agpl-3.0)

A powerful, flexible unit conversion mobile application targeting scientific and
technically-minded users.  Features both freeform calculator-style expression
evaluation and worksheet-based conversion modes.

Unitary is [free software](https://www.gnu.org/philosophy/free-sw.html), both libre and
gratis.  It does not and will never contain ads, paywalls, subscriptions, in-app
purchases, tracking, data harvesting, or any other monetization scheme.


Getting Unitary
---------------

- **Android**: download the APK from the
  [latest release](https://github.com/wisnij/unitary/releases/latest) and
  install it.  (You may need to allow installation from unknown sources.)
- **Web**: try it in your browser at <https://wisnij.github.io/unitary/> —
  the same app, deployed automatically from the latest code.
- **From source**: see [Development](#development) below.

Everything works offline.  The only network access Unitary ever performs is
fetching currency exchange rates, and built-in rates are bundled so currency
conversion works without a connection too.


What it does
------------

### Freeform mode

A calculator that understands units.  Type any expression into the "Convert
from" field, and optionally a target expression into "Convert to":

| Convert from                           | Convert to | Result                |
|----------------------------------------|------------|-----------------------|
| `5 ft + 3 in`                          | `cm`       | `160.02 cm`           |
| `3e4 kilometers/week`                  | `mph`      | `110.95914 mph`       |
| `sqrt(9 m^2) + sin(45 degrees) * 5 ft` | `m`        | `4.0776307 m`         |
| `tempF(212)`                           | `tempC`    | `tempC(100)`          |
| `100 USD`                              | `EUR`      | (at the current rate) |

Full dimensional analysis runs through every calculation: adding meters to
seconds is an error, converting joules to kilowatt-hours just works, and
exponents, functions, and SI prefixes all carry their dimensions correctly.

- **Expression language**: arithmetic (`+`, `-`, `*`, `/`, `^`), numeric
  fractions (`2|3`), implicit multiplication (`5 m`), parentheses,
  mathematical and trigonometric functions, physical constants (`c`, `pi`,
  `h`, ...), and inverse function application (`~tempF`) – the syntax is
  compatible with [GNU Units](https://www.gnu.org/software/units/), so
  expressions you'd type there work here too
- **Predictive completion**: inline suggestions for unit, prefix, and
  function names as you type
- **History**: successful conversions are saved and can be recalled with a
  tap
- **Definition lookup**: enter a bare unit name to see how it is defined

### Worksheet mode

Convert one value across many units at once.  Pick a worksheet, type a value
into any row, and every other row updates in real time.  Twelve worksheets
are built in: Angle, Area, Currency, Digital Storage, Energy, Length, Mass,
Pressure, Speed, Temperature, Time, and Volume.  Your entries persist across
sessions.

### Unit browser

Browse the entire unit catalog – over 7,000 units, 125 prefixes, and 100+
functions imported from the [GNU Units](https://www.gnu.org/software/units/)
database – alphabetically or grouped by physical dimension, with search and
per-unit detail pages showing definitions, aliases, and resolved values.

### Currency conversion

Live exchange rates (including precious metals XAU/XAG/XPT) are fetched
automatically from the [Frankfurter](https://frankfurter.dev) API when the
stored rates are more than a day old, and can be refreshed manually from
Settings or the Currency worksheet.  Rates are stored on the device, so
currency conversion keeps working offline.

### Designed for daily use

- **Dark mode**: follows the system theme, or set light/dark explicitly
- **Responsive**: phone and tablet layouts, portrait and landscape, with
  two-pane views on larger screens
- **Accessible**: screen-reader support (TalkBack/VoiceOver), WCAG-compliant
  contrast, 48 dp touch targets
- **Configurable**: precision (2-10 significant figures),
  automatic/scientific/engineering notation, real-time or on-submit
  evaluation


Development
-----------

Unitary is built with [Flutter](https://flutter.dev) (Dart).  The expression
engine and unit system are pure Dart with no Flutter dependency; state
management uses `flutter_riverpod`, and persistence uses
`shared_preferences`.

### Building from source

~~~~ bash
git clone https://github.com/wisnij/unitary.git
cd unitary
flutter pub get
flutter run
~~~~

### Running tests

~~~~ bash
flutter test --reporter failures-only   # full unit/widget suite
flutter analyze                         # lint check
tool/run_integration_tests.sh           # on-device tests (Android emulator)
~~~~

### Documentation

- **[Core Architecture](doc/architecture.md)** – data models,
  parser/evaluator, and subsystem design as implemented
- **[Evaluation Pipeline](doc/evaluation_pipeline.md)** – a worked example of
  how an expression is lexed, parsed, and evaluated
- **[Terminology](doc/terminology.md)** – definitions of key terms (unit,
  dimension, quantity, conformability, ...)
- **[Requirements](doc/requirements.md)** – feature specifications
- **[Implementation Plan](doc/implementation_plan.md)** – phased roadmap and
  progress; see also the [design progress tracker](doc/design_progress.md)
- **[Development Best Practices](doc/best_practices.md)** – coding standards
  and workflow
- **[Performance](doc/performance.md)** – benchmark tooling, baselines, and
  measurement procedures


Project status
--------------

Unitary is feature-complete for its MVP and currently in the final polish and
testing phase before its first public release.  Over 2,000 automated tests
cover the expression engine, unit system, and UI, plus an on-device
integration test suite run in CI.  See the
[Implementation Plan](doc/implementation_plan.md) for the detailed roadmap,
including planned post-MVP features such as custom unit definitions,
worksheet customization, and iOS support.


Contributing
------------

Bug reports, feature requests, and pull requests are welcome – see
[CONTRIBUTING.md](CONTRIBUTING.md) for guidelines, and the
[documentation](#documentation) links above for how the codebase fits
together.


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

### Contributors

This program includes data files that are part of [GNU
Units](https://www.gnu.org/software/units/).
GNU Units is copyright © 1996-2002, 2004-2020, 2022, 2024, 2026 Free Software
Foundation, Inc.
