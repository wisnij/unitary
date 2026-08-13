import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/check_coverage_lib.dart';

/// Builds a synthetic LCOV record for [path] from `line: hitCount` pairs.
///
/// Emits `LF:`/`LH:` consistent with the `DA:` lines unless [lf]/[lh] are
/// given, which lets a test deliberately contradict them.
String lcovRecord(
  String path,
  Map<int, int> lines, {
  int? lf,
  int? lh,
  List<String> extraDa = const [],
}) {
  final buf = StringBuffer('SF:$path\n');
  lines.forEach((line, count) => buf.writeln('DA:$line,$count'));
  for (final da in extraDa) {
    buf.writeln('DA:$da');
  }
  buf.writeln('LF:${lf ?? lines.length}');
  buf.writeln('LH:${lh ?? lines.values.where((c) => c > 0).length}');
  buf.writeln('end_of_record');
  return buf.toString();
}

/// Writes [content] to a real `lcov.info` in a fresh temporary directory and
/// returns its path, for the tests that must exercise the file-reading path.
String writeTempLcov(String content) {
  final dir = Directory.systemTemp.createTempSync('check_coverage_test');
  addTearDown(() => dir.deleteSync(recursive: true));
  final file = File('${dir.path}/lcov.info')..writeAsStringSync(content);
  return file.path;
}

/// A config with the production defaults but no allowlist, for tests that are
/// not about the allowlist.
CoverageConfig configWith({
  double minimumPercent = 90.0,
  List<String> scopes = const ['lib/'],
  List<String> exclusions = const [
    'lib/core/domain/data/predefined_units.dart',
  ],
  Set<String> expectedAbsent = const {},
}) => CoverageConfig(
  minimumPercent: minimumPercent,
  scopes: scopes,
  exclusions: exclusions,
  expectedAbsent: expectedAbsent,
);

