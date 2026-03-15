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

/// Evaluation failed with an error message.
class EvaluationError extends EvaluationResult {
  final String message;

  const EvaluationError({required this.message});
}
