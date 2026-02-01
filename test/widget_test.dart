import 'package:flutter_test/flutter_test.dart';

import 'package:unitary/app.dart';

void main() {
  testWidgets('App renders', (WidgetTester tester) async {
    await tester.pumpWidget(const UnitaryApp());
    expect(find.text('Unitary'), findsOneWidget);
  });
}
