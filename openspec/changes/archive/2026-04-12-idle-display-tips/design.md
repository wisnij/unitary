## Context

The freeform screen's result area is driven by `EvaluationResult`, a sealed class with an `EvaluationIdle` subclass.  `ResultDisplay` renders `EvaluationIdle` as a static "Enter an expression" string.

The goal is to replace that text with two lines: a fixed instruction ("Enter an expression above.") and a randomly chosen example drawn from a curated list ("Try: 60 mph").  A new example is picked each time the screen returns to idle, guaranteed to differ from the previous one.

## Goals / Non-Goals

**Goals:**

- Display a fixed instruction line ("Enter an expression above.") and a randomly chosen "Try: …" example line inside the idle result box.
- Pick a new example each time the screen returns to idle, guaranteed to differ from the previous one.
- Cover a range of app features in the example set (unit conversions, SI prefixes, constants, defined functions, compound expressions).

**Non-Goals:**

- Animated transitions between examples.
- User-configurable examples or custom example lists.
- Pre-evaluating the example to show its result.

## Decisions

### Where to store the selected example

**Decision**: `FreeformNotifier` owns a `_lastExample` field and a `_pickExample()` helper that selects a random entry from `idleExamples` different from `_lastExample`.  A private `_idle()` method calls `_pickExample()`, updates `_lastExample`, and returns the new `EvaluationIdle`.  Every idle transition goes through `_idle()`.

**Alternatives considered**:
- A separate `idleExampleProvider` — extra indirection for a trivial value; not worth it.
- Storing state in `EvaluationIdle` itself — the state class is a value object; tracking "last shown" belongs in the notifier.

**Rationale**: `FreeformNotifier` already owns every idle/active lifecycle transition, making it the natural place to manage the example rotation.

### Where to put the example strings

**Decision**: A top-level `const List<String> idleExamples` in a new file `lib/features/freeform/data/idle_examples.dart`.

**Rationale**: Keeps the list out of the widget and provider files, is easy to extend, and has no runtime cost.

### How to thread the example to `ResultDisplay`

**Decision**: Extend `EvaluationIdle` with an optional `String? example` field.  `FreeformNotifier` populates it when transitioning to idle.  `ResultDisplay` reads it directly.

**Alternatives considered**:
- Pass the example as a constructor argument to `ResultDisplay` — requires `HomeScreen` to know about the idle example separately from the result; more coupling.
- Embed a `Consumer` inside `ResultDisplay` — breaks the widget's clean dependency on just `EvaluationResult`.

**Rationale**: Putting the example inside `EvaluationIdle` keeps `ResultDisplay`'s interface unchanged and co-locates the data with the state variant that uses it.

### How to wire the tap-to-fill callback

**Decision**: Add an optional `VoidCallback? onTap` parameter to `ResultDisplay`.  `FreeformScreen` passes a callback that sets `_inputController.text` to the example string and calls `_evaluate()`.

**Alternatives considered**:
- Make the idle display itself a `GestureDetector` with access to the controller — would require lifting the controller or using a global key; breaks encapsulation.
- Return the example via a provider and react to it in `FreeformScreen` — unnecessary indirection for a simple tap action.

**Rationale**: A callback keeps `ResultDisplay` a dumb widget and `FreeformScreen` in control of its own text controller.

## Risks / Trade-offs

- **Same example across cold starts**: Because the example is chosen at provider init (not persisted), restarting the app may show the same example twice in a row (1-in-N chance).  Acceptable for an MVP hint; can be improved later by persisting a "last shown" index.
- **Example validity**: Hardcoded expressions must be valid for the current unit database.  A unit being renamed or removed would silently leave a stale hint.  Mitigation: add a test that evaluates each example against the real `UnitRepository`.
