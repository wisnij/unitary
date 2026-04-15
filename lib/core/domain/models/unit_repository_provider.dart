import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'unit_repository.dart';

/// Singleton [UnitRepository] shared by all consumers.
///
/// Both [parserProvider] and [BrowserNotifier] read from this provider so that
/// [UnitRepository.withPredefinedUnits] is called exactly once at app startup.
final unitRepositoryProvider = Provider<UnitRepository>((ref) {
  return UnitRepository.withPredefinedUnits();
});
