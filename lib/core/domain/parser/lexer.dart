import '../errors.dart';
import 'token.dart';

/// Converts an input string into a list of [Token]s.
///
/// Handles numbers (including scientific notation), operators (including
/// Unicode variants), identifiers (classified as functions or units based
/// on whether they are followed by `(`), and implicit multiplication.
class Lexer {
  final String _source;

  int _start = 0;
  int _current = 0;
  int _line = 1;
  int _column = 1;
  final List<Token> _tokens = [];

  Lexer(this._source);

  /// Scans the full input and returns the list of tokens, ending with EOF.
  List<Token> scanTokens() {
    while (!_isAtEnd()) {
      _skipWhitespace();
      if (_isAtEnd()) break;
      _start = _current;
      _scanToken();
    }

    _tokens.add(Token(TokenType.eof, '', null, _line, _column));
    return _insertImplicitMultiplies(_tokens);
  }

  void _scanToken() {
    final startLine = _line;
    final startColumn = _column;
    final c = _advance();

    switch (c) {
      case '+':
        _tokens.add(Token(TokenType.plus, '+', null, startLine, startColumn));
      case '-':
        _tokens.add(Token(TokenType.minus, '-', null, startLine, startColumn));
      case '*':
        if (!_isAtEnd() && _peek() == '*') {
          _advance();
          _tokens.add(
            Token(TokenType.power, '**', null, startLine, startColumn),
          );
        } else {
          _tokens.add(
            Token(TokenType.multiply, '*', null, startLine, startColumn),
          );
        }
      case '/':
        _tokens.add(Token(TokenType.divide, '/', null, startLine, startColumn));
      case '|':
        _tokens.add(
          Token(TokenType.divideHigh, '|', null, startLine, startColumn),
        );
      case '^':
        _tokens.add(Token(TokenType.power, '^', null, startLine, startColumn));
      case '(':
        _tokens.add(
          Token(TokenType.leftParen, '(', null, startLine, startColumn),
        );
      case ')':
        _tokens.add(
          Token(TokenType.rightParen, ')', null, startLine, startColumn),
        );
      case ',':
        _tokens.add(Token(TokenType.comma, ',', null, startLine, startColumn));
      case '\u00D7': // ×
        _tokens.add(
          Token(TokenType.multiply, '\u00D7', null, startLine, startColumn),
        );
      case '\u00B7': // ·
        _tokens.add(
          Token(TokenType.multiply, '\u00B7', null, startLine, startColumn),
        );
      case '\u00F7': // ÷
        _tokens.add(
          Token(TokenType.divide, '\u00F7', null, startLine, startColumn),
        );
      case '.':
        if (!_isAtEnd() && _isDigit(_peek())) {
          _scanNumber(startLine, startColumn);
        } else {
          throw LexException(
            'Unexpected character: .',
            line: startLine,
            column: startColumn,
          );
        }
      default:
        if (_isDigit(c)) {
          _scanNumber(startLine, startColumn);
        } else if (_isAlpha(c)) {
          _scanIdentifier(startLine, startColumn);
        } else {
          throw LexException(
            'Unexpected character: $c',
            line: startLine,
            column: startColumn,
          );
        }
    }
  }

  void _scanNumber(int startLine, int startColumn) {
    while (!_isAtEnd() && _isDigit(_peek())) {
      _advance();
    }

    // Decimal part (only if we haven't already started with '.').
    final lexemeSoFar = _source.substring(_start, _current);
    if (!lexemeSoFar.contains('.') &&
        !_isAtEnd() &&
        _peek() == '.' &&
        _current + 1 < _source.length &&
        _isDigit(_source[_current + 1])) {
      _advance(); // consume '.'
      while (!_isAtEnd() && _isDigit(_peek())) {
        _advance();
      }
    }

    // Scientific notation.
    if (!_isAtEnd() && (_peek() == 'e' || _peek() == 'E')) {
      _advance();
      if (!_isAtEnd() && (_peek() == '+' || _peek() == '-')) {
        _advance();
      }
      if (_isAtEnd() || !_isDigit(_peek())) {
        throw LexException(
          'Invalid scientific notation',
          line: startLine,
          column: startColumn,
        );
      }
      while (!_isAtEnd() && _isDigit(_peek())) {
        _advance();
      }
    }

    final lexeme = _source.substring(_start, _current);
    final value = double.parse(lexeme);
    _tokens.add(Token(TokenType.number, lexeme, value, startLine, startColumn));
  }

  void _scanIdentifier(int startLine, int startColumn) {
    while (!_isAtEnd() && _isAlphaNumeric(_peek())) {
      _advance();
    }

    final lexeme = _source.substring(_start, _current);
    final isFunction = _isFollowedByParen();

    if (isFunction) {
      _tokens.add(
        Token(TokenType.function, lexeme, lexeme, startLine, startColumn),
      );
    } else {
      _tokens.add(
        Token(TokenType.unit, lexeme, lexeme, startLine, startColumn),
      );
    }
  }

  /// Checks if the next non-whitespace character is '('.
  bool _isFollowedByParen() {
    var i = _current;
    while (i < _source.length && (_source[i] == ' ' || _source[i] == '\t')) {
      i++;
    }
    return i < _source.length && _source[i] == '(';
  }

  /// Second pass: insert implicit multiply tokens between adjacent tokens
  /// where juxtaposition implies multiplication.
  static List<Token> _insertImplicitMultiplies(List<Token> tokens) {
    if (tokens.length <= 1) return tokens;

    final result = <Token>[];

    for (var i = 0; i < tokens.length; i++) {
      final token = tokens[i];

      // Before adding this token, check if we need an implicit multiply
      // between the previous token and this one.
      if (result.isNotEmpty && _needsImplicitMultiply(result.last, token)) {
        result.add(
          Token(TokenType.multiply, '', null, token.line, token.column),
        );
      }

      result.add(token);
    }

    return result;
  }

  /// Returns true if an implicit multiply should be inserted between
  /// [left] and [right].
  static bool _needsImplicitMultiply(Token left, Token right) {
    // Left must be a "value-producing" token.
    final leftIsValue =
        left.type == TokenType.number ||
        left.type == TokenType.unit ||
        left.type == TokenType.rightParen;

    if (!leftIsValue) return false;

    // Right must start a new primary expression.
    // But NOT if left is a function token (function followed by paren is
    // a call, not multiplication).  Since functions are already classified
    // by the lexer, a unit followed by '(' IS implicit multiply.
    final rightStartsPrimary =
        right.type == TokenType.number ||
        right.type == TokenType.unit ||
        right.type == TokenType.function ||
        right.type == TokenType.leftParen;

    return rightStartsPrimary;
  }

  void _skipWhitespace() {
    while (!_isAtEnd()) {
      final c = _peek();
      if (c == ' ' || c == '\t') {
        _advance();
      } else if (c == '\n') {
        _line++;
        _column = 0;
        _advance();
      } else if (c == '\r') {
        _advance();
      } else {
        break;
      }
    }
  }

  String _advance() {
    final c = _source[_current];
    _current++;
    _column++;
    return c;
  }

  String _peek() => _source[_current];

  bool _isAtEnd() => _current >= _source.length;

  bool _isDigit(String c) => c.codeUnitAt(0) >= 48 && c.codeUnitAt(0) <= 57;

  bool _isAlpha(String c) {
    final code = c.codeUnitAt(0);
    return (code >= 65 && code <= 90) ||
        (code >= 97 && code <= 122) ||
        c == '_';
  }

  bool _isAlphaNumeric(String c) => _isAlpha(c) || _isDigit(c);
}
