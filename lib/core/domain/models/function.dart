import '../errors.dart';
import '../parser/ast.dart';
import '../parser/expression_parser.dart';
import '../utils.dart';
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
  /// Reference quantity defining the expected unit; null means any unit is
  /// accepted.  Only the dimension is used for validation; the value is
  /// available to callers that need the SI conversion factor (e.g. for
  /// [PiecewiseFunction] output unit resolution).
  final Quantity? quantity;

  /// Lower bound on the value; null means no lower bound.
  final Bound? min;

  /// Upper bound on the value; null means no upper bound.
  final Bound? max;

  /// If true, a pure dimensionless argument (empty dimension map) is also
  /// accepted when [quantity] is non-null.  Used for dimensionless primitives
  /// like radian, so that sin(0) is accepted in addition to sin(π/2 rad).
  final bool acceptDimensionless;

  const QuantitySpec({
    this.quantity,
    this.min,
    this.max,
    this.acceptDimensionless = false,
  });

  /// Returns true if [value] satisfies both the [min] and [max] bounds.
  bool isWithinBounds(double value) {
    if (min != null) {
      if (min!.closed ? value < min!.value : value <= min!.value) {
        return false;
      }
    }
    if (max != null) {
      if (max!.closed ? value > max!.value : value >= max!.value) {
        return false;
      }
    }
    return true;
  }

  /// Returns the domain/range interval in mathematical notation.
  ///
  /// Square brackets denote closed bounds; parentheses denote open or absent
  /// bounds.  Examples: `[0,)`, `(-1,1]`, `(,)`.
  String boundsString() {
    String fmt(double v) => stripTrailingZeros(v.toString());
    final String lower;
    if (min == null) {
      lower = '(';
    } else {
      lower = min!.closed ? '[${fmt(min!.value)}' : '(${fmt(min!.value)}';
    }
    final String upper;
    if (max == null) {
      upper = ')';
    } else {
      upper = max!.closed ? '${fmt(max!.value)}]' : '${fmt(max!.value)})';
    }
    return '$lower,$upper';
  }
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

  /// Formal parameter names, used for display (e.g. `['x']` for single-arg
  /// functions).  `DefinedFunction` returns its actual parameter names;
  /// other subclasses return generic names based on [arity].
  List<String> get params;

  /// Presentation label for the forward definition, shown as-is in the UI.
  /// Not guaranteed to be a parseable expression — may be a descriptive
  /// string such as `"<built-in function sin>"` or `"piecewise linear function"`.
  String? get definitionDisplay;

  /// Presentation label for the inverse definition, shown as-is in the UI.
  /// Returns `null` only when the inverse is not representable as a display
  /// string (e.g. [PiecewiseFunction] may use this). Implementations that have
  /// no inverse should return `'no inverse defined'`.
  String? get inverseDisplay;

  /// Validates args against [domain], evaluates, validates result against [range].
  ///
  /// The optional [context] parameter is passed through to [evaluate] for
  /// subclasses (e.g. [DefinedFunction]) that require an evaluation context.
  /// [BuiltinFunction] and [PiecewiseFunction] accept and ignore it.
  ///
  /// Throws [EvalException] on argument count mismatch or bound violation.
  /// Throws [DimensionException] on dimension mismatch.
  Quantity call(List<Quantity> args, [EvalContext? context]) {
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
    final result = evaluate(args, context);
    if (range != null) {
      _validateSpec(result, range!);
    }
    return result;
  }

  /// Validates args against [range], evaluates inverse, validates result
  /// against [domain].
  ///
  /// Inverse functions always take exactly one argument (a value in the
  /// forward function's range).
  ///
  /// The optional [context] parameter is passed through to [evaluateInverse]
  /// for subclasses that require an evaluation context.
  ///
  /// Throws [EvalException] if [hasInverse] is false.
  /// Throws [EvalException] on argument count mismatch or bound violation.
  /// Throws [DimensionException] on dimension mismatch.
  Quantity callInverse(List<Quantity> args, [EvalContext? context]) {
    if (!hasInverse) {
      throw EvalException('No inverse defined for "$id"');
    }
    if (args.length != 1) {
      throw EvalException(
        "Function '$id' inverse expects 1 argument, got ${args.length}",
      );
    }
    if (range != null) {
      _validateSpec(args[0], range!);
    }
    final result = evaluateInverse(args, context);
    if (domain != null && domain!.isNotEmpty) {
      _validateSpec(result, domain![0]);
    }
    return result;
  }

  /// Subclass-implemented forward evaluation logic.
  Quantity evaluate(List<Quantity> args, [EvalContext? context]);

  /// Subclass-implemented inverse evaluation logic.
  ///
  /// The default implementation throws [EvalException], ensuring subclasses
  /// that set [hasInverse] to true must override this method.
  Quantity evaluateInverse(List<Quantity> args, [EvalContext? context]) {
    throw EvalException('No inverse defined for "$id"');
  }

  void _validateSpec(Quantity q, QuantitySpec spec) {
    if (spec.quantity != null) {
      final matches = q.dimension == spec.quantity!.dimension;
      final dimensionlessFallback =
          spec.acceptDimensionless && q.isDimensionless;
      if (!matches && !dimensionlessFallback) {
        throw DimensionException(
          "Function '$id': argument requires dimension "
          '${spec.quantity!.dimension.canonicalRepresentation()}, '
          'got ${q.dimension.canonicalRepresentation()}',
        );
      }
    }
    // When the spec has a reference quantity, normalize the value into that
    // unit's space before comparing bounds (e.g. raw y table values).
    final qNorm = spec.quantity != null
        ? q.value / spec.quantity!.value
        : q.value;
    if (!spec.isWithinBounds(qNorm)) {
      throw EvalException(
        "Function '$id': value must be within ${spec.boundsString()}, got $qNorm",
      );
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
  final List<String>? _params;

  BuiltinFunction({
    required super.id,
    super.aliases,
    required super.arity,
    super.domain,
    super.range,
    List<String>? params,
    required Quantity Function(List<Quantity>) impl,
  }) : _params = params,
       _impl = impl;

  @override
  bool get hasInverse => false;

  @override
  List<String> get params => _params ?? _genericParams(arity);

  @override
  String? get definitionDisplay => '<built-in function $id>';

  @override
  String? get inverseDisplay => 'no inverse defined';

  @override
  Quantity evaluate(List<Quantity> args, [EvalContext? context]) => _impl(args);

  static List<String> _genericParams(int arity) {
    const letters = ['x', 'y', 'z'];
    return arity <= letters.length
        ? letters.sublist(0, arity)
        : List.generate(arity, (i) => 'x${i + 1}');
  }
}

/// A piecewise-linear function defined by a fixed set of (x, y) control points.
///
/// Forward evaluation: linearly interpolates between adjacent control points
/// for an input in [points.first.$1, points.last.$1].
///
/// Inverse evaluation: scans segments in order and returns x from the first
/// segment whose y range contains the input.  Because segments are ordered by
/// increasing x, this always yields the smallest matching x for non-monotonic
/// functions.  An early bounds check using the range min/max avoids scanning
/// all segments for clearly out-of-range inputs.
class PiecewiseFunction extends UnitaryFunction {
  /// Control points in ascending x order.  Each record is (x, y), where y is
  /// expressed in terms of the output unit (i.e. in the same units as
  /// [UnitaryFunction.range]'s quantity).
  final List<(double, double)> points;

  /// Stored for fidelity to the GNU Units source; has no behavioral effect.
  final bool noerror;

  /// [outputUnit] encodes the SI conversion factor and dimension of the output.
  /// Domain and range specs (including x/y bounds) are derived from [points]
  /// and [outputUnit] by [_makeDomain] and [_makeRange].
  PiecewiseFunction({
    required super.id,
    super.aliases,
    required this.points,
    required this.noerror,
    required Quantity outputUnit,
  }) : super(
         arity: 1,
         domain: _makeDomain(points),
         range: _makeRange(points, outputUnit),
       );

  static List<QuantitySpec> _makeDomain(List<(double, double)> points) {
    if (points.isEmpty) {
      throw ArgumentError.value(points, 'points', 'must not be empty');
    }
    return [
      QuantitySpec(
        quantity: Quantity.unity,
        min: Bound(points.first.$1, closed: true),
        max: Bound(points.last.$1, closed: true),
      ),
    ];
  }

  static QuantitySpec _makeRange(
    List<(double, double)> points,
    Quantity outputUnit,
  ) {
    var yMin = double.infinity;
    var yMax = double.negativeInfinity;
    for (final (_, y) in points) {
      if (y < yMin) {
        yMin = y;
      }
      if (y > yMax) {
        yMax = y;
      }
    }
    return QuantitySpec(
      quantity: outputUnit,
      min: Bound(yMin, closed: true),
      max: Bound(yMax, closed: true),
    );
  }

  @override
  bool get hasInverse => true;

  @override
  List<String> get params => const ['x']; // PiecewiseFunction is always arity 1

  @override
  String? get definitionDisplay => 'piecewise linear function';

  @override
  String? get inverseDisplay => 'piecewise linear function';

  @override
  Quantity evaluate(List<Quantity> args, [EvalContext? context]) {
    // Binary search for the enclosing segment.
    final x = args[0].value;
    var lo = 0;
    var hi = points.length - 2;
    while (lo < hi) {
      final mid = (lo + hi) ~/ 2;
      if (points[mid + 1].$1 < x) {
        lo = mid + 1;
      } else {
        hi = mid;
      }
    }
    final (x0, y0) = points[lo];
    final (x1, y1) = points[lo + 1];
    final t = x1 == x0 ? 0.0 : (x - x0) / (x1 - x0);
    final y = y0 + t * (y1 - y0);
    final unit = range!.quantity!;
    return Quantity(y * unit.value, unit.dimension);
  }

  @override
  Quantity evaluateInverse(List<Quantity> args, [EvalContext? context]) {
    final unit = range!.quantity!;
    final yRaw = args[0].value / unit.value;
    // Segments are ordered by increasing x, so the first segment containing
    // yRaw always yields the smallest matching x.
    for (var i = 0; i < points.length - 1; i++) {
      final (x0, y0) = points[i];
      final (x1, y1) = points[i + 1];
      final segMin = y0 < y1 ? y0 : y1;
      final segMax = y0 > y1 ? y0 : y1;
      if (yRaw < segMin || yRaw > segMax) {
        continue;
      }
      final dy = y1 - y0;
      final x = dy == 0.0 ? x0 : x0 + (yRaw - y0) / dy * (x1 - x0);
      return Quantity.dimensionless(x);
    }
    throw EvalException(
      "Function '$id': no segment contains inverse value $yRaw",
    );
  }
}

/// A user-defined function expressed as a forward expression string and an
/// optional inverse expression string.
///
/// The [params] list names the formal parameters.  When [call] is invoked,
/// each parameter is bound to the corresponding argument and the [forward]
/// expression is evaluated in that environment via [ExpressionParser].
///
/// The [inverse] expression (if non-null) is evaluated with the function's
/// primary id bound to the single argument.  Multi-parameter functions may
/// not have an inverse.
class DefinedFunction extends UnitaryFunction {
  /// Formal parameter names.
  @override
  final List<String> params;

  /// Expression string for the forward evaluation.
  final String forward;

  /// Expression string for the inverse evaluation; null if no inverse.
  final String? inverse;

  /// Whether the GNU Units `noerror` flag was present (stored for fidelity).
  final bool noerror;

  DefinedFunction({
    required super.id,
    super.aliases,
    required this.params,
    required this.forward,
    this.inverse,
    this.noerror = false,
    super.domain,
    super.range,
  }) : super(arity: params.length) {
    if (params.length > 1 && inverse != null) {
      throw ArgumentError(
        "DefinedFunction '$id': inverse is not supported for multi-parameter functions",
      );
    }
  }

  @override
  bool get hasInverse => inverse != null;

  @override
  String? get definitionDisplay => forward;

  @override
  String? get inverseDisplay => inverse ?? 'no inverse defined';

  @override
  Quantity evaluate(List<Quantity> args, [EvalContext? context]) {
    if (context == null) {
      throw EvalException(
        'DefinedFunction "$id" requires an EvalContext',
      );
    }

    final funcKey = '$id()';
    if (context.visited.contains(funcKey)) {
      throw EvalException(
        'Circular function definition detected for "$id"',
      );
    }

    final extendedVisited = {...context.visited, funcKey};
    final vars = <String, Quantity>{};
    for (var i = 0; i < params.length; i++) {
      vars[params[i]] = args[i];
    }

    return ExpressionParser(
      repo: context.repo,
      variables: vars,
      visited: extendedVisited,
    ).evaluate(forward);
  }

  @override
  Quantity evaluateInverse(List<Quantity> args, [EvalContext? context]) {
    if (context == null) {
      throw EvalException(
        'DefinedFunction "$id" requires an EvalContext',
      );
    }

    final funcKey = '$id()';
    if (context.visited.contains(funcKey)) {
      throw EvalException(
        'Circular function definition detected for "$id"',
      );
    }

    final extendedVisited = {...context.visited, funcKey};
    final vars = <String, Quantity>{id: args[0]};

    return ExpressionParser(
      repo: context.repo,
      variables: vars,
      visited: extendedVisited,
    ).evaluate(inverse!);
  }
}
