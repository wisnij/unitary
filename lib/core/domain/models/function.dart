import '../errors.dart';
import 'dimension.dart';
import 'quantity.dart';

/// A bound (lower or upper limit) on a quantity's value.
class Bound {
  /// The bound value.
  final double value;

  /// Whether this bound is inclusive (≤/≥). False means exclusive (</>).
  final bool closed;

  const Bound(this.value, {required this.closed});
}

/// Constraint specification for a function argument or return value.
class QuantitySpec {
  /// Required dimension; null means any dimension is accepted.
  final Dimension? dimension;

  /// Lower bound on the value; null means no lower bound.
  final Bound? min;

  /// Upper bound on the value; null means no upper bound.
  final Bound? max;

  /// If true, a pure dimensionless argument (empty dimension map) is also
  /// accepted when [dimension] is non-null.  Used for dimensionless primitives
  /// like radian, so that sin(0) is accepted in addition to sin(π/2 rad).
  final bool acceptDimensionless;

  QuantitySpec({
    this.dimension,
    this.min,
    this.max,
    this.acceptDimensionless = false,
  });
}

/// Abstract base class for all named callable identifiers.
///
/// Subclasses implement [evaluate] and optionally [evaluateInverse].
/// [call] wraps [evaluate] with argument count and spec validation.
abstract class UnitaryFunction {
  /// Primary registration name.
  final String id;

  /// Alternative names (may be empty).
  final List<String> aliases;

  /// Required number of arguments.
  final int arity;

  /// Optional per-argument constraint specs; one entry per argument position.
  /// Null means no constraints on any argument.
  final List<QuantitySpec>? domain;

  /// Optional constraint on the return value; null means no constraints.
  final QuantitySpec? range;

  UnitaryFunction({
    required this.id,
    List<String>? aliases,
    required this.arity,
    this.domain,
    this.range,
  }) : aliases = aliases ?? const [];

  /// All recognized names for this function: [id] + [aliases].
  List<String> get allNames => [id, ...aliases];

  /// Whether this function supports inverse evaluation via [callInverse].
  bool get hasInverse;

  /// Validates args against [domain], evaluates, validates result against [range].
  ///
  /// Throws [EvalException] on argument count mismatch or bound violation.
  /// Throws [DimensionException] on dimension mismatch.
  Quantity call(List<Quantity> args) {
    if (args.length != arity) {
      throw EvalException(
        "Function '$id' expects $arity argument(s), got ${args.length}",
      );
    }
    if (domain != null) {
      for (var i = 0; i < domain!.length && i < args.length; i++) {
        _validateSpec(args[i], domain![i]);
      }
    }
    final result = evaluate(args);
    if (range != null) {
      _validateSpec(result, range!);
    }
    return result;
  }

  /// Validates args, then delegates to [evaluateInverse].
  ///
  /// Throws [EvalException] if [hasInverse] is false.
  Quantity callInverse(List<Quantity> args) {
    if (!hasInverse) {
      throw EvalException('No inverse defined for "$id"');
    }
    if (args.length != arity) {
      throw EvalException(
        "Function '$id' expects $arity argument(s), got ${args.length}",
      );
    }
    return evaluateInverse(args);
  }

  /// Subclass-implemented forward evaluation logic.
  Quantity evaluate(List<Quantity> args);

  /// Subclass-implemented inverse evaluation logic.
  ///
  /// The default implementation throws [EvalException], ensuring subclasses
  /// that set [hasInverse] to true must override this method.
  Quantity evaluateInverse(List<Quantity> args) {
    throw EvalException('No inverse defined for "$id"');
  }

  void _validateSpec(Quantity q, QuantitySpec spec) {
    if (spec.dimension != null) {
      final matches = q.dimension == spec.dimension;
      final dimensionlessFallback =
          spec.acceptDimensionless && q.isDimensionless;
      if (!matches && !dimensionlessFallback) {
        throw DimensionException(
          "Function '$id': argument requires dimension "
          '${spec.dimension!.canonicalRepresentation()}, '
          'got ${q.dimension.canonicalRepresentation()}',
        );
      }
    }
    if (spec.min != null) {
      final min = spec.min!;
      final violated = min.closed ? q.value < min.value : q.value <= min.value;
      if (violated) {
        final op = min.closed ? '>=' : '>';
        throw EvalException(
          "Function '$id': argument must be $op ${min.value}, got ${q.value}",
        );
      }
    }
    if (spec.max != null) {
      final max = spec.max!;
      final violated = max.closed ? q.value > max.value : q.value >= max.value;
      if (violated) {
        final op = max.closed ? '<=' : '<';
        throw EvalException(
          "Function '$id': argument must be $op ${max.value}, got ${q.value}",
        );
      }
    }
  }
}

/// Concrete subclass for built-in mathematical functions.
///
/// Each instance wraps a Dart function [_impl] that computes the result.
/// [hasInverse] is always false; builtin functions do not support inverse
/// evaluation.
class BuiltinFunction extends UnitaryFunction {
  final Quantity Function(List<Quantity>) _impl;

  BuiltinFunction({
    required super.id,
    super.aliases,
    required super.arity,
    super.domain,
    super.range,
    required Quantity Function(List<Quantity>) impl,
  }) : _impl = impl;

  @override
  bool get hasInverse => false;

  @override
  Quantity evaluate(List<Quantity> args) => _impl(args);
}
