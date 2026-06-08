import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A single row in the worksheet UI.
///
/// Shows the row [label] and [expression] as display text, and a numeric
/// [TextField] for the value.  Calls [onChanged] on every keystroke and
/// [onFocused] when the field receives focus.
///
/// [labelColumnWidth] is the shared width used for the label column across all
/// rows in a worksheet.  Callers should compute a single value from the widest
/// label in the template (see [WorksheetScreen]) so that all input fields are
/// aligned.
class WorksheetRowWidget extends StatelessWidget {
  final String label;
  final String expression;
  final TextEditingController controller;
  final bool isActive;
  final bool isError;
  final ValueChanged<String> onChanged;
  final VoidCallback onFocused;
  final VoidCallback? onLabelLongPress;
  final double labelColumnWidth;

  const WorksheetRowWidget({
    super.key,
    required this.label,
    required this.expression,
    required this.controller,
    required this.isActive,
    required this.labelColumnWidth,
    this.isError = false,
    required this.onChanged,
    required this.onFocused,
    this.onLabelLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // Labels column: fixed shared width so all input fields are aligned.
          GestureDetector(
            onLongPress: onLabelLongPress,
            child: SizedBox(
              width: labelColumnWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    expression,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Input field: fills remaining space.
          Expanded(
            child: GestureDetector(
              onLongPress: () {
                final text = controller.text;
                if (text.isEmpty) {
                  return;
                }
                Clipboard.setData(ClipboardData(text: text));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Copied $text'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              child: Focus(
                onFocusChange: (focused) {
                  if (focused) {
                    onFocused();
                  }
                },
                child: TextField(
                  controller: controller,
                  style: isError
                      ? TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        )
                      : null,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^-?[0-9]*\.?[0-9]*(?:[eE][+-]?[0-9]*)?$'),
                    ),
                  ],
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    fillColor: isActive
                        ? Theme.of(
                            context,
                          ).colorScheme.primaryContainer.withValues(alpha: 0.3)
                        : null,
                    filled: isActive,
                  ),
                  onChanged: onChanged,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
