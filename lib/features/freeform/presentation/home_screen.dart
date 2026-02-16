import 'package:flutter/material.dart';

import '../../settings/presentation/settings_screen.dart';
import 'freeform_screen.dart';

/// Main app screen with drawer navigation.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Unitary')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.deepPurple),
              child: Text(
                'Unitary',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.calculate),
              title: const Text('Freeform'),
              selected: true,
              onTap: () => Navigator.pop(context),
            ),
            const ListTile(
              leading: Icon(Icons.table_chart),
              title: Text('Worksheet'),
              enabled: false,
              onTap: null,
            ),
            const Divider(),
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
          ],
        ),
      ),
      body: const FreeformScreen(),
    );
  }
}
