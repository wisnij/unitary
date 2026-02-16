import '../models/unit.dart';
import '../models/unit_repository.dart';

/// Registers all built-in units into the given [repo].
///
/// Includes 24 SI prefixes, length (7), mass (5), time (5),
/// temperature (9), other SI base units (3), dimensionless units (2),
/// constants (10), and derived units (12).
void registerBuiltinUnits(UnitRepository repo) {
  _registerPrefixes(repo);
  _registerLengthUnits(repo);
  _registerMassUnits(repo);
  _registerTimeUnits(repo);
  _registerTemperatureUnits(repo);
  _registerElectricalBaseUnit(repo);
  _registerOtherBaseUnits(repo);
  _registerDimensionlessUnits(repo);
  _registerConstants(repo);
  _registerDerivedUnits(repo);
}

void _registerPrefixes(UnitRepository repo) {
  // SI prefixes: 24 total, from quecto (10^-30) to quetta (10^30).
  // Long name as id, short symbol as alias.
  const prefixes = [
    PrefixUnit(id: 'quetta', aliases: ['Q'], expression: '1e30'),
    PrefixUnit(id: 'ronna', aliases: ['R'], expression: '1e27'),
    PrefixUnit(id: 'yotta', aliases: ['Y'], expression: '1e24'),
    PrefixUnit(id: 'zetta', aliases: ['Z'], expression: '1e21'),
    PrefixUnit(id: 'exa', aliases: ['E'], expression: '1e18'),
    PrefixUnit(id: 'peta', aliases: ['P'], expression: '1e15'),
    PrefixUnit(id: 'tera', aliases: ['T'], expression: '1e12'),
    PrefixUnit(id: 'giga', aliases: ['G'], expression: '1e9'),
    PrefixUnit(id: 'mega', aliases: ['M'], expression: '1e6'),
    PrefixUnit(id: 'kilo', aliases: ['k'], expression: '1000'),
    PrefixUnit(id: 'hecto', aliases: ['h'], expression: '100'),
    PrefixUnit(id: 'deca', aliases: ['da'], expression: '10'),
    PrefixUnit(id: 'deci', aliases: ['d'], expression: '0.1'),
    PrefixUnit(id: 'centi', aliases: ['c'], expression: '0.01'),
    PrefixUnit(id: 'milli', aliases: ['m'], expression: '0.001'),
    PrefixUnit(id: 'micro', aliases: ['u'], expression: '1e-6'),
    PrefixUnit(id: 'nano', aliases: ['n'], expression: '1e-9'),
    PrefixUnit(id: 'pico', aliases: ['p'], expression: '1e-12'),
    PrefixUnit(id: 'femto', aliases: ['f'], expression: '1e-15'),
    PrefixUnit(id: 'atto', aliases: ['a'], expression: '1e-18'),
    PrefixUnit(id: 'zepto', aliases: ['z'], expression: '1e-21'),
    PrefixUnit(id: 'yocto', aliases: ['y'], expression: '1e-24'),
    PrefixUnit(id: 'ronto', aliases: ['r'], expression: '1e-27'),
    PrefixUnit(id: 'quecto', aliases: ['q'], expression: '1e-30'),
  ];
  for (final prefix in prefixes) {
    repo.registerPrefix(prefix);
  }
}

void _registerLengthUnits(UnitRepository repo) {
  repo.register(
    const PrimitiveUnit(
      id: 'm',
      aliases: ['meter', 'metre'],
      description: 'SI base unit of length',
    ),
  );
  repo.register(
    // km, cm, mm are derivable via prefix splitting (kilo/centi/milli + meter).
    // um (micrometer) is also derivable, but 'micron' is a non-prefix alias.
    const DerivedUnit(
      id: 'micron',
      expression: 'micrometer',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'in',
      aliases: ['inch'],
      expression: '2.54 cm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ft',
      aliases: ['foot', 'feet'],
      expression: '12 inch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'yd',
      aliases: ['yard'],
      expression: '3 ft',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mi',
      aliases: ['mile'],
      expression: '5280 ft',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nmi',
      aliases: ['nautical_mile'],
      expression: '1852 m',
    ),
  );
}

void _registerMassUnits(UnitRepository repo) {
  repo.register(
    const PrimitiveUnit(
      id: 'kg',
      aliases: ['kilogram'],
      description: 'SI base unit of mass',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'g',
      aliases: ['gram'],
      expression: '0.001 kg',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lb',
      aliases: ['pound'],
      expression: '453.59237 g',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'oz',
      aliases: ['ounce'],
      expression: '1|16 lb',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 't',
      aliases: ['tonne', 'metric_ton'],
      expression: '1000 kg',
    ),
  );
}

void _registerTimeUnits(UnitRepository repo) {
  repo.register(
    const PrimitiveUnit(
      id: 's',
      aliases: ['second', 'sec'],
      description: 'SI base unit of time',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'min',
      aliases: ['minute'],
      expression: '60 s',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hr',
      aliases: ['hour'],
      expression: '60 min',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'day',
      expression: '24 hour',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'week',
      aliases: ['wk'],
      expression: '7 day',
    ),
  );
}

