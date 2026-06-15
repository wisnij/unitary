import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/currency_provider.dart';

/// A reusable manual exchange-rate refresh control.
///
/// Renders one of three states based on [currencyStatusProvider]:
/// - a refresh [IconButton] when idle,
/// - a [CircularProgressIndicator] spinner while a fetch is in progress,
/// - a disabled "Wait Ns" button during the 60-second cooldown.
///
/// On a failed refresh it shows the shared [_RefreshErrorDialog].  Because all
/// instances share the same provider state, the cooldown and in-progress state
/// stay consistent everywhere the control appears (Settings and the worksheet
/// AppBar).
class CurrencyRefreshButton extends ConsumerWidget {
  const CurrencyRefreshButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(currencyStatusProvider);
    final notifier = ref.read(currencyStatusProvider.notifier);

    if (status.isFetching) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (!status.canRefresh) {
      final secs = status.cooldownSecondsRemaining;
      return TextButton(
        onPressed: null,
        child: Text('Wait ${secs}s'),
      );
    }

    return IconButton(
      icon: const Icon(Icons.refresh),
      tooltip: 'Refresh exchange rates',
      onPressed: () async {
        final error = await notifier.refresh();
        if (error != null && context.mounted) {
          await showDialog<void>(
            context: context,
            builder: (ctx) => _RefreshErrorDialog(error: error),
          );
        }
      },
    );
  }
}

class _RefreshErrorDialog extends StatelessWidget {
  const _RefreshErrorDialog({required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Error during rate update',
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('The exchange rates could not be refreshed.'),
          ExpansionTile(
            title: const Text('Details'),
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(error),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
