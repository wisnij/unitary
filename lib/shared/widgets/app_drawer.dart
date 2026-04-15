import 'package:flutter/material.dart';

import '../../features/about/presentation/about_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../top_level_page.dart';

/// App-wide navigation drawer used by each top-level page Scaffold.
///
/// Accepts the [currentPage] to highlight the active tile and an [onNavigate]
/// callback invoked (after closing the drawer) when the user taps a page tile.
/// Settings and About tiles navigate via [Navigator.push].
class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
    required this.currentPage,
    required this.onNavigate,
  });

  /// The page currently active (used for selected-state highlighting).
  final TopLevelPage currentPage;

  /// Called with the target page when a Freeform/Worksheet/Browse tile is tapped.
  final void Function(TopLevelPage) onNavigate;

  void _navigate(BuildContext context, TopLevelPage page) {
    Navigator.pop(context); // close drawer
    onNavigate(page);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
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
                  selected: currentPage == TopLevelPage.freeform,
                  onTap: () => _navigate(context, TopLevelPage.freeform),
                ),
                ListTile(
                  leading: const Icon(Icons.table_chart),
                  title: const Text('Worksheet'),
                  selected: currentPage == TopLevelPage.worksheet,
                  onTap: () => _navigate(context, TopLevelPage.worksheet),
                ),
                ListTile(
                  leading: const Icon(Icons.library_books),
                  title: const Text('Browse'),
                  selected: currentPage == TopLevelPage.browser,
                  onTap: () => _navigate(context, TopLevelPage.browser),
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
    );
  }
}
