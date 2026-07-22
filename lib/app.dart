import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/currency/state/currency_provider.dart';
import 'features/settings/models/user_settings.dart';
import 'features/settings/state/settings_provider.dart';
import 'shared/app_shell.dart';

/// Maps the persisted [ThemePreference] to Flutter's [ThemeMode], the only
/// place the two are bridged (see [ThemePreference]'s doc comment).
ThemeMode _toFlutterThemeMode(ThemePreference preference) =>
    switch (preference) {
      ThemePreference.system => ThemeMode.system,
      ThemePreference.dark => ThemeMode.dark,
      ThemePreference.light => ThemeMode.light,
    };

class UnitaryApp extends ConsumerStatefulWidget {
  const UnitaryApp({super.key});

  @override
  ConsumerState<UnitaryApp> createState() => _UnitaryAppState();
}

class _UnitaryAppState extends ConsumerState<UnitaryApp> {
  @override
  void initState() {
    super.initState();
    // Fire-and-forget background staleness check after the first frame so the
    // repository and providers are fully initialised before we touch them.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(currencyStatusProvider.notifier).maybeRefresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp(
      title: 'Unitary',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: _toFlutterThemeMode(settings.themeMode),
      home: const AppShell(),
    );
  }
}
