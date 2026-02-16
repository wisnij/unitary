import 'dart:math' as math;

import '../errors.dart';
import '../models/dimension.dart';
import '../models/quantity.dart';
import '../models/unit.dart';
import '../models/unit_repository.dart';
import '../services/unit_resolver.dart';
import 'token.dart';

/// Evaluation context passed to AST nodes during evaluation.
class EvalContext {
  /// Unit repository for resolving unit names.  Null means Phase 1
  /// behavior (all identifiers treated as raw dimensions).
  final UnitRepository? repo;

  const EvalContext({this.repo});
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
/// resolved to its base-unit representation.  Otherwise, or if the unit
/// is not found in the repository, it falls back to a raw dimension.
class UnitNode extends ASTNode {
  final String unitName;

  const UnitNode(this.unitName);

  @override
  Quantity evaluate(EvalContext context) {
    final repo = context.repo;
    if (repo == null) {
      // No repo: Phase 1 behavior (raw dimension).
      return Quantity(1.0, Dimension({unitName: 1}));
    }

    final result = repo.findUnitWithPrefix(unitName);
    if (result.unit == null) {
      // Unknown unit: fall back to raw dimension.
      return Quantity(1.0, Dimension({unitName: 1}));
    }

    // Resolve to base units: 1 <unit> = quantity in primitives.
    final unitQuantity = resolveUnit(result.unit!, repo);
    if (result.prefix != null) {
      final prefixQuantity = resolveUnit(result.prefix!, repo);
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
class FunctionNode extends ASTNode {
  final String name;
  final List<ASTNode> arguments;

  const FunctionNode(this.name, this.arguments);

  @override
  Quantity evaluate(EvalContext context) {
    final args = arguments.map((a) => a.evaluate(context)).toList();
    return _evaluateBuiltin(name, args);
  }

  @override
  String toString() => 'Function($name, $arguments)';
}

/// An affine unit application (e.g., tempF(60)).
///
/// Stub for Phase 1; evaluation requires unit definitions.
class AffineUnitNode extends ASTNode {
  final String unitName;
  final ASTNode argument;

  const AffineUnitNode(this.unitName, this.argument);

  @override
  Quantity evaluate(EvalContext context) {
    final argValue = argument.evaluate(context);

    if (!argValue.isDimensionless) {
      throw DimensionException(
        "Affine unit '$unitName' requires a dimensionless argument, got "
        '${argValue.dimension.canonicalRepresentation()}',
      );
    }

    final repo = context.repo;
    if (repo == null) {
      throw EvalException(
        "Cannot evaluate affine unit '$unitName' without a unit repository",
      );
    }

    final unit = repo.getUnit(unitName) as AffineUnit;
    final baseUnit = repo.getUnit(unit.baseUnitId);
    final baseQuantity = resolveUnit(baseUnit, repo);
    final kelvin = (argValue.value + unit.offset) * unit.factor;
    return Quantity(kelvin * baseQuantity.value, baseQuantity.dimension);
  }

  @override
  String toString() => 'AffineUnit($unitName, $argument)';
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

// -- Built-in function evaluation --

/// Set of recognized built-in function names.
const _builtinFunctions = {
  'sin',
  'cos',
  'tan',
  'asin',
  'acos',
  'atan',
  'sqrt',
  'cbrt',
  'ln',
  'log',
  'exp',
  'abs',
};

/// Returns true if [name] is a recognized built-in function.
bool isBuiltinFunction(String name) => _builtinFunctions.contains(name);

Quantity _evaluateBuiltin(String name, List<Quantity> args) {
  switch (name) {
    case 'sin':
      _requireArgCount(name, args, 1);
      _requireDimensionless(name, args[0]);
      return Quantity.dimensionless(math.sin(args[0].value));
    case 'cos':
      _requireArgCount(name, args, 1);
      _requireDimensionless(name, args[0]);
      return Quantity.dimensionless(math.cos(args[0].value));
    case 'tan':
      _requireArgCount(name, args, 1);
      _requireDimensionless(name, args[0]);
      return Quantity.dimensionless(math.tan(args[0].value));
    case 'asin':
      _requireArgCount(name, args, 1);
      _requireDimensionless(name, args[0]);
      if (args[0].value < -1 || args[0].value > 1) {
        throw EvalException(
          'asin requires argument in range [-1, 1], got ${args[0].value}',
        );
      }
      return Quantity.dimensionless(math.asin(args[0].value));
    case 'acos':
      _requireArgCount(name, args, 1);
      _requireDimensionless(name, args[0]);
      if (args[0].value < -1 || args[0].value > 1) {
        throw EvalException(
          'acos requires argument in range [-1, 1], got ${args[0].value}',
        );
      }
      return Quantity.dimensionless(math.acos(args[0].value));
    case 'atan':
      _requireArgCount(name, args, 1);
      _requireDimensionless(name, args[0]);
      return Quantity.dimensionless(math.atan(args[0].value));
    case 'sqrt':
      _requireArgCount(name, args, 1);
      return args[0].power(0.5);
    case 'cbrt':
      _requireArgCount(name, args, 1);
      return args[0].power(1.0 / 3.0);
    case 'ln' || 'log':
      _requireArgCount(name, args, 1);
      _requireDimensionless(name, args[0]);
      if (args[0].value <= 0) {
        throw EvalException(
          '$name requires positive argument, got ${args[0].value}',
        );
      }
      return Quantity.dimensionless(math.log(args[0].value));
    case 'exp':
      _requireArgCount(name, args, 1);
      _requireDimensionless(name, args[0]);
      return Quantity.dimensionless(math.exp(args[0].value));
    case 'abs':
      _requireArgCount(name, args, 1);
      return args[0].abs();
    default:
      throw EvalException("Unknown function: '$name'");
  }
}

void _requireArgCount(String name, List<Quantity> args, int expected) {
  if (args.length != expected) {
    throw EvalException(
      "Function '$name' expects $expected argument(s), got ${args.length}",
    );
  }
}

void _requireDimensionless(String name, Quantity arg) {
  if (!arg.isDimensionless) {
    throw DimensionException(
      "Function '$name' requires dimensionless argument, got "
      '${arg.dimension.canonicalRepresentation()}',
    );
  }
}
