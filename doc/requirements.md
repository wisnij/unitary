Unitary - Requirements Document
===============================


Project Overview
----------------

Unitary is a powerful, flexible unit conversion application targeting scientific and technically-minded users. The app features both freeform expression evaluation (GNU Units-style) and worksheet-based conversion modes, with support for custom user-defined units and dimensions.


Target Platforms
----------------

- **Primary**: Android
- **Secondary**: iOS (from same codebase)
- **Framework**: Flutter (recommended for cross-platform support with native UI integration)


Core Feature Requirements
-------------------------

### 1. Unit Categories (Initial Release)

All conversions work completely offline:

- Length
- Weight/Mass
- Temperature
- Volume
- Area
- Speed
- Time
- Pressure
- Energy
- Digital Storage
- Currency (with online rate updates)

### 2. Conversion Modes

#### Freeform Input Mode

- GNU Units-style calculator interface
- Single expression evaluation: displays result in primitive units for that dimension
- Two expression evaluation: shows conversion factor between expressions
- Error display when expressions have incompatible dimensions
- Output unit customizable via output expression box

**Expression Support:**

- Addition/subtraction (same-dimension units only)
- Multiplication: space, `*`, `×`, `⋅`
- Division (low precedence): `/`, `÷`
- Division (high precedence): `|` (e.g., `1|2 s` = `0.5 s`, but `1/2 s` = `0.5 / s`)
- Exponents: supports fractional, decimal, and negative values
- Parentheses for grouping
- Arithmetic functions (sqrt, etc.)
- Trigonometric functions (sin, cos, tan, etc.)
- Mathematical and physical constants (pi, e, c, etc.)

**Dimensional Analysis:**

- Radians as dimensionless primitive unit
- Degrees defined in terms of radians
- Trig functions accept both radians and degrees
- Automatic dimensional propagation (e.g., `sqrt(m^2) = m`)

#### Worksheet Mode

- Multiple units of the same dimension displayed simultaneously
- Single input updates all output fields in real-time
- User can type into any field; all others update accordingly
- Pre-defined worksheets with 5-10 common units each
- User-editable worksheets
- User-created custom worksheets

### 3. Unit Definition System

**Built-in Units:**

- Based on GNU Units database for comprehensive coverage and compatibility
- Compound unit support (e.g., `kg m/s^2` for Newton)
- Offset conversion support (e.g., Celsius ↔ Fahrenheit)

**Aliases and Naming:**

- Support for multiple names per unit (e.g., "meter", "metre", "m")
- Support for plural forms (e.g., "meters", "metres")
- English only initially

**Custom Units (Future Enhancement):**

- Users can define new units in terms of existing units
- Users can create new dimensions by defining new units
- Custom unit definitions persist across sessions

### 4. Currency Conversion

**Rate Management:**

- Auto-update at app launch if last update >24 hours ago
- Manual refresh trigger available
- Ship with latest rates as of each release
- Display last update timestamp prominently
- Support all currencies with available rate data

**API Integration:**

- User-configurable rate source (future enhancement)
- Graceful failure handling: continue with last known rates
- Non-intrusive notification on fetch failure

**Offline Behavior:**

- Use most recently fetched rates when offline
- Clear indication of rate age

### 5. Display & Precision Settings

**Configurable Options:**

- Decimal places: 2-10
- Notation styles:
  - Plain decimals
  - Scientific notation
  - Engineering notation
- Dark mode: system default with manual override
- Material Design UI (keep current with style updates)

### 6. Data Persistence

**User Preferences:**

- Favorite/common units per category (sorted to top in pickers)
- Precision and notation settings
- Dark mode preference
- Last used category/mode
- Custom unit definitions

**Worksheet State:**

- Last entered value in each worksheet
- Last selected unit in each field
- User-created and user-modified worksheets

**Conversion History:**

- Save for reference (exact scope TBD)

### 7. User Interface Requirements

**Design Principles:**

- Minimalist interface
- Material Design for Android
- Native feel on each platform
- Dark mode support (default to system setting)

**Navigation:**

- Easy switching between freeform and worksheet modes
- Quick access to different categories
- Settings easily accessible

**Unit Selection:**

- Picker lists organized by category
- Favorites/common units sorted to top within category
- Search/filter capability

**Input Validation:**

- Real-time error display for invalid expressions
- Clear error messages explaining dimensionality mismatches
- Non-blocking errors (don't clear valid values)


Non-Functional Requirements
---------------------------

### Performance

- Real-time conversion updates (optimize if needed)
- Responsive UI even with complex expressions
- Efficient parsing and evaluation

### Maintainability

- Clean architecture with separated concerns
- Custom-built parser/evaluator for flexibility
- Extensible unit definition system
- Well-documented codebase

### Compatibility

- Android as primary target
- iOS support from same codebase
- Handle system theme changes gracefully
- Support various screen sizes

### User Experience

- Offline-first design
- Graceful degradation when services unavailable
- Non-intrusive notifications
- Preserve user work across sessions


Project Scope
-------------

**Timeline:** No fixed deadline; iterative development
**Release:** Open source on GitHub at MVP stage
**Language:** English only (initial release)
**Development:** Personal project, learning-oriented


Future Enhancements (Out of Scope for MVP)
------------------------------------------

- Custom unit sharing between users
- Multiple language support
- Unit definition import/export
- Additional mathematical functions
- Equation solver mode
- Graphing capabilities
- More worksheet templates
- Configurable currency rate sources
- Cloud sync of preferences/custom units


Success Criteria
----------------

A successful MVP will:

1. Accurately convert between all built-in unit categories
2. Parse and evaluate complex unit expressions with proper dimensional analysis
3. Provide both freeform and worksheet interfaces
4. Persist user preferences and custom definitions
5. Work completely offline (except currency rate updates)
6. Feel native and responsive on Android
7. Support dark mode and user customization
8. Serve as a foundation for future enhancements
