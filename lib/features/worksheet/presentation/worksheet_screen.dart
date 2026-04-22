import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/top_level_page.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../data/predefined_worksheets.dart';
import '../models/worksheet.dart';
import '../services/worksheet_engine.dart';
import '../state/worksheet_provider.dart';
import 'widgets/worksheet_row_widget.dart';

/// Worksheet mode screen.
///
/// Owns its own [Scaffold] and [AppBar].  Navigation to other top-level pages
/// is delegated to [onNavigate], which is called by [AppDrawer] when the user
/// taps a navigation tile.
class WorksheetScreen extends ConsumerStatefulWidget {
  const WorksheetScreen({super.key, required this.onNavigate});

  /// Called when the user navigates to another top-level page via the drawer.
  final void Function(TopLevelPage) onNavigate;

  @override
  ConsumerState<WorksheetScreen> createState() => _WorksheetScreenState();
}

class _WorksheetScreenState extends ConsumerState<WorksheetScreen> {
  // Controllers keyed by worksheetId + rowIndex, created lazily and retained.
  final Map<String, List<TextEditingController>> _controllers = {};

  @override
  void dispose() {
    for (final list in _controllers.values) {
      for (final c in list) {
        c.dispose();
      }
    }
    super.dispose();
  }

  List<TextEditingController> _controllersFor(WorksheetTemplate template) {
    return _controllers.putIfAbsent(
      template.id,
      () => List.generate(
        template.rows.length,
        (_) => TextEditingController(),
      ),
    );
  }

  /// Syncs controller text from state for non-active rows, avoiding
  /// overwriting what the user is currently typing.
  void _syncControllers(
    WorksheetTemplate template,
    List<WorksheetCellResult> values,
    int? activeIndex,
  ) {
    final controllers = _controllersFor(template);
    for (var i = 0; i < controllers.length; i++) {
      if (i == activeIndex) {
        continue; // let the user's raw text stand
      }
      final newText = values[i].text;
      if (controllers[i].text != newText) {
        controllers[i].text = newText;
      }
    }
  }

  void _onRowChanged(String worksheetId, int rowIndex, String text) {
    ref
        .read(worksheetProvider.notifier)
        .onRowChanged(worksheetId, rowIndex, text);
  }

  void _onRowFocused(String worksheetId, int rowIndex) {
    ref.read(worksheetProvider.notifier).onRowFocused(worksheetId, rowIndex);
  }

  @override
  Widget build(BuildContext context) {
    final worksheetState = ref.watch(worksheetProvider);
    final activeId = worksheetState.worksheetId;
    final template = predefinedWorksheets.firstWhere(
      (t) => t.id == activeId,
    );
    final values = worksheetState.valuesFor(activeId, template.rows.length);
    final activeIndex = worksheetState.activeRowIndex;

    // Sync non-active controller texts from state after each rebuild.
    _syncControllers(template, values, activeIndex);

    return Scaffold(
      appBar: AppBar(
        title: WorksheetDropdown(
          templates: [...predefinedWorksheets]
            ..sort(
              (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
            ),
          selectedId: activeId,
          onChanged: (id) =>
              ref.read(worksheetProvider.notifier).selectWorksheet(id),
        ),
      ),
      drawer: AppDrawer(
        currentPage: TopLevelPage.worksheet,
        onNavigate: widget.onNavigate,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: template.rows.length,
        itemBuilder: (context, i) {
          final row = template.rows[i];
          final controllers = _controllersFor(template);
          return WorksheetRowWidget(
            key: ValueKey('${template.id}_row_$i'),
            label: row.label,
            expression: row.expression,
            controller: controllers[i],
            isActive: activeIndex == i,
            isError: values[i].isError,
            onChanged: (text) => _onRowChanged(activeId, i, text),
            onFocused: () => _onRowFocused(activeId, i),
            onLabelLongPress: (activeIndex != null && activeIndex != i)
                ? () {
                    final sourceText = values[activeIndex].text;
                    if (sourceText.isEmpty) {
                      return;
                    }
                    controllers[i].text = sourceText;
                    _onRowChanged(activeId, i, sourceText);
                  }
                : null,
          );
        },
      ),
    );
  }
}

/// Dropdown widget for selecting a worksheet template.
///
/// Used as the AppBar title in [WorksheetScreen].
class WorksheetDropdown extends StatelessWidget {
  final List<WorksheetTemplate> templates;
  final String selectedId;
  final ValueChanged<String> onChanged;

  const WorksheetDropdown({
    super.key,
    required this.templates,
    required this.selectedId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return DropdownButton<String>(
      value: selectedId,
      underline: const SizedBox.shrink(),
      style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
      icon: const Icon(Icons.arrow_drop_down),
      selectedItemBuilder: (context) => [
        for (final t in templates)
          DropdownMenuItem(
            value: t.id,
            child: Text(
              t.name,
              style: textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ),
      ],
      items: [
        for (final t in templates)
          DropdownMenuItem(value: t.id, child: Text(t.name)),
      ],
      onChanged: (id) {
        if (id != null) {
          onChanged(id);
        }
      },
    );
  }
}
