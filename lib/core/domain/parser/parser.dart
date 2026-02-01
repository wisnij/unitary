import '../errors.dart';
import 'ast.dart';
import 'token.dart';

/// Recursive descent parser that builds an AST from a token list.
///
/// Grammar (lowest to highest precedence):
///
/// ```
/// expression     → addition
/// addition       → multiplication ( ('+' | '-') multiplication )*
/// multiplication → exponentiation ( ('*' | '/' | '÷' | '×' | '·') exponentiation )*
/// exponentiation → highDivision ( ('^' | '**') exponentiation )?
/// highDivision   → unary ( '|' unary )*
/// unary          → ('-' | '+') unary | call
/// call           → primary ( '(' arguments ')' )?    [only for functions]
/// primary        → NUMBER | UNIT | '(' expression ')'
/// ```
///
/// Implicit multiplication (juxtaposition) is handled by the lexer, which
/// inserts synthetic [TokenType.multiply] tokens between adjacent values.
/// These are handled at the `multiplication` level along with explicit `*`
/// and `/`.
///
/// **Note on precedence:** The Phase 1 plan specifies implicit multiplication
/// at a *higher* precedence than explicit multiplication/division.  However,
/// since the lexer inserts implicit multiply as [TokenType.multiply] tokens,
/// they are indistinguishable from explicit `*` at parse time and are handled
/// at the same level.  This means `5 m / 2 s` parses as `((5*m)/2)*s` rather
/// than `(5*m)/(2*s)`.  This is a known Phase 1 simplification; Phase 2 can
/// introduce separate precedence levels if needed once unit identifiers are
/// distinguishable from function names.
class Parser {
  final List<Token> _tokens;
  int _current = 0;

  Parser(this._tokens);

  /// Parses the token list and returns the root AST node.
  ASTNode parse() {
    final node = _expression();
    if (!_isAtEnd()) {
      final token = _peek();
      throw ParseException(
        'Expected end of expression',
        line: token.line,
        column: token.column,
      );
    }
    return node;
  }

  // -- Grammar rules (lowest to highest precedence) --

  /// expression → addition
  ASTNode _expression() => _addition();

  /// addition → multiplication ( ('+' | '-') multiplication )*
  ASTNode _addition() {
    var left = _multiplication();

    while (_match(TokenType.plus) || _match(TokenType.minus)) {
      final op = _previous().type;
      final right = _multiplication();
      left = BinaryOpNode(left, op, right);
    }

    return left;
  }

  /// multiplication → exponentiation ( ('*' | '/' | '÷') exponentiation )*
  ///
  /// Also handles implicit multiply tokens inserted by the lexer.
  ASTNode _multiplication() {
    var left = _exponentiation();

    while (_match(TokenType.multiply) || _match(TokenType.divide)) {
      final op = _previous().type;
      final right = _exponentiation();
      left = BinaryOpNode(left, op, right);
    }

    return left;
  }

  /// exponentiation → highDivision ( ('^' | '**') exponentiation )?
  ///
  /// Right-associative: `2^3^4` = `2^(3^4)`.  The right operand is parsed
  /// at the `exponentiation` level (right-recursive) to achieve this.
  ASTNode _exponentiation() {
    final left = _highDivision();

    if (_match(TokenType.power)) {
      final right = _exponentiation();
      return BinaryOpNode(left, TokenType.power, right);
    }

    return left;
  }

  /// highDivision → unary ( '|' unary )*
  ///
  /// Both operands of `|` must be [NumberNode]s; any other expression is a
  /// parse error.
  ASTNode _highDivision() {
    var left = _unary();

    if (_check(TokenType.divideHigh) && left is! NumberNode) {
      final opToken = _peek();
      throw ParseException(
        "Left operand of '|' must be a numeric literal",
        line: opToken.line,
        column: opToken.column,
      );
    }

    while (_match(TokenType.divideHigh)) {
      final opToken = _previous();
      final right = _unary();

      if (right is! NumberNode) {
        throw ParseException(
          "Right operand of '|' must be a numeric literal",
          line: opToken.line,
          column: opToken.column,
        );
      }

      left = BinaryOpNode(left, TokenType.divideHigh, right);
    }

    return left;
  }

  /// unary → ('-' | '+') unary | call
  ASTNode _unary() {
    if (_match(TokenType.minus) || _match(TokenType.plus)) {
      final op = _previous().type;
      final operand = _unary();
      return UnaryOpNode(op, operand);
    }

    return _call();
  }

  /// call → primary ( '(' arguments ')' )?
  ///
  /// Only consumes parenthesized arguments if the primary was a function
  /// token.
  ASTNode _call() {
    // If current token is a function, consume it and parse arguments.
    if (_check(TokenType.function)) {
      final funcToken = _advance();
      final name = funcToken.literal as String;

      _consume(TokenType.leftParen, "Expected '(' after function '$name'");

      final args = <ASTNode>[];
      if (!_check(TokenType.rightParen)) {
        do {
          args.add(_expression());
        } while (_match(TokenType.comma));
      }

      _consume(TokenType.rightParen, "Expected ')' after function arguments");

      return FunctionNode(name, args);
    }

    return _primary();
  }

  /// primary → NUMBER | UNIT | '(' expression ')'
  ASTNode _primary() {
    if (_match(TokenType.number)) {
      return NumberNode(_previous().literal as double);
    }

    if (_match(TokenType.unit)) {
      return UnitNode(_previous().literal as String);
    }

    if (_match(TokenType.leftParen)) {
      final expr = _expression();
      _consume(TokenType.rightParen, "Expected ')' after expression");
      return expr;
    }

    final token = _peek();
    throw ParseException(
      'Unexpected token: ${token.lexeme.isEmpty ? token.type : token.lexeme}',
      line: token.line,
      column: token.column,
    );
  }

  // -- Token navigation helpers --

  bool _match(TokenType type) {
    if (_check(type)) {
      _advance();
      return true;
    }
    return false;
  }

  bool _check(TokenType type) {
    if (_isAtEnd()) return false;
    return _peek().type == type;
  }

  Token _advance() {
    if (!_isAtEnd()) _current++;
    return _previous();
  }

  Token _peek() => _tokens[_current];

  Token _previous() => _tokens[_current - 1];

  bool _isAtEnd() => _peek().type == TokenType.eof;

  Token _consume(TokenType type, String message) {
    if (_check(type)) return _advance();

    final token = _peek();
    throw ParseException(message, line: token.line, column: token.column);
  }
}
