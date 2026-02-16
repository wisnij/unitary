import '../errors.dart';
import 'token.dart';

/// Converts an input string into a list of [Token]s.
///
/// Handles numbers (including scientific notation), operators (including
/// Unicode variants), and identifiers. Implicit multiplication is handled
/// by the parser, not the lexer.
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
      if (_isAtEnd()) {
        break;
      }
      _start = _current;
      _scanToken();
    }

    _tokens.add(Token(TokenType.eof, '', null, _line, _column));
    return _tokens;
  }

  /// ```
  /// PLUS      = "+"
  /// MINUS     = "-" / "‒" / "–" / "−"
  /// TIMES     = ("*" !"*") / "·" / "×" / "⋅" / "⨉"
  /// DIVIDE    = "/" / "÷" / "per"
  /// DIVIDENUM = "|" / "⁄"
  /// POWER     = "^" / "**"
  /// LPAR      = "("
  /// RPAR      = ")"
  /// COMMA     = ","
  /// ```
  void _scanToken() {
    final startLine = _line;
    final startColumn = _column;
    final c = _advance();

    switch (c) {
      case '+':
        _tokens.add(Token(TokenType.plus, '+', null, startLine, startColumn));
      case '-':
      case '\u2012': // ‒ figure dash
      case '\u2013': // – en dash
      case '\u2212': // − minus sign
        _tokens.add(Token(TokenType.minus, c, null, startLine, startColumn));
      case '*':
        if (!_isAtEnd() && _peek() == '*') {
          _advance();
          _tokens.add(
            Token(TokenType.exponent, '**', null, startLine, startColumn),
          );
        } else {
          _tokens.add(
            Token(TokenType.times, '*', null, startLine, startColumn),
          );
        }
      case '\u00B7': // · middle dot
      case '\u00D7': // × multiplication sign
      case '\u22C5': // ⋅ dot operator
      case '\u2A09': // ⨉ N-ary times operator
        _tokens.add(Token(TokenType.times, c, null, startLine, startColumn));
      case '/':
      case '\u00F7': // ÷ division sign
        _tokens.add(Token(TokenType.divide, c, null, startLine, startColumn));
      case '|':
      case '\u2044': // ⁄ fraction slash
        _tokens.add(
          Token(TokenType.divideNum, c, null, startLine, startColumn),
        );
      case '^':
        _tokens.add(
          Token(TokenType.exponent, '^', null, startLine, startColumn),
        );
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

  /// ```
  /// NUMBER      = coefficient exponent?
  /// coefficient = "." digits / digits ( "." digits? )?
  /// exponent    = [eE] sign? digits
  /// sign        = [-+]
  /// digits      = [0-9]+
  /// ```
  void _scanNumber(int startLine, int startColumn) {
    while (!_isAtEnd() && _isDigit(_peek())) {
      _advance();
    }

    // Decimal part (only if we haven't already started with '.').
    final lexemeSoFar = _source.substring(_start, _current);
    if (!lexemeSoFar.contains('.') && !_isAtEnd() && _peek() == '.') {
      _advance(); // consume '.'
      while (!_isAtEnd() && _isDigit(_peek())) {
        _advance();
      }
    }

    // Scientific notation: only if 'e'/'E' is immediately followed by
    // an optional sign and at least one digit (no intervening whitespace).
    if (!_isAtEnd() && (_peek() == 'e' || _peek() == 'E')) {
      // Look ahead to validate the pattern before consuming 'e'.
      var lookahead = _current + 1;
      if (lookahead < _source.length &&
          (_source[lookahead] == '+' || _source[lookahead] == '-')) {
        lookahead++;
      }
      // Only parse as scientific notation if there's at least one digit.
      if (lookahead < _source.length && _isDigit(_source[lookahead])) {
        _advance(); // consume 'e' or 'E'
        if (!_isAtEnd() && (_peek() == '+' || _peek() == '-')) {
          _advance(); // consume sign
        }
        while (!_isAtEnd() && _isDigit(_peek())) {
          _advance();
        }
      }
      // If pattern doesn't match, 'e' is not consumed and will be lexed
      // as a separate identifier token.
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
    if (lexeme == 'per') {
      // Handle as a different spelling of the / operator
      _tokens.add(Token(TokenType.divide, 'per', null, startLine, startColumn));
    } else {
      _tokens.add(
        Token(TokenType.identifier, lexeme, lexeme, startLine, startColumn),
      );
    }
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
