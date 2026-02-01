import 'package:flutter_test/flutter_test.dart';
import 'package:unitary/core/domain/models/dimension.dart';
import 'package:unitary/core/domain/parser/ast.dart';
import 'package:unitary/core/domain/parser/expression_parser.dart';
import 'package:unitary/core/domain/parser/token.dart';

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
}
