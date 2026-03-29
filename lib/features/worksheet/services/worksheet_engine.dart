import '../../../core/domain/errors.dart';
import '../../../core/domain/models/quantity.dart';
import '../../../core/domain/parser/ast.dart';
import '../../../core/domain/parser/expression_parser.dart';
import '../../../shared/utils/quantity_formatter.dart';
import '../../settings/models/user_settings.dart';
import '../models/worksheet.dart';

/// A single cell result from [computeWorksheet].
///
/// [text] is the string to display in the row's input field.
/// [isError] is true when [text] is an error label rather than a numeric value.
class WorksheetCellResult {
  final String text;
  final bool isError;

  const WorksheetCellResult({required this.text, required this.isError});

  /// Convenience constructor for a normal numeric value.
  const WorksheetCellResult.value(this.text) : isError = false;

  /// Convenience constructor for an error label.
  const WorksheetCellResult.error(this.text) : isError = true;

  @override
  bool operator ==(Object other) =>
      other is WorksheetCellResult &&
      other.text == text &&
      other.isError == isError;

  @override
  int get hashCode => Object.hash(text, isError);

  @override
  String toString() => 'WorksheetCellResult(text: $text, isError: $isError)';
}

/// Computes display values for all rows in a worksheet given a typed source value.
///
/// Returns a [WorksheetResult] with one entry per row.  The source row entry
/// is always `null` (the provider preserves the user's raw text there).
/// If the source value is not a valid number, or the base quantity cannot be
/// computed, all entries are `null` (clear the row).
WorksheetResult computeWorksheet({
  required List<WorksheetRow> rows,
  required int sourceIndex,
  required String sourceText,
  required ExpressionParser parser,
  required UserSettings settings,
}) {
  final sourceValue = double.tryParse(sourceText);
  if (sourceValue == null || sourceText.trim().isEmpty) {
    return WorksheetResult(List.filled(rows.length, null));
  }

  final Quantity base;
  try {
    base = _computeBase(parser, rows[sourceIndex], sourceValue);
  } on UnitaryException {
    return WorksheetResult(List.filled(rows.length, null));
  }

  final values = List<WorksheetCellResult?>.filled(rows.length, null);
  for (var i = 0; i < rows.length; i++) {
    if (i == sourceIndex) {
      continue; // provider preserves raw text
    }
    values[i] = _computeTargetResult(parser, rows[i], base, settings);
  }
  return WorksheetResult(values);
}

/// The result of [computeWorksheet]: one nullable [WorksheetCellResult] per row.
///
/// A `null` entry means "preserve / clear" — either it is the source row
/// (index left intentionally null) or input was invalid.
class WorksheetResult {
  final List<WorksheetCellResult?> values;
  const WorksheetResult(this.values);
}

/// Computes the base [Quantity] from the source row's typed value.
Quantity _computeBase(
  ExpressionParser parser,
  WorksheetRow row,
  double value,
) {
  return switch (row.kind) {
    UnitRow() => _unitRowBase(parser, row.expression, value),
    FunctionRow() => _funcRowBase(parser, row.expression, value),
  };
}

/// For a [UnitRow] source: `base = value × unitQty`.
Quantity _unitRowBase(
  ExpressionParser parser,
  String expression,
  double value,
) {
  final unitQty = parser.evaluate(expression);
  return Quantity(value * unitQty.value, unitQty.dimension);
}

/// For a [FunctionRow] source: `base = func.call([dimensionless(value)])`.
Quantity _funcRowBase(
  ExpressionParser parser,
  String functionName,
  double value,
) {
  final func = parser.repo?.findFunction(functionName);
  if (func == null) {
    throw EvalException('Unknown function: "$functionName"');
  }
  final context = EvalContext(repo: parser.repo, visited: parser.visited);
  return func.call([Quantity.dimensionless(value)], context);
}

/// Computes the [WorksheetCellResult] for a target row from a base [Quantity].
///
/// Returns an error result with a specific label on failure:
/// - `"wrong unit type"` — dimension mismatch
/// - `"out of bounds"` — value outside the function's domain
/// - `"no inverse"` — target [FunctionRow] has no inverse
/// - `"error"` — unexpected failure
WorksheetCellResult _computeTargetResult(
  ExpressionParser parser,
  WorksheetRow row,
  Quantity base,
  UserSettings settings,
) {
  try {
    final double displayValue = switch (row.kind) {
      UnitRow() => _unitRowTarget(parser, row.expression, base),
      FunctionRow() => _funcRowTarget(parser, row.expression, base),
    };
    return WorksheetCellResult.value(
      formatValue(
        displayValue,
        precision: settings.precision,
        notation: settings.notation,
      ),
    );
  } on DimensionException {
    return const WorksheetCellResult.error('wrong unit type');
  } on BoundsException {
    return const WorksheetCellResult.error('out of bounds');
  } on _NoInverseException {
    return const WorksheetCellResult.error('no inverse');
  } catch (_) {
    return const WorksheetCellResult.error('error');
  }
}

/// For a [UnitRow] target: `display = base.value / unitQty.value`.
double _unitRowTarget(
  ExpressionParser parser,
  String expression,
  Quantity base,
) {
  final unitQty = parser.evaluate(expression);
  if (!base.isConformableWith(unitQty)) {
    throw DimensionException(
      'Cannot convert ${base.dimension.canonicalRepresentation()} '
      'to ${unitQty.dimension.canonicalRepresentation()}',
    );
  }
  return base.value / unitQty.value;
}

/// For a [FunctionRow] target: `display = func.callInverse([base]).value`.
///
/// Returns the display value, or throws a named error:
/// - returns `"no inverse"` error result inline (no exception) when inverse is absent
double _funcRowTarget(
  ExpressionParser parser,
  String functionName,
  Quantity base,
) {
  final func = parser.repo?.findFunction(functionName);
  if (func == null) {
    throw EvalException('Unknown function: "$functionName"');
  }
  if (!func.hasInverse) {
    // Rethrow as a sentinel recognised by _computeTargetResult.
    throw _NoInverseException(functionName);
  }
  final context = EvalContext(repo: parser.repo, visited: parser.visited);
  final result = func.callInverse([base], context);
  return result.value;
}

/// Internal sentinel used to surface "no inverse" without exposing it as a
/// public API.  Caught exclusively in [_computeTargetResult].
class _NoInverseException implements Exception {
  final String functionName;
  const _NoInverseException(this.functionName);
}
