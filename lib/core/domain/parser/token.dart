/// The type of a lexical token in an expression.
enum TokenType {
  // Literals
  /// A numeric literal: `3.14`, `1.5e-10`, `.5`.
  number,

  /// A unit or function name.
  identifier,

  // Operators
  /// Addition, or unary plus: `+`.
  plus,

  /// Subtraction, or unary negation: `-`.
  minus,

  /// Explicit multiplication: `*`, or the Unicode variants `×`, `·`, `⋅`, `⨉`.
  ///
  /// Implicit multiplication (`5 m`) produces no token of its own — the parser
  /// infers it from adjacent operands, and binds it tighter than this token.
  times,

  /// Division: `/`, `÷`, or the word `per`.
  divide,

  /// Numeric fraction: `|` or `⁄`.
  ///
  /// Distinct from [divide] because it binds at the highest precedence level
  /// and both operands must be bare numeric literals — `2|3 m` is two-thirds
  /// of a metre, and `2|3 m|s` is a parse error.
  divideNum,

  /// Exponentiation: `^` or `**`.
  exponent,

  // Grouping
  /// Opening parenthesis: `(`.
  leftParen,

  /// Closing parenthesis: `)`.
  rightParen,

  /// Argument separator: `,`.
  comma,

  // Prefix operators
  /// Inverse function application: `~`, as in `~tempF`.
  ///
  /// Only meaningful immediately before a known function name.
  inverse,

  /// End of input.  Always the final token in a lexed sequence.
  eof,
}

/// A single token produced by the lexer.
class Token {
  /// The type of this token.
  final TokenType type;

  /// The original source text of this token.
  final String lexeme;

  /// Parsed value: [double] for numbers, [String] for identifiers.
  final Object? literal;

  /// The 1-based line number where this token starts.
  final int line;

  /// The 1-based column number where this token starts.
  final int column;

  const Token(this.type, this.lexeme, this.literal, this.line, this.column);

  @override
  String toString() => 'Token($type, ${literal ?? lexeme})';
}
