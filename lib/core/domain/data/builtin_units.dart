import 'dart:math' as math;

import '../models/dimension.dart';
import '../models/unit.dart';
import '../models/unit_definition.dart';
import '../models/unit_repository.dart';
import '../parser/expression_parser.dart';

/// Registers all built-in units into the given [repo].
///
/// Includes length (10), mass (6), time (6), temperature (9),
/// other SI base units (3), constants (10), and compound units (12).
void registerBuiltinUnits(UnitRepository repo) {
  _registerLengthUnits(repo);
  _registerMassUnits(repo);
  _registerTimeUnits(repo);
  _registerTemperatureUnits(repo);
  _registerElectricalBaseUnit(repo);
  _registerOtherBaseUnits(repo);
  _registerConstants(repo);
  _registerCompoundUnits(repo);
}

void _registerLengthUnits(UnitRepository repo) {
  repo.register(
    Unit(
      id: 'm',
      aliases: ['meter', 'metre'],
      description: 'SI base unit of length',
      definition: PrimitiveUnitDefinition(),
    ),
  );
  repo.register(
    const Unit(
      id: 'km',
      aliases: ['kilometer', 'kilometre'],
      definition: LinearDefinition(factor: 1000, baseUnitId: 'm'),
    ),
  );
  repo.register(
    const Unit(
      id: 'cm',
      aliases: ['centimeter', 'centimetre'],
      definition: LinearDefinition(factor: 0.01, baseUnitId: 'm'),
    ),
  );
  repo.register(
    const Unit(
      id: 'mm',
      aliases: ['millimeter', 'millimetre'],
      definition: LinearDefinition(factor: 0.001, baseUnitId: 'm'),
    ),
  );
  repo.register(
    const Unit(
      id: 'um',
      aliases: ['micrometer', 'micrometre', 'micron'],
      definition: LinearDefinition(factor: 1e-6, baseUnitId: 'm'),
    ),
  );
  repo.register(
    const Unit(
      id: 'in',
      aliases: ['inch'],
      definition: LinearDefinition(factor: 2.54, baseUnitId: 'cm'),
    ),
  );
  repo.register(
    const Unit(
      id: 'ft',
      aliases: ['foot', 'feet'],
      definition: LinearDefinition(factor: 12.0, baseUnitId: 'inch'),
    ),
  );
  repo.register(
    const Unit(
      id: 'yd',
      aliases: ['yard'],
      definition: LinearDefinition(factor: 3.0, baseUnitId: 'ft'),
    ),
  );
  repo.register(
    const Unit(
      id: 'mi',
      aliases: ['mile'],
      definition: LinearDefinition(factor: 1609.344, baseUnitId: 'm'),
    ),
  );
  repo.register(
    const Unit(
      id: 'nmi',
      aliases: ['nautical_mile'],
      definition: LinearDefinition(factor: 1852, baseUnitId: 'm'),
    ),
  );
}

void _registerMassUnits(UnitRepository repo) {
  repo.register(
    Unit(
      id: 'kg',
      aliases: ['kilogram'],
      description: 'SI base unit of mass',
      definition: PrimitiveUnitDefinition(),
    ),
  );
  repo.register(
    const Unit(
      id: 'g',
      aliases: ['gram'],
      definition: LinearDefinition(factor: 0.001, baseUnitId: 'kg'),
    ),
  );
  repo.register(
    const Unit(
      id: 'mg',
      aliases: ['milligram'],
      definition: LinearDefinition(factor: 1e-3, baseUnitId: 'g'),
    ),
  );
  repo.register(
    const Unit(
      id: 'lb',
      aliases: ['pound'],
      definition: LinearDefinition(factor: 453.59237, baseUnitId: 'g'),
    ),
  );
  repo.register(
    const Unit(
      id: 'oz',
      aliases: ['ounce'],
      definition: LinearDefinition(factor: 28.349523125, baseUnitId: 'g'),
    ),
  );
  repo.register(
    const Unit(
      id: 't',
      aliases: ['tonne', 'metric_ton'],
      definition: LinearDefinition(factor: 1000, baseUnitId: 'kg'),
    ),
  );
}

