import '../errors.dart';
import '../parser/lexer.dart';
import '../parser/token.dart';

/// The result of detecting a completable identifier token at a cursor position.
///
/// [prefix] is the full lexeme of the identifier (equal to
/// `text.substring(start, cursorOffset)` since the cursor must be at the end
/// of the token).  [start] is the 0-based character offset of the first
/// character of the identifier.
typedef TokenAtCursor = ({String prefix, int start});

/// Returns the identifier token ending at [cursorOffset] in [text], or [null]
/// if the cursor is not positioned immediately after a valid identifier of at
/// least 2 characters.
///
/// Uses the [Lexer] to tokenize [text] so that identifier character boundaries
/// are defined consistently with the expression parser.  Returns [null] when:
///
/// - The expression cannot be lexed ([LexException]).
/// - No identifier token spans [cursorOffset].
/// - The cursor is within (but not at the end of) an identifier.
/// - The token at the cursor is in whitespace, an operator, or a number.
/// - The identifier at the cursor is shorter than 2 characters.
///
/// Note: lexing only a prefix of the text is intentionally avoided, as it
/// would give false positives for mid-identifier cursors (e.g. `"123 ident|ifier"`
/// would incorrectly appear to end on an identifier token).
TokenAtCursor? tokenAtCursor(String text, int cursorOffset) {
  List<Token> tokens;
  try {
    tokens = Lexer(text).scanTokens();
  } on LexException {
    return null;
  }

  for (final token in tokens) {
    if (token.type == TokenType.eof) {
      break;
    }
    // Expressions are single-line, so column is always char offset + 1.
    final start = token.column - 1;
    final end = start + token.lexeme.length;
    if (cursorOffset < start) {
      // Cursor is in whitespace before this token; no match possible.
      break;
    }
    if (cursorOffset <= end) {
      // Cursor is within this token's character range.
      if (token.type == TokenType.identifier &&
          cursorOffset == end &&
          token.lexeme.length >= 2) {
        return (prefix: token.lexeme, start: start);
      }
      return null;
    }
  }
  return null;
}
