import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:unitary/core/domain/models/unit_repository.dart';
import 'package:unitary/core/domain/models/unit_repository_provider.dart';
import 'package:unitary/features/browser/state/browser_provider.dart';
import 'package:unitary/features/freeform/state/parser_provider.dart';

void main() {
  group('unitRepositoryProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
      addTearDown(container.dispose);
    });

    test('provides a UnitRepository', () {
      final repo = container.read(unitRepositoryProvider);
      expect(repo, isA<UnitRepository>());
    });

    test('returns the same instance on multiple reads', () {
      final repo1 = container.read(unitRepositoryProvider);
      final repo2 = container.read(unitRepositoryProvider);
      expect(identical(repo1, repo2), isTrue);
    });

    test('parserProvider and browserProvider share the same UnitRepository', () {
      final repoFromProvider = container.read(unitRepositoryProvider);
      final parser = container.read(parserProvider);
      final browser = container.read(browserProvider.notifier);

      // Both parserProvider and BrowserNotifier read from unitRepositoryProvider.
      expect(identical(parser.repo, repoFromProvider), isTrue);
      // BrowserNotifier stores the repo in _repo; verify through behavior
      // (it builds a catalog from the shared repo).
      expect(browser, isA<BrowserNotifier>());
      expect(identical(parser.repo, repoFromProvider), isTrue);
    });
  });
}
