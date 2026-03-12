import '../errors.dart';
import '../models/dimension.dart';
import '../models/quantity.dart';
import '../models/unit_repository.dart';
import '../services/unit_resolver.dart';
import 'token.dart';

/// Evaluation context passed to AST nodes during evaluation.
class EvalContext {
  /// Unit repository for resolving unit names.  Null means Phase 1
  /// behavior (all identifiers treated as raw dimensions).
  final UnitRepository? repo;

  /// Set of unit IDs currently being resolved (the active resolution stack).
  /// Used to detect circular unit definitions.
  final Set<String> visited;

  /// Optional variable bindings that shadow unit lookups.  When non-null,
  /// an identifier found in this map is returned directly as a [Quantity]
  /// without consulting the repository.
  final Map<String, Quantity>? variables;

  const EvalContext({
    this.repo,
    this.visited = const <String>{},
    this.variables,
  });
}

/// Base class for all AST nodes.
abstract class ASTNode {
  const ASTNode();

  /// Evaluate this node and return a [Quantity].
  Quantity evaluate(EvalContext context);
}

/// A numeric literal.
class NumberNode extends ASTNode {
  final double value;

  const NumberNode(this.value);

  @override
  Quantity evaluate(EvalContext context) => Quantity.dimensionless(value);

  @override
  String toString() => 'NumberNode($value)';
}

/// A unit identifier.
///
/// When the evaluation context has a unit repository, the unit name is
/// resolved to its base-unit representation.  If the unit is not found
/// in the repository, an [EvalException] is thrown.  If no repository
/// is provided (Phase 1 / parser-isolation mode), identifiers fall back
/// to raw dimensions.
class UnitNode extends ASTNode {
  final String unitName;

  const UnitNode(this.unitName);

  @override
  Quantity evaluate(EvalContext context) {
    // Variables shadow unit/repo lookups.
    if (context.variables != null && context.variables!.containsKey(unitName)) {
      return context.variables![unitName]!;
    }

    final repo = context.repo;
    if (repo == null) {
      // No repo: Phase 1 behavior (raw dimension).
      return Quantity(1.0, Dimension({unitName: 1}));
    }

    final result = repo.findUnitWithPrefix(unitName);
    if (result.unit == null) {
      throw EvalException('Unknown unit: "$unitName"');
    }

    // Resolve to base units: 1 <unit> = quantity in primitives.
    final unitQuantity = resolveUnit(result.unit!, repo, context.visited);
    if (result.prefix != null) {
      final prefixQuantity = resolveUnit(result.prefix!, repo, context.visited);
      return prefixQuantity.multiply(unitQuantity);
    }
    return unitQuantity;
  }

  @override
  String toString() => 'UnitNode($unitName)';
}

/// A binary operation (e.g., +, -, *, /, ^).
class BinaryOpNode extends ASTNode {
  final ASTNode left;
  final ASTNode right;
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
class UnaryOpNode extends ASTNode {
  final TokenType operator;
  final ASTNode operand;

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

/// A function call (e.g., sin(x), sqrt(x)).
///
/// When [inverse] is true, the call is dispatched to [UnitaryFunction.callInverse]
/// instead of [UnitaryFunction.call], implementing the `~` operator.
class FunctionNode extends ASTNode {
  final String name;
  final List<ASTNode> arguments;
  final bool inverse;

  const FunctionNode(this.name, this.arguments, {this.inverse = false});

  @override
  Quantity evaluate(EvalContext context) {
    final repo = context.repo;
    if (repo == null) {
      throw EvalException(
        "No repository; cannot call function '$name'",
      );
    }
    final func = repo.findFunction(name);
    if (func == null) {
      throw EvalException("Unknown function: '$name'");
    }
    final args = arguments.map((a) => a.evaluate(context)).toList();
    return inverse ? func.callInverse(args, context) : func.call(args, context);
  }

  @override
  String toString() => 'Function($name, $arguments, inverse: $inverse)';
}

/// A standalone unit identifier used as a definition request.
///
/// Stub for Phase 1; requires unit definitions.
class DefinitionRequestNode extends ASTNode {
  final String unitName;

  const DefinitionRequestNode(this.unitName);

  @override
  Quantity evaluate(EvalContext context) {
    throw UnimplementedError(
      'DefinitionRequestNode evaluation requires unit definitions (Phase 2)',
    );
  }

  @override
  String toString() => 'DefinitionRequest($unitName)';
}

/// A standalone function name used as a definition request.
///
/// Stub for Phase 1; requires function registry.
class FunctionDefinitionRequestNode extends ASTNode {
  final String functionName;

  const FunctionDefinitionRequestNode(this.functionName);

  @override
  Quantity evaluate(EvalContext context) {
    throw UnimplementedError(
      'FunctionDefinitionRequestNode evaluation not yet implemented',
    );
  }

  @override
  String toString() => 'FunctionDefinitionRequest($functionName)';
}
