# Design: Worksheet Mode

## Context

The freeform screen evaluates one expression at a time.  Worksheet mode adds a
second evaluation paradigm: a fixed set of rows, each labelled with a unit or
function, where typing a number in one row propagates computed values to all
others.  The existing `ExpressionParser`, `UnitRepository`, and
`UnitaryFunction` infrastructure already supports everything needed; this
design is purely additive.

Current navigation stub: `HomeScreen` has a disabled "Worksheet" `ListTile` in
the drawer.  Phase 6 enables it.

## Goals / Non-Goals

**Goals:**

- Domain model for worksheet templates (rows as expression strings with kinds)
- 10 predefined templates covering the required unit categories
- Real-time cross-row update engine (ratio-based and function-based)
- Worksheet screen with per-row numeric input fields
- AppBar dropdown for switching between worksheets
- In-session value retention (non-`autoDispose` Riverpod provider)

**Non-Goals:**

- Persistent storage (Phase 7: sqflite)
- Custom user-defined worksheets (Phase 12)
- Unit list rows (`ft;in` multi-field rows) — architecture accommodates them
  but they are not implemented here
- Sidebar pinning of worksheets (future)
- Currency worksheet (Phase 8+)

## Decisions

### 1. Row expressions are strings; kind is explicit

Each `WorksheetRow` stores a `String expression` (parsed on demand) and a
`WorksheetRowKind` (sealed: `UnitRow` | `FunctionRow`).

**Why not auto-detect kind at runtime?**  Auto-detection would couple the UI
rendering to `parseQuery` return types.  The sealed class makes the dispatch
exhaustiveness-checked by Dart, so adding a future `UnitListRow` variant forces
every `switch` site to handle it.  The kind is also meaningful at definition
time — template authors know whether they're specifying a unit or a function.

**Why compound expression strings?**  Simple named units (`ft`, `kg`) and
compound expressions (`m/s`, `km/h`, `ft^2`) use the same `ExpressionParser`
path.  Restricting to atoms would require special-casing the speed and area
worksheets.

### 2. Temperature uses FunctionRow for Celsius and Fahrenheit only

Kelvin (`K`) and Rankine (`degR`) are absolute scales with zero at absolute
zero — they are linear units and use `UnitRow`.  Celsius (`tempC`), Fahrenheit
(`tempF`), and Réaumur (`tempreaumur`) have non-zero origins and require
`FunctionRow`.

This generalises: any row may be a `FunctionRow` provided its output dimension
is conformable with the other rows' dimensions and the function has an inverse.

### 3. "Last keystroke wins" source semantics

The row the user most recently typed in is the conversion source.  Focus change
alone does not transfer source ownership — only a keystroke does.  This
prevents surprising recalculations when a user taps a field to read its value.

State shape:

```dart
class WorksheetState {
    final String worksheetId;
    final int? activeRowIndex;                        // null = no row edited yet
    final Map<String, List<String>> worksheetValues;  // per-template display strings
}
```

`worksheetValues[worksheetId][activeRowIndex]` holds the raw typed string.  All
other entries hold formatted computed values.  The active row is never
overwritten by the engine, preserving what the user typed.  Each template's
values are stored independently so switching worksheets and back preserves
values.

### 4. FunctionRow conversion via existing inverse mechanism

`UnitaryFunction.callInverse()` already exists and is used by the freeform
`FunctionConversionResult` path.  The worksheet engine reuses it directly:

```
source row is FunctionRow:
  base = func.call([Quantity(typedValue, dimensionless)], context)
  → yields base Quantity in primitive units

other row is FunctionRow:
  display = func.callInverse([base], context)  → scalar

other row is UnitRow:
  display = base.value / unitQty.value
```

No new function infrastructure is required.

### 5. Invalid input clears all other rows

Worksheet inputs accept only numeric strings.  On parse failure or empty
active-row input, all other `displayValues` are set to `""`.  This is simpler
than showing stale values, and numeric-only fields make invalid states rare.

### 6. In-session memory via non-`autoDispose` provider

A single `worksheetProvider` (non-`autoDispose` `NotifierProvider`) holds the
active worksheet ID and all row display values.  Navigating away and back
preserves values.  Values are lost on app restart; Phase 7 will add sqflite
persistence.

### 7. AppBar dropdown for worksheet selection

With 10 worksheets (11+ eventually), a tab bar overflows on narrow screens.
A `DropdownButton` in the `AppBar` is compact, scales to any count, and is
familiar to mobile users.  Sidebar pinning (future) will add fast-path `ListTile`s
in the drawer without changing this mechanism.

## Risks / Trade-offs

**FunctionRow dimension conformability is checked at runtime, not at template
definition time** → If a template is misconfigured (e.g., a `FunctionRow`
whose output dimension doesn't match the other rows), the error surfaces as a
runtime `EvalException` or a failed conversion.  Mitigation: predefined
templates are covered by tests; the engine surfaces a per-row error string
rather than crashing.

**No input validation beyond "is this a number?"** → Users can type `1e308`
and get `Infinity` in other fields.  Acceptable for MVP; can add range
validation later.

**In-session state resets on hot reload during development** → Acceptable;
this only affects the development workflow, not production.

## Open Questions

None — all design decisions were resolved in the explore session.
