import '../models/unit.dart';
import '../models/unit_definition.dart';
import '../models/unit_repository.dart';

/// Registers all built-in units into the given [repo].
///
/// Phase 2 includes length (10), mass (6), and time (6) units.
/// All non-primitive units use direct-to-primitive conversion factors
/// from NIST/SI reference values to minimize floating-point chain errors.
void registerBuiltinUnits(UnitRepository repo) {
  _registerLengthUnits(repo);
  _registerMassUnits(repo);
  _registerTimeUnits(repo);
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
      definition: LinearDefinition(factor: 0.0254, baseUnitId: 'm'),
    ),
  );
  repo.register(
    const Unit(
      id: 'ft',
      aliases: ['foot', 'feet'],
      definition: LinearDefinition(factor: 0.3048, baseUnitId: 'm'),
    ),
  );
  repo.register(
    const Unit(
      id: 'yd',
      aliases: ['yard'],
      definition: LinearDefinition(factor: 0.9144, baseUnitId: 'm'),
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
      definition: LinearDefinition(factor: 1e-6, baseUnitId: 'kg'),
    ),
  );
  repo.register(
    const Unit(
      id: 'lb',
      aliases: ['pound'],
      definition: LinearDefinition(factor: 0.45359237, baseUnitId: 'kg'),
    ),
  );
  repo.register(
    const Unit(
      id: 'oz',
      aliases: ['ounce'],
      definition: LinearDefinition(factor: 0.028349523125, baseUnitId: 'kg'),
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
      definition: LinearDefinition(factor: 3600, baseUnitId: 's'),
    ),
  );
  repo.register(
    const Unit(
      id: 'day',
      definition: LinearDefinition(factor: 86400, baseUnitId: 's'),
    ),
  );
  repo.register(
    const Unit(
      id: 'week',
      aliases: ['wk'],
      definition: LinearDefinition(factor: 604800, baseUnitId: 's'),
    ),
  );
}
