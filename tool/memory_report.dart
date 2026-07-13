#!/usr/bin/env dart

/// Memory footprint report for Unitary's core domain.
///
/// Usage (compile AOT first — under `dart run` the JIT compiler's own memory
/// swamps the numbers):
///   `dart compile exe tool/memory_report.dart -o build/memory_report`
///   `build/memory_report`
///
/// Builds the core-domain data structures stage by stage — unit repository,
/// fully populated resolution cache, browse catalog, currency descriptors —
/// and reports the process RSS after each stage, with deltas.  Earlier stages'
/// structures stay retained while later ones build, so deltas approximate the
/// incremental footprint of each structure.
library;

import 'dart:io';

import 'package:unitary/core/domain/models/unit_repository.dart';

import 'memory_report_lib.dart';

void main() {
  // AOT executables run in product mode; `dart run` uses the JIT VM, whose
  // in-process compiler inflates RSS far beyond the structures being measured
  // (observed: ~246 MB JIT baseline vs. ~8 MB AOT).
  const isProductMode = bool.fromEnvironment('dart.vm.product');
  if (!isProductMode) {
    stderr.writeln(
      'Warning: running under the JIT VM, where the in-process compiler '
      'dominates RSS.\nFor meaningful numbers, compile AOT first:\n'
      '  dart compile exe tool/memory_report.dart -o build/memory_report '
      '&& build/memory_report\n',
    );
  }

  late UnitRepository repo;

  final stages = [
    MemoryStage(
      name: 'unit repository',
      build: () {
        repo = UnitRepository.withPredefinedUnits();
        return repo;
      },
    ),
    MemoryStage(
      name: 'resolution cache (all units)',
      build: () {
        final resolved = <Object>[];
        for (final unit in repo.allUnits) {
          try {
            resolved.add(repo.resolveUnit(unit));
          } catch (_) {
            // Units with unresolvable definitions are skipped, matching
            // buildBrowseCatalog's tolerance.
          }
        }
        return resolved;
      },
    ),
    MemoryStage(
      name: 'browse catalog',
      build: () => repo.buildBrowseCatalog(),
    ),
    MemoryStage(
      name: 'currency descriptors',
      build: () => repo.buildCurrencyDescriptors(),
    ),
  ];

  final samples = runStages(
    stages,
    readRss: () => ProcessInfo.currentRss,
  );

  stdout.write(formatMemoryReport(samples));
}
