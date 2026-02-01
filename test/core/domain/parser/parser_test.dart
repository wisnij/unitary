import 'package:flutter_test/flutter_test.dart';
import 'package:unitary/core/domain/errors.dart';
import 'package:unitary/core/domain/parser/ast.dart';
import 'package:unitary/core/domain/parser/lexer.dart';
import 'package:unitary/core/domain/parser/parser.dart';
import 'package:unitary/core/domain/parser/token.dart';

ASTNode parse(String input) {
  final tokens = Lexer(input).scanTokens();
  return Parser(tokens).parse();
}

void main() {
  group('Parser: simple expressions', () {
    test('number literal', () {
      final node = parse('42');
      expect(node, isA<NumberNode>());
      expect((node as NumberNode).value, 42.0);
    });

    test('unit identifier', () {
      final node = parse('m');
      expect(node, isA<UnitNode>());
      expect((node as UnitNode).unitName, 'm');
    });

    test('addition', () {
      final node = parse('1 + 2');
      expect(node, isA<BinaryOpNode>());
      final bin = node as BinaryOpNode;
      expect(bin.operator, TokenType.plus);
      expect(bin.left, isA<NumberNode>());
      expect(bin.right, isA<NumberNode>());
    });

    test('subtraction', () {
      final node = parse('5 - 3');
      expect(node, isA<BinaryOpNode>());
      expect((node as BinaryOpNode).operator, TokenType.minus);
    });

    test('multiplication', () {
      final node = parse('2 * 3');
      expect(node, isA<BinaryOpNode>());
      expect((node as BinaryOpNode).operator, TokenType.multiply);
    });

    test('division', () {
      final node = parse('6 / 2');
      expect(node, isA<BinaryOpNode>());
      expect((node as BinaryOpNode).operator, TokenType.divide);
    });
  });

  group('Parser: operator precedence', () {
    test('multiplication before addition: 1 + 2 * 3', () {
      // Should parse as 1 + (2 * 3)
      final node = parse('1 + 2 * 3') as BinaryOpNode;
      expect(node.operator, TokenType.plus);
      expect(node.left, isA<NumberNode>());
      expect(node.right, isA<BinaryOpNode>());
      expect((node.right as BinaryOpNode).operator, TokenType.multiply);
    });

    test('multiplication before subtraction: 5 - 2 * 3', () {
      final node = parse('5 - 2 * 3') as BinaryOpNode;
      expect(node.operator, TokenType.minus);
      expect(node.right, isA<BinaryOpNode>());
    });

    test('parentheses override precedence: (1 + 2) * 3', () {
      final node = parse('(1 + 2) * 3') as BinaryOpNode;
      expect(node.operator, TokenType.multiply);
      expect(node.left, isA<BinaryOpNode>());
      expect((node.left as BinaryOpNode).operator, TokenType.plus);
    });

    test('left-to-right: 10 - 3 - 2', () {
      // Should parse as (10 - 3) - 2
      final node = parse('10 - 3 - 2') as BinaryOpNode;
      expect(node.operator, TokenType.minus);
      expect(node.left, isA<BinaryOpNode>());
      expect((node.left as BinaryOpNode).operator, TokenType.minus);
    });
  });

  group('Parser: exponentiation', () {
    test('basic exponent: 2^3', () {
      final node = parse('2^3') as BinaryOpNode;
      expect(node.operator, TokenType.power);
    });

    test('** as exponent: 2**3', () {
      final node = parse('2**3') as BinaryOpNode;
      expect(node.operator, TokenType.power);
    });

    test('right-associative: 2^3^4 = 2^(3^4)', () {
      final node = parse('2^3^4') as BinaryOpNode;
      expect(node.operator, TokenType.power);
      expect(node.left, isA<NumberNode>());
      // Right should be another power
      expect(node.right, isA<BinaryOpNode>());
      expect((node.right as BinaryOpNode).operator, TokenType.power);
    });

    test('exponent higher than multiply: 2 * 3^4', () {
      // Should parse as 2 * (3^4)
      final node = parse('2 * 3^4') as BinaryOpNode;
      expect(node.operator, TokenType.multiply);
      expect(node.right, isA<BinaryOpNode>());
      expect((node.right as BinaryOpNode).operator, TokenType.power);
    });
  });

  group('Parser: unary operators', () {
    test('unary minus: -5', () {
      final node = parse('-5');
      expect(node, isA<UnaryOpNode>());
      final unary = node as UnaryOpNode;
      expect(unary.operator, TokenType.minus);
      expect(unary.operand, isA<NumberNode>());
    });

    test('unary plus: +5', () {
      final node = parse('+5');
      expect(node, isA<UnaryOpNode>());
      expect((node as UnaryOpNode).operator, TokenType.plus);
    });

    test('double negative: --5', () {
      final node = parse('--5') as UnaryOpNode;
      expect(node.operator, TokenType.minus);
      expect(node.operand, isA<UnaryOpNode>());
    });

    test('unary binds tighter than ^: -2^3 = (-2)^3', () {
      // With unary tighter than ^, -2^3 should parse as (-2)^3
      final node = parse('-2^3') as BinaryOpNode;
      expect(node.operator, TokenType.power);
      expect(node.left, isA<UnaryOpNode>());
      expect(node.right, isA<NumberNode>());
    });

    test('2^-3 = 2^(-3)', () {
      final node = parse('2^-3') as BinaryOpNode;
      expect(node.operator, TokenType.power);
      expect(node.left, isA<NumberNode>());
      expect(node.right, isA<UnaryOpNode>());
    });
  });

  group('Parser: high-precedence division |', () {
    test('basic: 1|2', () {
      final node = parse('1|2') as BinaryOpNode;
      expect(node.operator, TokenType.divideHigh);
      expect(node.left, isA<NumberNode>());
      expect(node.right, isA<NumberNode>());
    });

    test('chained: 1|2|3', () {
      // Left-associative: (1|2)|3
      final node = parse('1|2|3') as BinaryOpNode;
      expect(node.operator, TokenType.divideHigh);
      expect(node.left, isA<BinaryOpNode>());
      expect(node.right, isA<NumberNode>());
    });

    test('| higher than ^: 1|2^3 = (1|2)^3', () {
      // | is higher precedence than ^, so this parses as (1|2)^3.
      // But wait — in the grammar, highDivision is called from
      // exponentiation, so exponentiation → highDivision ('^' unary)?
      // This means the left side of ^ is parsed at highDivision level,
      // so 1|2^3 parses as (1|2)^3. Let's verify:
      final node = parse('1|2^3') as BinaryOpNode;
      expect(node.operator, TokenType.power);
      expect(node.left, isA<BinaryOpNode>());
      expect((node.left as BinaryOpNode).operator, TokenType.divideHigh);
    });

    test('non-numeric left operand throws', () {
      expect(() => parse('m|2'), throwsA(isA<ParseException>()));
    });

    test('non-numeric right operand throws', () {
      expect(() => parse('1|m'), throwsA(isA<ParseException>()));
    });

    test('expression operand throws', () {
      expect(() => parse('(1+2)|3'), throwsA(isA<ParseException>()));
    });
  });

  group('Parser: implicit multiplication', () {
    test('number unit: 5 m', () {
      final node = parse('5 m') as BinaryOpNode;
      expect(node.operator, TokenType.multiply);
      expect(node.left, isA<NumberNode>());
      expect(node.right, isA<UnitNode>());
    });

    test('number number: 2 3', () {
      final node = parse('2 3') as BinaryOpNode;
      expect(node.operator, TokenType.multiply);
    });

    test('unit unit: m s', () {
      final node = parse('m s') as BinaryOpNode;
      expect(node.operator, TokenType.multiply);
      expect(node.left, isA<UnitNode>());
      expect(node.right, isA<UnitNode>());
    });

    test('number no-space unit: 5m', () {
      final node = parse('5m') as BinaryOpNode;
      expect(node.operator, TokenType.multiply);
    });

    test('implicit multiply with parens: (2)(3)', () {
      final node = parse('(2)(3)') as BinaryOpNode;
      expect(node.operator, TokenType.multiply);
    });
  });

  group('Parser: function calls', () {
    test('single argument function: sin(0.5)', () {
      final node = parse('sin(0.5)');
      expect(node, isA<FunctionNode>());
      final func = node as FunctionNode;
      expect(func.name, 'sin');
      expect(func.arguments.length, 1);
      expect(func.arguments[0], isA<NumberNode>());
    });

    test('function with expression argument: sqrt(9 m^2)', () {
      final node = parse('sqrt(9 m^2)') as FunctionNode;
      expect(node.name, 'sqrt');
      expect(node.arguments.length, 1);
    });

    test('nested function calls: abs(sin(0))', () {
      final node = parse('abs(sin(0))') as FunctionNode;
      expect(node.name, 'abs');
      expect(node.arguments[0], isA<FunctionNode>());
    });

    test('multi-argument function: atan2(1, 2)', () {
      final node = parse('atan2(1, 2)') as FunctionNode;
      expect(node.name, 'atan2');
      expect(node.arguments.length, 2);
    });

    test('function in expression: 5 + sin(0)', () {
      final node = parse('5 + sin(0)') as BinaryOpNode;
      expect(node.operator, TokenType.plus);
      expect(node.right, isA<FunctionNode>());
    });
  });

  group('Parser: complex expressions', () {
    test('5 * 3 + 2', () {
      final node = parse('5 * 3 + 2') as BinaryOpNode;
      expect(node.operator, TokenType.plus);
      expect(node.left, isA<BinaryOpNode>());
      expect((node.left as BinaryOpNode).operator, TokenType.multiply);
    });

    test('1|2 m', () {
      // 1|2 at highDiv level, then implicit multiply with m
      final node = parse('1|2 m') as BinaryOpNode;
      expect(node.operator, TokenType.multiply);
      expect(node.left, isA<BinaryOpNode>());
      expect((node.left as BinaryOpNode).operator, TokenType.divideHigh);
      expect(node.right, isA<UnitNode>());
    });

    test('deeply nested parentheses: ((((5))))', () {
      final node = parse('((((5))))');
      expect(node, isA<NumberNode>());
      expect((node as NumberNode).value, 5.0);
    });
  });

  group('Parser: error cases', () {
    test('empty input throws', () {
      expect(() => parse(''), throwsA(isA<ParseException>()));
    });

    test('missing right paren', () {
      expect(() => parse('(5 + 3'), throwsA(isA<ParseException>()));
    });

    test('missing function argument closing paren', () {
      expect(() => parse('sin(5'), throwsA(isA<ParseException>()));
    });

    test('unexpected operator at start', () {
      expect(() => parse('* 5'), throwsA(isA<ParseException>()));
    });

    test('trailing operator', () {
      expect(() => parse('5 +'), throwsA(isA<ParseException>()));
    });

    test('consecutive operators', () {
      // 5 + * 3 — * after + is unexpected for multiplication level
      // But actually + then * 3 — * is parsed at multiplication level
      // which expects exponentiation first, which calls unary, which calls
      // call, which calls primary — primary sees * and throws.
      expect(() => parse('5 + * 3'), throwsA(isA<ParseException>()));
    });
  });
}
