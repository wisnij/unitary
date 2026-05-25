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

    // -------------------------------------------------------------------------
    // Infix matching
    // -------------------------------------------------------------------------

    test(
      'returns infix matches when name contains prefix but does not start with it',
      () {
        // 'ring' is contained in 'ringsize' (prefix match) and in unit names
        // like 'euringsize' and 'jpringsize' (infix matches).
        final names = repo
            .suggestCompletions('ring')
            .map((e) => e.name)
            .toSet();
        expect(names, contains('ringsize'));
        expect(
          names,
          anyElement(
            predicate<String>(
              (n) => n.contains('ring') && !n.startsWith('ring'),
            ),
          ),
        );
      },
    );

    test('prefix matches appear before infix matches', () {
      const q = 'ring';
      final results = repo.suggestCompletions(q);

      final lastPrefixIdx = results.lastIndexWhere(
        (e) => e.name.toLowerCase().startsWith(q),
      );
      final firstInfixIdx = results.indexWhere(
        (e) => !e.name.toLowerCase().startsWith(q),
      );

      if (lastPrefixIdx != -1 && firstInfixIdx != -1) {
        expect(
          lastPrefixIdx,
          lessThan(firstInfixIdx),
          reason: 'all prefix matches must appear before any infix match',
        );
      }
    });

    // -------------------------------------------------------------------------
    // Ranking within tiers
    // -------------------------------------------------------------------------

    test(
      'within prefix matches, primary-ID entries appear before alias-only entries',
      () {
        const q = 'me';
        final results = repo.suggestCompletions(q);
        final prefixResults = results
            .where((e) => e.name.toLowerCase().startsWith(q))
            .toList();

        final primaryIndices = prefixResults
            .asMap()
            .entries
            .where((e) => e.value.isPrimaryId)
            .map((e) => e.key)
            .toList();
        final aliasIndices = prefixResults
            .asMap()
            .entries
            .where((e) => !e.value.isPrimaryId)
            .map((e) => e.key)
            .toList();

        if (primaryIndices.isNotEmpty && aliasIndices.isNotEmpty) {
          expect(primaryIndices.last, lessThan(aliasIndices.first));
        }
      },
    );

    test(
      'within infix matches, primary-ID entries appear before alias-only entries',
      () {
        // Use a query that is guaranteed to produce infix results.
        const q = 'ring';
        final results = repo.suggestCompletions(q);
        final infixResults = results
            .where((e) => !e.name.toLowerCase().startsWith(q))
            .toList();

        final primaryIndices = infixResults
            .asMap()
            .entries
            .where((e) => e.value.isPrimaryId)
            .map((e) => e.key)
            .toList();
        final aliasIndices = infixResults
            .asMap()
            .entries
            .where((e) => !e.value.isPrimaryId)
            .map((e) => e.key)
            .toList();

        if (primaryIndices.isNotEmpty && aliasIndices.isNotEmpty) {
          expect(primaryIndices.last, lessThan(aliasIndices.first));
        }
      },
    );

    test(
      'results within each of the four groups are sorted alphabetically',
      () {
        const q = 'ring';
        final results = repo.suggestCompletions(q);

        List<String> names(bool isPrefix, bool isPrimary) => results
            .where(
              (e) =>
                  e.name.toLowerCase().startsWith(q) == isPrefix &&
                  e.isPrimaryId == isPrimary,
            )
            .map((e) => e.name.toLowerCase())
            .toList();

        for (final group in [
          names(true, true), // prefix primary
          names(true, false), // prefix alias
          names(false, true), // infix primary
          names(false, false), // infix alias
        ]) {
          expect(
            group,
            equals([...group]..sort()),
            reason: 'group should be alphabetically sorted',
          );
        }
      },
    );

    // -------------------------------------------------------------------------
    // Entry kinds
    // -------------------------------------------------------------------------

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
