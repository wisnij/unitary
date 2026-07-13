/// Companion benchmark for `computeWorksheet()`.
///
/// This lives under `flutter test` rather than in `tool/benchmark.dart`
/// because the worksheet engine's import chain reaches
/// `package:flutter/material.dart` (via `UserSettings`), which the standalone
/// `dart run` VM cannot compile.  It reuses the benchmark library's runner and
/// formatting, prints a results table, and asserts only sanity conditions so
/// it doubles as a smoke test in normal suite runs.
///
/// Run directly to see the numbers:
///   `flutter test test/tool/worksheet_benchmark_test.dart --reporter expanded`
///
/// Note: `flutter test` runs debug-mode JIT with asserts enabled, so these
/// numbers are for relative/order-of-magnitude questions only, and are not
/// comparable to `tool/benchmark.dart` output.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:unitary/core/domain/models/unit_repository.dart';
import 'package:unitary/core/domain/parser/expression_parser.dart';
import 'package:unitary/features/settings/models/user_settings.dart';
import 'package:unitary/features/worksheet/data/predefined_worksheets.dart';
import 'package:unitary/features/worksheet/models/worksheet.dart';
import 'package:unitary/features/worksheet/services/worksheet_engine.dart';

import '../../tool/benchmark_lib.dart';

void main() {
  test('worksheet-compute benchmark', () {
    final repo = UnitRepository.withPredefinedUnits();
    final parser = ExpressionParser(repo: repo);
    final settings = UserSettings();

    WorksheetTemplate templateById(String id) =>
        predefinedWorksheets.firstWhere((t) => t.id == id);

    BenchmarkCase templateCase(String id, String sourceText) {
      final template = templateById(id);
      return BenchmarkCase(
        name: 'worksheet-compute-$id',
        iterations: 20,
        iteration: () {
          return () {
            benchmarkSink = computeWorksheet(
              rows: template.rows,
              sourceIndex: 0,
              sourceText: sourceText,
              parser: parser,
              settings: settings,
            );
          };
        },
      );
    }

    final cases = [
      // Large UnitRow template and a FunctionRow (temperature) template.
      templateCase('length', '12.5'),
      templateCase('temperature', '100'),
    ];

    final results = cases.map(runCase).toList();

    // Printing the table is this benchmark's purpose.
    // ignore: avoid_print
    print('\n${formatResultsTable(results)}');

    // Sanity conditions: the engine really computed values.  The source value
    // 500 (K for temperature) keeps every row in-domain — notably gas mark,
    // whose function rejects values below its defined range.
    for (final template in ['length', 'temperature']) {
      final rows = templateById(template).rows;
      final result = computeWorksheet(
        rows: rows,
        sourceIndex: 0,
        sourceText: '500',
        parser: parser,
        settings: settings,
      );
      final computed = result.values.whereType<WorksheetCellResult>();
      expect(
        computed,
        hasLength(rows.length - 1),
        reason: 'every non-source row of $template computes a value',
      );
      expect(computed.map((c) => c.isError), everyElement(isFalse));
    }
    for (final result in results) {
      expect(result.samplesUs, hasLength(20));
    }
  });
}
