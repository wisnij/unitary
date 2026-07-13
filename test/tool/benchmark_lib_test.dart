import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import '../../tool/benchmark_lib.dart';

void main() {
  group('BenchmarkResult statistics', () {
    test('computes min, median, and mean from an odd number of samples', () {
      final result = BenchmarkResult(name: 'x', samplesUs: [30, 10, 20]);
      expect(result.minUs, 10);
      expect(result.medianUs, 20.0);
      expect(result.meanUs, 20.0);
    });

    test('median of an even number of samples averages the middle two', () {
      final result = BenchmarkResult(name: 'x', samplesUs: [40, 10, 30, 20]);
      expect(result.minUs, 10);
      expect(result.medianUs, 25.0);
      expect(result.meanUs, 25.0);
    });

    test('handles a single sample', () {
      final result = BenchmarkResult(name: 'x', samplesUs: [42]);
      expect(result.minUs, 42);
      expect(result.medianUs, 42.0);
      expect(result.meanUs, 42.0);
      expect(result.iterations, 1);
    });

    test('iterations reflects the sample count', () {
      final result = BenchmarkResult(name: 'x', samplesUs: [1, 2, 3, 4]);
      expect(result.iterations, 4);
    });
  });

  group('runCase', () {
    test(
      'runs the setup factory and body once per warmup and timed iteration',
      () {
        var setupCalls = 0;
        var bodyCalls = 0;
        final benchmarkCase = BenchmarkCase(
          name: 'counting',
          warmup: 2,
          iterations: 3,
          iteration: () {
            setupCalls++;
            return () {
              bodyCalls++;
            };
          },
        );

        final result = runCase(benchmarkCase);

        expect(setupCalls, 5, reason: 'setup runs for warmup + timed');
        expect(bodyCalls, 5, reason: 'body runs for warmup + timed');
        expect(
          result.samplesUs.length,
          3,
          reason: 'only timed iterations produce samples',
        );
        expect(result.name, 'counting');
      },
    );

    test('produces non-negative samples', () {
      final benchmarkCase = BenchmarkCase(
        name: 'busy',
        warmup: 1,
        iterations: 2,
        iteration: () {
          return () {
            var sum = 0;
            for (var i = 0; i < 1000; i++) {
              sum += i;
            }
            benchmarkSink = sum;
          };
        },
      );

      final result = runCase(benchmarkCase);

      expect(result.samplesUs, everyElement(greaterThanOrEqualTo(0)));
    });
  });

  group('filterCases', () {
    final cases = [
      BenchmarkCase(name: 'resolve-all-cold', iteration: _noopIteration),
      BenchmarkCase(name: 'resolve-all-warm', iteration: _noopIteration),
      BenchmarkCase(name: 'browse-catalog', iteration: _noopIteration),
    ];

    test('null filter returns all cases', () {
      expect(filterCases(cases, null), hasLength(3));
    });

    test('substring filter keeps only matching case names', () {
      final filtered = filterCases(cases, 'resolve');
      expect(filtered.map((c) => c.name), [
        'resolve-all-cold',
        'resolve-all-warm',
      ]);
    });

    test('non-matching filter returns an empty list', () {
      expect(filterCases(cases, 'nonexistent'), isEmpty);
    });
  });

  group('JSON serialization', () {
    final results = [
      BenchmarkResult(name: 'alpha', samplesUs: [10, 20, 30]),
      BenchmarkResult(name: 'beta', samplesUs: [100]),
    ];

    test('round-trips names and samples', () {
      final json = resultsToJson(results);
      final parsed = resultsFromJson(json);
      expect(parsed, hasLength(2));
      expect(parsed[0].name, 'alpha');
      expect(parsed[0].samplesUs, [10, 20, 30]);
      expect(parsed[1].name, 'beta');
      expect(parsed[1].samplesUs, [100]);
    });

    test('includes environment metadata', () {
      final decoded =
          jsonDecode(resultsToJson(results)) as Map<String, Object?>;
      expect(decoded['timestamp'], isA<String>());
      expect(decoded['dartVersion'], isA<String>());
      expect(decoded['operatingSystem'], isA<String>());
    });

    test('throws FormatException on malformed input', () {
      expect(() => resultsFromJson('{"nope": true}'), throwsFormatException);
      expect(() => resultsFromJson('not json'), throwsFormatException);
    });
  });

  group('compareToBaseline', () {
    test('matches cases by name and computes the change fraction', () {
      final current = [
        BenchmarkResult(name: 'a', samplesUs: [150, 150, 150]),
      ];
      final baseline = [
        BenchmarkResult(name: 'a', samplesUs: [100, 100, 100]),
      ];

      final comparison = compareToBaseline(current, baseline);

      expect(comparison.matched, hasLength(1));
      expect(comparison.matched[0].name, 'a');
      expect(comparison.matched[0].changeFraction, closeTo(0.5, 1e-9));
      expect(comparison.unmatchedCurrent, isEmpty);
      expect(comparison.unmatchedBaseline, isEmpty);
    });

    test('reports cases missing from the baseline and vice versa', () {
      final current = [
        BenchmarkResult(name: 'shared', samplesUs: [10]),
        BenchmarkResult(name: 'new-case', samplesUs: [10]),
      ];
      final baseline = [
        BenchmarkResult(name: 'shared', samplesUs: [10]),
        BenchmarkResult(name: 'removed-case', samplesUs: [10]),
      ];

      final comparison = compareToBaseline(current, baseline);

      expect(comparison.matched.map((m) => m.name), ['shared']);
      expect(comparison.unmatchedCurrent, ['new-case']);
      expect(comparison.unmatchedBaseline, ['removed-case']);
    });

    test('negative change fraction for an improvement', () {
      final current = [
        BenchmarkResult(name: 'a', samplesUs: [50, 50]),
      ];
      final baseline = [
        BenchmarkResult(name: 'a', samplesUs: [100, 100]),
      ];

      final comparison = compareToBaseline(current, baseline);

      expect(comparison.matched[0].changeFraction, closeTo(-0.5, 1e-9));
    });
  });

  group('formatDurationUs', () {
    test('formats sub-millisecond values in microseconds', () {
      expect(formatDurationUs(870), '870 µs');
    });

    test('formats millisecond-range values in milliseconds', () {
      expect(formatDurationUs(12345), '12.3 ms');
    });

    test('formats second-range values in seconds', () {
      expect(formatDurationUs(1234567), '1.23 s');
    });
  });

  group('formatResultsTable', () {
    test('contains each case name, iteration count, and formatted times', () {
      final results = [
        BenchmarkResult(name: 'alpha', samplesUs: [500, 600, 700]),
        BenchmarkResult(name: 'beta', samplesUs: [2000000]),
      ];

      final table = formatResultsTable(results);

      expect(table, contains('alpha'));
      expect(table, contains('beta'));
      expect(table, contains('600 µs'));
      expect(table, contains('2.00 s'));
      expect(table, contains('3'));
    });
  });

  group('formatComparisonTable', () {
    BaselineComparison comparisonWithChange(double fraction) {
      const baselineUs = 1000;
      final currentUs = (baselineUs * (1 + fraction)).round();
      return compareToBaseline(
        [
          BenchmarkResult(name: 'a', samplesUs: [currentUs]),
        ],
        [
          BenchmarkResult(name: 'a', samplesUs: [baselineUs]),
        ],
      );
    }

    test('flags a regression beyond the threshold', () {
      final table = formatComparisonTable(comparisonWithChange(0.5));
      expect(table, contains('REGRESSION'));
      expect(table, contains('+50'));
    });

    test('flags an improvement beyond the threshold', () {
      final table = formatComparisonTable(comparisonWithChange(-0.5));
      expect(table, contains('improvement'));
      expect(table, contains('-50'));
    });

    test('does not flag changes within the threshold', () {
      final table = formatComparisonTable(comparisonWithChange(0.1));
      expect(table, isNot(contains('REGRESSION')));
      expect(table, isNot(contains('improvement')));
    });

    test('respects a custom threshold', () {
      final table = formatComparisonTable(
        comparisonWithChange(0.1),
        threshold: 0.05,
      );
      expect(table, contains('REGRESSION'));
    });

    test('lists unmatched cases', () {
      final comparison = compareToBaseline(
        [
          BenchmarkResult(name: 'new-case', samplesUs: [10]),
        ],
        [
          BenchmarkResult(name: 'removed-case', samplesUs: [10]),
        ],
      );

      final table = formatComparisonTable(comparison);

      expect(table, contains('new-case'));
      expect(table, contains('removed-case'));
      expect(table, contains('not in baseline'));
      expect(table, contains('not in this run'));
    });

    test('includes the machine-dependence caveat', () {
      final table = formatComparisonTable(comparisonWithChange(0.0));
      expect(table, contains(machineDependenceCaveat));
    });
  });
}

BenchmarkBody _noopIteration() {
  return () {};
}
