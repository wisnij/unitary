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

    testWidgets('dark mode toggle works', (tester) async {
      await tester.pumpWidget(buildApp());

      // Initially "Use system theme" is checked, manual switch is off.
      final systemCheckbox = find.byType(Checkbox);
      expect(systemCheckbox, findsOneWidget);

      // Uncheck system theme.
      await tester.tap(systemCheckbox);
      await tester.pumpAndSettle();

      // Now the dark mode switch should be enabled.
      final darkSwitch = find.byType(Switch);
      expect(darkSwitch, findsOneWidget);

      // Toggle dark mode on.
      await tester.tap(darkSwitch);
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(SettingsScreen)),
      );
      expect(container.read(settingsProvider).darkMode, true);
    });

    testWidgets('system theme checkbox sets darkMode to null', (tester) async {
      // Start with dark mode explicitly set.
      SharedPreferences.setMockInitialValues({'darkMode': true});
      final prefs = await SharedPreferences.getInstance();
      repo = SettingsRepository(prefs);
      await tester.pumpWidget(buildApp());

      // Check "Use system theme".
      final systemCheckbox = find.byType(Checkbox);
      await tester.tap(systemCheckbox);
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(SettingsScreen)),
      );
      expect(container.read(settingsProvider).darkMode, isNull);
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
