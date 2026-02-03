import '../errors.dart';
import 'ast.dart';
import 'token.dart';

/// Recursive descent parser that builds an AST from a token list.
///
/// Grammar (lowest to highest precedence):
///
/// ```
/// expression  = sum / DIVIDE listProduct
/// sum         = opProduct ( (PLUS / MINUS) opProduct )*
/// opProduct   = listProduct ( (TIMES / DIVIDE) listProduct )*
/// listProduct = unary power*
/// unary       = ( PLUS / MINUS )? power
/// power       = primary ( EXPONENT unary )*  [folded right-to-left]
/// primary     = numexpr / LPAR expression RPAR / function / unit
/// numexpr     = NUMBER ( NUMDIV NUMBER )*
/// function    = IDENTIFIER LPAR arguments RPAR  [if known builtin function]
/// arguments   = expression ( COMMA expression )*
/// unit        = IDENTIFIER                       [fallback if not function]
/// ```
///
/// Implicit multiplication is handled at the `listProduct` level, giving it
/// higher precedence than explicit `*` and `/`. This means `5 m / 2 s` parses
/// as `(5*m) / (2*s)`.
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

  /// expression = sum / DIVIDE listProduct
  ///
  /// Leading `/` creates a reciprocal (1/x).
  ASTNode _expression() {
    if (_match(TokenType.divide)) {
      final operand = _listProduct();
      return BinaryOpNode(const NumberNode(1.0), TokenType.divide, operand);
    }
    return _sum();
  }

  /// sum = opProduct ( (PLUS / MINUS) opProduct )*
  ASTNode _sum() {
    var left = _opProduct();

    while (_match(TokenType.plus) || _match(TokenType.minus)) {
      final op = _previous().type;
      final right = _opProduct();
      left = BinaryOpNode(left, op, right);
    }

    return left;
  }

  /// opProduct = listProduct ( (TIMES / DIVIDE) listProduct )*
  ASTNode _opProduct() {
    var left = _listProduct();

    while (_match(TokenType.multiply) || _match(TokenType.divide)) {
      final op = _previous().type;
      final right = _listProduct();
      left = BinaryOpNode(left, op, right);
    }

    return left;
  }

  /// listProduct = unary power*
  ///
  /// Implicit multiplication: after parsing `unary`, continue collecting
  /// `power` terms while the current token can start an implicit multiply.
  ASTNode _listProduct() {
    var left = _unary();

    while (_startsImplicitMultiply()) {
      final right = _power();
      left = BinaryOpNode(left, TokenType.multiply, right);
    }

    return left;
  }

  /// Check if current token can start a power (for implicit multiply).
  bool _startsImplicitMultiply() {
    return _check(TokenType.number) ||
        _check(TokenType.identifier) ||
        _check(TokenType.leftParen);
  }

  /// unary = ( PLUS / MINUS ) unary | power
  ///
  /// Recursive to support `--5` (double negation).
  ASTNode _unary() {
    if (_match(TokenType.plus) || _match(TokenType.minus)) {
      final op = _previous().type;
      final operand = _unary();
      return UnaryOpNode(op, operand);
    }
    return _power();
  }

  /// power = primary ( EXPONENT unary )*  [folded right-to-left]
  ///
  /// Right-associative: `2^3^4` = `2^(3^4)`.
  ASTNode _power() {
    final operands = <ASTNode>[_primary()];

    while (_match(TokenType.power)) {
      operands.add(_unary());
    }

    // Fold right-to-left
    var result = operands.last;
    for (var i = operands.length - 2; i >= 0; i--) {
      result = BinaryOpNode(operands[i], TokenType.power, result);
    }

    return result;
  }

  /// primary = numexpr / LPAR expression RPAR / function / unit
  ASTNode _primary() {
    if (_check(TokenType.number)) {
      return _numexpr();
    }

    if (_match(TokenType.leftParen)) {
      final expr = _expression();
      _consume(TokenType.rightParen, "Expected ')' after expression");
      return expr;
    }

    if (_check(TokenType.identifier)) {
      return _identifierOrFunction();
    }

    final token = _peek();
    throw ParseException(
      'Unexpected token: ${token.lexeme.isEmpty ? token.type : token.lexeme}',
      line: token.line,
      column: token.column,
    );
  }

  /// numexpr = NUMBER ( NUMDIV NUMBER )*
  ///
  /// Both operands of `|` must be bare NUMBER literals.
  ASTNode _numexpr() {
    final numberToken = _advance();
    var left = NumberNode(numberToken.literal as double) as ASTNode;

    while (_match(TokenType.divideHigh)) {
      final opToken = _previous();
      if (!_check(TokenType.number)) {
        throw ParseException(
          "Right operand of '|' must be a numeric literal",
          line: opToken.line,
          column: opToken.column,
        );
      }
      final rightToken = _advance();
      final right = NumberNode(rightToken.literal as double);
      left = BinaryOpNode(left, TokenType.divideHigh, right);
    }

    return left;
  }

  /// function = IDENTIFIER LPAR arguments RPAR  [if known builtin function]
  /// unit = IDENTIFIER                          [fallback if not function]
  ///
  /// If the identifier is a known builtin function AND followed by `(`,
  /// parse as function call. Otherwise, treat as unit (which may still
  /// be followed by `(` for implicit multiplication).
  ASTNode _identifierOrFunction() {
    final token = _advance();
    final name = token.literal as String;

    if (_check(TokenType.leftParen) && isBuiltinFunction(name)) {
      _advance(); // consume '('

      // Require at least one argument (zero-arg calls not allowed)
      if (_check(TokenType.rightParen)) {
        throw ParseException(
          "Function '$name' requires at least one argument",
          line: token.line,
          column: token.column,
        );
      }

      final args = _arguments();
      _consume(TokenType.rightParen, "Expected ')' after function arguments");
      return FunctionNode(name, args);
    }

    return UnitNode(name);
  }

  /// arguments = expression ( COMMA expression )*
  List<ASTNode> _arguments() {
    final args = <ASTNode>[_expression()];
    while (_match(TokenType.comma)) {
      args.add(_expression());
    }
    return args;
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
