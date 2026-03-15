import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:unitary/features/about/presentation/license_screen.dart';

const _fakeLicenseText =
    'GNU AFFERO GENERAL PUBLIC LICENSE\nVersion 3, 19 November 2007\n';

class _FakeAssetBundle extends CachingAssetBundle {
  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    if (key == 'LICENSE.md') {
      return _fakeLicenseText;
    }
    throw FlutterError('Asset not found: $key');
  }

  @override
  Future<ByteData> load(String key) async {
    throw FlutterError('Asset not found: $key');
  }
}

void main() {
  Widget buildApp({Widget? home}) {
    return MaterialApp(
      home: DefaultAssetBundle(
        bundle: _FakeAssetBundle(),
        child: home ?? const LicenseScreen(),
      ),
    );
  }

  group('LicenseScreen', () {
    testWidgets('shows app bar with title "License terms"', (tester) async {
      await tester.pumpWidget(buildApp());
      expect(find.text('License terms'), findsOneWidget);
    });

    testWidgets('shows loading indicator before asset resolves', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp());
      // Before the FutureBuilder resolves, the loading indicator is visible.
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays license text after asset loads', (tester) async {
      await tester.pumpWidget(buildApp());
      // Allow the FutureBuilder to complete.
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(
        find.textContaining('GNU AFFERO GENERAL PUBLIC LICENSE'),
        findsOneWidget,
      );
    });

    testWidgets('back navigation returns to previous screen', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => DefaultAssetBundle(
                        bundle: _FakeAssetBundle(),
                        child: const LicenseScreen(),
                      ),
                    ),
                  );
                },
                child: const Text('Open license'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open license'));
      await tester.pumpAndSettle();
      expect(find.text('License terms'), findsOneWidget);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(find.text('Open license'), findsOneWidget);
      expect(find.text('License terms'), findsNothing);
    });
  });
}
