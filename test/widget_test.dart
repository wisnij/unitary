import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:unitary/app.dart';

import 'helpers/repository_overrides.dart';

void main() {
  testWidgets('App renders', (WidgetTester tester) async {
    final repos = await TestRepositories.create();

    // UnitaryApp is itself the MaterialApp, so it's pumped directly rather
    // than through pumpApp (which would wrap it in a second MaterialApp).
    await tester.pumpWidget(
      ProviderScope(overrides: repos.overrides, child: const UnitaryApp()),
    );
    expect(find.text('Unitary'), findsOneWidget);
  });
}