void _registerTimeUnits(UnitRepository repo) {
  repo.register(
    Unit(
      id: 's',
      aliases: ['second', 'sec'],
      description: 'SI base unit of time',
      definition: PrimitiveUnitDefinition(),
    ),
  );
  repo.register(
    const Unit(
      id: 'ms',
      aliases: ['millisecond'],
      definition: LinearDefinition(factor: 0.001, baseUnitId: 's'),
    ),
  );
  repo.register(
    const Unit(
      id: 'min',
      aliases: ['minute'],
      definition: LinearDefinition(factor: 60, baseUnitId: 's'),
    ),
  );
  repo.register(
    const Unit(
      id: 'hr',
      aliases: ['hour'],
      definition: LinearDefinition(factor: 60, baseUnitId: 'min'),
    ),
  );
  repo.register(
    const Unit(
      id: 'day',
      definition: LinearDefinition(factor: 24, baseUnitId: 'hour'),
    ),
  );
  repo.register(
    const Unit(
      id: 'week',
      aliases: ['wk'],
      definition: LinearDefinition(factor: 7, baseUnitId: 'day'),
    ),
  );
}

void _registerTemperatureUnits(UnitRepository repo) {
  // K is the SI base primitive for temperature.
  repo.register(
    Unit(
      id: 'K',
      aliases: ['kelvin'],
      description: 'SI base unit of temperature',
      definition: PrimitiveUnitDefinition(),
    ),
  );

  // Degree variants (linear — temperature differences).
  repo.register(
    const Unit(
      id: 'degK',
      aliases: ['degkelvin'],
      definition: LinearDefinition(factor: 1.0, baseUnitId: 'K'),
    ),
  );
  repo.register(
    const Unit(
      id: 'degC',
      aliases: ['degcelsius'],
      definition: LinearDefinition(factor: 1.0, baseUnitId: 'K'),
    ),
  );
  repo.register(
    const Unit(
      id: 'degF',
      aliases: ['degfahrenheit'],
      definition: LinearDefinition(factor: 5 / 9, baseUnitId: 'K'),
    ),
  );
  repo.register(
    const Unit(
      id: 'degR',
      aliases: ['degrankine'],
      definition: LinearDefinition(factor: 5 / 9, baseUnitId: 'K'),
    ),
  );

  // Affine variants (absolute temperature readings).
  // Formula: (value + offset) * factor → kelvin
  repo.register(
    const Unit(
      id: 'tempK',
      aliases: ['tempkelvin'],
      definition: AffineDefinition(factor: 1.0, offset: 0.0, baseUnitId: 'K'),
    ),
  );
  repo.register(
    const Unit(
      id: 'tempC',
      aliases: ['tempcelsius'],
      definition: AffineDefinition(
        factor: 1.0,
        offset: 273.15,
        baseUnitId: 'K',
      ),
    ),
  );
  repo.register(
    const Unit(
      id: 'tempF',
      aliases: ['tempfahrenheit'],
      definition: AffineDefinition(
        factor: 5 / 9,
        offset: 459.67,
        baseUnitId: 'K',
      ),
    ),
  );
  repo.register(
    const Unit(
      id: 'tempR',
      aliases: ['temprankine'],
      definition: AffineDefinition(factor: 5 / 9, offset: 0.0, baseUnitId: 'K'),
    ),
  );
}

void _registerElectricalBaseUnit(UnitRepository repo) {
  repo.register(
    Unit(
      id: 'A',
      aliases: ['ampere', 'amp'],
      description: 'SI base unit of electric current',
      definition: PrimitiveUnitDefinition(),
    ),
  );
}

void _registerOtherBaseUnits(UnitRepository repo) {
  repo.register(
    Unit(
      id: 'mol',
      aliases: ['mole'],
      description: 'SI base unit of amount of substance',
      definition: PrimitiveUnitDefinition(),
    ),
  );
  repo.register(
    Unit(
      id: 'cd',
      aliases: ['candela'],
      description: 'SI base unit of luminous intensity',
      definition: PrimitiveUnitDefinition(),
    ),
  );
}

