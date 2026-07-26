import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/misc.dart' show Override;

import 'repository_overrides.dart';

/// Pumps [child] wrapped in a [ProviderScope] (with default must-override
/// repositories from [repos], constructing one via [TestRepositories.create]
/// if not supplied) and a [MaterialApp].
///
/// [overrides] are layered on top of the defaults: an override for a
/// provider that also has a default replaces that default.
Future<void> pumpApp(
  WidgetTester tester,
  Widget child, {
  TestRepositories? repos,
  List<Override> overrides = const [],
}) async {
  final defaults = repos ?? await TestRepositories.create();
  final merged = {
    for (final override in defaults.overrides) override.origin: override,
    for (final override in overrides) override.origin: override,
  };

  await tester.pumpWidget(
    ProviderScope(
      overrides: merged.values.toList(),
      child: MaterialApp(home: child),
    ),
  );
}
