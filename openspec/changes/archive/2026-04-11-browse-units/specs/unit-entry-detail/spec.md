## ADDED Requirements

### Requirement: Primary name and aliases
The detail page SHALL display the entry's primary registration ID as the main
title.  If the entry has any aliases they SHALL all be listed together in a
dedicated section.

#### Scenario: Primary name displayed
- **WHEN** the detail page is opened for any entry
- **THEN** the primary registration ID is shown as the page title or heading

#### Scenario: Aliases listed when present
- **WHEN** the entry has one or more aliases
- **THEN** all aliases are shown in an aliases section, sorted
  case-insensitively in lexicographic order

#### Scenario: Aliases section absent when none
- **WHEN** the entry has no aliases
- **THEN** no aliases section is rendered

---

### Requirement: Entry type
The detail page SHALL display the entry's type in a "Type" section that
appears immediately after the Aliases section (or after the Name section when
there are no aliases).

The type label SHALL be:
- `"Primitive unit"` for a non-dimensionless `PrimitiveUnit`
- `"Primitive unit (dimensionless)"` for a `PrimitiveUnit` with
  `isDimensionless == true`
- `"Derived unit"` for a `DerivedUnit` that is not a `PrefixUnit`
- `"Prefix"` for a `PrefixUnit`
- `"Piecewise linear function"` for a `PiecewiseFunction`
- `"Function"` for any other `UnitaryFunction`

#### Scenario: Type shown for primitive unit
- **WHEN** the detail page is opened for a non-dimensionless primitive unit
- **THEN** the type section shows `"Primitive unit"`

#### Scenario: Type shows dimensionless qualifier
- **WHEN** the detail page is opened for a primitive unit with
  `isDimensionless == true`
- **THEN** the type section shows `"Primitive unit (dimensionless)"`

#### Scenario: Type shown for derived unit
- **WHEN** the detail page is opened for a derived unit
- **THEN** the type section shows `"Derived unit"`

#### Scenario: Type shown for prefix
- **WHEN** the detail page is opened for a prefix entry
- **THEN** the type section shows `"Prefix"`

#### Scenario: Type shown for piecewise function
- **WHEN** the detail page is opened for a `PiecewiseFunction`
- **THEN** the type section shows `"Piecewise linear function"`

#### Scenario: Type shown for non-piecewise function
- **WHEN** the detail page is opened for any other function
- **THEN** the type section shows `"Function"`

#### Scenario: Type section appears after Aliases
- **WHEN** the entry has aliases
- **THEN** the Type section appears below the Aliases section

---

### Requirement: Description
If the entry has a non-null description string the detail page SHALL display
it in a description section.

#### Scenario: Description shown when set
- **WHEN** the entry's description field is non-null
- **THEN** the description text is visible on the page

#### Scenario: Description section absent when unset
- **WHEN** the entry's description field is null
- **THEN** no description section is rendered

---

### Requirement: Definition display
The detail page SHALL display the entry's definition in a definition section,
except for primitive units which have no definition section.

- For a `PrimitiveUnit` no definition section is shown (the type label is
  sufficient).
- For a `DerivedUnit` (including `PrefixUnit`) the definition SHALL show the
  unit's expression string.
- For a `DefinedFunction` or `BuiltinFunction` the definition SHALL show the
  function signature followed by the forward expression:
  `name(param1, param2) = expression`.  For `BuiltinFunction` where no
  expression string exists the body SHALL read `[builtin function]`.
- For a `PiecewiseFunction` the definition SHALL show the control-point table
  directly (no text label).

#### Scenario: Primitive unit has no definition section
- **WHEN** the detail page is opened for a primitive unit
- **THEN** no definition section is rendered

#### Scenario: Derived unit definition
- **WHEN** the detail page is opened for a derived unit
- **THEN** the definition section shows the unit's expression (e.g. `4.184 J`)

#### Scenario: Defined function definition
- **WHEN** the detail page is opened for a `DefinedFunction`
- **THEN** the definition section shows `name(params) = <forward expression>`
  (e.g. `tempC(x) = x + 273.15`)

#### Scenario: Piecewise function definition
- **WHEN** the detail page is opened for a `PiecewiseFunction`
- **THEN** the definition section shows the control-point table

---

### Requirement: Inverse expression (functions only)
For function entries that have an inverse, the detail page SHALL display the
inverse expression in a separate inverse section.

#### Scenario: Inverse shown when present
- **WHEN** the entry is a `DefinedFunction` with a non-null inverse expression
- **THEN** the inverse expression is shown in an inverse section

#### Scenario: Inverse section absent when not available
- **WHEN** the entry is a function with no inverse (`hasInverse == false` or
  no inverse expression)
- **THEN** no inverse section is rendered

---

### Requirement: Value (units and prefixes only)
For unit and prefix entries the detail page SHALL display the fully resolved
base-unit quantity in a "Value" section showing the formatted quantity only
(e.g. `0.3048 m`).

