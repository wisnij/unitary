#!/usr/bin/env dart

/// Performance benchmark script for Unitary's core domain.
///
/// Usage:
///   `dart run tool/benchmark.dart [--filter <substring>] [--json <path>] [--baseline <path>]`
///
/// Runs pure-Dart benchmarks over the core-domain hot paths (repository
/// construction, unit resolution, expression evaluation, browse catalog,
/// currency descriptors, completion suggestions, worksheet computation) and
/// prints a results table.
///
/// `--json path` additionally writes the results as JSON; `--baseline path`
/// compares this run against a previous JSON file.  Timings are machine- and
/// mode-dependent, so baselines are only comparable to runs on the same
/// machine; baseline files should not be committed.
library;

import 'dart:io';

import 'package:unitary/core/domain/models/unit_repository.dart';
import 'package:unitary/core/domain/parser/expression_parser.dart';
import 'package:unitary/features/settings/models/user_settings.dart';
import 'package:unitary/features/worksheet/data/predefined_worksheets.dart';
import 'package:unitary/features/worksheet/services/worksheet_engine.dart';

import 'benchmark_lib.dart';

/// Representative freeform expressions: simple conversion, compound units,
/// functions, derived-unit arithmetic, and a long worst-case expression.
const _expressions = [
  '5 ft',
  '3e4 kilometers/week',
  'tempF(212)',
  '5 N + 3 kg*m/s^2',
  'sqrt(9 m^2) + sin(45 degrees) * 5 ft',
  '(5 kg * 9.8 m/s^2 * 10 m) / (2 min * 3 W) + ln(2) * sqrt(4) * sin(30 degrees) + 1 BTU / 1 kJ',
];

/// Representative completion queries: short prefix with many hits, longer
/// prefix, infix match, and a no-hit worst case that scans the whole catalog.
const _completionQueries = ['me', 'met', 'ring', 'zzzz'];

List<BenchmarkCase> buildDefaultCases() {
  // Shared warm repository for the cases that measure steady-state behavior.
  final sharedRepo = UnitRepository.withPredefinedUnits();
  final sharedParser = ExpressionParser(repo: sharedRepo);

  void resolveAll(UnitRepository repo) {
    for (final unit in repo.allUnits) {
      try {
        benchmarkSink = repo.resolveUnit(unit);
      } catch (_) {
        // Units with unresolvable definitions are skipped, matching
        // buildBrowseCatalog's tolerance.
      }
    }
  }

  return [
    BenchmarkCase(
      name: 'repo-construct',
      iteration: () {
        return () {
          benchmarkSink = UnitRepository.withPredefinedUnits();
        };
      },
    ),
    BenchmarkCase(
      name: 'resolve-all-cold',
      iteration: () {
        final repo = UnitRepository.withPredefinedUnits();
        return () {
          resolveAll(repo);
        };
      },
    ),
    BenchmarkCase(
      name: 'resolve-all-warm',
      iteration: () {
        // Shared repo: the warmup iterations populate the resolution cache,
        // so timed iterations measure cache hits.
        return () {
          resolveAll(sharedRepo);
        };
      },
    ),
    BenchmarkCase(
      name: 'evaluate-expressions',
      iterations: 20,
      iteration: () {
        return () {
          for (final expression in _expressions) {
            benchmarkSink = sharedParser.evaluate(expression);
          }
        };
      },
    ),
    BenchmarkCase(
      name: 'browse-catalog',
      iteration: () {
        // Fresh repository per iteration: at startup the catalog is built
        // against a cold resolution cache, so that is what gets measured.
        final repo = UnitRepository.withPredefinedUnits();
        return () {
          benchmarkSink = repo.buildBrowseCatalog();
        };
      },
    ),
    BenchmarkCase(
      name: 'currency-descriptors',
      iteration: () {
        // Fresh repository per iteration: buildCurrencyDescriptors memoizes
        // its result, so reuse would measure a cache hit.
        final repo = UnitRepository.withPredefinedUnits();
        return () {
          benchmarkSink = repo.buildCurrencyDescriptors();
        };
      },
    ),
    BenchmarkCase(
      name: 'suggest-completions',
      iterations: 20,
      iteration: () {
        return () {
          for (final query in _completionQueries) {
            benchmarkSink = sharedRepo.suggestCompletions(query);
          }
        };
      },
    ),
    _worksheetCase(sharedParser, 'length', '12.5'),
    _worksheetCase(sharedParser, 'temperature', '100'),
  ];
}

/// Builds a [BenchmarkCase] that times [computeWorksheet] for the predefined
/// template [id], sourced from row 0 with [sourceText].
BenchmarkCase _worksheetCase(
  ExpressionParser parser,
  String id,
  String sourceText,
) {
  final template = predefinedWorksheets.firstWhere((t) => t.id == id);
  final settings = UserSettings();
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

void main(List<String> args) {
  String? filter;
  String? jsonPath;
  String? baselinePath;

  for (var i = 0; i < args.length; i++) {
    switch (args[i]) {
      case '--help' || '-h':
        _printUsage(stdout);
        return;
      case '--filter':
        filter = _flagValue(args, i++, '--filter');
      case '--json':
        jsonPath = _flagValue(args, i++, '--json');
      case '--baseline':
        baselinePath = _flagValue(args, i++, '--baseline');
      default:
        stderr.writeln('Unknown argument: ${args[i]}');
        _printUsage(stderr);
        exit(1);
    }
  }

  final cases = filterCases(buildDefaultCases(), filter);
  if (cases.isEmpty) {
    stderr.writeln('No benchmark cases match filter "$filter".');
    exit(1);
  }

  final results = <BenchmarkResult>[];
  for (final benchmarkCase in cases) {
    stderr.writeln('running ${benchmarkCase.name}...');
    results.add(runCase(benchmarkCase));
  }

  stdout.writeln();
  stdout.write(formatResultsTable(results));

  if (jsonPath != null) {
    File(jsonPath).writeAsStringSync(resultsToJson(results));
    stderr.writeln('\nwrote $jsonPath');
  }

  if (baselinePath != null) {
    final baselineFile = File(baselinePath);
    if (!baselineFile.existsSync()) {
      stderr.writeln('Baseline file not found: $baselinePath');
      exit(1);
    }
    final List<BenchmarkResult> baseline;
    try {
      baseline = resultsFromJson(baselineFile.readAsStringSync());
    } on FormatException catch (e) {
      stderr.writeln('Could not parse baseline file $baselinePath: $e');
      exit(1);
    }
    stdout.writeln('\nComparison against $baselinePath:');
    stdout.write(formatComparisonTable(compareToBaseline(results, baseline)));
  }
}

String _flagValue(List<String> args, int i, String flag) {
  if (i + 1 >= args.length) {
    stderr.writeln('Missing value for $flag');
    _printUsage(stderr);
    exit(1);
  }
  return args[i + 1];
}

void _printUsage(IOSink sink) {
  sink.writeln('''
Usage: dart run tool/benchmark.dart [options]

Options:
  --filter <substring>   Run only cases whose names contain <substring>.
  --json <path>          Write results as JSON to <path>.
  --baseline <path>      Compare this run against a previous --json output.
  --help                 Show this help.

Note: $machineDependenceCaveat
Baseline files should stay local (not committed).''');
}
