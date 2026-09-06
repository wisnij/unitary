/// Core library for the coverage-threshold checker.
///
/// Contains the LCOV parser, the scope/exclusion filter, the expected-absence
/// allowlist comparison, and the threshold verdict.  The executable wrapper
/// with argument parsing and output formatting lives in `check_coverage.dart`.
library;

import 'dart:convert';
import 'dart:io';

/// Minimum scoped line coverage, as a percentage, enforced in CI.
///
/// Above the ">80% for parser and core domain logic" MVP success criterion:
/// hand-written `lib/` measured 95.88% when this gate was introduced, so 90%
/// leaves room for ordinary churn while still failing on a real regression.
const double defaultMinimumPercent = 90.0;

/// Path prefixes whose files are subject to the threshold.
///
/// All first-party source.  Narrowing this to `lib/core/` would match the MVP
/// criterion's wording, but non-core code is covered at least as well, so
/// narrowing would only shrink what the gate protects.
const List<String> defaultScopes = ['lib/'];

/// Paths excluded from the scope, as exact relative paths or, with a trailing
/// slash, directory prefixes.
///
/// The generated units file is more than twice the size of all hand-written
/// `lib/` code combined and is fully covered as a side effect of unit
/// registration, so including it would let real coverage regress a long way
/// without moving the reported number.  It is named exactly rather than by its
/// directory so that its hand-written sibling `builtin_functions.dart` stays
/// inside the gate.
const List<String> defaultExclusions = [
  'lib/core/domain/data/predefined_units.dart',
];

/// In-scope files expected to be absent from the coverage report.
///
/// A report omits a file either because no test loads it, or because it has no
/// executable lines to instrument — and the report cannot distinguish the two.
/// Rather than guess, every expected absence is pinned here and checked in both
/// directions: an unlisted absence fails, and so does an entry whose file has
/// started reporting coverage or has been deleted.
///
/// Add an entry only for a file that genuinely has nothing to instrument
/// (const-only data, a bare enum, declarations) or that is unreachable from the
/// unit-test run, and say which in its comment.  When a listed file gains
/// executable lines, the check will fail until its entry is removed.
const Set<String> defaultExpectedAbsent = {
  // Application entry point; the unit-test run never loads it.  (The
  // integration suite drives it, but runs separately and is not measured here.)
  'lib/main.dart',
  // A bare enum declaration.
  'lib/shared/top_level_page.dart',
  // Three const declarations.
  'lib/features/about/about_constants.dart',
  // 224 lines of const worksheet template data.
  'lib/features/worksheet/data/predefined_worksheets.dart',
};

/// Default location of the LCOV report written by `flutter test --coverage`.
const String defaultLcovPath = 'coverage/lcov.info';

/// Parses command-line arguments into a report path and a [CoverageConfig].
///
/// Recognises `--lcov`, `--min`, `--scope`, and `--exclude`; `--scope` and
/// `--exclude` may each be repeated.  The two differ deliberately:
///
/// - `--scope` **replaces** the defaults, because narrowing what is measured is
///   the entire reason to pass it.
/// - `--exclude` **adds** to the defaults, so the generated units file can never
///   be dropped from the exclusion list by accident.  It is larger than all
///   hand-written `lib/` code combined and fully covered, so letting it back
///   into the count would silently inflate the reported figure — the exact
///   distortion the default exclusion exists to prevent.
///
/// The expected-absence allowlist is deliberately not exposed as a flag: it is a
/// reviewed, test-covered constant rather than a per-invocation knob.
///
/// Throws [FormatException] on an unknown argument, a flag missing its value,
/// or a `--min` outside 0..100.  `--help` is handled by the executable, since
/// it is an output concern rather than a configuration one.
(String, CoverageConfig) parseArgs(List<String> args) {
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
      exclusions: [...defaultExclusions, ...exclusions],
    ),
  );
}

/// Line-coverage counts for a single file.
class FileCoverage {
  final String path;
  final int covered;
  final int total;

