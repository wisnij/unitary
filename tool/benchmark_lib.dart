/// Core library for the performance benchmark script.
///
/// Contains the benchmark case abstraction, timing runner, statistics,
/// baseline comparison, and output formatting.  The executable wrapper with
/// the case registry lives in `benchmark.dart`.
library;

import 'dart:convert';
import 'dart:io';

/// A timed benchmark body, returned fresh from [BenchmarkCase.iteration].
typedef BenchmarkBody = void Function();

/// Assign otherwise-unused benchmark results here so the optimizer cannot
/// eliminate the work being measured.
Object? benchmarkSink;

/// Caveat printed with baseline comparisons: timings are only comparable to
/// runs on the same machine in the same mode.
const String machineDependenceCaveat =
    'Timings are machine- and mode-dependent (JIT vs. AOT); '
    'only compare against baselines recorded on the same machine.';

/// A single benchmark case.
///
/// [iteration] is a per-iteration setup factory: it is called once per
/// iteration (warmup and timed alike) and may do arbitrary untimed setup work
/// (e.g. constructing a fresh `UnitRepository` for cold-cache cases).  Only
/// the [BenchmarkBody] it returns is timed.
class BenchmarkCase {
  final String name;
  final int warmup;
  final int iterations;
  final BenchmarkBody Function() iteration;

  BenchmarkCase({
    required this.name,
    this.warmup = 2,
    this.iterations = 10,
    required this.iteration,
  });
}

/// Timing samples for one executed benchmark case.
class BenchmarkResult {
  final String name;

  /// Wall-clock time of each timed iteration, in microseconds.
  final List<int> samplesUs;

  BenchmarkResult({required this.name, required this.samplesUs});

  int get iterations => samplesUs.length;

  int get minUs => samplesUs.reduce((a, b) => a < b ? a : b);

  double get medianUs {
    final sorted = List<int>.of(samplesUs)..sort();
    final mid = sorted.length ~/ 2;
    if (sorted.length.isOdd) {
      return sorted[mid].toDouble();
    }
    return (sorted[mid - 1] + sorted[mid]) / 2;
  }

  double get meanUs => samplesUs.reduce((a, b) => a + b) / samplesUs.length;
}

/// Runs [benchmarkCase]: [BenchmarkCase.warmup] untimed iterations followed by
/// [BenchmarkCase.iterations] timed ones.  Setup work done in the iteration
/// factory is excluded from the timing.
BenchmarkResult runCase(BenchmarkCase benchmarkCase) {
  for (var i = 0; i < benchmarkCase.warmup; i++) {
    final body = benchmarkCase.iteration();
    body();
  }

  final samplesUs = <int>[];
  final stopwatch = Stopwatch();
  for (var i = 0; i < benchmarkCase.iterations; i++) {
    final body = benchmarkCase.iteration();
    stopwatch
      ..reset()
      ..start();
    body();
    stopwatch.stop();
    samplesUs.add(stopwatch.elapsedMicroseconds);
  }

  return BenchmarkResult(name: benchmarkCase.name, samplesUs: samplesUs);
}

/// Returns the cases whose names contain [filter]; all cases if [filter] is
/// null.
List<BenchmarkCase> filterCases(List<BenchmarkCase> cases, String? filter) {
  if (filter == null) {
    return cases;
  }
  return cases.where((c) => c.name.contains(filter)).toList();
}

/// Serializes [results] with environment metadata as pretty-printed JSON.
String resultsToJson(List<BenchmarkResult> results) {
  final document = {
    'timestamp': DateTime.now().toIso8601String(),
    'dartVersion': Platform.version,
    'operatingSystem': Platform.operatingSystem,
    'results': [
      for (final result in results)
        {
          'name': result.name,
          'samplesUs': result.samplesUs,
          // Derived from samplesUs; included so the JSON is self-describing.
          // resultsFromJson reads only name and samplesUs.
          'iterations': result.iterations,
          'minUs': result.minUs,
          'medianUs': result.medianUs,
          'meanUs': result.meanUs,
        },
    ],
  };
  return const JsonEncoder.withIndent('  ').convert(document);
}

/// Parses JSON produced by [resultsToJson].
///
/// Throws [FormatException] if the input is not valid benchmark JSON.
List<BenchmarkResult> resultsFromJson(String json) {
  final Object? decoded;
  try {
    decoded = jsonDecode(json);
  } on FormatException {
    rethrow;
  }
  if (decoded is! Map<String, Object?> || decoded['results'] is! List) {
    throw const FormatException('Missing "results" list in benchmark JSON');
  }
  final results = <BenchmarkResult>[];
  for (final entry in decoded['results'] as List) {
    if (entry is! Map<String, Object?> ||
        entry['name'] is! String ||
        entry['samplesUs'] is! List) {
      throw FormatException('Malformed benchmark result entry: $entry');
    }
    results.add(
      BenchmarkResult(
        name: entry['name'] as String,
        samplesUs: (entry['samplesUs'] as List).cast<int>(),
      ),
    );
  }
  return results;
}

