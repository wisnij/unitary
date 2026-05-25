import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/domain/completion/token_at_cursor.dart';
import '../../../core/domain/models/completion_entry.dart';
import '../../../core/domain/models/unit_repository_provider.dart';

/// Parameters for a completion lookup.
class CompletionQuery {
  const CompletionQuery({required this.text, required this.cursorOffset});

  /// The full expression text in the field.
  final String text;

  /// The current cursor offset (0-based character index).
  final int cursorOffset;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompletionQuery &&
          other.text == text &&
          other.cursorOffset == cursorOffset;

  @override
  int get hashCode => Object.hash(text, cursorOffset);
}

/// Returns a ranked list of [CompletionEntry] suggestions for the identifier
/// token at [query.cursorOffset] in [query.text].
///
/// Returns an empty list when the cursor is not immediately at the end of a
/// valid identifier token of at least 2 characters, or when no repository
/// entries match the token prefix.
final completionsProvider =
    Provider.family<List<CompletionEntry>, CompletionQuery>((ref, query) {
      final token = tokenAtCursor(query.text, query.cursorOffset);
      if (token == null) {
        return const [];
      }
      final repo = ref.watch(unitRepositoryProvider);
      return repo.suggestCompletions(token.prefix);
    });
