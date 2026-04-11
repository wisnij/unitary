import 'package:flutter_test/flutter_test.dart';
import 'package:unitary/core/domain/models/browse_entry.dart';
import 'package:unitary/core/domain/models/dimension.dart';

void main() {
  group('BrowseEntry', () {
    test('primary unit entry', () {
      const entry = BrowseEntry(
        name: 'meter',
        primaryId: 'meter',
        kind: BrowseEntryKind.unit,
        summaryLine: '[primitive unit]',
        dimension: null,
      );

      expect(entry.name, 'meter');
      expect(entry.primaryId, 'meter');
      expect(entry.kind, BrowseEntryKind.unit);
      expect(entry.aliasFor, isNull);
      expect(entry.summaryLine, '[primitive unit]');
      expect(entry.dimension, isNull);
      expect(entry.isAlias, isFalse);
    });

    test('alias entry has non-null aliasFor', () {
      const entry = BrowseEntry(
        name: 'm',
        primaryId: 'meter',
        kind: BrowseEntryKind.unit,
        aliasFor: 'meter',
        summaryLine: '[primitive unit]',
      );

      expect(entry.name, 'm');
      expect(entry.primaryId, 'meter');
      expect(entry.aliasFor, 'meter');
      expect(entry.isAlias, isTrue);
    });

    test('prefix entry', () {
      const entry = BrowseEntry(
        name: 'kilo',
        primaryId: 'kilo',
        kind: BrowseEntryKind.prefix,
        summaryLine: '1000',
      );

      expect(entry.kind, BrowseEntryKind.prefix);
      expect(entry.isAlias, isFalse);
    });

    test('function entry', () {
      const entry = BrowseEntry(
        name: 'tempC',
        primaryId: 'tempC',
        kind: BrowseEntryKind.function,
        summaryLine: '[function]',
      );

      expect(entry.kind, BrowseEntryKind.function);
    });

    test('piecewise function entry', () {
      const entry = BrowseEntry(
        name: 'normaltemp',
        primaryId: 'normaltemp',
        kind: BrowseEntryKind.function,
        summaryLine: '[piecewise linear function]',
      );

      expect(entry.summaryLine, '[piecewise linear function]');
    });

    test('entry with dimension', () {
      final dim = Dimension({'m': 1});
      final entry = BrowseEntry(
        name: 'foot',
        primaryId: 'foot',
        kind: BrowseEntryKind.unit,
        summaryLine: '0.3048 m',
        dimension: dim,
      );

      expect(entry.dimension, dim);
    });

    test('aliasFor equals primaryId for alias entries', () {
      const entry = BrowseEntry(
        name: 'ft',
        primaryId: 'foot',
        kind: BrowseEntryKind.unit,
        aliasFor: 'foot',
        summaryLine: '0.3048 m',
      );

      expect(entry.aliasFor, equals(entry.primaryId));
    });
  });
}