/// A matched case in a baseline comparison.
class CaseComparison {
  final String name;
  final double currentMedianUs;
  final double baselineMedianUs;

  CaseComparison({
    required this.name,
    required this.currentMedianUs,
    required this.baselineMedianUs,
  });

  /// Relative change from baseline to current: 0.5 means 50% slower.
  double get changeFraction =>
      (currentMedianUs - baselineMedianUs) / baselineMedianUs;
}

/// Result of comparing a benchmark run against a baseline run.
class BaselineComparison {
  /// Cases present in both runs, in the current run's order.
  final List<CaseComparison> matched;

  /// Case names in the current run but not the baseline.
  final List<String> unmatchedCurrent;

  /// Case names in the baseline but not the current run.
  final List<String> unmatchedBaseline;

  BaselineComparison({
    required this.matched,
    required this.unmatchedCurrent,
    required this.unmatchedBaseline,
  });
}

/// Matches [current] against [baseline] by case name.
BaselineComparison compareToBaseline(
  List<BenchmarkResult> current,
  List<BenchmarkResult> baseline,
) {
  final baselineByName = {for (final r in baseline) r.name: r};
  final matched = <CaseComparison>[];
  final unmatchedCurrent = <String>[];

  for (final result in current) {
    final baselineResult = baselineByName.remove(result.name);
    if (baselineResult == null) {
      unmatchedCurrent.add(result.name);
    } else {
      matched.add(
        CaseComparison(
          name: result.name,
          currentMedianUs: result.medianUs,
          baselineMedianUs: baselineResult.medianUs,
        ),
      );
    }
  }

  return BaselineComparison(
    matched: matched,
    unmatchedCurrent: unmatchedCurrent,
    unmatchedBaseline: baselineByName.keys.toList(),
  );
}

/// Formats a microsecond duration with a human-friendly unit (µs, ms, or s).
String formatDurationUs(num us) {
  if (us < 1000) {
    return '${us.round()} µs';
  }
  if (us < 1000000) {
    return '${_threeSignificant(us / 1000)} ms';
  }
  return '${_threeSignificant(us / 1000000)} s';
}

String _threeSignificant(double value) {
  if (value >= 100) {
    return value.toStringAsFixed(0);
  }
  if (value >= 10) {
    return value.toStringAsFixed(1);
  }
  return value.toStringAsFixed(2);
}

/// Formats [results] as an aligned human-readable table.
String formatResultsTable(List<BenchmarkResult> results) {
  final rows = [
    ['case', 'iters', 'min', 'median', 'mean'],
    for (final result in results)
      [
        result.name,
        '${result.iterations}',
        formatDurationUs(result.minUs),
        formatDurationUs(result.medianUs),
        formatDurationUs(result.meanUs),
      ],
  ];
  return _alignColumns(rows);
}

/// Formats a baseline comparison as an aligned table, flagging cases whose
/// median changed by more than [threshold] (a fraction; 0.2 = 20%).
String formatComparisonTable(
  BaselineComparison comparison, {
  double threshold = 0.20,
}) {
  final rows = [
    ['case', 'baseline', 'current', 'change', ''],
    for (final match in comparison.matched)
      [
        match.name,
        formatDurationUs(match.baselineMedianUs),
        formatDurationUs(match.currentMedianUs),
        _formatPercent(match.changeFraction),
        _changeFlag(match.changeFraction, threshold),
      ],
  ];

  final buffer = StringBuffer(_alignColumns(rows));
  for (final name in comparison.unmatchedCurrent) {
    buffer.writeln('$name: not in baseline');
  }
  for (final name in comparison.unmatchedBaseline) {
    buffer.writeln('$name: not in this run');
  }
  buffer
    ..writeln()
    ..writeln('Note: $machineDependenceCaveat');
  return buffer.toString();
}

String _formatPercent(double fraction) {
  final percent = fraction * 100;
  final sign = percent >= 0 ? '+' : '';
  return '$sign${percent.toStringAsFixed(1)}%';
}

String _changeFlag(double fraction, double threshold) {
  if (fraction > threshold) {
    return 'REGRESSION';
  }
  if (fraction < -threshold) {
    return 'improvement';
  }
  return '';
}

String _alignColumns(List<List<String>> rows) {
  final widths = <int>[];
  for (final row in rows) {
    for (var i = 0; i < row.length; i++) {
      if (i >= widths.length) {
        widths.add(0);
      }
      if (row[i].length > widths[i]) {
        widths[i] = row[i].length;
      }
    }
  }

  final buffer = StringBuffer();
  for (final row in rows) {
    final cells = <String>[];
    for (var i = 0; i < row.length; i++) {
      cells.add(row[i].padRight(widths[i]));
    }
    buffer.writeln(cells.join('  ').trimRight());
  }
  return buffer.toString();
}
