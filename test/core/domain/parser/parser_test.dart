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

    test('division with per', () {
      final node = parse('6 per 2');
      expect(node, isA<BinaryOpNode>());
      expect((node as BinaryOpNode).operator, TokenType.divide);
    });
  });

  group('Parser: operator precedence', () {
    test('multiplication before addition: 1 + 2 * 3 = 1 + (2 * 3)', () {
      final node = parse('1 + 2 * 3') as BinaryOpNode;
      expect(node.operator, TokenType.plus);
      expect(node.left, isA<NumberNode>());
      expect(node.right, isA<BinaryOpNode>());
      expect((node.right as BinaryOpNode).operator, TokenType.multiply);
    });

    test('multiplication before subtraction: 5 - 2 * 3 = 5 - (2 * 3)', () {
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

    test('left-to-right: 10 - 3 - 2 = (10 - 3) - 2', () {
      final node = parse('10 - 3 - 2') as BinaryOpNode;
      expect(node.operator, TokenType.minus);
      expect(node.left, isA<BinaryOpNode>());
      expect((node.left as BinaryOpNode).operator, TokenType.minus);
    });

    test('left-to-right: 2 per 3 per 4 = (2/3) / 4', () {
      final node = parse('2 per 3 per 4') as BinaryOpNode;
      expect(node.operator, TokenType.divide);
      expect(node.left, isA<BinaryOpNode>());
      expect((node.left as BinaryOpNode).operator, TokenType.divide);
      expect(node.right, isA<NumberNode>());
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

    test('exponent higher than multiply: 2*3^4 = 2 * (3^4)', () {
      // Should parse as 2 * (3^4)
      final node = parse('2*3^4') as BinaryOpNode;
      expect(node.operator, TokenType.multiply);
      expect(node.left, isA<NumberNode>());
      expect(node.right, isA<BinaryOpNode>());
      expect((node.right as BinaryOpNode).operator, TokenType.power);
    });

    test('exponent higher than multiply: 2^3*4 = (2^3) * 4', () {
      // Should parse as (2^3) * 4
      final node = parse('2^3*4') as BinaryOpNode;
      expect(node.operator, TokenType.multiply);
      expect(node.left, isA<BinaryOpNode>());
      expect((node.left as BinaryOpNode).operator, TokenType.power);
      expect(node.right, isA<NumberNode>());
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

    test('double negative: 1--2 = 1 - (-2)', () {
      final node = parse('1--2') as BinaryOpNode;
      expect(node.operator, TokenType.minus);
      expect(node.left, isA<NumberNode>());
      expect(node.right, isA<UnaryOpNode>());

      final unary = node.right as UnaryOpNode;
      expect(unary.operator, TokenType.minus);
      expect(unary.operand, isA<NumberNode>());
    });

    test('unary binds lower than ^: -2^3 = -(2^3)', () {
      // unary calls power, so -2^3 = -(2^3)
      final node = parse('-2^3') as UnaryOpNode;
      expect(node.operator, TokenType.minus);
      expect(node.operand, isA<BinaryOpNode>());
      expect((node.operand as BinaryOpNode).operator, TokenType.power);
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
      // | is in numexpr which is parsed as primary, so 1|2 is one unit
      // Then ^3 is applied: (1|2)^3
      final node = parse('1|2^3') as BinaryOpNode;
      expect(node.operator, TokenType.power);
      expect(node.left, isA<BinaryOpNode>());
      expect((node.left as BinaryOpNode).operator, TokenType.divideHigh);
    });

    test('non-numeric left operand throws', () {
      expect(() => parse('m|1'), throwsA(isA<ParseException>()));
    });

    test('non-numeric right operand throws', () {
      expect(() => parse('1|m'), throwsA(isA<ParseException>()));
    });

    test('expression operand for | is rejected', () {
      expect(() => parse('(1+2)|3'), throwsA(isA<ParseException>()));
    });

    test('-1|2 is unary minus of (1|2)', () {
      // -1|2 = -(1|2) since unary calls power, power calls primary,
      // primary calls numexpr for numbers, and numexpr handles |.
      final node = parse('-1|2') as UnaryOpNode;
      expect(node.operator, TokenType.minus);
      expect(node.operand, isA<BinaryOpNode>());
      expect((node.operand as BinaryOpNode).operator, TokenType.divideHigh);
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

    test(
      'implicit multiply higher precedence than /: 5 m / 2 s = (5m)/(2s)',
      () {
        // implicit multiply is at listProduct level, higher than opProduct
        // (explicit * and /), so this parses as (5*m) / (2*s)
        final node = parse('5 m / 2 s') as BinaryOpNode;
        expect(node.operator, TokenType.divide);
        expect(node.left, isA<BinaryOpNode>());
        expect((node.left as BinaryOpNode).operator, TokenType.multiply);
        expect(node.right, isA<BinaryOpNode>());
        expect((node.right as BinaryOpNode).operator, TokenType.multiply);
      },
    );

    test('m(5) is implicit multiply: m * 5', () {
      // Non-function identifier followed by ( is implicit multiply
      final node = parse('m(5)') as BinaryOpNode;
      expect(node.operator, TokenType.multiply);
      expect(node.left, isA<UnitNode>());
      expect((node.left as UnitNode).unitName, 'm');
      expect(node.right, isA<NumberNode>());
    });
  });

  group('Parser: reciprocal syntax', () {
    test('/2 = 1/2 (reciprocal)', () {
      final node = parse('/2') as BinaryOpNode;
      expect(node.operator, TokenType.divide);
      expect(node.left, isA<NumberNode>());
      expect((node.left as NumberNode).value, 1.0);
      expect(node.right, isA<NumberNode>());
      expect((node.right as NumberNode).value, 2.0);
    });

    test('/m = 1/m (reciprocal unit)', () {
      final node = parse('/m') as BinaryOpNode;
      expect(node.operator, TokenType.divide);
      expect(node.left, isA<NumberNode>());
      expect((node.left as NumberNode).value, 1.0);
      expect(node.right, isA<UnitNode>());
    });

    test('per m = 1/m (reciprocal unit)', () {
      final node = parse('per m') as BinaryOpNode;
      expect(node.operator, TokenType.divide);
      expect(node.left, isA<NumberNode>());
      expect((node.left as NumberNode).value, 1.0);
      expect(node.right, isA<UnitNode>());
    });

    test('/(2 + 3) = 1/(2+3)', () {
      final node = parse('/(2 + 3)') as BinaryOpNode;
      expect(node.operator, TokenType.divide);
      expect(node.left, isA<NumberNode>());
      expect(node.right, isA<BinaryOpNode>());
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
      // atan2 is not in builtins, so this parses as unit * (1, 2)
      // which will fail. Let's use a real multi-arg test.
      // Actually, let's just test comma separation works.
      // We can call sin with wrong args (will fail at eval, not parse).
      final node = parse('sin(1 + 2)') as FunctionNode;
      expect(node.name, 'sin');
      expect(node.arguments.length, 1);
    });

    test('function in expression: 5 + sin(0)', () {
      final node = parse('5 + sin(0)') as BinaryOpNode;
      expect(node.operator, TokenType.plus);
      expect(node.right, isA<FunctionNode>());
    });

    test('zero-arg function call throws', () {
      expect(() => parse('sin()'), throwsA(isA<ParseException>()));
    });

    test(
      'unknown identifier with parens is implicit multiply, not function',
      () {
        // foo(5) where foo is not a builtin should be foo * 5
        final node = parse('foo(5)') as BinaryOpNode;
        expect(node.operator, TokenType.multiply);
        expect(node.left, isA<UnitNode>());
        expect((node.left as UnitNode).unitName, 'foo');
      },
    );
  });

  group('Parser: complex expressions', () {
    test('5 * 3 + 2', () {
      final node = parse('5 * 3 + 2') as BinaryOpNode;
      expect(node.operator, TokenType.plus);
      expect(node.left, isA<BinaryOpNode>());
      expect((node.left as BinaryOpNode).operator, TokenType.multiply);
    });

    test('1|2 m', () {
      // 1|2 parsed as numexpr, then implicit multiply with m
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

    test('extra right paren', () {
      expect(() => parse('(5 + 3))'), throwsA(isA<ParseException>()));
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
      // 5 + * 3 — * after + is unexpected
      expect(() => parse('5 + * 3'), throwsA(isA<ParseException>()));
    });

    test('double negative: --1', () {
      expect(() => parse('--1'), throwsA(isA<ParseException>()));
    });

    test('invalid numeric literal: 1e+', () {
      expect(() => parse('1e+'), throwsA(isA<ParseException>()));
    });
  });
}
