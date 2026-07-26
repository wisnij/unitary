import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:unitary/features/settings/data/settings_repository.dart';
import 'package:unitary/features/settings/state/settings_provider.dart';

import 'pump_app.dart';
import 'repository_overrides.dart';

/// Displays the current settings precision, so tests can observe which
/// [SettingsRepository] a pumped widget tree actually resolved.
class _PrecisionText extends ConsumerWidget {
  const _PrecisionText();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final precision = ref.watch(settingsProvider).precision;
    return Text('precision: $precision');
  }
}

void main() {
  group('pumpApp', () {
    testWidgets('zero-argument call supplies working defaults', (
      tester,
    ) async {
      await pumpApp(tester, const _PrecisionText());

      expect(find.text('precision: 8'), findsOneWidget);
    });

    testWidgets('caller overrides take precedence over defaults', (
      tester,
    ) async {
      final repos = await TestRepositories.create(
        initialPrefs: {'precision': 5},
      );

      await pumpApp(
        tester,
        const _PrecisionText(),
        overrides: [
          settingsRepositoryProvider.overrideWithValue(repos.settings),
        ],
      );

      expect(find.text('precision: 5'), findsOneWidget);
    });

    testWidgets('pre-seeded repository is visible after pumping', (
      tester,
    ) async {
      final repos = await TestRepositories.create();
      await repos.settings.save(
        repos.settings.load().copyWith(precision: 4),
      );

      await pumpApp(tester, const _PrecisionText(), repos: repos);

      expect(find.text('precision: 4'), findsOneWidget);
    });
  });
}
