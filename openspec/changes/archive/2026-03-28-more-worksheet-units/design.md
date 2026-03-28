## Context

`predefined_worksheets.dart` defines 10 `WorksheetTemplate` constants, each containing a
list of `WorksheetRow` entries.  Eight templates currently have fewer than 10 rows.  No model,
engine, or state code needs to change; this is purely a data update to that one file.

## Goals / Non-Goals

**Goals:**
- Bring every template to exactly 10 rows by adding the units specified in the proposal
- Correct the Energy template labels (`cal` → "small calories" / `cal_th`, `kcal` → "food Calories")

**Non-Goals:**
- Reordering rows that are not being touched
- Changing any model, engine, or UI code
- Adding units beyond the 10-row target

## Decisions

**Row ordering within each template**

New rows are inserted by magnitude order (smallest → largest), consistent with all existing
templates.  Specific placements:

- *Length*: `µm` before `mm`
- *Mass*: `µg` before `mg`
- *Time*: `ns` before `µs`, `µs` before `ms`; `century` after `decade`
  — but `decade` is not in the current list, so `century` goes after `year`
- *Area*: `mm^2` before `cm^2`; `yd^2` between `ft^2` and `m^2`
- *Speed*: `m/min` (≈ 0.017 m/s) and `in/s` (≈ 0.025 m/s) are both slower than `km/hr`
  (≈ 0.278 m/s), so both are inserted before it, in that order
- *Pressure*: `MPa` after `bar`; `torr` adjacent to `mmHg` (they are nearly equal);
  `inHg` between `kPa` and `psi`; `mbar` between `Pa` and `mmHg`
- *Energy*: `Wh` between `BTU` and `kcal` (1 Wh = 3600 J; 1 kJ = 1000 J, so Wh > kJ > BTU)
- *Digital Storage*: SI units (`kB`, `MB`, `GB`, `TB`) interleaved with IEC units by
  magnitude — `kB` before `KiB`, `MB` before `MiB`, etc.

**Unicode µ in expression strings**

The proposal uses `µm`, `µg`, `µs` (U+00B5 MICRO SIGN) in expression strings.  The unit
repository registers `micro` with aliases `['u', 'µ', 'μ']`, so both the ASCII `u` and the
Unicode `µ` work.  Use `µ` in expressions to match the proposal and be visually unambiguous
to future readers of the source.

**`cal_th` instead of `cal` for small calories**

`cal` is an alias for `calorie_th` (thermochemical calorie), so both expressions resolve
identically.  Using `cal_th` makes the distinction from food Calories explicit at a glance.

## Risks / Trade-offs

- **µ in source code**: Dart source files are UTF-8, so the `µ` character is valid.  The
  existing codebase already uses `µ` in comments and strings elsewhere.  Risk is low.
- **SI vs IEC storage rows**: Users may expect `kB = 1024 B`; the worksheet does not label
  the distinction.  Mitigation: row labels ("kilobytes", "kibibytes") make the two systems
  visually distinct without requiring extra UI.
