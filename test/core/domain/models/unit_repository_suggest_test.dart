import 'package:flutter_test/flutter_test.dart';

import 'package:unitary/core/domain/models/completion_entry.dart';
import 'package:unitary/core/domain/models/unit_repository.dart';

void main() {
  late UnitRepository repo;

  setUp(() {
    repo = UnitRepository.withPredefinedUnits();
  });

  group('UnitRepository.suggestCompletions', () {
    test('empty prefix returns empty list', () {
      expect(repo.suggestCompletions(''), isEmpty);
    });

    test('no matches returns empty list', () {
      expect(repo.suggestCompletions('zzzzzzz'), isEmpty);
    });

    test('returns unit aliases that start with prefix', () {
      // "kilogram" is an alias for the SI base unit "kg".
      final names = repo.suggestCompletions('kilo').map((e) => e.name).toSet();
      expect(names, contains('kilogram'));
    });

    test('returns prefix primary IDs that start with prefix', () {
      // "kilo" is a registered prefix primary ID.
      final names = repo.suggestCompletions('kil').map((e) => e.name).toSet();
      expect(names, contains('kilo'));
    });

    test('returns function primary IDs that start with prefix', () {
      final names = repo.suggestCompletions('temp').map((e) => e.name).toSet();
      expect(names, contains('tempC'));
      expect(names, contains('tempF'));
      expect(names, contains('tempK'));
    });

    test('matching is case-insensitive', () {
      final lower = repo.suggestCompletions('meter').map((e) => e.name).toSet();
      final upper = repo.suggestCompletions('METER').map((e) => e.name).toSet();
      expect(lower, equals(upper));
      expect(lower, isNotEmpty);
    });

    test('primary-ID matches appear before alias-only matches', () {
      final results = repo.suggestCompletions('me');
      final primaryIndices = results
          .asMap()
          .entries
          .where((e) => e.value.isPrimaryId)
          .map((e) => e.key)
          .toList();
      final aliasIndices = results
          .asMap()
          .entries
          .where((e) => !e.value.isPrimaryId)
          .map((e) => e.key)
          .toList();
      if (primaryIndices.isNotEmpty && aliasIndices.isNotEmpty) {
        expect(primaryIndices.last, lessThan(aliasIndices.first));
      }
    });

    test('results within each group are sorted alphabetically', () {
      final results = repo.suggestCompletions('kil');
      final primaryNames = results
          .where((e) => e.isPrimaryId)
          .map((e) => e.name.toLowerCase())
          .toList();
      final aliasNames = results
          .where((e) => !e.isPrimaryId)
          .map((e) => e.name.toLowerCase())
          .toList();
      expect(primaryNames, equals([...primaryNames]..sort()));
      expect(aliasNames, equals([...aliasNames]..sort()));
    });

    test('unit primary ID entry has kind == unit', () {
      // "kg" is the primary ID for the SI kilogram base unit.
      final results = repo.suggestCompletions('kg');
      final kgEntry = results.where((e) => e.name == 'kg' && e.isPrimaryId);
      expect(kgEntry, isNotEmpty);
      expect(kgEntry.first.entryKind, equals(CompletionEntryKind.unit));
    });

    test('prefix entries have kind == prefix', () {
      final results = repo.suggestCompletions('kilo');
      final prefixEntries = results.where(
        (e) => e.name == 'kilo' && e.isPrimaryId,
      );
      expect(prefixEntries, isNotEmpty);
      expect(
        prefixEntries.first.entryKind,
        equals(CompletionEntryKind.prefix),
      );
    });

    test('function entries have kind == function', () {
      final results = repo.suggestCompletions('tempC');
      final funcEntries = results.where(
        (e) => e.name == 'tempC' && e.isPrimaryId,
      );
      expect(funcEntries, isNotEmpty);
      expect(
        funcEntries.first.entryKind,
        equals(CompletionEntryKind.function),
      );
    });

    test('limit enforced', () {
      // 'a' matches a large number of entries.
      final results = repo.suggestCompletions('a', limit: 5);
      expect(results.length, lessThanOrEqualTo(5));
    });

    test('alias entries have isPrimaryId == false', () {
      // "kilogram" is an alias for the primary ID "kg".
      final results = repo.suggestCompletions('kilogram');
      final kgAliasEntries = results.where((e) => e.name == 'kilogram');
      expect(kgAliasEntries, isNotEmpty);
      expect(kgAliasEntries.first.isPrimaryId, isFalse);
    });
  });
}
