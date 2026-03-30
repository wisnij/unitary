## Why

When displaying a unit definition, the raw definition line is suppressed if it
is identical to the formatted result.  The current check is an exact string
comparison, so cosmetic whitespace differences (e.g. `"m/s"` vs `"m / s"`)
cause the definition line to be shown unnecessarily even though it carries no
new information.

## What Changes

- The redundancy check in `_buildUnitDefinitionResult` SHALL collapse internal
  whitespace before comparing `rawDefinitionLine` to `formattedResult`, so that
  strings that differ only in spacing are still considered identical.

## Capabilities

### New Capabilities

_(none)_

### Modified Capabilities

- `unit-definition-display`: The **Redundant definition line is suppressed**
  requirement currently specifies an exact string comparison; it will be
  broadened to treat strings that differ only in whitespace as identical.

## Impact

- `lib/features/freeform/state/freeform_provider.dart` — one-line change to the
  redundancy check
- `openspec/specs/unit-definition-display/spec.md` — delta spec tightening the
  requirement and adding a new scenario
- No new dependencies; no API or data-model changes
