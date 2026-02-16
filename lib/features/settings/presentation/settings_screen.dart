import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_settings.dart';
import '../state/settings_provider.dart';

/// Settings screen with precision, notation, dark mode, and evaluation mode.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final useSystemTheme = settings.darkMode == null;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const _SectionHeader(title: 'Display'),
          ListTile(
            title: const Text('Decimal precision'),
            trailing: DropdownButton<int>(
              value: settings.precision,
              onChanged: (value) {
                if (value != null) {
                  notifier.updatePrecision(value);
                }
              },
              items: [
                for (var i = 2; i <= 10; i++)
                  DropdownMenuItem(value: i, child: Text('$i')),
              ],
            ),
          ),
          ListTile(
            title: const Text('Number notation'),
            trailing: DropdownButton<Notation>(
              value: settings.notation,
              onChanged: (value) {
                if (value != null) {
                  notifier.updateNotation(value);
                }
              },
              items: [
                for (final n in Notation.values)
                  DropdownMenuItem(value: n, child: Text(n.label)),
              ],
            ),
          ),
          const _SectionHeader(title: 'Appearance'),
          CheckboxListTile(
            title: const Text('Use system theme'),
            value: useSystemTheme,
            onChanged: (value) {
              if (value == true) {
                notifier.updateDarkMode(null);
              } else {
                notifier.updateDarkMode(false);
              }
            },
          ),
          SwitchListTile(
            title: const Text('Dark mode'),
            value: settings.darkMode ?? false,
            onChanged: useSystemTheme
                ? null
                : (value) => notifier.updateDarkMode(value),
          ),
          const _SectionHeader(title: 'Behavior'),
          RadioGroup<EvaluationMode>(
            groupValue: settings.evaluationMode,
            onChanged: (value) {
              if (value != null) {
                notifier.updateEvaluationMode(value);
              }
            },
            child: const Column(
              children: [
                RadioListTile<EvaluationMode>(
                  title: Text('Real-time'),
                  subtitle: Text('Evaluate as you type'),
                  value: EvaluationMode.realtime,
                ),
                RadioListTile<EvaluationMode>(
                  title: Text('On submit'),
                  subtitle: Text('Evaluate on Enter or button press'),
                  value: EvaluationMode.onSubmit,
                ),
              ],
            ),
          ),
          const _SectionHeader(title: 'About'),
          const ListTile(
            title: Text('Version'),
            subtitle: Text('0.4.0'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
