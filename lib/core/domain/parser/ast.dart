import '../errors.dart';
import '../models/quantity.dart';
import '../models/unit_repository.dart';
import 'token.dart';

/// Evaluation context passed to AST nodes during evaluation.
class EvalContext {
  /// Unit repository for resolving unit names.
  final UnitRepository repo;

  /// Set of unit IDs currently being resolved (the active resolution stack).
  /// Used to detect circular unit definitions.
  final Set<String> visited;

  /// Optional variable bindings that shadow unit lookups.  When non-null,
  /// an identifier found in this map is returned directly as a [Quantity]
  /// without consulting the repository.
  final Map<String, Quantity>? variables;

  const EvalContext({
    required this.repo,
    this.visited = const <String>{},
    this.variables,
  });
}

/// Base class for all AST nodes.
///
/// Sealed so that exhaustive switch statements over the full node hierarchy
/// are enforced by the Dart compiler.  Nodes that produce a [Quantity] when
/// evaluated extend [ExpressionNode]; name-reference nodes (e.g.
/// [FunctionNameNode]) extend this class directly.
sealed class ASTNode {
  const ASTNode();
}

/// Abstract base for AST nodes that can be evaluated to a [Quantity].
///
/// Sealed so that exhaustive switch statements over expression node subtypes
/// are enforced by the Dart compiler.  All nodes that produce a value during
/// evaluation extend this class.
sealed class ExpressionNode extends ASTNode {
  const ExpressionNode();

  /// Evaluate this node and return a [Quantity].
  Quantity evaluate(EvalContext context);
}

/// A numeric literal.
class NumberNode extends ExpressionNode {
  final double value;

  const NumberNode(this.value);

  @override
  Quantity evaluate(EvalContext context) => Quantity.dimensionless(value);

  @override
  String toString() => 'NumberNode($value)';
}

/// A unit identifier.
///
/// The unit name is resolved to its base-unit representation via the
/// repository in the evaluation context.  If the unit is not found,
/// an [EvalException] is thrown.
class UnitNode extends ExpressionNode {
  final String unitName;

  const UnitNode(this.unitName);

  @override
  Quantity evaluate(EvalContext context) {
    // Variables shadow unit/repo lookups.
    if (context.variables != null && context.variables!.containsKey(unitName)) {
      return context.variables![unitName]!;
    }

    final result = context.repo.findUnitWithPrefix(unitName);
    if (result.unit == null) {
      throw EvalException('Unknown unit: "$unitName"');
    }

    // Resolve to base units: 1 <unit> = quantity in primitives.
    final unitQuantity = context.repo.resolveUnit(
      result.unit!,
      context.visited,
    );
    if (result.prefix != null) {
      final prefixQuantity = context.repo.resolveUnit(
        result.prefix!,
        context.visited,
      );
      return prefixQuantity.multiply(unitQuantity);
    }
    return unitQuantity;
  }

  @override
  String toString() => 'UnitNode($unitName)';
}

/// A binary operation (e.g., +, -, *, /, ^).
class BinaryOpNode extends ExpressionNode {
  final ExpressionNode left;
  final ExpressionNode right;
  final TokenType operator;

  const BinaryOpNode(this.left, this.operator, this.right);

  @override
  Quantity evaluate(EvalContext context) {
    final leftVal = left.evaluate(context);
    final rightVal = right.evaluate(context);

    switch (operator) {
      case TokenType.plus:
        return leftVal.add(rightVal);
      case TokenType.minus:
        return leftVal.subtract(rightVal);
      case TokenType.times:
        return leftVal.multiply(rightVal);
      case TokenType.divide || TokenType.divideNum:
        return leftVal.divide(rightVal);
      case TokenType.exponent:
        if (!rightVal.isDimensionless) {
          throw DimensionException(
            'Exponent must be dimensionless, got '
            '${rightVal.dimension.canonicalRepresentation()}',
          );
        }
        return leftVal.power(rightVal.value);
      default:
        throw EvalException('Unknown binary operator: $operator');
    }
  }

  @override
  String toString() => 'BinaryOp($operator, $left, $right)';
}

/// A unary operation (+ or -).
class UnaryOpNode extends ExpressionNode {
  final TokenType operator;
  final ExpressionNode operand;

  const UnaryOpNode(this.operator, this.operand);

  @override
  Quantity evaluate(EvalContext context) {
    final val = operand.evaluate(context);
    switch (operator) {
      case TokenType.minus:
        return val.negate();
      case TokenType.plus:
        return val;
      default:
        throw EvalException('Unknown unary operator: $operator');
    }
  }

  @override
  String toString() => 'UnaryOp($operator, $operand)';
}

/// A function call with arguments (e.g., sin(x), sqrt(x), ~tempF(212)).
///
/// When [inverse] is true, the call is dispatched to [UnitaryFunction.callInverse]
/// instead of [UnitaryFunction.call], implementing the `~` operator.
class FunctionCallNode extends ExpressionNode {
  final String name;
  final List<ExpressionNode> arguments;
  final bool inverse;

  const FunctionCallNode(this.name, this.arguments, {this.inverse = false});

  @override
  Quantity evaluate(EvalContext context) {
    final func = context.repo.findFunction(name);
    if (func == null) {
      throw EvalException("Unknown function: '$name'");
    }
    final args = arguments.map((a) => a.evaluate(context)).toList();
    return inverse ? func.callInverse(args, context) : func.call(args, context);
  }

  @override
  String toString() => 'FunctionCall($name, $arguments, inverse: $inverse)';
}

/// A bare function name with no argument list.
///
/// Represents either `funcName` (bare forward reference) or `~funcName`
/// (bare inverse reference).  This node carries only the syntactic facts
/// the parser knows; contextual meaning (show definition, show inverse
/// expression, apply inverse conversion) is determined by the calling code.
///
/// This node does NOT extend [ExpressionNode] and cannot be evaluated.
class FunctionNameNode extends ASTNode {
  final String name;
  final bool inverse;

  const FunctionNameNode(this.name, {required this.inverse});

  @override
  String toString() => 'FunctionName($name, inverse: $inverse)';
}

/// A standalone unit or prefix identifier used as a definition request.
///
/// Produced by [ExpressionParser.parseQuery] when the input is a single
/// bare identifier that resolves to a known unit, prefix+unit, or prefix.
class DefinitionRequestNode extends ASTNode {
  final String unitName;

  const DefinitionRequestNode(this.unitName);

  @override
  String toString() => 'DefinitionRequest($unitName)';
}
