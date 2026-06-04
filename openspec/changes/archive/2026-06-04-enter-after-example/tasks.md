## 1. Implementation

- [x] 1.1 In `freeform_screen.dart`, add `FocusScope.of(context).unfocus()` at the end of the idle-example `onTap` handler (after setting `_inputController.text` and triggering evaluation)

## 2. Tests

- [x] 2.1 Add widget tests in the freeform screen test file asserting that after tapping the idle example, neither field has focus — covering three cases: no prior focus, Convert-from was focused, Convert-to was focused

## 3. Spec Sync

- [x] 3.1 Run `/opsx:sync` to merge the delta spec into `openspec/specs/idle-example-hint/spec.md`
