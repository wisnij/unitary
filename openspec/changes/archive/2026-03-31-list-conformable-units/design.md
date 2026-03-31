## Context

The freeform screen evaluates expressions and converts between units, but
offers no way to discover which units are compatible with a given input.
Users must already know the unit name to type into the "Convert to" field.
This change adds an AppBar icon button that opens a scrollable modal list of
all registered units and functions whose dimension is conformable with the
evaluated "Convert from" expression, letting users browse and select a target.

The freeform screen (`FreeformScreen`) is currently a body-only widget whose
`TextEditingController`s and evaluation logic live in a private `ConsumerState`.
The `AppBar` is owned by `HomeScreen`, which also hosts the worksheet page and
shared navigation drawer.  `UnitRepository` already exposes `allUnits` and
`allFunctions` iterables but has no conformability-query method.

## Goals / Non-Goals

**Goals:**

- Add `UnitRepository.findConformable(Dimension)` returning all conformable
  primary units (excluding prefixes) and functions, sorted case-insensitively
  by name.
- Add an icon button to the freeform AppBar that opens a conformable-units
  modal bottom sheet.
- The modal displays each entry's name and either its definition expression
  (for `DerivedUnit`) or a function-type label ("function" or "piecewise linear
  function").  Aliases are included and displayed as `"alias = primaryId"`.
- Tapping an entry dismisses the modal and overwrites the "Convert to" field
  with the entry's name.
- Button is disabled (greyed out) when the input has not produced a quantity
  with a fixed dimension.

**Non-Goals:**

- Search/filter within the conformable-units list.
- Listing prefixed unit variants (e.g. `km`, `mm`) — only canonical unit IDs
  and their registered aliases.
- Persisting or remembering the last selected entry.

## Decisions

### 1. `ConformableEntry` return type

`findConformable` returns `List<ConformableEntry>`, a simple value class:

```dart
class ConformableEntry {
  final String name;
  final String? definitionExpression; // non-null for DerivedUnit (and their aliases)
  final String? functionLabel;        // non-null for functions (and their aliases)
  final String? aliasFor;             // non-null for alias entries; the primary ID
}
```

`definitionExpression` and `functionLabel` are mutually exclusive.
`PrimitiveUnit` entries have both null; the UI renders `"[primitive unit]"` for
them as a special case.  Alias entries carry the same `definitionExpression` or
`functionLabel` as their primary entry, plus a non-null `aliasFor`.

**Alternative considered:** returning `(Unit | UnitaryFunction)` discriminated
union.  Rejected: callers (UI) only need name and display strings; exposing raw
domain objects couples the UI layer to the domain model unnecessarily.

### 2. Lazy quantity cache in `UnitRepository`

Resolving 7000+ units on every button press would be too slow.  A
`Map<String, Quantity?>` cache (`_resolvedQuantityCache`) is built lazily
the first time `findConformable` is called.  Entries that throw during
resolution are stored as `null` and silently excluded from results.

The cache stores the full resolved `Quantity` (not just the `Dimension`) so
that callers have access to the SI conversion factor if needed in future use
cases.  Conformability in `findConformable` is checked against
`cachedQuantity.dimension`.

The cache is keyed by unit primary ID and is never invalidated during a session
(unit definitions are immutable at runtime).

**Alternative considered:** pre-computing the cache at registration time
(during `withPredefinedUnits()`).  Rejected: it would slow startup and
requires careful handling of forward references, since units registered early
may reference units not yet registered.

**Alternative considered:** async/isolate offload.  Rejected for MVP: the lazy
cache means only the first button press pays the build cost; subsequent presses
are O(n) over the cache map, which is fast.

### 3. Decoupling the AppBar button from `FreeformScreen`

`HomeScreen` owns the `AppBar` and must add the button only when the freeform
page is active.  `FreeformScreen` owns the `TextEditingController`s and must
react to the button press (force-evaluate, build the entry list, show the
modal, handle the tap-back).

Rather than pass a `GlobalKey` or build a callback chain, this change uses a
lightweight Riverpod trigger provider:

```dart
final conformableBrowseRequestProvider =
    NotifierProvider<ConformableBrowseNotifier, int>(ConformableBrowseNotifier.new);
```

`HomeScreen` calls `notifier.trigger()` (which increments the counter) when the
button is pressed.  `FreeformScreen` uses `ref.listenManual` in `initState` to
subscribe durably and detect each increment; the subscription is closed in
`dispose`.  `ref.listenManual` is used instead of `ref.listen` (in `build`)
because the latter does not fire when the provider changes outside of a build
cycle, which causes the subscription to be silently dropped in widget tests.

This keeps the two widgets decoupled and the trigger trivially testable.

**Alternative considered:** `GlobalKey<_FreeformScreenState>` with a public
`showConformableUnits()` method.  Rejected: mixes UI-tree references with
logic, harder to test.

**Alternative considered:** making `FreeformScreen` a `Scaffold` with its own
`AppBar`.  Rejected: requires a larger restructuring of `HomeScreen` (shared
drawer, consistent AppBar height, worksheet page consistency) out of scope for
this change.

### 4. Button enabled/disabled state

The button is enabled when `freeformProvider` holds any result type that
carries a well-defined evaluated `Quantity` dimension:

- `EvaluationSuccess` — numeric expression result
- `ConversionSuccess` — two-field conversion result
- `UnitDefinitionResult` — bare unit name lookup (e.g. `byte`); the parser
  resolves the unit to a `Quantity`, so a dimension is available
- `FunctionConversionResult` — function applied to a value; the output
  `Quantity` has a known dimension

`FunctionDefinitionResult` is excluded even though it is a "success" state:
a bare function name (e.g. `tempC`) is a definition lookup, not an evaluation,
and does not produce a quantity with a fixed output dimension.  All error and
idle states are also excluded.

On button press, `FreeformScreen` cancels any pending debounce and
force-evaluates synchronously before querying.  This ensures a freshly-typed
expression is reflected in the list even if the debounce timer has not fired.

### 5. Modal widget and list item rendering

`showModalBottomSheet` is used (vs. `showDialog`) for native mobile feel and
because the list may be long.  The bottom sheet contains a `DraggableScrollableSheet`
wrapping a `ListView.builder` over the sorted `ConformableEntry` list.  Each
item is a `ListTile` with:

- **title**: for alias entries, `"<name> = <aliasFor>"`; otherwise just `name`
- **subtitle**: `functionLabel` if non-null, else `definitionExpression` if
  non-null, else `"[primitive unit]"`

Tapping an item overwrites the "Convert to" field with `entry.name` (the alias
name itself, not the primary ID) and triggers evaluation.  Overwrite (not
append) is used because the selected name is already conformable; appending to
existing field text could produce a non-conformable expression.

### 6. Functions: range-based conformability

For `UnitaryFunction`, conformability is determined by the function's range
`QuantitySpec.quantity.dimension`.  Functions with no range constraint
(`range.quantity == null`) are excluded — they produce any dimension and would
always appear in every list, which is not meaningful.

The secondary label displayed in the list item is:
- `"[piecewise linear function]"` for `PiecewiseFunction`
- `"[function]"` for all other `UnitaryFunction` subtypes
- `"[primitive unit]"` for `PrimitiveUnit`
- the definition expression string (unparenthesised) for `DerivedUnit`

## Risks / Trade-offs

- **First-press latency**: Building the dimension cache for all 7000+ units on
  first press may take hundreds of milliseconds on low-end devices.  A progress
  indicator (or computing the cache eagerly in a background isolate at startup)
  can be added later if profiling shows this is a real problem.
  → Mitigation: show a loading indicator in the modal while the cache builds.

- **`DraggableScrollableSheet` nesting**: `ModalBottomSheet` + scrollable list
  can have gesture conflict with the parent scroll view.  Use
  `DraggableScrollableSheet` with `expand: false` and a fixed initial size to
  avoid this.
  → Mitigation: set `isScrollControlled: true` on `showModalBottomSheet` and
  test scroll behavior on device.

## Open Questions

- Should the modal include a search/filter field?  Deferred to a future change;
  the list could be large (hundreds of conformable entries for common dimensions
  like length).
- Should the button also appear in worksheet mode (to fill a row's unit)?
  Out of scope for this change; note for future.