Resolution uses the same `resolveUnit` path used elsewhere in the app.  If
resolution fails (e.g. circular definition, unsupported expression) the value
section SHALL be omitted silently.

#### Scenario: Value shown for a derived unit
- **WHEN** the detail page is opened for a unit that resolves successfully
- **THEN** the value section shows the formatted base-unit quantity
  (e.g. `0.3048 m` for `ft`)

#### Scenario: Value shown for a prefix
- **WHEN** the detail page is opened for a prefix
- **THEN** the value section shows the prefix's scale factor expressed in
  base units

#### Scenario: Value section absent for functions
- **WHEN** the detail page is opened for any function entry
- **THEN** no value section is rendered

#### Scenario: Value section absent when resolution fails
- **WHEN** resolution of the unit throws an exception
- **THEN** no value section is rendered and no error is surfaced to the user

---

### Requirement: Domain and range (functions only)
For function entries that carry domain or range constraints the detail page
SHALL display those constraints in a domain/range section.

The display SHALL use the quantity expression from each `QuantitySpec` where
present, along with any bound values.

#### Scenario: Domain shown when specified
- **WHEN** the function has a non-null `domain` with at least one
  `QuantitySpec` that carries a quantity or bounds
- **THEN** the domain information is visible in a domain/range section

#### Scenario: Range shown when specified
- **WHEN** the function has a non-null `range` with a `QuantitySpec` that
  carries a quantity or bounds
- **THEN** the range information is visible in the domain/range section

#### Scenario: Domain/range section absent when unconstrained
- **WHEN** the function has null `domain` and null `range`
- **THEN** no domain/range section is rendered

---

### Requirement: Piecewise function control-point table
For `PiecewiseFunction` entries the detail page SHALL display a two-column
table of all control points from `PiecewiseFunction.points`, in the order
they are stored.

- The input column header is always `"Input"` — piecewise function arguments
  are always dimensionless so no unit expression is needed.
- The output column header SHALL use the `outputUnitExpression` from
  `func.range` when it is non-null and not `"1"`.  When that expression is
  absent the header SHALL fall back to
  `func.range.quantity.dimension.canonicalRepresentation()`.  When the
  range dimension is dimensionless the header SHALL read plain `"Output"`.
- Each row SHALL show one `(x, y)` pair from `points`.

#### Scenario: Points table rendered for piecewise function
- **WHEN** the detail page is opened for a `PiecewiseFunction` with N control
  points
- **THEN** a table with N data rows is shown, one per control point, in the
  same order as `PiecewiseFunction.points`

#### Scenario: Output header uses outputUnitExpression when set
- **WHEN** the function's range has a non-null `outputUnitExpression` (e.g. `"K"`)
- **THEN** the output column header reads `"Output (K)"`

#### Scenario: Output header falls back to canonical representation
- **WHEN** the function's range has no `outputUnitExpression` but has a
  non-dimensionless quantity
- **THEN** the output column header reads `"Output (<canonical rep>)"`

#### Scenario: Input header is always plain "Input"
- **WHEN** any `PiecewiseFunction` detail page is rendered
- **THEN** the input column header reads `"Input"` with no unit appended

#### Scenario: Column headers fall back to generic labels
- **WHEN** the function has no range quantity
- **THEN** the column headers read `"Input"` and `"Output"`

#### Scenario: Points table absent for non-piecewise functions
- **WHEN** the detail page is opened for any function that is not a
  `PiecewiseFunction`
- **THEN** no points table is rendered

---

### Requirement: Long-press copy
The Name, Definition, and Value fields SHALL support long-press to copy their
text content to the system clipboard.  After copying, a snackbar SHALL be
shown with the message `"Copied: <text>"`.

#### Scenario: Long-pressing Name copies the primary ID
- **WHEN** the user long-presses the Name field
- **THEN** the primary ID is written to the clipboard and a snackbar reading
  `"Copied: <id>"` appears

#### Scenario: Long-pressing Definition copies the definition text
- **WHEN** the user long-presses the Definition field
- **THEN** the definition string is written to the clipboard and a snackbar
  reading `"Copied: <definition>"` appears

#### Scenario: Long-pressing Value copies the formatted quantity
- **WHEN** the detail page is open for a unit or prefix that has a value
  and the user long-presses the Value field
- **THEN** the formatted quantity string is written to the clipboard and a
  snackbar reading `"Copied: <value>"` appears

---

### Requirement: Alias navigation routing
The detail page SHALL always display the information for the primary entry,
regardless of whether the user tapped a primary or alias row in the browse
list.

#### Scenario: Alias tap shows primary detail page
- **WHEN** the user taps a browse list row that represents an alias
- **THEN** the detail page opens showing the primary entry's information
  (identical to tapping the primary row directly)