void main() {
  group('parseLcov', () {
    test('counts covered and total lines from DA records', () {
      final parsed = parseLcov(
        lcovRecord('lib/a.dart', {1: 3, 2: 0, 3: 1, 4: 0}),
      );

      expect(parsed['lib/a.dart']!.covered, 2);
      expect(parsed['lib/a.dart']!.total, 4);
      expect(parsed['lib/a.dart']!.percent, 50.0);
    });

    test('treats a zero hit count as uncovered', () {
      final parsed = parseLcov(lcovRecord('lib/a.dart', {1: 0, 2: 0}));

      expect(parsed['lib/a.dart']!.covered, 0);
      expect(parsed['lib/a.dart']!.total, 2);
    });

    test('parses multiple records in one report', () {
      final parsed = parseLcov(
        lcovRecord('lib/a.dart', {1: 1}) + lcovRecord('lib/b.dart', {1: 0}),
      );

      expect(parsed.keys, containsAll(['lib/a.dart', 'lib/b.dart']));
      expect(parsed['lib/a.dart']!.covered, 1);
      expect(parsed['lib/b.dart']!.covered, 0);
    });

    test('a record with no DA lines contributes no tracked lines', () {
      final parsed = parseLcov('SF:lib/a.dart\nLF:0\nLH:0\nend_of_record\n');

      expect(parsed['lib/a.dart']!.total, 0);
      expect(parsed['lib/a.dart']!.covered, 0);
    });

    test('ignores an empty report', () {
      expect(parseLcov(''), isEmpty);
    });

    group('duplicate line records', () {
      test('merges a repeated line, keeping the highest count', () {
        // Line 1 appears twice: once uncovered, once covered.
        final parsed = parseLcov(
          lcovRecord('lib/a.dart', {1: 0, 2: 1}, extraDa: ['1,5']),
        );

        expect(parsed['lib/a.dart']!.total, 2, reason: 'line 1 counted once');
        expect(parsed['lib/a.dart']!.covered, 2, reason: 'line 1 is covered');
      });

      test('merges across two records for the same file', () {
        final parsed = parseLcov(
          lcovRecord('lib/a.dart', {1: 0, 2: 0}) +
              lcovRecord('lib/a.dart', {1: 4, 3: 1}),
        );

        expect(parsed['lib/a.dart']!.total, 3, reason: 'lines 1, 2, 3');
        expect(parsed['lib/a.dart']!.covered, 2, reason: 'lines 1 and 3');
      });
    });

    test('ignores LF/LH values that contradict the DA records', () {
      // Claims 100/100 in the summary, but the DA lines say 1 of 2.
      final parsed = parseLcov(
        lcovRecord('lib/a.dart', {1: 1, 2: 0}, lf: 100, lh: 100),
      );

      expect(parsed['lib/a.dart']!.total, 2);
      expect(parsed['lib/a.dart']!.covered, 1);
    });
  });

  group('scope', () {
    test('counts core, features, and shared alike', () {
      final result = evaluate(
        reported: parseLcov(
          lcovRecord('lib/core/domain/models/quantity.dart', {1: 1, 2: 0}) +
              lcovRecord('lib/features/freeform/state/x.dart', {1: 1, 2: 1}) +
              lcovRecord('lib/shared/utils/y.dart', {1: 1, 2: 1}),
        ),
        filesOnDisk: const [
          'lib/core/domain/models/quantity.dart',
          'lib/features/freeform/state/x.dart',
          'lib/shared/utils/y.dart',
        ],
        config: configWith(),
      );

      expect(result.total, 6);
      expect(result.covered, 5);
      expect(result.files.map((f) => f.path), hasLength(3));
    });

    test('ignores files outside lib/', () {
      final result = evaluate(
        reported: parseLcov(
          lcovRecord('lib/a.dart', {1: 1}) +
              lcovRecord('tool/benchmark_lib.dart', {1: 0, 2: 0}) +
              lcovRecord('test/foo_test.dart', {1: 0, 2: 0}),
        ),
        filesOnDisk: const ['lib/a.dart'],
        config: configWith(),
      );

      expect(result.total, 1, reason: 'only lib/a.dart is in scope');
      expect(result.covered, 1);
      expect(result.percent, 100.0);
    });
  });

  group('exclusions', () {
    test(
      'drops the generated units file from the totals and the file list',
      () {
        final result = evaluate(
          reported: parseLcov(
            lcovRecord('lib/core/domain/data/predefined_units.dart', {
                  1: 1,
                  2: 1,
                  3: 1,
                }) +
                lcovRecord('lib/core/domain/models/unit.dart', {1: 1, 2: 0}),
          ),
          filesOnDisk: const [
            'lib/core/domain/data/predefined_units.dart',
            'lib/core/domain/models/unit.dart',
          ],
          config: configWith(),
        );

        expect(result.total, 2, reason: 'generated file excluded');
        expect(result.covered, 1);
        expect(
          result.files.map((f) => f.path),
          isNot(contains('lib/core/domain/data/predefined_units.dart')),
        );
      },
    );

    test('retains the hand-written sibling of the generated file', () {
      final result = evaluate(
        reported: parseLcov(
          lcovRecord('lib/core/domain/data/builtin_functions.dart', {
            1: 1,
            2: 1,
          }),
        ),
        filesOnDisk: const ['lib/core/domain/data/builtin_functions.dart'],
        config: configWith(),
      );

      expect(
        result.files.map((f) => f.path),
        contains('lib/core/domain/data/builtin_functions.dart'),
      );
      expect(result.total, 2);
    });

    test('a trailing-slash exclusion drops a whole directory', () {
      final result = evaluate(
        reported: parseLcov(
          lcovRecord('lib/gen/a.dart', {1: 1}) +
              lcovRecord('lib/gen/nested/b.dart', {1: 1}) +
              lcovRecord('lib/c.dart', {1: 0}),
        ),
        filesOnDisk: const [
          'lib/gen/a.dart',
          'lib/gen/nested/b.dart',
          'lib/c.dart',
        ],
        config: configWith(exclusions: const ['lib/gen/']),
      );

      expect(result.total, 1, reason: 'only lib/c.dart survives');
      expect(result.covered, 0);
    });
  });

  group('allowlist', () {
    test('unexpected absence fails and names the file', () {
      final result = evaluate(
        reported: parseLcov(lcovRecord('lib/a.dart', {1: 1, 2: 1})),
        filesOnDisk: const ['lib/a.dart', 'lib/untested.dart'],
        config: configWith(),
      );

      expect(result.passed, isFalse);
      expect(result.unexpectedAbsent, ['lib/untested.dart']);
      expect(result.percent, 100.0, reason: 'the percentage itself is fine');
    });

    test('an allowlisted file present in the report fails as stale', () {
      final result = evaluate(
        reported: parseLcov(
          lcovRecord('lib/a.dart', {1: 1}) +
              lcovRecord('lib/decl.dart', {1: 1}),
        ),
        filesOnDisk: const ['lib/a.dart', 'lib/decl.dart'],
        config: configWith(expectedAbsent: const {'lib/decl.dart'}),
      );

      expect(result.passed, isFalse);
      expect(result.stalePresent, ['lib/decl.dart']);
      expect(result.staleMissing, isEmpty);
    });

    test('an allowlist entry with no file on disk fails as stale', () {
      final result = evaluate(
        reported: parseLcov(lcovRecord('lib/a.dart', {1: 1})),
        filesOnDisk: const ['lib/a.dart'],
        config: configWith(expectedAbsent: const {'lib/deleted.dart'}),
      );

      expect(result.passed, isFalse);
      expect(result.staleMissing, ['lib/deleted.dart']);
      expect(result.stalePresent, isEmpty);
      expect(result.unexpectedAbsent, isEmpty);
    });

    test('an expected absence is accepted and contributes 0/0', () {
      // A low minimum so this test isolates the allowlist from the threshold.
      final withAllowlisted = evaluate(
        reported: parseLcov(lcovRecord('lib/a.dart', {1: 1, 2: 0})),
        filesOnDisk: const ['lib/a.dart', 'lib/decl.dart'],
        config: configWith(
          minimumPercent: 50.0,
          expectedAbsent: const {'lib/decl.dart'},
        ),
      );
      final withoutIt = evaluate(
        reported: parseLcov(lcovRecord('lib/a.dart', {1: 1, 2: 0})),
        filesOnDisk: const ['lib/a.dart'],
        config: configWith(minimumPercent: 50.0),
      );

      expect(withAllowlisted.passed, isTrue);
      expect(withAllowlisted.unexpectedAbsent, isEmpty);
      // 0/0, not 0/1: the totals and percentage are untouched.
      expect(withAllowlisted.total, withoutIt.total);
      expect(withAllowlisted.covered, withoutIt.covered);
      expect(withAllowlisted.percent, withoutIt.percent);
    });

    test('an excluded file absent from the report is exempt', () {
      final result = evaluate(
        reported: parseLcov(lcovRecord('lib/a.dart', {1: 1})),
        filesOnDisk: const [
          'lib/a.dart',
          'lib/core/domain/data/predefined_units.dart',
        ],
        config: configWith(),
      );

      expect(result.passed, isTrue);
      expect(
        result.unexpectedAbsent,
        isEmpty,
        reason: 'exclusion wins over the absence check',
      );
      expect(result.staleMissing, isEmpty);
    });
  });

  group('threshold', () {
    test('passes above the minimum', () {
      final result = evaluate(
        reported: parseLcov(lcovRecord('lib/a.dart', {1: 1, 2: 1, 3: 1, 4: 0})),
        filesOnDisk: const ['lib/a.dart'],
        config: configWith(minimumPercent: 70.0),
      );

      expect(result.percent, 75.0);
      expect(result.passed, isTrue);
    });

    test('passes exactly at the minimum', () {
      final result = evaluate(
        reported: parseLcov(lcovRecord('lib/a.dart', {1: 1, 2: 1, 3: 1, 4: 0})),
        filesOnDisk: const ['lib/a.dart'],
        config: configWith(minimumPercent: 75.0),
      );

      expect(result.percent, 75.0);
      expect(result.passed, isTrue, reason: 'the bound is inclusive');
    });

    test('fails below the minimum', () {
      final result = evaluate(
        reported: parseLcov(lcovRecord('lib/a.dart', {1: 1, 2: 1, 3: 1, 4: 0})),
        filesOnDisk: const ['lib/a.dart'],
        config: configWith(minimumPercent: 80.0),
      );

      expect(result.percent, 75.0);
      expect(result.passed, isFalse);
    });

    test('orders the per-file breakdown least-covered first', () {
      final result = evaluate(
        reported: parseLcov(
          lcovRecord('lib/good.dart', {1: 1, 2: 1}) +
              lcovRecord('lib/bad.dart', {1: 0, 2: 0}) +
              lcovRecord('lib/mid.dart', {1: 1, 2: 0}),
        ),
        filesOnDisk: const ['lib/good.dart', 'lib/bad.dart', 'lib/mid.dart'],
        config: configWith(minimumPercent: 0.0),
      );

      expect(result.files.map((f) => f.path), [
        'lib/bad.dart',
        'lib/mid.dart',
        'lib/good.dart',
      ]);
    });
  });

  group('checkCoverage (file-reading path)', () {
    test('reads a report from disk and evaluates it', () {
      final path = writeTempLcov(lcovRecord('lib/a.dart', {1: 1, 2: 1}));

      final result = checkCoverage(
        lcovPath: path,
        config: configWith(),
        filesOnDisk: const ['lib/a.dart'],
      );

      expect(result.error, isNull);
      expect(result.percent, 100.0);
      expect(result.passed, isTrue);
    });

    test('fails with a clear error naming a missing report', () {
      final result = checkCoverage(
        lcovPath: '/nonexistent/dir/lcov.info',
        config: configWith(),
        filesOnDisk: const [],
      );

      expect(result.passed, isFalse);
      expect(result.error, isNotNull);
      expect(result.error, contains('/nonexistent/dir/lcov.info'));
    });
  });

  group('production defaults', () {
    test('enforce at least the 80% MVP criterion', () {
      expect(defaultMinimumPercent, greaterThanOrEqualTo(80.0));
    });

    test('scope all of lib/ and exclude the generated units file', () {
      expect(defaultScopes, ['lib/']);
      expect(
        defaultExclusions,
        contains(
          'lib/core/domain/data/predefined_units.dart',
        ),
      );
    });

    test('allowlist every file expected to be absent from the report', () {
      expect(defaultExpectedAbsent, {
        'lib/main.dart',
        'lib/shared/top_level_page.dart',
        'lib/features/about/about_constants.dart',
        'lib/features/worksheet/data/predefined_worksheets.dart',
      });
    });
  });
}
