import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/domain/models/browse_entry.dart';
import '../../../shared/top_level_page.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/fast_scroll_bar.dart';
import '../state/browser_provider.dart';
import 'unit_entry_detail_screen.dart';

/// Unit browser screen.
///
/// Displays units, prefixes, and functions in either alphabetical or dimension
/// view.  Groups are collapsible.  A search bar can filter entries by name.
///
/// Owns its own [Scaffold] and [AppBar].  Navigation to other top-level pages
/// is delegated to [onNavigate], which is called by [AppDrawer] when the user
/// taps a navigation tile.
class BrowserScreen extends ConsumerStatefulWidget {
  const BrowserScreen({super.key, required this.onNavigate});

  /// Called when the user navigates to another top-level page via the drawer.
  final void Function(TopLevelPage) onNavigate;

  @override
  ConsumerState<BrowserScreen> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends ConsumerState<BrowserScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Clear the text field whenever the search bar is hidden.
    ref.listen(browserProvider.select((s) => s.searchVisible), (_, visible) {
      if (!visible) {
        _searchController.clear();
      }
    });

    final state = ref.watch(browserProvider);
    final notifier = ref.read(browserProvider.notifier);
    final groups = notifier.visibleGroups();
    final isAlpha = state.viewMode == BrowseViewMode.alphabetical;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search',
            onPressed: notifier.toggleSearch,
          ),
          IconButton(
            icon: const Icon(Icons.unfold_more),
            tooltip: 'Expand all',
            onPressed: notifier.expandAll,
          ),
          IconButton(
            icon: const Icon(Icons.unfold_less),
            tooltip: 'Collapse all',
            onPressed: notifier.collapseAll,
          ),
          IconButton(
            icon: Icon(isAlpha ? Icons.category : Icons.sort_by_alpha),
            tooltip: isAlpha ? 'Group by dimension' : 'Group alphabetically',
            onPressed: () => notifier.setViewMode(
              isAlpha ? BrowseViewMode.dimension : BrowseViewMode.alphabetical,
            ),
          ),
        ],
      ),
      drawer: AppDrawer(
        currentPage: TopLevelPage.browser,
        onNavigate: widget.onNavigate,
      ),
      body: Column(
        children: [
          // Search bar (shown when active).
          if (state.searchVisible)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search units…',
                  isDense: true,
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      notifier.setSearchQuery('');
                    },
                  ),
                ),
                onChanged: notifier.setSearchQuery,
              ),
            ),
          // Main list.
          Expanded(
            child: _BrowseListView(
              groups: groups,
              collapsedGroups: state.collapsedGroups,
              searchActive: state.searchQuery.isNotEmpty,
              onToggleGroup: notifier.toggleGroup,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// List view
// ---------------------------------------------------------------------------

class _BrowseListView extends StatefulWidget {
  const _BrowseListView({
    required this.groups,
    required this.collapsedGroups,
    required this.searchActive,
    required this.onToggleGroup,
  });

  final BrowseGroups groups;
  final Set<String> collapsedGroups;
  final bool searchActive;
  final ValueChanged<String> onToggleGroup;

  @override
  State<_BrowseListView> createState() => _BrowseListViewState();
}

class _BrowseListViewState extends State<_BrowseListView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Build a flat item list: header + entries interleaved.
    // Simultaneously collect group anchors: (flat-list index, label) per header.
    final items = <_ListItem>[];
    final groupAnchors = <(int, String)>[];
    for (final (label, entries) in widget.groups) {
      final isCollapsed = widget.collapsedGroups.contains(label);
      groupAnchors.add((items.length, label));
      items.add(_GroupHeaderItem(label: label, collapsed: isCollapsed));
      for (final entry in entries) {
        items.add(_EntryItem(entry: entry));
      }
    }

    final listView = ListView.builder(
      controller: _scrollController,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        if (item is _GroupHeaderItem) {
          return _GroupHeaderTile(
            label: item.label,
            collapsed: item.collapsed,
            onTap: () => widget.onToggleGroup(item.label),
          );
        } else if (item is _EntryItem) {
          return _EntryTile(entry: item.entry);
        }
        return const SizedBox.shrink();
      },
    );

    return FastScrollBar(
      controller: _scrollController,
      itemCount: items.length,
      groupAnchors: groupAnchors,
      active: !widget.searchActive,
      child: listView,
    );
  }
}

// ---------------------------------------------------------------------------
// List item types (sealed via abstract class)
// ---------------------------------------------------------------------------

abstract class _ListItem {}

class _GroupHeaderItem extends _ListItem {
  _GroupHeaderItem({required this.label, required this.collapsed});
  final String label;
  final bool collapsed;
}

class _EntryItem extends _ListItem {
  _EntryItem({required this.entry});
  final BrowseEntry entry;
}

// ---------------------------------------------------------------------------
// Group header tile
// ---------------------------------------------------------------------------

class _GroupHeaderTile extends StatelessWidget {
  const _GroupHeaderTile({
    required this.label,
    required this.collapsed,
    required this.onTap,
  });

  final String label;
  final bool collapsed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Icon(
              collapsed ? Icons.chevron_right : Icons.expand_more,
              color: theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Entry tile
// ---------------------------------------------------------------------------

class _EntryTile extends ConsumerWidget {
  const _EntryTile({required this.entry});

  final BrowseEntry entry;

  /// Decorates a name for display: appends `-` for prefixes, `(p1, p2)` for
  /// functions with parameters.
  static String _decorate(String name, BrowseEntry entry) {
    if (entry.kind == BrowseEntryKind.prefix) {
      return '$name-';
    }
    final p = entry.params;
    if (p != null && p.isNotEmpty) {
      return '$name(${p.join(', ')})';
    }
    return name;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final title = entry.isAlias
        ? '${_decorate(entry.name, entry)} = ${entry.primaryId}'
        : _decorate(entry.name, entry);

    return ListTile(
      title: Text(title),
      subtitle: Text(
        entry.summaryLine,
        style: TextStyle(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => UnitEntryDetailScreen(
              primaryId: entry.primaryId,
              kind: entry.kind,
            ),
          ),
        );
      },
    );
  }
}
