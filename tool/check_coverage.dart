#!/usr/bin/env dart

/// Coverage-threshold checker for Unitary.
///
/// Usage:
///   `dart run tool/check_coverage.dart [--lcov <path>] [--min <percent>]`
///   `                                  [--scope <prefix>] [--exclude <path>]`
///
/// Reads the LCOV report written by `flutter test --coverage`, restricts it to
/// the enforced scope (all of `lib/`, minus the generated units file), and
/// exits non-zero if line coverage falls below the minimum or if the set of
/// files absent from the report no longer matches the expected-absence
/// allowlist.
///
/// Run from the repository root: LCOV paths are repo-relative, and the
/// allowlist comparison enumerates source files from the working directory.
///
/// `--scope` and `--exclude` may each be repeated; supplying either replaces
/// the corresponding default rather than adding to it.
library;

import 'dart:io';

import 'check_coverage_lib.dart';

String get _usage =>
    '''
Usage: dart run tool/check_coverage.dart [options]

Options:
  --lcov <path>       LCOV report to read (default: $defaultLcovPath)
  --min <percent>     Minimum scoped line coverage (default: $defaultMinimumPercent)
  --scope <prefix>    Path prefix to enforce; repeatable (default: ${defaultScopes.join(', ')})
  --exclude <path>    Path or directory prefix to exclude; repeatable
  -h, --help          Show this help
''';

void main(List<String> args) {
  if (args.contains('-h') || args.contains('--help')) {
    stdout.write(_usage);
    return;
  }

  final String lcovPath;
  final CoverageConfig config;
  try {
    (lcovPath, config) = _parseArgs(args);
  } on FormatException catch (e) {
    stderr.writeln('Error: ${e.message}');
    stderr.write(_usage);
    exit(2);
  }

  final result = checkCoverage(lcovPath: lcovPath, config: config);
  _report(result, config);
  exit(result.passed ? 0 : 1);
}

(String, CoverageConfig) _parseArgs(List<String> args) {
  var lcovPath = defaultLcovPath;
  var minimum = defaultMinimumPercent;
  final scopes = <String>[];
  final exclusions = <String>[];

  String valueFor(int i, String flag) {
    if (i + 1 >= args.length) {
      throw FormatException('$flag requires a value');
    }
    return args[i + 1];
  }

  for (var i = 0; i < args.length; i++) {
    switch (args[i]) {
      case '--lcov':
        lcovPath = valueFor(i, '--lcov');
        i++;
      case '--min':
        final raw = valueFor(i, '--min');
        final parsed = double.tryParse(raw);
        if (parsed == null || parsed < 0 || parsed > 100) {
          throw FormatException(
            '--min must be a percentage in 0..100, got "$raw"',
          );
        }
        minimum = parsed;
        i++;
      case '--scope':
        scopes.add(valueFor(i, '--scope'));
        i++;
      case '--exclude':
        exclusions.add(valueFor(i, '--exclude'));
        i++;
      default:
        throw FormatException('unknown argument "${args[i]}"');
    }
  }

  return (
    lcovPath,
    CoverageConfig(
      minimumPercent: minimum,
      scopes: scopes.isEmpty ? defaultScopes : scopes,
      exclusions: exclusions.isEmpty ? defaultExclusions : exclusions,
    ),
  );
}

void _report(CoverageResult result, CoverageConfig config) {
  if (result.error != null) {
    stderr.writeln('Error: ${result.error}');
    return;
  }

  final width = result.files.fold(
    0,
    (w, f) => f.path.length > w ? f.path.length : w,
  );

  stdout.writeln(
    'Coverage for ${config.scopes.join(', ')} '
    '(excluding ${config.exclusions.length} path(s)), least-covered first:',
  );
  stdout.writeln();
  for (final file in result.files) {
    stdout.writeln(
      '  ${file.path.padRight(width)}  '
      '${file.percent.toStringAsFixed(2).padLeft(6)}%  '
      '${file.covered}/${file.total}',
    );
  }

  stdout.writeln();
  stdout.writeln(
    '  Total: ${result.covered}/${result.total} = '
    '${result.percent.toStringAsFixed(2)}%',
  );

  if (result.hasAllowlistMismatch) {
    stdout.writeln();
    _reportMismatches(result);
  }

  stdout.writeln();
  if (result.passed) {
    stdout.writeln(
      'PASS: coverage ${result.percent.toStringAsFixed(2)}% meets the '
      '${result.minimumPercent.toStringAsFixed(2)}% minimum.',
    );
  } else if (!result.meetsThreshold) {
    stdout.writeln(
      'FAIL: coverage ${result.percent.toStringAsFixed(2)}% is below the '
      '${result.minimumPercent.toStringAsFixed(2)}% minimum.',
    );
  } else {
    stdout.writeln(
      'FAIL: coverage ${result.percent.toStringAsFixed(2)}% meets the minimum, '
      'but the expected-absence allowlist is out of date.',
    );
  }
}

void _reportMismatches(CoverageResult result) {
  if (result.unexpectedAbsent.isNotEmpty) {
    stdout.writeln(
      'In-scope files absent from the coverage report but not on the '
      'expected-absence allowlist:',
    );
    for (final path in result.unexpectedAbsent) {
      stdout.writeln('  $path');
    }
    stdout.writeln(
      '  -> Write a test that loads the file, or, if it has no executable '
      'lines to instrument\n'
      '     (const-only data, a bare enum), add it to defaultExpectedAbsent '
      'in\n'
      '     tool/check_coverage_lib.dart with a comment saying which.',
    );
  }

  if (result.stalePresent.isNotEmpty) {
    stdout.writeln(
      'Allowlisted files that now report coverage (stale allowlist entries):',
    );
    for (final path in result.stalePresent) {
      stdout.writeln('  $path');
    }
    stdout.writeln(
      '  -> Remove these from defaultExpectedAbsent in '
      'tool/check_coverage_lib.dart\n'
      '     so their lines count toward the total.',
    );
  }

  if (result.staleMissing.isNotEmpty) {
    stdout.writeln(
      'Allowlisted files that no longer exist (stale allowlist entries):',
    );
    for (final path in result.staleMissing) {
      stdout.writeln('  $path');
    }
    stdout.writeln(
      '  -> Remove these from defaultExpectedAbsent in '
      'tool/check_coverage_lib.dart.',
    );
  }
}
