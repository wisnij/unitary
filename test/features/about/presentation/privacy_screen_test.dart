import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unitary/features/about/presentation/privacy_screen.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

// The link sits alone in its own paragraph so that tapping the centre of the
// rendered widget lands on the link span rather than on surrounding prose.
const _fakePolicyText = '''
Privacy Policy
==============

Unitary collects nothing.

<https://wisnij.github.io/unitary/privacy>
''';

/// Serves [_fakePolicyText] for `PRIVACY.md`, and fails for anything else.
class _FakeAssetBundle extends CachingAssetBundle {
  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    if (key == 'PRIVACY.md') {
      return _fakePolicyText;
    }
    throw FlutterError('Asset not found: $key');
  }

  @override
  Future<ByteData> load(String key) async {
    throw FlutterError('Asset not found: $key');
  }
}

/// An asset bundle whose every load fails, for the error path.
class _FailingAssetBundle extends CachingAssetBundle {
  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    throw FlutterError('Asset not found: $key');
  }

  @override
  Future<ByteData> load(String key) async {
    throw FlutterError('Asset not found: $key');
  }
}

/// Records launched URLs, optionally reporting failure.
class _FakeUrlLauncher extends UrlLauncherPlatform {
  final List<String> launchedUrls = [];
  bool shouldFail = false;

  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    if (shouldFail) {
      throw PlatformException(code: 'error');
    }
    launchedUrls.add(url);
    return true;
  }
}

void main() {
  late _FakeUrlLauncher fakeUrlLauncher;

  setUp(() {
    fakeUrlLauncher = _FakeUrlLauncher();
    UrlLauncherPlatform.instance = fakeUrlLauncher;
  });

  Widget buildApp({AssetBundle? bundle}) {
    return MaterialApp(
      home: DefaultAssetBundle(
        bundle: bundle ?? _FakeAssetBundle(),
        child: const PrivacyScreen(),
      ),
    );
  }

  group('PrivacyScreen', () {
    testWidgets('shows app bar with title "Privacy policy"', (tester) async {
      await tester.pumpWidget(buildApp());

      expect(find.text('Privacy policy'), findsOneWidget);
    });

    testWidgets('shows loading indicator before the asset resolves', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders the bundled document after it loads', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.textContaining('Unitary collects nothing'), findsOneWidget);
    });

    testWidgets('shows an error message when the asset cannot be read', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp(bundle: _FailingAssetBundle()));
      await tester.pump();

      expect(find.textContaining('Failed to load'), findsOneWidget);
    });

    testWidgets('tapping a link opens it in the browser', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pump();

      await tester.tap(
        find.textContaining('wisnij.github.io/unitary/privacy'),
      );
      await tester.pumpAndSettle();

      expect(
        fakeUrlLauncher.launchedUrls,
        contains('https://wisnij.github.io/unitary/privacy'),
      );
    });

    testWidgets('a link launch failure does not crash', (tester) async {
      fakeUrlLauncher.shouldFail = true;
      await tester.pumpWidget(buildApp());
      await tester.pump();

      await tester.tap(
        find.textContaining('wisnij.github.io/unitary/privacy'),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.textContaining('Unitary collects nothing'), findsOneWidget);
    });

    testWidgets('back navigation returns to the previous screen', (
      tester,
    ) async {
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
                        child: const PrivacyScreen(),
                      ),
                    ),
                  );
                },
                child: const Text('Open policy'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open policy'));
      await tester.pumpAndSettle();
      expect(find.text('Privacy policy'), findsOneWidget);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(find.text('Open policy'), findsOneWidget);
      expect(find.text('Privacy policy'), findsNothing);
    });
  });
}
