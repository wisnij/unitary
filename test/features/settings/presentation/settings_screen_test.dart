import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:unitary/features/settings/data/settings_repository.dart';
import 'package:unitary/features/settings/models/user_settings.dart';
import 'package:unitary/features/settings/presentation/settings_screen.dart';
import 'package:unitary/features/settings/state/settings_provider.dart';

void main() {
  late SettingsRepository repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    repo = SettingsRepository(prefs);
    PackageInfo.setMockInitialValues(
      appName: 'unitary',
      packageName: 'com.wisnij.unitary',
      version: '0.0.1',
      buildNumber: '',
      buildSignature: '',
    );
  });

  Widget buildApp() {
    return ProviderScope(
      overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
      child: const MaterialApp(home: SettingsScreen()),
    );
  }

  group('SettingsScreen', () {
    testWidgets('renders all settings sections', (tester) async {
      // The settings list is taller than the default test window; use a taller
      // one so all sections are mounted.
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildApp());
      expect(find.text('Settings'), findsOneWidget); // AppBar title.
      expect(find.text('Display'), findsOneWidget);
      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Behavior'), findsOneWidget);
      expect(find.text('About'), findsOneWidget);
    });

    testWidgets('version tile shows app version from PackageInfo', (
      tester,
    ) async {
      // The settings list is taller than the default 600px test window, so the
      // Version tile would be unmounted (off-screen). Use a taller window.
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildApp());
      await tester.pump(); // Allow FutureProvider to resolve.
      expect(find.text('Version'), findsOneWidget);
      expect(find.textContaining('0.0.1'), findsOneWidget);
    });

    testWidgets('renders precision dropdown with default value', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp());
      expect(find.text('Decimal precision'), findsOneWidget);
      // Default precision is 8.
      expect(find.text('8'), findsOneWidget);
    });

    testWidgets('changing precision updates provider state', (tester) async {
      await tester.pumpWidget(buildApp());

      // Tap the precision dropdown.
      await tester.tap(find.text('8'));
      await tester.pumpAndSettle();

      // Select 4.
      await tester.tap(find.text('4').last);
      await tester.pumpAndSettle();

      // Verify state updated.
      final container = ProviderScope.containerOf(
        tester.element(find.byType(SettingsScreen)),
      );
      expect(container.read(settingsProvider).precision, 4);
    });

    testWidgets('renders notation dropdown with default value', (tester) async {
      await tester.pumpWidget(buildApp());
      expect(find.text('Number notation'), findsOneWidget);
      expect(find.text('Automatic'), findsOneWidget);
    });

    testWidgets('changing notation updates provider state', (tester) async {
      await tester.pumpWidget(buildApp());

      // Tap the notation dropdown.
      await tester.tap(find.text('Automatic'));
      await tester.pumpAndSettle();

      // Select Scientific.
      await tester.tap(find.text('Scientific').last);
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(SettingsScreen)),
      );
      expect(container.read(settingsProvider).notation, Notation.scientific);
    });

    testWidgets('appearance section shows three theme radio options', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp());
      expect(find.text('Use system theme'), findsOneWidget);
      expect(find.text('Dark mode'), findsOneWidget);
      expect(find.text('Light mode'), findsOneWidget);
    });

    testWidgets('selecting dark mode radio updates themeMode', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp());

      await tester.tap(find.text('Dark mode'));
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(SettingsScreen)),
      );
      expect(container.read(settingsProvider).themeMode, ThemeMode.dark);
    });

    testWidgets('selecting light mode radio updates themeMode', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp());

      await tester.tap(find.text('Light mode'));
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(SettingsScreen)),
      );
      expect(container.read(settingsProvider).themeMode, ThemeMode.light);
    });

    testWidgets('selecting system theme radio updates themeMode', (
      tester,
    ) async {
      // Start with dark mode set.
      SharedPreferences.setMockInitialValues({'themeMode': 'dark'});
      final prefs = await SharedPreferences.getInstance();
      repo = SettingsRepository(prefs);
      await tester.pumpWidget(buildApp());

      await tester.tap(find.text('Use system theme'));
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(SettingsScreen)),
      );
      expect(container.read(settingsProvider).themeMode, ThemeMode.system);
    });

    testWidgets('evaluation mode selection works', (tester) async {
      await tester.pumpWidget(buildApp());

      // Default is real-time.
      expect(find.text('Real-time'), findsOneWidget);
      expect(find.text('On submit'), findsOneWidget);

      // Select on-submit.
      await tester.tap(find.text('On submit'));
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(SettingsScreen)),
      );
      expect(
        container.read(settingsProvider).evaluationMode,
        EvaluationMode.onSubmit,
      );
    });
  });
}
