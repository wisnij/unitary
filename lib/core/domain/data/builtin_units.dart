import '../models/unit.dart';
import '../models/unit_repository.dart';

/// Registers all built-in units into the given [repo].
///
/// Includes length (10), mass (6), time (6), temperature (9),
/// other SI base units (3), dimensionless units (2), constants (10),
/// and compound units (12).
void registerBuiltinUnits(UnitRepository repo) {
  _registerLengthUnits(repo);
  _registerMassUnits(repo);
  _registerTimeUnits(repo);
  _registerTemperatureUnits(repo);
  _registerElectricalBaseUnit(repo);
  _registerOtherBaseUnits(repo);
  _registerDimensionlessUnits(repo);
  _registerConstants(repo);
  _registerCompoundUnits(repo);
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
    const CompoundUnit(
      id: 'km',
      aliases: ['kilometer', 'kilometre'],
      expression: '1000 m',
    ),
  );
  repo.register(
    const CompoundUnit(
      id: 'cm',
      aliases: ['centimeter', 'centimetre'],
      expression: '0.01 m',
    ),
  );
  repo.register(
    const CompoundUnit(
      id: 'mm',
      aliases: ['millimeter', 'millimetre'],
      expression: '0.001 m',
    ),
  );
  repo.register(
    const CompoundUnit(
      id: 'um',
      aliases: ['micrometer', 'micrometre', 'micron'],
      expression: '1e-6 m',
    ),
  );
  repo.register(
    const CompoundUnit(id: 'in', aliases: ['inch'], expression: '2.54 cm'),
  );
  repo.register(
    const CompoundUnit(
      id: 'ft',
      aliases: ['foot', 'feet'],
      expression: '12 inch',
    ),
  );
  repo.register(
    const CompoundUnit(id: 'yd', aliases: ['yard'], expression: '3 ft'),
  );
  repo.register(
    const CompoundUnit(id: 'mi', aliases: ['mile'], expression: '1609.344 m'),
  );
  repo.register(
    const CompoundUnit(
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
    const CompoundUnit(id: 'g', aliases: ['gram'], expression: '0.001 kg'),
  );
  repo.register(
    const CompoundUnit(id: 'mg', aliases: ['milligram'], expression: '1e-3 g'),
  );
  repo.register(
    const CompoundUnit(id: 'lb', aliases: ['pound'], expression: '453.59237 g'),
  );
  repo.register(
    const CompoundUnit(
      id: 'oz',
      aliases: ['ounce'],
      expression: '28.349523125 g',
    ),
  );
  repo.register(
    const CompoundUnit(
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
    const CompoundUnit(
      id: 'ms',
      aliases: ['millisecond'],
      expression: '0.001 s',
    ),
  );
  repo.register(
    const CompoundUnit(id: 'min', aliases: ['minute'], expression: '60 s'),
  );
  repo.register(
    const CompoundUnit(id: 'hr', aliases: ['hour'], expression: '60 min'),
  );
  repo.register(const CompoundUnit(id: 'day', expression: '24 hour'));
  repo.register(
    const CompoundUnit(id: 'week', aliases: ['wk'], expression: '7 day'),
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

  // Degree variants (compound — temperature differences).
  repo.register(
    const CompoundUnit(id: 'degK', aliases: ['degkelvin'], expression: 'K'),
  );
  repo.register(
    const CompoundUnit(id: 'degC', aliases: ['degcelsius'], expression: 'K'),
  );
  repo.register(
    const CompoundUnit(
      id: 'degF',
      aliases: ['degfahrenheit'],
      expression: '(5/9) K',
    ),
  );
  repo.register(
    const CompoundUnit(
      id: 'degR',
      aliases: ['degrankine'],
      expression: '(5/9) K',
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
  repo.register(const CompoundUnit(id: 'pi', expression: '3.141592653589793'));
  repo.register(
    const CompoundUnit(id: 'euler', expression: '2.718281828459045'),
  );
  repo.register(const CompoundUnit(id: 'tau', expression: '6.283185307179586'));

  // Physical constants (dimensioned).
  repo.register(
    const CompoundUnit(
      id: 'c',
      aliases: ['speed_of_light'],
      expression: '299792458 m / s',
    ),
  );
  repo.register(
    const CompoundUnit(
      id: 'gravity',
      aliases: ['g0'],
      expression: '9.80665 m / s^2',
    ),
  );
  repo.register(
    const CompoundUnit(
      id: 'h',
      aliases: ['planck'],
      expression: '6.62607015e-34 kg m^2 / s',
    ),
  );
  repo.register(
    const CompoundUnit(
      id: 'N_A',
      aliases: ['avogadro'],
      expression: '6.02214076e23 / mol',
    ),
  );
  repo.register(
    const CompoundUnit(
      id: 'k_B',
      aliases: ['boltzmann'],
      expression: '1.380649e-23 kg m^2 / (s^2 K)',
    ),
  );
  repo.register(
    const CompoundUnit(
      id: 'e',
      aliases: ['elementary_charge'],
      expression: '1.602176634e-19 A s',
    ),
  );
  repo.register(
    const CompoundUnit(
      id: 'R',
      aliases: ['gas_constant'],
      expression: '8.314462618 kg m^2 / (s^2 K mol)',
    ),
  );
}

void _registerCompoundUnits(UnitRepository repo) {
  repo.register(
    const CompoundUnit(id: 'N', aliases: ['newton'], expression: 'kg m / s^2'),
  );
  repo.register(
    const CompoundUnit(id: 'Pa', aliases: ['pascal'], expression: 'N / m^2'),
  );
  repo.register(
    const CompoundUnit(id: 'J', aliases: ['joule'], expression: 'N m'),
  );
  repo.register(
    const CompoundUnit(id: 'W', aliases: ['watt'], expression: 'J / s'),
  );
  repo.register(
    const CompoundUnit(id: 'Hz', aliases: ['hertz'], expression: '/ s'),
  );
  repo.register(
    const CompoundUnit(id: 'C', aliases: ['coulomb'], expression: 'A s'),
  );
  repo.register(
    const CompoundUnit(id: 'V', aliases: ['volt'], expression: 'W / A'),
  );
  repo.register(
    const CompoundUnit(id: 'ohm', aliases: ['Ohm'], expression: 'V / A'),
  );
  repo.register(
    const CompoundUnit(id: 'F', aliases: ['farad'], expression: 'C / V'),
  );
  repo.register(
    const CompoundUnit(id: 'Wb', aliases: ['weber'], expression: 'V s'),
  );
  repo.register(
    const CompoundUnit(id: 'T', aliases: ['tesla'], expression: 'Wb / m^2'),
  );
  repo.register(
    const CompoundUnit(id: 'H', aliases: ['henry'], expression: 'Wb / A'),
  );
}
