import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/currency_provider.dart';

/// Currency rates section for the Settings screen.
class CurrencySettingsSection extends ConsumerWidget {
  const CurrencySettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(currencyStatusProvider);
    final notifier = ref.read(currencyStatusProvider.notifier);

    final String subtitle;
    if (status.lastUpdatedAt == null) {
      subtitle = 'Using built-in rates';
    } else {
      subtitle = 'Last updated: ${_formatDateTime(status.lastUpdatedAt!)}';
    }

    final Widget trailing;
    if (status.isFetching) {
      trailing = const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    } else if (!status.canRefresh) {
      final secs = status.cooldownSecondsRemaining;
      trailing = TextButton(
        onPressed: null,
        child: Text('Wait ${secs}s'),
      );
    } else {
      trailing = IconButton(
        icon: const Icon(Icons.refresh),
        tooltip: 'Refresh exchange rates',
        onPressed: () => notifier.refresh(),
      );
    }

    return ListTile(
      title: const Text('Exchange rates'),
      subtitle: Text(subtitle),
      trailing: trailing,
    );
  }
}

String _formatDateTime(DateTime dt) {
  final local = dt.toLocal();
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final month = months[local.month - 1];
  final h = local.hour;
  final hour = h % 12 == 0 ? 12 : h % 12;
  final minute = local.minute.toString().padLeft(2, '0');
  final amPm = h < 12 ? 'AM' : 'PM';
  return '$month ${local.day}, ${local.year}, $hour:$minute $amPm';
}
