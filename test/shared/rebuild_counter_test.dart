import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'rebuild_counter.dart';

class _Harness extends StatefulWidget {
  const _Harness();

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  int value = 0;

  void increment() {
    setState(() {
      value++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Child(value: value),
        const _Bystander(),
      ],
    );
  }
}

class _Child extends StatelessWidget {
  const _Child({required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    return Text('$value', textDirection: TextDirection.ltr);
  }
}

class _Bystander extends StatelessWidget {
  const _Bystander();

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}

void main() {
  testWidgets('counts rebuilds by widget type after installation', (
    tester,
  ) async {
    await tester.pumpWidget(const _Harness());

    final counter = RebuildCounter()..install(tester);
    addTearDown(() => counter.uninstall(tester));

    expect(counter.of('_Harness'), 0, reason: 'initial pump not counted');

    tester.state<_HarnessState>(find.byType(_Harness)).increment();
    await tester.pump();

    expect(counter.of('_Harness'), 1);
    expect(counter.of('_Child'), 1);
    expect(
      counter.of('_Bystander'),
      0,
      reason: 'const child is not rebuilt by parent setState',
    );
  });

  testWidgets('reset clears accumulated counts', (tester) async {
    await tester.pumpWidget(const _Harness());

    final counter = RebuildCounter()..install(tester);
    addTearDown(() => counter.uninstall(tester));

    tester.state<_HarnessState>(find.byType(_Harness)).increment();
    await tester.pump();
    expect(counter.of('_Harness'), 1);

    counter.reset();
    expect(counter.of('_Harness'), 0);
  });

  testWidgets('uninstall stops counting', (tester) async {
    await tester.pumpWidget(const _Harness());

    final counter = RebuildCounter()..install(tester);
    counter.uninstall(tester);

    tester.state<_HarnessState>(find.byType(_Harness)).increment();
    await tester.pump();

    expect(counter.of('_Harness'), 0);
  });
}
