import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/currency/state/currency_provider.dart';
import 'features/settings/state/settings_provider.dart';
import 'shared/app_shell.dart';

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
      themeMode: settings.themeMode,
      home: const AppShell(),
    );
  }
}
