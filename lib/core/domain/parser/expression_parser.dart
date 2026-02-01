import '../models/quantity.dart';
import 'ast.dart';
import 'lexer.dart';
import 'parser.dart';
import 'token.dart';

/// Convenience class that ties the lexer, parser, and evaluator together.
class ExpressionParser {
  /// Lex, parse, and evaluate an expression string.
  Quantity evaluate(String input) {
    final tokens = Lexer(input).scanTokens();
    final ast = Parser(tokens).parse();
    return ast.evaluate(const EvalContext());
  }

  /// Lex and parse an expression string, returning the AST.
  ASTNode parse(String input) {
    final tokens = Lexer(input).scanTokens();
    return Parser(tokens).parse();
  }

  /// Lex an expression string, returning the token list.
  List<Token> tokenize(String input) {
    return Lexer(input).scanTokens();
  }
}
