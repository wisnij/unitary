import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/domain/models/browse_entry.dart';
import '../../../core/domain/models/function.dart';
import '../../../core/domain/models/quantity.dart';
import '../../../core/domain/models/unit.dart';
import '../../../core/domain/models/unit_repository.dart';
import '../../../core/domain/services/unit_resolver.dart';
import '../../../shared/utils/quantity_formatter.dart';
import '../../settings/models/user_settings.dart';
import '../../settings/state/settings_provider.dart';

/// Detail page for a single unit, prefix, or function.
///
/// Always receives [primaryId] + [kind] — alias rows in the browse list
/// navigate here using the alias's [BrowseEntry.primaryId], so both the
/// primary and its aliases end up on the same page.
class UnitEntryDetailScreen extends ConsumerWidget {
  const UnitEntryDetailScreen({
    super.key,
    required this.primaryId,
    required this.kind,
    this.repo,
  });

  final String primaryId;
  final BrowseEntryKind kind;

  /// Optional override for the unit repository; when null, the shared
  /// predefined-units instance is used.  Pass a custom repo in tests to avoid
  /// loading the full database.
  final UnitRepository? repo;

  static final _defaultRepo = UnitRepository.withPredefinedUnits();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final effectiveRepo = repo ?? _defaultRepo;

    return Scaffold(
      appBar: AppBar(title: Text(primaryId)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _DetailBody(
          primaryId: primaryId,
          kind: kind,
          repo: effectiveRepo,
          settings: settings,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Body widget — separated so it can be tested independently.
// ---------------------------------------------------------------------------

class _DetailBody extends StatelessWidget {
  const _DetailBody({
    required this.primaryId,
    required this.kind,
    required this.repo,
    required this.settings,
  });

  final String primaryId;
  final BrowseEntryKind kind;
  final UnitRepository repo;
  final UserSettings settings;

  @override
  Widget build(BuildContext context) {
    return switch (kind) {
      BrowseEntryKind.unit || BrowseEntryKind.prefix => _UnitDetailBody(
        primaryId: primaryId,
        repo: repo,
        settings: settings,
      ),
      BrowseEntryKind.function => _FunctionDetailBody(
        primaryId: primaryId,
        repo: repo,
        settings: settings,
      ),
    };
  }
}

// ---------------------------------------------------------------------------
// Shared section widgets
// ---------------------------------------------------------------------------

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class _DetailText extends StatelessWidget {
  const _DetailText(this.text, {this.mono = false, this.copyable = true});
  final String text;
  final bool mono;

  /// When true, long-pressing copies [text] to the clipboard and shows a
  /// confirmation snack bar.
  final bool copyable;

  @override
  Widget build(BuildContext context) {
    final textWidget = Text(
      text,
      style: mono
          ? Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontFamily: 'monospace',
            )
          : Theme.of(context).textTheme.bodyMedium,
    );

    if (!copyable) {
      return textWidget;
    }

    return GestureDetector(
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: text));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Copied: $text'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: textWidget,
    );
  }
}

// ---------------------------------------------------------------------------
// Unit / prefix detail
// ---------------------------------------------------------------------------

class _UnitDetailBody extends StatelessWidget {
  const _UnitDetailBody({
    required this.primaryId,
    required this.repo,
    required this.settings,
  });

  final String primaryId;
  final UnitRepository repo;
  final UserSettings settings;

