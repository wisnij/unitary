import 'package:flutter_test/flutter_test.dart';
import 'package:unitary/core/domain/errors.dart';
import 'package:unitary/core/domain/parser/lexer.dart';
import 'package:unitary/core/domain/parser/token.dart';

/// Helper: extract token types from a list (excluding EOF).
List<TokenType> types(List<Token> tokens) =>
    tokens.where((t) => t.type != TokenType.eof).map((t) => t.type).toList();

/// Helper: extract literals from a list (excluding EOF).
List<Object?> literals(List<Token> tokens) =>
    tokens.where((t) => t.type != TokenType.eof).map((t) => t.literal).toList();

void main() {
  List<Token> lex(String input) => Lexer(input).scanTokens();

  group('Lexer: numbers', () {
    test('integer', () {
      final tokens = lex('42');
      expect(types(tokens), [TokenType.number]);
      expect(tokens[0].literal, 42.0);
    });

    test('decimal', () {
      final tokens = lex('3.14');
      expect(types(tokens), [TokenType.number]);
      expect(tokens[0].literal, 3.14);
    });

    test('leading decimal point', () {
      final tokens = lex('.5');
      expect(types(tokens), [TokenType.number]);
      expect(tokens[0].literal, 0.5);
    });

    test('trailing decimal point', () {
      final tokens = lex('5.');
      expect(types(tokens), [TokenType.number]);
      expect(tokens[0].literal, 5.0);
    });

    test('zero', () {
      final tokens = lex('0');
      expect(types(tokens), [TokenType.number]);
      expect(tokens[0].literal, 0.0);
    });

    test('scientific notation', () {
      final tokens = lex('1.5e-10');
      expect(types(tokens), [TokenType.number]);
      expect(tokens[0].literal, 1.5e-10);
    });

    test('scientific notation uppercase E', () {
      final tokens = lex('3E8');
      expect(types(tokens), [TokenType.number]);
      expect(tokens[0].literal, 3e8);
    });

    test('scientific notation positive exponent', () {
      final tokens = lex('2e+5');
      expect(types(tokens), [TokenType.number]);
      expect(tokens[0].literal, 2e5);
    });

    test('leading decimal with scientific notation', () {
      final tokens = lex('.5e2');
      expect(types(tokens), [TokenType.number]);
      expect(tokens[0].literal, 50.0);
    });

    test('trailing decimal with scientific notation', () {
      final tokens = lex('5.e2');
      expect(types(tokens), [TokenType.number]);
      expect(tokens[0].literal, 500.0);
    });
  });

  group('Lexer: scientific notation edge cases', () {
    // When 'e'/'E' is not followed by [optional sign] + digits,
    // it becomes a separate identifier token.

    test('1e without digits: number then identifier', () {
      final tokens = lex('1e');
      expect(types(tokens), [TokenType.number, TokenType.identifier]);
      expect(tokens[0].literal, 1.0);
      expect(tokens[1].literal, 'e');
    });

    test('1E without digits: number then identifier', () {
      final tokens = lex('1E');
      expect(types(tokens), [TokenType.number, TokenType.identifier]);
      expect(tokens[0].literal, 1.0);
      expect(tokens[1].literal, 'E');
    });

    test('1e+2 is valid scientific notation', () {
      final tokens = lex('1e+2');
      expect(types(tokens), [TokenType.number]);
      expect(tokens[0].literal, 100.0);
    });

    test('1e2 is valid scientific notation', () {
      final tokens = lex('1e2');
      expect(types(tokens), [TokenType.number]);
      expect(tokens[0].literal, 100.0);
    });

    test('1e-2 is valid scientific notation', () {
      final tokens = lex('1e-2');
      expect(types(tokens), [TokenType.number]);
      expect(tokens[0].literal, 0.01);
    });

    test('1e+ space 2: space breaks scientific notation', () {
      // '1e+ 2' → number(1), identifier(e), plus, number(2)
      final tokens = lex('1e+ 2');
      expect(types(tokens), [
        TokenType.number,
        TokenType.identifier,
        TokenType.plus,
        TokenType.number,
      ]);
      expect(tokens[0].literal, 1.0);
      expect(tokens[1].literal, 'e');
      expect(tokens[3].literal, 2.0);
    });

    test('1e space +2: space breaks scientific notation', () {
      // '1e +2' → number(1), identifier(e), plus, number(2)
      final tokens = lex('1e +2');
      expect(types(tokens), [
        TokenType.number,
        TokenType.identifier,
        TokenType.plus,
        TokenType.number,
      ]);
      expect(tokens[0].literal, 1.0);
      expect(tokens[1].literal, 'e');
      expect(tokens[3].literal, 2.0);
    });

    test('1e- space 2: space breaks scientific notation', () {
      final tokens = lex('1e- 2');
      expect(types(tokens), [
        TokenType.number,
        TokenType.identifier,
        TokenType.minus,
        TokenType.number,
      ]);
      expect(tokens[0].literal, 1.0);
      expect(tokens[1].literal, 'e');
      expect(tokens[3].literal, 2.0);
    });

    test('1e space -2: space breaks scientific notation', () {
      final tokens = lex('1e -2');
      expect(types(tokens), [
        TokenType.number,
        TokenType.identifier,
        TokenType.minus,
        TokenType.number,
      ]);
      expect(tokens[0].literal, 1.0);
      expect(tokens[1].literal, 'e');
      expect(tokens[3].literal, 2.0);
    });

    test('1e+: sign without digit produces three tokens', () {
      // '1e+' → number(1), identifier(e), plus
      // This is invalid grammar, but that's the parser's problem
      final tokens = lex('1e+');
      expect(types(tokens), [
        TokenType.number,
        TokenType.identifier,
        TokenType.plus,
      ]);
      expect(tokens[0].literal, 1.0);
      expect(tokens[1].literal, 'e');
    });

    test('1e-: sign without digit produces three tokens', () {
      final tokens = lex('1e-');
      expect(types(tokens), [
        TokenType.number,
        TokenType.identifier,
        TokenType.minus,
      ]);
      expect(tokens[0].literal, 1.0);
      expect(tokens[1].literal, 'e');
    });

    test('1.5e without digits: decimal then identifier', () {
      final tokens = lex('1.5e');
      expect(types(tokens), [TokenType.number, TokenType.identifier]);
      expect(tokens[0].literal, 1.5);
      expect(tokens[1].literal, 'e');
    });

    test('1.5e+ without digit: three tokens', () {
      final tokens = lex('1.5e+');
      expect(types(tokens), [
        TokenType.number,
        TokenType.identifier,
        TokenType.plus,
      ]);
      expect(tokens[0].literal, 1.5);
      expect(tokens[1].literal, 'e');
    });

    test('.5e without digits: decimal then identifier', () {
      final tokens = lex('.5e');
      expect(types(tokens), [TokenType.number, TokenType.identifier]);
      expect(tokens[0].literal, 0.5);
      expect(tokens[1].literal, 'e');
    });

    test('.5e2 is valid scientific notation', () {
      final tokens = lex('.5e2');
      expect(types(tokens), [TokenType.number]);
      expect(tokens[0].literal, 50.0);
    });

    test('1e2e: scientific notation followed by identifier', () {
      // '1e2' is number(100), then 'e' starts new identifier
      final tokens = lex('1e2e');
      expect(types(tokens), [TokenType.number, TokenType.identifier]);
      expect(tokens[0].literal, 100.0);
      expect(tokens[1].literal, 'e');
    });

    test('1e+2e: scientific notation followed by identifier', () {
      // '1e+2' is number(100), then 'e' starts new identifier
      final tokens = lex('1e+2e');
      expect(types(tokens), [TokenType.number, TokenType.identifier]);
      expect(tokens[0].literal, 100.0);
      expect(tokens[1].literal, 'e');
    });

    test('1e2m: scientific notation followed by identifier', () {
      final tokens = lex('1e2m');
      expect(types(tokens), [TokenType.number, TokenType.identifier]);
      expect(tokens[0].literal, 100.0);
      expect(tokens[1].literal, 'm');
    });

    test('1em: e followed by letter is identifier', () {
      // '1' is number, 'em' is identifier (not scientific notation)
      final tokens = lex('1em');
      expect(types(tokens), [TokenType.number, TokenType.identifier]);
      expect(tokens[0].literal, 1.0);
      expect(tokens[1].literal, 'em');
    });

    test('1e+m: e+ not followed by digit', () {
      // '1' is number, 'e' is identifier, '+' is plus, 'm' is identifier
      final tokens = lex('1e+m');
      expect(types(tokens), [
        TokenType.number,
        TokenType.identifier,
        TokenType.plus,
        TokenType.identifier,
      ]);
      expect(tokens[0].literal, 1.0);
      expect(tokens[1].literal, 'e');
      expect(tokens[3].literal, 'm');
    });
  });

  group('Lexer: operators', () {
    test('plus', () {
      expect(types(lex('+')), [TokenType.plus]);
    });

    test('minus', () {
      expect(types(lex('-')), [TokenType.minus]);
    });

    test('star', () {
      expect(types(lex('*')), [TokenType.times]);
    });

    test('double star is power', () {
      final tokens = lex('**');
      expect(types(tokens), [TokenType.exponent]);
      expect(tokens[0].lexeme, '**');
    });

    test('slash', () {
      expect(types(lex('/')), [TokenType.divide]);
    });

    test('per', () {
      expect(types(lex('per')), [TokenType.divide]);
    });

    test('pipe', () {
      expect(types(lex('|')), [TokenType.divideNum]);
    });

    test('caret', () {
      expect(types(lex('^')), [TokenType.exponent]);
    });

    test('left paren', () {
      expect(types(lex('(')), [TokenType.leftParen]);
    });

    test('right paren', () {
      expect(types(lex(')')), [TokenType.rightParen]);
    });

    test('comma', () {
      expect(types(lex(',')), [TokenType.comma]);
    });
  });

  group('Lexer: Unicode operators', () {
    test('multiplication sign U+00D7', () {
      expect(types(lex('\u00D7')), [TokenType.times]);
    });

    test('middle dot U+00B7', () {
      expect(types(lex('\u00B7')), [TokenType.times]);
    });

    test('dot operator U+22C5', () {
      expect(types(lex('\u22C5')), [TokenType.times]);
    });

    test('N-ary times operator U+2A09', () {
      expect(types(lex('\u2A09')), [TokenType.times]);
    });

    test('division sign U+00F7', () {
      expect(types(lex('\u00F7')), [TokenType.divide]);
    });

    test('figure dash U+2012', () {
      expect(types(lex('\u2012')), [TokenType.minus]);
    });

    test('en dash U+2013', () {
      expect(types(lex('\u2013')), [TokenType.minus]);
    });

    test('minus sign U+2212', () {
      expect(types(lex('\u2212')), [TokenType.minus]);
    });

    test('fraction slash U+2044', () {
      expect(types(lex('\u2044')), [TokenType.divideNum]);
    });
  });

  group('Lexer: identifiers', () {
    test('simple identifier', () {
      final tokens = lex('m');
      expect(types(tokens), [TokenType.identifier]);
      expect(tokens[0].literal, 'm');
    });

    test('identifier followed by ( is still identifier', () {
      final tokens = lex('sin(');
      expect(tokens[0].type, TokenType.identifier);
      expect(tokens[0].literal, 'sin');
      expect(tokens[1].type, TokenType.leftParen);
    });

    test('identifier with space then ( is still identifier', () {
      final tokens = lex('sin (');
      expect(tokens[0].type, TokenType.identifier);
      expect(tokens[0].literal, 'sin');
    });

    test('multi-character identifier', () {
      final tokens = lex('meter');
      expect(types(tokens), [TokenType.identifier]);
      expect(tokens[0].literal, 'meter');
    });

    test('identifier with digits', () {
      final tokens = lex('log2');
      expect(types(tokens), [TokenType.identifier]);
      expect(tokens[0].literal, 'log2');
    });

    test('identifier starting with underscore', () {
      final tokens = lex('_foo');
      expect(types(tokens), [TokenType.identifier]);
      expect(tokens[0].literal, '_foo');
    });

    test('multiple identifiers', () {
      final tokens = lex('m s');
      final nonEof = tokens.where((t) => t.type != TokenType.eof).toList();
      expect(nonEof.where((t) => t.type == TokenType.identifier).length, 2);
    });

    test('per as divide operator: not leading', () {
      final tokens = lex('percent');
      expect(types(tokens), [TokenType.identifier]);
      expect(tokens[0].literal, 'percent');
    });

    test('per as divide operator: not trailing', () {
      final tokens = lex('super');
      expect(types(tokens), [TokenType.identifier]);
      expect(tokens[0].literal, 'super');
    });

    test('per as divide operator: not internal', () {
      final tokens = lex('mileperhour');
      expect(types(tokens), [TokenType.identifier]);
      expect(tokens[0].literal, 'mileperhour');
    });
  });

  group('Lexer: implicit multiplication', () {
    test('number followed by identifier: 5m', () {
      expect(types(lex('5m')), [TokenType.number, TokenType.identifier]);
    });

    test('number space identifier: 5 m', () {
      expect(types(lex('5 m')), [TokenType.number, TokenType.identifier]);
    });

    test('number space number: 2 3', () {
      expect(types(lex('2 3')), [TokenType.number, TokenType.number]);
    });

    test('identifier space identifier: m s', () {
      expect(types(lex('m s')), [TokenType.identifier, TokenType.identifier]);
    });

    test('right paren followed by left paren: )(', () {
      expect(types(lex(')(')), [TokenType.rightParen, TokenType.leftParen]);
    });

    test('right paren followed by number: )5', () {
      expect(types(lex(')5')), [TokenType.rightParen, TokenType.number]);
    });

    test('right paren followed by identifier: )m', () {
      expect(types(lex(')m')), [TokenType.rightParen, TokenType.identifier]);
    });

    test('number followed by left paren: 5(', () {
      expect(types(lex('5(')), [TokenType.number, TokenType.leftParen]);
    });

    test('identifier followed by number: m 5', () {
      expect(types(lex('m 5')), [TokenType.identifier, TokenType.number]);
    });

    test('identifier followed by left paren: m(', () {
      expect(types(lex('m(')), [TokenType.identifier, TokenType.leftParen]);
    });

    test('no implicit multiply after operator: 5 + 3', () {
      expect(types(lex('5 + 3')), [
        TokenType.number,
        TokenType.plus,
        TokenType.number,
      ]);
    });

    test('no implicit multiply after left paren', () {
      expect(types(lex('(5')), [TokenType.leftParen, TokenType.number]);
    });

    test('number followed by leading-dot number: 2 .3', () {
      expect(types(lex('2 .3')), [TokenType.number, TokenType.number]);
    });

    test('trailing-dot number followed by number: 2. 3', () {
      expect(types(lex('2. 3')), [TokenType.number, TokenType.number]);
    });

    test('trailing-dot number followed by number: 2. .3', () {
      expect(types(lex('2. .3')), [TokenType.number, TokenType.number]);
    });
  });

  group('Lexer: whitespace', () {
    test('ignores spaces', () {
      final tokens = lex('  5  +  3  ');
      expect(types(tokens), [
        TokenType.number,
        TokenType.plus,
        TokenType.number,
      ]);
    });

    test('ignores tabs', () {
      final tokens = lex('\t5\t+\t3');
      expect(types(tokens), [
        TokenType.number,
        TokenType.plus,
        TokenType.number,
      ]);
    });

    test('empty input gives only EOF', () {
      final tokens = lex('');
      expect(tokens.length, 1);
      expect(tokens[0].type, TokenType.eof);
    });

    test('whitespace only gives only EOF', () {
      final tokens = lex('   ');
      expect(tokens.length, 1);
      expect(tokens[0].type, TokenType.eof);
    });
  });

  group('Lexer: line and column tracking', () {
    test('first token starts at line 1 column 1', () {
      final tokens = lex('5');
      expect(tokens[0].line, 1);
      expect(tokens[0].column, 1);
    });

    test('second token column accounts for first', () {
      final tokens = lex('5+3');
      // 5 at col 1, + at col 2, 3 at col 3
      expect(tokens[0].column, 1);
      expect(tokens[1].column, 2);
      expect(tokens[2].column, 3);
    });

    test('spaces advance column', () {
      final tokens = lex('5 + 3');
      expect(tokens[0].column, 1); // 5
      expect(tokens[1].column, 3); // +
      expect(tokens[2].column, 5); // 3
    });

    test('newline increments line', () {
      final tokens = lex('5\n+\n3');
      expect(tokens[0].line, 1);
      expect(tokens[1].line, 2);
      expect(tokens[2].line, 3);
    });
  });

  group('Lexer: complex expressions', () {
    test('5 * 3 + 2', () {
      expect(types(lex('5 * 3 + 2')), [
        TokenType.number,
        TokenType.times,
        TokenType.number,
        TokenType.plus,
        TokenType.number,
      ]);
    });

    test('sin(0.5) + cos(1)', () {
      expect(types(lex('sin(0.5) + cos(1)')), [
        TokenType.identifier,
        TokenType.leftParen,
        TokenType.number,
        TokenType.rightParen,
        TokenType.plus,
        TokenType.identifier,
        TokenType.leftParen,
        TokenType.number,
        TokenType.rightParen,
      ]);
    });

    test('1|2 m', () {
      expect(types(lex('1|2 m')), [
        TokenType.number,
        TokenType.divideNum,
        TokenType.number,
        TokenType.identifier,
      ]);
    });

    test('2^-3', () {
      expect(types(lex('2^-3')), [
        TokenType.number,
        TokenType.exponent,
        TokenType.minus,
        TokenType.number,
      ]);
    });

    test('2**3', () {
      expect(types(lex('2**3')), [
        TokenType.number,
        TokenType.exponent,
        TokenType.number,
      ]);
    });

    test('sqrt(9 m^2)', () {
      expect(types(lex('sqrt(9 m^2)')), [
        TokenType.identifier,
        TokenType.leftParen,
        TokenType.number,
        TokenType.identifier,
        TokenType.exponent,
        TokenType.number,
        TokenType.rightParen,
      ]);
    });
  });

  group('Lexer: error cases', () {
    test('unknown character throws LexException', () {
      expect(() => lex('@'), throwsA(isA<LexException>()));
    });

    test('error includes position', () {
      try {
        lex('5 + @');
        fail('Should have thrown');
      } on LexException catch (e) {
        expect(e.column, 5);
      }
    });

    test('lone dot throws', () {
      // A dot not followed by a digit is not a valid number.
      expect(() => lex('.'), throwsA(isA<LexException>()));
    });

    test('dot followed by non-digit throws', () {
      expect(() => lex('.+'), throwsA(isA<LexException>()));
    });
  });

  group('Lexer: EOF token', () {
    test('last token is always EOF', () {
      final tokens = lex('5');
      expect(tokens.last.type, TokenType.eof);
    });

    test('empty input produces EOF', () {
      final tokens = lex('');
      expect(tokens.length, 1);
      expect(tokens[0].type, TokenType.eof);
    });
  });
}
