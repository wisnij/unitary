import 'package:flutter/material.dart';

import '../features/about/presentation/about_screen.dart';
import '../features/browser/presentation/browser_screen.dart';
import '../features/freeform/presentation/freeform_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/worksheet/presentation/worksheet_screen.dart';
import 'top_level_page.dart';
import 'window_size_class.dart';

/// Top-level app shell hosting the three pages and the adaptive navigation.
///
/// The pages are kept in an [IndexedStack] so each retains its widget state
/// while inactive.  Top-level navigation chrome adapts to [WindowSizeClass]:
/// at compact and medium widths each page supplies its own [Drawer] (via
/// `AppDrawer`); at expanded width the shell renders a persistent
/// [NavigationRail] beside the page and the pages suppress their drawer.
///
/// Each page still owns its own [Scaffold]/[AppBar]; the shell only layers the
/// rail around them.  See `openspec/changes/responsive-layouts/design.md` §2
/// (approach B) for why AppBar construction is not centralized here.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  TopLevelPage _currentPage = TopLevelPage.freeform;

  // Stable identity for the page stack so its subtree (and each page's State)
  // survives being reparented when the layout switches between the drawer and
  // rail trees as the window crosses the expanded breakpoint.
  final GlobalKey _bodyKey = GlobalKey();

  void _switchPage(TopLevelPage page) {
    if (_currentPage != page) {
      setState(() => _currentPage = page);
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = IndexedStack(
      key: _bodyKey,
      index: _currentPage.index,
      children: [
        FreeformScreen(onNavigate: _switchPage),
        WorksheetScreen(onNavigate: _switchPage),
        BrowserScreen(onNavigate: _switchPage),
      ],
    );

    if (!WindowSizeClass.of(context).usesRail) {
      // Compact / medium: each page owns its drawer and hamburger.
      return body;
    }

    // Expanded: a single persistent rail beside the active page.  The rail is
    // built once, outside the IndexedStack, so there is exactly one instance.
    return Scaffold(
      body: Row(
        children: [
          _AppNavigationRail(
            currentPage: _currentPage,
            onNavigate: _switchPage,
          ),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(child: body),
        ],
      ),
    );
  }
}

/// Persistent navigation rail shown at the expanded window size class.
///
/// Lists the three top-level destinations (in [TopLevelPage] order) and exposes
/// Settings and About in its trailing slot, mirroring the [Drawer] used at
/// narrower widths.
class _AppNavigationRail extends StatelessWidget {
  const _AppNavigationRail({
    required this.currentPage,
    required this.onNavigate,
  });

  final TopLevelPage currentPage;
  final void Function(TopLevelPage) onNavigate;

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: currentPage.index,
      onDestinationSelected: (index) => onNavigate(TopLevelPage.values[index]),
      labelType: NavigationRailLabelType.all,
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.calculate),
          label: Text('Freeform'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.table_chart),
          label: Text('Worksheet'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.library_books),
          label: Text('Browse'),
        ),
      ],
      trailing: Expanded(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.settings),
                tooltip: 'Settings',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const SettingsScreen(),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.info_outline),
                tooltip: 'About',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const AboutScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
