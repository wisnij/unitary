import '../../../core/domain/models/quantity.dart';

/// Represents the current state of freeform expression evaluation.
sealed class EvaluationResult {
  const EvaluationResult();
}

/// No input yet — show placeholder text.
class EvaluationIdle extends EvaluationResult {
  const EvaluationIdle();
}

/// Single expression evaluated successfully.
class EvaluationSuccess extends EvaluationResult {
  final Quantity result;
  final String formattedResult;

  const EvaluationSuccess({
    required this.result,
    required this.formattedResult,
  });
}

/// Two-expression conversion succeeded.
class ConversionSuccess extends EvaluationResult {
  final double convertedValue;
  final String formattedResult;
  final String formattedReciprocal;
  final String outputUnit;

  const ConversionSuccess({
    required this.convertedValue,
    required this.formattedResult,
    required this.formattedReciprocal,
    required this.outputUnit,
  });
}

/// Bare unit, prefix+unit, or prefix name in input field — shows a
/// multi-line definition block.
///
/// [aliasLine] is pre-formatted with a leading `"= "` and shows either the
/// canonical unit ID (when the input was an alias), or the decomposed
/// `"<prefix.id> <unit.id>"` form (for prefix+unit and bare prefix aliases).
/// It is `null` when the input was already the canonical ID.
///
/// [definitionLine] is pre-formatted with a leading `"= "` and shows the
/// unit's definition expression (for derived units).  It is `null` for
/// primitive units, prefix+unit matches, and bare prefixes.
///
/// [formattedResult] is pre-formatted with a leading `"= "` and shows the
/// fully-resolved quantity using the user's current precision and notation.
class UnitDefinitionResult extends EvaluationResult {
  final String? aliasLine;
  final String? definitionLine;
  final String formattedResult;

  const UnitDefinitionResult({
    required this.aliasLine,
    required this.definitionLine,
    required this.formattedResult,
  });
}

/// Bare function name (forward or `~inverse`) in input field — shows the
/// function's definition or inverse expression.
///
/// [label] is the pre-formatted display label, e.g. `"sin(x) ="` or
/// `"~tempF(x) ="`.  [expression] is the display string for the body, or
/// `null` when no expression is available.
class FunctionDefinitionResult extends EvaluationResult {
  final String label;
  final String? expression;

  const FunctionDefinitionResult({
    required this.label,
    required this.expression,
  });
}

/// Function-name output applied via inverse — shows `functionName(value)`.
///
/// [functionName] is the name of the function whose inverse was applied
/// (e.g. `"tempC"`).  [formattedValue] is the formatted numeric result
/// (e.g. `"20"`).  The display composes these as `"tempC(20)"`.
class FunctionConversionResult extends EvaluationResult {
  final String functionName;
  final String formattedValue;

  const FunctionConversionResult({
    required this.functionName,
    required this.formattedValue,
  });
}

/// Evaluation failed with an error message.
class EvaluationError extends EvaluationResult {
  final String message;

  const EvaluationError({required this.message});
}