  const FileCoverage({
    required this.path,
    required this.covered,
    required this.total,
  });

  /// Percentage of executable lines covered; a file with no executable lines
  /// counts as fully covered so it cannot drag an aggregate down.
  double get percent => total == 0 ? 100.0 : 100.0 * covered / total;
}

/// What to enforce, and over which files.
class CoverageConfig {
  final double minimumPercent;
  final List<String> scopes;
  final List<String> exclusions;
  final Set<String> expectedAbsent;

  const CoverageConfig({
    this.minimumPercent = defaultMinimumPercent,
    this.scopes = defaultScopes,
    this.exclusions = defaultExclusions,
    this.expectedAbsent = defaultExpectedAbsent,
  });

  /// Whether [path] is excluded, by exact match or directory prefix.
  bool isExcluded(String path) => exclusions.any(
    (e) => e.endsWith('/') ? path.startsWith(e) : path == e,
  );

  /// Whether [path] falls inside the enforced scope.
  bool isInScope(String path) =>
      scopes.any(path.startsWith) && !isExcluded(path);
}

/// The outcome of a coverage check.
class CoverageResult {
  /// In-scope files present in the report, least-covered first.
  final List<FileCoverage> files;

  /// In-scope files on disk that the report omits without an allowlist entry.
  final List<String> unexpectedAbsent;

  /// Allowlist entries whose files now report coverage.
  final List<String> stalePresent;

  /// Allowlist entries whose files no longer exist on disk.
  final List<String> staleMissing;

  final int covered;
  final int total;
  final double minimumPercent;

  /// Set when the check could not run at all (e.g. no report to read).
  final String? error;

  const CoverageResult({
    required this.files,
    required this.unexpectedAbsent,
    required this.stalePresent,
    required this.staleMissing,
    required this.covered,
    required this.total,
    required this.minimumPercent,
    this.error,
  });

  double get percent => total == 0 ? 100.0 : 100.0 * covered / total;

  bool get hasAllowlistMismatch =>
      unexpectedAbsent.isNotEmpty ||
      stalePresent.isNotEmpty ||
      staleMissing.isNotEmpty;

  bool get meetsThreshold => percent >= minimumPercent;

  bool get passed => error == null && !hasAllowlistMismatch && meetsThreshold;
}

/// Parses LCOV text into per-file line counts.
///
/// Only `SF:` and `DA:` records are consulted.  `LF:`/`LH:` summary records are
/// ignored: deriving the totals from the per-line data keeps the result correct
/// for any producer, and self-consistent when the two disagree.  A line number
/// appearing more than once for the same file is counted once, at its highest
/// recorded hit count, so a line covered in any record counts as covered.
Map<String, FileCoverage> parseLcov(String content) {
  // file path -> line number -> highest hit count seen.
  final hits = <String, Map<int, int>>{};
  String? current;

  for (final line in const LineSplitter().convert(content)) {
    if (line.startsWith('SF:')) {
      current = line.substring(3).trim();
      hits.putIfAbsent(current, () => <int, int>{});
    } else if (line.startsWith('DA:') && current != null) {
      final parts = line.substring(3).split(',');
      if (parts.length < 2) {
        continue;
      }
      final lineNo = int.tryParse(parts[0].trim());
      final count = int.tryParse(parts[1].trim());
      if (lineNo == null || count == null) {
        continue;
      }
      final fileHits = hits[current]!;
      final existing = fileHits[lineNo];
      if (existing == null || count > existing) {
        fileHits[lineNo] = count;
      }
    } else if (line.startsWith('end_of_record')) {
      current = null;
    }
  }

  return {
    for (final entry in hits.entries)
      entry.key: FileCoverage(
        path: entry.key,
        covered: entry.value.values.where((c) => c > 0).length,
        total: entry.value.length,
      ),
  };
}

