import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/domain/models/browse_entry.dart';
import '../../../core/domain/models/dimension.dart';
import '../../../core/domain/models/unit_repository.dart';

/// Whether the browse list is grouped alphabetically or by dimension.
enum BrowseViewMode { alphabetical, dimension }

/// Immutable UI state for the browser screen.
class BrowserState {
  /// Current view mode.
  final BrowseViewMode viewMode;

  /// Current search query; empty string means no filter.
  final String searchQuery;

  /// Whether the search bar is visible.
  final bool searchVisible;

  /// Labels of groups that are currently collapsed.
  ///
  /// When [searchQuery] is non-empty this set is ignored and all groups render
  /// as expanded; the set is preserved so that collapse state is restored when
  /// the search is cleared.
  final Set<String> collapsedGroups;

  const BrowserState({
    required this.viewMode,
    required this.searchQuery,
    required this.searchVisible,
    required this.collapsedGroups,
  });

  BrowserState copyWith({
    BrowseViewMode? viewMode,
    String? searchQuery,
    bool? searchVisible,
    Set<String>? collapsedGroups,
  }) {
    return BrowserState(
      viewMode: viewMode ?? this.viewMode,
      searchQuery: searchQuery ?? this.searchQuery,
      searchVisible: searchVisible ?? this.searchVisible,
      collapsedGroups: collapsedGroups ?? this.collapsedGroups,
    );
  }
}

/// Ordered groups: a list of (groupLabel, entries) pairs.
typedef BrowseGroups = List<(String, List<BrowseEntry>)>;

/// Non-autoDispose provider: browse state persists across navigation.
final browserProvider = NotifierProvider<BrowserNotifier, BrowserState>(
  BrowserNotifier.new,
);

/// Manages the unit browser catalog, grouping, filtering, and collapse state.
class BrowserNotifier extends Notifier<BrowserState> {
  late List<BrowseEntry> _catalog;
  late UnitRepository _repo;

  /// Alphabetical index: sorted list of (letter, entries) pairs.
  /// Built eagerly in [build].
  late BrowseGroups _alphabeticalIndex;

  /// Dimension index: built lazily on first switch to dimension view.
  BrowseGroups? _dimensionIndex;

  /// Snapshot of [BrowserState.collapsedGroups] taken when search mode is
  /// entered (query transitions from empty to non-empty).  Restored when the
  /// query is cleared.
  Set<String>? _preSearchCollapsedGroups;

  /// Returns the [UnitRepository] and catalog to use.
  ///
  /// Override in tests to inject a custom repository.
  (UnitRepository, List<BrowseEntry>) createData() {
    final repo = UnitRepository.withPredefinedUnits();
    return (repo, repo.buildBrowseCatalog());
  }

  @override
  BrowserState build() {
    final (repoResult, catalogResult) = createData();
    _repo = repoResult;
    _catalog = catalogResult;
    _alphabeticalIndex = buildAlphabeticalIndex(_catalog);

    // Build the dimension index eagerly: build() is already called lazily
    // (on first provider read, i.e. when the user opens the browser), so
    // there is no app-startup cost.  Starting in dimension view means we
    // need the index and its group labels immediately for collapsedGroups.
    _dimensionIndex = _buildDimensionIndex(_catalog, _repo.dimensionLabels);
    final allDimensionLabels = _dimensionIndex!.map((g) => g.$1).toSet();

    return BrowserState(
      viewMode: BrowseViewMode.dimension,
      searchQuery: '',
      searchVisible: false,
      collapsedGroups: allDimensionLabels,
    );
  }

  // ---------------------------------------------------------------------------
  // Public actions
  // ---------------------------------------------------------------------------

  /// Switches between [BrowseViewMode.alphabetical] and
  /// [BrowseViewMode.dimension].
  ///
  /// Resets [BrowserState.collapsedGroups] to each view's default:
  /// - Alphabetical: all groups collapsed (full label set).
  /// - Dimension: all groups collapsed (full label set); triggers lazy build
  ///   of the dimension index on first switch.
  void setViewMode(BrowseViewMode mode) {
    if (mode == state.viewMode) {
      return;
    }

    if (mode == BrowseViewMode.alphabetical) {
      final allLabels = _alphabeticalIndex.map((g) => g.$1).toSet();
      state = state.copyWith(
        viewMode: mode,
        collapsedGroups: allLabels,
      );
    } else {
      _ensureDimensionIndex();
      final allLabels = _dimensionIndex?.map((g) => g.$1).toSet() ?? {};
      state = state.copyWith(
        viewMode: mode,
        collapsedGroups: allLabels,
      );
    }
  }

  /// Toggles the collapsed state of [groupLabel].
  void toggleGroup(String groupLabel) {
    final current = Set<String>.from(state.collapsedGroups);
    if (current.contains(groupLabel)) {
      current.remove(groupLabel);
    } else {
      current.add(groupLabel);
    }
    state = state.copyWith(collapsedGroups: current);
  }

  /// Expands all groups in the current view by clearing the collapsed set.
  void expandAll() {
    state = state.copyWith(collapsedGroups: const {});
  }

