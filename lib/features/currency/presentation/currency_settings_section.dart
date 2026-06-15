import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/utils/date_formatter.dart';
import '../state/currency_provider.dart';
import 'currency_refresh_button.dart';

/// Currency rates section for the Settings screen.
class CurrencySettingsSection extends ConsumerWidget {
  const CurrencySettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(currencyStatusProvider);

    final String subtitle;
    if (status.lastUpdatedAt == null) {
      subtitle = 'Using built-in rates';
    } else {
      subtitle = 'Last updated: ${formatDateTime(status.lastUpdatedAt!)}';
    }

    return ListTile(
      title: const Text('Exchange rates'),
      subtitle: Text(subtitle),
      trailing: const CurrencyRefreshButton(),
    );
  }
}
