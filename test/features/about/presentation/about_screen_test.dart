import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:unitary/features/about/presentation/about_screen.dart';
import 'package:unitary/features/about/presentation/license_screen.dart';
import 'package:unitary/features/about/state/build_metadata_provider.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

import '../../../helpers/repository_overrides.dart';

/// Fake [UrlLauncherPlatform] that records launched URLs.
class FakeUrlLauncher extends UrlLauncherPlatform {
  final List<String> launchedUrls = [];

  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    launchedUrls.add(url);
    return true;
  }
}

void main() {
  late TestRepositories repos;
  late FakeUrlLauncher fakeUrlLauncher;

  setUp(() async {
    repos = await TestRepositories.create();
    PackageInfo.setMockInitialValues(
      appName: 'unitary',
      packageName: 'dev.wisnij.unitary',
      version: '1.2.3',
      buildNumber: '',
      buildSignature: '',
    );
    fakeUrlLauncher = FakeUrlLauncher();
    UrlLauncherPlatform.instance = fakeUrlLauncher;
  });

  Widget buildApp() {
    return ProviderScope(
      overrides: repos.overrides,
      child: const MaterialApp(home: AboutScreen()),
    );
  }

  // Returns the first semantics node exposing a custom action with [label].
  SemanticsNode? findCustomActionNode(WidgetTester tester, String label) {
    SemanticsNode? result;
    bool visit(SemanticsNode node) {
      if (result != null) {
        return false;
      }
      final ids = node.getSemanticsData().customSemanticsActionIds;
      if (ids != null) {
        for (final id in ids) {
          if (CustomSemanticsAction.getAction(id)?.label == label) {
            result = node;
            return false;
          }
        }
      }
      node.visitChildren(visit);
      return true;
    }

    var root = tester.getSemantics(find.byType(MaterialApp));
    while (root.parent != null) {
      root = root.parent!;
    }
    visit(root);
    return result;
  }

  group('AboutScreen', () {
    testWidgets('renders app bar with title "About"', (tester) async {
      await tester.pumpWidget(buildApp());
      expect(find.text('About'), findsOneWidget);
    });

    testWidgets('shows Version tile with app version', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pump(); // Allow FutureProvider to resolve.

      expect(find.text('Version'), findsOneWidget);
      expect(find.text('1.2.3'), findsOneWidget);
    });

    testWidgets('long-pressing Version tile shows copy confirmation', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp());
      await tester.pump();

      await tester.longPress(find.widgetWithText(ListTile, 'Version'));
      await tester.pump();

      expect(find.textContaining('Copied:'), findsOneWidget);
    });

    testWidgets('long-pressing Build tile shows copy confirmation', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ...repos.overrides,
            buildMetadataProvider.overrideWithValue('20260315-abc1234'),
          ],
          child: const MaterialApp(home: AboutScreen()),
        ),
      );
      await tester.pump();

      await tester.longPress(find.widgetWithText(ListTile, 'Build'));
      await tester.pump();

      expect(find.textContaining('Copied:'), findsOneWidget);
    });

    testWidgets('copy tiles expose labeled custom semantics actions', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ...repos.overrides,
            buildMetadataProvider.overrideWithValue('20260315-abc1234'),
          ],
          child: const MaterialApp(home: AboutScreen()),
        ),
      );
      await tester.pump();

      // Both copyable tiles expose their action in the semantics tree.
      expect(findCustomActionNode(tester, 'Copy version'), isNotNull);
      expect(findCustomActionNode(tester, 'Copy build'), isNotNull);

      handle.dispose();
    });

    testWidgets('invoking the Copy version action shows the confirmation', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(buildApp());
      await tester.pump();

      final node = findCustomActionNode(tester, 'Copy version');
      expect(node, isNotNull);

      final actionId = CustomSemanticsAction.getIdentifier(
        const CustomSemanticsAction(label: 'Copy version'),
      );
      node!.owner!.performAction(
        node.id,
        SemanticsAction.customAction,
        actionId,
      );
      await tester.pump();

      expect(find.textContaining('Copied:'), findsOneWidget);

      handle.dispose();
    });

    testWidgets('Build tile is hidden when buildMetadata is empty', (
      tester,
    ) async {
      // buildMetadata defaults to '' in tests (no BUILD_METADATA dart-define).
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Build'), findsNothing);
    });

    testWidgets('License terms tile shows GNU AGPL 3.0 subtitle', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp());
      expect(find.text('License terms'), findsOneWidget);
      expect(find.text('GNU AGPL 3.0'), findsOneWidget);
    });

    testWidgets('tapping License terms navigates to LicenseScreen', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp());

      await tester.tap(find.text('License terms'));
      await tester.pumpAndSettle();

      expect(find.byType(LicenseScreen), findsOneWidget);
    });

    testWidgets('Project home tile shows URL subtitle', (tester) async {
      await tester.pumpWidget(buildApp());
      expect(find.text('Project home'), findsOneWidget);
      expect(find.text('https://github.com/wisnij/unitary'), findsOneWidget);
    });

    testWidgets('tapping Project home launches GitHub URL', (tester) async {
      await tester.pumpWidget(buildApp());

      await tester.tap(find.text('Project home'));
      await tester.pumpAndSettle();

      expect(
        fakeUrlLauncher.launchedUrls,
        contains('https://github.com/wisnij/unitary'),
      );
    });
  });
}
