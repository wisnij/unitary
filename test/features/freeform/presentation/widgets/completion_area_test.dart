import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:unitary/core/domain/models/completion_entry.dart';
import 'package:unitary/features/freeform/presentation/widgets/completion_area.dart';

CompletionEntry _entry(
  String name, [
  CompletionEntryKind kind = CompletionEntryKind.unit,
]) => CompletionEntry(name: name, isPrimaryId: true, entryKind: kind);

/// Finds the chip label [text] inside the completion area (and not the same
/// text in an expression field).
Finder _chip(String text) => find.descendant(
  of: find.byType(CompletionArea),
  matching: find.text(text),
);

/// All chips, each sized to its touch target.
final Finder _chips = find.descendant(
  of: find.byType(CompletionArea),
  matching: find.byType(OutlinedButton),
);

/// The pill of the chip labelled [text]: the region that draws the border
/// and the hover and press highlights.
Finder _pill(String text) => find.ancestor(
  of: _chip(text),
  matching: find.descendant(
    of: find.byType(CompletionArea),
    matching: find.byType(InkWell),
  ),
);

/// The area's scroll offset.
double _scrollOffset(WidgetTester tester) => tester
    .state<ScrollableState>(
      find.descendant(
        of: find.byType(CompletionArea),
        matching: find.byType(Scrollable),
      ),
    )
    .position
    .pixels;

