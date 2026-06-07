import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'unit_repository.dart';

/// Singleton [UnitRepository] shared by all consumers.
///
/// Both [parserProvider] and [BrowserNotifier] read from this provider so that
/// [UnitRepository.withPredefinedUnits] is called exactly once at app startup.
final unitRepositoryProvider = Provider<UnitRepository>((ref) {
  return UnitRepository.withPredefinedUnits();
});

/// Incremented whenever dynamic units in [unitRepositoryProvider] are
/// updated (e.g. after a currency rate refresh).  Consumers that cache
/// derived data from the repository (such as [BrowserNotifier]) watch this
/// counter so they can rebuild without being re-created from scratch.
final unitRepositoryVersionProvider =
    NotifierProvider<UnitRepositoryVersion, int>(UnitRepositoryVersion.new);

/// Notifier for [unitRepositoryVersionProvider].
class UnitRepositoryVersion extends Notifier<int> {
  @override
  int build() => 0;

  /// Signals that dynamic units in the repository have changed.
  void increment() => state++;
}
