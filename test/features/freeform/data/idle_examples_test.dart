import 'package:flutter_test/flutter_test.dart';
import 'package:unitary/core/domain/models/unit_repository.dart';
import 'package:unitary/core/domain/parser/expression_parser.dart';
import 'package:unitary/features/freeform/data/idle_examples.dart';

void main() {
  late UnitRepository repo;

  setUp(() {
    repo = UnitRepository.withPredefinedUnits();
  });

  group('idleExamples', () {
    test('list has at least 10 entries', () {
      expect(idleExamples.length, greaterThanOrEqualTo(10));
    });

    test('all examples evaluate without error', () {
      final parser = ExpressionParser(repo: repo);
      final failures = <String>[];
      for (final example in idleExamples) {
        try {
          parser.evaluate(example);
        } catch (e) {
          failures.add('$example: $e');
        }
      }
      expect(failures, isEmpty, reason: 'Failing examples: $failures');
    });
  });
}
