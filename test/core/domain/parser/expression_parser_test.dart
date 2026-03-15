import 'package:flutter_test/flutter_test.dart';
import 'package:unitary/core/domain/models/dimension.dart';
import 'package:unitary/core/domain/models/unit_repository.dart';
import 'package:unitary/core/domain/parser/ast.dart';
import 'package:unitary/core/domain/parser/expression_parser.dart';
import 'package:unitary/core/domain/parser/token.dart';

void main() {
  final parser = ExpressionParser(repo: UnitRepository.withPredefinedUnits());

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

  group('ExpressionParser.parseExpression', () {
    test('returns ExpressionNode', () {
      final node = parser.parseExpression('5 + 3');
      expect(node, isA<BinaryOpNode>());
    });
  });

  group('FunctionNameNode', () {
    test('forward reference stores name and inverse: false', () {
      const node = FunctionNameNode('tempF', inverse: false);
      expect(node.name, 'tempF');
      expect(node.inverse, isFalse);
    });

    test('inverse reference stores name and inverse: true', () {
      const node = FunctionNameNode('tempF', inverse: true);
      expect(node.name, 'tempF');
      expect(node.inverse, isTrue);
    });

    test('is an ASTNode but not an ExpressionNode', () {
      const node = FunctionNameNode('tempF', inverse: false);
      expect(node, isA<ASTNode>());
      expect(node, isNot(isA<ExpressionNode>()));
    });

    test('toString includes name and inverse flag', () {
      expect(
        const FunctionNameNode('tempF', inverse: false).toString(),
        'FunctionName(tempF, inverse: false)',
      );
      expect(
        const FunctionNameNode('tempF', inverse: true).toString(),
        'FunctionName(tempF, inverse: true)',
      );
    });
  });

  group('ExpressionParser.parseQuery', () {
    late UnitRepository repo;
    late ExpressionParser repoParser;
    late ExpressionParser noRepoParser;

    setUp(() {
      repo = UnitRepository.withPredefinedUnits();
      repoParser = ExpressionParser(repo: repo);
      noRepoParser = ExpressionParser();
    });

    test(
      'bare known-function name returns FunctionNameNode(inverse: false)',
      () {
        final node = repoParser.parseQuery('tempF');
        expect(node, isA<FunctionNameNode>());
        final fn = node as FunctionNameNode;
        expect(fn.name, 'tempF');
        expect(fn.inverse, isFalse);
      },
    );

    test('~funcName returns FunctionNameNode(inverse: true)', () {
      final node = repoParser.parseQuery('~tempF');
      expect(node, isA<FunctionNameNode>());
      final fn = node as FunctionNameNode;
      expect(fn.name, 'tempF');
      expect(fn.inverse, isTrue);
    });

    test(
      'bare unit identifier (not a function) delegates to parseExpression',
      () {
        final node = repoParser.parseQuery('meter');
        expect(node, isA<UnitNode>());
        expect((node as UnitNode).unitName, 'meter');
      },
    );

    test('multi-token input delegates to parseExpression', () {
      final node = repoParser.parseQuery('5 km');
      expect(node, isA<BinaryOpNode>());
    });

    test('function call with parens delegates to parseExpression', () {
      final node = repoParser.parseQuery('tempF(32)');
      expect(node, isA<FunctionCallNode>());
    });

    test('without a repository all inputs delegate to parseExpression', () {
      final node = noRepoParser.parseQuery('tempF');
      // Without repo, "tempF" is treated as a raw UnitNode.
      expect(node, isA<ExpressionNode>());
      expect(node, isNot(isA<FunctionNameNode>()));
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
      repo = UnitRepository.withPredefinedUnits();
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
    test('evaluate 5 feet and convert via division', () {
      final repo = UnitRepository.withPredefinedUnits();
      final repoParser = ExpressionParser(repo: repo);

      // Evaluate "5 ft" — produces Quantity in base units (meters)
      final quantity = repoParser.evaluate('5 ft');
      expect(quantity.value, closeTo(1.524, 1e-10));
      expect(quantity.dimension, Dimension({'m': 1}));

      // Convert to feet: divide base value by 1 ft in base units
      final feetBase = repoParser.evaluate('ft');
      final inFeet = quantity.value / feetBase.value;
      expect(inFeet, closeTo(5.0, 1e-10));

      // Convert to miles: divide base value by 1 mi in base units
      final milesBase = repoParser.evaluate('mi');
      final inMiles = quantity.value / milesBase.value;
      expect(inMiles, closeTo(5.0 * 0.3048 / 1609.344, 1e-10));
    });
  });
}
