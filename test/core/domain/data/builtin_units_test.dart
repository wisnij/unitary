import 'package:flutter_test/flutter_test.dart';
import 'package:unitary/core/domain/data/builtin_units.dart';
import 'package:unitary/core/domain/models/dimension.dart';
import 'package:unitary/core/domain/models/unit_repository.dart';

void main() {
  late UnitRepository repo;

  setUp(() {
    repo = UnitRepository();
    registerBuiltinUnits(repo);
  });

  group('Registration', () {
    test('all units register without collision', () {
      // If we get here, registerBuiltinUnits() didn't throw.
      expect(repo.allUnits.length, 22);
    });

    test('registers 10 length units', () {
      for (final id in [
        'm',
        'km',
        'cm',
        'mm',
        'um',
        'in',
        'ft',
        'yd',
        'mi',
        'nmi',
      ]) {
        expect(repo.findUnit(id), isNotNull, reason: 'unit $id should exist');
      }
    });

    test('registers 6 mass units', () {
      for (final id in ['kg', 'g', 'mg', 'lb', 'oz', 't']) {
        expect(repo.findUnit(id), isNotNull, reason: 'unit $id should exist');
      }
    });

    test('registers 6 time units', () {
      for (final id in ['s', 'ms', 'min', 'hr', 'day', 'week']) {
        expect(repo.findUnit(id), isNotNull, reason: 'unit $id should exist');
      }
    });
  });

  group('Conversion factors', () {
    test('1 ft = 0.3048 m', () {
      final ft = repo.getUnit('ft');
      expect(ft.definition.toQuantity(1.0, repo).value, closeTo(0.3048, 1e-10));
    });

    test('1 mi = 1609.344 m', () {
      final mi = repo.getUnit('mi');
      expect(
        mi.definition.toQuantity(1.0, repo).value,
        closeTo(1609.344, 1e-6),
      );
    });

    test('1 in = 0.0254 m', () {
      final inch = repo.getUnit('in');
      expect(
        inch.definition.toQuantity(1.0, repo).value,
        closeTo(0.0254, 1e-10),
      );
    });

    test('1 yd = 0.9144 m', () {
      final yd = repo.getUnit('yd');
      expect(yd.definition.toQuantity(1.0, repo).value, closeTo(0.9144, 1e-10));
    });

    test('1 km = 1000 m', () {
      final km = repo.getUnit('km');
      expect(km.definition.toQuantity(1.0, repo).value, closeTo(1000.0, 1e-10));
    });

    test('1 cm = 0.01 m', () {
      final cm = repo.getUnit('cm');
      expect(cm.definition.toQuantity(1.0, repo).value, closeTo(0.01, 1e-15));
    });

    test('1 mm = 0.001 m', () {
      final mm = repo.getUnit('mm');
      expect(mm.definition.toQuantity(1.0, repo).value, closeTo(0.001, 1e-15));
    });

    test('1 um = 1e-6 m', () {
      final um = repo.getUnit('um');
      expect(um.definition.toQuantity(1.0, repo).value, closeTo(1e-6, 1e-18));
    });

    test('1 nmi = 1852 m', () {
      final nmi = repo.getUnit('nmi');
      expect(
        nmi.definition.toQuantity(1.0, repo).value,
        closeTo(1852.0, 1e-10),
      );
    });

    test('1 lb = 0.45359237 kg', () {
      final lb = repo.getUnit('lb');
      expect(
        lb.definition.toQuantity(1.0, repo).value,
        closeTo(0.45359237, 1e-10),
      );
    });

    test('1 oz = 0.028349523125 kg', () {
      final oz = repo.getUnit('oz');
      expect(
        oz.definition.toQuantity(1.0, repo).value,
        closeTo(0.028349523125, 1e-14),
      );
    });

    test('1 g = 0.001 kg', () {
      final g = repo.getUnit('g');
      expect(g.definition.toQuantity(1.0, repo).value, closeTo(0.001, 1e-15));
    });

    test('1 mg = 1e-6 kg', () {
      final mg = repo.getUnit('mg');
      expect(mg.definition.toQuantity(1.0, repo).value, closeTo(1e-6, 1e-18));
    });

    test('1 t = 1000 kg', () {
      final t = repo.getUnit('t');
      expect(t.definition.toQuantity(1.0, repo).value, closeTo(1000.0, 1e-10));
    });

    test('1 hr = 3600 s', () {
      final hr = repo.getUnit('hr');
      expect(hr.definition.toQuantity(1.0, repo).value, closeTo(3600.0, 1e-10));
    });

    test('1 min = 60 s', () {
      final min = repo.getUnit('min');
      expect(min.definition.toQuantity(1.0, repo).value, closeTo(60.0, 1e-10));
    });

    test('1 day = 86400 s', () {
      final day = repo.getUnit('day');
      expect(
        day.definition.toQuantity(1.0, repo).value,
        closeTo(86400.0, 1e-10),
      );
    });

    test('1 week = 604800 s', () {
      final week = repo.getUnit('week');
      expect(
        week.definition.toQuantity(1.0, repo).value,
        closeTo(604800.0, 1e-10),
      );
    });

    test('1 ms = 0.001 s', () {
      final ms = repo.getUnit('ms');
      expect(ms.definition.toQuantity(1.0, repo).value, closeTo(0.001, 1e-15));
    });
  });

  group('Alias resolution', () {
    test('"meter" resolves to m', () {
      expect(repo.findUnit('meter')?.id, 'm');
    });

    test('"metre" resolves to m', () {
      expect(repo.findUnit('metre')?.id, 'm');
    });

    test('"foot" resolves to ft', () {
      expect(repo.findUnit('foot')?.id, 'ft');
    });

    test('"feet" resolves to ft', () {
      expect(repo.findUnit('feet')?.id, 'ft');
    });

    test('"mile" resolves to mi', () {
      expect(repo.findUnit('mile')?.id, 'mi');
    });

    test('"kilogram" resolves to kg', () {
      expect(repo.findUnit('kilogram')?.id, 'kg');
    });

    test('"second" resolves to s', () {
      expect(repo.findUnit('second')?.id, 's');
    });

    test('"sec" resolves to s', () {
      expect(repo.findUnit('sec')?.id, 's');
    });

    test('"yard" resolves to yd', () {
      expect(repo.findUnit('yard')?.id, 'yd');
    });

    test('"pound" resolves to lb', () {
      expect(repo.findUnit('pound')?.id, 'lb');
    });

    test('"ounce" resolves to oz', () {
      expect(repo.findUnit('ounce')?.id, 'oz');
    });

    test('"tonne" resolves to t', () {
      expect(repo.findUnit('tonne')?.id, 't');
    });

    test('"metric_ton" resolves to t', () {
      expect(repo.findUnit('metric_ton')?.id, 't');
    });

    test('"inch" resolves to in', () {
      expect(repo.findUnit('inch')?.id, 'in');
    });

    test('"wk" resolves to week', () {
      expect(repo.findUnit('wk')?.id, 'week');
    });

    test('"hour" resolves to hr', () {
      expect(repo.findUnit('hour')?.id, 'hr');
    });

    test('"minute" resolves to min', () {
      expect(repo.findUnit('minute')?.id, 'min');
    });

    test('"nautical_mile" resolves to nmi', () {
      expect(repo.findUnit('nautical_mile')?.id, 'nmi');
    });

    test('"micron" resolves to um', () {
      expect(repo.findUnit('micron')?.id, 'um');
    });
  });

  group('Plural stripping', () {
    test('"meters" resolves to m (via "meter" + strip s)', () {
      expect(repo.findUnit('meters')?.id, 'm');
    });

    test('"inches" resolves to in (via "inch" + strip es)', () {
      expect(repo.findUnit('inches')?.id, 'in');
    });

    test('"pounds" resolves to lb (via "pound" + strip s)', () {
      expect(repo.findUnit('pounds')?.id, 'lb');
    });

    test('"hours" resolves to hr (via "hour" + strip s)', () {
      expect(repo.findUnit('hours')?.id, 'hr');
    });

    test('"kilometres" resolves to km (via "kilometre" + strip s)', () {
      expect(repo.findUnit('kilometres')?.id, 'km');
    });

    test('"ounces" resolves to oz (via "ounce" + strip s)', () {
      expect(repo.findUnit('ounces')?.id, 'oz');
    });

    test('"minutes" resolves to min (via "minute" + strip s)', () {
      expect(repo.findUnit('minutes')?.id, 'min');
    });
  });

  group('Dimensions', () {
    test('length units have dimension {m: 1}', () {
      final lengthDim = Dimension({'m': 1});
      for (final id in [
        'm',
        'km',
        'cm',
        'mm',
        'um',
        'in',
        'ft',
        'yd',
        'mi',
        'nmi',
      ]) {
        final unit = repo.getUnit(id);
        expect(
          unit.definition.toQuantity(1.0, repo).dimension,
          lengthDim,
          reason: '$id should have length dimension',
        );
      }
    });

    test('mass units have dimension {kg: 1}', () {
      final massDim = Dimension({'kg': 1});
      for (final id in ['kg', 'g', 'mg', 'lb', 'oz', 't']) {
        final unit = repo.getUnit(id);
        expect(
          unit.definition.toQuantity(1.0, repo).dimension,
          massDim,
          reason: '$id should have mass dimension',
        );
      }
    });

    test('time units have dimension {s: 1}', () {
      final timeDim = Dimension({'s': 1});
      for (final id in ['s', 'ms', 'min', 'hr', 'day', 'week']) {
        final unit = repo.getUnit(id);
        expect(
          unit.definition.toQuantity(1.0, repo).dimension,
          timeDim,
          reason: '$id should have time dimension',
        );
      }
    });
  });
}