void _registerConstants(UnitRepository repo) {
  // Mathematical constants (dimensionless).
  repo.register(
    Unit(
      id: 'pi',
      definition: ConstantDefinition(
        constantValue: math.pi,
        dimension: Dimension.dimensionless,
      ),
    ),
  );
  repo.register(
    Unit(
      id: 'euler',
      definition: ConstantDefinition(
        constantValue: math.e,
        dimension: Dimension.dimensionless,
      ),
    ),
  );
  repo.register(
    Unit(
      id: 'tau',
      definition: ConstantDefinition(
        constantValue: 2 * math.pi,
        dimension: Dimension.dimensionless,
      ),
    ),
  );

  // Physical constants (dimensioned).
  repo.register(
    Unit(
      id: 'c',
      aliases: ['speed_of_light'],
      definition: ConstantDefinition(
        constantValue: 299792458.0,
        dimension: Dimension({'m': 1, 's': -1}),
      ),
    ),
  );
  repo.register(
    Unit(
      id: 'gravity',
      aliases: ['g0'],
      definition: ConstantDefinition(
        constantValue: 9.80665,
        dimension: Dimension({'m': 1, 's': -2}),
      ),
    ),
  );
  repo.register(
    Unit(
      id: 'h',
      aliases: ['planck'],
      definition: ConstantDefinition(
        constantValue: 6.62607015e-34,
        dimension: Dimension({'kg': 1, 'm': 2, 's': -1}),
      ),
    ),
  );
  repo.register(
    Unit(
      id: 'N_A',
      aliases: ['avogadro'],
      definition: ConstantDefinition(
        constantValue: 6.02214076e23,
        dimension: Dimension({'mol': -1}),
      ),
    ),
  );
  repo.register(
    Unit(
      id: 'k_B',
      aliases: ['boltzmann'],
      definition: ConstantDefinition(
        constantValue: 1.380649e-23,
        dimension: Dimension({'kg': 1, 'm': 2, 's': -2, 'K': -1}),
      ),
    ),
  );
  repo.register(
    Unit(
      id: 'e',
      aliases: ['elementary_charge'],
      definition: ConstantDefinition(
        constantValue: 1.602176634e-19,
        dimension: Dimension({'A': 1, 's': 1}),
      ),
    ),
  );
  repo.register(
    Unit(
      id: 'R',
      aliases: ['gas_constant'],
      definition: ConstantDefinition(
        constantValue: 8.314462618,
        dimension: Dimension({'kg': 1, 'm': 2, 's': -2, 'K': -1, 'mol': -1}),
      ),
    ),
  );
}

void _registerCompoundUnits(UnitRepository repo) {
  // Helper: parse an expression, register the unit, and resolve it.
  void registerCompound(String id, List<String> aliases, String expression) {
    final def = CompoundDefinition(expression: expression);
    repo.register(Unit(id: id, aliases: aliases, definition: def));
    final quantity = ExpressionParser(repo: repo).evaluate(expression);
    def.resolve(quantity);
  }

  // Order matters: each unit can only reference already-registered units.
  registerCompound('N', ['newton'], 'kg m / s^2');
  registerCompound('Pa', ['pascal'], 'N / m^2');
  registerCompound('J', ['joule'], 'N m');
  registerCompound('W', ['watt'], 'J / s');
  registerCompound('Hz', ['hertz'], '/ s');
  registerCompound('C', ['coulomb'], 'A s');
  registerCompound('V', ['volt'], 'W / A');
  registerCompound('ohm', ['Ohm'], 'V / A');
  registerCompound('F', ['farad'], 'C / V');
  registerCompound('Wb', ['weber'], 'V s');
  registerCompound('T', ['tesla'], 'Wb / m^2');
  registerCompound('H', ['henry'], 'Wb / A');
}
