## 1. Tests

- [x] 1.1 Add widget tests for swap button visibility (always present between the fields)
- [x] 1.2 Add widget tests for enabled state: disabled when either field is empty, enabled when both are non-empty
- [x] 1.3 Add widget test for swap action: field contents are exchanged and evaluation is triggered

## 2. Implementation

- [x] 2.1 Update output field `onChanged` to call `setState` (needed so the swap button enable state rebuilds when the output field changes)
- [x] 2.2 Add `_swap()` method to `_FreeformScreenState` that exchanges controller text, cancels the debounce, and calls `_evaluate()`
- [x] 2.3 Replace the `SizedBox(height: 16)` spacer between the two fields with a `Row` containing a centred `IconButton` (icon: `Icons.swap_vert`) whose `onPressed` is `_swap` when `_canSwap` is true, and `null` otherwise
