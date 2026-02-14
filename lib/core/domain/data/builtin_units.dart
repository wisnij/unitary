import '../models/unit.dart';
import '../models/unit_definition.dart';
import '../models/unit_repository.dart';

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
      definition: CompoundDefinition(expression: '1000 m'),
    ),
  );
  repo.register(
    const Unit(
      id: 'cm',
      aliases: ['centimeter', 'centimetre'],
      definition: CompoundDefinition(expression: '0.01 m'),
    ),
  );
  repo.register(
    const Unit(
      id: 'mm',
      aliases: ['millimeter', 'millimetre'],
      definition: CompoundDefinition(expression: '0.001 m'),
    ),
  );
  repo.register(
    const Unit(
      id: 'um',
      aliases: ['micrometer', 'micrometre', 'micron'],
      definition: CompoundDefinition(expression: '1e-6 m'),
    ),
  );
  repo.register(
    const Unit(
      id: 'in',
      aliases: ['inch'],
      definition: CompoundDefinition(expression: '2.54 cm'),
    ),
  );
  repo.register(
    const Unit(
      id: 'ft',
      aliases: ['foot', 'feet'],
      definition: CompoundDefinition(expression: '12 inch'),
    ),
  );
  repo.register(
    const Unit(
      id: 'yd',
      aliases: ['yard'],
      definition: CompoundDefinition(expression: '3 ft'),
    ),
  );
  repo.register(
    const Unit(
      id: 'mi',
      aliases: ['mile'],
      definition: CompoundDefinition(expression: '1609.344 m'),
    ),
  );
  repo.register(
    const Unit(
      id: 'nmi',
      aliases: ['nautical_mile'],
      definition: CompoundDefinition(expression: '1852 m'),
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
      definition: CompoundDefinition(expression: '0.001 kg'),
    ),
  );
  repo.register(
    const Unit(
      id: 'mg',
      aliases: ['milligram'],
      definition: CompoundDefinition(expression: '1e-3 g'),
    ),
  );
  repo.register(
    const Unit(
      id: 'lb',
      aliases: ['pound'],
      definition: CompoundDefinition(expression: '453.59237 g'),
    ),
  );
  repo.register(
    const Unit(
      id: 'oz',
      aliases: ['ounce'],
      definition: CompoundDefinition(expression: '28.349523125 g'),
    ),
  );
  repo.register(
    const Unit(
      id: 't',
      aliases: ['tonne', 'metric_ton'],
      definition: CompoundDefinition(expression: '1000 kg'),
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
      definition: CompoundDefinition(expression: '0.001 s'),
    ),
  );
  repo.register(
    const Unit(
      id: 'min',
      aliases: ['minute'],
      definition: CompoundDefinition(expression: '60 s'),
    ),
  );
  repo.register(
    const Unit(
      id: 'hr',
      aliases: ['hour'],
      definition: CompoundDefinition(expression: '60 min'),
    ),
  );
  repo.register(
    const Unit(
      id: 'day',
      definition: CompoundDefinition(expression: '24 hour'),
    ),
  );
  repo.register(
    const Unit(
      id: 'week',
      aliases: ['wk'],
      definition: CompoundDefinition(expression: '7 day'),
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

  // Degree variants (compound — temperature differences).
  repo.register(
    const Unit(
      id: 'degK',
      aliases: ['degkelvin'],
      definition: CompoundDefinition(expression: 'K'),
    ),
  );
  repo.register(
    const Unit(
      id: 'degC',
      aliases: ['degcelsius'],
      definition: CompoundDefinition(expression: 'K'),
    ),
  );
  repo.register(
    const Unit(
      id: 'degF',
      aliases: ['degfahrenheit'],
      definition: CompoundDefinition(expression: '(5/9) K'),
    ),
  );
  repo.register(
    const Unit(
      id: 'degR',
      aliases: ['degrankine'],
      definition: CompoundDefinition(expression: '(5/9) K'),
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
    const Unit(
      id: 'pi',
      definition: CompoundDefinition(expression: '3.141592653589793'),
    ),
  );
  repo.register(
    const Unit(
      id: 'euler',
      definition: CompoundDefinition(expression: '2.718281828459045'),
    ),
  );
  repo.register(
    const Unit(
      id: 'tau',
      definition: CompoundDefinition(expression: '6.283185307179586'),
    ),
  );

  // Physical constants (dimensioned).
  repo.register(
    const Unit(
      id: 'c',
      aliases: ['speed_of_light'],
      definition: CompoundDefinition(expression: '299792458 m / s'),
    ),
  );
  repo.register(
    const Unit(
      id: 'gravity',
      aliases: ['g0'],
      definition: CompoundDefinition(expression: '9.80665 m / s^2'),
    ),
  );
  repo.register(
    const Unit(
      id: 'h',
      aliases: ['planck'],
      definition: CompoundDefinition(expression: '6.62607015e-34 kg m^2 / s'),
    ),
  );
  repo.register(
    const Unit(
      id: 'N_A',
      aliases: ['avogadro'],
      definition: CompoundDefinition(expression: '6.02214076e23 / mol'),
    ),
  );
  repo.register(
    const Unit(
      id: 'k_B',
      aliases: ['boltzmann'],
      definition: CompoundDefinition(
        expression: '1.380649e-23 kg m^2 / (s^2 K)',
      ),
    ),
  );
  repo.register(
    const Unit(
      id: 'e',
      aliases: ['elementary_charge'],
      definition: CompoundDefinition(expression: '1.602176634e-19 A s'),
    ),
  );
  repo.register(
    const Unit(
      id: 'R',
      aliases: ['gas_constant'],
      definition: CompoundDefinition(
        expression: '8.314462618 kg m^2 / (s^2 K mol)',
      ),
    ),
  );
}

void _registerCompoundUnits(UnitRepository repo) {
  repo.register(
    const Unit(
      id: 'N',
      aliases: ['newton'],
      definition: CompoundDefinition(expression: 'kg m / s^2'),
    ),
  );
  repo.register(
    const Unit(
      id: 'Pa',
      aliases: ['pascal'],
      definition: CompoundDefinition(expression: 'N / m^2'),
    ),
  );
  repo.register(
    const Unit(
      id: 'J',
      aliases: ['joule'],
      definition: CompoundDefinition(expression: 'N m'),
    ),
  );
  repo.register(
    const Unit(
      id: 'W',
      aliases: ['watt'],
      definition: CompoundDefinition(expression: 'J / s'),
    ),
  );
  repo.register(
    const Unit(
      id: 'Hz',
      aliases: ['hertz'],
      definition: CompoundDefinition(expression: '/ s'),
    ),
  );
  repo.register(
    const Unit(
      id: 'C',
      aliases: ['coulomb'],
      definition: CompoundDefinition(expression: 'A s'),
    ),
  );
  repo.register(
    const Unit(
      id: 'V',
      aliases: ['volt'],
      definition: CompoundDefinition(expression: 'W / A'),
    ),
  );
  repo.register(
    const Unit(
      id: 'ohm',
      aliases: ['Ohm'],
      definition: CompoundDefinition(expression: 'V / A'),
    ),
  );
  repo.register(
    const Unit(
      id: 'F',
      aliases: ['farad'],
      definition: CompoundDefinition(expression: 'C / V'),
    ),
  );
  repo.register(
    const Unit(
      id: 'Wb',
      aliases: ['weber'],
      definition: CompoundDefinition(expression: 'V s'),
    ),
  );
  repo.register(
    const Unit(
      id: 'T',
      aliases: ['tesla'],
      definition: CompoundDefinition(expression: 'Wb / m^2'),
    ),
  );
  repo.register(
    const Unit(
      id: 'H',
      aliases: ['henry'],
      definition: CompoundDefinition(expression: 'Wb / A'),
    ),
  );
}