/// Pumps a bare [CompletionArea] of the given size.
Future<void> _pumpArea(
  WidgetTester tester, {
  required List<CompletionEntry> suggestions,
  ValueChanged<CompletionEntry>? onSelected,
  Size size = const Size(400, 200),
}) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox.fromSize(
            size: size,
            child: CompletionArea(
              suggestions: suggestions,
              onSelected: onSelected ?? (_) {},
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('completion labels', () {
    test('every completion kind yields a name+kind label (coverage)', () {
      // Coverage guard: iterate the whole enum so a new CompletionEntryKind
      // added without a label word fails here (in addition to the compile-time
      // guard from the exhaustive switch in completionSemanticLabel).
      for (final kind in CompletionEntryKind.values) {
        final label = completionSemanticLabel(_entry('foo', kind));
        expect(label, contains('foo'), reason: 'label "$label" missing name');
        expect(
          label,
          contains(kind.name),
          reason: 'label "$label" missing kind word "${kind.name}"',
        );
      }
    });

    test('semantic labels use the "<name>, <kind>" form', () {
      expect(completionSemanticLabel(_entry('meter')), 'meter, unit');
      expect(
        completionSemanticLabel(_entry('kilo', CompletionEntryKind.prefix)),
        'kilo, prefix',
      );
      expect(
        completionSemanticLabel(_entry('tempC', CompletionEntryKind.function)),
        'tempC, function',
      );
    });

    test('display names are annotated by kind', () {
      expect(completionDisplayName(_entry('kg')), 'kg');
      expect(
        completionDisplayName(_entry('kilo', CompletionEntryKind.prefix)),
        'kilo-',
      );
      expect(
        completionDisplayName(_entry('tempC', CompletionEntryKind.function)),
        'tempC(',
      );
    });

    test('insert text is specific to the kind', () {
      expect(completionInsertText(_entry('kg')), 'kg ');
      expect(
        completionInsertText(_entry('kilo', CompletionEntryKind.prefix)),
        'kilo',
      );
      expect(
        completionInsertText(_entry('tempC', CompletionEntryKind.function)),
        'tempC(',
      );
    });
  });

  group('CompletionArea', () {
    testWidgets('shows no chips without suggestions', (tester) async {
      await _pumpArea(tester, suggestions: const []);
      expect(_chips, findsNothing);
    });

    testWidgets('shows kind-annotated chips in the order given', (
      tester,
    ) async {
      await _pumpArea(
        tester,
        suggestions: [
          _entry('kg'),
          _entry('kilo', CompletionEntryKind.prefix),
          _entry('tempC', CompletionEntryKind.function),
        ],
      );

      expect(_chips, findsNWidgets(3));
      final kg = tester.getRect(_chip('kg'));
      final kilo = tester.getRect(_chip('kilo-'));
      final tempC = tester.getRect(_chip('tempC('));
      // One line, left to right.
      expect(kg.center.dy, kilo.center.dy);
      expect(kilo.center.dy, tempC.center.dy);
      expect(kg.right, lessThan(kilo.left));
      expect(kilo.right, lessThan(tempC.left));
    });

    testWidgets('wraps onto further lines, keeping rank order', (
      tester,
    ) async {
      final suggestions = [for (var i = 0; i < 12; i++) _entry('unitname$i')];
      await _pumpArea(tester, suggestions: suggestions);

      final first = tester.getRect(_chips.first);
      final last = tester.getRect(_chips.last);
      expect(last.top, greaterThan(first.top), reason: 'chips wrapped');

      // Reading order (top to bottom, then left to right) matches the list.
      final rects = [
        for (final s in suggestions) tester.getRect(_chip(s.name)),
      ];
      for (var i = 1; i < rects.length; i++) {
        final sameLine = rects[i].center.dy == rects[i - 1].center.dy;
        if (sameLine) {
          expect(rects[i].left, greaterThan(rects[i - 1].right));
        } else {
          expect(rects[i].center.dy, greaterThan(rects[i - 1].center.dy));
        }
      }
    });

    testWidgets('each chip has a touch target of at least 48 × 48 dp', (
      tester,
    ) async {
      await _pumpArea(
        tester,
        suggestions: [_entry('kg'), _entry('internationalnauticalmile')],
      );

      for (final element in _chips.evaluate()) {
        final size = (element.renderObject! as RenderBox).size;
        expect(size.height, greaterThanOrEqualTo(48));
        expect(size.width, greaterThanOrEqualTo(48));
      }
    });

    testWidgets('highlights stay inside the pill, which is 32 dp high', (
      tester,
    ) async {
      await _pumpArea(
        tester,
        suggestions: [_entry('li'), _entry('internationalnauticalmile')],
      );

      for (final name in ['li', 'internationalnauticalmile']) {
        final pill = tester.getRect(_pill(name));
        final target = tester.getRect(
          find.ancestor(of: _chip(name), matching: _chips),
        );
        expect(pill.height, 32, reason: name);
        // The pill is centred in the taller touch target and spans its width.
        expect(pill.center.dy, target.center.dy, reason: name);
        expect(pill.left, target.left, reason: name);
        expect(pill.right, target.right, reason: name);
      }
    });

    testWidgets('a narrow chip is a 48 dp pill flush with the left inset', (
      tester,
    ) async {
      // A one-character label is narrower than the minimum (the test font
      // is wider than the real one, so 'li' would not be).  The long names
      // push later chips onto new lines.
      await _pumpArea(
        tester,
        suggestions: [
          _entry('l'),
          _entry('x' * 40),
          _entry('y' * 40),
        ],
      );

      final narrow = tester.getRect(_pill('l'));
      final nextLine = tester.getRect(_pill('y' * 40));
      expect(narrow.width, 48);
      expect(nextLine.top, greaterThan(narrow.bottom));
      expect(narrow.left, nextLine.left, reason: 'no extra indentation');
      expect(narrow.left, 16);
    });

    testWidgets('a tap in the padding around the pill selects the chip', (
      tester,
    ) async {
      final selected = <CompletionEntry>[];
      final li = _entry('li');
      await _pumpArea(tester, suggestions: [li], onSelected: selected.add);

      final pill = tester.getRect(_pill('li'));
      await tester.tapAt(Offset(pill.center.dx, pill.top - 4));
      expect(selected, [li]);
    });

    testWidgets('a chip is never wider than the area', (tester) async {
      await _pumpArea(
        tester,
        suggestions: [_entry('x' * 80)],
        size: const Size(200, 200),
      );

      final area = tester.getRect(find.byType(CompletionArea));
      final chip = tester.getRect(_chips);
      expect(chip.left, greaterThanOrEqualTo(area.left));
      expect(chip.right, lessThanOrEqualTo(area.right));
      expect(tester.takeException(), isNull);
    });

    testWidgets('tapping a chip reports its suggestion', (tester) async {
      final selected = <CompletionEntry>[];
      final kilo = _entry('kilo', CompletionEntryKind.prefix);
      await _pumpArea(
        tester,
        suggestions: [_entry('kg'), kilo],
        onSelected: selected.add,
      );

      await tester.tap(_chip('kilo-'));
      expect(selected, [kilo]);
    });

    testWidgets('chips expose "<name>, <kind>" labels, one per chip', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await _pumpArea(
        tester,
        suggestions: [
          _entry('meter'),
          _entry('kilo', CompletionEntryKind.prefix),
          _entry('tempC', CompletionEntryKind.function),
        ],
      );

      expect(find.bySemanticsLabel('meter, unit'), findsOneWidget);
      expect(find.bySemanticsLabel('kilo, prefix'), findsOneWidget);
      expect(find.bySemanticsLabel('tempC, function'), findsOneWidget);
      // The visible text keeps its trailing punctuation.
      expect(_chip('kilo-'), findsOneWidget);
      // A chip that bypassed the Semantics wrapper would break this count.
      expect(
        find.bySemanticsLabel(RegExp(r', (unit|prefix|function)$')),
        findsNWidgets(_chips.evaluate().length),
      );
      handle.dispose();
    });

    testWidgets('scrolls so that every suggestion can be reached', (
      tester,
    ) async {
      final selected = <CompletionEntry>[];
      final suggestions = [for (var i = 0; i < 50; i++) _entry('unitname$i')];
      await _pumpArea(
        tester,
        suggestions: suggestions,
        onSelected: selected.add,
        size: const Size(400, 96),
      );

      final area = tester.getRect(find.byType(CompletionArea));
      expect(
        tester.getRect(_chip('unitname49')).top,
        greaterThan(area.bottom),
        reason: 'the last chip starts below the visible area',
      );

      await tester.scrollUntilVisible(
        _chip('unitname49'),
        48,
        scrollable: find.descendant(
          of: find.byType(CompletionArea),
          matching: find.byType(Scrollable),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(_chip('unitname49'));
      expect(selected, [suggestions.last]);
    });

    testWidgets('scroll position returns to the top when suggestions change', (
      tester,
    ) async {
      final first = [for (var i = 0; i < 50; i++) _entry('unitname$i')];
      await _pumpArea(tester, suggestions: first, size: const Size(400, 96));

      await tester.drag(find.byType(CompletionArea), const Offset(0, -150));
      await tester.pumpAndSettle();
      expect(_scrollOffset(tester), greaterThan(0));

      // The same list keeps the position...
      await _pumpArea(tester, suggestions: first, size: const Size(400, 96));
      expect(_scrollOffset(tester), greaterThan(0));

      // ...a new one resets it.
      final second = [for (var i = 0; i < 50; i++) _entry('othername$i')];
      await _pumpArea(tester, suggestions: second, size: const Size(400, 96));
      expect(_scrollOffset(tester), 0);
    });
  });

  group('CompletionAreaLayout', () {
    late TextEditingController fromController;
    late TextEditingController toController;
    late FocusNode fromFocus;
    late FocusNode toFocus;
    late List<String> fromChanges;
    late List<String> toChanges;

    const fromKey = Key('from');
    const toKey = Key('to');
    const contentKey = Key('content');

    setUp(() {
      fromController = TextEditingController();
      toController = TextEditingController();
      fromFocus = FocusNode();
      toFocus = FocusNode();
      fromChanges = [];
      toChanges = [];
    });

    tearDown(() {
      fromController.dispose();
      toController.dispose();
      fromFocus.dispose();
      toFocus.dispose();
    });

    /// Pumps two plain fields above a completion area, in a 400×[height] box.
    /// [spacer] adds height to the content.
    Future<void> pumpLayout(
      WidgetTester tester, {
      double height = 500,
      double spacer = 0,
    }) {
      return tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Align(
                alignment: Alignment.topLeft,
                child: SizedBox(
                  width: 400,
                  height: height,
                  child: CompletionAreaLayout(
                    targets: [
                      CompletionTarget(
                        controller: fromController,
                        focusNode: fromFocus,
                        onChanged: fromChanges.add,
                      ),
                      CompletionTarget(
                        controller: toController,
                        focusNode: toFocus,
                        onChanged: toChanges.add,
                      ),
                    ],
                    child: SingleChildScrollView(
                      key: contentKey,
                      child: Column(
                        children: [
                          TextField(
                            key: fromKey,
                            controller: fromController,
                            focusNode: fromFocus,
                          ),
                          TextField(
                            key: toKey,
                            controller: toController,
                            focusNode: toFocus,
                          ),
                          SizedBox(height: spacer),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    /// Focuses the field with [key] and sets its text with the cursor at the
    /// end.
    Future<void> type(WidgetTester tester, Key key, String text) async {
      await tester.tap(find.byKey(key));
      await tester.pump();
      final controller = key == fromKey ? fromController : toController;
      controller.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
      await tester.pump();
    }

    testWidgets('shows no chips initially', (tester) async {
      await pumpLayout(tester);
      expect(_chips, findsNothing);
    });

    testWidgets('shows ranked chips for the focused field', (tester) async {
      await pumpLayout(tester);
      await type(tester, fromKey, 'kg');

      expect(_chip('kg'), findsOneWidget);
      // The exact match is the first chip.
      expect(
        find.descendant(of: _chips.first, matching: find.text('kg')),
        findsOneWidget,
      );
    });

    testWidgets('shows kind-annotated chips from the repository', (
      tester,
    ) async {
      await pumpLayout(tester);
      await type(tester, fromKey, 'kilo');
      expect(_chip('kilo-'), findsOneWidget);

      await type(tester, fromKey, 'temp');
      expect(_chip('tempC('), findsOneWidget);
    });

    testWidgets('shows no chips when nothing matches', (tester) async {
      await pumpLayout(tester);
      await type(tester, fromKey, 'zzz');
      expect(_chips, findsNothing);
    });

    testWidgets('shows no chips for a single-character token', (tester) async {
      await pumpLayout(tester);
      await type(tester, fromKey, 'k');
      expect(_chips, findsNothing);
    });

    testWidgets('shows no chips when the cursor is not at the token end', (
      tester,
    ) async {
      await pumpLayout(tester);
      await type(tester, fromKey, 'kilogram');
      expect(_chips, findsWidgets);

      fromController.selection = const TextSelection.collapsed(offset: 4);
      await tester.pump();
      expect(_chips, findsNothing);
    });

    testWidgets('clears the chips when the token is deleted', (tester) async {
      await pumpLayout(tester);
      await type(tester, fromKey, 'kg');
      expect(_chips, findsWidgets);

      await type(tester, fromKey, '');
      expect(_chips, findsNothing);
    });

    testWidgets('clears the chips when focus is lost', (tester) async {
      await pumpLayout(tester);
      await type(tester, fromKey, 'kg');
      expect(_chips, findsWidgets);

      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pump();
      await tester.pump();
      expect(_chips, findsNothing);
    });

    testWidgets('shows only the focused field\'s suggestions', (tester) async {
      await pumpLayout(tester);
      await type(tester, fromKey, 'kg');
      expect(_chip('kg'), findsOneWidget);

      await type(tester, toKey, 'met');
      expect(_chip('kg'), findsNothing);
      expect(_chip('meter'), findsOneWidget);
    });

    testWidgets('a unit chip inserts the name and a space, then clears', (
      tester,
    ) async {
      await pumpLayout(tester);
      await type(tester, fromKey, '5 kilogra');

      await tester.tap(_chip('kilogram'));
      await tester.pump();
      await tester.pump();

      expect(fromController.text, '5 kilogram ');
      expect(fromController.selection.baseOffset, 11);
      expect(fromChanges, ['5 kilogram ']);
      expect(fromFocus.hasFocus, isTrue);
      expect(_chips, findsNothing);
    });

    testWidgets('a prefix chip inserts the name without the dash', (
      tester,
    ) async {
      await pumpLayout(tester);
      await type(tester, fromKey, 'kilo');

      await tester.tap(_chip('kilo-'));
      await tester.pump();

      expect(fromController.text, 'kilo');
      expect(fromChanges, ['kilo']);
    });

    testWidgets('a function chip inserts the name and parenthesis', (
      tester,
    ) async {
      await pumpLayout(tester);
      await type(tester, fromKey, 'tempC');

      await tester.tap(_chip('tempC('));
      await tester.pump();
      await tester.pump();

      expect(fromController.text, 'tempC(');
      expect(fromController.selection.baseOffset, 6);
      expect(fromChanges, ['tempC(']);
      // The cursor follows '(', which is not an identifier.
      expect(_chips, findsNothing);
    });

    testWidgets('a chip is inserted into the focused field only', (
      tester,
    ) async {
      await pumpLayout(tester);
      await type(tester, fromKey, 'kg');
      await type(tester, toKey, 'tempC');

      await tester.tap(_chip('tempC('));
      await tester.pump();

      expect(toController.text, 'tempC(');
      expect(toChanges, ['tempC(']);
      expect(toFocus.hasFocus, isTrue);
      expect(fromController.text, 'kg');
      expect(fromChanges, isEmpty);
    });

    testWidgets('the area fills the height below the content', (tester) async {
      await pumpLayout(tester);
      await type(tester, fromKey, 'kg');

      final content = tester.getRect(find.byKey(contentKey));
      final area = tester.getRect(find.byType(CompletionArea));
      expect(area.top, content.bottom);
      expect(area.bottom, 500);
      expect(area.height, greaterThan(48));
    });

    testWidgets('showing chips does not move content that leaves room', (
      tester,
    ) async {
      await pumpLayout(tester);
      await tester.tap(find.byKey(fromKey));
      await tester.pump();
      final before = tester.getRect(find.byKey(contentKey));

      await type(tester, fromKey, 'kg');
      expect(_chips, findsWidgets);
      expect(tester.getRect(find.byKey(contentKey)), before);
    });

    testWidgets('the area keeps one chip line when the content is tall', (
      tester,
    ) async {
      await pumpLayout(tester, height: 300, spacer: 600);

      // No suggestions: the content has the whole height.
      expect(tester.getSize(find.byKey(contentKey)).height, 300);
      expect(tester.getSize(find.byType(CompletionArea)).height, 0);

      await type(tester, fromKey, 'kg');
      expect(tester.getSize(find.byKey(contentKey)).height, 252);
      expect(tester.getSize(find.byType(CompletionArea)).height, 48);
      expect(_chip('kg'), findsOneWidget);
    });
  });
}
