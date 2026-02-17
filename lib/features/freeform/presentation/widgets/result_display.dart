import 'package:flutter/material.dart';

import '../../state/freeform_state.dart';

/// Displays the evaluation result with appropriate styling.
class ResultDisplay extends StatelessWidget {
  final EvaluationResult result;

  const ResultDisplay({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final (Widget child, Color borderColor) = switch (result) {
      EvaluationIdle() => (
        Text(
          'Enter an expression',
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 16,
          ),
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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(4),
      ),
      child: child,
    );
  }
}
