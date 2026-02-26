import '../models/quantity.dart';
import '../models/unit_repository.dart';
import 'ast.dart';
import 'lexer.dart';
import 'parser.dart';
import 'token.dart';

/// Convenience class that ties the lexer, parser, and evaluator together.
class ExpressionParser {
  /// Optional unit repository for unit-aware evaluation.
  final UnitRepository? repo;

  /// Active unit-resolution stack, threaded through from [resolveUnit] to
  /// detect circular definitions.
  final Set<String> visited;

  ExpressionParser({this.repo, Set<String>? visited})
    : visited = visited ?? <String>{};

  /// Lex, parse, and evaluate an expression string.
  Quantity evaluate(String input) {
    final ast = parse(input);
    return ast.evaluate(EvalContext(repo: repo, visited: visited));
  }

  /// Lex and parse an expression string, returning the AST.
  ASTNode parse(String input) {
    final tokens = tokenize(input);
    return Parser(tokens, repo: repo).parse();
  }

  /// Lex an expression string, returning the token list.
  List<Token> tokenize(String input) {
    return Lexer(input).scanTokens();
  }
}
