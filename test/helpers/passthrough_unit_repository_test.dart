import 'package:flutter_test/flutter_test.dart';
import 'package:unitary/core/domain/models/dimension.dart';
import 'package:unitary/core/domain/models/unit.dart';
import 'package:unitary/core/domain/parser/expression_parser.dart';

import 'passthrough_unit_repository.dart';

void main() {
  group('PassthroughUnitRepository', () {
    late PassthroughUnitRepository repo;

    setUp(() {
      repo = PassthroughUnitRepository();
    });

    test('findUnit returns a non-null PrimitiveUnit for any name', () {
      final unit = repo.findUnit('wakalixes');
      expect(unit, isA<PrimitiveUnit>());
      expect(unit!.id, 'wakalixes');
    });

    test('findUnit returns a PrimitiveUnit for an empty string', () {
      final unit = repo.findUnit('');
      expect(unit, isA<PrimitiveUnit>());
    });

    test('findUnitWithPrefix returns a UnitMatch with a PrimitiveUnit', () {
      final match = repo.findUnitWithPrefix('wakalixes');
      expect(match.unit, isA<PrimitiveUnit>());
      expect(match.unit!.id, 'wakalixes');
      expect(match.prefix, isNull);
    });

    test(
      "evaluating '5 wakalixes' produces Quantity(5.0, {'wakalixes': 1})",
      () {
        final result = ExpressionParser(repo: repo).evaluate('5 wakalixes');
        expect(result.value, 5.0);
        expect(result.dimension, Dimension({'wakalixes': 1}));
      },
    );
  });
}
