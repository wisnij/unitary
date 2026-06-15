import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/utils/date_formatter.dart';
import '../../../currency/state/currency_provider.dart';
import '../../models/worksheet.dart';

/// Renders the [banner] declared by a worksheet template as a small,
/// unobtrusive bar above the worksheet rows.
///
/// Dispatches on the [WorksheetBanner] variant; each variant has its own
/// content widget.  New banner kinds add a branch here.
class WorksheetBannerWidget extends StatelessWidget {
  const WorksheetBannerWidget({super.key, required this.banner});

  final WorksheetBanner banner;

  @override
  Widget build(BuildContext context) {
    return switch (banner) {
      CurrencyRatesBanner() => const _CurrencyRatesBanner(),
    };
  }
}

/// Shows the currency exchange-rate sync status: the timestamp of the most
/// recent successful sync, or an indication that built-in rates are in use.
///
/// Reads from the same [currencyStatusProvider] as the Settings "Currency
/// rates" section and uses the shared [formatDateTime] helper, so the displayed
/// value is identical to Settings and updates reactively after a refresh.
class _CurrencyRatesBanner extends ConsumerWidget {
  const _CurrencyRatesBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(currencyStatusProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textStyle = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant);

    final String text;
    if (status.lastUpdatedAt == null) {
      text = 'Using built-in rates';
    } else {
      text = 'Rates updated: ${formatDateTime(status.lastUpdatedAt!)}';
    }

    return Container(
      width: double.infinity,
      color: colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Icon(Icons.schedule, size: 16, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: textStyle)),
        ],
      ),
    );
  }
}
