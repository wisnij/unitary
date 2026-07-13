/// Core library for the memory report script.
///
/// Contains the stage abstraction, staged runner with RSS sampling, and
/// report formatting.  The executable wrapper with the real stage list lives
/// in `memory_report.dart`.
library;

/// Caveat printed with every report: RSS is a coarse measurement.
const String rssCaveat =
    'RSS is a coarse, order-of-magnitude measurement: it includes VM '
    'overhead and is affected by garbage-collection timing.';

/// One build stage of the memory report.
///
/// [build] constructs the structure being measured and returns it; the runner
/// retains the returned object so it cannot be garbage-collected before later
/// stages are sampled.
class MemoryStage {
  final String name;
  final Object? Function() build;

  MemoryStage({required this.name, required this.build});
}

/// RSS and delta observed after one stage completed.
class StageSample {
  final String name;
  final int rssBytes;

  /// Change from the previous stage's RSS (0 for the baseline).
  final int deltaBytes;

  /// The object returned by the stage's build, retained to keep it (and
  /// everything it references) alive for the remaining stages.
  final Object? retained;

  StageSample({
    required this.name,
    required this.rssBytes,
    required this.deltaBytes,
    this.retained,
  });
}

/// Runs [stages] in order, sampling [readRss] before any stage (the
/// `baseline` sample) and after each stage's build completes.
List<StageSample> runStages(
  List<MemoryStage> stages, {
  required int Function() readRss,
}) {
  final samples = <StageSample>[];

  var previousRss = readRss();
  samples.add(
    StageSample(name: 'baseline', rssBytes: previousRss, deltaBytes: 0),
  );

  for (final stage in stages) {
    final retained = stage.build();
    final rss = readRss();
    samples.add(
      StageSample(
        name: stage.name,
        rssBytes: rss,
        deltaBytes: rss - previousRss,
        retained: retained,
      ),
    );
    previousRss = rss;
  }

  return samples;
}

/// Formats a byte count with a human-friendly unit (kB or MB), signed.
String formatBytes(int bytes) {
  final sign = bytes < 0 ? '-' : '';
  final magnitude = bytes.abs();
  if (magnitude < 1024 * 1024) {
    return '$sign${_threeSignificant(magnitude / 1024)} kB';
  }
  return '$sign${_threeSignificant(magnitude / (1024 * 1024))} MB';
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

/// Formats [samples] as an aligned table followed by the RSS caveat.
String formatMemoryReport(List<StageSample> samples) {
  final rows = [
    ['stage', 'rss', 'delta'],
    for (final sample in samples)
      [
        sample.name,
        formatBytes(sample.rssBytes),
        sample.name == 'baseline' ? '' : formatBytes(sample.deltaBytes),
      ],
  ];

  final buffer = StringBuffer(_alignColumns(rows))
    ..writeln()
    ..writeln('Note: $rssCaveat');
  return buffer.toString();
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