/// Evaluates a parsed report against [config].
///
/// [filesOnDisk] is the set of source paths that exist, used for the
/// expected-absence comparison; it is passed in rather than read here so the
/// logic stays pure and testable.
CoverageResult evaluate({
  required Map<String, FileCoverage> reported,
  required List<String> filesOnDisk,
  required CoverageConfig config,
  String? error,
}) {
  final inScopeReported =
      [
        for (final entry in reported.entries)
          if (config.isInScope(entry.key)) entry.value,
      ]..sort((a, b) {
        final byPercent = a.percent.compareTo(b.percent);
        return byPercent != 0 ? byPercent : a.path.compareTo(b.path);
      });

  var covered = 0;
  var total = 0;
  for (final file in inScopeReported) {
    covered += file.covered;
    total += file.total;
  }

  final onDisk = filesOnDisk.toSet();

  // In-scope files that exist but the report omits, without an allowlist entry.
  final unexpectedAbsent = [
    for (final path in filesOnDisk)
      if (config.isInScope(path) &&
          !reported.containsKey(path) &&
          !config.expectedAbsent.contains(path))
        path,
  ]..sort();

  // Allowlist entries that no longer describe reality.  Only entries inside
  // the configured scope are checked: `isInScope` covers exclusions (so the
  // two mechanisms cannot fight) and also skips entries outside the scope
  // prefixes, which [filesOnDisk] was never asked to enumerate — without that,
  // narrowing the scope would report every allowlisted file elsewhere in the
  // tree as deleted.
  final stalePresent = <String>[];
  final staleMissing = <String>[];
  for (final path in config.expectedAbsent) {
    if (!config.isInScope(path)) {
      continue;
    }
    if (reported.containsKey(path)) {
      stalePresent.add(path);
    } else if (!onDisk.contains(path)) {
      staleMissing.add(path);
    }
  }
  stalePresent.sort();
  staleMissing.sort();

  return CoverageResult(
    files: inScopeReported,
    unexpectedAbsent: unexpectedAbsent,
    stalePresent: stalePresent,
    staleMissing: staleMissing,
    covered: covered,
    total: total,
    minimumPercent: config.minimumPercent,
    error: error,
  );
}

/// Lists first-party `.dart` files under [config]'s scopes, as repo-relative
/// paths with forward slashes, relative to [root] (default: the cwd).
List<String> enumerateSourceFiles(CoverageConfig config, {String root = '.'}) {
  final files = <String>[];
  for (final scope in config.scopes) {
    final dir = Directory(root == '.' ? scope : '$root/$scope');
    if (!dir.existsSync()) {
      continue;
    }
    for (final entity in dir.listSync(recursive: true, followLinks: false)) {
      if (entity is! File || !entity.path.endsWith('.dart')) {
        continue;
      }
      var path = entity.path.replaceAll(r'\', '/');
      final prefix = root == '.' ? '' : '$root/';
      if (prefix.isNotEmpty && path.startsWith(prefix)) {
        path = path.substring(prefix.length);
      }
      if (path.startsWith('./')) {
        path = path.substring(2);
      }
      files.add(path);
    }
  }
  files.sort();
  return files;
}

/// Reads the report at [lcovPath] and evaluates it against [config].
///
/// [filesOnDisk] defaults to enumerating [config]'s scopes from [root]; tests
/// pass an explicit list instead.  A missing report yields a failing result
/// carrying an [CoverageResult.error] rather than throwing.
CoverageResult checkCoverage({
  String lcovPath = defaultLcovPath,
  CoverageConfig config = const CoverageConfig(),
  List<String>? filesOnDisk,
  String root = '.',
}) {
  final file = File(lcovPath);
  if (!file.existsSync()) {
    return evaluate(
      reported: const {},
      filesOnDisk: const [],
      config: config,
      error:
          'Coverage report not found: $lcovPath\n'
          'Run `flutter test --coverage` first.',
    );
  }

  return evaluate(
    reported: parseLcov(file.readAsStringSync()),
    filesOnDisk: filesOnDisk ?? enumerateSourceFiles(config, root: root),
    config: config,
  );
}
