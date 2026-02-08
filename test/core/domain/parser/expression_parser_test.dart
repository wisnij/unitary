import 'package:flutter_test/flutter_test.dart';
import 'package:unitary/core/domain/models/dimension.dart';
import 'package:unitary/core/domain/models/unit_repository.dart';
import 'package:unitary/core/domain/parser/ast.dart';
import 'package:unitary/core/domain/parser/expression_parser.dart';
import 'package:unitary/core/domain/parser/token.dart';
import 'package:unitary/core/domain/services/unit_service.dart';

void main() {
  final parser = ExpressionParser();

  group('ExpressionParser.evaluate', () {
    test('simple arithmetic', () {
      final result = parser.evaluate('2 + 3');
      expect(result.value, 5.0);
      expect(result.isDimensionless, isTrue);
    });

    test('expression with units', () {
      final result = parser.evaluate('5 m * 3');
      expect(result.value, 15.0);
      expect(result.dimension, Dimension({'m': 1}));
    });

    test('function call', () {
      final result = parser.evaluate('sqrt(9 m^2)');
      expect(result.value, 3.0);
      expect(result.dimension, Dimension({'m': 1}));
    });
  });

  group('ExpressionParser.parse', () {
    test('returns AST node', () {
      final node = parser.parse('5 + 3');
      expect(node, isA<BinaryOpNode>());
    });
  });

  group('ExpressionParser.tokenize', () {
    test('returns token list', () {
      final tokens = parser.tokenize('5 + 3');
      final types = tokens.map((t) => t.type).toList();
      expect(types, [
        TokenType.number,
        TokenType.plus,
        TokenType.number,
        TokenType.eof,
      ]);
    });
  });

  group('ExpressionParser with UnitRepository', () {
    late UnitRepository repo;
    late ExpressionParser repoParser;

    setUp(() {
      repo = UnitRepository.withBuiltinUnits();
      repoParser = ExpressionParser(repo: repo);
    });

    test('evaluate with repo resolves units to base', () {
      final result = repoParser.evaluate('5 ft');
      expect(result.value, closeTo(1.524, 1e-10));
      expect(result.dimension, Dimension({'m': 1}));
    });

    test('evaluate without repo uses raw dimension (Phase 1 behavior)', () {
      final noRepoParser = ExpressionParser();
      final result = noRepoParser.evaluate('5 m');
      expect(result.value, 5.0);
      expect(result.dimension, Dimension({'m': 1}));
    });

    test('evaluate with repo: arithmetic on mixed units', () {
      final result = repoParser.evaluate('5 ft + 1 m');
      expect(result.value, closeTo(2.524, 1e-10));
      expect(result.dimension, Dimension({'m': 1}));
    });
  });

  group('Phase 2 deliverable', () {
    test('convert 5 feet to meters and back', () {
      final repo = UnitRepository.withBuiltinUnits();
      final repoParser = ExpressionParser(repo: repo);

      // Evaluate "5 ft" — produces Quantity in base units (meters)
      final quantity = repoParser.evaluate('5 ft');
      expect(quantity.value, closeTo(1.524, 1e-10));
      expect(quantity.dimension, Dimension({'m': 1}));

      // Convert to feet explicitly
      final feet = repo.getUnit('ft');
      final inFeet = convert(quantity, feet, repo);
      expect(inFeet.value, closeTo(5.0, 1e-10));

      // Convert to miles
      final miles = repo.getUnit('mi');
      final inMiles = convert(quantity, miles, repo);
      expect(inMiles.value, closeTo(5.0 * 0.3048 / 1609.344, 1e-10));
    });
  });
}