void _registerTemperatureUnits(UnitRepository repo) {
  // K is the SI base primitive for temperature.
  repo.register(
    const PrimitiveUnit(
      id: 'K',
      aliases: ['kelvin'],
      description: 'SI base unit of temperature',
    ),
  );

  // Degree variants (derived — temperature differences).
  repo.register(
    const DerivedUnit(
      id: 'degK',
      aliases: ['degkelvin'],
      expression: 'K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'degC',
      aliases: ['degcelsius'],
      expression: 'K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'degF',
      aliases: ['degfahrenheit'],
      expression: '5|9 K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'degR',
      aliases: ['degrankine'],
      expression: '5|9 K',
    ),
  );

  // Affine variants (absolute temperature readings).
  // Formula: (value + offset) * factor → kelvin
  repo.register(
    const AffineUnit(
      id: 'tempK',
      aliases: ['tempkelvin'],
      factor: 1.0,
      offset: 0.0,
      baseUnitId: 'K',
    ),
  );
  repo.register(
    const AffineUnit(
      id: 'tempC',
      aliases: ['tempcelsius'],
      factor: 1.0,
      offset: 273.15,
      baseUnitId: 'K',
    ),
  );
  repo.register(
    const AffineUnit(
      id: 'tempF',
      aliases: ['tempfahrenheit'],
      factor: 5 / 9,
      offset: 459.67,
      baseUnitId: 'K',
    ),
  );
  repo.register(
    const AffineUnit(
      id: 'tempR',
      aliases: ['temprankine'],
      factor: 5 / 9,
      offset: 0.0,
      baseUnitId: 'K',
    ),
  );
}

void _registerElectricalBaseUnit(UnitRepository repo) {
  repo.register(
    const PrimitiveUnit(
      id: 'A',
      aliases: ['ampere', 'amp'],
      description: 'SI base unit of electric current',
    ),
  );
}

void _registerOtherBaseUnits(UnitRepository repo) {
  repo.register(
    const PrimitiveUnit(
      id: 'mol',
      aliases: ['mole'],
      description: 'SI base unit of amount of substance',
    ),
  );
  repo.register(
    const PrimitiveUnit(
      id: 'cd',
      aliases: ['candela'],
      description: 'SI base unit of luminous intensity',
    ),
  );
}

void _registerDimensionlessUnits(UnitRepository repo) {
  repo.register(
    const PrimitiveUnit(
      id: 'radian',
      description: 'SI dimensionless unit of plane angle',
      isDimensionless: true,
    ),
  );
  repo.register(
    const PrimitiveUnit(
      id: 'sr',
      aliases: ['steradian'],
      description: 'SI dimensionless unit of solid angle',
      isDimensionless: true,
    ),
  );
}

void _registerConstants(UnitRepository repo) {
  // Mathematical constants (dimensionless).
  repo.register(
    const DerivedUnit(
      id: 'pi',
      expression: '3.141592653589793',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'euler',
      expression: '2.718281828459045',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tau',
      expression: '2 pi',
    ),
  );

  // Physical constants (dimensioned).
  repo.register(
    const DerivedUnit(
      id: 'c',
      aliases: ['speed_of_light'],
      expression: '299792458 m/s',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gravity',
      aliases: ['g0'],
      expression: '9.80665 m/s^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'h',
      aliases: ['planck'],
      expression: '6.62607015e-34 J s',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'N_A',
      aliases: ['avogadro'],
      expression: '6.02214076e23 / mol',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'k',
      aliases: ['boltzmann'],
      expression: '1.380649e-23 J/K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'e',
      aliases: ['elementary_charge'],
      expression: '1.602176634e-19 C',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'R',
      aliases: ['gas_constant'],
      expression: 'k N_A',
    ),
  );
}

void _registerDerivedUnits(UnitRepository repo) {
  repo.register(
    const DerivedUnit(
      id: 'N',
      aliases: ['newton'],
      expression: 'kg m / s^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'Pa',
      aliases: ['pascal'],
      expression: 'N / m^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'J',
      aliases: ['joule'],
      expression: 'N m',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'W',
      aliases: ['watt'],
      expression: 'J / s',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'Hz',
      aliases: ['hertz'],
      expression: '/ s',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'C',
      aliases: ['coulomb'],
      expression: 'A s',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'V',
      aliases: ['volt'],
      expression: 'W / A',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ohm',
      expression: 'V / A',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'F',
      aliases: ['farad'],
      expression: 'C / V',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'Wb',
      aliases: ['weber'],
      expression: 'V s',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'T',
      aliases: ['tesla'],
      expression: 'Wb / m^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'H',
      aliases: ['henry'],
      expression: 'Wb / A',
    ),
  );
}
