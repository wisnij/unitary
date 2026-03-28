import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../about/presentation/about_screen.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../worksheet/data/predefined_worksheets.dart';
import '../../worksheet/presentation/worksheet_screen.dart';
import '../../worksheet/state/worksheet_provider.dart';
import 'freeform_screen.dart';

enum _TopLevelPage { freeform, worksheet }

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

    return Scaffold(
      appBar: AppBar(
        title: _currentPage == _TopLevelPage.worksheet
            ? WorksheetDropdown(
                templates: predefinedWorksheets,
                selectedId: worksheetState.worksheetId,
                onChanged: (id) =>
                    ref.read(worksheetProvider.notifier).selectWorksheet(id),
              )
            : const Text('Unitary'),
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
      body: _currentPage == _TopLevelPage.worksheet
          ? const WorksheetScreen()
          : const FreeformScreen(),
    );
  }
}