  /// Collapses all groups in the current view.
  void collapseAll() {
    final index = state.viewMode == BrowseViewMode.alphabetical
        ? _alphabeticalIndex
        : (_dimensionIndex ?? const []);
    final allLabels = index.map((g) => g.$1).toSet();
    state = state.copyWith(collapsedGroups: allLabels);
  }

  /// Toggles the search bar visibility.  Hides the bar and clears the query
  /// when currently visible.
  void toggleSearch() {
    if (state.searchVisible) {
      setSearchQuery('');
      state = state.copyWith(searchVisible: false);
    } else {
      state = state.copyWith(searchVisible: true);
    }
  }

  /// Updates the search query.
  ///
  /// When the query transitions from empty to non-empty, all groups are
  /// expanded and the previous [BrowserState.collapsedGroups] is saved.  When
  /// the query is cleared, the saved state is restored.  While a non-empty
  /// query is active, [toggleGroup] works normally so the user can still
  /// collapse individual groups.
  void setSearchQuery(String query) {
    final wasEmpty = state.searchQuery.isEmpty;
    final nowEmpty = query.isEmpty;

    if (!nowEmpty) {
      // Any non-empty query: expand all groups.  Save the pre-search collapse
      // state on the first entry (empty → non-empty transition).
      if (wasEmpty) {
        _preSearchCollapsedGroups = Set.unmodifiable(state.collapsedGroups);
      }
      state = state.copyWith(searchQuery: query, collapsedGroups: const {});
    } else if (!wasEmpty) {
      // Leaving search: restore saved collapse state.
      final restored = _preSearchCollapsedGroups ?? const <String>{};
      _preSearchCollapsedGroups = null;
      state = state.copyWith(searchQuery: query, collapsedGroups: restored);
    } else {
      state = state.copyWith(searchQuery: query);
    }
  }

  // ---------------------------------------------------------------------------
  // Computed view
  // ---------------------------------------------------------------------------

  /// Returns the groups to display given the current [BrowserState].
  ///
  /// Each element is a `(groupLabel, entries)` pair.
  BrowseGroups visibleGroups() {
    final index = state.viewMode == BrowseViewMode.alphabetical
        ? _alphabeticalIndex
        : (_dimensionIndex ?? const []);

    final query = state.searchQuery.toLowerCase();
    final filtering = query.isNotEmpty;

    final result = <(String, List<BrowseEntry>)>[];
    for (final (label, entries) in index) {
      final filtered = filtering
          ? entries.where((e) => e.name.toLowerCase().contains(query)).toList()
          : entries;

      if (filtered.isEmpty) {
        continue;
      }

      final collapsed = state.collapsedGroups.contains(label);
      result.add((label, collapsed ? const [] : filtered));
    }
    return result;
  }

  // ---------------------------------------------------------------------------
  // Index builders
  // ---------------------------------------------------------------------------

  /// Exposed for testing.
  static BrowseGroups buildAlphabeticalIndex(List<BrowseEntry> catalog) {
    final map = <String, List<BrowseEntry>>{};

    for (final entry in catalog) {
      final first = entry.name.isEmpty ? '#' : entry.name[0].toUpperCase();
      final key = RegExp('[A-Z]').hasMatch(first) ? first : '#';
      (map[key] ??= []).add(entry);
    }

    // Sort entries within each group case-insensitively.
    for (final entries in map.values) {
      entries.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
    }

    // Sort groups: A–Z first, then #.
    final keys = map.keys.toList()
      ..sort((a, b) {
        if (a == '#') {
          return 1;
        }
        if (b == '#') {
          return -1;
        }
        return a.compareTo(b);
      });

    return [for (final k in keys) (k, map[k]!)];
  }

  static BrowseGroups _buildDimensionIndex(
    List<BrowseEntry> catalog,
    Map<String, String> dimensionLabels,
  ) {
    final map = <Dimension, List<BrowseEntry>>{};

    for (final entry in catalog) {
      final dim = entry.dimension;
      if (dim == null) {
        continue;
      }
      (map[dim] ??= []).add(entry);
    }

    // Sort entries within each group case-insensitively.
    for (final entries in map.values) {
      entries.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
    }

    String labelFor(Dimension dim) {
      final rep = dim.canonicalRepresentation();
      final userLabel = dimensionLabels[rep];
      if (userLabel != null) {
        return '$userLabel ($rep)';
      }
      return rep;
    }

    bool hasLabel(Dimension dim) {
      return dimensionLabels.containsKey(dim.canonicalRepresentation());
    }

    // Sort: labeled groups first (alphabetically by label), then unlabeled
    // groups (alphabetically by canonical representation).
    final dims = map.keys.toList()
      ..sort((a, b) {
        final aLabeled = hasLabel(a);
        final bLabeled = hasLabel(b);
        if (aLabeled && !bLabeled) {
          return -1;
        }
        if (!aLabeled && bLabeled) {
          return 1;
        }
        return labelFor(a).toLowerCase().compareTo(labelFor(b).toLowerCase());
      });

    return [for (final d in dims) (labelFor(d), map[d]!)];
  }

  /// Ensures the dimension index is built (no-op if already built).
  void _ensureDimensionIndex() {
    if (_dimensionIndex != null) {
      return;
    }
    _dimensionIndex = _buildDimensionIndex(_catalog, _repo.dimensionLabels);
  }
}
