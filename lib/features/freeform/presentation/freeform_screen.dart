import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../settings/models/user_settings.dart';
import '../../settings/state/settings_provider.dart';
import '../state/freeform_provider.dart';
import 'widgets/result_display.dart';

/// Freeform expression evaluation screen.
class FreeformScreen extends ConsumerStatefulWidget {
  const FreeformScreen({super.key});

  @override
  ConsumerState<FreeformScreen> createState() => _FreeformScreenState();
}

class _FreeformScreenState extends ConsumerState<FreeformScreen> {
  final _inputController = TextEditingController();
  final _outputController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _inputController.dispose();
    _outputController.dispose();
    super.dispose();
  }

  void _onInputChanged(String _) {
    final settings = ref.read(settingsProvider);
    if (settings.evaluationMode == EvaluationMode.realtime) {
      _debounceEvaluate();
    }
  }

  void _onOutputChanged(String _) {
    final settings = ref.read(settingsProvider);
    if (settings.evaluationMode == EvaluationMode.realtime) {
      _debounceEvaluate();
    }
  }

  void _debounceEvaluate() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), _evaluate);
  }

  void _evaluate() {
    final input = _inputController.text;
    final output = _outputController.text;
    final notifier = ref.read(freeformProvider.notifier);

    if (input.trim().isEmpty) {
      notifier.clear();
      return;
    }

    if (output.trim().isEmpty) {
      notifier.evaluateSingle(input);
    } else {
      notifier.evaluateConversion(input, output);
    }
  }

  void _clear() {
    _inputController.clear();
    _outputController.clear();
    ref.read(freeformProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(freeformProvider);
    final settings = ref.watch(settingsProvider);
    final isOnSubmit = settings.evaluationMode == EvaluationMode.onSubmit;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _inputController,
            decoration: InputDecoration(
              labelText: 'Expression',
              hintText: '5 miles + 3 km',
              border: const OutlineInputBorder(),
              suffixIcon: _inputController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: _clear,
                    )
                  : null,
            ),
            onChanged: (value) {
              setState(() {}); // Rebuild to show/hide clear button.
              _onInputChanged(value);
            },
            onSubmitted: (_) => _evaluate(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _outputController,
            decoration: const InputDecoration(
              labelText: 'Convert to (optional)',
              hintText: 'feet',
              border: OutlineInputBorder(),
            ),
            onChanged: _onOutputChanged,
            onSubmitted: (_) => _evaluate(),
          ),
          const SizedBox(height: 24),
          ResultDisplay(result: result),
          if (isOnSubmit) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _evaluate,
              child: const Text('Evaluate'),
            ),
          ],
        ],
      ),
    );
  }
}
