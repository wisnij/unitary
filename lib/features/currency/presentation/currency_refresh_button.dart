import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/currency_provider.dart';

/// A reusable manual exchange-rate refresh control.
///
/// Renders one of three states based on [currencyStatusProvider]:
/// - an enabled refresh [IconButton] when idle,
/// - a [CircularProgressIndicator] spinner while a fetch is in progress,
/// - a disabled (grayed) refresh button with a "Wait Ns" countdown during the
///   60-second cooldown.
///
/// While in cooldown the widget rebuilds once per second so the countdown ticks
/// down and the control re-enables as soon as the cooldown elapses.  The
/// re-enable decision is derived from the wall clock via
/// [CurrencyStatus.canRefresh], so it is independent of any state-clearing timer
/// in the notifier.
///
/// On a failed refresh it shows the shared [_RefreshErrorDialog].  Because all
/// instances share the same provider state, the cooldown and in-progress state
/// stay consistent everywhere the control appears (Settings and the worksheet
/// AppBar).
class CurrencyRefreshButton extends ConsumerStatefulWidget {
  const CurrencyRefreshButton({super.key});

  @override
  ConsumerState<CurrencyRefreshButton> createState() =>
      _CurrencyRefreshButtonState();
}

class _CurrencyRefreshButtonState extends ConsumerState<CurrencyRefreshButton> {
  Timer? _ticker;

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  /// Starts a 1-second repeating rebuild while [active]; stops it otherwise.
  void _syncTicker(bool active) {
    if (active) {
      _ticker ??= Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) {
          setState(() {});
        }
      });
    } else {
      _ticker?.cancel();
      _ticker = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(currencyStatusProvider);
    final notifier = ref.read(currencyStatusProvider.notifier);

    if (status.isFetching) {
      _syncTicker(false);
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    final inCooldown = !status.canRefresh;
    _syncTicker(inCooldown);

    if (inCooldown) {
      final secs = status.cooldownSecondsRemaining;
      // Icon at the end so it stays in the same position as the enabled
      // IconButton; the countdown label sits to its left.
      return TextButton.icon(
        onPressed: null,
        iconAlignment: IconAlignment.end,
        icon: const Icon(Icons.refresh),
        label: Text('Wait ${secs}s'),
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
