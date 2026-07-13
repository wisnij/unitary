import 'package:flutter_test/flutter_test.dart';
import '../../tool/memory_report_lib.dart';

void main() {
  group('runStages', () {
    test('samples a baseline first, then each stage in order', () {
      final rssValues = [1000, 3000, 3500];
      var reads = 0;
      final buildOrder = <String>[];

      final samples = runStages(
        [
          MemoryStage(
            name: 'first',
            build: () {
              buildOrder.add('first');
              return Object();
            },
          ),
          MemoryStage(
            name: 'second',
            build: () {
              buildOrder.add('second');
              return Object();
            },
          ),
        ],
        readRss: () => rssValues[reads++],
      );

      expect(buildOrder, ['first', 'second']);
      expect(samples.map((s) => s.name), ['baseline', 'first', 'second']);
      expect(samples.map((s) => s.rssBytes), [1000, 3000, 3500]);
    });

    test('computes deltas from the previous stage', () {
      final rssValues = [1000, 4000, 3500];
      var reads = 0;

      final samples = runStages(
        [
          MemoryStage(name: 'grow', build: () => Object()),
          MemoryStage(name: 'shrink', build: () => Object()),
        ],
        readRss: () => rssValues[reads++],
      );

      expect(samples[0].deltaBytes, 0, reason: 'baseline has no delta');
      expect(samples[1].deltaBytes, 3000);
      expect(
        samples[2].deltaBytes,
        -500,
        reason: 'deltas can be negative (GC timing)',
      );
    });

    test('baseline RSS is read before any stage builds', () {
      var buildsAtFirstRead = -1;
      var builds = 0;
      var reads = 0;

      runStages(
        [
          MemoryStage(
            name: 'stage',
            build: () {
              builds++;
              return Object();
            },
          ),
        ],
        readRss: () {
          if (reads++ == 0) {
            buildsAtFirstRead = builds;
          }
          return 0;
        },
      );

      expect(buildsAtFirstRead, 0);
    });

    test('retains stage results so they cannot be garbage-collected', () {
      final samples = runStages(
        [
          MemoryStage(name: 'stage', build: () => List.filled(10, 0)),
        ],
        readRss: () => 0,
      );

      expect(samples.byName('stage').retained, isA<List<int>>());
    });
  });

  group('formatBytes', () {
    test('formats small values in kB', () {
      expect(formatBytes(45056), '44.0 kB');
    });

    test('formats megabyte-range values in MB', () {
      expect(formatBytes(12582912), '12.0 MB');
    });

    test('formats negative deltas with a sign', () {
      expect(formatBytes(-1048576), '-1.00 MB');
    });
  });

  group('formatMemoryReport', () {
    test('contains each stage, RSS, delta, and the coarseness caveat', () {
      final samples = runStages(
        [
          MemoryStage(name: 'repo', build: () => Object()),
          MemoryStage(name: 'catalog', build: () => Object()),
        ],
        readRss: () => 100 * 1024 * 1024,
      );

      final report = formatMemoryReport(samples);

      expect(report, contains('baseline'));
      expect(report, contains('repo'));
      expect(report, contains('catalog'));
      expect(report, contains('100 MB'));
      expect(report, contains(rssCaveat));
    });
  });
}

extension on List<StageSample> {
  StageSample byName(String name) => firstWhere((s) => s.name == name);
}
