import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unitary/core/domain/models/browse_entry.dart';
import 'package:unitary/core/domain/models/unit.dart';
import 'package:unitary/core/domain/models/unit_repository.dart';
import 'package:unitary/features/browser/state/browser_provider.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Creates a [ProviderContainer] whose [browserProvider] is backed by [repo].
ProviderContainer _makeContainer(UnitRepository repo) {
  final container = ProviderContainer(
    overrides: [
      browserProvider.overrideWith(() => _TestBrowserNotifier(repo)),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

class _TestBrowserNotifier extends BrowserNotifier {
  _TestBrowserNotifier(this._testRepo);
  final UnitRepository _testRepo;

  @override
  (UnitRepository, List<BrowseEntry>) createData() =>
      (_testRepo, _testRepo.buildBrowseCatalog());
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late UnitRepository repo;

  setUp(() {
    repo = UnitRepository(
      dimensionLabels: {
        'm': 'Length',
        'kg': 'Mass',
      },
    );
    repo.register(const PrimitiveUnit(id: 'm', aliases: ['meter']));
    repo.register(const PrimitiveUnit(id: 'kg'));
    repo.register(
      const DerivedUnit(
        id: 'ft',
        aliases: ['foot', 'feet'],
        expression: '0.3048 m',
      ),
    );
    repo.register(const DerivedUnit(id: 'km', expression: '1000 m'));
    repo.register(
      const DerivedUnit(
        id: 'lb',
        aliases: ['pound'],
        expression: '0.45359237 kg',
      ),
    );
    // A unit whose expression is deliberately broken so resolution fails.
    repo.register(const DerivedUnit(id: 'badUnit', expression: 'unknownXYZ'));
  });

  group('alphabetical index', () {
    test('entries are grouped by first letter', () {
      final container = _makeContainer(repo);
      container
          .read(browserProvider.notifier)
          .setViewMode(
            BrowseViewMode.alphabetical,
          );
      final groups = container.read(browserProvider.notifier).visibleGroups();
      final keys = groups.map((g) => g.$1).toList();
      expect(keys, contains('F')); // foot/feet/ft
      expect(keys, contains('K')); // kg / km
      expect(keys, contains('M')); // m / meter
    });

    test('# group collects non-letter entries', () {
      repo.register(const DerivedUnit(id: '42answer', expression: '42 m'));
      final container = _makeContainer(repo);
      container
          .read(browserProvider.notifier)
          .setViewMode(
            BrowseViewMode.alphabetical,
          );
      final groups = container.read(browserProvider.notifier).visibleGroups();
      final hashGroup = groups.where((g) => g.$1 == '#').toList();
      expect(hashGroup, isNotEmpty);
      expect(
        hashGroup.first.$2.any((e) => e.name == '42answer'),
        isTrue,
      );
    });

    test('# group sorts last', () {
      repo.register(const DerivedUnit(id: '1thing', expression: '1 m'));
      final container = _makeContainer(repo);
      container
          .read(browserProvider.notifier)
          .setViewMode(
            BrowseViewMode.alphabetical,
          );
      final groups = container.read(browserProvider.notifier).visibleGroups();
      expect(groups.last.$1, '#');
    });

    test('entries within each group are sorted case-insensitively', () {
      final container = _makeContainer(repo);
      container
          .read(browserProvider.notifier)
          .setViewMode(
            BrowseViewMode.alphabetical,
          );
      final groups = container.read(browserProvider.notifier).visibleGroups();
      final fGroup = groups.firstWhere((g) => g.$1 == 'F');
      final names = fGroup.$2.map((e) => e.name.toLowerCase()).toList();
      final sorted = [...names]..sort();
      expect(names, sorted);
    });
  });

  group('dimension index', () {
    test('labeled groups appear before unlabeled groups', () {
      final container = _makeContainer(repo);
      // Default view is dimension; all groups start collapsed.
      // Expand all groups so we can see their labels.
      final collapsed = Set<String>.from(
        container.read(browserProvider).collapsedGroups,
      );
      for (final label in collapsed) {
        container.read(browserProvider.notifier).toggleGroup(label);
      }

      final groups = container.read(browserProvider.notifier).visibleGroups();
      final labels = groups.map((g) => g.$1).toList();

      // 'Length' and 'Mass' are labeled; 'badUnit' has null dimension so absent.
      final lengthIdx = labels.indexOf('Length');
      final massIdx = labels.indexOf('Mass');
      expect(lengthIdx, greaterThanOrEqualTo(0));
      expect(massIdx, greaterThanOrEqualTo(0));

      // Any unlabeled groups come after all labeled ones.
      for (var i = 0; i < labels.length; i++) {
        final isLabeled = labels[i] == 'Length' || labels[i] == 'Mass';
        if (!isLabeled) {
          expect(i, greaterThan(lengthIdx));
          expect(i, greaterThan(massIdx));
        }
      }
    });

    test('unresolvable unit is excluded from dimension groups', () {
      final container = _makeContainer(repo);
      // Default is dimension view; expand all groups to inspect entries.
      final collapsed = Set<String>.from(
        container.read(browserProvider).collapsedGroups,
      );
      for (final label in collapsed) {
        container.read(browserProvider.notifier).toggleGroup(label);
      }
      final allEntries = container
          .read(browserProvider.notifier)
          .visibleGroups()
          .expand((g) => g.$2);
      expect(allEntries.any((e) => e.name == 'badUnit'), isFalse);
    });
  });

  group('collapse / expand', () {
    test('alphabetical view starts fully expanded', () {
      final container = _makeContainer(repo);
      container
          .read(browserProvider.notifier)
          .setViewMode(BrowseViewMode.alphabetical);
      expect(container.read(browserProvider).collapsedGroups, isEmpty);
    });

    test('dimension view starts fully collapsed', () {
      final container = _makeContainer(repo);
      // Default is dimension view; all groups should start collapsed.
      final notifier = container.read(browserProvider.notifier);
      final groups = notifier.visibleGroups();
      // All groups exist but have empty entry lists (collapsed).
      for (final (_, entries) in groups) {
        expect(entries, isEmpty);
      }
    });

    test('toggleGroup expands a collapsed group', () {
      final container = _makeContainer(repo);
      container
          .read(browserProvider.notifier)
          .setViewMode(BrowseViewMode.alphabetical);
      container.read(browserProvider.notifier).toggleGroup('M');
      expect(
        container.read(browserProvider).collapsedGroups,
        contains('M'),
      );
      container.read(browserProvider.notifier).toggleGroup('M');
      expect(
        container.read(browserProvider).collapsedGroups,
        isNot(contains('M')),
      );
    });

    test('switching view resets collapse state', () {
      final container = _makeContainer(repo);
      container
          .read(browserProvider.notifier)
          .setViewMode(BrowseViewMode.alphabetical);
      container.read(browserProvider.notifier).toggleGroup('M');
      // Switch to dimension view and back.
      container
          .read(browserProvider.notifier)
          .setViewMode(BrowseViewMode.dimension);
      container
          .read(browserProvider.notifier)
          .setViewMode(BrowseViewMode.alphabetical);
      // Back to alphabetical: collapsed state reset to empty.
      expect(container.read(browserProvider).collapsedGroups, isEmpty);
    });
  });

  group('search filtering', () {
    test('filter shows only matching entries', () {
      final container = _makeContainer(repo);
      container
          .read(browserProvider.notifier)
          .setViewMode(BrowseViewMode.alphabetical);
      container
          .read(browserProvider.notifier)
          .setSearchQuery('zzz_nonexistent');
      final groups = container.read(browserProvider.notifier).visibleGroups();
      expect(groups, isEmpty);
    });

    test('partial match is case-insensitive', () {
      final container = _makeContainer(repo);
      container
          .read(browserProvider.notifier)
          .setViewMode(BrowseViewMode.alphabetical);
      container.read(browserProvider.notifier).setSearchQuery('METER');
      final groups = container.read(browserProvider.notifier).visibleGroups();
      final allNames = groups.expand((g) => g.$2).map((e) => e.name).toList();
      expect(allNames, contains('meter'));
    });

    test('groups with no matching entries are hidden', () {
      final container = _makeContainer(repo);
      container
          .read(browserProvider.notifier)
          .setViewMode(BrowseViewMode.alphabetical);
      container.read(browserProvider.notifier).setSearchQuery('meter');
      final groups = container.read(browserProvider.notifier).visibleGroups();
      final labels = groups.map((g) => g.$1).toList();
      // Only the 'M' group should survive.
      expect(labels, ['M']);
    });

    test('entering search expands all groups', () {
      final container = _makeContainer(repo);
      container
          .read(browserProvider.notifier)
          .setViewMode(BrowseViewMode.alphabetical);
      container.read(browserProvider.notifier).toggleGroup('M');
      expect(
        container.read(browserProvider).collapsedGroups,
        contains('M'),
      );
      container.read(browserProvider.notifier).setSearchQuery('foot');
      expect(container.read(browserProvider).collapsedGroups, isEmpty);
    });

    test('typing more text while searching re-expands groups', () {
      final container = _makeContainer(repo);
      container
          .read(browserProvider.notifier)
          .setViewMode(BrowseViewMode.alphabetical);
      // Enter search mode — all expand.
      container.read(browserProvider.notifier).setSearchQuery('f');
      // Collapse a group while searching.
      container.read(browserProvider.notifier).toggleGroup('F');
      expect(
        container.read(browserProvider).collapsedGroups,
        contains('F'),
      );
      // Refining the query re-expands all groups.
      container.read(browserProvider.notifier).setSearchQuery('fo');
      expect(container.read(browserProvider).collapsedGroups, isEmpty);
    });

    test('groups can be collapsed while search is active', () {
      final container = _makeContainer(repo);
      container
          .read(browserProvider.notifier)
          .setViewMode(BrowseViewMode.alphabetical);
      container.read(browserProvider.notifier).setSearchQuery('f');
      // Collapse the F group while searching.
      container.read(browserProvider.notifier).toggleGroup('F');
      final groups = container.read(browserProvider.notifier).visibleGroups();
      final fGroup = groups.firstWhere(
        (g) => g.$1 == 'F',
        orElse: () => ('', const []),
      );
      expect(fGroup.$2, isEmpty);
    });

    test('collapse state restored after clearing search', () {
      final container = _makeContainer(repo);
      container
          .read(browserProvider.notifier)
          .setViewMode(BrowseViewMode.alphabetical);
      container.read(browserProvider.notifier).toggleGroup('M');
      container.read(browserProvider.notifier).setSearchQuery('meter');
      container.read(browserProvider.notifier).setSearchQuery('');
      final groups = container.read(browserProvider.notifier).visibleGroups();
      final mGroup = groups.firstWhere(
        (g) => g.$1 == 'M',
        orElse: () => ('', const []),
      );
      // 'M' was toggled collapsed; search cleared → back to collapsed.
      expect(mGroup.$2, isEmpty);
    });
  });
}
