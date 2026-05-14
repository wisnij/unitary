import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/freeform_history_repository.dart';

/// Provides the [FreeformHistoryRepository] instance.
///
/// Must be overridden in [ProviderScope] with an initialized repository.
final freeformHistoryRepositoryProvider = Provider<FreeformHistoryRepository>(
  (ref) => throw UnimplementedError(
    'freeformHistoryRepositoryProvider must be overridden',
  ),
);

/// Non-autoDispose provider: history persists across navigation.
final freeformHistoryProvider =
    NotifierProvider<FreeformHistoryNotifier, List<FreeformHistoryEntry>>(
      FreeformHistoryNotifier.new,
    );

/// Manages the freeform conversion history.
class FreeformHistoryNotifier extends Notifier<List<FreeformHistoryEntry>> {
  @override
  List<FreeformHistoryEntry> build() {
    return ref.read(freeformHistoryRepositoryProvider).load();
  }

  /// Records a (from, to) pair, applying deduplication and the 100-entry cap.
  ///
  /// Trims both values.  If an identical (from, to) pair already exists, it is
  /// moved to the top.  Entries are truncated to [FreeformHistoryRepository.maxEntries].
  Future<void> record(String from, String to) async {
    final trimmedFrom = from.trim();
    final trimmedTo = to.trim();
    final entry = FreeformHistoryEntry(from: trimmedFrom, to: trimmedTo);

    final updated = [
      entry,
      ...state.where((e) => e != entry),
    ];

    final capped = updated.length > FreeformHistoryRepository.maxEntries
        ? updated.sublist(0, FreeformHistoryRepository.maxEntries)
        : updated;

    state = capped;
    await ref.read(freeformHistoryRepositoryProvider).save(capped);
  }
}
