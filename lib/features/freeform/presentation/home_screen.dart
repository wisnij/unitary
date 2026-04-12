import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../about/presentation/about_screen.dart';
import '../../browser/presentation/browser_screen.dart';
import '../../browser/state/browser_provider.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../worksheet/data/predefined_worksheets.dart';
import '../../worksheet/presentation/worksheet_screen.dart';
import '../../worksheet/state/worksheet_provider.dart';
import '../state/conformable_browse_provider.dart';
import '../state/freeform_provider.dart';
import '../state/freeform_state.dart';
import 'freeform_screen.dart';

enum _TopLevelPage { freeform, worksheet, browser }

/// Main app screen with drawer navigation.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  _TopLevelPage _currentPage = _TopLevelPage.freeform;

  void _switchPage(BuildContext context, _TopLevelPage page) {
    Navigator.pop(context); // close drawer
    if (_currentPage != page) {
      setState(() => _currentPage = page);
    }
  }

  @override
  Widget build(BuildContext context) {
    final worksheetState = ref.watch(worksheetProvider);

    final freeformResult = ref.watch(freeformProvider);
    final browseEnabled =
        _currentPage == _TopLevelPage.freeform &&
        conformableBrowseEnabled(freeformResult);

    return Scaffold(
      appBar: AppBar(
        title: switch (_currentPage) {
          _TopLevelPage.worksheet => WorksheetDropdown(
            templates: predefinedWorksheets,
            selectedId: worksheetState.worksheetId,
            onChanged: (id) =>
                ref.read(worksheetProvider.notifier).selectWorksheet(id),
          ),
          _TopLevelPage.browser => const Text('Browse'),
          _ => const Text('Unitary'),
        },
        actions: [
          if (_currentPage == _TopLevelPage.freeform)
            IconButton(
              icon: const Icon(Icons.balance),
              tooltip: 'Browse conformable units',
              onPressed: browseEnabled
                  ? () => ref
                        .read(conformableBrowseRequestProvider.notifier)
                        .trigger()
                  : null,
            ),
          if (_currentPage == _TopLevelPage.browser) ...[
            Consumer(
              builder: (context, ref, child) => IconButton(
                icon: const Icon(Icons.search),
                tooltip: 'Search',
                onPressed: ref.read(browserProvider.notifier).toggleSearch,
              ),
            ),
            Consumer(
              builder: (context, ref, child) {
                final searchActive = ref.watch(
                  browserProvider.select((s) => s.searchQuery.isNotEmpty),
                );
                return IconButton(
                  icon: const Icon(Icons.unfold_more),
                  tooltip: 'Expand all',
                  onPressed: searchActive
                      ? null
                      : ref.read(browserProvider.notifier).expandAll,
                );
              },
            ),
            Consumer(
              builder: (context, ref, child) {
                final searchActive = ref.watch(
                  browserProvider.select((s) => s.searchQuery.isNotEmpty),
                );
                return IconButton(
                  icon: const Icon(Icons.unfold_less),
                  tooltip: 'Collapse all',
                  onPressed: searchActive
                      ? null
                      : ref.read(browserProvider.notifier).collapseAll,
                );
              },
            ),
            Consumer(
              builder: (context, ref, child) {
                final isAlpha =
                    ref.watch(
                      browserProvider.select((s) => s.viewMode),
                    ) ==
                    BrowseViewMode.alphabetical;
                return IconButton(
                  icon: Icon(isAlpha ? Icons.category : Icons.sort_by_alpha),
                  tooltip: isAlpha
                      ? 'Group by dimension'
                      : 'Sort alphabetically',
                  onPressed: () => ref
                      .read(browserProvider.notifier)
                      .setViewMode(
                        isAlpha
                            ? BrowseViewMode.dimension
                            : BrowseViewMode.alphabetical,
                      ),
                );
              },
            ),
          ],
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const DrawerHeader(
                    decoration: BoxDecoration(color: Colors.blue),
                    child: Text(
                      'Unitary',
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.calculate),
                    title: const Text('Freeform'),
                    selected: _currentPage == _TopLevelPage.freeform,
                    onTap: () => _switchPage(context, _TopLevelPage.freeform),
                  ),
                  ListTile(
                    leading: const Icon(Icons.table_chart),
                    title: const Text('Worksheet'),
                    selected: _currentPage == _TopLevelPage.worksheet,
                    onTap: () => _switchPage(context, _TopLevelPage.worksheet),
                  ),
                  ListTile(
                    leading: const Icon(Icons.library_books),
                    title: const Text('Browse'),
                    selected: _currentPage == _TopLevelPage.browser,
                    onTap: () => _switchPage(context, _TopLevelPage.browser),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const SettingsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const AboutScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: switch (_currentPage) {
        _TopLevelPage.worksheet => const WorksheetScreen(),
        _TopLevelPage.browser => const BrowserScreen(),
        _ => const FreeformScreen(),
      },
    );
  }
}
