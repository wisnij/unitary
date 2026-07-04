import 'package:flutter/material.dart';

import '../../../../shared/utils/quantity_formatter.dart';
import '../../data/idle_examples.dart';
import '../../state/freeform_state.dart';

/// The spoken form of [result], used as the accessible label of the
/// live-region result display so a screen reader announces each settled
/// evaluation.
///
/// Labels are composed from each variant's display strings via [formatSpeech]
/// (structural symbols worded, exponents spoken), with multi-line variants
/// joined as sentences.  The switch is exhaustive over the sealed
/// [EvaluationResult] type so a new variant cannot ship without a spoken form.
String resultSpeechLabel(EvaluationResult result) {
  return switch (result) {
    EvaluationIdle(:final example) => _idleSpeech(example),
    EvaluationSuccess(:final formattedResult) => formatSpeech(formattedResult),
    ConversionSuccess(:final formattedResult, :final formattedReciprocal) =>
      '${formatSpeech(formattedResult)}. ${formatSpeech(formattedReciprocal)}',
    UnitDefinitionResult(
      :final aliasLine,
      :final definitionLine,
      :final formattedResult,
    ) =>
      [
        aliasLine,
        definitionLine,
        formattedResult,
      ].nonNulls.map(formatSpeech).join('. '),
    FunctionDefinitionResult(:final label, :final expression) => formatSpeech(
      '$label ${expression ?? 'not available'}',
    ),
    FunctionConversionResult(:final functionName, :final formattedValue) =>
      formatSpeech('$functionName($formattedValue)'),
    ReciprocalConversionSuccess(
      :final reciprocalInputLabel,
      :final formattedResult,
      :final formattedReciprocal,
    ) =>
      'Reciprocal conversion. ${formatSpeech(reciprocalInputLabel)}. '
          '${formatSpeech(formattedResult)}. '
          '${formatSpeech(formattedReciprocal)}',
    EvaluationError(:final message) => 'Error: $message',
  };
}

String _idleSpeech(FreeformExample? example) {
  const instruction = 'Enter an expression above.';
  if (example == null) {
    return instruction;
  }
  final hint = example.outputExpression != null
      ? '${example.inputExpression} to ${example.outputExpression}'
      : example.inputExpression;
  return '$instruction Try: ${formatSpeech(hint)}';
}

/// Displays the evaluation result with appropriate styling.
///
/// When [result] is [EvaluationIdle] and [onTap] is provided, the idle
/// display is tappable: tapping it invokes [onTap] (typically to fill the
/// input field with the example expression).
class ResultDisplay extends StatelessWidget {
  final EvaluationResult result;
  final VoidCallback? onTap;

  const ResultDisplay({super.key, required this.result, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final (Widget child, Color borderColor) = switch (result) {
      EvaluationIdle(:final example) => (
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter an expression above.',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 16,
              ),
            ),
            if (example != null) ...[
              const SizedBox(height: 4),
              Text(
                example.outputExpression != null
                    ? 'Try: ${example.inputExpression} → ${example.outputExpression}'
                    : 'Try: ${example.inputExpression}',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 16,
                ),
              ),
            ],
          ],
        ),
        colorScheme.outline,
      ),
      EvaluationSuccess(:final formattedResult) => (
        Text(
          formattedResult,
          style: TextStyle(
            color: colorScheme.primary,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        colorScheme.primary,
      ),
      ConversionSuccess(
        :final formattedResult,
        :final formattedReciprocal,
      ) =>
        (
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                formattedResult,
                style: TextStyle(
                  color: colorScheme.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                formattedReciprocal,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          colorScheme.primary,
        ),
      UnitDefinitionResult(
        :final aliasLine,
        :final definitionLine,
        :final formattedResult,
      ) =>
        (
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (aliasLine != null) ...[
                Text(
                  aliasLine,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
              ],
              if (definitionLine != null) ...[
                Text(
                  definitionLine,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
              ],
              Text(
                formattedResult,
                style: TextStyle(
                  color: colorScheme.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          colorScheme.primary,
        ),
      FunctionDefinitionResult(:final label, :final expression) => (
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              expression ?? '<not available>',
              style: TextStyle(
                color: colorScheme.primary,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        colorScheme.primary,
      ),
      FunctionConversionResult(:final functionName, :final formattedValue) => (
        Text(
          '$functionName($formattedValue)',
          style: TextStyle(
            color: colorScheme.primary,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        colorScheme.primary,
      ),
      ReciprocalConversionSuccess(
        :final reciprocalInputLabel,
        :final formattedResult,
        :final formattedReciprocal,
      ) =>
        (
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: colorScheme.tertiary,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'reciprocal conversion',
                    style: TextStyle(
                      color: colorScheme.tertiary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                reciprocalInputLabel,
                style: TextStyle(
                  color: colorScheme.primary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                formattedResult,
                style: TextStyle(
                  color: colorScheme.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                formattedReciprocal,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          colorScheme.primary,
        ),
      EvaluationError(:final message) => (
        Row(
          children: [
            Icon(Icons.error_outline, color: colorScheme.error),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: colorScheme.error, fontSize: 16),
              ),
            ),
          ],
        ),
        colorScheme.error,
      ),
    };

    final container = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(4),
      ),
      // The composed live-region label below carries the spoken form of the
      // whole result, so the individual text nodes are excluded to avoid
      // being read out a second time.
      child: ExcludeSemantics(child: child),
    );

    if (result is EvaluationIdle && onTap != null) {
      return Semantics(
        liveRegion: true,
        button: true,
        label: resultSpeechLabel(result),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(onTap: onTap, child: container),
        ),
      );
    }
    return Semantics(
      liveRegion: true,
      label: resultSpeechLabel(result),
      child: container,
    );
  }
}
