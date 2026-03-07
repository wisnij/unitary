## Context

`_classifyLine` in `tool/import_gnu_units_lib.dart` classifies each GNU Units definition line by inspecting the name token.  It currently checks for `(` before `[`:

```
if (nameToken.contains('(')) → unsupported (nonlinear)
if (nameToken.contains('[')) → piecewise
```

Some piecewise functions have name tokens containing both `[` and `(` because the output unit expression itself uses parentheses.  A real example from GNU Units:

```
plategauge[(oz/ft^2)/(480*lb/ft^3)]
```

The output unit expression `(oz/ft^2)/(480*lb/ft^3)` contains `(`, so the current order causes this entry to hit the `(` branch first and be misclassified as unsupported.

## Goals / Non-Goals

**Goals:**
- Piecewise entries whose name token contains both `[` and `(` are correctly classified as piecewise.
- Entries with only `(` continue to be classified as unsupported.

**Non-Goals:**
- No changes to piecewise parsing logic, codegen, or runtime evaluation.
- No changes to any other part of `_classifyLine`.

## Decisions

**Swap the two checks: `[` before `(`.**

`[` is an unambiguous marker for piecewise functions — no other GNU Units definition type uses bracket syntax in its name token.  `(` is used by nonlinear definitions that are not piecewise.  Checking `[` first correctly handles all combinations:

| Name token pattern                          | Old result    | New result  |
|---------------------------------------------|---------------|-------------|
| `gasmark[degR]`                             | piecewise ✓   | piecewise ✓ |
| `plategauge[(oz/ft^2)/(480*lb/ft^3)]`       | unsupported ✗ | piecewise ✓ |
| `tempC(x)`                                  | unsupported ✓ | unsupported ✓ |

No alternative ordering achieves the same result without additional string analysis.

## Risks / Trade-offs

- **Risk**: Other hidden name-token patterns not covered by the test corpus.
  → Mitigation: the fix is strictly additive — it only changes behavior for tokens that previously fell into the wrong branch.  Existing covered cases are unaffected.
