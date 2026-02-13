import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:unitary/core/domain/data/builtin_units.dart';
import 'package:unitary/core/domain/models/dimension.dart';
import 'package:unitary/core/domain/models/unit_definition.dart';
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
      // 22 (Phase 2) + 4 primitives + 8 temp + 10 constants + 12 compound = 56
      expect(repo.allUnits.length, 56);
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

    test('temperature units have dimension {K: 1}', () {
      final tempDim = Dimension({'K': 1});
      for (final id in [
        'K',
        'degK',
        'tempK',
        'degC',
        'tempC',
        'degF',
        'tempF',
        'degR',
        'tempR',
      ]) {
        final unit = repo.getUnit(id);
        expect(
          unit.definition.toQuantity(1.0, repo).dimension,
          tempDim,
          reason: '$id should have temperature dimension',
        );
      }
    });

    test('new SI base units have correct dimensions', () {
      expect(
        repo.getUnit('K').definition.toQuantity(1.0, repo).dimension,
        Dimension({'K': 1}),
      );
      expect(
        repo.getUnit('A').definition.toQuantity(1.0, repo).dimension,
        Dimension({'A': 1}),
      );
      expect(
        repo.getUnit('mol').definition.toQuantity(1.0, repo).dimension,
        Dimension({'mol': 1}),
      );
      expect(
        repo.getUnit('cd').definition.toQuantity(1.0, repo).dimension,
        Dimension({'cd': 1}),
      );
    });
  });

  group('SI base unit registration', () {
    test('registers K with aliases', () {
      expect(repo.findUnit('K')?.id, 'K');
      expect(repo.findUnit('kelvin')?.id, 'K');
    });

    test('registers A with aliases', () {
      expect(repo.findUnit('A')?.id, 'A');
      expect(repo.findUnit('ampere')?.id, 'A');
      expect(repo.findUnit('amp')?.id, 'A');
    });

    test('registers mol with aliases', () {
      expect(repo.findUnit('mol')?.id, 'mol');
      expect(repo.findUnit('mole')?.id, 'mol');
    });

    test('registers cd with aliases', () {
      expect(repo.findUnit('cd')?.id, 'cd');
      expect(repo.findUnit('candela')?.id, 'cd');
    });
  });

  group('Temperature conversions', () {
    test('tempF(212) = 373.15 K', () {
      final def = repo.getUnit('tempF').definition;
      expect(def.toQuantity(212.0, repo).value, closeTo(373.15, 1e-2));
    });

    test('tempF(32) = 273.15 K', () {
      final def = repo.getUnit('tempF').definition;
      expect(def.toQuantity(32.0, repo).value, closeTo(273.15, 1e-2));
    });

    test('tempF(-40) = 233.15 K', () {
      final def = repo.getUnit('tempF').definition;
      expect(def.toQuantity(-40.0, repo).value, closeTo(233.15, 1e-2));
    });

    test('tempC(100) = 373.15 K', () {
      final def = repo.getUnit('tempC').definition;
      expect(def.toQuantity(100.0, repo).value, closeTo(373.15, 1e-10));
    });

    test('tempC(0) = 273.15 K', () {
      final def = repo.getUnit('tempC').definition;
      expect(def.toQuantity(0.0, repo).value, closeTo(273.15, 1e-10));
    });

    test('tempC(-40) = 233.15 K', () {
      final def = repo.getUnit('tempC').definition;
      expect(def.toQuantity(-40.0, repo).value, closeTo(233.15, 1e-10));
    });

    test('tempK(373.15) = 373.15 K', () {
      final def = repo.getUnit('tempK').definition;
      expect(def.toQuantity(373.15, repo).value, closeTo(373.15, 1e-10));
    });

    test('tempR(671.67) ≈ 373.15 K', () {
      final def = repo.getUnit('tempR').definition;
      expect(def.toQuantity(671.67, repo).value, closeTo(373.15, 1e-2));
    });

    test('tempR(0) = 0 K', () {
      final def = repo.getUnit('tempR').definition;
      expect(def.toQuantity(0.0, repo).value, closeTo(0.0, 1e-10));
    });

    test('100 degF = 55.556 K', () {
      final def = repo.getUnit('degF').definition;
      expect(def.toQuantity(100.0, repo).value, closeTo(55.5556, 1e-3));
    });

    test('100 degC = 100 K', () {
      final def = repo.getUnit('degC').definition;
      expect(def.toQuantity(100.0, repo).value, closeTo(100.0, 1e-10));
    });

    test('180 degR = 100 K', () {
      final def = repo.getUnit('degR').definition;
      expect(def.toQuantity(180.0, repo).value, closeTo(100.0, 1e-10));
    });

    test('1 degK = 1 K', () {
      final def = repo.getUnit('degK').definition;
      expect(def.toQuantity(1.0, repo).value, closeTo(1.0, 1e-10));
    });

    test('affine units are affine', () {
      for (final id in ['tempK', 'tempC', 'tempF', 'tempR']) {
        expect(
          repo.getUnit(id).definition.isAffine,
          isTrue,
          reason: '$id should be affine',
        );
      }
    });

    test('degree units are not affine', () {
      for (final id in ['degK', 'degC', 'degF', 'degR']) {
        expect(
          repo.getUnit(id).definition.isAffine,
          isFalse,
          reason: '$id should not be affine',
        );
      }
    });

    test('temperature aliases resolve correctly', () {
      expect(repo.findUnit('degcelsius')?.id, 'degC');
      expect(repo.findUnit('tempcelsius')?.id, 'tempC');
      expect(repo.findUnit('degfahrenheit')?.id, 'degF');
      expect(repo.findUnit('tempfahrenheit')?.id, 'tempF');
      expect(repo.findUnit('degkelvin')?.id, 'degK');
      expect(repo.findUnit('tempkelvin')?.id, 'tempK');
      expect(repo.findUnit('degrankine')?.id, 'degR');
      expect(repo.findUnit('temprankine')?.id, 'tempR');
    });
  });

  group('Constants', () {
    test('pi has correct value and is dimensionless', () {
      final def = repo.getUnit('pi').definition;
      final q = def.toQuantity(1.0, repo);
      expect(q.value, closeTo(math.pi, 1e-15));
      expect(q.isDimensionless, isTrue);
    });

    test('euler has correct value and is dimensionless', () {
      final def = repo.getUnit('euler').definition;
      final q = def.toQuantity(1.0, repo);
      expect(q.value, closeTo(math.e, 1e-15));
      expect(q.isDimensionless, isTrue);
    });

    test('tau = 2*pi', () {
      final def = repo.getUnit('tau').definition;
      final q = def.toQuantity(1.0, repo);
      expect(q.value, closeTo(2 * math.pi, 1e-15));
      expect(q.isDimensionless, isTrue);
    });

    test('c = 299792458 m/s', () {
      final def = repo.getUnit('c').definition;
      final q = def.toQuantity(1.0, repo);
      expect(q.value, closeTo(299792458.0, 1e-2));
      expect(q.dimension, Dimension({'m': 1, 's': -1}));
    });

    test('gravity = 9.80665 m/s^2', () {
      final def = repo.getUnit('gravity').definition;
      final q = def.toQuantity(1.0, repo);
      expect(q.value, closeTo(9.80665, 1e-10));
      expect(q.dimension, Dimension({'m': 1, 's': -2}));
    });

    test('h = 6.62607015e-34 kg*m^2/s', () {
      final def = repo.getUnit('h').definition;
      final q = def.toQuantity(1.0, repo);
      expect(q.value, closeTo(6.62607015e-34, 1e-44));
      expect(q.dimension, Dimension({'kg': 1, 'm': 2, 's': -1}));
    });

    test('N_A = 6.02214076e23 /mol', () {
      final def = repo.getUnit('N_A').definition;
      final q = def.toQuantity(1.0, repo);
      expect(q.value, closeTo(6.02214076e23, 1e13));
      expect(q.dimension, Dimension({'mol': -1}));
    });

    test('k_B = 1.380649e-23 kg*m^2/(s^2*K)', () {
      final def = repo.getUnit('k_B').definition;
      final q = def.toQuantity(1.0, repo);
      expect(q.value, closeTo(1.380649e-23, 1e-33));
      expect(q.dimension, Dimension({'kg': 1, 'm': 2, 's': -2, 'K': -1}));
    });

    test('e = 1.602176634e-19 A*s', () {
      final def = repo.getUnit('e').definition;
      final q = def.toQuantity(1.0, repo);
      expect(q.value, closeTo(1.602176634e-19, 1e-29));
      expect(q.dimension, Dimension({'A': 1, 's': 1}));
    });

    test('R = 8.314462618 kg*m^2/(s^2*K*mol)', () {
      final def = repo.getUnit('R').definition;
      final q = def.toQuantity(1.0, repo);
      expect(q.value, closeTo(8.314462618, 1e-9));
      expect(
        q.dimension,
        Dimension({'kg': 1, 'm': 2, 's': -2, 'K': -1, 'mol': -1}),
      );
    });

    test('constant aliases resolve correctly', () {
      expect(repo.findUnit('speed_of_light')?.id, 'c');
      expect(repo.findUnit('g0')?.id, 'gravity');
      expect(repo.findUnit('planck')?.id, 'h');
      expect(repo.findUnit('avogadro')?.id, 'N_A');
      expect(repo.findUnit('boltzmann')?.id, 'k_B');
      expect(repo.findUnit('elementary_charge')?.id, 'e');
      expect(repo.findUnit('gas_constant')?.id, 'R');
    });

    test('2 pi ≈ 6.28318', () {
      final def = repo.getUnit('pi').definition;
      final q = def.toQuantity(2.0, repo);
      expect(q.value, closeTo(2 * math.pi, 1e-10));
    });
  });

  group('Compound units', () {
    test('all compound units are resolved', () {
      for (final id in [
        'N',
        'Pa',
        'J',
        'W',
        'Hz',
        'C',
        'V',
        'ohm',
        'F',
        'Wb',
        'T',
        'H',
      ]) {
        final unit = repo.getUnit(id);
        expect(
          unit.definition,
          isA<CompoundDefinition>(),
          reason: '$id should be CompoundDefinition',
        );
        expect(
          (unit.definition as CompoundDefinition).isResolved,
          isTrue,
          reason: '$id should be resolved',
        );
      }
    });

    test('N has dimension {kg:1, m:1, s:-2}', () {
      final q = repo.getUnit('N').definition.toQuantity(1.0, repo);
      expect(q.value, closeTo(1.0, 1e-10));
      expect(q.dimension, Dimension({'kg': 1, 'm': 1, 's': -2}));
    });

    test('Pa has dimension {kg:1, m:-1, s:-2}', () {
      final q = repo.getUnit('Pa').definition.toQuantity(1.0, repo);
      expect(q.value, closeTo(1.0, 1e-10));
      expect(q.dimension, Dimension({'kg': 1, 'm': -1, 's': -2}));
    });

    test('J has dimension {kg:1, m:2, s:-2}', () {
      final q = repo.getUnit('J').definition.toQuantity(1.0, repo);
      expect(q.value, closeTo(1.0, 1e-10));
      expect(q.dimension, Dimension({'kg': 1, 'm': 2, 's': -2}));
    });

    test('W has dimension {kg:1, m:2, s:-3}', () {
      final q = repo.getUnit('W').definition.toQuantity(1.0, repo);
      expect(q.value, closeTo(1.0, 1e-10));
      expect(q.dimension, Dimension({'kg': 1, 'm': 2, 's': -3}));
    });

    test('Hz has dimension {s:-1}', () {
      final q = repo.getUnit('Hz').definition.toQuantity(1.0, repo);
      expect(q.value, closeTo(1.0, 1e-10));
      expect(q.dimension, Dimension({'s': -1}));
    });

    test('C (coulomb) has dimension {A:1, s:1}', () {
      final q = repo.getUnit('C').definition.toQuantity(1.0, repo);
      expect(q.value, closeTo(1.0, 1e-10));
      expect(q.dimension, Dimension({'A': 1, 's': 1}));
    });

    test('V has dimension {kg:1, m:2, s:-3, A:-1}', () {
      final q = repo.getUnit('V').definition.toQuantity(1.0, repo);
      expect(q.value, closeTo(1.0, 1e-10));
      expect(q.dimension, Dimension({'kg': 1, 'm': 2, 's': -3, 'A': -1}));
    });

    test('ohm has dimension {kg:1, m:2, s:-3, A:-2}', () {
      final q = repo.getUnit('ohm').definition.toQuantity(1.0, repo);
      expect(q.value, closeTo(1.0, 1e-10));
      expect(q.dimension, Dimension({'kg': 1, 'm': 2, 's': -3, 'A': -2}));
    });

    test('F (farad) has dimension {A:2, s:4, kg:-1, m:-2}', () {
      final q = repo.getUnit('F').definition.toQuantity(1.0, repo);
      expect(q.value, closeTo(1.0, 1e-10));
      expect(q.dimension, Dimension({'A': 2, 's': 4, 'kg': -1, 'm': -2}));
    });

    test('Wb has dimension {kg:1, m:2, s:-2, A:-1}', () {
      final q = repo.getUnit('Wb').definition.toQuantity(1.0, repo);
      expect(q.value, closeTo(1.0, 1e-10));
      expect(q.dimension, Dimension({'kg': 1, 'm': 2, 's': -2, 'A': -1}));
    });

    test('T has dimension {kg:1, s:-2, A:-1}', () {
      final q = repo.getUnit('T').definition.toQuantity(1.0, repo);
      expect(q.value, closeTo(1.0, 1e-10));
      expect(q.dimension, Dimension({'kg': 1, 's': -2, 'A': -1}));
    });

    test('H has dimension {kg:1, m:2, s:-2, A:-2}', () {
      final q = repo.getUnit('H').definition.toQuantity(1.0, repo);
      expect(q.value, closeTo(1.0, 1e-10));
      expect(q.dimension, Dimension({'kg': 1, 'm': 2, 's': -2, 'A': -2}));
    });

    test('5 N = Quantity(5, {kg:1, m:1, s:-2})', () {
      final q = repo.getUnit('N').definition.toQuantity(5.0, repo);
      expect(q.value, closeTo(5.0, 1e-10));
      expect(q.dimension, Dimension({'kg': 1, 'm': 1, 's': -2}));
    });

    test('compound unit aliases resolve correctly', () {
      expect(repo.findUnit('newton')?.id, 'N');
      expect(repo.findUnit('pascal')?.id, 'Pa');
      expect(repo.findUnit('joule')?.id, 'J');
      expect(repo.findUnit('watt')?.id, 'W');
      expect(repo.findUnit('hertz')?.id, 'Hz');
      expect(repo.findUnit('coulomb')?.id, 'C');
      expect(repo.findUnit('volt')?.id, 'V');
      expect(repo.findUnit('Ohm')?.id, 'ohm');
      expect(repo.findUnit('farad')?.id, 'F');
      expect(repo.findUnit('weber')?.id, 'Wb');
      expect(repo.findUnit('tesla')?.id, 'T');
      expect(repo.findUnit('henry')?.id, 'H');
    });
  });
}
