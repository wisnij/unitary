import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:unitary/features/settings/data/settings_repository.dart';
import 'package:unitary/features/settings/state/settings_provider.dart';
import 'package:unitary/features/worksheet/data/predefined_worksheets.dart';
import 'package:unitary/features/worksheet/data/worksheet_repository.dart';
import 'package:unitary/features/worksheet/presentation/worksheet_screen.dart';
import 'package:unitary/features/worksheet/state/worksheet_provider.dart';
import 'package:unitary/shared/readable_width.dart';

// Note: the "Label and input column widths" requirement in the worksheet-ui
// spec (minimum 130 dp label column, 12 em input minimum, equal-width inputs)
// is enforced via Flutter's Table + IntrinsicColumnWidth layout.  Font metrics
// in the headless test environment do not match device rendering, so these
// constraints are verified through manual testing on device rather than
// automated widget tests.

void main() {
  late SettingsRepository settingsRepo;
  late WorksheetRepository worksheetRepo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    settingsRepo = SettingsRepository(prefs);
    worksheetRepo = WorksheetRepository(prefs);
  });

  Widget buildApp() {
    return ProviderScope(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(settingsRepo),
        worksheetRepositoryProvider.overrideWithValue(worksheetRepo),
      ],
      child: MaterialApp(
        home: WorksheetScreen(onNavigate: (_) {}),
      ),
    );
  }

  // Selects a worksheet template by id via the provider, so tests can assume
  // an active worksheet (none is selected on launch).
  void selectTemplate(WidgetTester tester, String id) {
    final container = ProviderScope.containerOf(
      tester.element(find.byType(WorksheetScreen)),
    );
    container.read(worksheetProvider.notifier).selectWorksheet(id);
  }

  group('WorksheetScreen', () {
    testWidgets('no worksheet is selected on launch', (tester) async {
      await tester.pumpWidget(buildApp());

      final container = ProviderScope.containerOf(
        tester.element(find.byType(WorksheetScreen)),
      );
      expect(container.read(worksheetProvider).worksheetId, isNull);
      // The placeholder is shown (default test window is the medium tier).
      expect(find.text('Select a worksheet'), findsOneWidget);
    });

    testWidgets('wraps worksheet content in the shared ReadableWidth cap', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp());
      selectTemplate(tester, 'length');
      await tester.pumpAndSettle();

      expect(find.byType(ReadableWidth), findsOneWidget);
    });

    testWidgets('shows rows for the selected template', (tester) async {
      await tester.pumpWidget(buildApp());
      selectTemplate(tester, 'length');
      await tester.pumpAndSettle();

      final activeTemplate = predefinedWorksheets.firstWhere(
        (t) => t.id == 'length',
      );

      // All row labels for the active template should be visible.
      for (final row in activeTemplate.rows) {
        expect(
          find.text(row.label),
          findsAtLeastNWidgets(1),
          reason: '${row.label} label not found',
        );
      }
    });

    testWidgets('shows row expression as secondary label', (tester) async {
      await tester.pumpWidget(buildApp());
      selectTemplate(tester, 'length');
      await tester.pumpAndSettle();

      final activeTemplate = predefinedWorksheets.firstWhere(
        (t) => t.id == 'length',
      );
      final firstExpression = activeTemplate.rows.first.expression;

      expect(find.text(firstExpression), findsAtLeastNWidgets(1));
    });

    testWidgets('dropdown lists templates in alphabetical order', (
      tester,
    ) async {
      // The AppBar dropdown is the compact-width selector; at medium/expanded
      // the templates are listed in a left pane instead (see
      // worksheet_two_pane_test.dart).
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(590, 800);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(buildApp());
      // A worksheet must be active for the dropdown selector to appear.
      selectTemplate(tester, 'length');
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();

      final expectedOrder = predefinedWorksheets.map((t) => t.name).toList()
        ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

      // Verify items appear in alphabetical top-to-bottom order.
      // Use skipOffstage: false so items scrolled off-screen are still found.
      double prevBottom = double.negativeInfinity;
      for (final name in expectedOrder) {
        final itemFinder = find.text(name, skipOffstage: false).last;
        final itemTop = tester.getTopLeft(itemFinder).dy;
        expect(
          itemTop,
          greaterThan(prevBottom),
          reason: '$name should appear below the previous item',
        );
        prevBottom = tester.getBottomLeft(itemFinder).dy;
      }
    });

    testWidgets('active row is not overwritten when engine updates', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp());
      selectTemplate(tester, 'length');
      await tester.pumpAndSettle();

      // Find the meters text field (first row of length worksheet).
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.first, '1');
      // Wait for debounce.
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump();

      // The first field should still show '1' (the user's input).
      final firstController = tester
          .widget<TextField>(textFields.first)
          .controller!;
      expect(firstController.text, '1');
    });
  });

  group('WorksheetScreen error display', () {
    // Typing -1 into the Kelvin row (below absolute zero) makes the Celsius
    // and Fahrenheit function rows produce "out of bounds" errors, while the
    // Rankine unit row converts normally.
    Future<void> pumpTemperatureError(WidgetTester tester) async {
      await tester.pumpWidget(buildApp());
      selectTemplate(tester, 'temperature');
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, '-1');
      // Wait for debounce.
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump();
    }

    testWidgets('erroring cell shows errorText below an empty field', (
      tester,
    ) async {
      await pumpTemperatureError(tester);

      final fields = tester
          .widgetList<TextField>(find.byType(TextField))
          .toList();
      final celsius = fields[1];
      expect(celsius.controller!.text, isEmpty);
      expect(celsius.decoration?.errorText, 'out of bounds');
    });

    testWidgets('erroring cell has no red text style override', (
      tester,
    ) async {
      await pumpTemperatureError(tester);

      final fields = tester
          .widgetList<TextField>(find.byType(TextField))
          .toList();
      expect(fields[1].style, isNull);
    });

    testWidgets('error is exposed to assistive technology', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpTemperatureError(tester);

      // The decoration's errorText is exposed as the text field's semantic
      // hint, so a screen reader reads the error when focusing the field.
      // With -1 K, four function rows error (Celsius, Fahrenheit, Réaumur,
      // gas mark).
      var errorHints = 0;
      void visit(SemanticsNode node) {
        if (node.hint == 'out of bounds') {
          errorHints++;
        }
        node.visitChildren((child) {
          visit(child);
          return true;
        });
      }

      var root = tester.getSemantics(find.byType(MaterialApp));
      while (root.parent != null) {
        root = root.parent!;
      }
      visit(root);
      expect(errorHints, 4);

      handle.dispose();
    });

    testWidgets('non-error cells are unaffected', (tester) async {
      await pumpTemperatureError(tester);

      final fields = tester
          .widgetList<TextField>(find.byType(TextField))
          .toList();
      // Kelvin row keeps the user's raw text.
      expect(fields[0].controller!.text, '-1');
      expect(fields[0].decoration?.errorText, isNull);
      // Rankine row shows a normal converted value with no error.
      expect(fields[3].controller!.text, isNotEmpty);
      expect(fields[3].decoration?.errorText, isNull);
    });

    testWidgets('valid input shows no errorText anywhere', (tester) async {
      await tester.pumpWidget(buildApp());
      selectTemplate(tester, 'temperature');
      await tester.pumpAndSettle();
      // 450 K is within every row's domain, including gas mark (oven range).
      await tester.enterText(find.byType(TextField).first, '450');
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump();

      final fields = tester
          .widgetList<TextField>(find.byType(TextField))
          .toList();
      for (final field in fields) {
        expect(field.decoration?.errorText, isNull);
      }
    });

    testWidgets('table renders cleanly with a taller error row present', (
      tester,
    ) async {
      await pumpTemperatureError(tester);

      // No layout exceptions, and the row labels alongside the taller
      // error cells remain visible.
      expect(tester.takeException(), isNull);
      expect(find.text('Celsius'), findsOneWidget);
      expect(find.text('Fahrenheit'), findsOneWidget);
    });
  });

  group('WorksheetScreen copy semantics', () {
    List<MethodCall> clipboardCalls = [];

    setUp(() {
      clipboardCalls = [];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
            if (call.method == 'Clipboard.setData') {
              clipboardCalls.add(call);
            }
            return null;
          });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });

    String? lastClipboardText() {
      if (clipboardCalls.isEmpty) {
        return null;
      }
      final args = clipboardCalls.last.arguments as Map;
      return args['text'] as String?;
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

    testWidgets('value field exposes a Copy value custom action', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(buildApp());
      selectTemplate(tester, 'length');
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, '1');
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump();

      final node = findCustomActionNode(tester, 'Copy value');
      expect(node, isNotNull);

      // Invoking the custom action copies the field's current text.
      final actionId = CustomSemanticsAction.getIdentifier(
        const CustomSemanticsAction(label: 'Copy value'),
      );
      node!.owner!.performAction(
        node.id,
        SemanticsAction.customAction,
        actionId,
      );
      await tester.pump();

      expect(lastClipboardText(), '1');

      handle.dispose();
    });

    testWidgets('Copy value action on an empty field is a no-op', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(buildApp());
      selectTemplate(tester, 'length');
      await tester.pumpAndSettle();

      final node = findCustomActionNode(tester, 'Copy value');
      expect(node, isNotNull);

      final actionId = CustomSemanticsAction.getIdentifier(
        const CustomSemanticsAction(label: 'Copy value'),
      );
      node!.owner!.performAction(
        node.id,
        SemanticsAction.customAction,
        actionId,
      );
      await tester.pump();

      expect(lastClipboardText(), isNull);

      handle.dispose();
    });
  });
}
