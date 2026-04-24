import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/domain/errors.dart';
import '../../../core/domain/models/quantity.dart';
import '../../../core/domain/models/unit_repository.dart';
import '../../../shared/top_level_page.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../settings/models/user_settings.dart';
import '../../settings/state/settings_provider.dart';
import '../state/freeform_provider.dart';
import '../state/freeform_state.dart';
import '../state/parser_provider.dart';
import 'widgets/result_display.dart';

/// Freeform expression evaluation screen.
///
/// Owns its own [Scaffold] and [AppBar].  Navigation to other top-level pages
/// is delegated to [onNavigate], which is called by [AppDrawer] when the user
/// taps a navigation tile.
class FreeformScreen extends ConsumerStatefulWidget {
  const FreeformScreen({super.key, required this.onNavigate});

  /// Called when the user navigates to another top-level page via the drawer.
  final void Function(TopLevelPage) onNavigate;

  @override
  ConsumerState<FreeformScreen> createState() => _FreeformScreenState();
}

class _FreeformScreenState extends ConsumerState<FreeformScreen> {
  final _inputController = TextEditingController();
  final _outputController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    final (:input, :output) = ref.read(freeformRepositoryProvider).load();
    _inputController.text = input;
    _outputController.text = output;
    if (input.trim().isNotEmpty) {
      // Defer evaluation to post-frame: Riverpod blocks provider mutations
      // during the widget-tree build phase (which includes initState).
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _evaluate();
        }
      });
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _inputController.dispose();
    _outputController.dispose();
    super.dispose();
  }

  void _onInputChanged(String _) {
    setState(() {}); // Rebuild to update clear button and swap button states.
    _saveToRepository();
    final settings = ref.read(settingsProvider);
    if (settings.evaluationMode == EvaluationMode.realtime) {
      _debounceEvaluate();
    }
  }

  void _onOutputChanged(String _) {
    setState(() {}); // Rebuild to update swap button enabled state.
    _saveToRepository();
    final settings = ref.read(settingsProvider);
    if (settings.evaluationMode == EvaluationMode.realtime) {
      _debounceEvaluate();
    }
  }

  void _saveToRepository() {
    ref
        .read(freeformRepositoryProvider)
        .save(
          _inputController.text,
          _outputController.text,
        );
  }

  void _swap() {
    final inputText = _inputController.text;
    _inputController.text = _outputController.text;
    _outputController.text = inputText;
    _cancelDebounce();
    _evaluate();
  }

  void _cancelDebounce() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
  }

  void _debounceEvaluate() {
    _cancelDebounce();
    _debounceTimer = Timer(const Duration(milliseconds: 500), _evaluate);
  }

  void _evaluate() {
    final input = _inputController.text;
    final output = _outputController.text;
    ref.read(freeformProvider.notifier).evaluate(input, output);
  }

  void _clear() {
    _inputController.clear();
    _outputController.clear();
    ref.read(freeformProvider.notifier).clear();
  }

  void _showConformableModal(BuildContext context) {
    final parser = ref.read(parserProvider);

    final Quantity inputQty;
    try {
      inputQty = parser.evaluate(_inputController.text.trim());
    } on UnitaryException {
      return;
    }

    final stopwatch = kDebugMode ? (Stopwatch()..start()) : null;
    final entries = parser.repo.findConformable(inputQty.dimension);
    if (kDebugMode) {
      stopwatch!.stop();
      debugPrint(
        'findConformable took ${stopwatch.elapsedMilliseconds}ms '
        '(${entries.length} entries)',
      );
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ConformableUnitsModal(
        entries: entries,
        onSelect: (name) {
          Navigator.of(context).pop();
          _fillOutputField(name);
        },
      ),
    );
  }

  void _fillOutputField(String name) {
    _outputController.text = name;
    _cancelDebounce();
    _evaluate();
  }

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(freeformProvider);
    final settings = ref.watch(settingsProvider);
    final isOnSubmit = settings.evaluationMode == EvaluationMode.onSubmit;
    final canSwap =
        _inputController.text.isNotEmpty && _outputController.text.isNotEmpty;
    final browseEnabled = conformableBrowseEnabled(result);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Unitary'),
        actions: [
          IconButton(
            icon: const Icon(Icons.balance),
            tooltip: 'Browse conformable units',
            onPressed: browseEnabled
                ? () => _showConformableModal(context)
                : null,
          ),
        ],
      ),
      drawer: AppDrawer(
        currentPage: TopLevelPage.freeform,
        onNavigate: widget.onNavigate,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _inputController,
              decoration: InputDecoration(
                labelText: 'Convert from',
                border: const OutlineInputBorder(),
                suffixIcon: _inputController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clear,
                      )
                    : null,
              ),
              onChanged: _onInputChanged,
              onSubmitted: (_) => _evaluate(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.swap_vert),
                  onPressed: canSwap ? _swap : null,
                ),
              ],
            ),
            TextField(
              controller: _outputController,
              decoration: const InputDecoration(
                labelText: 'Convert to (optional)',
                border: OutlineInputBorder(),
              ),
              onChanged: _onOutputChanged,
              onSubmitted: (_) => _evaluate(),
            ),
            const SizedBox(height: 24),
            ResultDisplay(
              result: result,
              onTap: result is EvaluationIdle && result.example != null
                  ? () {
                      _inputController.text = result.example!;
                      setState(() {});
                      _cancelDebounce();
                      _evaluate();
                    }
                  : null,
            ),
            if (isOnSubmit) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _evaluate,
                child: const Text('Evaluate'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Modal bottom sheet listing units and functions conformable with the
/// evaluated "Convert from" expression.
class _ConformableUnitsModal extends StatelessWidget {
  final List<ConformableEntry> entries;
  final void Function(String name) onSelect;

  const _ConformableUnitsModal({
    required this.entries,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) {
        return Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: entries.length,
                itemBuilder: (_, index) {
                  final entry = entries[index];
                  final titleText = entry.aliasFor != null
                      ? '${entry.name} = ${entry.aliasFor}'
                      : entry.name;
                  final subtitle =
                      entry.functionLabel ??
                      entry.definitionExpression ??
                      '[primitive unit]';
                  return ListTile(
                    title: Text(titleText),
                    subtitle: Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () => onSelect(entry.name),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
