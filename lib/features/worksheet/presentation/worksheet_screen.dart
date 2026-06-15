import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/top_level_page.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../currency/presentation/currency_refresh_button.dart';
import '../data/predefined_worksheets.dart';
import '../models/worksheet.dart';
import '../services/worksheet_engine.dart';
import '../state/worksheet_provider.dart';
import 'widgets/worksheet_banner.dart';

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

    final banner = template.banner;

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
        actions: [
          if (banner is CurrencyRatesBanner) const CurrencyRefreshButton(),
        ],
      ),
      drawer: AppDrawer(
        currentPage: TopLevelPage.worksheet,
        onNavigate: widget.onNavigate,
      ),
      body: Column(
        children: [
          if (banner != null) WorksheetBannerWidget(banner: banner),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Cap the label column so the input never shrinks below 12 em.
                // IntrinsicColumnWidth then sizes the column to the widest rendered
                // label up to this cap — no TextPainter pre-measurement needed.
                const minInputEm = 12.0;
                const labelAbsoluteMax = 200.0;
                const listPadding = 16.0;
                const columnSpacing = 8.0;
                final inputFontSize =
                    Theme.of(context).textTheme.bodyLarge?.fontSize ?? 16.0;
                final maxLabelWidth =
                    (constraints.maxWidth -
                            listPadding * 2 -
                            columnSpacing -
                            minInputEm * inputFontSize)
                        .clamp(0.0, labelAbsoluteMax);

                final controllers = _controllersFor(template);

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(listPadding),
                  child: Table(
                    columnWidths: const {
                      0: IntrinsicColumnWidth(),
                      1: FixedColumnWidth(columnSpacing),
                      2: FlexColumnWidth(),
                    },
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: [
                      for (var i = 0; i < template.rows.length; i++)
                        _buildTableRow(
                          context,
                          template,
                          values,
                          controllers,
                          activeIndex,
                          activeId,
                          i,
                          maxLabelWidth,
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  TableRow _buildTableRow(
    BuildContext context,
    WorksheetTemplate template,
    List<WorksheetCellResult> values,
    List<TextEditingController> controllers,
    int? activeIndex,
    String activeId,
    int i,
    double maxLabelWidth,
  ) {
    final row = template.rows[i];
    final isActive = activeIndex == i;

    return TableRow(
      key: ValueKey('${template.id}_row_$i'),
      children: [
        // Label cell — intrinsic width, capped at maxLabelWidth.
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: GestureDetector(
            onLongPress: (activeIndex != null && activeIndex != i)
                ? () {
                    final sourceText = values[activeIndex].text;
                    if (sourceText.isEmpty) {
                      return;
                    }
                    controllers[i].text = sourceText;
                    _onRowChanged(activeId, i, sourceText);
                  }
                : null,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: 130,
                maxWidth: maxLabelWidth,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    row.label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    row.expression,
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
        ),
        // Spacer cell (FixedColumnWidth(8) provides the gap).
        const SizedBox.shrink(),
        // Input cell — fills remaining space via FlexColumnWidth.
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: GestureDetector(
            onLongPress: () {
              final text = controllers[i].text;
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
                  _onRowFocused(activeId, i);
                }
              },
              child: TextField(
                controller: controllers[i],
                style: values[i].isError
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
                onChanged: (text) => _onRowChanged(activeId, i, text),
              ),
            ),
          ),
        ),
      ],
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
