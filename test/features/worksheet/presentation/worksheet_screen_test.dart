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

  group('WorksheetScreen source row indicator', () {
    // Makes the first row of the length worksheet the source row by typing
    // into it, then settles the debounced recompute.
    Future<void> pumpWithSourceRow(WidgetTester tester) async {
      await tester.pumpWidget(buildApp());
      selectTemplate(tester, 'length');
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, '1');
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump();
    }

    OutlineInputBorder? enabledBorderOf(WidgetTester tester, int index) {
      final field = tester.widget<TextField>(find.byType(TextField).at(index));
      return field.decoration?.enabledBorder as OutlineInputBorder?;
    }

    testWidgets('source row shows a 2 dp primary border, others default', (
      tester,
    ) async {
      await pumpWithSourceRow(tester);

      final context = tester.element(find.byType(TextField).first);
      final primary = Theme.of(context).colorScheme.primary;

      final sourceBorder = enabledBorderOf(tester, 0);
      expect(sourceBorder, isNotNull);
      expect(sourceBorder!.borderSide.color, primary);
      expect(sourceBorder.borderSide.width, 2);

      // Non-source rows keep the default enabled border.
      expect(enabledBorderOf(tester, 1), isNull);
      expect(enabledBorderOf(tester, 2), isNull);
    });

    testWidgets('source row keeps the supplementary tint', (tester) async {
      await pumpWithSourceRow(tester);

      final fields = tester
          .widgetList<TextField>(find.byType(TextField))
          .toList();
      expect(fields[0].decoration?.filled, isTrue);
      expect(fields[0].decoration?.fillColor, isNotNull);
      expect(fields[1].decoration?.filled, isNot(isTrue));
    });

    testWidgets('source row height matches non-source row height', (
      tester,
    ) async {
      await pumpWithSourceRow(tester);

      final sourceHeight = tester.getSize(find.byType(TextField).first).height;
      final normalHeight = tester.getSize(find.byType(TextField).at(1)).height;
      expect(sourceHeight, normalHeight);
    });

    testWidgets('focus without keystroke does not move the border', (
      tester,
    ) async {
      await pumpWithSourceRow(tester);

      // Tap another row without typing; source ownership must not transfer.
      await tester.tap(find.byType(TextField).at(2));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump();

      expect(enabledBorderOf(tester, 0), isNotNull);
      expect(enabledBorderOf(tester, 2), isNull);
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

    testWidgets('erroring cell shows the message in-field with error color', (
      tester,
    ) async {
      await pumpTemperatureError(tester);

      final fields = tester
          .widgetList<TextField>(find.byType(TextField))
          .toList();
      final celsius = fields[1];
      expect(celsius.controller!.text, 'out of bounds');
      final context = tester.element(find.byType(TextField).at(1));
      expect(celsius.style?.color, Theme.of(context).colorScheme.error);
    });

    testWidgets('erroring cell shows an error prefix icon', (tester) async {
      await pumpTemperatureError(tester);

      // With -1 K, four function rows error (Celsius, Fahrenheit, Réaumur,
      // gas mark); each shows the freeform-style error icon.
      expect(find.byIcon(Icons.error_outline), findsNWidgets(4));
    });

    testWidgets('error state is exposed to assistive technology', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpTemperatureError(tester);

      // Each error icon carries an "Error" semantic label, so a screen
      // reader conveys the error state alongside the message text.
      expect(find.bySemanticsLabel('Error'), findsNWidgets(4));

      handle.dispose();
    });

    testWidgets('erroring fields are marked invalid in semantics', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpTemperatureError(tester);

      // The four erroring fields carry validationResult: invalid on their
      // own text-field semantics node; the two valid fields do not.
      var invalidFields = 0;
      var otherFields = 0;
      void visit(SemanticsNode node) {
        final data = node.getSemanticsData();
        if (data.flagsCollection.isTextField) {
          if (data.validationResult == SemanticsValidationResult.invalid) {
            invalidFields++;
          } else {
            otherFields++;
          }
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
      expect(invalidFields, 4);
      expect(otherFields, 2);

      handle.dispose();
    });

    testWidgets('error field height matches normal field height', (
      tester,
    ) async {
      await pumpTemperatureError(tester);

      // The prefix icon must not change the field height (its default 48 dp
      // minimum constraints are overridden), so row spacing stays uniform.
      final errorHeight = tester.getSize(find.byType(TextField).at(1)).height;
      final normalHeight = tester.getSize(find.byType(TextField).at(3)).height;
      expect(errorHeight, normalHeight);
    });

    testWidgets('non-error cells are unaffected', (tester) async {
      await pumpTemperatureError(tester);

      final fields = tester
          .widgetList<TextField>(find.byType(TextField))
          .toList();
      // Kelvin row keeps the user's raw text.
      expect(fields[0].controller!.text, '-1');
      expect(fields[0].style, isNull);
      expect(fields[0].decoration?.prefixIcon, isNull);
      // Rankine row shows a normal converted value with no error styling.
      expect(fields[3].controller!.text, isNotEmpty);
      expect(fields[3].style, isNull);
      expect(fields[3].decoration?.prefixIcon, isNull);
    });

    testWidgets('valid input shows no error icon anywhere', (tester) async {
      await tester.pumpWidget(buildApp());
      selectTemplate(tester, 'temperature');
      await tester.pumpAndSettle();
      // 450 K is within every row's domain, including gas mark (oven range).
      await tester.enterText(find.byType(TextField).first, '450');
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump();

      expect(find.byIcon(Icons.error_outline), findsNothing);
      final fields = tester
          .widgetList<TextField>(find.byType(TextField))
          .toList();
      for (final field in fields) {
        expect(field.style, isNull);
      }
    });
  });

  group('WorksheetScreen semantics geometry', () {
    testWidgets('field semantics rects align with their render rects', (
      tester,
    ) async {
      // Regression test for a RenderTable semantics bug: without an explicit
      // cell role on each cell (provided by TableCell), the table adds a
      // cell-offset transform on top of the child's own offset, shifting the
      // assistive-technology focus rectangle sideways off the real field.
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(buildApp());
      selectTemplate(tester, 'temperature');
      await tester.pumpAndSettle();

      // Collect the text-field semantics nodes in traversal order.
      final nodes = <SemanticsNode>[];
      void visit(SemanticsNode node) {
        if (node.getSemanticsData().flagsCollection.isTextField) {
          nodes.add(node);
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

      final fieldCount = tester
          .widgetList<TextField>(find.byType(TextField))
          .length;
      expect(nodes.length, fieldCount);

      // The root semantics transform is scaled by the device pixel ratio.
      final dpr = tester.view.devicePixelRatio;
      for (var i = 0; i < nodes.length; i++) {
        var transform = Matrix4.identity();
        SemanticsNode? n = nodes[i];
        while (n != null) {
          if (n.transform != null) {
            transform = (n.transform!.clone())..multiply(transform);
          }
          n = n.parent;
        }
        final semanticsRect = MatrixUtils.transformRect(
          transform,
          nodes[i].rect,
        );
        final renderRect = tester.getRect(find.byType(TextField).at(i));
        expect(
          semanticsRect.left,
          closeTo(renderRect.left * dpr, 0.1),
          reason: 'field $i semantics rect misaligned horizontally',
        );
        expect(
          semanticsRect.top,
          closeTo(renderRect.top * dpr, 0.1),
          reason: 'field $i semantics rect misaligned vertically',
        );
      }

      handle.dispose();
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
