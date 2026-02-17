import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:unitary/core/domain/parser/expression_parser.dart';
import 'package:unitary/features/freeform/state/parser_provider.dart';

void main() {
  group('parserProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('provides an ExpressionParser', () {
      final parser = container.read(parserProvider);
      expect(parser, isA<ExpressionParser>());
    });

    test('parser can evaluate simple expressions', () {
      final parser = container.read(parserProvider);
      final result = parser.evaluate('2 + 3');
      expect(result.value, 5.0);
      expect(result.isDimensionless, isTrue);
    });

    test('parser can evaluate expressions with units', () {
      final parser = container.read(parserProvider);
      final result = parser.evaluate('5 ft');
      expect(result.value, closeTo(1.524, 1e-6));
      expect(result.dimension.units, containsPair('m', 1));
    });

    test('parser can evaluate unit conversions', () {
      final parser = container.read(parserProvider);
      final miles = parser.evaluate('5 miles');
      final km = parser.evaluate('km');
      expect(miles.isConformableWith(km), isTrue);
    });

    test('returns same instance on multiple reads', () {
      final parser1 = container.read(parserProvider);
      final parser2 = container.read(parserProvider);
      expect(identical(parser1, parser2), isTrue);
    });
  });
}
