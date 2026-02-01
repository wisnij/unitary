/// The type of a lexical token in an expression.
enum TokenType {
  // Literals
  number, // 3.14, 1.5e-10, .5
  unit, // any identifier not followed by '('
  // Operators
  plus, // +
  minus, // -
  multiply, // *, ×, ·
  divide, // /, ÷
  divideHigh, // |
  power, // ^, **
  // Grouping
  leftParen, // (
  rightParen, // )
  comma, // ,
  // Functions
  function, // identifier followed by '('
  // Special
  eof, // end of input
}

/// A single token produced by the lexer.
class Token {
  /// The type of this token.
  final TokenType type;

  /// The original source text of this token.
  final String lexeme;

  /// Parsed value: [double] for numbers, [String] for unit/function names.
  final Object? literal;

  /// The 1-based line number where this token starts.
  final int line;

  /// The 1-based column number where this token starts.
  final int column;

  const Token(this.type, this.lexeme, this.literal, this.line, this.column);

  @override
  String toString() => 'Token($type, ${literal ?? lexeme})';
}
