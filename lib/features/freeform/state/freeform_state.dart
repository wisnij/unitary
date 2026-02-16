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
  final String outputUnit;

  const ConversionSuccess({
    required this.convertedValue,
    required this.formattedResult,
    required this.outputUnit,
  });
}

/// Evaluation failed with an error message.
class EvaluationError extends EvaluationResult {
  final String message;

  const EvaluationError({required this.message});
}