  @override
  Widget build(BuildContext context) {
    final Unit? unit = repo.findUnit(primaryId) ?? repo.findPrefix(primaryId);
    if (unit == null) {
      return Text('Unit not found: $primaryId');
    }

    // Resolved quantity.
    Quantity? resolved;
    try {
      resolved = resolveUnit(unit, repo);
    } catch (_) {
      resolved = null;
    }

    final String typeLabel;
    if (unit is PrefixUnit) {
      typeLabel = 'Prefix';
    } else if (unit is PrimitiveUnit) {
      typeLabel = unit.isDimensionless
          ? 'Primitive unit (dimensionless)'
          : 'Primitive unit';
    } else {
      typeLabel = 'Derived unit';
    }

    final children = <Widget>[
      // Primary name.
      const _SectionTitle('Name'),
      _DetailText(unit.id, mono: true, copyable: true),
    ];

    // Aliases (sorted case-insensitively).
    if (unit.aliases.isNotEmpty) {
      final sortedAliases = unit.aliases.toList()
        ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      children.add(const _SectionTitle('Aliases'));
      children.add(_DetailText(sortedAliases.join(', '), mono: true));
    }

    // Type.
    children.add(const _SectionTitle('Type'));
    children.add(_DetailText(typeLabel));

    // Description.
    if (unit.description != null) {
      children.add(const _SectionTitle('Description'));
      children.add(_DetailText(unit.description!));
    }

    // Definition — omitted for primitive units (no expression to show).
    if (unit is DerivedUnit) {
      children.add(const _SectionTitle('Definition'));
      children.add(_DetailText(unit.expression, mono: true, copyable: true));
    }

    // Resolved quantity (shown as its SI value).
    if (resolved != null) {
      children.add(const _SectionTitle('Value'));
      final formatted = formatQuantity(
        resolved,
        precision: settings.precision,
        notation: settings.notation,
      );
      children.add(_DetailText(formatted, mono: true, copyable: true));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}

// ---------------------------------------------------------------------------
// Function detail
// ---------------------------------------------------------------------------

class _FunctionDetailBody extends StatelessWidget {
  const _FunctionDetailBody({
    required this.primaryId,
    required this.repo,
    required this.settings,
  });

  final String primaryId;
  final UnitRepository repo;
  final UserSettings settings;

  @override
  Widget build(BuildContext context) {
    final func = repo.findFunction(primaryId);
    if (func == null) {
      return Text('Function not found: $primaryId');
    }

    final String typeLabel = func is PiecewiseFunction
        ? 'Piecewise linear function'
        : 'Function';

    final children = <Widget>[
      // Primary name.
      const _SectionTitle('Name'),
      _DetailText(func.id, mono: true, copyable: true),
    ];

    // Aliases (sorted case-insensitively).
    if (func.aliases.isNotEmpty) {
      final sortedAliases = func.aliases.toList()
        ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      children.add(const _SectionTitle('Aliases'));
      children.add(_DetailText(sortedAliases.join(', '), mono: true));
    }

    // Type.
    children.add(const _SectionTitle('Type'));
    children.add(_DetailText(typeLabel));

    // Functions do not currently carry a description field.

    // Definition.
    children.add(const _SectionTitle('Definition'));
    if (func is PiecewiseFunction) {
      // For piecewise functions the control-point table is the definition;
      // Domain / Range and a separate Values section are not shown.
      if (func.points.isNotEmpty) {
        children.add(_PiecewiseTable(func: func, settings: settings));
      }
    } else {
      final signature = '${func.id}(${func.params.join(', ')}) = ';
      final body = func is DefinedFunction
          ? func.forward
          : (func.definitionDisplay ?? '[builtin function]');
      children.add(_DetailText('$signature$body', mono: true, copyable: true));
    }

    // Inverse (if available) — only for non-piecewise DefinedFunctions.
    if (func is DefinedFunction && func.hasInverse) {
      children.add(const _SectionTitle('Inverse'));
      children.add(_DetailText(func.inverse!, mono: true));
    }

    // Domain / range (if constrained) — not shown for PiecewiseFunctions.
    if (func is! PiecewiseFunction) {
      final hasDomain =
          func.domain != null && func.domain!.any(_specIsNonEmpty);
      final hasRange = func.range != null && _specIsNonEmpty(func.range!);
      if (hasDomain || hasRange) {
        children.add(const _SectionTitle('Domain / Range'));
        if (hasDomain) {
          for (var i = 0; i < func.domain!.length; i++) {
            final spec = func.domain![i];
            if (_specIsNonEmpty(spec)) {
              final argName = i < func.params.length ? func.params[i] : 'arg$i';
              children.add(
                _DetailText(_formatSpec('Argument $argName', spec)),
              );
            }
          }
        }
        if (hasRange) {
          children.add(_DetailText(_formatSpec('Range', func.range!)));
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  static bool _specIsNonEmpty(QuantitySpec spec) {
    return spec.quantity != null || spec.min != null || spec.max != null;
  }

  static String _formatSpec(String prefix, QuantitySpec spec) {
    final parts = <String>[];
    if (spec.quantity != null) {
      if (spec.unitExpression != null) {
        parts.add(
          spec.unitExpression == '1' ? 'dimensionless' : spec.unitExpression!,
        );
      } else {
        final dim = spec.quantity!.dimension;
        parts.add(
          dim.isDimensionless ? 'dimensionless' : dim.canonicalRepresentation(),
        );
      }
    }
    if (spec.min != null || spec.max != null) {
      parts.add(spec.boundsString());
    }
    return '$prefix: ${parts.join(' ')}';
  }
}

// ---------------------------------------------------------------------------
// Piecewise table
// ---------------------------------------------------------------------------

class _PiecewiseTable extends StatelessWidget {
  const _PiecewiseTable({required this.func, required this.settings});

  final PiecewiseFunction func;
  final UserSettings settings;

  @override
  Widget build(BuildContext context) {
    // Derive output column header from range quantity unit label.
    // The input is always dimensionless so its header is always plain 'Input'.
    const String inputHeader = 'Input';
    String outputHeader = 'Output';
    if (func.range != null) {
      final rangeSpec = func.range!;
      final unitExpr = rangeSpec.unitExpression;
      if (unitExpr != null && unitExpr != '1') {
        outputHeader = 'Output ($unitExpr)';
      } else {
        final rangeDim = rangeSpec.quantity?.dimension;
        if (rangeDim != null && !rangeDim.isDimensionless) {
          outputHeader = 'Output (${rangeDim.canonicalRepresentation()})';
        }
      }
    }

    return Table(
      border: TableBorder.all(
        color: Theme.of(context).colorScheme.outlineVariant,
      ),
      columnWidths: const {
        0: FlexColumnWidth(),
        1: FlexColumnWidth(),
      },
      children: [
        // Header row.
        TableRow(
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          ),
          children: [
            _tableCell(context, inputHeader, header: true),
            _tableCell(context, outputHeader, header: true),
          ],
        ),
        // Data rows.
        for (final (x, y) in func.points)
          TableRow(
            children: [
              _tableCell(
                context,
                formatValue(
                  x,
                  precision: settings.precision,
                  notation: settings.notation,
                ),
              ),
              _tableCell(
                context,
                formatValue(
                  y,
                  precision: settings.precision,
                  notation: settings.notation,
                ),
              ),
            ],
          ),
      ],
    );
  }

  static Widget _tableCell(
    BuildContext context,
    String text, {
    bool header = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(
        text,
        style: header
            ? Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
              )
            : Theme.of(context).textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
              ),
      ),
    );
  }
}
