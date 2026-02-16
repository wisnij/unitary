import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/freeform/presentation/home_screen.dart';
import 'features/settings/state/settings_provider.dart';

class UnitaryApp extends ConsumerWidget {
  const UnitaryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final ThemeMode themeMode;
    switch (settings.darkMode) {
      case true:
        themeMode = ThemeMode.dark;
      case false:
        themeMode = ThemeMode.light;
      case null:
        themeMode = ThemeMode.system;
    }

    return MaterialApp(
      title: 'Unitary',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: themeMode,
      home: const HomeScreen(),
    );
  }
}
