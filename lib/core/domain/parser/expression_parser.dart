import '../models/quantity.dart';
import '../models/unit_repository.dart';
import 'ast.dart';
import 'lexer.dart';
import 'parser.dart';
import 'token.dart';

/// Convenience class that ties the lexer, parser, and evaluator together.
class ExpressionParser {
  /// Unit repository for unit-aware evaluation.
  final UnitRepository repo;

  /// Active unit-resolution stack, threaded through from [resolveUnit] to
  /// detect circular definitions.
  final Set<String> visited;

  /// Optional variable bindings that shadow unit lookups during evaluation.
  final Map<String, Quantity>? variables;

  ExpressionParser({required this.repo, Set<String>? visited, this.variables})
    : visited = visited ?? <String>{};

  /// Lex, parse, and evaluate an expression string.
  Quantity evaluate(String input) {
    final ast = parseExpression(input);
    return ast.evaluate(
      EvalContext(repo: repo, visited: visited, variables: variables),
    );
  }

  /// Lex and parse an expression string, returning an [ExpressionNode].
  ///
  /// Use this entry point when the input is known to be a mathematical
  /// expression (not a bare function name reference).
  ExpressionNode parseExpression(String input) =>
      Parser(tokenize(input), repo: repo).parseExpression();

  /// Lex and parse an input that may be an expression or a bare function name.
  ///
  /// Returns a [FunctionNameNode] when the input is exactly a bare known-
  /// function identifier (optionally preceded by `~`).  Otherwise delegates
  /// to [Parser.parseExpression] and returns the resulting [ExpressionNode].
  ///
  ASTNode parseQuery(String input) =>
      Parser(tokenize(input), repo: repo).parseQuery();

  /// Evaluate an already-parsed [ExpressionNode] using this parser's context.
  Quantity evaluateNode(ExpressionNode node) => node.evaluate(
    EvalContext(repo: repo, visited: visited, variables: variables),
  );

  /// Lex an expression string, returning the token list.
  List<Token> tokenize(String input) {
    return Lexer(input).scanTokens();
  }
}
