import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/domain/models/unit_repository_provider.dart';
import '../data/currency_rate_repository.dart';
import '../domain/currency_service.dart';

/// Provides the [CurrencyRateRepository] instance.
///
/// Must be overridden in [ProviderScope] with an initialized repository.
final currencyRateRepositoryProvider = Provider<CurrencyRateRepository>(
  (ref) => throw UnimplementedError(
    'currencyRateRepositoryProvider must be overridden',
  ),
);

/// Provides the [CurrencyService] instance.
final currencyServiceProvider = Provider<CurrencyService>((ref) {
  return CurrencyService(
    repo: ref.watch(unitRepositoryProvider),
    rateRepo: ref.watch(currencyRateRepositoryProvider),
  );
});

/// State exposed by [CurrencyStatusNotifier].
class CurrencyStatus {
  /// When rates were last successfully fetched, or null if never.
  final DateTime? lastUpdatedAt;

  /// Whether a fetch is currently in progress.
  final bool isFetching;

  /// When the 60-second manual-refresh cooldown expires, or null if not active.
  final DateTime? cooldownExpiry;

  const CurrencyStatus({
    this.lastUpdatedAt,
    this.isFetching = false,
    this.cooldownExpiry,
  });

  /// Whether the manual refresh button should be enabled.
  bool get canRefresh =>
      !isFetching &&
      (cooldownExpiry == null ||
          DateTime.now().toUtc().isAfter(cooldownExpiry!));

  /// Remaining cooldown in whole seconds, or 0 if not active.
  int get cooldownSecondsRemaining {
    if (cooldownExpiry == null) {
      return 0;
    }
    final remaining = cooldownExpiry!
        .difference(DateTime.now().toUtc())
        .inSeconds;
    return remaining > 0 ? remaining : 0;
  }

  CurrencyStatus copyWith({
    DateTime? lastUpdatedAt,
    bool? isFetching,
    DateTime? cooldownExpiry,
    bool clearCooldown = false,
    bool clearLastUpdated = false,
  }) {
    return CurrencyStatus(
      lastUpdatedAt: clearLastUpdated
          ? null
          : (lastUpdatedAt ?? this.lastUpdatedAt),
      isFetching: isFetching ?? this.isFetching,
      cooldownExpiry: clearCooldown
          ? null
          : (cooldownExpiry ?? this.cooldownExpiry),
    );
  }
}

/// Manages currency refresh state: last-updated timestamp, fetch progress,
/// and the 60-second manual-refresh cooldown.
final currencyStatusProvider =
    NotifierProvider<CurrencyStatusNotifier, CurrencyStatus>(
      CurrencyStatusNotifier.new,
    );

class CurrencyStatusNotifier extends Notifier<CurrencyStatus> {
  static const _cooldown = Duration(seconds: 60);

  @override
  CurrencyStatus build() {
    final stored = ref.read(currencyRateRepositoryProvider).load();
    return CurrencyStatus(lastUpdatedAt: stored?.updatedAt);
  }

  /// Triggers an immediate fetch, bypassing the 24-hour staleness check.
  /// Enforces a 60-second cooldown between manual refresh attempts.
  Future<void> refresh() async {
    if (!state.canRefresh) {
      return;
    }
    final expiry = DateTime.now().toUtc().add(_cooldown);
    state = state.copyWith(isFetching: true, cooldownExpiry: expiry);
    try {
      await ref.read(currencyServiceProvider).fetchRates();
      final stored = ref.read(currencyRateRepositoryProvider).load();
      state = state.copyWith(
        isFetching: false,
        lastUpdatedAt: stored?.updatedAt,
      );
    } on Exception {
      state = state.copyWith(isFetching: false);
    }
    // Schedule state update when cooldown expires so the button re-enables.
    Timer(_cooldown, () {
      if (!ref.read(currencyStatusProvider).isFetching) {
        state = state.copyWith(clearCooldown: true);
      }
    });
  }
}
