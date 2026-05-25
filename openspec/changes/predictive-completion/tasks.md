## 1. Domain Layer: Token Detection

- [x] 1.1 Create `lib/core/domain/completion/token_at_cursor.dart` with a `tokenAtCursor(String text, int cursorOffset)` function returning `({String prefix, int start})?` — lexes the full text via `Lexer`, finds the `identifier` token whose range spans the cursor, returns a result only if `cursorOffset == tokenEnd`; returns `null` otherwise
- [x] 1.2 Handle `LexException` gracefully: catch and return `null` (do not fall back to lexing a prefix, as that would give false positives for mid-identifier cursors)
- [x] 1.3 Write tests in `test/core/domain/completion/token_at_cursor_test.dart` covering: cursor at end of identifier (≥2 chars), single-character token (→ null), cursor mid-identifier (→ null, e.g. `"123 ident|ifier"`), cursor in whitespace (→ null), cursor after operator (→ null), sci-notation `1e10` cursor after `e` (→ null), cursor at start of identifier (→ null), empty string (→ null)

## 2. Domain Layer: Suggestion Computation

- [x] 2.1 Add `CompletionEntry` value class to `lib/core/domain/models/completion_entry.dart` with fields: `name` (String), `isPrimaryId` (bool), `entryKind` (enum: unit, function, prefix)
- [x] 2.2 Add `suggestCompletions(String prefix, {int limit = 50}) → List<CompletionEntry>` method to `UnitRepository` — iterates `_unitLookup`, `_prefixLookup`, `_functionLookup` with case-insensitive substring filter; sorts results into two tiers (prefix matches first, then infix matches), each sorted alphabetically; primary IDs and aliases interleaved within each tier
- [x] 2.3 Write tests in `test/core/domain/models/unit_repository_suggest_test.dart` covering: prefix match, infix match, prefix-before-infix ordering, case-insensitive match, empty prefix, no matches, functions returned, prefixes returned, alphabetical sort within each tier, limit enforced

## 3. State Layer: Completion Provider

- [x] 3.1 Create `lib/features/freeform/state/completion_provider.dart` with a `CompletionQuery` value class `{String text, int cursorOffset}` and a `completionsProvider(CompletionQuery) → List<CompletionEntry>` provider (synchronous `Provider.family`)
- [x] 3.2 Provider logic: call `tokenAtCursor`, return `[]` if no token or token is empty, call `repo.suggestCompletions(token.token)`, return result
- [x] 3.3 Write tests in `test/features/freeform/state/completion_provider_test.dart` covering: suggestions returned for partial identifier, empty list for whitespace cursor, empty list for empty token, result from repo passed through

## 4. UI Layer: CompletionField Widget

- [x] 4.1 Create `lib/features/freeform/presentation/widgets/completion_field.dart` — a `CompletionField` `ConsumerStatefulWidget` wrapping a child `TextField` with an `OverlayPortal` (or `CompositedTransformTarget`/`CompositedTransformFollower`) for the suggestion list
- [x] 4.2 Implement overlay anchor positioning: render below field by default; switch to above when field center is in the lower half of the viewport
- [x] 4.3 Implement overlay show/hide logic: show when field is focused + suggestions list is non-empty; hide on focus loss, empty token, or no matches
- [x] 4.4 Build the suggestion list widget: `ListView` capped at 8 visible items (fixed item height), each row shows `CompletionEntry.name`, tapping a row calls the insertion callback
- [x] 4.5 Write widget tests in `test/features/freeform/presentation/widgets/completion_field_test.dart` covering: overlay appears when typing partial unit, overlay hidden when no matches, overlay hidden on focus loss, tap inserts completion and dismisses overlay

## 5. UI Layer: Tap-to-Insert Logic

- [x] 5.1 Implement insertion logic in `CompletionField`: on suggestion tap, call `tokenAtCursor` on the controller's current value, replace `text[start..end]` with the selected name, set `controller.selection` to collapsed at `start + name.length`
- [x] 5.2 After insertion, dismiss the overlay and invoke the provided `onChanged` callback so the parent screen re-triggers evaluation
- [x] 5.3 Write unit tests for the token-replacement logic (pure function): correct replacement at start, middle, and end of expression; cursor positioned correctly

## 6. Integration: Wire CompletionField into FreeformScreen

- [x] 6.1 Wrap the "Convert from" `TextField` in `FreeformScreen` with `CompletionField`; pass `controller`, `focusNode`, and `onChanged` through
- [x] 6.2 Wrap the "Convert to" `TextField` similarly
- [x] 6.3 Confirm that each field's overlay is independent (only the focused field shows suggestions)
- [x] 6.4 Write integration tests in `test/features/freeform/presentation/freeform_screen_test.dart` covering: both fields surface completions, only focused field shows overlay, tapping suggestion updates expression and triggers evaluation

## 7. Documentation and Cleanup

- [x] 7.1 Add dartdoc comments to `tokenAtCursor`, `CompletionEntry`, `UnitRepository.suggestCompletions`, and `CompletionField`
- [x] 7.2 Run `flutter test --reporter failures-only` and confirm all tests pass
- [x] 7.3 Run `flutter analyze` and fix any lint errors
- [x] 7.4 Update `README.md` current test count and phase status if needed
- [x] 7.5 Update `doc/design_progress.md` to record this feature as complete
