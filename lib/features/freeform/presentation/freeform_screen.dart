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
import '../data/freeform_history_repository.dart';
import '../state/freeform_history_provider.dart';
import '../state/freeform_provider.dart';
import '../state/freeform_state.dart';
import '../state/parser_provider.dart';
import 'widgets/completion_field.dart';
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
  final _inputFocus = FocusNode();
  final _outputFocus = FocusNode();
  bool _anyFieldFocused = false;
  ({TextEditingController ctrl, FocusNode focus})? _lastFocused;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _inputFocus.addListener(_onFocusChange);
    _outputFocus.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _inputController.dispose();
    _outputController.dispose();
    _inputFocus.removeListener(_onFocusChange);
    _outputFocus.removeListener(_onFocusChange);
    _inputFocus.dispose();
    _outputFocus.dispose();
    super.dispose();
  }

  // On mobile (Android/iOS), the panel appears above the system keyboard and
  // should only show when a field is focused.  On desktop/web there is no
  // system keyboard, so the panel is always visible.
  bool get _showPanel {
    final isMobile =
        !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);
    return !isMobile || _anyFieldFocused;
  }

  void _onFocusChange() {
    if (_inputFocus.hasFocus) {
      _lastFocused = (ctrl: _inputController, focus: _inputFocus);
    } else if (_outputFocus.hasFocus) {
      _lastFocused = (ctrl: _outputController, focus: _outputFocus);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final focused = _inputFocus.hasFocus || _outputFocus.hasFocus;
      if (focused != _anyFieldFocused) {
        setState(() {
          _anyFieldFocused = focused;
        });
      }
    });
  }

  void _onInputChanged(String _) {
    setState(() {}); // Rebuild to update clear button and swap button states.
    final settings = ref.read(settingsProvider);
    if (settings.evaluationMode == EvaluationMode.realtime) {
      _debounceEvaluate();
    }
  }

  void _onOutputChanged(String _) {
    setState(() {}); // Rebuild to update swap button enabled state.
    final settings = ref.read(settingsProvider);
    if (settings.evaluationMode == EvaluationMode.realtime) {
      _debounceEvaluate();
    }
  }

  void _insertSymbol(String symbol) {
    final (:ctrl, :focus) =
        _lastFocused ?? (ctrl: _inputController, focus: _inputFocus);
    final sel = ctrl.selection;
    final start = (sel.isValid && sel.start >= 0)
        ? sel.start
        : ctrl.text.length;
    final end = (sel.isValid && sel.end >= 0) ? sel.end : ctrl.text.length;
    final cursorOffset = start + symbol.length;
    ctrl.value = TextEditingValue(
      text: ctrl.text.replaceRange(start, end, symbol),
      selection: TextSelection.collapsed(offset: cursorOffset),
    );
    focus.requestFocus();
    // On web, regaining focus can cause the browser to select all text.
    // Override that in the next frame so the cursor lands after the inserted
    // symbol.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ctrl.selection = TextSelection.collapsed(offset: cursorOffset);
      }
    });
    final settings = ref.read(settingsProvider);
    if (settings.evaluationMode == EvaluationMode.realtime) {
      _debounceEvaluate();
    }
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

  void _restoreHistoryEntry(FreeformHistoryEntry entry) {
    _inputController.text = entry.from;
    _outputController.text = entry.to;
    _cancelDebounce();
    _evaluate();
  }

  void _showHistoryModal(BuildContext context) {
    final history = ref.read(freeformHistoryProvider);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _HistoryModal(
        entries: history,
        onSelect: (entry) {
          Navigator.of(context).pop();
          _restoreHistoryEntry(entry);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(freeformProvider);
    final history = ref.watch(freeformHistoryProvider);
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
            icon: const Icon(Icons.history),
            tooltip: 'Conversion history',
            onPressed: history.isNotEmpty
                ? () => _showHistoryModal(context)
                : null,
          ),
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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CompletionField(
                    controller: _inputController,
                    focusNode: _inputFocus,
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
                  CompletionField(
                    controller: _outputController,
                    focusNode: _outputFocus,
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
                            FocusScope.of(context).unfocus();
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
          ),
          if (_showPanel) _KeyPanel(onSymbol: _insertSymbol),
        ],
      ),
    );
  }
}

/// Ordered list of symbols shown in the freeform key panel.
const freeformKeyPanelSymbols = ['^', '*', '/', '|', '+', '-', '~', '(', ')'];

/// Supplementary symbol key panel displayed above the system keyboard.
class _KeyPanel extends StatelessWidget {
  const _KeyPanel({required this.onSymbol});

  final void Function(String) onSymbol;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.surfaceContainerLow,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(height: 1, thickness: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            child: Row(
              children: [
                for (final sym in freeformKeyPanelSymbols)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          foregroundColor: colorScheme.onSurface,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => onSymbol(sym),
                        child: Text(
                          sym,
                          style: const TextStyle(
                            fontSize: 18,
                            // 'monospace' is a CSS generic family recognised by
                            // Android (resolves to Roboto Mono / Droid Sans
                            // Mono) but is not guaranteed on iOS.  If iOS
                            // support is added, replace with a bundled font or
                            // a fontFamilyFallback list.
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Modal bottom sheet listing past successful freeform conversions.
class _HistoryModal extends StatelessWidget {
  final List<FreeformHistoryEntry> entries;
  final void Function(FreeformHistoryEntry) onSelect;

  const _HistoryModal({required this.entries, required this.onSelect});

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
                  final label = entry.result.isNotEmpty
                      ? '${entry.from} = ${entry.result}'
                      : entry.from;
                  return ListTile(
                    title: Text(label),
                    onTap: () => onSelect(entry),
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
