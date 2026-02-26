// GENERATED CODE - DO NOT EDIT BY HAND
// Run `dart run tool/generate_builtin_units.dart` to regenerate.

import '../models/unit.dart';
import '../models/unit_repository.dart';

/// Registers all built-in units into the given [repo].
void registerBuiltinUnits(UnitRepository repo) {
  _registerUnits(repo);
  _registerPrefixes(repo);
}

void _registerUnits(UnitRepository repo) {
  repo.register(
    const PrimitiveUnit(
      id: 's',
      aliases: ['second', 'sec', 'TIME'],
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nu_133Cs',
      aliases: ['ν_133Cs'],
      expression: '9192631770 Hz',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'c_SI',
      expression: '299792458',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'c',
      aliases: ['light'],
      expression: '299792458 m/s',
    ),
  );
  repo.register(
    const PrimitiveUnit(
      id: 'm',
      aliases: [
        'meter',
        'metre',
        'LENGTH',
        'WAVELENGTH',
        'DISPLACEMENT',
        'DISTANCE',
        'ELONGATION',
      ],
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'h_SI',
      expression: '6.62607015e-34',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'h',
      aliases: ['ℎ'],
      expression: '6.62607015e-34 J s',
    ),
  );
  repo.register(
    const PrimitiveUnit(
      id: 'kg',
      aliases: ['kilogram', 'MASS', 'key', '㎏'],
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'k_SI',
      expression: '1.380649e-23',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'boltzmann',
      aliases: ['k', 'kboltzmann'],
      expression: '1.380649e-23 J/K',
    ),
  );
  repo.register(
    const PrimitiveUnit(
      id: 'K',
      aliases: [
        'kelvin',
        'TEMPERATURE',
        'TEMPERATURE_DIFFERENCE',
        'degcelsius',
        'degC',
        'degK',
        'tempK',
        'thermalvolt',
        'K',
        '℃',
        '°C',
        '°K',
      ],
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'e_SI',
      expression: '1.602176634e-19',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'e',
      aliases: ['atomiccharge'],
      expression: '1.602176634e-19 C',
    ),
  );
  repo.register(
    const PrimitiveUnit(
      id: 'A',
      aliases: ['ampere', 'amp', 'CURRENT', 'galvat'],
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'avogadro',
      aliases: ['N_A'],
      expression: '6.02214076e23 / mol',
    ),
  );
  repo.register(
    const PrimitiveUnit(
      id: 'mol',
      aliases: ['mole', 'AMOUNT', '㏖'],
    ),
  );
  repo.register(
    const PrimitiveUnit(
      id: 'cd',
      aliases: ['candela', 'LUMINOUS_INTENSITY', '㏅'],
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'K_cd',
      expression: '683 lumen/W',
    ),
  );
  repo.register(
    const PrimitiveUnit(
      id: 'radian',
      aliases: ['ANGLE'],
      isDimensionless: true,
    ),
  );
  repo.register(
    const PrimitiveUnit(
      id: 'sr',
      aliases: ['steradian', 'SOLID_ANGLE', '㏛'],
      isDimensionless: true,
    ),
  );
  repo.register(
    const PrimitiveUnit(
      id: 'bit',
      aliases: ['INFORMATION'],
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'one',
      expression: '1',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'two',
      expression: '2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'double',
      expression: '2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'couple',
      expression: '2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'three',
      expression: '3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'triple',
      expression: '3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'four',
      expression: '4',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'quadruple',
      expression: '4',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'five',
      expression: '5',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'quintuple',
      expression: '5',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'six',
      expression: '6',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'seven',
      expression: '7',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'eight',
      expression: '8',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nine',
      expression: '9',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ten',
      expression: '10',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'eleven',
      expression: '11',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'twelve',
      expression: '12',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thirteen',
      expression: '13',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'fourteen',
      expression: '14',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'fifteen',
      expression: '15',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sixteen',
      expression: '16',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'seventeen',
      expression: '17',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'eighteen',
      expression: '18',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nineteen',
      expression: '19',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'twenty',
      expression: '20',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thirty',
      expression: '30',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'forty',
      expression: '40',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'fifty',
      expression: '50',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sixty',
      expression: '60',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'seventy',
      expression: '70',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'eighty',
      expression: '80',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ninety',
      expression: '90',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hundred',
      expression: '100',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thousand',
      expression: '1000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'million',
      expression: '1e6',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'twoscore',
      expression: 'two score',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'threescore',
      expression: 'three score',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'fourscore',
      expression: 'four score',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'fivescore',
      expression: 'five score',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sixscore',
      expression: 'six score',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sevenscore',
      expression: 'seven score',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'eightscore',
      expression: 'eight score',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ninescore',
      expression: 'nine score',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tenscore',
      expression: 'ten score',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'twelvescore',
      expression: 'twelve score',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'shortbillion',
      aliases: ['billion'],
      expression: '1e9',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'shorttrillion',
      aliases: ['trillion'],
      expression: '1e12',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'shortquadrillion',
      aliases: ['quadrillion'],
      expression: '1e15',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'shortquintillion',
      aliases: ['quintillion'],
      expression: '1e18',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'shortsextillion',
      aliases: ['sextillion'],
      expression: '1e21',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'shortseptillion',
      aliases: ['septillion'],
      expression: '1e24',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'shortoctillion',
      aliases: ['octillion'],
      expression: '1e27',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'shortnonillion',
      aliases: ['shortnoventillion', 'nonillion', 'noventillion'],
      expression: '1e30',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'shortdecillion',
      aliases: ['decillion'],
      expression: '1e33',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'shortundecillion',
      aliases: ['undecillion'],
      expression: '1e36',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'shortduodecillion',
      aliases: ['duodecillion'],
      expression: '1e39',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'shorttredecillion',
      aliases: ['tredecillion'],
      expression: '1e42',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'shortquattuordecillion',
      aliases: ['quattuordecillion'],
      expression: '1e45',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'shortquindecillion',
      aliases: ['quindecillion'],
      expression: '1e48',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'shortsexdecillion',
      aliases: ['sexdecillion'],
      expression: '1e51',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'shortseptendecillion',
      aliases: ['septendecillion'],
      expression: '1e54',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'shortoctodecillion',
      aliases: ['octodecillion'],
      expression: '1e57',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'shortnovemdecillion',
      aliases: ['novemdecillion'],
      expression: '1e60',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'shortvigintillion',
      aliases: ['vigintillion'],
      expression: '1e63',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'centillion',
      expression: '1e303',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'googol',
      expression: '1e100',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'longbillion',
      expression: 'million^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'longtrillion',
      expression: 'million^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'longquadrillion',
      expression: 'million^4',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'longquintillion',
      expression: 'million^5',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'longsextillion',
      expression: 'million^6',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'longseptillion',
      expression: 'million^7',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'longoctillion',
      expression: 'million^8',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'longnonillion',
      aliases: ['longnoventillion'],
      expression: 'million^9',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'longdecillion',
      expression: 'million^10',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'longundecillion',
      expression: 'million^11',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'longduodecillion',
      expression: 'million^12',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'longtredecillion',
      expression: 'million^13',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'longquattuordecillion',
      expression: 'million^14',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'longquindecillion',
      expression: 'million^15',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'longsexdecillion',
      expression: 'million^16',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'longseptdecillion',
      expression: 'million^17',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'longoctodecillion',
      expression: 'million^18',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'longnovemdecillion',
      expression: 'million^19',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'longvigintillion',
      expression: 'million^20',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'milliard',
      aliases: ['longmilliard'],
      expression: '1000 million',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'billiard',
      aliases: ['longbilliard'],
      expression: '1000 million^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'trilliard',
      aliases: ['longtrilliard'],
      expression: '1000 million^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'quadrilliard',
      aliases: ['longquadrilliard'],
      expression: '1000 million^4',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'quintilliard',
      aliases: ['longquintilliard'],
      expression: '1000 million^5',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sextilliard',
      aliases: ['longsextilliard'],
      expression: '1000 million^6',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'septilliard',
      aliases: ['longseptilliard'],
      expression: '1000 million^7',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'octilliard',
      aliases: ['longoctilliard'],
      expression: '1000 million^8',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nonilliard',
      aliases: ['noventilliard', 'longnonilliard', 'longnoventilliard'],
      expression: '1000 million^9',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'decilliard',
      aliases: ['longdecilliard'],
      expression: '1000 million^10',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lakh',
      expression: '1e5',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'crore',
      expression: '1e7',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'arab',
      expression: '1e9',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'kharab',
      expression: '1e11',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neel',
      expression: '1e13',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'padm',
      expression: '1e15',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'shankh',
      expression: '1e17',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'newton',
      aliases: ['N', 'FORCE', 'nt'],
      expression: 'kg m / s^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'pascal',
      aliases: ['Pa', 'tor', 'pa', '㎩'],
      expression: 'N/m^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'joule',
      aliases: ['J', 'ENERGY'],
      expression: 'N m',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'watt',
      aliases: ['W', 'POWER'],
      expression: 'J/s',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'coulomb',
      aliases: ['C', 'CHARGE', 'coul'],
      expression: 'A s',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'volt',
      aliases: ['V'],
      expression: 'W/A',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ohm',
      aliases: ['RESISTANCE', 'Ω', 'Ω'],
      expression: 'V/A',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'siemens',
      aliases: ['S', 'CONDUCTANCE', 'mho', '℧'],
      expression: 'A/V',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'farad',
      aliases: ['F', 'CAPACITANCE'],
      expression: 'C/V',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'weber',
      aliases: ['Wb', '㏝'],
      expression: 'V s',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'henry',
      aliases: ['H', 'INDUCTANCE'],
      expression: 'V s / A',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tesla',
      aliases: ['T', 'B_FIELD'],
      expression: 'Wb/m^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hertz',
      aliases: ['Hz', 'FREQUENCY', 'hz', '㎐'],
      expression: '/s',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'AREA',
      expression: 'LENGTH^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'VOLUME',
      expression: 'LENGTH^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'TORQUE',
      expression: 'FORCE DISTANCE',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'PRESSURE',
      expression: 'FORCE / AREA',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'STRESS',
      expression: 'FORCE / AREA',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'WAVENUMBER',
      expression: '1/WAVELENGTH',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'VELOCITY',
      expression: 'DISPLACEMENT / TIME',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'SPEED',
      expression: 'DISTANCE / TIME',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ACCELERATION',
      expression: 'VELOCITY / TIME',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'MOMENTUM',
      expression: 'MASS VELOCITY',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'IMPULSE',
      expression: 'FORCE TIME',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'STRAIN',
      expression: 'ELONGATION / LENGTH',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'WORK',
      expression: 'FORCE DISTANCE',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'DENSITY',
      expression: 'MASS / VOLUME',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'LINEAR_DENSITY',
      expression: 'MASS / LENGTH',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'SPECIFIC_ENERGY',
      expression: 'ENERGY / MASS',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'VISCOSITY',
      expression: 'FORCE TIME / AREA',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'KINEMATIC_VISCOSITY',
      expression: 'VISCOSITY / DENSITY',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'RESISTIVITY',
      expression: 'RESISTANCE AREA / LENGTH',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'CONDUCTIVITY',
      expression: 'CONDUCTANCE LENGTH / AREA',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'E_FIELD',
      expression: 'ELECTRIC_POTENTIAL / LENGTH',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ELECTRIC_PERMITTIVITY',
      expression: 'epsilon0 / epsilon0_SI',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'MAGNETIC_PERMEABILITY',
      expression: 'mu0 / mu0_SI',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'D_FIELD',
      expression: 'E_FIELD ELECTRIC_PERMITTIVITY',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'H_FIELD',
      expression: 'B_FIELD / MAGNETIC_PERMEABILITY',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ELECTRIC_DIPOLE_MOMENT',
      expression: 'CHARGE DISTANCE',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'MAGNETIC_DIPOLE_MOMENT',
      expression: 'TORQUE / B_FIELD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'POLARIZATION',
      expression: 'ELECTRIC_DIPOLE_MOMENT / VOLUME',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'MAGNETIZATION',
      expression: 'MAGNETIC_DIPOLE_MOMENT / VOLUME',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ELECTRIC_POTENTIAL',
      aliases: ['VOLTAGE'],
      expression: 'ENERGY / CHARGE',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'E_FLUX',
      expression: 'E_FIELD AREA',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'D_FLUX',
      expression: 'D_FIELD AREA',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'B_FLUX',
      expression: 'B_FIELD AREA',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'H_FLUX',
      expression: 'H_FIELD AREA',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gram',
      aliases: ['gm', 'g', 'gramme'],
      expression: 'millikg',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tonne',
      aliases: ['t', 'metricton'],
      expression: '1000 kg',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sthene',
      aliases: ['funal'],
      expression: 'tonne m / s^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'pieze',
      expression: 'sthene / m^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'quintal',
      expression: '100 kg',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bar',
      aliases: ['b', '㍴'],
      expression: '1e5 Pa',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'vac',
      expression: 'millibar',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'micron',
      expression: 'micrometer',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bicron',
      expression: 'picometer',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cc',
      aliases: ['㏄'],
      expression: 'cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'liter',
      aliases: ['L', 'l', 'litre', 'ℓ'],
      expression: '1000 cc',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'oldliter',
      expression: '1.000028 dm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'Ah',
      expression: 'amp hour',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'angstrom',
      aliases: ['ångström', 'Å', 'Å'],
      expression: '1e-10 m',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'xunit_cu',
      aliases: ['xunit', 'siegbahn'],
      expression: '1.00207697e-13 m',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'xunit_mo',
      expression: '1.00209952e-13 m',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'angstromstar',
      expression: '1.00001495 angstrom',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'silicon_d220',
      expression: '1.920155716e-10 m',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'siliconlattice',
      expression: 'sqrt(8) silicon_d220',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'fermi',
      expression: '1e-15 m',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'barn',
      expression: '1e-28 m^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'shed',
      expression: '1e-24 barn',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'brewster',
      expression: 'micron^2/N',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'diopter',
      aliases: ['dioptre'],
      expression: '/m',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'fresnel',
      expression: '1e12 Hz',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'shake',
      expression: '1e-8 sec',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'svedberg',
      expression: '1e-13 s',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gamma',
      expression: 'microgram',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lambda',
      expression: 'microliter',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'spat',
      expression: '1e12 m',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'preece',
      expression: '1e13 ohm m',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'planck',
      expression: 'J s',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sturgeon',
      expression: '/henry',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'daraf',
      expression: '1/farad',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'leo',
      expression: '10 m/s^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'poiseuille',
      expression: 'N s / m^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mayer',
      expression: 'J/g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mired',
      expression: '/ microK',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'crocodile',
      expression: 'megavolt',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'metricounce',
      aliases: ['mounce'],
      expression: '25 g',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'finsenunit',
      expression: '1e5 W/m^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'fluxunit',
      aliases: ['jansky', 'Jy'],
      expression: '1e-26 W/m^2 Hz',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'flick',
      expression: 'W / cm^2 sr micrometer',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'pfu',
      expression: '/ cm^2 sr s',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'pyron',
      expression: 'cal_IT / cm^2 min',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'katal',
      aliases: ['kat'],
      expression: 'mol/sec',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'solarluminosity',
      expression: '382.8e24 W',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'solarirradiance',
      aliases: ['solarconstant', 'TSI'],
      expression: 'solarluminosity / (4 pi sundist^2)',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'are',
      aliases: ['a', 'sotka'],
      expression: '100 m^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'minute',
      aliases: ['min'],
      expression: '60 s',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hour',
      aliases: ['hr'],
      expression: '60 min',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'day',
      aliases: ['d', 'da', 'solarday', '㍲'],
      expression: '24 hr',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'week',
      aliases: ['wk'],
      expression: '7 day',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sennight',
      expression: '7 day',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'fortnight',
      expression: '14 day',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'blink',
      expression: '1e-5 day',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ce',
      expression: '1e-2 day',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cron',
      expression: '1e6 years',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'watch',
      expression: '4 hours',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bell',
      expression: '1|8 watch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'decimalhour',
      expression: '1|10 day',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'decimalminute',
      aliases: ['beat'],
      expression: '1|100 decimalhour',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'decimalsecond',
      expression: '1|100 decimalminute',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'circle',
      aliases: ['turn', 'revolution', 'rev'],
      expression: '2 pi radian',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'degree',
      aliases: ['deg', 'arcdeg', '°'],
      expression: '1|360 circle',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'arcmin',
      aliases: ['arcminute', '\'', '′'],
      expression: '1|60 degree',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'arcsec',
      aliases: ['arcsecond', '"', '\'\'', '″'],
      expression: '1|60 arcmin',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rightangle',
      expression: '90 degrees',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'quadrant',
      expression: '1|4 circle',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'quintant',
      expression: '1|5 circle',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sextant',
      expression: '1|6 circle',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sign',
      expression: '1|12 circle',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'pulsatance',
      expression: 'radian / sec',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gon',
      aliases: ['grade'],
      expression: '1|100 rightangle',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'centesimalminute',
      expression: '1|100 grade',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'centesimalsecond',
      expression: '1|100 centesimalminute',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'milangle',
      expression: '1|6400 circle',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'pointangle',
      expression: '1|32 circle',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'centrad',
      expression: '0.01 radian',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mas',
      expression: 'milli arcsec',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'seclongitude',
      expression: 'circle (seconds/day)',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sphere',
      expression: '4 pi sr',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'squaredegree',
      expression: '1|180^2 pi^2 sr',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'squareminute',
      aliases: ['squarearcmin'],
      expression: '1|60^2 squaredegree',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'squaresecond',
      aliases: ['squarearcsec'],
      expression: '1|60^2 squareminute',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sphericalrightangle',
      expression: '1|8 sphere',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'octant',
      expression: '1|8 sphere',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'percent',
      aliases: ['%'],
      expression: '0.01',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mill',
      expression: '0.001',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'proof',
      expression: '1|200',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ppm',
      aliases: ['partspermillion', '㏙'],
      expression: '1e-6',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ppb',
      aliases: ['partsperbillion'],
      expression: '1e-9',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ppt',
      aliases: ['partspertrillion'],
      expression: '1e-12',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'karat',
      aliases: ['caratgold'],
      expression: '1|24',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gammil',
      expression: 'mg/l',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'basispoint',
      expression: '0.01 %',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'fine',
      expression: '1|1000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'degfahrenheit',
      expression: '5|9 degC',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'degF',
      aliases: [
        'degreesrankine',
        'degrankine',
        'degreerankine',
        'degR',
        'tempR',
        'temprankine',
        '℉',
        '°F',
        '°R',
      ],
      expression: '5|9 degC',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'degreaumur',
      expression: '10|8 degC',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'pi',
      aliases: ['π', '𝜋'],
      expression: '3.14159265358979323846',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tau',
      aliases: ['τ'],
      expression: '2 pi',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'phi',
      expression: '(sqrt(5)+1)/2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'coulombconst',
      aliases: ['k_C'],
      expression: 'alpha hbar c / e^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'k_C_SI',
      expression: 'alpha hbar_SI c_SI / e_SI^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'epsilon0_SI',
      expression: '1 / 4 pi k_C_SI',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'epsilon0',
      aliases: ['ε₀'],
      expression: '1 / 4 pi k_C',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mu0_SI',
      expression: '1 / epsilon0_SI c_SI^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mu0',
      aliases: ['μ₀'],
      expression: '1 / epsilon0 c^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'Z0',
      aliases: ['Z₀'],
      expression: '4 pi k_C / c',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'energy',
      expression: 'c^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hbar',
      aliases: ['spin', 'natural_action', 'atomicaction', 'ℏ'],
      expression: 'h / 2 pi',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hbar_SI',
      expression: 'h_SI / 2 pi',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'G_SI',
      expression: '6.67430e-11',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'G',
      expression: '6.67430e-11 N m^2 / kg^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'atomicmassunit_SI',
      expression: '1.66053906892e-27',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'atomicmassunit',
      aliases: ['u', 'amu', 'dalton', 'Da'],
      expression: '1.66053906892e-27 kg',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'amu_chem',
      expression: '1.66026e-27 kg',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'amu_phys',
      expression: '1.65981e-27 kg',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'molarmassconstant',
      expression: 'N_A u',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gasconstant',
      aliases: ['R'],
      expression: 'k N_A',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sackurtetrodeconstant',
      expression: '5|2 + ln((u k K / 2 pi hbar^2)^(3|2) k K / atm)',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'molarvolume',
      aliases: ['V_m'],
      expression: 'R stdtemp / atm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'loschmidt',
      aliases: ['n0', 'n₀'],
      expression: 'avogadro / molarvolume',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'molarvolume_si',
      expression: 'N_A siliconlattice^3 / 8',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'stefanboltzmann',
      aliases: ['sigma', 'σ'],
      expression: 'pi^2 k^4 / 60 hbar^3 c^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wiendisplacement',
      expression: '(h c/k)/4.9651142317442763',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wienfrequencydisplacement',
      expression: '2.8214393721220788934 k/h',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'K_J90',
      expression: '483597.9 GHz/V',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'K_J',
      expression: '2e/h',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'R_K90',
      expression: '25812.807 ohm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'R_K',
      expression: 'h/e^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ampere90',
      expression: '(K_J90 R_K90 / K_J R_K) A',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'coulomb90',
      expression: '(K_J90 R_K90 / K_J R_K) C',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'farad90',
      expression: '(R_K90/R_K) F',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'henry90',
      expression: '(R_K/R_K90) H',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ohm90',
      expression: '(R_K/R_K90) ohm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'volt90',
      expression: '(K_J90/K_J) V',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'watt90',
      expression: '(K_J90^2 R_K90 / K_J^2 R_K) W',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gravity',
      aliases: ['force'],
      expression: '9.80665 m/s^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'atm',
      aliases: ['atmosphere', 'stdatmP0', 'Patm'],
      expression: '101325 Pa',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'Hg',
      aliases: ['hg'],
      expression: '13.5951 gram force / cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'water',
      aliases: ['H2O', 'wc'],
      expression: 'gram force/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'waterdensity',
      expression: 'gram / cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mach',
      expression: '331.46 m/s',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'standardtemp',
      aliases: ['stdtemp'],
      expression: '273.15 K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'normaltemp',
      aliases: ['normtemp'],
      expression: 'tempF(70)',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'Hg10C',
      expression: '13.5708 force gram / cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'Hg20C',
      expression: '13.5462 force gram / cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'Hg23C',
      expression: '13.5386 force gram / cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'Hg30C',
      expression: '13.5217 force gram / cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'Hg40C',
      expression: '13.4973 force gram / cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'Hg60F',
      expression: '13.5574 force gram / cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'H2O0C',
      expression: '0.99987 force gram / cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'H2O5C',
      expression: '0.99999 force gram / cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'H2O10C',
      expression: '0.99973 force gram / cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'H2O15C',
      expression: '0.99913 force gram / cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'H2O18C',
      expression: '0.99862 force gram / cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'H2O20C',
      expression: '0.99823 force gram / cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'H2O25C',
      expression: '0.99707 force gram / cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'H2O50C',
      expression: '0.98807 force gram / cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'H2O100C',
      expression: '0.95838 force gram / cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hartree',
      aliases: ['E_h', 'atomicenergy'],
      expression: '4.3597447222060e-18 J',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'Rinfinity',
      aliases: ['R∞', 'R_∞'],
      expression: 'hartree / 2 h c',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'R_H',
      expression: 'Rinfinity m_p / (m_e + m_p)',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'alpha',
      aliases: ['α'],
      expression: '7.2973525643e-3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bohrradius',
      aliases: ['a0', 'a₀'],
      expression: 'hbar / alpha m_e c',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'prout',
      expression: '185.5 keV',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'conductancequantum',
      aliases: ['G0', 'G₀'],
      expression: 'e^2 / pi hbar',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'magneticfluxquantum',
      aliases: ['Phi0', 'Φ₀'],
      expression: 'pi hbar / e',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'circulationquantum',
      expression: 'h / 2 m_e',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'weakmixingangle',
      expression: '0.22305',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'w_to_z_mass_ratio',
      expression: '0.88145',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'electronradius',
      expression: 'alpha^2 bohrradius',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thomsoncrosssection',
      expression: '8|3 pi electronradius^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'alphachargeradius',
      expression: '1.6785e-15 m',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'deuteronchargeradius',
      expression: '2.12778e-15 m',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'protonchargeradius',
      expression: '8.4075e-16 m',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'electronmass_SI',
      expression: 'electronmass_u atomicmassunit_SI',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'electronmass_u',
      expression: '5.485799090441e-4',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'electronmass',
      aliases: ['m_e', 'atomicmass'],
      expression: '5.485799090441e-4 u',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'muonmass',
      aliases: ['m_mu'],
      expression: '0.1134289257 u',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'taumass',
      aliases: ['m_tau'],
      expression: '1.90754 u',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'protonmass',
      aliases: ['m_p'],
      expression: '1.0072764665789 u',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neutronmass',
      aliases: ['m_n'],
      expression: '1.00866491606 u',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'deuteronmass',
      aliases: ['m_d'],
      expression: '2.013553212544 u',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'alphaparticlemass',
      aliases: ['m_alpha'],
      expression: '4.001506179129 u',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tritonmass',
      aliases: ['m_t'],
      expression: '3.01550071597 u',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'helionmass',
      aliases: ['m_h'],
      expression: '3.014932246932 u',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'electronwavelength',
      aliases: ['lambda_C', 'λ_C'],
      expression: 'h / m_e c',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'protonwavelength',
      aliases: ['lambda_C_p'],
      expression: 'h / m_p c',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neutronwavelength',
      aliases: ['lambda_C_n'],
      expression: 'h / m_n c',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'muonwavelength',
      aliases: ['lambda_C_mu'],
      expression: 'h / m_mu c',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tauwavelength',
      aliases: ['lambda_C_tau'],
      expression: 'h / m_tau c',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'g_d',
      expression: '0.8574382335',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'g_e',
      expression: '-2.00231930436092',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'g_h',
      expression: '-4.2552506995',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'g_mu',
      expression: '-2.00233184123',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'g_n',
      expression: '-3.82608552',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'g_p',
      expression: '5.5856946893',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'g_t',
      expression: '5.957924930',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'fermicoupling',
      expression: '1.1663787e-5 / GeV^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bohrmagneton',
      aliases: ['mu_B', 'μ_B'],
      expression: 'e hbar / 2 electronmass',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mu_e',
      expression: 'g_e mu_B / 2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mu_mu',
      expression: 'g_mu mu_B m_e / 2 muonmass',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nuclearmagneton',
      aliases: ['mu_N'],
      expression: 'mu_B m_e / protonmass',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mu_p',
      expression: 'g_p mu_N / 2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mu_n',
      expression: 'g_n mu_N / 2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mu_d',
      expression: 'g_d mu_N',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mu_t',
      expression: 'g_t mu_N / 2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mu_h',
      expression: 'g_h mu_N / 2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'shielded_mu_h',
      expression: '-1.07455311035e-26 J / T',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'shielded_mu_p',
      expression: '1.4105705830e-26 J / T',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'kgf',
      expression: 'kg force',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'technicalatmosphere',
      aliases: ['at'],
      expression: 'kgf / cm^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hyl',
      expression: 'kgf s^2 / m',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mmHg',
      expression: 'mm Hg',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'torr',
      expression: 'atm / 760',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'inHg',
      expression: 'inch Hg',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'inH2O',
      expression: 'inch water',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mmH2O',
      expression: 'mm water',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'eV',
      aliases: ['electronvolt', 'natural_energy', 'ev'],
      expression: 'e V',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lightyear',
      aliases: ['ly'],
      expression: 'c julianyear',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lightsecond',
      expression: 'c s',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lightminute',
      expression: 'c min',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'parsec',
      aliases: ['pc', '㍶'],
      expression: 'au / tan(arcsec)',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rydberg',
      expression: '1|2 hartree',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'crith',
      expression: '0.089885 gram',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'amagat',
      expression: 'N_A / molarvolume',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'amagatvolume',
      expression: 'mol molarvolume',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lorentz',
      expression: 'bohrmagneton / h c',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cminv',
      aliases: ['invcm'],
      expression: 'h c / cm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wavenumber',
      expression: '1/cm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'kcal_mol',
      expression: 'kcal_th / mol N_A',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'dyne',
      aliases: ['dyn'],
      expression: 'cm gram / s^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'erg',
      expression: 'cm dyne',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'poise',
      aliases: ['P'],
      expression: 'gram / cm s',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhe',
      expression: '/poise',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'stokes',
      aliases: ['St', 'stoke', 'lentor'],
      expression: 'cm^2 / s',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'Gal',
      aliases: ['galileo'],
      expression: 'cm / s^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'barye',
      aliases: ['barad'],
      expression: 'dyne/cm^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'kayser',
      aliases: ['balmer'],
      expression: '1/cm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'kine',
      expression: 'cm/s',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bole',
      expression: 'g cm / s',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'pond',
      expression: 'gram force',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'glug',
      expression: 'gram force s^2 / cm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'darcy',
      expression: 'centipoise cm^2 / s atm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mobileohm',
      expression: 'cm / dyn s',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mechanicalohm',
      expression: 'dyn s / cm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'acousticalohm',
      aliases: ['ray'],
      expression: 'dyn s / cm^5',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rayl',
      expression: 'dyn s / cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'eotvos',
      expression: '1e-9 Gal/cm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'statcoulomb',
      aliases: ['esu', 'statcoul', 'statC', 'stC', 'franklin', 'Fr'],
      expression: 'sqrt(dyne cm^2/k_C)',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'statampere',
      aliases: ['statamp', 'statA', 'stA'],
      expression: 'statcoulomb / s',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'statvolt',
      aliases: ['statV', 'stV'],
      expression: 'dyne cm / statamp sec',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'statfarad',
      aliases: ['statF', 'stF', 'cmcapacitance'],
      expression: 'statamp sec / statvolt',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'stathenry',
      aliases: ['statH', 'stH'],
      expression: 'statvolt sec / statamp',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'statohm',
      aliases: ['stohm'],
      expression: 'statvolt / statamp',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'statmho',
      aliases: ['stmho'],
      expression: '/statohm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'statweber',
      aliases: ['statWb', 'stWb'],
      expression: 'statvolt sec',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'stattesla',
      aliases: ['statT', 'stT'],
      expression: 'statWb/cm^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'debye',
      expression: '1e-10 statC angstrom',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'helmholtz',
      expression: 'debye/angstrom^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'jar',
      expression: '1000 statfarad',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'abampere',
      aliases: ['abamp', 'aA', 'abA', 'biot', 'Bi'],
      expression: '10 A',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'abcoulomb',
      aliases: ['abcoul', 'abC'],
      expression: 'abamp sec',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'abfarad',
      aliases: ['abF'],
      expression: 'abampere sec / abvolt',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'abhenry',
      aliases: ['abH'],
      expression: 'abvolt sec / abamp',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'abvolt',
      aliases: ['abV'],
      expression: 'dyne cm / abamp sec',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'abohm',
      expression: 'abvolt / abamp',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'abmho',
      expression: '/abohm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'maxwell',
      aliases: ['Mx'],
      expression: 'erg / abamp',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gauss',
      aliases: ['Gs'],
      expression: 'maxwell / cm^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'oersted',
      aliases: ['Oe', 'oe'],
      expression: 'gauss / mu0',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gilbert',
      aliases: ['Gb', 'Gi'],
      expression: 'gauss cm / mu0',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'unitpole',
      expression: '4 pi maxwell',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'emu',
      expression: 'erg/gauss',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hlu_charge',
      expression: 'statcoulomb / sqrt(4 pi)',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hlu_current',
      expression: 'hlu_charge / sec',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hlu_volt',
      expression: 'erg / hlu_charge',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hlu_efield',
      expression: 'hlu_volt / cm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hlu_bfield',
      expression: 'sqrt(4 pi) gauss',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'natural_charge',
      expression: 'e / sqrt(4 pi alpha)',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'natural_time',
      expression: 'natural_action / natural_energy',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'natural_length',
      expression: 'natural_time c',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'natural_mass',
      expression: 'natural_energy / c^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'natural_momentum',
      expression: 'natural_energy / c',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'natural_temp',
      expression: 'natural_energy / boltzmann',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'natural_force',
      expression: 'natural_energy / natural_length',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'natural_power',
      expression: 'natural_energy / natural_time',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'natural_volt',
      expression: 'natural_energy / natural_charge',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'natural_Efield',
      expression: 'natural_volt / natural_length',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'natural_Bfield',
      expression: 'natural_Efield / c',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'natural_current',
      expression: 'natural_charge / natural_time',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'planckmass',
      aliases: ['m_P'],
      expression: 'sqrt(hbar c / G)',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'planckenergy',
      aliases: ['E_P'],
      expression: 'planckmass c^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'plancktime',
      aliases: ['t_P'],
      expression: 'hbar / planckenergy',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'plancklength',
      aliases: ['l_P'],
      expression: 'plancktime c',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'plancktemperature',
      aliases: ['T_P'],
      expression: 'planckenergy / k',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'planckforce',
      expression: 'planckenergy / plancklength',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'planckcharge',
      expression: 'sqrt(epsilon0 hbar c)',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'planckcurrent',
      expression: 'planckcharge / plancktime',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'planckvolt',
      expression: 'planckenergy / planckcharge',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'planckEfield',
      expression: 'planckvolt / plancklength',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'planckBfield',
      expression: 'planckEfield / c',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'planckmass_red',
      expression: 'sqrt(hbar c / 8 pi G)',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'planckenergy_red',
      expression: 'planckmass_red c^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'plancktime_red',
      expression: 'hbar / planckenergy_red',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'plancklength_red',
      expression: 'plancktime_red c',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'plancktemperature_red',
      expression: 'planckenergy_red / k',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'planckforce_red',
      expression: 'planckenergy_red / plancklength_red',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'planckcharge_red',
      expression: 'sqrt(epsilon0 hbar c)',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'planckcurrent_red',
      expression: 'planckcharge_red / plancktime_red',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'planckvolt_red',
      expression: 'planckenergy_red / planckcharge_red',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'planckEfield_red',
      expression: 'planckvolt_red / plancklength_red',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'planckBfield_red',
      expression: 'planckEfield_red /c',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'intampere',
      aliases: ['intamp'],
      expression: '0.999835 A',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'intfarad',
      expression: '0.999505 F',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'intvolt',
      expression: '1.00033 V',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'intohm',
      expression: '1.000495 ohm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'daniell',
      expression: '1.042 V',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'faraday',
      expression: 'N_A e mol',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'faraday_phys',
      expression: '96521.9 C',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'faraday_chem',
      expression: '96495.7 C',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'faradayconst',
      expression: 'N_A e',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'kappline',
      expression: '6000 maxwell',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'siemensunit',
      expression: '0.9534 ohm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'copperconductivity',
      aliases: ['IACS'],
      expression: '58 siemens m / mm^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'copperdensity',
      expression: '8.89 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ouncecopper',
      aliases: ['ozcu'],
      expression: 'oz / ft^2 copperdensity',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'candle',
      expression: '1.02 candela',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hefnerunit',
      aliases: ['hefnercandle'],
      expression: '0.9 candle',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'violle',
      expression: '20.17 cd',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lumen',
      aliases: ['LUMINOUS_FLUX', 'lm', '㏐'],
      expression: 'cd sr',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'talbot',
      aliases: ['LUMINOUS_ENERGY', 'lumberg', 'lumerg'],
      expression: 'lumen s',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lux',
      aliases: ['ILLUMINANCE', 'EXITANCE', 'lx', '㏓'],
      expression: 'lm/m^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'phot',
      aliases: ['ph'],
      expression: 'lumen / cm^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'footcandle',
      expression: 'lumen/ft^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'metercandle',
      expression: 'lumen/m^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mcs',
      expression: 'metercandle s',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nox',
      expression: '1e-3 lux',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'skot',
      expression: '1e-3 apostilb',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'LUMINANCE',
      expression: 'cd/m^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nit',
      expression: 'cd/m^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'stilb',
      aliases: ['sb'],
      expression: 'cd / cm^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'apostilb',
      aliases: ['asb', 'blondel'],
      expression: 'cd/pi m^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'equivalentlux',
      expression: 'cd / pi m^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'equivalentphot',
      expression: 'cd / pi cm^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lambert',
      expression: 'cd / pi cm^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'footlambert',
      aliases: ['fL'],
      expression: 'cd / pi ft^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sunlum',
      expression: '1.6e9 cd/m^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sunillum',
      expression: '100e3 lux',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sunillum_o',
      expression: '10e3 lux',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sunlum_h',
      expression: '6e6 cd/m^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'skylum',
      expression: '8000 cd/m^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'skylum_o',
      expression: '2000 cd/m^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'moonlum',
      expression: '2500 cd/m^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 's100',
      aliases: ['iso100'],
      expression: '100 / lx s',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'k1250',
      expression: '12.5 (cd/m2) / lx s',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'k1400',
      expression: '14 (cd/m2) / lx s',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'c250',
      expression: '250 lx / lx s',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'N_exif',
      aliases: ['N_speed'],
      expression: '1|3.125 lx s',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'K_apex1961',
      expression: '11.4 (cd/m2) / lx s',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'K_apex1971',
      aliases: ['K_lum'],
      expression: '12.5 (cd/m2) / lx s',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'C_apex1961',
      aliases: ['C_illum'],
      expression: '224 lx / lx s',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'C_apex1971',
      expression: '322 lx / lx s',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'anomalisticyear',
      expression: '365.2596 days',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'siderealyear',
      aliases: ['earthyear'],
      expression: '365.256360417 day',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tropicalyear',
      aliases: ['year', 'yr', 'solaryear'],
      expression: '365.242198781 day',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'eclipseyear',
      expression: '346.62 days',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'saros',
      expression: '223 synodicmonth',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'siderealday',
      aliases: ['earthday', 'earthday_sidereal'],
      expression: '86164.09054 s',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'siderealhour',
      expression: '1|24 siderealday',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'siderealminute',
      expression: '1|60 siderealhour',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'siderealsecond',
      expression: '1|60 siderealminute',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'anomalisticmonth',
      expression: '27.55454977 day',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nodicalmonth',
      aliases: ['draconicmonth', 'draconiticmonth'],
      expression: '27.2122199 day',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'siderealmonth',
      expression: '27.321661 day',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lunarmonth',
      aliases: ['synodicmonth', 'lunation'],
      expression: '29 days + 12 hours + 44 minutes + 2.8 seconds',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lune',
      expression: '1|30 lunation',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lunour',
      expression: '1|24 lune',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'month',
      aliases: ['mo'],
      expression: '1|12 year',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lustrum',
      expression: '5 years',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'decade',
      expression: '10 years',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'century',
      expression: '100 years',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'millennium',
      aliases: ['millennia'],
      expression: '1000 years',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lunaryear',
      expression: '12 lunarmonth',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'calendaryear',
      expression: '365 day',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'commonyear',
      expression: '365 day',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'leapyear',
      expression: '366 day',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'julianyear',
      expression: '365.25 days',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gregorianyear',
      expression: '365.2425 days',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'islamicyear',
      expression: '354 day',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'islamicleapyear',
      expression: '355 day',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'islamicmonth',
      expression: '1|12 islamicyear',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mercuryday_sidereal',
      aliases: ['mercuryday'],
      expression: '1407.6 hr',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'venusday_sidereal',
      aliases: ['venusday'],
      expression: '5832.6 hr',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'marsday_sidereal',
      aliases: ['marsday'],
      expression: '24.6229 hr',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'jupiterday_sidereal',
      aliases: ['jupiterday'],
      expression: '9.9250 hr',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'saturnday_sidereal',
      aliases: ['saturnday'],
      expression: '10.656 hr',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'uranusday_sidereal',
      aliases: ['uranusday'],
      expression: '17.24 hr',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neptuneday_sidereal',
      aliases: ['neptuneday'],
      expression: '16.11 hr',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'plutoday_sidereal',
      aliases: ['plutoday'],
      expression: '153.2928 hr',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mercuryday_solar',
      expression: '4222.6 hr',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'venusday_solar',
      expression: '2802.0 hr',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'earthday_solar',
      expression: '24 hr',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'marsday_solar',
      expression: '24.6597 hr',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'jupiterday_solar',
      expression: '9.9259 hr',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'saturnday_solar',
      expression: '10.656 hr',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'uranusday_solar',
      expression: '17.24 hr',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neptuneday_solar',
      expression: '16.11 hr',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'plutoday_solar',
      expression: '153.2820 hr',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mercuryyear',
      expression: '87.969 day',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'venusyear',
      expression: '224.701 day',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'marsyear',
      expression: '686.980 day',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'jupiteryear',
      expression: '4332.589 day',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'saturnyear',
      expression: '10759.22 day',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'uranusyear',
      expression: '30685.4 day',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neptuneyear',
      expression: '60189 day',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'plutoyear',
      expression: '90560 day',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mercuryradius',
      expression: '2440.5 km',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'venusradius',
      expression: '6051.8 km',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'earthradius',
      expression: '6378.137 km',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'marsradius',
      expression: '3396.2 km',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'jupiterradius',
      expression: '71492 km',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'saturnradius',
      expression: '60268 km',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'uranusradius',
      expression: '25559 km',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neptuneradius',
      expression: '24764 km',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'plutoradius',
      expression: '1188 km',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mercuryradius_mean',
      expression: '2440.5 km',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'venusradius_mean',
      expression: '6051.8 km',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'earthradius_mean',
      expression: '6371 km',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'marsradius_mean',
      expression: '3389.5 km',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'jupiterradius_mean',
      expression: '69911 km',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'saturnradius_mean',
      expression: '58232 km',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'uranusradius_mean',
      expression: '25362 km',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neptuneradius_mean',
      expression: '24622 km',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'plutoradius_mean',
      expression: '1188 km',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mercuryradius_polar',
      expression: '2438.3 km',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'venusradius_polar',
      expression: '6051.8 km',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'marsradius_polar',
      expression: '3376.2 km',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'jupiterradius_polar',
      expression: '66854 km',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'saturnradius_polar',
      expression: '54364 km',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'uranusradius_polar',
      expression: '24973 km',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neptuneradius_polar',
      expression: '24341 km',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'plutoradius_polar',
      expression: '1188 km',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mercurysundist_min',
      expression: '46.000 Gm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mercurysundist_max',
      expression: '69.818 Gm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'venussundist_min',
      expression: '107.480 Gm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'venussundist_max',
      expression: '108.941 Gm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'marssundist_min',
      expression: '206.650 Gm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'marssundist_max',
      expression: '249.261 Gm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'jupitersundist_min',
      expression: '740.595 Gm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'jupitersundist_max',
      expression: '816.363 Gm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'saturnsundist_min',
      expression: '1357.554 Gm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'saturnsundist_max',
      expression: '1506.527 Gm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'uranussundist_min',
      expression: '2732.696 Gm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'uranussundist_max',
      expression: '3001.390 Gm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neptunesundist_min',
      expression: '4471.050 Gm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neptunesundist_max',
      expression: '4558.857 Gm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'plutosundist_min',
      expression: '4434.987 Gm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'plutosundist_max',
      expression: '7304.326 Gm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sundist',
      expression: '1.0000010178 au',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'moondist',
      expression: '384400 km',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sundist_near',
      aliases: ['earthsundist_min', 'sundist_min'],
      expression: '147.095 Gm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sundist_far',
      aliases: ['earthsundist_max', 'sundist_max'],
      expression: '152.100 Gm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'moondist_min',
      expression: '356371 km',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'moondist_max',
      expression: '406720 km',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'earthradius_polar',
      expression: '(1-earthflattening) earthradius_equatorial',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'WGS84_earthflattening',
      expression: '1|298.257223563',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'WGS84_earthradius_equatorial',
      expression: '6378137 m',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'WGS84_earthradius_polar',
      expression: '(1-WGS84_earthflattening) WGS84_earthradius_equatorial',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'IERS_earthflattening',
      aliases: ['earthflattening'],
      expression: '1|298.25642',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'IERS_earthradius_equatorial',
      aliases: ['earthradius_equatorial'],
      expression: '6378136.6 m',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'IERS_earthradius_polar',
      expression: '(1-IERS_earthflattening) IERS_earthradius_equatorial',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'landarea',
      expression: '148.847e6 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'oceanarea',
      expression: '361.254e6 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'moonradius',
      expression: '1738 km',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sunradius',
      expression: '6.96e8 m',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gauss_k',
      expression: '0.01720209895',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gaussianyear',
      expression: '(2 pi / gauss_k) days',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'astronomicalunit',
      aliases: ['au', '㍳'],
      expression: '149597870700 m',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'GMsun',
      expression: '132712440041.279419 km^3 / s^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'solarmass',
      aliases: ['sunmass'],
      expression: 'GMsun/G',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mercurymass',
      expression: '22031.868551 km^3 / s^2 G',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'venusmass',
      expression: '324858.592000 km^3 / s^2 G',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'marsmass',
      expression: '42828.375816 km^3 / s^2 G',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'jupitermass',
      expression: '126712764.100000 km^3 / s^2 G',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'saturnmass',
      expression: '37940584.841800 km^3 / s^2 G',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'uranusmass',
      expression: '5794556.400000 km^3 / s^2 G',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neptunemass',
      expression: '6836527.100580 km^3 / s^2 G',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'plutomass',
      expression: '975.500000 km^3 / s^2 G',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ceresmass',
      expression: '62.62890 km^3 / s^2 G',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'vestamass',
      expression: '17.288245 km^3 / s^2 G',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'earthmass',
      expression: '398600.435507 km^3 / s^2 G',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'moonmass',
      expression: '4902.800118 km^3 / s^2 G',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'moonearthmassratio',
      expression: 'moonmass/earthmass',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'earthmoonmass',
      expression: 'earthmass+moonmass',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'moongravity',
      expression: '1.62 m/s^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gravity_equatorial',
      expression: '9.7803263359 m / s^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gravity_polar',
      expression: '9.8321849378 m / s^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hubble',
      aliases: ['H0', 'H₀'],
      expression: '70 km/s/Mpc',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lunarparallax',
      aliases: ['moonhp'],
      expression: 'asin(earthradius_equatorial / moondist)',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'extinction_coeff',
      expression: '0.21',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'moonvmag',
      expression: '-12.74',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sunvmag',
      expression: '-26.74',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'moonsd',
      expression: 'asin(moonradius / moondist)',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sunsd',
      expression: 'asin(sunradius / sundist)',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'S10',
      expression: 'SB_degree(10)',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'atomicvelocity',
      expression: 'sqrt(atomicenergy / atomicmass)',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'atomictime',
      expression: 'atomicaction / atomicenergy',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'atomiclength',
      expression: 'atomicvelocity atomictime',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'atomicforce',
      expression: 'atomicenergy / atomiclength',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'atomicmomentum',
      expression: 'atomicenergy / atomicvelocity',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'atomiccurrent',
      expression: 'atomiccharge / atomictime',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'atomicdipolemoment',
      expression: 'atomiccharge atomiclength',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'atomicpotential',
      aliases: ['atomicvolt'],
      expression: 'atomicenergy / atomiccharge',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'atomicEfield',
      expression: 'atomicpotential / atomiclength',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'atomicBfield',
      expression: 'atomicEfield / atomicvelocity',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'atomictemperature',
      expression: 'atomicenergy / boltzmann',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thermalcoulomb',
      expression: 'J/K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thermalampere',
      expression: 'W/K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thermalfarad',
      expression: 'J/K^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thermalohm',
      aliases: ['fourier'],
      expression: 'K^2/W',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thermalhenry',
      expression: 'J K^2/W^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'inch',
      aliases: ['in', '㏌'],
      expression: '2.54 cm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'foot',
      aliases: ['feet', 'ft'],
      expression: '12 inch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'yard',
      aliases: ['yd', 'internationalyard'],
      expression: '3 ft',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mile',
      aliases: ['statutemile', 'mi', 'smi'],
      expression: '5280 ft',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'line',
      expression: '1|12 inch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rod',
      aliases: ['pole', 'perch', 'rd'],
      expression: '16.5 ft',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'furlong',
      expression: '40 rod',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'league',
      expression: '3 mile',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'US',
      expression: '1200|3937 m/ft',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'int',
      expression: '3937|1200 ft/m',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'surveyorschain',
      aliases: ['surveychain', 'gunterschain'],
      expression: '66 surveyft',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'surveyorspole',
      expression: '1|4 surveyorschain',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'surveyorslink',
      expression: '1|100 surveyorschain',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'USacre',
      expression: '10 surveychain^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'USacrefoot',
      expression: 'USacre surveyfoot',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'chain',
      aliases: ['ch'],
      expression: '66 ft',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'link',
      expression: '1|100 chain',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'intacre',
      aliases: ['acre', 'ac'],
      expression: '10 chain^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'intacrefoot',
      aliases: ['acrefoot'],
      expression: 'acre foot',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'section',
      expression: 'mile^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'township',
      expression: '36 section',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'homestead',
      expression: '160 acre',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'engineerschain',
      aliases: ['ramsdenschain'],
      expression: '100 ft',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'engineerslink',
      aliases: ['ramsdenslink'],
      expression: '1|100 engineerschain',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gurleychain',
      expression: '33 feet',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gurleylink',
      expression: '1|50 gurleychain',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wingchain',
      expression: '66 feet',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'winglink',
      expression: '1|80 wingchain',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'troughtonyard',
      expression: '914.42190 mm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bronzeyard11',
      expression: '914.39980 mm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mendenhallyard',
      expression: 'surveyyard',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'fathom',
      expression: '6 ft',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nauticalmile',
      aliases: ['nmi', 'nmile'],
      expression: '1852 m',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'intcable',
      expression: '1|10 nauticalmile',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'uscable',
      aliases: ['cableslength', 'cablelength', 'navycablelength', 'cable'],
      expression: '120 fathom',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'surveycable',
      aliases: ['UScable'],
      expression: '120 USfathom',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'brcable',
      aliases: ['admiraltycable'],
      expression: '1|10 brnauticalmile',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'marineleague',
      expression: '3 nauticalmile',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'knot',
      expression: 'nauticalmile / hr',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'click',
      aliases: ['klick'],
      expression: 'km',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'pound',
      aliases: ['lb', 'lbm', '℔'],
      expression: '0.45359237 kg',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'grain',
      aliases: ['gr'],
      expression: '1|7000 pound',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ounce',
      aliases: ['oz', '℥'],
      expression: '1|16 pound',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'dram',
      aliases: ['dr', 'ʒ'],
      expression: '1|16 ounce',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ushundredweight',
      aliases: ['cwt', 'shorthundredweight', 'hundredweight'],
      expression: '100 pounds',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'shortton',
      aliases: ['uston', 'ton'],
      expression: '2000 lb',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'quarterweight',
      aliases: ['quarter'],
      expression: '1|4 uston',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'shortquarterweight',
      aliases: ['shortquarter'],
      expression: '1|4 shortton',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'troypound',
      aliases: ['appound'],
      expression: '5760 grain',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'troyounce',
      aliases: ['ozt', 'fineounce', 'apounce'],
      expression: '1|12 troypound',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'pennyweight',
      aliases: ['dwt'],
      expression: '1|20 troyounce',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'assayton',
      expression: 'mg ton / troyounce',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'usassayton',
      expression: 'mg uston / troyounce',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'brassayton',
      expression: 'mg brton / troyounce',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'metriccarat',
      aliases: ['carat', 'ct'],
      expression: '0.2 gram',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'metricgrain',
      expression: '50 mg',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'jewelerspoint',
      expression: '1|100 carat',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'silversmithpoint',
      expression: '1|4000 inch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'momme',
      aliases: ['monme', 'taiqian', '台錢'],
      expression: '3.75 grams',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'apdram',
      expression: '1|8 apounce',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'apscruple',
      aliases: ['scruple', '℈'],
      expression: '1|3 apdram',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'usgallon',
      aliases: ['gal', 'gallon'],
      expression: '231 in^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'quart',
      aliases: ['qt'],
      expression: '1|4 gallon',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'pint',
      aliases: ['pt'],
      expression: '1|2 quart',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gill',
      expression: '1|4 pint',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'usquart',
      expression: '1|4 usgallon',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'uspint',
      expression: '1|2 usquart',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'usgill',
      expression: '1|4 uspint',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'usfluidounce',
      aliases: ['floz', 'usfloz', 'fluidounce'],
      expression: '1|16 uspint',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'fluiddram',
      aliases: ['fldr'],
      expression: '1|8 usfloz',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'minimvolume',
      aliases: ['minim'],
      expression: '1|60 fluiddram',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'liquidbarrel',
      expression: '31.5 usgallon',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'usbeerbarrel',
      expression: '2 beerkegs',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'beerkeg',
      expression: '15.5 usgallon',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ponykeg',
      expression: '1|2 beerkeg',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'winekeg',
      expression: '12 usgallon',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'petroleumbarrel',
      aliases: ['barrel', 'bbl'],
      expression: '42 usgallon',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ushogshead',
      aliases: ['hd', 'hogshead'],
      expression: '2 liquidbarrel',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'usfirkin',
      aliases: ['firkin'],
      expression: '9 usgallon',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'usbushel',
      aliases: ['bu', 'bushel'],
      expression: '2150.42 in^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'peck',
      aliases: ['pk'],
      expression: '1|4 bushel',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'uspeck',
      expression: '1|4 usbushel',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'brpeck',
      expression: '1|4 brbushel',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'drygallon',
      expression: '1|2 uspeck',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'dryquart',
      expression: '1|4 drygallon',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'drypint',
      expression: '1|2 dryquart',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'drybarrel',
      expression: '7056 in^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cranberrybarrel',
      expression: '5826 in^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'heapedbushel',
      expression: '1.278 usbushel',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wheatbushel',
      expression: '60 lb',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'soybeanbushel',
      expression: '60 lb',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cornbushel',
      expression: '56 lb',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ryebushel',
      expression: '56 lb',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'barleybushel',
      expression: '48 lb',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'oatbushel',
      expression: '32 lb',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ricebushel',
      expression: '45 lb',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'canada_oatbushel',
      expression: '34 lb',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ponyvolume',
      aliases: ['pony'],
      expression: '1 usfloz',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'jigger',
      aliases: ['shot'],
      expression: '1.5 usfloz',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'eushot',
      expression: '25 ml',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'fifth',
      expression: '1|5 usgallon',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'winebottle',
      expression: '750 ml',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'winesplit',
      expression: '1|4 winebottle',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'magnum',
      expression: '1.5 liter',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'metrictenth',
      expression: '375 ml',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'metricfifth',
      expression: '750 ml',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'metricquart',
      expression: '1 liter',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'reputedquart',
      aliases: ['brwinebottle'],
      expression: '1|6 brgallon',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'reputedpint',
      expression: '1|2 reputedquart',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'split',
      expression: '200 ml',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'jeroboam',
      expression: '2 magnum',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rehoboam',
      expression: '3 magnum',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'methuselah',
      expression: '4 magnum',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'imperialbottle',
      expression: '4 magnum',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'salmanazar',
      expression: '6 magnum',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'balthazar',
      expression: '8 magnum',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nebuchadnezzar',
      expression: '10 magnum',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'solomon',
      expression: '12 magnum',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'melchior',
      expression: '12 magnum',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sovereign',
      expression: '17.5 magnum',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'primat',
      expression: '18 magnum',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'goliath',
      expression: '18 magnum',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'melchizedek',
      expression: '20 magnum',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'midas',
      expression: '20 magnum',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wineglass',
      expression: '150 ml',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'smallwineglass',
      expression: '125 ml',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mediumwineglass',
      expression: '175 ml',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'largewineglass',
      expression: '250 ml',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'alcoholunitus',
      expression: '14 g / ethanoldensity',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'alcoholunitca',
      expression: '13.6 g / ethanoldensity',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'alcoholunituk',
      expression: '8 g / ethanoldensity',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'alcoholunitau',
      expression: '10 g / ethanoldensity',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'coffeeratio',
      expression: '55 g/L',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'clarkdegree',
      expression: 'grains/brgallon',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gpg',
      expression: 'grains/usgallon',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'shoeiron',
      expression: '1|48 inch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'shoeounce',
      expression: '1|64 inch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'shoesize_delta',
      expression: '1|3 inch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'shoe_men0',
      expression: '8.25 inch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'shoe_women0',
      expression: '(7+11|12) inch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'shoe_boys0',
      expression: '(3+11|12) inch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'shoe_girls0',
      expression: '(3+7|12) inch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'europeshoesize',
      expression: '2|3 cm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'fin',
      expression: '5 US\$',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sawbuck',
      expression: '10 US\$',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'usgrand',
      aliases: ['grand'],
      expression: '1000 US\$',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lid',
      expression: '1 oz',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'usfootballfield',
      aliases: ['footballfield'],
      expression: '100 yards',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'canadafootballfield',
      expression: '110 yards',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'marathon',
      expression: '26 miles + 385 yards',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'UKlength_B',
      expression: '0.9143992 meter / yard',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'UKlength_SJJ',
      aliases: ['UK'],
      expression: '0.91439841 meter / yard',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'UKlength_K',
      expression: 'meter / 39.37079 inch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'UKlength_C',
      expression: 'meter / 1.09362311 yard',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'brnauticalmile',
      aliases: ['geographicalmile', 'admiraltymile'],
      expression: '6080 ft',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'brknot',
      aliases: ['admiraltyknot'],
      expression: 'brnauticalmile / hr',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'seamile',
      expression: '6000 ft',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'shackle',
      expression: '15 fathoms',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'clove',
      expression: '7 lb',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'stone',
      expression: '14 lb',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tod',
      expression: '28 lb',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'brquarterweight',
      expression: '1|4 brhundredweight',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'brhundredweight',
      aliases: ['longhundredweight'],
      expression: '8 stone',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'longton',
      aliases: ['brton'],
      expression: '20 brhundredweight',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'brminim',
      aliases: ['imperialminim'],
      expression: '1|60 brdram',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'brscruple',
      aliases: ['fluidscruple', 'imperialscruple'],
      expression: '1|3 brdram',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'brdram',
      aliases: ['imperialdram'],
      expression: '1|8 brfloz',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'brfluidounce',
      aliases: ['brfloz', 'imperialfluidounce', 'imperialfloz'],
      expression: '1|20 brpint',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'brgill',
      aliases: ['noggin', 'imperialgill'],
      expression: '1|4 brpint',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'brpint',
      aliases: ['imperialpint'],
      expression: '1|2 brquart',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'brquart',
      aliases: ['imperialquart'],
      expression: '1|4 brgallon',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'brgallon',
      aliases: ['imperialgallon'],
      expression: '4.54609 l',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'brbarrel',
      aliases: ['imperialbarrel'],
      expression: '36 brgallon',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'brbushel',
      aliases: ['imperialbushel'],
      expression: '8 brgallon',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'brheapedbushel',
      aliases: ['imperialheapedbushel'],
      expression: '1.278 brbushel',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'brquarter',
      aliases: ['imperialquarter'],
      expression: '8 brbushel',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'brchaldron',
      aliases: ['imperialchaldron'],
      expression: '36 brbushel',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bag',
      expression: '4 brbushel',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bucket',
      expression: '4 brgallon',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'kilderkin',
      expression: '2 brfirkin',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'last',
      expression: '40 brbushel',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'pottle',
      expression: '0.5 brgallon',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'pin',
      expression: '4.5 brgallon',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'puncheon',
      expression: '72 brgallon',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'seam',
      expression: '8 brbushel',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'coomb',
      expression: '4 brbushel',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'boll',
      expression: '6 brbushel',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'firlot',
      expression: '1|4 boll',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'brfirkin',
      aliases: ['imperialfirkin'],
      expression: '9 brgallon',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cran',
      expression: '37.5 brgallon',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'brwinehogshead',
      aliases: ['brhogshead', 'imperialwinehogshead', 'imperialhogshead'],
      expression: '52.5 brgallon',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'brbeerhogshead',
      aliases: ['imperialbeerhogshead'],
      expression: '54 brgallon',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'brbeerbutt',
      aliases: ['imperialbeerbutt'],
      expression: '2 brbeerhogshead',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'registerton',
      expression: '100 ft^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'shippington',
      aliases: ['freightton'],
      expression: '40 ft^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'brshippington',
      expression: '42 ft^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'displacementton',
      expression: '35 ft^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'waterton',
      expression: '224 brgallon',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'strike',
      expression: '70.5 l',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'amber',
      expression: '4 brbushel',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'barleycorn',
      expression: '1|3 UKinch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nail',
      expression: '1|16 UKyard',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'UKpole',
      expression: '16.5 UKft',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rope',
      expression: '20 UKft',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'englishell',
      aliases: ['ell'],
      expression: '45 UKinch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'flemishell',
      expression: '27 UKinch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'span',
      expression: '9 UKinch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'goad',
      expression: '4.5 UKft',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hide',
      expression: '120 acre',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'virgate',
      expression: '1|4 hide',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nook',
      expression: '1|2 virgate',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rood',
      expression: 'furlong rod',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'englishcarat',
      expression: 'troyounce/151.5',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mancus',
      expression: '2 oz',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mast',
      expression: '2.5 lb',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nailkeg',
      expression: '100 lbs',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'basebox',
      expression: '31360 in^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'geometricpace',
      expression: '5 ft',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'pace',
      expression: '2.5 ft',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'USmilitarypace',
      expression: '30 in',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'USdoubletimepace',
      expression: '36 in',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'fingerbreadth',
      aliases: ['finger'],
      expression: '7|8 in',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'fingerlength',
      expression: '4.5 in',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'palmlength',
      expression: '8 in',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hand',
      aliases: ['palmwidth'],
      expression: '4 inch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'shaftment',
      expression: '6 inch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'smoot',
      expression: '5 ft + 7 in',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tomcruise',
      expression: '5 ft + 7.75 in',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'saltspoon',
      expression: '1|4 tsp',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'uscup',
      aliases: ['cup'],
      expression: '8 usfloz',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ustablespoon',
      aliases: [
        'Tbsp',
        'tbl',
        'tbsp',
        'tblsp',
        'Tb',
        'ustbl',
        'ustbsp',
        'ustblsp',
        'tablespoon',
      ],
      expression: '1|16 uscup',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'usteaspoon',
      aliases: ['tsp', 'ustsp', 'teaspoon'],
      expression: '1|3 ustablespoon',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'metriccup',
      expression: '250 ml',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'stickbutter',
      expression: '1|4 lb',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'legalcup',
      expression: '240 ml',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'legaltablespoon',
      aliases: ['legaltbsp'],
      expression: '1|16 legalcup',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'number1can',
      expression: '10 usfloz',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'number2can',
      expression: '19 usfloz',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'number2.5can',
      expression: '3.5 uscups',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'number3can',
      expression: '4 uscups',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'number5can',
      expression: '7 uscups',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'number10can',
      expression: '105 usfloz',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'brcup',
      expression: '1|2 brpint',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'brteacup',
      expression: '1|3 brpint',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'brtablespoon',
      aliases: ['brtbl', 'brtbsp', 'brtblsp'],
      expression: '15 ml',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'brteaspoon',
      aliases: ['brtsp'],
      expression: '1|3 brtablespoon',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'brdessertspoon',
      aliases: ['dessertspoon', 'dsp'],
      expression: '2 brteaspoon',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'australiatablespoon',
      aliases: ['austbl', 'austbsp', 'austblsp'],
      expression: '20 ml',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'australiateaspoon',
      aliases: ['austsp'],
      expression: '1|4 australiatablespoon',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'etto',
      aliases: ['etti'],
      expression: '100 g',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'catty',
      expression: '0.5 kg',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'oldcatty',
      expression: '4|3 lbs',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tael',
      expression: '1|16 oldcatty',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mace',
      expression: '0.1 tael',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'oldpicul',
      expression: '100 oldcatty',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'picul',
      expression: '100 catty',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'seer',
      aliases: ['ser'],
      expression: '14400 grain',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'maund',
      expression: '40 seer',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'pakistanseer',
      expression: '1 kg',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'pakistanmaund',
      expression: '40 pakistanseer',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'chittak',
      expression: '1|16 seer',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tola',
      expression: '1|5 chittak',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ollock',
      expression: '1|4 liter',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'japancup',
      expression: '200 ml',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'butter',
      expression: '8 oz/uscup',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'butter_clarified',
      expression: '6.8 oz/uscup',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cocoa_butter',
      expression: '9 oz/uscup',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'shortening',
      expression: '6.75 oz/uscup',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'oil',
      expression: '7.5 oz/uscup',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cakeflour_sifted',
      expression: '3.5 oz/uscup',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cakeflour_spooned',
      expression: '4 oz/uscup',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cakeflour_scooped',
      expression: '4.5 oz/uscup',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'flour_sifted',
      expression: '4 oz/uscup',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'flour_spooned',
      expression: '4.25 oz/uscup',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'flour_scooped',
      expression: '5 oz/uscup',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'breadflour_sifted',
      expression: '4.25 oz/uscup',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'breadflour_spooned',
      expression: '4.5 oz/uscup',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'breadflour_scooped',
      expression: '5.5 oz/uscup',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cornstarch',
      expression: '120 grams/uscup',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'dutchcocoa_sifted',
      expression: '75 g/uscup',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'dutchcocoa_spooned',
      expression: '92 g/uscup',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'dutchcocoa_scooped',
      expression: '95 g/uscup',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cocoa_sifted',
      expression: '75 g/uscup',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cocoa_spooned',
      expression: '82 g/uscup',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cocoa_scooped',
      expression: '95 g/uscup',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'heavycream',
      expression: '232 g/uscup',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'milk',
      expression: '242 g/uscup',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sourcream',
      expression: '242 g/uscup',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'molasses',
      expression: '11.25 oz/uscup',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cornsyrup',
      expression: '11.5 oz/uscup',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'honey',
      expression: '11.75 oz/uscup',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sugar',
      expression: '200 g/uscup',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'powdered_sugar',
      expression: '4 oz/uscup',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'brownsugar_light',
      expression: '217 g/uscup',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'brownsugar_dark',
      expression: '239 g/uscup',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'baking_powder',
      expression: '4.6 grams / ustsp',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'salt',
      expression: '6 g / ustsp',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'koshersalt',
      expression: '2.8 g / ustsp',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'koshersalt_morton',
      expression: '4.8 g / ustsp',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'egg',
      expression: '50 grams',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'eggwhite',
      expression: '30 grams',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'eggyolk',
      expression: '18.6 grams',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'eggvolume',
      expression: '3 ustablespoons + 1|2 ustsp',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'eggwhitevolume',
      expression: '2 ustablespoons',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'eggyolkvolume',
      expression: '3.5 ustsp',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ethanoldensity',
      aliases: ['alcoholdensity'],
      expression: '0.7893 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'baumeconst',
      expression: '145',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_cherry',
      expression: '35 lb/ft^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_redoak',
      expression: '44 lb/ft^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_whiteoak',
      expression: '47 lb/ft^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_blackwalnut',
      aliases: ['wood_walnut'],
      expression: '38 lb/ft^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_birch',
      expression: '43 lb/ft^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_hardmaple',
      expression: '44 lb/ft^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_bigleafmaple',
      expression: '34 lb/ft^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_boxeldermaple',
      expression: '30 lb/ft^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_redmaple',
      expression: '38 lb/ft^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_silvermaple',
      expression: '33 lb/ft^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_stripedmaple',
      expression: '32 lb/ft^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_softmaple',
      expression:
          '(wood_bigleafmaple + wood_boxeldermaple + wood_redmaple + wood_silvermaple + wood_stripedmaple) / 5',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_poplar',
      expression: '29 lb/ft^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_beech',
      expression: '45 lb/ft^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_jeffreypine',
      expression: '28 lb/ft^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_ocotepine',
      expression: '44 lb/ft^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_ponderosapine',
      expression: '28 lb/ft^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_loblollypine',
      expression: '35 lb/ft^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_longleafpine',
      expression: '41 lb/ft^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_shortleafpine',
      expression: '35 lb/ft^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_slashpine',
      expression: '41 lb/ft^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_yellowpine',
      expression:
          '(wood_loblollypine + wood_longleafpine + wood_shortleafpine + wood_slashpine) / 4',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_redpine',
      expression: '34 lb/ft^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_easternwhitepine',
      expression: '25 lb/ft^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_westernwhitepine',
      expression: '27 lb/ft^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_whitepine',
      expression: '(wood_easternwhitepine + wood_westernwhitepine) / 2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_douglasfir',
      expression: '32 lb/ft^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_blackspruce',
      expression: '28 lb/ft^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_engelmannspruce',
      expression: '24 lb/ft^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_redspruce',
      expression: '27 lb/ft^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_sitkaspruce',
      expression: '27 lb/ft^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_whitespruce',
      expression: '27 lb/ft^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_spruce',
      expression:
          '(wood_blackspruce + wood_engelmannspruce + wood_redspruce + wood_sitkaspruce + wood_whitespruce) / 5',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_basswood',
      expression: '26 lb/ft^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_balsa',
      expression: '9 lb/ft^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_ebony_gaboon',
      expression: '60 lb/ft^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_ebony_macassar',
      expression: '70 lb/ft^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_mahogany',
      expression: '37 lb/ft^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_teak',
      expression: '41 lb/ft^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_rosewood_brazilian',
      expression: '52 lb/ft^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_rosewood_honduran',
      expression: '64 lb/ft^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_rosewood_indian',
      expression: '52 lb/ft^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_cocobolo',
      expression: '69 lb/ft^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_bubinga',
      expression: '56 lb/ft^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_zebrawood',
      expression: '50 lb/ft^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_koa',
      expression: '38 lb/ft^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_snakewood',
      expression: '75.7 lb/ft^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_lignumvitae',
      expression: '78.5 lb/ft^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_blackwood',
      expression: '79.3 lb/ft^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_blackironwood',
      expression: '84.5 lb/ft^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_mod_beech',
      expression: '1.720e6 lbf/in^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_mod_birchyellow',
      aliases: ['wood_mod_birch'],
      expression: '2.010e6 lbf/in^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_mod_cherry',
      expression: '1.490e6 lbf/in^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_mod_hardmaple',
      expression: '1.830e6 lbf/in^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_mod_bigleafmaple',
      expression: '1.450e6 lbf/in^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_mod_boxeldermaple',
      expression: '1.050e6 lbf/in^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_mod_redmaple',
      expression: '1.640e6 lbf/in^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_mod_silvermaple',
      expression: '1.140e6 lbf/in^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_mod_softmaple',
      expression:
          '(wood_mod_bigleafmaple + wood_mod_boxeldermaple + wood_mod_redmaple + wood_mod_silvermaple) / 4',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_mod_redoak',
      expression: '1.761e6 lbf/in^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_mod_whiteoak',
      expression: '1.762e6 lbf/in^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_mod_poplar',
      expression: '1.580e6 lbf/in^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_mod_blackwalnut',
      aliases: ['wood_mod_walnut'],
      expression: '1.680e6 lbf/in^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_mod_jeffreypine',
      expression: '1.240e6 lbf/in^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_mod_ocotepine',
      expression: '2.209e6 lbf/in^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_mod_ponderosapine',
      expression: '1.290e6 lbf/in^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_mod_loblollypine',
      expression: '1.790e6 lbf/in^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_mod_longleafpine',
      expression: '1.980e6 lbf/in^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_mod_shortleafpine',
      expression: '1.750e6 lbf/in^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_mod_slashpine',
      expression: '1.980e6 lbf/in^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_mod_yellowpine',
      expression:
          '(wood_mod_loblollypine + wood_mod_longleafpine + wood_mod_shortleafpine + wood_mod_slashpine) / 4',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_mod_redpine',
      expression: '1.630e6 lbf/in^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_mod_easternwhitepine',
      expression: '1.240e6 lbf/in^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_mod_westernwhitepine',
      expression: '1.460e6 lbf/in^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_mod_whitepine',
      expression: '(wood_mod_easternwhitepine + wood_mod_westernwhitepine) / 2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_mod_douglasfir',
      expression: '1.765e6 lbf/in^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_mod_blackspruce',
      expression: '1.523e6 lbf/in^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_mod_englemannspruce',
      expression: '1.369e6 lbf/in^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_mod_redspruce',
      expression: '1.560e6 lbf/in^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_mod_sitkaspruce',
      expression: '1.600e6 lbf/in^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_mod_whitespruce',
      expression: '1.315e6 lbf/in^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_mod_spruce',
      expression:
          '(wood_mod_blackspruce + wood_mod_englemannspruce + wood_mod_redspruce + wood_mod_sitkaspruce + wood_mod_whitespruce) / 5',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_mod_balsa',
      expression: '0.538e6 lbf/in^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_mod_basswood',
      expression: '1.460e6 lbf/in^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_mod_blackwood',
      expression: '2.603e6 lbf/in^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_mod_bubinga',
      expression: '2.670e6 lbf/in^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_mod_cocobolo',
      expression: '2.712e6 lbf/in^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_mod_ebony_gaboon',
      expression: '2.449e6 lbf/in^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_mod_ebony_macassar',
      expression: '2.515e6 lbf/in^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_mod_blackironwood',
      expression: '2.966e6 lbf/in^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_mod_koa',
      expression: '1.503e6 lbf/in^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_mod_lignumvitae',
      expression: '2.043e6 lbf/in^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_mod_mahogany',
      expression: '1.458e6 lbf/in^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_mod_rosewood_brazilian',
      expression: '2.020e6 lbf/in^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_mod_rosewood_honduran',
      expression: '3.190e6 lbf/in^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_mod_rosewood_indian',
      expression: '1.668e6 lbf/in^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_mod_snakewood',
      expression: '3.364e6 lbf/in^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_mod_teak',
      expression: '1.781e6 lbf/in^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wood_mod_zebrawood',
      expression: '2.374e6 lbf/in^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_russia',
      expression: '17098246 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_antarctica',
      expression: '14000000 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_china',
      expression: '9596961 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_brazil',
      expression: '8515767 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_australia',
      expression: '7692024 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_india',
      expression: '3287263 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_argentina',
      expression: '2780400 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_kazakhstan',
      expression: '2724900 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_algeria',
      expression: '2381741 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_drcongo',
      expression: '2344858 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_greenland',
      expression: '2166086 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_saudiarabia',
      expression: '2149690 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_mexico',
      expression: '1964375 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_indonesia',
      expression: '1910931 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_sudan',
      expression: '1861484 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_libya',
      expression: '1759540 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_iran',
      expression: '1648195 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_mongolia',
      expression: '1564110 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_peru',
      expression: '1285216 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_chad',
      expression: '1284000 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_niger',
      expression: '1267000 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_angola',
      expression: '1246700 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_mali',
      expression: '1240192 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_southafrica',
      expression: '1221037 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_colombia',
      expression: '1141748 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_ethiopia',
      expression: '1104300 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_bolivia',
      expression: '1098581 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_mauritania',
      expression: '1030700 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_egypt',
      expression: '1002450 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_tanzania',
      expression: '945087 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_nigeria',
      expression: '923768 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_venezuela',
      expression: '916445 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_pakistan',
      expression: '881912 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_namibia',
      expression: '825615 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_mozambique',
      expression: '801590 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_turkey',
      expression: '783562 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_chile',
      expression: '756102 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_zambia',
      expression: '752612 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_myanmar',
      aliases: ['area_burma'],
      expression: '676578 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_afghanistan',
      expression: '652230 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_southsudan',
      expression: '644329 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_france',
      expression: '640679 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_somalia',
      expression: '637657 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_centralafrica',
      expression: '622984 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_ukraine',
      expression: '603500 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_crimea',
      expression: '27000 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_madagascar',
      expression: '587041 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_botswana',
      expression: '581730 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_kenya',
      expression: '580367 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_yemen',
      expression: '527968 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_thailand',
      expression: '513120 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_spain',
      expression: '505992 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_turkmenistan',
      expression: '488100 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_cameroon',
      expression: '475422 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_papuanewguinea',
      expression: '462840 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_sweden',
      expression: '450295 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_uzbekistan',
      expression: '447400 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_morocco',
      expression: '446550 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_iraq',
      expression: '438317 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_paraguay',
      expression: '406752 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_zimbabwe',
      expression: '390757 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_japan',
      expression: '377973 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_germany',
      expression: '357114 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_congorepublic',
      expression: '342000 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_finland',
      expression: '338424 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_vietnam',
      expression: '331212 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_malaysia',
      expression: '330803 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_norway',
      expression: '323802 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_ivorycoast',
      expression: '322463 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_poland',
      expression: '312696 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_oman',
      expression: '309500 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_italy',
      expression: '301339 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_philippines',
      expression: '300000 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_ecuador',
      expression: '276841 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_burkinafaso',
      expression: '274222 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_newzealand',
      expression: '270467 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_gabon',
      expression: '267668 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_westernsahara',
      expression: '266000 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_guinea',
      expression: '245857 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_uganda',
      expression: '241550 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_ghana',
      expression: '238533 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_romania',
      expression: '238397 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_laos',
      expression: '236800 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_guyana',
      expression: '214969 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_belarus',
      expression: '207600 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_kyrgyzstan',
      expression: '199951 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_senegal',
      expression: '196722 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_syria',
      expression: '185180 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_golanheights',
      expression: '1150 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_cambodia',
      expression: '181035 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_uruguay',
      expression: '176215 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_somaliland',
      expression: '176120 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_suriname',
      expression: '163820 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_tunisia',
      expression: '163610 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_bangladesh',
      expression: '147570 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_nepal',
      expression: '147181 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_tajikistan',
      expression: '143100 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_greece',
      expression: '131990 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_nicaragua',
      expression: '130373 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_northkorea',
      expression: '120540 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_malawi',
      expression: '118484 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_eritrea',
      expression: '117600 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_benin',
      expression: '114763 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_honduras',
      expression: '112492 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_liberia',
      expression: '111369 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_bulgaria',
      expression: '110879 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_cuba',
      expression: '109884 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_guatemala',
      expression: '108889 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_iceland',
      expression: '103000 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_southkorea',
      expression: '100210 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_hungary',
      expression: '93028 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_portugal',
      expression: '92090 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_jordan',
      expression: '89342 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_serbia',
      expression: '88361 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_azerbaijan',
      expression: '86600 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_austria',
      expression: '83871 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_uae',
      expression: '83600 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_czechia',
      aliases: ['area_czechrepublic'],
      expression: '78865 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_panama',
      expression: '75417 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_sierraleone',
      expression: '71740 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_ireland',
      expression: '70273 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_georgia',
      expression: '69700 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_srilanka',
      expression: '65610 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_lithuania',
      expression: '65300 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_latvia',
      expression: '64559 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_togo',
      expression: '56785 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_croatia',
      expression: '56594 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_bosnia',
      expression: '51209 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_costarica',
      expression: '51100 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_slovakia',
      expression: '49037 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_dominicanrepublic',
      expression: '48671 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_estonia',
      expression: '45227 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_denmark',
      expression: '43094 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_netherlands',
      expression: '41850 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_switzerland',
      expression: '41284 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_bhutan',
      expression: '38394 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_taiwan',
      expression: '36193 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_guineabissau',
      expression: '36125 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_moldova',
      expression: '33846 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_belgium',
      expression: '30528 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_lesotho',
      expression: '30355 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_armenia',
      expression: '29743 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_solomonislands',
      expression: '28896 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_albania',
      expression: '28748 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_equitorialguinea',
      expression: '28051 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_burundi',
      expression: '27834 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_haiti',
      expression: '27750 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_rwanda',
      expression: '26338 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_northmacedonia',
      expression: '25713 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_djibouti',
      expression: '23200 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_belize',
      expression: '22966 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_elsalvador',
      expression: '21041 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_israel',
      expression: '20770 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_slovenia',
      expression: '20273 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_fiji',
      expression: '18272 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_kuwait',
      expression: '17818 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_eswatini',
      expression: '17364 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_easttimor',
      expression: '14919 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_bahamas',
      expression: '13943 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_montenegro',
      expression: '13812 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_vanatu',
      expression: '12189 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_qatar',
      expression: '11586 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_gambia',
      expression: '11295 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_jamaica',
      expression: '10991 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_kosovo',
      expression: '10887 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_lebanon',
      expression: '10452 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_cyprus',
      expression: '9251 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_puertorico',
      expression: '9104 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_westbank',
      expression: '5860 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_hongkong',
      expression: '2755 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_luxembourg',
      expression: '2586 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_singapore',
      expression: '716 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_gazastrip',
      expression: '360 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_malta',
      expression: '316 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_liechtenstein',
      expression: '160 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_monaco',
      expression: '2.02 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_vaticancity',
      expression: '0.44 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_europeanunion',
      aliases: ['area_eu'],
      expression:
          'area_austria + area_belgium + area_bulgaria + area_croatia + area_cyprus + area_czechia + area_denmark + area_estonia + area_finland + area_france + area_germany + area_greece + area_hungary + area_ireland + area_italy + area_latvia + area_lithuania + area_luxembourg + area_malta + area_netherlands + area_poland + area_portugal + area_romania + area_slovakia + area_slovenia + area_spain + area_sweden',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_alaska',
      expression: '1723336.8 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_texas',
      expression: '695661.6 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_california',
      expression: '423967.4 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_montana',
      expression: '380831.1 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_newmexico',
      expression: '314917.4 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_arizona',
      expression: '295233.5 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_nevada',
      expression: '286379.7 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_colorado',
      expression: '269601.4 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_oregon',
      expression: '254799.2 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_wyoming',
      expression: '253334.5 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_michigan',
      expression: '250486.8 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_minnesota',
      expression: '225162.8 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_utah',
      expression: '219881.9 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_idaho',
      expression: '216442.6 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_kansas',
      expression: '213100.0 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_nebraska',
      expression: '200329.9 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_southdakota',
      expression: '199728.7 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_washington',
      expression: '184660.8 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_northdakota',
      expression: '183107.8 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_oklahoma',
      expression: '181037.2 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_missouri',
      expression: '180540.3 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_florida',
      expression: '170311.7 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_wisconsin',
      expression: '169634.8 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_georgia_us',
      expression: '153910.4 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_illinois',
      expression: '149995.4 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_iowa',
      expression: '145745.9 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_newyork',
      expression: '141296.7 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_northcarolina',
      expression: '139391.0 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_arkansas',
      expression: '137731.8 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_alabama',
      expression: '135767.4 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_louisiana',
      expression: '135658.7 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_mississippi',
      expression: '125437.7 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_pennsylvania',
      expression: '119280.2 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_ohio',
      expression: '116097.7 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_virginia',
      expression: '110786.6 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_tennessee',
      expression: '109153.1 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_kentucky',
      expression: '104655.7 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_indiana',
      expression: '94326.2 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_maine',
      expression: '91633.1 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_southcarolina',
      expression: '82932.7 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_westvirginia',
      expression: '62755.5 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_maryland',
      expression: '32131.2 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_hawaii',
      expression: '28313.0 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_massachusetts',
      expression: '27335.7 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_vermont',
      expression: '24906.3 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_newhampshire',
      expression: '24214.2 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_newjersey',
      expression: '22591.4 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_connecticut',
      expression: '14357.4 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_delaware',
      expression: '6445.8 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_rhodeisland',
      expression: '4001.2 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_districtofcolumbia',
      expression: '177.0 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_unitedstates',
      aliases: ['area_us'],
      expression:
          'area_alabama + area_alaska + area_arizona + area_arkansas + area_california + area_colorado + area_connecticut + area_delaware + area_districtofcolumbia + area_florida + area_georgia_us + area_hawaii + area_idaho + area_illinois + area_indiana + area_iowa + area_kansas + area_kentucky + area_louisiana + area_maine + area_maryland + area_massachusetts + area_michigan + area_minnesota + area_mississippi + area_missouri + area_montana + area_nebraska + area_nevada + area_newhampshire + area_newjersey + area_newmexico + area_newyork + area_northcarolina + area_northdakota + area_ohio + area_oklahoma + area_oregon + area_pennsylvania + area_rhodeisland + area_southcarolina + area_southdakota + area_tennessee + area_texas + area_utah + area_vermont + area_virginia + area_washington + area_westvirginia + area_wisconsin + area_wyoming',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_ontario',
      expression: '1076395 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_quebec',
      expression: '1542056 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_novascotia',
      expression: '55284 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_newbrunswick',
      expression: '72908 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_canada_original',
      expression:
          'area_ontario + area_quebec + area_novascotia + area_newbrunswick',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_manitoba',
      expression: '647797 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_britishcolumbia',
      expression: '944735 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_princeedwardisland',
      expression: '5660 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_canada_additional',
      expression:
          'area_manitoba + area_britishcolumbia + area_princeedwardisland',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_alberta',
      expression: '661848 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_saskatchewan',
      expression: '651036 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_newfoundlandandlabrador',
      expression: '405212 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_canada_recent',
      expression:
          'area_alberta + area_saskatchewan + area_newfoundlandandlabrador',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_canada_provinces',
      expression:
          'area_canada_original + area_canada_additional + area_canada_recent',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_northwestterritories',
      expression: '1346106 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_yukon',
      expression: '482443 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_nunavut',
      expression: '2093190 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_canada_territories',
      expression: 'area_northwestterritories + area_yukon + area_nunavut',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_canada',
      expression: 'area_canada_provinces + area_canada_territories',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_england',
      expression: '132947.76 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_wales',
      expression: '21224.48 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_englandwales',
      expression: 'area_england + area_wales',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_scotland',
      expression: '80226.36 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_greatbritain',
      aliases: ['area_gb'],
      expression: 'area_england + area_wales + area_scotland',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_northernireland',
      expression: '14133.38 km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'area_unitedkingdom',
      aliases: ['area_uk'],
      expression: 'area_greatbritain + area_northernireland',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ouncedal',
      expression: 'oz ft / s^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'poundal',
      aliases: ['pdl'],
      expression: 'lb ft / s^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tondal',
      expression: 'longton ft / s^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'osi',
      expression: 'ounce force / inch^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'psi',
      aliases: ['psia'],
      expression: 'pound force / inch^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tsi',
      expression: 'ton force / inch^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'reyn',
      expression: 'psi sec',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'slug',
      aliases: ['geepound'],
      expression: 'lbf s^2 / ft',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'slugf',
      expression: 'slug force',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'slinch',
      expression: 'lbf s^2 / inch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'slinchf',
      expression: 'slinch force',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lbf',
      expression: 'lb force',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tonf',
      expression: 'ton force',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'kip',
      expression: '1000 lbf',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ksi',
      expression: 'kip / in^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mil',
      aliases: ['㏕'],
      expression: '0.001 inch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thou',
      expression: '0.001 inch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tenth',
      expression: '0.0001 inch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'millionth',
      expression: '1e-6 inch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'circularinch',
      aliases: ['circleinch'],
      expression: '1|4 pi in^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cylinderinch',
      expression: 'circleinch inch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'circularmil',
      aliases: ['cmil'],
      expression: '1|4 pi mil^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'MCM',
      expression: 'kcmil',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cental',
      aliases: ['centner'],
      expression: '100 pound',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'caliber',
      expression: '0.01 inch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'duty',
      expression: 'ft lbf',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'celo',
      expression: 'ft / s^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'jerk',
      expression: 'ft / s^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'australiapoint',
      expression: '0.01 inch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sabin',
      expression: 'ft^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'standardgauge',
      expression: '4 ft + 8.5 in',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'flag',
      expression: '5 ft^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rollwallpaper',
      expression: '30 ft^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'fillpower',
      expression: 'in^3 / ounce',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'pinlength',
      expression: '1|16 inch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'buttonline',
      expression: '1|40 inch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'beespace',
      expression: '1|4 inch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'diamond',
      expression: '8|5 ft',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'retmaunit',
      aliases: ['U', 'RU'],
      expression: '1.75 in',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'count',
      expression: 'per pound',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'flightlevel',
      aliases: ['FL'],
      expression: '100 ft',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'calorie_th',
      aliases: ['calorie', 'cal', 'thermcalorie', 'cal_th', '㎈'],
      expression: '4.184 J',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'calorie_IT',
      aliases: ['cal_IT'],
      expression: '4.1868 J',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'calorie_15',
      aliases: ['cal_15', 'calorie_fifteen'],
      expression: '4.18580 J',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'calorie_20',
      aliases: ['cal_20', 'calorie_twenty'],
      expression: '4.18190 J',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'calorie_4',
      aliases: ['cal_4', 'calorie_four'],
      expression: '4.204 J',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cal_mean',
      expression: '4.19002 J',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'Calorie',
      expression: 'kilocalorie',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thermie',
      expression: '1e6 cal_15',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'btu_IT',
      aliases: ['BTU', 'btu', 'britishthermalunit'],
      expression: 'cal_IT lb degF / gram K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'btu_th',
      expression: 'cal_th lb degF / gram K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'btu_mean',
      expression: 'cal_mean lb degF / gram K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'btu_15',
      expression: 'cal_15 lb degF / gram K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'btu_ISO',
      expression: '1055.06 J',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'quad',
      expression: 'quadrillion btu',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ECtherm',
      expression: '1e5 btu_ISO',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'UStherm',
      aliases: ['therm'],
      expression: '1.054804e8 J',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'water_fusion_heat',
      expression: '6.01 kJ/mol / (18.015 g/mol)',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'water_vaporization_heat',
      expression: '2256.4 J/g',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'SPECIFIC_HEAT',
      expression: 'ENERGY / MASS / TEMPERATURE_DIFFERENCE',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'SPECIFIC_HEAT_CAPACITY',
      expression: 'ENERGY / MASS / TEMPERATURE_DIFFERENCE',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specificheat_water',
      aliases: ['water_specificheat'],
      expression: 'calorie / g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specificheat_aluminum',
      expression: '0.91 J/g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specificheat_antimony',
      expression: '0.21 J/g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specificheat_barium',
      expression: '0.20 J/g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specificheat_beryllium',
      expression: '1.83 J/g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specificheat_bismuth',
      expression: '0.13 J/g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specificheat_cadmium',
      expression: '0.23 J/g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specificheat_cesium',
      expression: '0.24 J/g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specificheat_chromium',
      expression: '0.46 J/g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specificheat_cobalt',
      expression: '0.42 J/g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specificheat_copper',
      expression: '0.39 J/g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specificheat_gallium',
      expression: '0.37 J/g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specificheat_germanium',
      expression: '0.32 J/g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specificheat_gold',
      expression: '0.13 J/g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specificheat_hafnium',
      expression: '0.14 J/g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specificheat_indium',
      expression: '0.24 J/g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specificheat_iridium',
      expression: '0.13 J/g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specificheat_iron',
      expression: '0.45 J/g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specificheat_lanthanum',
      expression: '0.195 J/g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specificheat_lead',
      expression: '0.13 J/g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specificheat_lithium',
      expression: '3.57 J/g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specificheat_lutetium',
      expression: '0.15 J/g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specificheat_magnesium',
      expression: '1.05 J/g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specificheat_manganese',
      expression: '0.48 J/g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specificheat_mercury',
      expression: '0.14 J/g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specificheat_molybdenum',
      expression: '0.25 J/g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specificheat_nickel',
      expression: '0.44 J/g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specificheat_osmium',
      expression: '0.13 J/g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specificheat_palladium',
      expression: '0.24 J/g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specificheat_platinum',
      expression: '0.13 J/g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specificheat_plutonum',
      expression: '0.13 J/g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specificheat_potassium',
      expression: '0.75 J/g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specificheat_rhenium',
      expression: '0.14 J/g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specificheat_rhodium',
      expression: '0.24 J/g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specificheat_rubidium',
      expression: '0.36 J/g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specificheat_ruthenium',
      expression: '0.24 J/g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specificheat_scandium',
      expression: '0.57 J/g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specificheat_selenium',
      expression: '0.32 J/g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specificheat_silicon',
      expression: '0.71 J/g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specificheat_silver',
      expression: '0.23 J/g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specificheat_sodium',
      expression: '1.21 J/g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specificheat_strontium',
      expression: '0.30 J/g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specificheat_tantalum',
      expression: '0.14 J/g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specificheat_thallium',
      expression: '0.13 J/g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specificheat_thorium',
      expression: '0.13 J/g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specificheat_tin',
      expression: '0.21 J/g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specificheat_titanium',
      expression: '0.54 J/g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specificheat_tungsten',
      expression: '0.13 J/g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specificheat_uranium',
      expression: '0.12 J/g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specificheat_vanadium',
      expression: '0.39 J/g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specificheat_yttrium',
      expression: '0.30 J/g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specificheat_zinc',
      expression: '0.39 J/g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specificheat_zirconium',
      expression: '0.27 J/g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specificheat_ethanol',
      expression: '2.3 J/g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specificheat_ammonia',
      expression: '4.6 J/g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specificheat_freon',
      expression: '0.91 J/g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specificheat_gasoline',
      expression: '2.22 J/g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specificheat_iodine',
      expression: '2.15 J/g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specificheat_oliveoil',
      expression: '1.97 J/g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specificheat_hydrogen',
      expression: '14.3 J/g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specificheat_helium',
      expression: '5.1932 J/g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specificheat_argon',
      expression: '0.5203 J/g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specificheat_tissue',
      expression: '3.5 J/g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specificheat_diamond',
      expression: '0.5091 J/g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specificheat_granite',
      expression: '0.79 J/g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specificheat_graphite',
      expression: '0.71 J/g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specificheat_ice',
      expression: '2.11 J/g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specificheat_asphalt',
      expression: '0.92 J/g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specificheat_brick',
      expression: '0.84 J/g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specificheat_concrete',
      expression: '0.88 J/g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specificheat_glass_silica',
      expression: '0.84 J/g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specificheat_glass_flint',
      expression: '0.503 J/g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specificheat_glass_pyrex',
      expression: '0.753 J/g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specificheat_gypsum',
      expression: '1.09 J/g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specificheat_marble',
      expression: '0.88 J/g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specificheat_sand',
      expression: '0.835 J/g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specificheat_soil',
      expression: '0.835 J/g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specificheat_wood',
      expression: '1.7 J/g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specificheat_sucrose',
      expression: '1.244 J/g K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tonoil',
      aliases: ['toe'],
      expression: '1e10 cal_IT',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'toncoal',
      expression: '7e9 cal_IT',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'barreloil',
      expression: '5.8 Mbtu',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'naturalgas_HHV',
      aliases: ['naturalgas'],
      expression: '1027 btu/ft3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'naturalgas_LHV',
      expression: '930 btu/ft3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'charcoal',
      expression: '30 GJ/tonne',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'woodenergy_dry',
      expression: '20 GJ/tonne',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'woodenergy_airdry',
      expression: '15 GJ/tonne',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'coal_bituminous',
      expression: '27 GJ / tonne',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'coal_lignite',
      expression: '15 GJ / tonne',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'coal_US',
      expression: '22 GJ / uston',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ethanol_HHV',
      expression: '84000 btu/usgallon',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ethanol_LHV',
      expression: '75700 btu/usgallon',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'diesel',
      expression: '130500 btu/usgallon',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gasoline_LHV',
      expression: '115000 btu/usgallon',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gasoline_HHV',
      aliases: ['gasoline'],
      expression: '125000 btu/usgallon',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'heating',
      expression: '37.3 MJ/liter',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'fueloil',
      expression: '39.7 MJ/liter',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'propane',
      expression: '93.3 MJ/m^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'butane',
      expression: '124 MJ/m^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mpg_e',
      aliases: ['MPGe'],
      expression: 'miles / gallon gasoline_LHV',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'uranium_pure',
      expression: '200 MeV avogadro / (235.0439299 g/mol)',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'uranium_natural',
      expression: '0.7% uranium_pure',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'celsiusheatunit',
      aliases: ['chu'],
      expression: 'cal lb degC / gram K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'VA',
      expression: 'volt ampere',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'kWh',
      expression: 'kilowatt hour',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'horsepower',
      aliases: ['mechanicalhorsepower', 'hp', 'brhorsepower'],
      expression: '550 foot pound force / sec',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'metrichorsepower',
      aliases: ['chevalvapeur'],
      expression: '75 kilogram force meter / sec',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'electrichorsepower',
      expression: '746 W',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'boilerhorsepower',
      expression: '9809.50 W',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'waterhorsepower',
      expression: '746.043 W',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'donkeypower',
      expression: '250 W',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'THERMAL_CONDUCTIVITY',
      expression: 'POWER / AREA (TEMPERATURE_DIFFERENCE/LENGTH)',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'THERMAL_RESISTIVITY',
      expression: '1/THERMAL_CONDUCTIVITY',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'THERMAL_CONDUCTANCE',
      expression: 'POWER / TEMPERATURE_DIFFERENCE',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'THERMAL_RESISTANCE',
      expression: '1/THERMAL_CONDUCTANCE',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'THERMAL_ADMITTANCE',
      expression: 'THERMAL_CONDUCTIVITY / LENGTH',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'THERMAL_INSULANCE',
      expression: 'THERMAL_RESISTIVITY LENGTH',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'THERMAL_INSULATION',
      expression: 'THERMAL_RESISTIVITY LENGTH',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'Rvalue',
      expression: 'degF ft^2 hr / btu',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'Uvalue',
      expression: '1/Rvalue',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'europeanUvalue',
      expression: 'watt / m^2 K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'RSI',
      expression: 'degC m^2 / W',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'clo',
      expression: '0.155 degC m^2 / W',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tog',
      expression: '0.1 degC m^2 / W',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'THERMAL_DIFFUSIVITY',
      expression: 'THERMAL_CONDUCTIVITY / DENSITY SPECIFIC_HEAT_CAPACITY',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'diamond_natural_thermal_conductivity',
      expression: '2200 W / m K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'diamond_synthetic_thermal_conductivity',
      expression: '3320 W / m K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'silver_thermal_conductivity',
      expression: '406 W / m K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'aluminum_thermal_conductivity',
      expression: '205 W / m K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'copper_thermal_conductivity',
      expression: '385 W / m K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gold_thermal_conductivity',
      expression: '314 W / m K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iron_thermal_conductivity',
      expression: '79.5 W / m K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'stainless_304_thermal_conductivity',
      expression: '15.5 W / m K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'diamond_synthetic_thermal_diffusivity',
      expression: '1200 mm^2 / s',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'diamond_natural_thermal_diffusivity',
      expression: '780 mm^2 / s',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'helium_thermal_diffusivity',
      expression: '190 mm^2 / s',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'silver_thermal_diffusivity',
      expression: '165.63 mm^2 / s',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gold_thermal_diffusivity',
      expression: '127 mm^2 / s',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'copper_thermal_diffusivity',
      expression: '111 mm^2 / s',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'aluminum_thermal_diffusivity',
      expression: '97 mm^2 / s',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iron_thermal_diffusivity',
      expression: '23 mm^2 / s',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'air_thermal_diffusivity',
      expression: '19 mm^2 / s',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'stainless_304_thermal_diffusivity',
      expression: '4.2 mm^2 / s',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ice_thermal_diffusivity',
      expression: '1.02 mm^2 / s',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'glass_thermal_diffusivity',
      expression: '0.34 mm^2 / s',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'water_thermal_diffusivity',
      expression: '0.143 mm^2 / s',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nylon_thermal_diffusivity',
      expression: '0.09 mm^2 / s',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'pine_thermal_diffusivity',
      expression: '0.082 mm^2 / s',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ENTROPY',
      expression: 'ENERGY / TEMPERATURE',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'clausius',
      expression: '1e3 cal/K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'langley',
      expression: 'thermcalorie/cm^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'poncelet',
      expression: '100 kg force m / s',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tonrefrigeration',
      aliases: ['tonref'],
      expression: 'uston 144 btu / lb day',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'refrigeration',
      expression: 'tonref / ton',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'frigorie',
      expression: '1000 cal_15',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'airwatt',
      expression: '8.5 (ft^3/min) inH2O',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tnt',
      expression: '1e9 cal_th / ton',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'davycrocket',
      expression: '10 ton tnt',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hiroshima',
      aliases: ['littleboy'],
      expression: '15.5 kiloton tnt',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nagasaki',
      aliases: ['fatman'],
      expression: '21 kiloton tnt',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ivyking',
      expression: '500 kiloton tnt',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'castlebravo',
      expression: '15 megaton tnt',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tsarbomba',
      expression: '50 megaton tnt',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'b53bomb',
      expression: '9 megaton tnt',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'trinity',
      aliases: ['gadget'],
      expression: '18 kiloton tnt',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'perm_0C',
      aliases: ['perm_zero', 'perm_0', 'perm'],
      expression: 'grain / hr ft^2 inHg',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'perm_23C',
      aliases: ['perm_twentythree'],
      expression: 'grain / hr ft^2 in Hg23C',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'pair',
      expression: '2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'brace',
      expression: '2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nest',
      expression: '3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hattrick',
      expression: '3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'dicker',
      expression: '10',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'dozen',
      expression: '12',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bakersdozen',
      expression: '13',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'score',
      expression: '20',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'flock',
      expression: '40',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'timer',
      expression: '40',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'shock',
      expression: '60',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'toncount',
      expression: '100',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'longhundred',
      expression: '120',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gross',
      expression: '144',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'greatgross',
      expression: '12 gross',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tithe',
      expression: '1|10',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'shortquire',
      expression: '24',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'quire',
      expression: '25',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'shortream',
      expression: '480',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ream',
      expression: '500',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'perfectream',
      expression: '516',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bundle',
      expression: '2 reams',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bale',
      expression: '5 bundles',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lettersize',
      expression: '8.5 inch 11 inch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'legalsize',
      expression: '8.5 inch 14 inch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ledgersize',
      expression: '11 inch 17 inch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'executivesize',
      expression: '7.25 inch 10.5 inch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'Apaper',
      expression: '8.5 inch 11 inch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'Bpaper',
      expression: '11 inch 17 inch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'Cpaper',
      expression: '17 inch 22 inch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'Dpaper',
      expression: '22 inch 34 inch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'Epaper',
      expression: '34 inch 44 inch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'envelope6_25size',
      expression: '3.5 inch 6 inch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'envelope6_75size',
      expression: '3.625 inch 6.5 inch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'envelope7size',
      expression: '3.75 inch 6.75 inch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'envelope7_75size',
      expression: '3.875 inch 7.5 inch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'envelope8_625size',
      expression: '3.625 inch 8.625 inch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'envelope9size',
      expression: '3.875 inch 8.875 inch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'envelope10size',
      expression: '4.125 inch 9.5 inch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'envelope11size',
      expression: '4.5 inch 10.375 inch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'envelope12size',
      expression: '4.75 inch 11 inch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'envelope14size',
      expression: '5 inch 11.5 inch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'envelope16size',
      expression: '6 inch 12 inch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'envelopeA1size',
      expression: '3.625 inch 5.125 inch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'envelopeA2size',
      expression: '4.375 inch 5.75 inch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'envelopeA6size',
      expression: '4.75 inch 6.5 inch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'envelopeA7size',
      expression: '5.25 inch 7.25 inch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'envelopeA8size',
      expression: '5.5 inch 8.125 inch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'envelopeA9size',
      expression: '5.75 inch 8.75 inch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'envelopeA10size',
      expression: '6 inch 9.5 inch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'envelope4bar',
      expression: '3.625 inch 5.125 inch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'envelope5_5bar',
      expression: '4.375 inch 5.75 inch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'envelope6bar',
      expression: '4.75 inch 6.5 inch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'envelope1baby',
      expression: '2.25 inch 3.5 inch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'envelope00coin',
      expression: '1.6875 inch 2.75 inch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'envelope1coin',
      expression: '2.25 inch 3.5 inch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'envelope3coin',
      expression: '2.5 inch 4.25 inch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'envelope4coin',
      expression: '3 inch 4.5 inch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'envelope4_5coin',
      expression: '3 inch 4.875 inch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'envelope5coin',
      expression: '2.875 inch 5.25 inch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'envelope5_5coin',
      expression: '3.125 inch 5.5 inch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'envelope6coin',
      expression: '3.375 inch 6 inch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'envelope7coin',
      expression: '3.5 inch 6.5 inch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'A0paper',
      expression: '841 mm 1189 mm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'A1paper',
      expression: '594 mm 841 mm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'A2paper',
      expression: '420 mm 594 mm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'A3paper',
      expression: '297 mm 420 mm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'A4paper',
      expression: '210 mm 297 mm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'A5paper',
      expression: '148 mm 210 mm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'A6paper',
      expression: '105 mm 148 mm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'A7paper',
      expression: '74 mm 105 mm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'A8paper',
      expression: '52 mm 74 mm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'A9paper',
      expression: '37 mm 52 mm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'A10paper',
      expression: '26 mm 37 mm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'B0paper',
      expression: '1000 mm 1414 mm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'B1paper',
      expression: '707 mm 1000 mm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'B2paper',
      expression: '500 mm 707 mm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'B3paper',
      expression: '353 mm 500 mm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'B4paper',
      expression: '250 mm 353 mm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'B5paper',
      expression: '176 mm 250 mm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'B6paper',
      expression: '125 mm 176 mm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'B7paper',
      expression: '88 mm 125 mm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'B8paper',
      expression: '62 mm 88 mm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'B9paper',
      expression: '44 mm 62 mm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'B10paper',
      expression: '31 mm 44 mm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'C0paper',
      expression: '917 mm 1297 mm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'C1paper',
      expression: '648 mm 917 mm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'C2paper',
      expression: '458 mm 648 mm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'C3paper',
      expression: '324 mm 458 mm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'C4paper',
      expression: '229 mm 324 mm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'C5paper',
      expression: '162 mm 229 mm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'C6paper',
      expression: '114 mm 162 mm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'C7paper',
      expression: '81 mm 114 mm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'C8paper',
      expression: '57 mm 81 mm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'C9paper',
      expression: '40 mm 57 mm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'C10paper',
      expression: '28 mm 40 mm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gsm',
      expression: 'grams / meter^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'poundbookpaper',
      aliases: [
        'lbbook',
        'poundtextpaper',
        'lbtext',
        'poundoffsetpaper',
        'lboffset',
        'poundbiblepaper',
        'lbbible',
      ],
      expression: 'lb / 25 inch 38 inch ream',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'poundtagpaper',
      aliases: [
        'lbtag',
        'poundbagpaper',
        'lbbag',
        'poundnewsprintpaper',
        'lbnewsprint',
        'poundposterpaper',
        'lbposter',
        'poundtissuepaper',
        'lbtissue',
        'poundwrappingpaper',
        'lbwrapping',
        'poundwaxingpaper',
        'lbwaxing',
        'poundglassinepaper',
        'lbglassine',
      ],
      expression: 'lb / 24 inch 36 inch ream',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'poundcoverpaper',
      aliases: ['lbcover'],
      expression: 'lb / 20 inch 26 inch ream',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'poundindexpaper',
      aliases: ['lbindex', 'poundindexbristolpaper', 'lbindexbristol'],
      expression: 'lb / 25.5 inch 30.5 inch ream',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'poundbondpaper',
      aliases: [
        'lbbond',
        'poundwritingpaper',
        'lbwriting',
        'poundledgerpaper',
        'lbledger',
        'poundcopypaper',
        'lbcopy',
      ],
      expression: 'lb / 17 inch 22 inch ream',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'poundblottingpaper',
      aliases: ['lbblotting'],
      expression: 'lb / 19 inch 24 inch ream',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'poundblankspaper',
      aliases: ['lbblanks'],
      expression: 'lb / 22 inch 28 inch ream',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'poundpostcardpaper',
      aliases: [
        'lbpostcard',
        'poundweddingbristol',
        'lbweddingbristol',
        'poundbristolpaper',
        'lbbristol',
      ],
      expression: 'lb / 22.5 inch 28.5 inch ream',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'poundboxboard',
      aliases: ['lbboxboard', 'poundpaperboard', 'lbpaperboard'],
      expression: 'lb / 1000 ft^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'paperM',
      expression: 'lb / 1000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'pointthickness',
      expression: '0.001 in',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'paperdensity',
      expression: '0.8 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'papercaliper',
      expression: 'in paperdensity',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'paperpoint',
      expression: 'pointthickness paperdensity',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'fournierpoint',
      expression: '0.1648 inch / 12',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'olddidotpoint',
      aliases: ['frenchprinterspoint'],
      expression: '1|72 frenchinch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bertholdpoint',
      expression: '1|2660 m',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'INpoint',
      expression: '0.4 mm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'germandidotpoint',
      aliases: ['didotpoint', 'europeanpoint'],
      expression: '0.376065 mm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'metricpoint',
      expression: '3|8 mm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'oldpoint',
      aliases: ['printerspoint', 'texpoint'],
      expression: '1|72.27 inch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'texscaledpoint',
      aliases: ['texsp'],
      expression: '1|65536 texpoint',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'computerpoint',
      aliases: ['point', 'postscriptpoint', 'pspoint'],
      expression: '1|72 inch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'computerpica',
      expression: '12 computerpoint',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'twip',
      expression: '1|20 point',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'Q',
      expression: '1|4 mm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cicero',
      expression: '12 didotpoint',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'stick',
      expression: '2 inches',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'excelsior',
      expression: '3 oldpoint',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'brilliant',
      expression: '3.5 oldpoint',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'diamondtype',
      expression: '4 oldpoint',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'pearl',
      expression: '5 oldpoint',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'agate',
      aliases: ['ruby'],
      expression: '5.5 oldpoint',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nonpareil',
      expression: '6 oldpoint',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mignonette',
      aliases: ['emerald'],
      expression: '6.5 oldpoint',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'minion',
      expression: '7 oldpoint',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'brevier',
      expression: '8 oldpoint',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bourgeois',
      expression: '9 oldpoint',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'longprimer',
      expression: '10 oldpoint',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'smallpica',
      expression: '11 oldpoint',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'pica',
      expression: '12 oldpoint',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'english',
      expression: '14 oldpoint',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'columbian',
      expression: '16 oldpoint',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'greatprimer',
      expression: '18 oldpoint',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'paragon',
      expression: '20 oldpoint',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'meridian',
      expression: '44 oldpoint',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'canon',
      expression: '48 oldpoint',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nonplusultra',
      expression: '2 didotpoint',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'brillant',
      expression: '3 didotpoint',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'diamant',
      expression: '4 didotpoint',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'perl',
      expression: '5 didotpoint',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nonpareille',
      expression: '6 didotpoint',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'kolonel',
      expression: '7 didotpoint',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'petit',
      expression: '8 didotpoint',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'borgis',
      expression: '9 didotpoint',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'korpus',
      aliases: ['corpus', 'garamond'],
      expression: '10 didotpoint',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mittel',
      expression: '14 didotpoint',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tertia',
      expression: '16 didotpoint',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'text',
      expression: '18 didotpoint',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'kleine_kanon',
      expression: '32 didotpoint',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'kanon',
      expression: '36 didotpoint',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'grobe_kanon',
      expression: '42 didotpoint',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'missal',
      expression: '48 didotpoint',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'kleine_sabon',
      expression: '72 didotpoint',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'grobe_sabon',
      expression: '84 didotpoint',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nat',
      expression: '(1/ln(2)) bits',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hartley',
      aliases: ['ban', 'dit'],
      expression: 'log2(10) bits',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bps',
      expression: 'bit/sec',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'byte',
      aliases: ['B'],
      expression: '8 bit',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'octet',
      expression: '8 bits',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nybble',
      aliases: ['nibble'],
      expression: '4 bits',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nyp',
      expression: '2 bits',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'meg',
      expression: 'megabyte',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gig',
      expression: 'gigabyte',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'jiffy',
      aliases: ['jiffies'],
      expression: '0.01 sec',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cdaudiospeed',
      expression: '44.1 kHz 2*16 bits',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cdromspeed',
      expression: '75 2048 bytes / sec',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'dvdspeed',
      expression: '1385 kB/s',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'FIT',
      expression: '/ 1e9 hour',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ipv4classA',
      expression: 'ipv4subnetsize(8)',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ipv4classB',
      expression: 'ipv4subnetsize(16)',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ipv4classC',
      expression: 'ipv4subnetsize(24)',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'octave',
      expression: '2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'majorsecond',
      expression: 'musicalfifth^2 / octave',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'majorthird',
      expression: '5|4',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'minorthird',
      expression: '6|5',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'musicalfourth',
      expression: '4|3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'musicalfifth',
      expression: '3|2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'majorsixth',
      expression: 'musicalfourth majorthird',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'minorsixth',
      expression: 'musicalfourth minorthird',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'majorseventh',
      expression: 'musicalfifth majorthird',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'minorseventh',
      expression: 'musicalfifth minorthird',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'pythagoreanthird',
      expression: 'majorsecond musicalfifth^2 / octave',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'syntoniccomma',
      expression: 'pythagoreanthird / majorthird',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'pythagoreancomma',
      expression: 'musicalfifth^12 / octave^7',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'semitone',
      expression: 'octave^(1|12)',
    ),
  );
  repo.register(
    const PrimitiveUnit(
      id: 'wholenote',
      aliases: ['MUSICAL_NOTE_LENGTH', 'semibreve'],
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'halfnote',
      aliases: ['minimnote'],
      expression: '1|2 wholenote',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'quarternote',
      aliases: ['crotchet'],
      expression: '1|4 wholenote',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'eighthnote',
      aliases: ['quaver'],
      expression: '1|8 wholenote',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sixteenthnote',
      aliases: ['semiquaver'],
      expression: '1|16 wholenote',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thirtysecondnote',
      aliases: ['demisemiquaver'],
      expression: '1|32 wholenote',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sixtyfourthnote',
      aliases: ['hemidemisemiquaver', 'semidemisemiquaver'],
      expression: '1|64 wholenote',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'dotted',
      expression: '3|2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'doubledotted',
      expression: '7|4',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'breve',
      expression: 'doublewholenote',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'woolyarnrun',
      expression: '1600 yard/pound',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'yarncut',
      expression: '300 yard/pound',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cottonyarncount',
      expression: '840 yard/pound',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'linenyarncount',
      expression: '300 yard/pound',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'worstedyarncount',
      expression: '1680 ft/pound',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'metricyarncount',
      expression: 'meter/gram',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'denier',
      expression: '1|9 tex',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'manchesteryarnnumber',
      expression: 'drams/1000 yards',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'pli',
      expression: 'lb/in',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'typp',
      expression: '1000 yd/lb',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'asbestoscut',
      expression: '100 yd/lb',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tex',
      expression: 'gram / km',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'drex',
      expression: '0.1 tex',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'poumar',
      expression: 'lb / 1e6 yard',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'skeincotton',
      expression: '80*54 inch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cottonbolt',
      aliases: ['bolt'],
      expression: '120 ft',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'woolbolt',
      expression: '210 ft',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'heer',
      expression: '600 yards',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cut',
      expression: '300 yards',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lea',
      expression: '300 yards',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sailmakersyard',
      expression: '28.5 in',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sailmakersounce',
      expression: 'oz / sailmakersyard 36 inch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'silkmomme',
      aliases: ['silkmm'],
      expression: 'momme / 25 yards 1.49 inch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mcg',
      expression: 'microgram',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iudiptheria',
      expression: '62.8 microgram',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iupenicillin',
      expression: '0.6 microgram',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iuinsulin',
      expression: '41.67 microgram',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'drop',
      expression: '1|20 ml',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bloodunit',
      expression: '450 ml',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'frenchcathetersize',
      aliases: ['charriere'],
      expression: '1|3 mm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hectare',
      aliases: ['hektare'],
      expression: 'hectoare',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'decare',
      aliases: ['dekare', 'stremma', 'dunam', 'dulum', 'donum', 'dönüm', 'mål'],
      expression: 'dekaare',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'megohm',
      expression: 'megaohm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'kilohm',
      expression: 'kiloohm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'microhm',
      expression: 'microohm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'megalerg',
      expression: 'megaerg',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'austriaschilling',
      aliases: ['ATS'],
      expression: '1|13.7603 euro',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'belgiumfranc',
      aliases: ['BEF'],
      expression: '1|40.3399 euro',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cypruspound',
      aliases: ['CYP'],
      expression: '1|0.585274 euro',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'estoniakroon',
      aliases: ['EEK'],
      expression: '1|15.6466 euro',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'finlandmarkka',
      aliases: ['markka', 'FIM'],
      expression: '1|5.94573 euro',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'francefranc',
      aliases: ['franc', 'FRF', '₣'],
      expression: '1|6.55957 euro',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'germanymark',
      aliases: ['mark', 'DEM'],
      expression: '1|1.95583 euro',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'greecedrachma',
      aliases: ['drachma', 'GRD', '₯'],
      expression: '1|340.75 euro',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'irelandpunt',
      aliases: ['IEP'],
      expression: '1|0.787564 euro',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'italylira',
      aliases: ['ITL'],
      expression: '1|1936.27 euro',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'latvialats',
      aliases: ['LVL'],
      expression: '1|0.702804 euro',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lithuanialitas',
      aliases: ['LTL'],
      expression: '1|3.4528 euro',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'luxembourgfranc',
      aliases: ['LUF'],
      expression: '1|40.3399 euro',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'maltalira',
      aliases: ['MTL'],
      expression: '1|0.4293 euro',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'slovakiakoruna',
      aliases: ['SKK'],
      expression: '1|30.1260 euro',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sloveniatolar',
      aliases: ['SIT'],
      expression: '1|239.640 euro',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'spainpeseta',
      aliases: ['peseta', 'ESP', '₧'],
      expression: '1|166.386 euro',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'netherlandsguilder',
      aliases: ['guilder', 'hollandguilder', 'NLG'],
      expression: '1|2.20371 euro',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'portugalescudo',
      aliases: ['escudo', 'PTE'],
      expression: '1|200.482 euro',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'capeverdeescudo',
      aliases: ['CVE'],
      expression: '1|95.000562 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bulgarialev',
      aliases: ['BGN'],
      expression: '1|1.628166 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bosniaconvertiblemark',
      aliases: ['BAM'],
      expression: '1|1.685076 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'comorosfranc',
      aliases: ['KMF'],
      expression: '1|423.862627 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'westafricafranc',
      aliases: ['XOF'],
      expression: '1|655.957 euro',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cfpfranc',
      aliases: ['XPF'],
      expression: '1|119.33 euro',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'centralafricacfafranc',
      aliases: ['XAF'],
      expression: '1|565.15017 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'uaedirham',
      aliases: ['AED'],
      expression: '1|3.6725 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'afghanistanafghani',
      aliases: ['AFN'],
      expression: '1|66.013611 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'albanialek',
      aliases: ['ALL'],
      expression: '1|83.001612 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'armeniadram',
      aliases: ['AMD'],
      expression: '1|379.929976 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'antillesguilder',
      aliases: ['ANG'],
      expression: '1|1.79 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'angolakwanza',
      aliases: ['AOA'],
      expression: '1|921.106491 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'argentinapeso',
      aliases: ['ARS'],
      expression: '1|1452.25 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'australiadollar',
      aliases: ['AUD', 'KID', 'TVD', 'kiribatidollar', 'tuvaludollar'],
      expression: '1|1.495527 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'arubaflorin',
      aliases: ['AWG'],
      expression: '1|1.79 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'azerbaijanmanat',
      aliases: ['AZN'],
      expression: '1|1.700327 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'barbadosdollar',
      aliases: ['BBD'],
      expression: '1|2 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bangladeshtaka',
      aliases: ['BDT'],
      expression: '1|122.272083 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bahraindinar',
      aliases: ['BHD'],
      expression: '1|0.376 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'burundifranc',
      aliases: ['BIF'],
      expression: '1|2969.643677 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bermudadollar',
      aliases: ['BMD'],
      expression: '1|1 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bruneidollar',
      aliases: ['BND'],
      expression: '1|1.288648 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'boliviaboliviano',
      aliases: ['BOB'],
      expression: '1|6.930268 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'brazilreal',
      aliases: ['BRL'],
      expression: '1|5.37229 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bahamasdollar',
      aliases: ['BSD'],
      expression: '1|1 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bhutanngultrum',
      aliases: ['BTN'],
      expression: '1|90.735263 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'botswanapula',
      aliases: ['BWP'],
      expression: '1|14.009281 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'belarusruble',
      aliases: ['BYN'],
      expression: '1|2.907469 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'oldbelarusruble',
      aliases: ['BYR'],
      expression: '1|10000 BYN',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'belizedollar',
      aliases: ['BZD'],
      expression: '1|2 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'canadadollar',
      aliases: ['CAD'],
      expression: '1|1.390893 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'drcfranccongolais',
      aliases: ['CDF'],
      expression: '1|2232.051304 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'swissfranc',
      aliases: ['CHF'],
      expression: '1|0.802772 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'chilepeso',
      aliases: ['CLP'],
      expression: '1|882.729872 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'chinayuan',
      aliases: ['yuan', 'CNY'],
      expression: '1|6.984368 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'colombiapeso',
      aliases: ['COP'],
      expression: '1|3671.773168 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'costaricacolon',
      aliases: ['CRC', '₡'],
      expression: '1|495.791715 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cubapeso',
      aliases: ['CUP'],
      expression: '1|24 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'czechiakoruna',
      aliases: ['CZK'],
      expression: '1|20.916922 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'djiboutifranc',
      aliases: ['DJF'],
      expression: '1|177.721 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'denmarkkrone',
      aliases: ['DKK', 'FOK', 'faroeislandskróna'],
      expression: '1|6.428595 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'dominicanrepublicpeso',
      aliases: ['DOP'],
      expression: '1|63.73713 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'algeriadinar',
      aliases: ['DZD'],
      expression: '1|130.100881 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'egyptpound',
      aliases: ['EGP'],
      expression: '1|47.276692 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'eritreanakfa',
      aliases: ['ERN'],
      expression: '1|15 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ethiopiabirr',
      aliases: ['ETB'],
      expression: '1|154.500543 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'euro',
      aliases: ['EUR', '€'],
      expression: '1|0.861567 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'fijidollar',
      aliases: ['FJD'],
      expression: '1|2.279756 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'falklandislandspound',
      aliases: ['FKP'],
      expression: '1|0.746976 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ukpound',
      aliases: [
        'britainpound',
        'greatbritainpound',
        'unitedkingdompound',
        'poundsterling',
        'UKP',
        'GBP',
        'GGP',
        'IMP',
        'JEP',
        'guernseypound',
        'isleofmanpound',
        'jerseypound',
        'quid',
        '£',
        '￡',
      ],
      expression: '1|0.746949 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'georgialari',
      aliases: ['GEL'],
      expression: '1|2.695262 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ghanacedi',
      aliases: ['GHS'],
      expression: '1|10.846904 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gibraltarpound',
      aliases: ['GIP'],
      expression: '1|0.746976 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gambiadalasi',
      aliases: ['GMD'],
      expression: '1|74.000717 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'guineafranc',
      aliases: ['GNF'],
      expression: '1|8751.731051 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'guatemalaquetzal',
      aliases: ['GTQ'],
      expression: '1|7.669491 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'guyanadollar',
      aliases: ['GYD'],
      expression: '1|209.174648 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hongkongdollar',
      aliases: ['HKD'],
      expression: '1|7.798338 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'honduraslempira',
      aliases: ['HNL'],
      expression: '1|26.392445 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'croatiakuna',
      aliases: ['HRK'],
      expression: '1|6.491468 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'haitigourde',
      aliases: ['HTG'],
      expression: '1|130.952919 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hungaryforint',
      aliases: ['HUF'],
      expression: '1|331.937504 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'indonesiarupiah',
      aliases: ['IDR'],
      expression: '1|16922.779217 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'israelnewshekel',
      aliases: ['ILS', '₪'],
      expression: '1|3.144652 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'indiarupee',
      aliases: ['rupee', 'INR', '₨'],
      expression: '1|90.75459 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iraqdinar',
      aliases: ['IQD'],
      expression: '1|1311.330006 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iranrial',
      aliases: ['IRR', '﷼'],
      expression: '1|144946.759588 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'icelandkrona',
      aliases: ['icelandkróna', 'ISK'],
      expression: '1|125.967226 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'jamaicadollar',
      aliases: ['JMD'],
      expression: '1|157.564305 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'jordandinar',
      aliases: ['JOD'],
      expression: '1|0.709 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'japanyen',
      aliases: ['yen', 'JPY', '¥', '￥'],
      expression: '1|158.153086 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'kenyaschilling',
      aliases: ['KES'],
      expression: '1|128.995752 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'kyrgyzstansom',
      aliases: ['KGS'],
      expression: '1|87.43013 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cambodiariel',
      aliases: ['KHR'],
      expression: '1|4024.473523 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'southkoreawon',
      aliases: ['KRW', '₩', '￦'],
      expression: '1|1472.865907 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'kuwaitdinar',
      aliases: ['KWD'],
      expression: '1|0.30773 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'caymanislandsdollar',
      aliases: ['KYD'],
      expression: '1|0.833333 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'kazakhstantenge',
      aliases: ['KZT'],
      expression: '1|510.653154 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'laokip',
      aliases: ['LAK', '₭'],
      expression: '1|21725.336647 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lebanonpound',
      aliases: ['LBP'],
      expression: '1|89500 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'srilankarupee',
      aliases: ['LKR'],
      expression: '1|309.519989 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'liberiadollar',
      aliases: ['LRD'],
      expression: '1|180.076844 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lesotholoti',
      aliases: ['LSL'],
      expression: '1|16.399952 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'libyadinar',
      aliases: ['LYD'],
      expression: '1|5.433049 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'moroccodirham',
      aliases: ['MAD'],
      expression: '1|9.225812 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'moldovaleu',
      aliases: ['MDL'],
      expression: '1|17.119528 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'madagascarariary',
      aliases: ['MGA'],
      expression: '1|4624.896064 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'macedoniadenar',
      aliases: ['MKD'],
      expression: '1|52.916747 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'myanmarkyat',
      aliases: ['MMK'],
      expression: '1|2098.381195 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mongoliatugrik',
      aliases: ['mongoliatögrög', 'MNT', '₮'],
      expression: '1|3590.660037 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'macaupataca',
      aliases: ['MOP'],
      expression: '1|8.032288 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mauritaniaoldouguiya',
      aliases: ['MRO'],
      expression: '1|10 MRU',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mauritaniaouguiya',
      aliases: ['MRU'],
      expression: '1|39.870311 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mauritiusrupee',
      aliases: ['MUR'],
      expression: '1|46.193512 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'maldiverufiyaa',
      aliases: ['MVR'],
      expression: '1|15.450075 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'malawikwacha',
      aliases: ['MWK'],
      expression: '1|1745.679464 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mexicopeso',
      aliases: ['peso', 'MXN'],
      expression: '1|17.653023 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'malaysiaringgit',
      aliases: ['MYR'],
      expression: '1|4.056835 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mozambiquemetical',
      aliases: ['MZN'],
      expression: '1|63.669477 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'namibiadollar',
      aliases: ['NAD'],
      expression: '1|16.399952 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nigerianaira',
      aliases: ['NGN', '₦'],
      expression: '1|1418.883199 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nicaraguacordobaoro',
      aliases: ['NIO'],
      expression: '1|36.817288 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'norwaykrone',
      aliases: ['NOK'],
      expression: '1|10.091705 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nepalrupee',
      aliases: ['NPR'],
      expression: '1|145.17642 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'newzealanddollar',
      aliases: ['NZD'],
      expression: '1|1.738401 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'omanrial',
      aliases: ['OMR'],
      expression: '1|0.384497 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'panamabalboa',
      aliases: ['PAB'],
      expression: '1|1 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'perunuevosol',
      aliases: ['PEN'],
      expression: '1|3.359954 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'papuanewguineakina',
      aliases: ['PGK'],
      expression: '1|4.268933 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'philippinepeso',
      aliases: ['PHP', '₱'],
      expression: '1|59.427214 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'pakistanrupee',
      aliases: ['PKR'],
      expression: '1|281.991114 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'polandzloty',
      aliases: ['polandzłoty', 'PLN'],
      expression: '1|3.633973 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'paraguayguarani',
      aliases: ['PYG'],
      expression: '1|6770.040137 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'qatarrial',
      aliases: ['QAR'],
      expression: '1|3.64 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'romanianewlei',
      aliases: ['RON'],
      expression: '1|4.384557 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'serbiadinar',
      aliases: ['RSD'],
      expression: '1|100.98223 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'russiaruble',
      aliases: ['RUB'],
      expression: '1|78.010574 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rwandafranc',
      aliases: ['RWF'],
      expression: '1|1459.673436 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'saudiarabiariyal',
      aliases: ['SAR'],
      expression: '1|3.75 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'solomonislandsdollar',
      aliases: ['SBD'],
      expression: '1|8.034816 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'seychellesrupee',
      aliases: ['SCR'],
      expression: '1|13.844911 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sudanpound',
      aliases: ['SDG'],
      expression: '1|510.878322 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'swedenkrona',
      aliases: ['SEK'],
      expression: '1|9.229196 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'singaporedollar',
      aliases: ['SGD'],
      expression: '1|1.288648 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sainthelenapound',
      aliases: ['SHP'],
      expression: '1|0.746976 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'somaliaschilling',
      aliases: ['SOS'],
      expression: '1|570.493871 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'surinamedollar',
      aliases: ['SRD'],
      expression: '1|38.2395 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'southsudanpound',
      aliases: ['SSP'],
      expression: '1|4689.186929 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'saotome&principedobra',
      aliases: ['sãotomé&príncipedobra', 'STN'],
      expression: '1|21.108364 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'syriapound',
      aliases: ['SYP'],
      expression: '1|114.049474 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'swazilandlilangeni',
      aliases: ['SZL'],
      expression: '1|16.399952 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thailandbaht',
      aliases: ['THB', '฿'],
      expression: '1|31.436994 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tajikistansomoni',
      aliases: ['TJS'],
      expression: '1|9.309428 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'turkmenistanmanat',
      aliases: ['TMT'],
      expression: '1|3.499775 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tunisiadinar',
      aliases: ['TND'],
      expression: '1|2.895405 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tongapa\'anga',
      aliases: ['tongapa’anga', 'TOP'],
      expression: '1|2.38796 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'turkeylira',
      aliases: ['lira', 'TRY', '₤'],
      expression: '1|43.264872 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'trinidadandtobagodollar',
      aliases: ['TTD'],
      expression: '1|6.75783 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'taiwandollar',
      aliases: ['TWD'],
      expression: '1|31.578125 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tanzaniashilling',
      aliases: ['TZS'],
      expression: '1|2472.456193 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ukrainehryvnia',
      aliases: ['UAH'],
      expression: '1|43.43695 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ugandaschilling',
      aliases: ['UGX'],
      expression: '1|3508.807564 USD',
    ),
  );
  repo.register(
    const PrimitiveUnit(
      id: 'US\$',
      aliases: [
        'MONEY',
        'buck',
        'greenback',
        'unitedstatesdollar',
        'usdollar',
        '\$',
        'USD',
        'dollar',
        '﹩',
      ],
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'uruguaypeso',
      aliases: ['UYU'],
      expression: '1|38.711456 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'uzbekistansum',
      aliases: ['UZS'],
      expression: '1|12010.746871 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'venezuelabolivarsoberano',
      aliases: ['VES'],
      expression: '1|344.5071 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'vietnamdong',
      aliases: ['vietnamđồng', 'VND', '₫'],
      expression: '1|26225.120878 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'vanuatuvatu',
      aliases: ['VUV'],
      expression: '1|120.507219 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'samoatala',
      aliases: ['WST'],
      expression: '1|2.754873 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'eastcaribbeandollar',
      aliases: ['XCD'],
      expression: '1|2.7 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'specialdrawingrights',
      aliases: ['XDR'],
      expression: '1|0.732856 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'yemenrial',
      aliases: ['YER'],
      expression: '1|238.447524 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'southafricarand',
      aliases: ['rand', 'ZAR'],
      expression: '1|16.399987 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'zambiakwacha',
      aliases: ['ZMW'],
      expression: '1|19.982927 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'zimbabwedollar',
      aliases: ['ZWL'],
      expression: '1|25.6057 USD',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bitcoin',
      aliases: ['XBT'],
      expression: '95431.16 US\$',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'silverprice',
      expression: '92.42 US\$/troyounce',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'goldprice',
      expression: '4616.49 US\$/troyounce',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'platinumprice',
      expression: '2416.27 US\$/troyounce',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'olddollargold',
      expression: '23.22 grains goldprice',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'newdollargold',
      aliases: ['dollargold'],
      expression: '96|7 grains goldprice',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'poundgold',
      expression: '113 grains goldprice',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'goldounce',
      aliases: ['XAU'],
      expression: 'goldprice troyounce',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'silverounce',
      aliases: ['XAG'],
      expression: 'silverprice troyounce',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'platinumounce',
      aliases: ['XPT'],
      expression: 'platinumprice troyounce',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'USpennyweight',
      expression: '2.5 grams',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'USnickelweight',
      expression: '5 grams',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'USdimeweight',
      expression: 'US\$ 0.10 / (20 US\$ / lb)',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'USquarterweight',
      expression: 'US\$ 0.25 / (20 US\$ / lb)',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'UShalfdollarweight',
      expression: 'US\$ 0.50 / (20 US\$ / lb)',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'USdollarweight',
      expression: '8.1 grams',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'fiver',
      expression: '5 quid',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tenner',
      expression: '10 quid',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'monkey',
      expression: '500 quid',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'brgrand',
      expression: '1000 quid',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'shilling',
      aliases: ['bob'],
      expression: '1|20 britainpound',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'oldpence',
      aliases: ['oldpenny'],
      expression: '1|12 shilling',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'farthing',
      expression: '1|4 oldpence',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'guinea',
      expression: '21 shilling',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'crown',
      expression: '5 shilling',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'florin',
      expression: '2 shilling',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'groat',
      expression: '4 oldpence',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tanner',
      expression: '6 oldpence',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'brpenny',
      aliases: ['pence'],
      expression: '0.01 britainpound',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tuppence',
      aliases: ['tuppenny'],
      expression: '2 pence',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ha\'penny',
      aliases: ['hapenny'],
      expression: 'halfbrpenny',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'oldtuppence',
      aliases: ['oldtuppenny'],
      expression: '2 oldpence',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'threepence',
      aliases: ['threepenny', 'oldthreepence', 'oldthreepenny'],
      expression: '3 oldpence',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'oldhalfpenny',
      aliases: ['oldha\'penny', 'oldhapenny'],
      expression: 'halfoldpenny',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'brpony',
      expression: '25 britainpound',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'loony',
      expression: '1 canadadollar',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'toony',
      expression: '2 canadadollar',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'satoshi',
      expression: '1e-8 bitcoin',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'UScpi_now',
      aliases: ['USCPI_now', 'cpi_now', 'CPI_now'],
      expression: '324.122',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'UScpi_lastdate',
      aliases: ['USCPI_lastdate', 'cpi_lastdate', 'CPI_lastdate'],
      expression: '2025.9166666666667',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cord',
      expression: '4*4*8 ft^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'facecord',
      expression: '1|2 cord',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cordfoot',
      aliases: ['cordfeet'],
      expression: '1|8 cord',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'housecord',
      expression: '1|3 cord',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'boardfoot',
      aliases: ['boardfeet', 'fbm'],
      expression: 'ft^2 inch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'stack',
      expression: '4 yard^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rick',
      expression: '4 ft 8 ft 16 inches',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'stere',
      expression: 'm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'timberfoot',
      expression: 'ft^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'standard',
      expression: '120 12 ft 11 in 1.5 in',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hoppusfoot',
      expression: '(4/pi) ft^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hoppusboardfoot',
      expression: '1|12 hoppusfoot',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hoppuston',
      expression: '50 hoppusfoot',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'deal',
      expression: '12 ft 11 in 2.5 in',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wholedeal',
      expression: '12 ft 11 in 1.25 in',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'splitdeal',
      expression: '12 ft 11 in 5|8 in',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'poundcut',
      aliases: ['lbcut'],
      expression: 'pound / gallon',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'FLUID_FLOW',
      expression: 'VOLUME / TIME',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cumec',
      expression: 'm^3/s',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cusec',
      expression: 'ft^3/s',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gph',
      expression: 'gal/hr',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gpm',
      expression: 'gal/min',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mgd',
      expression: 'megagal/day',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'brgph',
      expression: 'brgallon/hr',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'brgpm',
      expression: 'brgallon/min',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'brmgd',
      expression: 'mega brgallon/day',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'usgph',
      expression: 'usgallon/hr',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'usgpm',
      expression: 'usgallon/min',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'usmgd',
      expression: 'mega usgallon/day',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cfs',
      expression: 'ft^3/s',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cfh',
      expression: 'ft^3/hour',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cfm',
      expression: 'ft^3/min',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lpm',
      expression: 'liter/min',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lfm',
      expression: 'ft/min',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'pru',
      expression: 'mmHg / (ml/min)',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'viscosity_mercury',
      expression: '1.526 mPa s',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'viscosity_milk',
      expression: '2.12 mPa s',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'viscosity_oliveoil',
      expression: '56.2 mPa s',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'minersinchAZ',
      expression: '1.5 ft^3/min',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'minersinchCA',
      expression: '1.5 ft^3/min',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'minersinchMT',
      expression: '1.5 ft^3/min',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'minersinchNV',
      expression: '1.5 ft^3/min',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'minersinchOR',
      expression: '1.5 ft^3/min',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'minersinchID',
      expression: '1.2 ft^3/min',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'minersinchKS',
      expression: '1.2 ft^3/min',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'minersinchNE',
      expression: '1.2 ft^3/min',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'minersinchNM',
      expression: '1.2 ft^3/min',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'minersinchND',
      expression: '1.2 ft^3/min',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'minersinchSD',
      expression: '1.2 ft^3/min',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'minersinchUT',
      expression: '1.2 ft^3/min',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'minersinchCO',
      expression: '1 ft^3/sec / 38.4',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'minersinchBC',
      expression: '1.68 ft^3/min',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sverdrup',
      expression: '1e6 m^3 / sec',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'GAS_FLOW',
      expression: 'PRESSURE FLUID_FLOW',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sccm',
      expression: 'atm cc/min',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sccs',
      expression: 'atm cc/sec',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'scfh',
      expression: 'atm ft^3/hour',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'scfm',
      expression: 'atm ft^3/min',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'slpm',
      expression: 'atm liter/min',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'slph',
      expression: 'atm liter/hour',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lusec',
      expression: 'liter micron Hg / s',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lapserate',
      expression: '6.5 K/km',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'air_1976',
      expression:
          '78.084 % 28.0134 + 20.9476 % 31.9988 + 9340 ppm 39.948 + 314 ppm 44.00995 + 18.18 ppm 20.183 + 5.24 ppm 4.0026 + 1.5 ppm 16.04303 + 1.14 ppm 83.80 + 0.5 ppm 2.01594 + 0.27 ppm 44.0128 + 0.087 ppm 131.30',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'air_1962',
      expression:
          '78.084 % 28.0134 + 20.9476 % 31.9988 + 9340 ppm 39.948 + 314 ppm 44.00995 + 18.18 ppm 20.183 + 5.24 ppm 4.0026 + 2 ppm 16.04303 + 1.14 ppm 83.80 + 0.5 ppm 2.01594 + 0.5 ppm 44.0128 + 0.087 ppm 131.30',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'air_2023',
      aliases: ['air'],
      expression:
          '78.08% nitrogen 2 + 20.95% oxygen 2 + 9340 ppm argon + 419 ppm (carbon + oxygen 2) + 18.18 ppm neon + 5.24 ppm helium + 1.92 ppm (carbon + 4 hydrogen) + 1.14 ppm krypton + 0.55 ppm hydrogen 2 + 0.34 ppm (nitrogen 2 + oxygen)',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'air_2015',
      expression:
          '78.08% nitrogen 2 + 20.95% oxygen 2 + 9340 ppm argon + 400 ppm (carbon + oxygen 2) + 18.18 ppm neon + 5.24 ppm helium + 1.7 ppm (carbon + 4 hydrogen) + 1.14 ppm krypton + 0.55 ppm hydrogen 2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'R_1976',
      expression: '8.31432e3 N m/(kmol K)',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'polyndx_1976',
      aliases: ['polyndx'],
      expression: 'air_1976 (kg/kmol) gravity/(R_1976 lapserate) - 1',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'polyexpnt',
      expression: '(polyndx + 1) / polyndx',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'stdatmT0',
      expression: '288.15 K',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'earthradUSAtm',
      expression: '6356766 m',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'seawater',
      expression: '0.1 bar / meter',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'msw',
      expression: 'meter seawater',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'fsw',
      expression: 'foot seawater',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'g0',
      expression: '(0)',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'g00',
      expression: '(-1)',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'g000',
      expression: '(-2)',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'g0000',
      expression: '(-3)',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'g00000',
      expression: '(-4)',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'g000000',
      expression: '(-5)',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'g0000000',
      expression: '(-6)',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'g1_0',
      expression: '(-1)',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'g2_0',
      expression: '(-1)',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'g3_0',
      expression: '(-2)',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'g4_0',
      expression: '(-3)',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'g5_0',
      expression: '(-4)',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'g6_0',
      expression: '(-5)',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'g7_0',
      expression: '(-6)',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'drillA',
      expression: '0.234 in',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'drillB',
      expression: '0.238 in',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'drillC',
      expression: '0.242 in',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'drillD',
      expression: '0.246 in',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'drillE',
      expression: '0.250 in',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'drillF',
      expression: '0.257 in',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'drillG',
      expression: '0.261 in',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'drillH',
      expression: '0.266 in',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'drillI',
      expression: '0.272 in',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'drillJ',
      expression: '0.277 in',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'drillK',
      expression: '0.281 in',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'drillL',
      expression: '0.290 in',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'drillM',
      expression: '0.295 in',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'drillN',
      expression: '0.302 in',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'drillO',
      expression: '0.316 in',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'drillP',
      expression: '0.323 in',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'drillQ',
      expression: '0.332 in',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'drillR',
      expression: '0.339 in',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'drillS',
      expression: '0.348 in',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'drillT',
      expression: '0.358 in',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'drillU',
      expression: '0.368 in',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'drillV',
      expression: '0.377 in',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'drillW',
      expression: '0.386 in',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'drillX',
      expression: '0.397 in',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'drillY',
      expression: '0.404 in',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'drillZ',
      expression: '0.413 in',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'dmtxxcoarse',
      aliases: ['dmtsilver', 'dmtxx'],
      expression: '120 micron',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'dmtxcoarse',
      aliases: ['dmtx', 'dmtblack'],
      expression: '60 micron',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'dmtcoarse',
      aliases: ['dmtc', 'dmtblue'],
      expression: '45 micron',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'dmtfine',
      aliases: ['dmtred', 'dmtf'],
      expression: '25 micron',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'dmtefine',
      aliases: ['dmte', 'dmtgreen'],
      expression: '9 micron',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'dmtceramic',
      aliases: ['dmtcer', 'dmtwhite'],
      expression: '7 micron',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'dmteefine',
      aliases: ['dmttan', 'dmtee'],
      expression: '3 micron',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hardtranslucentarkansas',
      expression: '6 micron',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'softarkansas',
      expression: '22 micron',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'extrafineindia',
      expression: '22 micron',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'fineindia',
      expression: '35 micron',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mediumindia',
      expression: '53.5 micron',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'coarseindia',
      expression: '97 micron',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'finecrystolon',
      expression: '45 micron',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mediumcrystalon',
      expression: '78 micron',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'coarsecrystalon',
      expression: '127 micron',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hardblackarkansas',
      expression: '6 micron',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hardwhitearkansas',
      expression: '11 micron',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'washita',
      expression: '35 micron',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sizeAring',
      expression: '37.50 mm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sizeBring',
      expression: '38.75 mm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sizeCring',
      expression: '40.00 mm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sizeDring',
      expression: '41.25 mm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sizeEring',
      expression: '42.50 mm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sizeFring',
      expression: '43.75 mm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sizeGring',
      expression: '45.00 mm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sizeHring',
      expression: '46.25 mm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sizeIring',
      expression: '47.50 mm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sizeJring',
      expression: '48.75 mm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sizeKring',
      expression: '50.00 mm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sizeLring',
      expression: '51.25 mm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sizeMring',
      expression: '52.50 mm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sizeNring',
      expression: '53.75 mm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sizeOring',
      expression: '55.00 mm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sizePring',
      expression: '56.25 mm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sizeQring',
      expression: '57.50 mm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sizeRring',
      expression: '58.75 mm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sizeSring',
      expression: '60.00 mm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sizeTring',
      expression: '61.25 mm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sizeUring',
      expression: '62.50 mm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sizeVring',
      expression: '63.75 mm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sizeWring',
      expression: '65.00 mm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sizeXring',
      expression: '66.25 mm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sizeYring',
      expression: '67.50 mm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sizeZring',
      expression: '68.75 mm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mph',
      expression: 'mile/hr',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'brmpg',
      expression: 'mile/brgallon',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'usmpg',
      expression: 'mile/usgallon',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mpg',
      expression: 'mile/gal',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'kph',
      expression: 'km/hr',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'fpm',
      expression: 'ft/min',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'fps',
      expression: 'ft/s',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rpm',
      expression: 'rev/min',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rps',
      expression: 'rev/sec',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mbh',
      expression: '1e3 btu/hour',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mcm',
      expression: '1e3 circularmil',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ipy',
      expression: 'inch/year',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ccf',
      expression: '100 ft^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'Mcf',
      expression: '1000 ft^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'kp',
      expression: 'kilopond',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'kpm',
      expression: 'kp meter',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'Wh',
      expression: 'W hour',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hph',
      expression: 'hp hour',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'plf',
      expression: 'lb / foot',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mh',
      expression: 'mH',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'pf',
      expression: 'pF',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'dry',
      expression: 'drygallon/gallon',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'beV',
      aliases: ['bev'],
      expression: 'GeV',
    ),
  );
  repo.register(
    const PrimitiveUnit(
      id: 'event',
      isDimensionless: true,
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'becquerel',
      aliases: ['Bq', '㏃'],
      expression: 'event /s',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'curie',
      aliases: ['Ci'],
      expression: '3.7e10 Bq',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rutherford',
      expression: '1e6 Bq',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gray',
      aliases: ['RADIATION_DOSE', 'Gy', '㏉'],
      expression: 'J/kg',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rad',
      aliases: ['㎭'],
      expression: '1e-2 Gy',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rep',
      expression: '8.38 mGy',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sievert',
      aliases: ['Sv', '㏜'],
      expression: 'J/kg',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rem',
      expression: '1e-2 Sv',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'banana_dose',
      expression: '0.1e-6 sievert',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'roentgen',
      aliases: ['rontgen', 'röntgen'],
      expression: '2.58e-4 C / kg',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sievertunit',
      expression: '8.38 rontgen',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'eman',
      expression: '1e-7 Ci/m^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mache',
      expression: '3.7e-7 Ci/m^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hydrogen_1',
      expression: '1.0078250322',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hydrogen_2',
      expression: '2.0141017781',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hydrogen_3',
      expression: '3.0160492779',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hydrogen_4',
      expression: '4.0264300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hydrogen_5',
      expression: '5.0353110000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hydrogen_6',
      expression: '6.0449600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hydrogen_7',
      expression: '7.0527000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hydrogen',
      expression: '0.99988500 hydrogen_1 + 0.00011500 hydrogen_2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'helium_3',
      expression: '3.0160293201',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'helium_4',
      expression: '4.0026032541',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'helium_5',
      expression: '5.0120570000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'helium_6',
      expression: '6.0188858910',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'helium_7',
      expression: '7.0279907000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'helium_8',
      expression: '8.0339343900',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'helium_9',
      expression: '9.0439460000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'helium_10',
      expression: '10.0527900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'helium',
      expression: '0.00000134 helium_3 + 0.99999866 helium_4',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lithium_3',
      expression: '3.0308000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lithium_4',
      expression: '4.0271900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lithium_5',
      expression: '5.0125380000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lithium_6',
      expression: '6.0151228874',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lithium_7',
      expression: '7.0160034366',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lithium_8',
      expression: '8.0224862460',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lithium_9',
      expression: '9.0267901900',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lithium_10',
      expression: '10.0354830000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lithium_11',
      expression: '11.0437235800',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lithium_12',
      expression: '12.0525170000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lithium_13',
      expression: '13.0626300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lithium',
      expression: '0.07590000 lithium_6 + 0.92410000 lithium_7',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'beryllium_5',
      expression: '5.0399000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'beryllium_6',
      expression: '6.0197264000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'beryllium_7',
      expression: '7.0169287170',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'beryllium_8',
      expression: '8.0053051020',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'beryllium_9',
      aliases: ['beryllium'],
      expression: '9.0121830650',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'beryllium_10',
      expression: '10.0135346950',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'beryllium_11',
      expression: '11.0216610800',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'beryllium_12',
      expression: '12.0269221000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'beryllium_13',
      expression: '13.0361350000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'beryllium_14',
      expression: '14.0428900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'beryllium_15',
      expression: '15.0534200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'beryllium_16',
      expression: '16.0616700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'boron_6',
      expression: '6.0508000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'boron_7',
      expression: '7.0297120000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'boron_8',
      expression: '8.0246073000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'boron_9',
      expression: '9.0133296500',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'boron_10',
      expression: '10.0129369500',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'boron_11',
      expression: '11.0093053600',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'boron_12',
      expression: '12.0143527000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'boron_13',
      expression: '13.0177802000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'boron_14',
      expression: '14.0254040000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'boron_15',
      expression: '15.0310880000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'boron_16',
      expression: '16.0398420000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'boron_17',
      expression: '17.0469900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'boron_18',
      expression: '18.0556600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'boron_19',
      expression: '19.0631000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'boron_20',
      expression: '20.0720700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'boron_21',
      expression: '21.0812900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'boron',
      expression: '0.19900000 boron_10 + 0.80100000 boron_11',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'carbon_8',
      expression: '8.0376430000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'carbon_9',
      expression: '9.0310372000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'carbon_10',
      expression: '10.0168533100',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'carbon_11',
      expression: '11.0114336000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'carbon_12',
      expression: '12.0000000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'carbon_13',
      expression: '13.0033548351',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'carbon_14',
      expression: '14.0032419884',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'carbon_15',
      expression: '15.0105992600',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'carbon_16',
      expression: '16.0147013000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'carbon_17',
      expression: '17.0225770000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'carbon_18',
      expression: '18.0267510000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'carbon_19',
      expression: '19.0348000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'carbon_20',
      expression: '20.0403200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'carbon_21',
      expression: '21.0490000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'carbon_22',
      expression: '22.0575300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'carbon_23',
      expression: '23.0689000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'carbon',
      expression: '0.98930000 carbon_12 + 0.01070000 carbon_13',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nitrogen_10',
      expression: '10.0416500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nitrogen_11',
      expression: '11.0260910000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nitrogen_12',
      expression: '12.0186132000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nitrogen_13',
      expression: '13.0057386100',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nitrogen_14',
      expression: '14.0030740044',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nitrogen_15',
      expression: '15.0001088989',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nitrogen_16',
      expression: '16.0061019000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nitrogen_17',
      expression: '17.0084490000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nitrogen_18',
      expression: '18.0140780000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nitrogen_19',
      expression: '19.0170220000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nitrogen_20',
      expression: '20.0233660000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nitrogen_21',
      expression: '21.0271100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nitrogen_22',
      expression: '22.0343900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nitrogen_23',
      expression: '23.0411400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nitrogen_24',
      expression: '24.0503900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nitrogen_25',
      expression: '25.0601000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nitrogen',
      expression: '0.99636000 nitrogen_14 + 0.00364000 nitrogen_15',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'oxygen_12',
      expression: '12.0342620000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'oxygen_13',
      expression: '13.0248150000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'oxygen_14',
      expression: '14.0085963600',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'oxygen_15',
      expression: '15.0030656200',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'oxygen_16',
      expression: '15.9949146196',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'oxygen_17',
      expression: '16.9991317565',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'oxygen_18',
      expression: '17.9991596129',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'oxygen_19',
      expression: '19.0035780000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'oxygen_20',
      expression: '20.0040753500',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'oxygen_21',
      expression: '21.0086550000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'oxygen_22',
      expression: '22.0099660000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'oxygen_23',
      expression: '23.0156960000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'oxygen_24',
      expression: '24.0198600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'oxygen_25',
      expression: '25.0293600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'oxygen_26',
      expression: '26.0372900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'oxygen_27',
      expression: '27.0477200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'oxygen_28',
      expression: '28.0559100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'oxygen',
      expression:
          '0.99757000 oxygen_16 + 0.00038000 oxygen_17 + 0.00205000 oxygen_18',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'fluorine_14',
      expression: '14.0343150000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'fluorine_15',
      expression: '15.0180430000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'fluorine_16',
      expression: '16.0114657000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'fluorine_17',
      expression: '17.0020952400',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'fluorine_18',
      expression: '18.0009373300',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'fluorine_19',
      aliases: ['fluorine'],
      expression: '18.9984031627',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'fluorine_20',
      expression: '19.9999812520',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'fluorine_21',
      expression: '20.9999489000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'fluorine_22',
      expression: '22.0029990000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'fluorine_23',
      expression: '23.0035570000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'fluorine_24',
      expression: '24.0081150000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'fluorine_25',
      expression: '25.0121990000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'fluorine_26',
      expression: '26.0200380000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'fluorine_27',
      expression: '27.0264400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'fluorine_28',
      expression: '28.0353400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'fluorine_29',
      expression: '29.0425400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'fluorine_30',
      expression: '30.0516500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'fluorine_31',
      expression: '31.0597100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neon_16',
      expression: '16.0257500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neon_17',
      expression: '17.0177139600',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neon_18',
      expression: '18.0057087000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neon_19',
      expression: '19.0018809100',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neon_20',
      expression: '19.9924401762',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neon_21',
      expression: '20.9938466850',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neon_22',
      expression: '21.9913851140',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neon_23',
      expression: '22.9944669100',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neon_24',
      expression: '23.9936106500',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neon_25',
      expression: '24.9977890000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neon_26',
      expression: '26.0005150000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neon_27',
      expression: '27.0075530000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neon_28',
      expression: '28.0121200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neon_29',
      expression: '29.0197500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neon_30',
      expression: '30.0247300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neon_31',
      expression: '31.0331000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neon_32',
      expression: '32.0397200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neon_33',
      expression: '33.0493800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neon_34',
      expression: '34.0567300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neon',
      expression:
          '0.90480000 neon_20 + 0.00270000 neon_21 + 0.09250000 neon_22',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sodium_18',
      expression: '18.0268800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sodium_19',
      expression: '19.0138800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sodium_20',
      expression: '20.0073544000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sodium_21',
      expression: '20.9976546900',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sodium_22',
      expression: '21.9944374100',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sodium_23',
      aliases: ['sodium'],
      expression: '22.9897692820',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sodium_24',
      expression: '23.9909629500',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sodium_25',
      expression: '24.9899540000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sodium_26',
      expression: '25.9926346000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sodium_27',
      expression: '26.9940765000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sodium_28',
      expression: '27.9989390000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sodium_29',
      expression: '29.0028771000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sodium_30',
      expression: '30.0090979000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sodium_31',
      expression: '31.0131630000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sodium_32',
      expression: '32.0201900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sodium_33',
      expression: '33.0257300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sodium_34',
      expression: '34.0335900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sodium_35',
      expression: '35.0406200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sodium_36',
      expression: '36.0492900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sodium_37',
      expression: '37.0570500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'magnesium_19',
      expression: '19.0341690000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'magnesium_20',
      expression: '20.0188500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'magnesium_21',
      expression: '21.0117160000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'magnesium_22',
      expression: '21.9995706500',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'magnesium_23',
      expression: '22.9941242100',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'magnesium_24',
      expression: '23.9850416970',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'magnesium_25',
      expression: '24.9858369760',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'magnesium_26',
      expression: '25.9825929680',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'magnesium_27',
      expression: '26.9843406240',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'magnesium_28',
      expression: '27.9838767000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'magnesium_29',
      expression: '28.9886170000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'magnesium_30',
      expression: '29.9904629000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'magnesium_31',
      expression: '30.9966480000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'magnesium_32',
      expression: '31.9991102000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'magnesium_33',
      expression: '33.0053271000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'magnesium_34',
      expression: '34.0089350000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'magnesium_35',
      expression: '35.0167900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'magnesium_36',
      expression: '36.0218800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'magnesium_37',
      expression: '37.0303700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'magnesium_38',
      expression: '38.0365800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'magnesium_39',
      expression: '39.0453800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'magnesium_40',
      expression: '40.0521800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'magnesium',
      expression:
          '0.78990000 magnesium_24 + 0.10000000 magnesium_25 + 0.11010000 magnesium_26',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'aluminium_21',
      expression: '21.0289700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'aluminium_22',
      expression: '22.0195400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'aluminium_23',
      expression: '23.0072443500',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'aluminium_24',
      expression: '23.9999489000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'aluminium_25',
      expression: '24.9904281000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'aluminium_26',
      expression: '25.9868919040',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'aluminium_27',
      aliases: ['aluminium'],
      expression: '26.9815385300',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'aluminium_28',
      expression: '27.9819102100',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'aluminium_29',
      expression: '28.9804565000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'aluminium_30',
      expression: '29.9829600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'aluminium_31',
      expression: '30.9839450000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'aluminium_32',
      expression: '31.9880850000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'aluminium_33',
      expression: '32.9909090000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'aluminium_34',
      expression: '33.9967050000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'aluminium_35',
      expression: '34.9997640000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'aluminium_36',
      expression: '36.0063900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'aluminium_37',
      expression: '37.0105300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'aluminium_38',
      expression: '38.0174000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'aluminium_39',
      expression: '39.0225400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'aluminium_40',
      expression: '40.0300300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'aluminium_41',
      expression: '41.0363800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'aluminium_42',
      expression: '42.0438400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'aluminium_43',
      expression: '43.0514700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'aluminum_21',
      expression: '21.0289700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'aluminum_22',
      expression: '22.0195400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'aluminum_23',
      expression: '23.0072443500',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'aluminum_24',
      expression: '23.9999489000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'aluminum_25',
      expression: '24.9904281000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'aluminum_26',
      expression: '25.9868919040',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'aluminum_27',
      aliases: ['aluminum'],
      expression: '26.9815385300',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'aluminum_28',
      expression: '27.9819102100',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'aluminum_29',
      expression: '28.9804565000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'aluminum_30',
      expression: '29.9829600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'aluminum_31',
      expression: '30.9839450000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'aluminum_32',
      expression: '31.9880850000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'aluminum_33',
      expression: '32.9909090000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'aluminum_34',
      expression: '33.9967050000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'aluminum_35',
      expression: '34.9997640000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'aluminum_36',
      expression: '36.0063900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'aluminum_37',
      expression: '37.0105300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'aluminum_38',
      expression: '38.0174000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'aluminum_39',
      expression: '39.0225400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'aluminum_40',
      expression: '40.0300300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'aluminum_41',
      expression: '41.0363800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'aluminum_42',
      expression: '42.0438400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'aluminum_43',
      expression: '43.0514700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'silicon_22',
      expression: '22.0357900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'silicon_23',
      expression: '23.0254400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'silicon_24',
      expression: '24.0115350000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'silicon_25',
      expression: '25.0041090000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'silicon_26',
      expression: '25.9923338400',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'silicon_27',
      expression: '26.9867048100',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'silicon_28',
      expression: '27.9769265347',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'silicon_29',
      expression: '28.9764946649',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'silicon_30',
      expression: '29.9737701360',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'silicon_31',
      expression: '30.9753631940',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'silicon_32',
      expression: '31.9741515400',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'silicon_33',
      expression: '32.9779769600',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'silicon_34',
      expression: '33.9785760000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'silicon_35',
      expression: '34.9845830000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'silicon_36',
      expression: '35.9866950000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'silicon_37',
      expression: '36.9929210000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'silicon_38',
      expression: '37.9955230000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'silicon_39',
      expression: '39.0024910000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'silicon_40',
      expression: '40.0058300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'silicon_41',
      expression: '41.0130100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'silicon_42',
      expression: '42.0177800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'silicon_43',
      expression: '43.0248000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'silicon_44',
      expression: '44.0306100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'silicon_45',
      expression: '45.0399500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'silicon',
      expression:
          '0.92223000 silicon_28 + 0.04685000 silicon_29 + 0.03092000 silicon_30',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'phosphorus_24',
      expression: '24.0357700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'phosphorus_25',
      expression: '25.0211900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'phosphorus_26',
      expression: '26.0117800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'phosphorus_27',
      expression: '26.9992240000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'phosphorus_28',
      expression: '27.9923266000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'phosphorus_29',
      expression: '28.9818007900',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'phosphorus_30',
      expression: '29.9783137500',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'phosphorus_31',
      aliases: ['phosphorus'],
      expression: '30.9737619984',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'phosphorus_32',
      expression: '31.9739076430',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'phosphorus_33',
      expression: '32.9717257000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'phosphorus_34',
      expression: '33.9736458900',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'phosphorus_35',
      expression: '34.9733141000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'phosphorus_36',
      expression: '35.9782600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'phosphorus_37',
      expression: '36.9796070000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'phosphorus_38',
      expression: '37.9842520000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'phosphorus_39',
      expression: '38.9862270000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'phosphorus_40',
      expression: '39.9913300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'phosphorus_41',
      expression: '40.9946540000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'phosphorus_42',
      expression: '42.0010800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'phosphorus_43',
      expression: '43.0050200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'phosphorus_44',
      expression: '44.0112100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'phosphorus_45',
      expression: '45.0164500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'phosphorus_46',
      expression: '46.0244600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'phosphorus_47',
      expression: '47.0313900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sulfur_26',
      expression: '26.0290700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sulfur_27',
      expression: '27.0182800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sulfur_28',
      expression: '28.0043700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sulfur_29',
      expression: '28.9966110000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sulfur_30',
      expression: '29.9849070300',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sulfur_31',
      expression: '30.9795570100',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sulfur_32',
      expression: '31.9720711744',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sulfur_33',
      expression: '32.9714589098',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sulfur_34',
      expression: '33.9678670040',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sulfur_35',
      expression: '34.9690323100',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sulfur_36',
      expression: '35.9670807100',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sulfur_37',
      expression: '36.9711255100',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sulfur_38',
      expression: '37.9711633000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sulfur_39',
      expression: '38.9751340000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sulfur_40',
      expression: '39.9754826000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sulfur_41',
      expression: '40.9795935000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sulfur_42',
      expression: '41.9810651000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sulfur_43',
      expression: '42.9869076000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sulfur_44',
      expression: '43.9901188000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sulfur_45',
      expression: '44.9957200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sulfur_46',
      expression: '46.0000400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sulfur_47',
      expression: '47.0079500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sulfur_48',
      expression: '48.0137000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sulfur_49',
      expression: '49.0227600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sulfur',
      aliases: ['sulphur'],
      expression:
          '0.94990000 sulfur_32 + 0.00750000 sulfur_33 + 0.04250000 sulfur_34 + 0.00010000 sulfur_36',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'chlorine_28',
      expression: '28.0295400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'chlorine_29',
      expression: '29.0147800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'chlorine_30',
      expression: '30.0047700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'chlorine_31',
      expression: '30.9924140000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'chlorine_32',
      expression: '31.9856846400',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'chlorine_33',
      expression: '32.9774519900',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'chlorine_34',
      expression: '33.9737624850',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'chlorine_35',
      expression: '34.9688526820',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'chlorine_36',
      expression: '35.9683068090',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'chlorine_37',
      expression: '36.9659026020',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'chlorine_38',
      expression: '37.9680104400',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'chlorine_39',
      expression: '38.9680082000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'chlorine_40',
      expression: '39.9704150000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'chlorine_41',
      expression: '40.9706850000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'chlorine_42',
      expression: '41.9732500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'chlorine_43',
      expression: '42.9738900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'chlorine_44',
      expression: '43.9778700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'chlorine_45',
      expression: '44.9802900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'chlorine_46',
      expression: '45.9851700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'chlorine_47',
      expression: '46.9891600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'chlorine_48',
      expression: '47.9956400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'chlorine_49',
      expression: '49.0012300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'chlorine_50',
      expression: '50.0090500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'chlorine_51',
      expression: '51.0155400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'chlorine',
      expression: '0.75760000 chlorine_35 + 0.24240000 chlorine_37',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'argon_30',
      expression: '30.0230700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'argon_31',
      expression: '31.0121200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'argon_32',
      expression: '31.9976378000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'argon_33',
      expression: '32.9899255500',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'argon_34',
      expression: '33.9802700900',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'argon_35',
      expression: '34.9752575900',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'argon_36',
      expression: '35.9675451050',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'argon_37',
      expression: '36.9667763300',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'argon_38',
      expression: '37.9627321100',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'argon_39',
      expression: '38.9643130000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'argon_40',
      expression: '39.9623831237',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'argon_41',
      expression: '40.9645005700',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'argon_42',
      expression: '41.9630457000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'argon_43',
      expression: '42.9656361000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'argon_44',
      expression: '43.9649238000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'argon_45',
      expression: '44.9680397300',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'argon_46',
      expression: '45.9680830000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'argon_47',
      expression: '46.9729350000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'argon_48',
      expression: '47.9759100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'argon_49',
      expression: '48.9819000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'argon_50',
      expression: '49.9861300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'argon_51',
      expression: '50.9937000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'argon_52',
      expression: '51.9989600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'argon_53',
      expression: '53.0072900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'argon',
      expression:
          '0.00333600 argon_36 + 0.00062900 argon_38 + 0.99603500 argon_40',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'potassium_32',
      expression: '32.0226500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'potassium_33',
      expression: '33.0075600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'potassium_34',
      expression: '33.9986900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'potassium_35',
      expression: '34.9880054100',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'potassium_36',
      expression: '35.9813020100',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'potassium_37',
      expression: '36.9733758900',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'potassium_38',
      expression: '37.9690811200',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'potassium_39',
      expression: '38.9637064864',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'potassium_40',
      expression: '39.9639981660',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'potassium_41',
      expression: '40.9618252579',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'potassium_42',
      expression: '41.9624023100',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'potassium_43',
      expression: '42.9607347000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'potassium_44',
      expression: '43.9615869900',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'potassium_45',
      expression: '44.9606914900',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'potassium_46',
      expression: '45.9619815900',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'potassium_47',
      expression: '46.9616616000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'potassium_48',
      expression: '47.9653411900',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'potassium_49',
      expression: '48.9682107500',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'potassium_50',
      expression: '49.9723800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'potassium_51',
      expression: '50.9758280000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'potassium_52',
      expression: '51.9822400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'potassium_53',
      expression: '52.9874600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'potassium_54',
      expression: '53.9946300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'potassium_55',
      expression: '55.0007600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'potassium_56',
      expression: '56.0085100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'potassium',
      expression:
          '0.93258100 potassium_39 + 0.00011700 potassium_40 + 0.06730200 potassium_41',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'calcium_34',
      expression: '34.0148700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'calcium_35',
      expression: '35.0051400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'calcium_36',
      expression: '35.9930740000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'calcium_37',
      expression: '36.9858978500',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'calcium_38',
      expression: '37.9763192200',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'calcium_39',
      expression: '38.9707108100',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'calcium_40',
      expression: '39.9625908630',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'calcium_41',
      expression: '40.9622779200',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'calcium_42',
      expression: '41.9586178300',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'calcium_43',
      expression: '42.9587664400',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'calcium_44',
      expression: '43.9554815600',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'calcium_45',
      expression: '44.9561863500',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'calcium_46',
      expression: '45.9536890000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'calcium_47',
      expression: '46.9545424000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'calcium_48',
      expression: '47.9525227600',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'calcium_49',
      expression: '48.9556627400',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'calcium_50',
      expression: '49.9574992000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'calcium_51',
      expression: '50.9609890000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'calcium_52',
      expression: '51.9632170000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'calcium_53',
      expression: '52.9694500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'calcium_54',
      expression: '53.9734000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'calcium_55',
      expression: '54.9803000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'calcium_56',
      expression: '55.9850800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'calcium_57',
      expression: '56.9926200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'calcium_58',
      expression: '57.9979400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'calcium',
      expression:
          '0.96941000 calcium_40 + 0.00647000 calcium_42 + 0.00135000 calcium_43 + 0.02086000 calcium_44 + 0.00004000 calcium_46 + 0.00187000 calcium_48',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'scandium_36',
      expression: '36.0164800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'scandium_37',
      expression: '37.0037400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'scandium_38',
      expression: '37.9951200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'scandium_39',
      expression: '38.9847850000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'scandium_40',
      expression: '39.9779673000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'scandium_41',
      expression: '40.9692511050',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'scandium_42',
      expression: '41.9655165300',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'scandium_43',
      expression: '42.9611505000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'scandium_44',
      expression: '43.9594029000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'scandium_45',
      aliases: ['scandium'],
      expression: '44.9559082800',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'scandium_46',
      expression: '45.9551682600',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'scandium_47',
      expression: '46.9524037000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'scandium_48',
      expression: '47.9522236000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'scandium_49',
      expression: '48.9500146000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'scandium_50',
      expression: '49.9521760000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'scandium_51',
      expression: '50.9535920000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'scandium_52',
      expression: '51.9568800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'scandium_53',
      expression: '52.9590900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'scandium_54',
      expression: '53.9639300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'scandium_55',
      expression: '54.9678200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'scandium_56',
      expression: '55.9734500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'scandium_57',
      expression: '56.9777700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'scandium_58',
      expression: '57.9840300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'scandium_59',
      expression: '58.9889400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'scandium_60',
      expression: '59.9956500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'scandium_61',
      expression: '61.0010000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'titanium_38',
      expression: '38.0114500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'titanium_39',
      expression: '39.0023600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'titanium_40',
      expression: '39.9905000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'titanium_41',
      expression: '40.9831480000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'titanium_42',
      expression: '41.9730490300',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'titanium_43',
      expression: '42.9685225000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'titanium_44',
      expression: '43.9596899500',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'titanium_45',
      expression: '44.9581219800',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'titanium_46',
      expression: '45.9526277200',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'titanium_47',
      expression: '46.9517587900',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'titanium_48',
      expression: '47.9479419800',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'titanium_49',
      expression: '48.9478656800',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'titanium_50',
      expression: '49.9447868900',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'titanium_51',
      expression: '50.9466106500',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'titanium_52',
      expression: '51.9468930000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'titanium_53',
      expression: '52.9497300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'titanium_54',
      expression: '53.9510500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'titanium_55',
      expression: '54.9552700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'titanium_56',
      expression: '55.9579100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'titanium_57',
      expression: '56.9636400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'titanium_58',
      expression: '57.9666000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'titanium_59',
      expression: '58.9724700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'titanium_60',
      expression: '59.9760300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'titanium_61',
      expression: '60.9824500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'titanium_62',
      expression: '61.9865100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'titanium_63',
      expression: '62.9937500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'titanium',
      expression:
          '0.08250000 titanium_46 + 0.07440000 titanium_47 + 0.73720000 titanium_48 + 0.05410000 titanium_49 + 0.05180000 titanium_50',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'vanadium_40',
      expression: '40.0127600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'vanadium_41',
      expression: '41.0002100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'vanadium_42',
      expression: '41.9918200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'vanadium_43',
      expression: '42.9807660000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'vanadium_44',
      expression: '43.9741100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'vanadium_45',
      expression: '44.9657748000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'vanadium_46',
      expression: '45.9601987800',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'vanadium_47',
      expression: '46.9549049100',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'vanadium_48',
      expression: '47.9522522000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'vanadium_49',
      expression: '48.9485118000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'vanadium_50',
      expression: '49.9471560100',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'vanadium_51',
      expression: '50.9439570400',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'vanadium_52',
      expression: '51.9447730100',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'vanadium_53',
      expression: '52.9443367000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'vanadium_54',
      expression: '53.9464390000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'vanadium_55',
      expression: '54.9472400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'vanadium_56',
      expression: '55.9504800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'vanadium_57',
      expression: '56.9525200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'vanadium_58',
      expression: '57.9567200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'vanadium_59',
      expression: '58.9593900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'vanadium_60',
      expression: '59.9643100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'vanadium_61',
      expression: '60.9672500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'vanadium_62',
      expression: '61.9726500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'vanadium_63',
      expression: '62.9763900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'vanadium_64',
      expression: '63.9826400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'vanadium_65',
      expression: '64.9875000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'vanadium_66',
      expression: '65.9939800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'vanadium',
      expression: '0.00250000 vanadium_50 + 0.99750000 vanadium_51',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'chromium_42',
      expression: '42.0067000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'chromium_43',
      expression: '42.9975300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'chromium_44',
      expression: '43.9853600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'chromium_45',
      expression: '44.9790500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'chromium_46',
      expression: '45.9683590000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'chromium_47',
      expression: '46.9628974000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'chromium_48',
      expression: '47.9540291000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'chromium_49',
      expression: '48.9513333000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'chromium_50',
      expression: '49.9460418300',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'chromium_51',
      expression: '50.9447650200',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'chromium_52',
      expression: '51.9405062300',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'chromium_53',
      expression: '52.9406481500',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'chromium_54',
      expression: '53.9388791600',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'chromium_55',
      expression: '54.9408384300',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'chromium_56',
      expression: '55.9406531000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'chromium_57',
      expression: '56.9436130000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'chromium_58',
      expression: '57.9443500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'chromium_59',
      expression: '58.9485900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'chromium_60',
      expression: '59.9500800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'chromium_61',
      expression: '60.9544200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'chromium_62',
      expression: '61.9561000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'chromium_63',
      expression: '62.9616500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'chromium_64',
      expression: '63.9640800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'chromium_65',
      expression: '64.9699600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'chromium_66',
      expression: '65.9736600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'chromium_67',
      expression: '66.9801600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'chromium_68',
      expression: '67.9840300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'chromium',
      expression:
          '0.04345000 chromium_50 + 0.83789000 chromium_52 + 0.09501000 chromium_53 + 0.02365000 chromium_54',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'manganese_44',
      expression: '44.0071500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'manganese_45',
      expression: '44.9944900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'manganese_46',
      expression: '45.9860900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'manganese_47',
      expression: '46.9757750000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'manganese_48',
      expression: '47.9685200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'manganese_49',
      expression: '48.9595950000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'manganese_50',
      expression: '49.9542377800',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'manganese_51',
      expression: '50.9482084700',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'manganese_52',
      expression: '51.9455639000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'manganese_53',
      expression: '52.9412888900',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'manganese_54',
      expression: '53.9403576000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'manganese_55',
      aliases: ['manganese'],
      expression: '54.9380439100',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'manganese_56',
      expression: '55.9389036900',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'manganese_57',
      expression: '56.9382861000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'manganese_58',
      expression: '57.9400666000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'manganese_59',
      expression: '58.9403911000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'manganese_60',
      expression: '59.9431366000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'manganese_61',
      expression: '60.9444525000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'manganese_62',
      expression: '61.9479500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'manganese_63',
      expression: '62.9496647000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'manganese_64',
      expression: '63.9538494000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'manganese_65',
      expression: '64.9560198000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'manganese_66',
      expression: '65.9605470000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'manganese_67',
      expression: '66.9642400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'manganese_68',
      expression: '67.9696200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'manganese_69',
      expression: '68.9736600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'manganese_70',
      expression: '69.9793700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'manganese_71',
      expression: '70.9836800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iron_45',
      expression: '45.0144200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iron_46',
      expression: '46.0006300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iron_47',
      expression: '46.9918500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iron_48',
      expression: '47.9802300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iron_49',
      expression: '48.9734290000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iron_50',
      expression: '49.9629750000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iron_51',
      expression: '50.9568410000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iron_52',
      expression: '51.9481131000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iron_53',
      expression: '52.9453064000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iron_54',
      expression: '53.9396089900',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iron_55',
      expression: '54.9382919900',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iron_56',
      expression: '55.9349363300',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iron_57',
      expression: '56.9353928400',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iron_58',
      expression: '57.9332744300',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iron_59',
      expression: '58.9348743400',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iron_60',
      expression: '59.9340711000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iron_61',
      expression: '60.9367462000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iron_62',
      expression: '61.9367918000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iron_63',
      expression: '62.9402727000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iron_64',
      expression: '63.9409878000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iron_65',
      expression: '64.9450115000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iron_66',
      expression: '65.9462500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iron_67',
      expression: '66.9505400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iron_68',
      expression: '67.9529500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iron_69',
      expression: '68.9580700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iron_70',
      expression: '69.9610200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iron_71',
      expression: '70.9667200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iron_72',
      expression: '71.9698300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iron_73',
      expression: '72.9757200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iron_74',
      expression: '73.9793500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iron',
      expression:
          '0.05845000 iron_54 + 0.91754000 iron_56 + 0.02119000 iron_57 + 0.00282000 iron_58',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cobalt_47',
      expression: '47.0105700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cobalt_48',
      expression: '48.0009300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cobalt_49',
      expression: '48.9889100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cobalt_50',
      expression: '49.9809100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cobalt_51',
      expression: '50.9706470000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cobalt_52',
      expression: '51.9635100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cobalt_53',
      expression: '52.9542041000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cobalt_54',
      expression: '53.9484598700',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cobalt_55',
      expression: '54.9419972000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cobalt_56',
      expression: '55.9398388000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cobalt_57',
      expression: '56.9362905700',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cobalt_58',
      expression: '57.9357521000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cobalt_59',
      aliases: ['cobalt'],
      expression: '58.9331942900',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cobalt_60',
      expression: '59.9338163000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cobalt_61',
      expression: '60.9324766200',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cobalt_62',
      expression: '61.9340590000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cobalt_63',
      expression: '62.9336000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cobalt_64',
      expression: '63.9358110000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cobalt_65',
      expression: '64.9364621000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cobalt_66',
      expression: '65.9394430000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cobalt_67',
      expression: '66.9406096000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cobalt_68',
      expression: '67.9442600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cobalt_69',
      expression: '68.9461400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cobalt_70',
      expression: '69.9496300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cobalt_71',
      expression: '70.9523700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cobalt_72',
      expression: '71.9572900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cobalt_73',
      expression: '72.9603900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cobalt_74',
      expression: '73.9651500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cobalt_75',
      expression: '74.9687600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cobalt_76',
      expression: '75.9741300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nickel_48',
      expression: '48.0176900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nickel_49',
      expression: '49.0077000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nickel_50',
      expression: '49.9947400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nickel_51',
      expression: '50.9861100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nickel_52',
      expression: '51.9748000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nickel_53',
      expression: '52.9681900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nickel_54',
      expression: '53.9578920000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nickel_55',
      expression: '54.9513306300',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nickel_56',
      expression: '55.9421285500',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nickel_57',
      expression: '56.9397921800',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nickel_58',
      expression: '57.9353424100',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nickel_59',
      expression: '58.9343462000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nickel_60',
      expression: '59.9307858800',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nickel_61',
      expression: '60.9310555700',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nickel_62',
      expression: '61.9283453700',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nickel_63',
      expression: '62.9296696300',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nickel_64',
      expression: '63.9279668200',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nickel_65',
      expression: '64.9300851700',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nickel_66',
      expression: '65.9291393000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nickel_67',
      expression: '66.9315694000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nickel_68',
      expression: '67.9318688000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nickel_69',
      expression: '68.9356103000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nickel_70',
      expression: '69.9364313000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nickel_71',
      expression: '70.9405190000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nickel_72',
      expression: '71.9417859000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nickel_73',
      expression: '72.9462067000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nickel_74',
      expression: '73.9479800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nickel_75',
      expression: '74.9525000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nickel_76',
      expression: '75.9553300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nickel_77',
      expression: '76.9605500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nickel_78',
      expression: '77.9633600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nickel_79',
      expression: '78.9702500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nickel',
      expression:
          '0.68077000 nickel_58 + 0.26223000 nickel_60 + 0.01139900 nickel_61 + 0.03634600 nickel_62 + 0.00925500 nickel_64',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'copper_52',
      expression: '51.9967100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'copper_53',
      expression: '52.9845900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'copper_54',
      expression: '53.9766600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'copper_55',
      expression: '54.9660400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'copper_56',
      expression: '55.9589500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'copper_57',
      expression: '56.9492125000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'copper_58',
      expression: '57.9445330500',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'copper_59',
      expression: '58.9394974800',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'copper_60',
      expression: '59.9373645000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'copper_61',
      expression: '60.9334576000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'copper_62',
      expression: '61.9325954100',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'copper_63',
      expression: '62.9295977200',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'copper_64',
      expression: '63.9297643400',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'copper_65',
      expression: '64.9277897000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'copper_66',
      expression: '65.9288690300',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'copper_67',
      expression: '66.9277303000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'copper_68',
      expression: '67.9296109000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'copper_69',
      expression: '68.9294293000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'copper_70',
      expression: '69.9323921000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'copper_71',
      expression: '70.9326768000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'copper_72',
      expression: '71.9358203000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'copper_73',
      expression: '72.9366744000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'copper_74',
      expression: '73.9398749000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'copper_75',
      expression: '74.9415226000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'copper_76',
      expression: '75.9452750000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'copper_77',
      expression: '76.9479200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'copper_78',
      expression: '77.9522300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'copper_79',
      expression: '78.9550200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'copper_80',
      expression: '79.9608900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'copper_81',
      expression: '80.9658700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'copper_82',
      expression: '81.9724400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'copper',
      expression: '0.69150000 copper_63 + 0.30850000 copper_65',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'zinc_54',
      expression: '53.9920400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'zinc_55',
      expression: '54.9839800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'zinc_56',
      expression: '55.9725400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'zinc_57',
      expression: '56.9650600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'zinc_58',
      expression: '57.9545910000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'zinc_59',
      expression: '58.9493126600',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'zinc_60',
      expression: '59.9418421000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'zinc_61',
      expression: '60.9395070000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'zinc_62',
      expression: '61.9343339700',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'zinc_63',
      expression: '62.9332115000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'zinc_64',
      expression: '63.9291420100',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'zinc_65',
      expression: '64.9292407700',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'zinc_66',
      expression: '65.9260338100',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'zinc_67',
      expression: '66.9271277500',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'zinc_68',
      expression: '67.9248445500',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'zinc_69',
      expression: '68.9265507000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'zinc_70',
      expression: '69.9253192000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'zinc_71',
      expression: '70.9277196000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'zinc_72',
      expression: '71.9268428000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'zinc_73',
      expression: '72.9295826000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'zinc_74',
      expression: '73.9294073000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'zinc_75',
      expression: '74.9328402000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'zinc_76',
      expression: '75.9331150000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'zinc_77',
      expression: '76.9368872000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'zinc_78',
      expression: '77.9382892000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'zinc_79',
      expression: '78.9426381000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'zinc_80',
      expression: '79.9445529000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'zinc_81',
      expression: '80.9504026000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'zinc_82',
      expression: '81.9542600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'zinc_83',
      expression: '82.9605600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'zinc_84',
      expression: '83.9652100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'zinc_85',
      expression: '84.9722600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'zinc',
      expression:
          '0.49170000 zinc_64 + 0.27730000 zinc_66 + 0.04040000 zinc_67 + 0.18450000 zinc_68 + 0.00610000 zinc_70',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gallium_56',
      expression: '55.9953600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gallium_57',
      expression: '56.9832000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gallium_58',
      expression: '57.9747800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gallium_59',
      expression: '58.9635300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gallium_60',
      expression: '59.9572900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gallium_61',
      expression: '60.9493990000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gallium_62',
      expression: '61.9441902500',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gallium_63',
      expression: '62.9392942000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gallium_64',
      expression: '63.9368404000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gallium_65',
      expression: '64.9327345900',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gallium_66',
      expression: '65.9315894000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gallium_67',
      expression: '66.9282025000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gallium_68',
      expression: '67.9279805000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gallium_69',
      expression: '68.9255735000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gallium_70',
      expression: '69.9260219000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gallium_71',
      expression: '70.9247025800',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gallium_72',
      expression: '71.9263674700',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gallium_73',
      expression: '72.9251747000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gallium_74',
      expression: '73.9269457000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gallium_75',
      expression: '74.9265002000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gallium_76',
      expression: '75.9288276000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gallium_77',
      expression: '76.9291543000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gallium_78',
      expression: '77.9316088000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gallium_79',
      expression: '78.9328523000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gallium_80',
      expression: '79.9364208000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gallium_81',
      expression: '80.9381338000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gallium_82',
      expression: '81.9431765000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gallium_83',
      expression: '82.9471203000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gallium_84',
      expression: '83.9524600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gallium_85',
      expression: '84.9569900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gallium_86',
      expression: '85.9630100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gallium_87',
      expression: '86.9682400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gallium',
      expression: '0.60108000 gallium_69 + 0.39892000 gallium_71',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'germanium_58',
      expression: '57.9917200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'germanium_59',
      expression: '58.9824900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'germanium_60',
      expression: '59.9703600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'germanium_61',
      expression: '60.9637900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'germanium_62',
      expression: '61.9550200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'germanium_63',
      expression: '62.9496280000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'germanium_64',
      expression: '63.9416899000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'germanium_65',
      expression: '64.9393681000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'germanium_66',
      expression: '65.9338621000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'germanium_67',
      expression: '66.9327339000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'germanium_68',
      expression: '67.9280953000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'germanium_69',
      expression: '68.9279645000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'germanium_70',
      expression: '69.9242487500',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'germanium_71',
      expression: '70.9249523300',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'germanium_72',
      expression: '71.9220758260',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'germanium_73',
      expression: '72.9234589560',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'germanium_74',
      expression: '73.9211777610',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'germanium_75',
      expression: '74.9228583700',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'germanium_76',
      expression: '75.9214027260',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'germanium_77',
      expression: '76.9235498430',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'germanium_78',
      expression: '77.9228529000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'germanium_79',
      expression: '78.9253600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'germanium_80',
      expression: '79.9253508000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'germanium_81',
      expression: '80.9288329000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'germanium_82',
      expression: '81.9297740000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'germanium_83',
      expression: '82.9345391000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'germanium_84',
      expression: '83.9375751000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'germanium_85',
      expression: '84.9429697000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'germanium_86',
      expression: '85.9465800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'germanium_87',
      expression: '86.9526800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'germanium_88',
      expression: '87.9569100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'germanium_89',
      expression: '88.9637900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'germanium_90',
      expression: '89.9686300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'germanium',
      expression:
          '0.20570000 germanium_70 + 0.27450000 germanium_72 + 0.07750000 germanium_73 + 0.36500000 germanium_74 + 0.07730000 germanium_76',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'arsenic_60',
      expression: '59.9938800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'arsenic_61',
      expression: '60.9811200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'arsenic_62',
      expression: '61.9736100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'arsenic_63',
      expression: '62.9639000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'arsenic_64',
      expression: '63.9574300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'arsenic_65',
      expression: '64.9496110000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'arsenic_66',
      expression: '65.9441488000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'arsenic_67',
      expression: '66.9392511100',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'arsenic_68',
      expression: '67.9367741000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'arsenic_69',
      expression: '68.9322460000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'arsenic_70',
      expression: '69.9309260000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'arsenic_71',
      expression: '70.9271138000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'arsenic_72',
      expression: '71.9267523000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'arsenic_73',
      expression: '72.9238291000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'arsenic_74',
      expression: '73.9239286000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'arsenic_75',
      aliases: ['arsenic'],
      expression: '74.9215945700',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'arsenic_76',
      expression: '75.9223920200',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'arsenic_77',
      expression: '76.9206476000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'arsenic_78',
      expression: '77.9218280000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'arsenic_79',
      expression: '78.9209484000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'arsenic_80',
      expression: '79.9224746000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'arsenic_81',
      expression: '80.9221323000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'arsenic_82',
      expression: '81.9247412000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'arsenic_83',
      expression: '82.9252069000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'arsenic_84',
      expression: '83.9293033000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'arsenic_85',
      expression: '84.9321637000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'arsenic_86',
      expression: '85.9367015000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'arsenic_87',
      expression: '86.9402917000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'arsenic_88',
      expression: '87.9455500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'arsenic_89',
      expression: '88.9497600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'arsenic_90',
      expression: '89.9556300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'arsenic_91',
      expression: '90.9603900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'arsenic_92',
      expression: '91.9667400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'selenium_64',
      expression: '63.9710900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'selenium_65',
      expression: '64.9644000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'selenium_66',
      expression: '65.9555900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'selenium_67',
      expression: '66.9499940000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'selenium_68',
      expression: '67.9418252400',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'selenium_69',
      expression: '68.9394148000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'selenium_70',
      expression: '69.9335155000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'selenium_71',
      expression: '70.9322094000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'selenium_72',
      expression: '71.9271405000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'selenium_73',
      expression: '72.9267549000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'selenium_74',
      expression: '73.9224759340',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'selenium_75',
      expression: '74.9225228700',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'selenium_76',
      expression: '75.9192137040',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'selenium_77',
      expression: '76.9199141540',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'selenium_78',
      expression: '77.9173092800',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'selenium_79',
      expression: '78.9184992900',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'selenium_80',
      expression: '79.9165218000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'selenium_81',
      expression: '80.9179930000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'selenium_82',
      expression: '81.9166995000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'selenium_83',
      expression: '82.9191186000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'selenium_84',
      expression: '83.9184668000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'selenium_85',
      expression: '84.9222608000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'selenium_86',
      expression: '85.9243117000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'selenium_87',
      expression: '86.9286886000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'selenium_88',
      expression: '87.9314175000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'selenium_89',
      expression: '88.9366691000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'selenium_90',
      expression: '89.9401000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'selenium_91',
      expression: '90.9459600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'selenium_92',
      expression: '91.9498400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'selenium_93',
      expression: '92.9562900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'selenium_94',
      expression: '93.9604900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'selenium_95',
      expression: '94.9673000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'selenium',
      expression:
          '0.00890000 selenium_74 + 0.09370000 selenium_76 + 0.07630000 selenium_77 + 0.23770000 selenium_78 + 0.49610000 selenium_80 + 0.08730000 selenium_82',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bromine_67',
      expression: '66.9646500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bromine_68',
      expression: '67.9587300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bromine_69',
      expression: '68.9504970000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bromine_70',
      expression: '69.9447920000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bromine_71',
      expression: '70.9393422000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bromine_72',
      expression: '71.9365886000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bromine_73',
      expression: '72.9316715000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bromine_74',
      expression: '73.9299102000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bromine_75',
      expression: '74.9258105000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bromine_76',
      expression: '75.9245420000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bromine_77',
      expression: '76.9213792000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bromine_78',
      expression: '77.9211459000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bromine_79',
      expression: '78.9183376000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bromine_80',
      expression: '79.9185298000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bromine_81',
      expression: '80.9162897000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bromine_82',
      expression: '81.9168032000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bromine_83',
      expression: '82.9151756000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bromine_84',
      expression: '83.9164960000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bromine_85',
      expression: '84.9156458000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bromine_86',
      expression: '85.9188054000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bromine_87',
      expression: '86.9206740000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bromine_88',
      expression: '87.9240833000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bromine_89',
      expression: '88.9267046000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bromine_90',
      expression: '89.9312928000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bromine_91',
      expression: '90.9343986000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bromine_92',
      expression: '91.9396316000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bromine_93',
      expression: '92.9431300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bromine_94',
      expression: '93.9489000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bromine_95',
      expression: '94.9530100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bromine_96',
      expression: '95.9590300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bromine_97',
      expression: '96.9634400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bromine_98',
      expression: '97.9694600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bromine',
      expression: '0.50690000 bromine_79 + 0.49310000 bromine_81',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'krypton_69',
      expression: '68.9651800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'krypton_70',
      expression: '69.9560400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'krypton_71',
      expression: '70.9502700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'krypton_72',
      expression: '71.9420924000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'krypton_73',
      expression: '72.9392892000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'krypton_74',
      expression: '73.9330840000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'krypton_75',
      expression: '74.9309457000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'krypton_76',
      expression: '75.9259103000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'krypton_77',
      expression: '76.9246700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'krypton_78',
      expression: '77.9203649400',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'krypton_79',
      expression: '78.9200829000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'krypton_80',
      expression: '79.9163780800',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'krypton_81',
      expression: '80.9165912000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'krypton_82',
      expression: '81.9134827300',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'krypton_83',
      expression: '82.9141271600',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'krypton_84',
      expression: '83.9114977282',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'krypton_85',
      expression: '84.9125273000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'krypton_86',
      expression: '85.9106106269',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'krypton_87',
      expression: '86.9133547600',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'krypton_88',
      expression: '87.9144479000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'krypton_89',
      expression: '88.9178355000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'krypton_90',
      expression: '89.9195279000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'krypton_91',
      expression: '90.9238063000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'krypton_92',
      expression: '91.9261731000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'krypton_93',
      expression: '92.9311472000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'krypton_94',
      expression: '93.9341400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'krypton_95',
      expression: '94.9397110000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'krypton_96',
      expression: '95.9430170000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'krypton_97',
      expression: '96.9490900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'krypton_98',
      expression: '97.9524300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'krypton_99',
      expression: '98.9583900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'krypton_100',
      expression: '99.9623700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'krypton_101',
      expression: '100.9687300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'krypton',
      expression:
          '0.00355000 krypton_78 + 0.02286000 krypton_80 + 0.11593000 krypton_82 + 0.11500000 krypton_83 + 0.56987000 krypton_84 + 0.17279000 krypton_86',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rubidium_71',
      expression: '70.9653200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rubidium_72',
      expression: '71.9590800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rubidium_73',
      expression: '72.9505300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rubidium_74',
      expression: '73.9442659000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rubidium_75',
      expression: '74.9385732000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rubidium_76',
      expression: '75.9350730000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rubidium_77',
      expression: '76.9304016000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rubidium_78',
      expression: '77.9281419000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rubidium_79',
      expression: '78.9239899000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rubidium_80',
      expression: '79.9225164000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rubidium_81',
      expression: '80.9189939000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rubidium_82',
      expression: '81.9182090000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rubidium_83',
      expression: '82.9151142000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rubidium_84',
      expression: '83.9143752000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rubidium_85',
      expression: '84.9117897379',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rubidium_86',
      expression: '85.9111674300',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rubidium_87',
      expression: '86.9091805310',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rubidium_88',
      expression: '87.9113155900',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rubidium_89',
      expression: '88.9122783000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rubidium_90',
      expression: '89.9147985000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rubidium_91',
      expression: '90.9165372000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rubidium_92',
      expression: '91.9197284000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rubidium_93',
      expression: '92.9220393000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rubidium_94',
      expression: '93.9263948000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rubidium_95',
      expression: '94.9292600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rubidium_96',
      expression: '95.9341334000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rubidium_97',
      expression: '96.9371771000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rubidium_98',
      expression: '97.9416869000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rubidium_99',
      expression: '98.9450300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rubidium_100',
      expression: '99.9500300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rubidium_101',
      expression: '100.9540400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rubidium_102',
      expression: '101.9595200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rubidium_103',
      expression: '102.9639200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rubidium',
      expression: '0.72170000 rubidium_85 + 0.27830000 rubidium_87',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'strontium_73',
      expression: '72.9657000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'strontium_74',
      expression: '73.9561700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'strontium_75',
      expression: '74.9499500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'strontium_76',
      expression: '75.9417630000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'strontium_77',
      expression: '76.9379455000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'strontium_78',
      expression: '77.9321800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'strontium_79',
      expression: '78.9297077000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'strontium_80',
      expression: '79.9245175000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'strontium_81',
      expression: '80.9232114000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'strontium_82',
      expression: '81.9183999000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'strontium_83',
      expression: '82.9175544000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'strontium_84',
      expression: '83.9134191000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'strontium_85',
      expression: '84.9129320000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'strontium_86',
      expression: '85.9092606000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'strontium_87',
      expression: '86.9088775000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'strontium_88',
      expression: '87.9056125000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'strontium_89',
      expression: '88.9074511000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'strontium_90',
      expression: '89.9077300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'strontium_91',
      expression: '90.9101954000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'strontium_92',
      expression: '91.9110382000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'strontium_93',
      expression: '92.9140242000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'strontium_94',
      expression: '93.9153556000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'strontium_95',
      expression: '94.9193529000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'strontium_96',
      expression: '95.9217066000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'strontium_97',
      expression: '96.9263740000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'strontium_98',
      expression: '97.9286888000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'strontium_99',
      expression: '98.9328907000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'strontium_100',
      expression: '99.9357700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'strontium_101',
      expression: '100.9403520000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'strontium_102',
      expression: '101.9437910000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'strontium_103',
      expression: '102.9490900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'strontium_104',
      expression: '103.9526500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'strontium_105',
      expression: '104.9585500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'strontium_106',
      expression: '105.9626500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'strontium_107',
      expression: '106.9689700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'strontium',
      expression:
          '0.00560000 strontium_84 + 0.09860000 strontium_86 + 0.07000000 strontium_87 + 0.82580000 strontium_88',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'yttrium_76',
      expression: '75.9585600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'yttrium_77',
      expression: '76.9497810000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'yttrium_78',
      expression: '77.9436100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'yttrium_79',
      expression: '78.9373500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'yttrium_80',
      expression: '79.9343561000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'yttrium_81',
      expression: '80.9294556000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'yttrium_82',
      expression: '81.9269314000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'yttrium_83',
      expression: '82.9224850000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'yttrium_84',
      expression: '83.9206721000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'yttrium_85',
      expression: '84.9164330000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'yttrium_86',
      expression: '85.9148860000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'yttrium_87',
      expression: '86.9108761000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'yttrium_88',
      expression: '87.9095016000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'yttrium_89',
      aliases: ['yttrium'],
      expression: '88.9058403000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'yttrium_90',
      expression: '89.9071439000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'yttrium_91',
      expression: '90.9072974000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'yttrium_92',
      expression: '91.9089451000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'yttrium_93',
      expression: '92.9095780000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'yttrium_94',
      expression: '93.9115906000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'yttrium_95',
      expression: '94.9128161000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'yttrium_96',
      expression: '95.9158968000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'yttrium_97',
      expression: '96.9182741000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'yttrium_98',
      expression: '97.9223821000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'yttrium_99',
      expression: '98.9241480000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'yttrium_100',
      expression: '99.9277150000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'yttrium_101',
      expression: '100.9301477000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'yttrium_102',
      expression: '101.9343277000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'yttrium_103',
      expression: '102.9372430000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'yttrium_104',
      expression: '103.9419600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'yttrium_105',
      expression: '104.9454400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'yttrium_106',
      expression: '105.9505600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'yttrium_107',
      expression: '106.9545200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'yttrium_108',
      expression: '107.9599600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'yttrium_109',
      expression: '108.9643600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'zirconium_78',
      expression: '77.9556600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'zirconium_79',
      expression: '78.9494800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'zirconium_80',
      expression: '79.9404000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'zirconium_81',
      expression: '80.9373100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'zirconium_82',
      expression: '81.9313500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'zirconium_83',
      expression: '82.9292421000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'zirconium_84',
      expression: '83.9233269000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'zirconium_85',
      expression: '84.9214444000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'zirconium_86',
      expression: '85.9162972000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'zirconium_87',
      expression: '86.9148180000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'zirconium_88',
      expression: '87.9102213000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'zirconium_89',
      expression: '88.9088814000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'zirconium_90',
      expression: '89.9046977000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'zirconium_91',
      expression: '90.9056396000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'zirconium_92',
      expression: '91.9050347000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'zirconium_93',
      expression: '92.9064699000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'zirconium_94',
      expression: '93.9063108000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'zirconium_95',
      expression: '94.9080385000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'zirconium_96',
      expression: '95.9082714000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'zirconium_97',
      expression: '96.9109512000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'zirconium_98',
      expression: '97.9127289000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'zirconium_99',
      expression: '98.9166670000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'zirconium_100',
      expression: '99.9180006000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'zirconium_101',
      expression: '100.9214480000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'zirconium_102',
      expression: '101.9231409000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'zirconium_103',
      expression: '102.9271910000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'zirconium_104',
      expression: '103.9294360000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'zirconium_105',
      expression: '104.9340080000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'zirconium_106',
      expression: '105.9367600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'zirconium_107',
      expression: '106.9417400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'zirconium_108',
      expression: '107.9448700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'zirconium_109',
      expression: '108.9504100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'zirconium_110',
      expression: '109.9539600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'zirconium_111',
      expression: '110.9596800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'zirconium_112',
      expression: '111.9637000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'zirconium',
      expression:
          '0.51450000 zirconium_90 + 0.11220000 zirconium_91 + 0.17150000 zirconium_92 + 0.17380000 zirconium_94 + 0.02800000 zirconium_96',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'niobium_81',
      expression: '80.9496000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'niobium_82',
      expression: '81.9439600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'niobium_83',
      expression: '82.9372900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'niobium_84',
      expression: '83.9344900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'niobium_85',
      expression: '84.9288458000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'niobium_86',
      expression: '85.9257828000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'niobium_87',
      expression: '86.9206937000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'niobium_88',
      expression: '87.9182220000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'niobium_89',
      expression: '88.9134450000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'niobium_90',
      expression: '89.9112584000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'niobium_91',
      expression: '90.9069897000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'niobium_92',
      expression: '91.9071881000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'niobium_93',
      aliases: ['niobium'],
      expression: '92.9063730000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'niobium_94',
      expression: '93.9072788000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'niobium_95',
      expression: '94.9068324000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'niobium_96',
      expression: '95.9080973000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'niobium_97',
      expression: '96.9080959000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'niobium_98',
      expression: '97.9103265000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'niobium_99',
      expression: '98.9116130000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'niobium_100',
      expression: '99.9143276000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'niobium_101',
      expression: '100.9153103000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'niobium_102',
      expression: '101.9180772000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'niobium_103',
      expression: '102.9194572000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'niobium_104',
      expression: '103.9228925000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'niobium_105',
      expression: '104.9249465000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'niobium_106',
      expression: '105.9289317000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'niobium_107',
      expression: '106.9315937000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'niobium_108',
      expression: '107.9360748000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'niobium_109',
      expression: '108.9392200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'niobium_110',
      expression: '109.9440300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'niobium_111',
      expression: '110.9475300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'niobium_112',
      expression: '111.9524700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'niobium_113',
      expression: '112.9565100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'niobium_114',
      expression: '113.9620100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'niobium_115',
      expression: '114.9663400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'molybdenum_83',
      expression: '82.9498800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'molybdenum_84',
      expression: '83.9414900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'molybdenum_85',
      expression: '84.9382610000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'molybdenum_86',
      expression: '85.9311748000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'molybdenum_87',
      expression: '86.9281962000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'molybdenum_88',
      expression: '87.9219678000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'molybdenum_89',
      expression: '88.9194682000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'molybdenum_90',
      expression: '89.9139309000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'molybdenum_91',
      expression: '90.9117453000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'molybdenum_92',
      expression: '91.9068079600',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'molybdenum_93',
      expression: '92.9068095800',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'molybdenum_94',
      expression: '93.9050849000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'molybdenum_95',
      expression: '94.9058387700',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'molybdenum_96',
      expression: '95.9046761200',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'molybdenum_97',
      expression: '96.9060181200',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'molybdenum_98',
      expression: '97.9054048200',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'molybdenum_99',
      expression: '98.9077085100',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'molybdenum_100',
      expression: '99.9074718000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'molybdenum_101',
      expression: '100.9103414000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'molybdenum_102',
      expression: '101.9102834000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'molybdenum_103',
      expression: '102.9130790000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'molybdenum_104',
      expression: '103.9137344000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'molybdenum_105',
      expression: '104.9169690000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'molybdenum_106',
      expression: '105.9182590000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'molybdenum_107',
      expression: '106.9221060000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'molybdenum_108',
      expression: '107.9240330000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'molybdenum_109',
      expression: '108.9284240000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'molybdenum_110',
      expression: '109.9307040000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'molybdenum_111',
      expression: '110.9356540000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'molybdenum_112',
      expression: '111.9383100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'molybdenum_113',
      expression: '112.9433500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'molybdenum_114',
      expression: '113.9465300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'molybdenum_115',
      expression: '114.9519600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'molybdenum_116',
      expression: '115.9554500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'molybdenum_117',
      expression: '116.9611700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'molybdenum',
      expression:
          '0.14530000 molybdenum_92 + 0.09150000 molybdenum_94 + 0.15840000 molybdenum_95 + 0.16670000 molybdenum_96 + 0.09600000 molybdenum_97 + 0.24390000 molybdenum_98 + 0.09820000 molybdenum_100',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'technetium_85',
      expression: '84.9505800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'technetium_86',
      expression: '85.9449300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'technetium_87',
      expression: '86.9380672000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'technetium_88',
      expression: '87.9337800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'technetium_89',
      expression: '88.9276487000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'technetium_90',
      expression: '89.9240739000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'technetium_91',
      expression: '90.9184254000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'technetium_92',
      expression: '91.9152698000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'technetium_93',
      expression: '92.9102460000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'technetium_94',
      expression: '93.9096536000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'technetium_95',
      expression: '94.9076536000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'technetium_96',
      expression: '95.9078680000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'technetium_97',
      expression: '96.9063667000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'technetium_98',
      aliases: ['technetium'],
      expression: '97.9072124000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'technetium_99',
      expression: '98.9062508000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'technetium_100',
      expression: '99.9076539000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'technetium_101',
      expression: '100.9073090000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'technetium_102',
      expression: '101.9092097000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'technetium_103',
      expression: '102.9091760000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'technetium_104',
      expression: '103.9114250000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'technetium_105',
      expression: '104.9116550000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'technetium_106',
      expression: '105.9143580000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'technetium_107',
      expression: '106.9154606000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'technetium_108',
      expression: '107.9184957000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'technetium_109',
      expression: '108.9202560000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'technetium_110',
      expression: '109.9237440000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'technetium_111',
      expression: '110.9259010000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'technetium_112',
      expression: '111.9299458000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'technetium_113',
      expression: '112.9325690000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'technetium_114',
      expression: '113.9369100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'technetium_115',
      expression: '114.9399800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'technetium_116',
      expression: '115.9447600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'technetium_117',
      expression: '116.9480600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'technetium_118',
      expression: '117.9529900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'technetium_119',
      expression: '118.9566600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'technetium_120',
      expression: '119.9618700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ruthenium_87',
      expression: '86.9506900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ruthenium_88',
      expression: '87.9416000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ruthenium_89',
      expression: '88.9376200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ruthenium_90',
      expression: '89.9303444000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ruthenium_91',
      expression: '90.9267419000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ruthenium_92',
      expression: '91.9202344000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ruthenium_93',
      expression: '92.9171044000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ruthenium_94',
      expression: '93.9113429000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ruthenium_95',
      expression: '94.9104060000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ruthenium_96',
      expression: '95.9075902500',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ruthenium_97',
      expression: '96.9075471000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ruthenium_98',
      expression: '97.9052868000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ruthenium_99',
      expression: '98.9059341000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ruthenium_100',
      expression: '99.9042143000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ruthenium_101',
      expression: '100.9055769000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ruthenium_102',
      expression: '101.9043441000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ruthenium_103',
      expression: '102.9063186000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ruthenium_104',
      expression: '103.9054275000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ruthenium_105',
      expression: '104.9077476000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ruthenium_106',
      expression: '105.9073291000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ruthenium_107',
      expression: '106.9099720000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ruthenium_108',
      expression: '107.9101880000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ruthenium_109',
      expression: '108.9133260000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ruthenium_110',
      expression: '109.9140407000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ruthenium_111',
      expression: '110.9175700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ruthenium_112',
      expression: '111.9188090000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ruthenium_113',
      expression: '112.9228440000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ruthenium_114',
      expression: '113.9246136000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ruthenium_115',
      expression: '114.9288200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ruthenium_116',
      expression: '115.9312192000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ruthenium_117',
      expression: '116.9361000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ruthenium_118',
      expression: '117.9385300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ruthenium_119',
      expression: '118.9435700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ruthenium_120',
      expression: '119.9463100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ruthenium_121',
      expression: '120.9516400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ruthenium_122',
      expression: '121.9544700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ruthenium_123',
      expression: '122.9598900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ruthenium_124',
      expression: '123.9630500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ruthenium',
      expression:
          '0.05540000 ruthenium_96 + 0.01870000 ruthenium_98 + 0.12760000 ruthenium_99 + 0.12600000 ruthenium_100 + 0.17060000 ruthenium_101 + 0.31550000 ruthenium_102 + 0.18620000 ruthenium_104',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhodium_89',
      expression: '88.9505800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhodium_90',
      expression: '89.9442200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhodium_91',
      expression: '90.9368800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhodium_92',
      expression: '91.9323677000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhodium_93',
      expression: '92.9259128000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhodium_94',
      expression: '93.9217305000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhodium_95',
      expression: '94.9158979000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhodium_96',
      expression: '95.9144530000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhodium_97',
      expression: '96.9113290000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhodium_98',
      expression: '97.9107080000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhodium_99',
      expression: '98.9081282000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhodium_100',
      expression: '99.9081170000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhodium_101',
      expression: '100.9061606000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhodium_102',
      expression: '101.9068374000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhodium_103',
      aliases: ['rhodium'],
      expression: '102.9054980000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhodium_104',
      expression: '103.9066492000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhodium_105',
      expression: '104.9056885000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhodium_106',
      expression: '105.9072868000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhodium_107',
      expression: '106.9067480000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhodium_108',
      expression: '107.9087140000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhodium_109',
      expression: '108.9087488000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhodium_110',
      expression: '109.9110790000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhodium_111',
      expression: '110.9116423000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhodium_112',
      expression: '111.9144030000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhodium_113',
      expression: '112.9154393000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhodium_114',
      expression: '113.9187180000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhodium_115',
      expression: '114.9203116000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhodium_116',
      expression: '115.9240590000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhodium_117',
      expression: '116.9260354000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhodium_118',
      expression: '117.9303400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhodium_119',
      expression: '118.9325570000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhodium_120',
      expression: '119.9368600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhodium_121',
      expression: '120.9394200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhodium_122',
      expression: '121.9439900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhodium_123',
      expression: '122.9468500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhodium_124',
      expression: '123.9515100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhodium_125',
      expression: '124.9546900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhodium_126',
      expression: '125.9594600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'palladium_91',
      expression: '90.9503200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'palladium_92',
      expression: '91.9408800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'palladium_93',
      expression: '92.9365100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'palladium_94',
      expression: '93.9290376000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'palladium_95',
      expression: '94.9248898000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'palladium_96',
      expression: '95.9182151000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'palladium_97',
      expression: '96.9164720000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'palladium_98',
      expression: '97.9126983000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'palladium_99',
      expression: '98.9117748000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'palladium_100',
      expression: '99.9085050000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'palladium_101',
      expression: '100.9082864000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'palladium_102',
      expression: '101.9056022000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'palladium_103',
      expression: '102.9060809000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'palladium_104',
      expression: '103.9040305000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'palladium_105',
      expression: '104.9050796000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'palladium_106',
      expression: '105.9034804000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'palladium_107',
      expression: '106.9051282000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'palladium_108',
      expression: '107.9038916000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'palladium_109',
      expression: '108.9059504000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'palladium_110',
      expression: '109.9051722000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'palladium_111',
      expression: '110.9076896800',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'palladium_112',
      expression: '111.9073297000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'palladium_113',
      expression: '112.9102610000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'palladium_114',
      expression: '113.9103686000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'palladium_115',
      expression: '114.9136590000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'palladium_116',
      expression: '115.9142970000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'palladium_117',
      expression: '116.9179547000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'palladium_118',
      expression: '117.9190667000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'palladium_119',
      expression: '118.9233402000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'palladium_120',
      expression: '119.9245511000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'palladium_121',
      expression: '120.9289503000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'palladium_122',
      expression: '121.9306320000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'palladium_123',
      expression: '122.9351400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'palladium_124',
      expression: '123.9371400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'palladium_125',
      expression: '124.9417900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'palladium_126',
      expression: '125.9441600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'palladium_127',
      expression: '126.9490700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'palladium_128',
      expression: '127.9518300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'palladium',
      expression:
          '0.01020000 palladium_102 + 0.11140000 palladium_104 + 0.22330000 palladium_105 + 0.27330000 palladium_106 + 0.26460000 palladium_108 + 0.11720000 palladium_110',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'silver_93',
      expression: '92.9503300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'silver_94',
      expression: '93.9437300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'silver_95',
      expression: '94.9360200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'silver_96',
      expression: '95.9307440000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'silver_97',
      expression: '96.9239700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'silver_98',
      expression: '97.9215600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'silver_99',
      expression: '98.9176458000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'silver_100',
      expression: '99.9161154000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'silver_101',
      expression: '100.9126840000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'silver_102',
      expression: '101.9117047000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'silver_103',
      expression: '102.9089631000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'silver_104',
      expression: '103.9086239000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'silver_105',
      expression: '104.9065256000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'silver_106',
      expression: '105.9066636000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'silver_107',
      expression: '106.9050916000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'silver_108',
      expression: '107.9059503000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'silver_109',
      expression: '108.9047553000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'silver_110',
      expression: '109.9061102000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'silver_111',
      expression: '110.9052959000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'silver_112',
      expression: '111.9070486000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'silver_113',
      expression: '112.9065730000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'silver_114',
      expression: '113.9088230000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'silver_115',
      expression: '114.9087670000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'silver_116',
      expression: '115.9113868000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'silver_117',
      expression: '116.9117740000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'silver_118',
      expression: '117.9145955000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'silver_119',
      expression: '118.9155700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'silver_120',
      expression: '119.9187848000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'silver_121',
      expression: '120.9201250000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'silver_122',
      expression: '121.9236640000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'silver_123',
      expression: '122.9253370000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'silver_124',
      expression: '123.9289300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'silver_125',
      expression: '124.9310500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'silver_126',
      expression: '125.9347500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'silver_127',
      expression: '126.9371100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'silver_128',
      expression: '127.9410600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'silver_129',
      expression: '128.9439500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'silver_130',
      expression: '129.9507000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'silver',
      expression: '0.51839000 silver_107 + 0.48161000 silver_109',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cadmium_95',
      expression: '94.9499400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cadmium_96',
      expression: '95.9403400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cadmium_97',
      expression: '96.9351000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cadmium_98',
      expression: '97.9273890000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cadmium_99',
      expression: '98.9249258000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cadmium_100',
      expression: '99.9203488000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cadmium_101',
      expression: '100.9185862000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cadmium_102',
      expression: '101.9144820000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cadmium_103',
      expression: '102.9134165000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cadmium_104',
      expression: '103.9098564000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cadmium_105',
      expression: '104.9094639000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cadmium_106',
      expression: '105.9064599000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cadmium_107',
      expression: '106.9066121000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cadmium_108',
      expression: '107.9041834000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cadmium_109',
      expression: '108.9049867000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cadmium_110',
      expression: '109.9030066100',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cadmium_111',
      expression: '110.9041828700',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cadmium_112',
      expression: '111.9027628700',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cadmium_113',
      expression: '112.9044081300',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cadmium_114',
      expression: '113.9033650900',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cadmium_115',
      expression: '114.9054375100',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cadmium_116',
      expression: '115.9047631500',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cadmium_117',
      expression: '116.9072260000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cadmium_118',
      expression: '117.9069220000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cadmium_119',
      expression: '118.9098470000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cadmium_120',
      expression: '119.9098681000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cadmium_121',
      expression: '120.9129637000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cadmium_122',
      expression: '121.9134591000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cadmium_123',
      expression: '122.9168925000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cadmium_124',
      expression: '123.9176574000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cadmium_125',
      expression: '124.9212576000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cadmium_126',
      expression: '125.9224291000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cadmium_127',
      expression: '126.9264720000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cadmium_128',
      expression: '127.9278129000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cadmium_129',
      expression: '128.9318200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cadmium_130',
      expression: '129.9339400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cadmium_131',
      expression: '130.9406000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cadmium_132',
      expression: '131.9460400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cadmium_133',
      expression: '132.9528500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cadmium',
      expression:
          '0.01250000 cadmium_106 + 0.00890000 cadmium_108 + 0.12490000 cadmium_110 + 0.12800000 cadmium_111 + 0.24130000 cadmium_112 + 0.12220000 cadmium_113 + 0.28730000 cadmium_114 + 0.07490000 cadmium_116',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'indium_97',
      expression: '96.9493400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'indium_98',
      expression: '97.9421400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'indium_99',
      expression: '98.9341100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'indium_100',
      expression: '99.9309600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'indium_101',
      expression: '100.9263400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'indium_102',
      expression: '101.9241071000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'indium_103',
      expression: '102.9198819000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'indium_104',
      expression: '103.9182145000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'indium_105',
      expression: '104.9145020000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'indium_106',
      expression: '105.9134640000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'indium_107',
      expression: '106.9102900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'indium_108',
      expression: '107.9096935000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'indium_109',
      expression: '108.9071514000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'indium_110',
      expression: '109.9071700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'indium_111',
      expression: '110.9051085000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'indium_112',
      expression: '111.9055377000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'indium_113',
      expression: '112.9040618400',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'indium_114',
      expression: '113.9049179100',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'indium_115',
      expression: '114.9038787760',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'indium_116',
      expression: '115.9052599900',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'indium_117',
      expression: '116.9045157000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'indium_118',
      expression: '117.9063566000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'indium_119',
      expression: '118.9058507000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'indium_120',
      expression: '119.9079670000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'indium_121',
      expression: '120.9078510000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'indium_122',
      expression: '121.9102810000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'indium_123',
      expression: '122.9104340000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'indium_124',
      expression: '123.9131820000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'indium_125',
      expression: '124.9136050000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'indium_126',
      expression: '125.9165070000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'indium_127',
      expression: '126.9174460000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'indium_128',
      expression: '127.9204000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'indium_129',
      expression: '128.9218053000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'indium_130',
      expression: '129.9249770000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'indium_131',
      expression: '130.9269715000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'indium_132',
      expression: '131.9330010000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'indium_133',
      expression: '132.9383100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'indium_134',
      expression: '133.9445400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'indium_135',
      expression: '134.9500500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'indium',
      expression: '0.04290000 indium_113 + 0.95710000 indium_115',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tin_99',
      expression: '98.9485300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tin_100',
      expression: '99.9385000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tin_101',
      expression: '100.9352600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tin_102',
      expression: '101.9302900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tin_103',
      expression: '102.9281050000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tin_104',
      expression: '103.9231052000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tin_105',
      expression: '104.9212684000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tin_106',
      expression: '105.9169574000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tin_107',
      expression: '106.9157137000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tin_108',
      expression: '107.9118943000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tin_109',
      expression: '108.9112921000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tin_110',
      expression: '109.9078450000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tin_111',
      expression: '110.9077401000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tin_112',
      expression: '111.9048238700',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tin_113',
      expression: '112.9051757000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tin_114',
      expression: '113.9027827000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tin_115',
      expression: '114.9033446990',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tin_116',
      expression: '115.9017428000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tin_117',
      expression: '116.9029539800',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tin_118',
      expression: '117.9016065700',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tin_119',
      expression: '118.9033111700',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tin_120',
      expression: '119.9022016300',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tin_121',
      expression: '120.9042426000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tin_122',
      expression: '121.9034438000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tin_123',
      expression: '122.9057252000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tin_124',
      expression: '123.9052766000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tin_125',
      expression: '124.9077864000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tin_126',
      expression: '125.9076590000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tin_127',
      expression: '126.9103900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tin_128',
      expression: '127.9105070000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tin_129',
      expression: '128.9134650000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tin_130',
      expression: '129.9139738000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tin_131',
      expression: '130.9170450000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tin_132',
      expression: '131.9178267000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tin_133',
      expression: '132.9239134000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tin_134',
      expression: '133.9286821000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tin_135',
      expression: '134.9349086000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tin_136',
      expression: '135.9399900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tin_137',
      expression: '136.9465500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tin_138',
      expression: '137.9518400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tin',
      expression:
          '0.00970000 tin_112 + 0.00660000 tin_114 + 0.00340000 tin_115 + 0.14540000 tin_116 + 0.07680000 tin_117 + 0.24220000 tin_118 + 0.08590000 tin_119 + 0.32580000 tin_120 + 0.04630000 tin_122 + 0.05790000 tin_124',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'antimony_103',
      expression: '102.9396900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'antimony_104',
      expression: '103.9364800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'antimony_105',
      expression: '104.9312760000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'antimony_106',
      expression: '105.9286380000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'antimony_107',
      expression: '106.9241506000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'antimony_108',
      expression: '107.9222267000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'antimony_109',
      expression: '108.9181411000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'antimony_110',
      expression: '109.9168543000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'antimony_111',
      expression: '110.9132182000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'antimony_112',
      expression: '111.9124000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'antimony_113',
      expression: '112.9093750000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'antimony_114',
      expression: '113.9092900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'antimony_115',
      expression: '114.9065980000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'antimony_116',
      expression: '115.9067931000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'antimony_117',
      expression: '116.9048415000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'antimony_118',
      expression: '117.9055321000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'antimony_119',
      expression: '118.9039455000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'antimony_120',
      expression: '119.9050794000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'antimony_121',
      expression: '120.9038120000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'antimony_122',
      expression: '121.9051699000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'antimony_123',
      expression: '122.9042132000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'antimony_124',
      expression: '123.9059350000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'antimony_125',
      expression: '124.9052530000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'antimony_126',
      expression: '125.9072530000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'antimony_127',
      expression: '126.9069243000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'antimony_128',
      expression: '127.9091460000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'antimony_129',
      expression: '128.9091470000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'antimony_130',
      expression: '129.9116620000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'antimony_131',
      expression: '130.9119888000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'antimony_132',
      expression: '131.9145077000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'antimony_133',
      expression: '132.9152732000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'antimony_134',
      expression: '133.9205357000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'antimony_135',
      expression: '134.9251851000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'antimony_136',
      expression: '135.9307459000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'antimony_137',
      expression: '136.9355500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'antimony_138',
      expression: '137.9414500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'antimony_139',
      expression: '138.9465500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'antimony_140',
      expression: '139.9528300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'antimony',
      expression: '0.57210000 antimony_121 + 0.42790000 antimony_123',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tellurium_105',
      expression: '104.9433000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tellurium_106',
      expression: '105.9375000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tellurium_107',
      expression: '106.9350120000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tellurium_108',
      expression: '107.9293805000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tellurium_109',
      expression: '108.9273045000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tellurium_110',
      expression: '109.9224581000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tellurium_111',
      expression: '110.9210006000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tellurium_112',
      expression: '111.9167279000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tellurium_113',
      expression: '112.9158910000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tellurium_114',
      expression: '113.9120890000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tellurium_115',
      expression: '114.9119020000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tellurium_116',
      expression: '115.9084600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tellurium_117',
      expression: '116.9086460000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tellurium_118',
      expression: '117.9058540000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tellurium_119',
      expression: '118.9064071000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tellurium_120',
      expression: '119.9040593000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tellurium_121',
      expression: '120.9049440000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tellurium_122',
      expression: '121.9030435000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tellurium_123',
      expression: '122.9042698000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tellurium_124',
      expression: '123.9028171000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tellurium_125',
      expression: '124.9044299000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tellurium_126',
      expression: '125.9033109000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tellurium_127',
      expression: '126.9052257000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tellurium_128',
      expression: '127.9044612800',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tellurium_129',
      expression: '128.9065964600',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tellurium_130',
      expression: '129.9062227480',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tellurium_131',
      expression: '130.9085222130',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tellurium_132',
      expression: '131.9085467000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tellurium_133',
      expression: '132.9109688000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tellurium_134',
      expression: '133.9113940000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tellurium_135',
      expression: '134.9165557000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tellurium_136',
      expression: '135.9201006000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tellurium_137',
      expression: '136.9255989000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tellurium_138',
      expression: '137.9294722000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tellurium_139',
      expression: '138.9353672000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tellurium_140',
      expression: '139.9394990000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tellurium_141',
      expression: '140.9458000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tellurium_142',
      expression: '141.9502200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tellurium_143',
      expression: '142.9567600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tellurium',
      expression:
          '0.00090000 tellurium_120 + 0.02550000 tellurium_122 + 0.00890000 tellurium_123 + 0.04740000 tellurium_124 + 0.07070000 tellurium_125 + 0.18840000 tellurium_126 + 0.31740000 tellurium_128 + 0.34080000 tellurium_130',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iodine_107',
      expression: '106.9467800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iodine_108',
      expression: '107.9434800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iodine_109',
      expression: '108.9380853000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iodine_110',
      expression: '109.9350890000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iodine_111',
      expression: '110.9302692000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iodine_112',
      expression: '111.9280050000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iodine_113',
      expression: '112.9236501000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iodine_114',
      expression: '113.9218500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iodine_115',
      expression: '114.9180480000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iodine_116',
      expression: '115.9168100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iodine_117',
      expression: '116.9136480000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iodine_118',
      expression: '117.9130740000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iodine_119',
      expression: '118.9100740000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iodine_120',
      expression: '119.9100870000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iodine_121',
      expression: '120.9074051000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iodine_122',
      expression: '121.9075888000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iodine_123',
      expression: '122.9055885000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iodine_124',
      expression: '123.9062090000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iodine_125',
      expression: '124.9046294000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iodine_126',
      expression: '125.9056233000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iodine_127',
      aliases: ['iodine'],
      expression: '126.9044719000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iodine_128',
      expression: '127.9058086000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iodine_129',
      expression: '128.9049837000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iodine_130',
      expression: '129.9066702000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iodine_131',
      expression: '130.9061263000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iodine_132',
      expression: '131.9079935000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iodine_133',
      expression: '132.9077970000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iodine_134',
      expression: '133.9097588000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iodine_135',
      expression: '134.9100488000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iodine_136',
      expression: '135.9146040000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iodine_137',
      expression: '136.9180282000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iodine_138',
      expression: '137.9227264000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iodine_139',
      expression: '138.9265060000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iodine_140',
      expression: '139.9317300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iodine_141',
      expression: '140.9356900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iodine_142',
      expression: '141.9412000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iodine_143',
      expression: '142.9456500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iodine_144',
      expression: '143.9513900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iodine_145',
      expression: '144.9560500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'xenon_109',
      expression: '108.9504300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'xenon_110',
      expression: '109.9442600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'xenon_111',
      expression: '110.9416070000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'xenon_112',
      expression: '111.9355590000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'xenon_113',
      expression: '112.9332217000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'xenon_114',
      expression: '113.9279800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'xenon_115',
      expression: '114.9262940000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'xenon_116',
      expression: '115.9215810000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'xenon_117',
      expression: '116.9203590000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'xenon_118',
      expression: '117.9161790000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'xenon_119',
      expression: '118.9154110000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'xenon_120',
      expression: '119.9117840000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'xenon_121',
      expression: '120.9114530000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'xenon_122',
      expression: '121.9083680000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'xenon_123',
      expression: '122.9084820000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'xenon_124',
      expression: '123.9058920000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'xenon_125',
      expression: '124.9063944000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'xenon_126',
      expression: '125.9042983000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'xenon_127',
      expression: '126.9051829000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'xenon_128',
      expression: '127.9035310000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'xenon_129',
      expression: '128.9047808611',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'xenon_130',
      expression: '129.9035093490',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'xenon_131',
      expression: '130.9050840600',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'xenon_132',
      expression: '131.9041550856',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'xenon_133',
      expression: '132.9059108000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'xenon_134',
      expression: '133.9053946600',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'xenon_135',
      expression: '134.9072278000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'xenon_136',
      expression: '135.9072144840',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'xenon_137',
      expression: '136.9115577800',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'xenon_138',
      expression: '137.9141463000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'xenon_139',
      expression: '138.9187922000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'xenon_140',
      expression: '139.9216458000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'xenon_141',
      expression: '140.9267872000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'xenon_142',
      expression: '141.9299731000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'xenon_143',
      expression: '142.9353696000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'xenon_144',
      expression: '143.9389451000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'xenon_145',
      expression: '144.9447200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'xenon_146',
      expression: '145.9485180000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'xenon_147',
      expression: '146.9542600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'xenon_148',
      expression: '147.9581300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'xenon',
      expression:
          '0.00095200 xenon_124 + 0.00089000 xenon_126 + 0.01910200 xenon_128 + 0.26400600 xenon_129 + 0.04071000 xenon_130 + 0.21232400 xenon_131 + 0.26908600 xenon_132 + 0.10435700 xenon_134 + 0.08857300 xenon_136',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'caesium_112',
      expression: '111.9503090000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'caesium_113',
      expression: '112.9444291000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'caesium_114',
      expression: '113.9412960000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'caesium_115',
      expression: '114.9359100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'caesium_116',
      expression: '115.9333700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'caesium_117',
      expression: '116.9286170000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'caesium_118',
      expression: '117.9265600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'caesium_119',
      expression: '118.9223770000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'caesium_120',
      expression: '119.9206770000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'caesium_121',
      expression: '120.9172270000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'caesium_122',
      expression: '121.9161080000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'caesium_123',
      expression: '122.9129960000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'caesium_124',
      expression: '123.9122578000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'caesium_125',
      expression: '124.9097280000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'caesium_126',
      expression: '125.9094460000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'caesium_127',
      expression: '126.9074174000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'caesium_128',
      expression: '127.9077487000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'caesium_129',
      expression: '128.9060657000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'caesium_130',
      expression: '129.9067093000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'caesium_131',
      expression: '130.9054649000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'caesium_132',
      expression: '131.9064339000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'caesium_133',
      aliases: ['caesium'],
      expression: '132.9054519610',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'caesium_134',
      expression: '133.9067185030',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'caesium_135',
      expression: '134.9059770000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'caesium_136',
      expression: '135.9073114000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'caesium_137',
      expression: '136.9070892300',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'caesium_138',
      expression: '137.9110171000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'caesium_139',
      expression: '138.9133638000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'caesium_140',
      expression: '139.9172831000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'caesium_141',
      expression: '140.9200455000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'caesium_142',
      expression: '141.9242960000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'caesium_143',
      expression: '142.9273490000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'caesium_144',
      expression: '143.9320760000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'caesium_145',
      expression: '144.9355270000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'caesium_146',
      expression: '145.9403440000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'caesium_147',
      expression: '146.9441560000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'caesium_148',
      expression: '147.9492300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'caesium_149',
      expression: '148.9530200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'caesium_150',
      expression: '149.9583300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'caesium_151',
      expression: '150.9625800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cesium_112',
      expression: '111.9503090000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cesium_113',
      expression: '112.9444291000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cesium_114',
      expression: '113.9412960000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cesium_115',
      expression: '114.9359100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cesium_116',
      expression: '115.9333700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cesium_117',
      expression: '116.9286170000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cesium_118',
      expression: '117.9265600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cesium_119',
      expression: '118.9223770000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cesium_120',
      expression: '119.9206770000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cesium_121',
      expression: '120.9172270000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cesium_122',
      expression: '121.9161080000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cesium_123',
      expression: '122.9129960000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cesium_124',
      expression: '123.9122578000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cesium_125',
      expression: '124.9097280000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cesium_126',
      expression: '125.9094460000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cesium_127',
      expression: '126.9074174000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cesium_128',
      expression: '127.9077487000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cesium_129',
      expression: '128.9060657000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cesium_130',
      expression: '129.9067093000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cesium_131',
      expression: '130.9054649000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cesium_132',
      expression: '131.9064339000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cesium_133',
      aliases: ['cesium'],
      expression: '132.9054519610',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cesium_134',
      expression: '133.9067185030',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cesium_135',
      expression: '134.9059770000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cesium_136',
      expression: '135.9073114000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cesium_137',
      expression: '136.9070892300',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cesium_138',
      expression: '137.9110171000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cesium_139',
      expression: '138.9133638000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cesium_140',
      expression: '139.9172831000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cesium_141',
      expression: '140.9200455000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cesium_142',
      expression: '141.9242960000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cesium_143',
      expression: '142.9273490000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cesium_144',
      expression: '143.9320760000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cesium_145',
      expression: '144.9355270000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cesium_146',
      expression: '145.9403440000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cesium_147',
      expression: '146.9441560000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cesium_148',
      expression: '147.9492300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cesium_149',
      expression: '148.9530200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cesium_150',
      expression: '149.9583300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cesium_151',
      expression: '150.9625800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'barium_114',
      expression: '113.9506600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'barium_115',
      expression: '114.9473700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'barium_116',
      expression: '115.9412800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'barium_117',
      expression: '116.9381400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'barium_118',
      expression: '117.9330600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'barium_119',
      expression: '118.9306600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'barium_120',
      expression: '119.9260500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'barium_121',
      expression: '120.9240500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'barium_122',
      expression: '121.9199040000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'barium_123',
      expression: '122.9187810000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'barium_124',
      expression: '123.9150940000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'barium_125',
      expression: '124.9144720000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'barium_126',
      expression: '125.9112500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'barium_127',
      expression: '126.9110910000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'barium_128',
      expression: '127.9083420000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'barium_129',
      expression: '128.9086810000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'barium_130',
      expression: '129.9063207000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'barium_131',
      expression: '130.9069410000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'barium_132',
      expression: '131.9050611000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'barium_133',
      expression: '132.9060074000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'barium_134',
      expression: '133.9045081800',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'barium_135',
      expression: '134.9056883800',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'barium_136',
      expression: '135.9045757300',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'barium_137',
      expression: '136.9058271400',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'barium_138',
      expression: '137.9052470000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'barium_139',
      expression: '138.9088411000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'barium_140',
      expression: '139.9106057000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'barium_141',
      expression: '140.9144033000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'barium_142',
      expression: '141.9164324000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'barium_143',
      expression: '142.9206253000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'barium_144',
      expression: '143.9229549000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'barium_145',
      expression: '144.9275184000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'barium_146',
      expression: '145.9302840000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'barium_147',
      expression: '146.9353040000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'barium_148',
      expression: '147.9381710000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'barium_149',
      expression: '148.9430800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'barium_150',
      expression: '149.9460500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'barium_151',
      expression: '150.9512700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'barium_152',
      expression: '151.9548100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'barium_153',
      expression: '152.9603600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'barium',
      expression:
          '0.00106000 barium_130 + 0.00101000 barium_132 + 0.02417000 barium_134 + 0.06592000 barium_135 + 0.07854000 barium_136 + 0.11232000 barium_137 + 0.71698000 barium_138',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lanthanum_116',
      expression: '115.9563000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lanthanum_117',
      expression: '116.9499900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lanthanum_118',
      expression: '117.9467300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lanthanum_119',
      expression: '118.9409900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lanthanum_120',
      expression: '119.9380700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lanthanum_121',
      expression: '120.9331500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lanthanum_122',
      expression: '121.9307100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lanthanum_123',
      expression: '122.9263000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lanthanum_124',
      expression: '123.9245740000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lanthanum_125',
      expression: '124.9208160000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lanthanum_126',
      expression: '125.9195130000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lanthanum_127',
      expression: '126.9163750000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lanthanum_128',
      expression: '127.9155920000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lanthanum_129',
      expression: '128.9126940000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lanthanum_130',
      expression: '129.9123690000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lanthanum_131',
      expression: '130.9100700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lanthanum_132',
      expression: '131.9101190000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lanthanum_133',
      expression: '132.9082180000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lanthanum_134',
      expression: '133.9085140000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lanthanum_135',
      expression: '134.9069840000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lanthanum_136',
      expression: '135.9076350000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lanthanum_137',
      expression: '136.9064504000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lanthanum_138',
      expression: '137.9071149000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lanthanum_139',
      expression: '138.9063563000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lanthanum_140',
      expression: '139.9094806000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lanthanum_141',
      expression: '140.9109660000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lanthanum_142',
      expression: '141.9140909000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lanthanum_143',
      expression: '142.9160795000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lanthanum_144',
      expression: '143.9196460000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lanthanum_145',
      expression: '144.9218080000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lanthanum_146',
      expression: '145.9258750000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lanthanum_147',
      expression: '146.9284180000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lanthanum_148',
      expression: '147.9326790000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lanthanum_149',
      expression: '148.9353500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lanthanum_150',
      expression: '149.9394700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lanthanum_151',
      expression: '150.9423200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lanthanum_152',
      expression: '151.9468200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lanthanum_153',
      expression: '152.9503600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lanthanum_154',
      expression: '153.9551700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lanthanum_155',
      expression: '154.9590100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lanthanum',
      expression: '0.00088810 lanthanum_138 + 0.99911190 lanthanum_139',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cerium_119',
      expression: '118.9527100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cerium_120',
      expression: '119.9465400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cerium_121',
      expression: '120.9433500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cerium_122',
      expression: '121.9378700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cerium_123',
      expression: '122.9352800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cerium_124',
      expression: '123.9303100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cerium_125',
      expression: '124.9284400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cerium_126',
      expression: '125.9239710000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cerium_127',
      expression: '126.9227270000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cerium_128',
      expression: '127.9189110000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cerium_129',
      expression: '128.9181020000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cerium_130',
      expression: '129.9147360000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cerium_131',
      expression: '130.9144290000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cerium_132',
      expression: '131.9114640000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cerium_133',
      expression: '132.9115200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cerium_134',
      expression: '133.9089280000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cerium_135',
      expression: '134.9091610000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cerium_136',
      expression: '135.9071292100',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cerium_137',
      expression: '136.9077623600',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cerium_138',
      expression: '137.9059910000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cerium_139',
      expression: '138.9066551000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cerium_140',
      expression: '139.9054431000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cerium_141',
      expression: '140.9082807000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cerium_142',
      expression: '141.9092504000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cerium_143',
      expression: '142.9123921000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cerium_144',
      expression: '143.9136529000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cerium_145',
      expression: '144.9172650000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cerium_146',
      expression: '145.9188020000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cerium_147',
      expression: '146.9226899000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cerium_148',
      expression: '147.9244240000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cerium_149',
      expression: '148.9284270000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cerium_150',
      expression: '149.9303840000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cerium_151',
      expression: '150.9342720000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cerium_152',
      expression: '151.9366000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cerium_153',
      expression: '152.9409300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cerium_154',
      expression: '153.9438000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cerium_155',
      expression: '154.9485500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cerium_156',
      expression: '155.9518300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cerium_157',
      expression: '156.9570500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cerium',
      expression:
          '0.00185000 cerium_136 + 0.00251000 cerium_138 + 0.88450000 cerium_140 + 0.11114000 cerium_142',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'praseodymium_121',
      expression: '120.9553200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'praseodymium_122',
      expression: '121.9517500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'praseodymium_123',
      expression: '122.9459600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'praseodymium_124',
      expression: '123.9429400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'praseodymium_125',
      expression: '124.9377000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'praseodymium_126',
      expression: '125.9352400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'praseodymium_127',
      expression: '126.9307100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'praseodymium_128',
      expression: '127.9287910000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'praseodymium_129',
      expression: '128.9250950000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'praseodymium_130',
      expression: '129.9235900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'praseodymium_131',
      expression: '130.9202350000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'praseodymium_132',
      expression: '131.9192550000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'praseodymium_133',
      expression: '132.9163310000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'praseodymium_134',
      expression: '133.9156970000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'praseodymium_135',
      expression: '134.9131120000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'praseodymium_136',
      expression: '135.9126770000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'praseodymium_137',
      expression: '136.9106792000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'praseodymium_138',
      expression: '137.9107540000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'praseodymium_139',
      expression: '138.9089408000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'praseodymium_140',
      expression: '139.9090803000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'praseodymium_141',
      aliases: ['praseodymium'],
      expression: '140.9076576000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'praseodymium_142',
      expression: '141.9100496000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'praseodymium_143',
      expression: '142.9108228000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'praseodymium_144',
      expression: '143.9133109000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'praseodymium_145',
      expression: '144.9145182000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'praseodymium_146',
      expression: '145.9176800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'praseodymium_147',
      expression: '146.9190080000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'praseodymium_148',
      expression: '147.9221300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'praseodymium_149',
      expression: '148.9237360000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'praseodymium_150',
      expression: '149.9266765000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'praseodymium_151',
      expression: '150.9283090000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'praseodymium_152',
      expression: '151.9315530000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'praseodymium_153',
      expression: '152.9339040000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'praseodymium_154',
      expression: '153.9375300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'praseodymium_155',
      expression: '154.9405090000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'praseodymium_156',
      expression: '155.9446400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'praseodymium_157',
      expression: '156.9478900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'praseodymium_158',
      expression: '157.9524100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'praseodymium_159',
      expression: '158.9558900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neodymium_124',
      expression: '123.9522000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neodymium_125',
      expression: '124.9489000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neodymium_126',
      expression: '125.9431100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neodymium_127',
      expression: '126.9403800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neodymium_128',
      expression: '127.9352500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neodymium_129',
      expression: '128.9331000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neodymium_130',
      expression: '129.9285060000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neodymium_131',
      expression: '130.9272480000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neodymium_132',
      expression: '131.9233210000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neodymium_133',
      expression: '132.9223480000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neodymium_134',
      expression: '133.9187900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neodymium_135',
      expression: '134.9181810000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neodymium_136',
      expression: '135.9149760000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neodymium_137',
      expression: '136.9145620000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neodymium_138',
      expression: '137.9119500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neodymium_139',
      expression: '138.9119540000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neodymium_140',
      expression: '139.9095500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neodymium_141',
      expression: '140.9096147000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neodymium_142',
      expression: '141.9077290000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neodymium_143',
      expression: '142.9098200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neodymium_144',
      expression: '143.9100930000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neodymium_145',
      expression: '144.9125793000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neodymium_146',
      expression: '145.9131226000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neodymium_147',
      expression: '146.9161061000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neodymium_148',
      expression: '147.9168993000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neodymium_149',
      expression: '148.9201548000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neodymium_150',
      expression: '149.9209022000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neodymium_151',
      expression: '150.9238403000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neodymium_152',
      expression: '151.9246920000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neodymium_153',
      expression: '152.9277180000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neodymium_154',
      expression: '153.9294800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neodymium_155',
      expression: '154.9331357000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neodymium_156',
      expression: '155.9350800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neodymium_157',
      expression: '156.9393860000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neodymium_158',
      expression: '157.9419700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neodymium_159',
      expression: '158.9465300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neodymium_160',
      expression: '159.9494000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neodymium_161',
      expression: '160.9542800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neodymium',
      expression:
          '0.27152000 neodymium_142 + 0.12174000 neodymium_143 + 0.23798000 neodymium_144 + 0.08293000 neodymium_145 + 0.17189000 neodymium_146 + 0.05756000 neodymium_148 + 0.05638000 neodymium_150',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'promethium_126',
      expression: '125.9579200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'promethium_127',
      expression: '126.9519200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'promethium_128',
      expression: '127.9487000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'promethium_129',
      expression: '128.9432300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'promethium_130',
      expression: '129.9405300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'promethium_131',
      expression: '130.9356700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'promethium_132',
      expression: '131.9338400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'promethium_133',
      expression: '132.9297820000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'promethium_134',
      expression: '133.9283530000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'promethium_135',
      expression: '134.9248230000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'promethium_136',
      expression: '135.9235850000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'promethium_137',
      expression: '136.9204800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'promethium_138',
      expression: '137.9195480000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'promethium_139',
      expression: '138.9168000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'promethium_140',
      expression: '139.9160400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'promethium_141',
      expression: '140.9135550000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'promethium_142',
      expression: '141.9128900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'promethium_143',
      expression: '142.9109383000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'promethium_144',
      expression: '143.9125964000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'promethium_145',
      aliases: ['promethium'],
      expression: '144.9127559000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'promethium_146',
      expression: '145.9147024000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'promethium_147',
      expression: '146.9151450000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'promethium_148',
      expression: '147.9174819000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'promethium_149',
      expression: '148.9183423000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'promethium_150',
      expression: '149.9209910000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'promethium_151',
      expression: '150.9212175000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'promethium_152',
      expression: '151.9235060000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'promethium_153',
      expression: '152.9241567000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'promethium_154',
      expression: '153.9264720000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'promethium_155',
      expression: '154.9281370000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'promethium_156',
      expression: '155.9311175000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'promethium_157',
      expression: '156.9331214000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'promethium_158',
      expression: '157.9365650000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'promethium_159',
      expression: '158.9392870000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'promethium_160',
      expression: '159.9431000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'promethium_161',
      expression: '160.9460700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'promethium_162',
      expression: '161.9502200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'promethium_163',
      expression: '162.9535700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'samarium_128',
      expression: '127.9584200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'samarium_129',
      expression: '128.9547600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'samarium_130',
      expression: '129.9490000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'samarium_131',
      expression: '130.9461800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'samarium_132',
      expression: '131.9408700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'samarium_133',
      expression: '132.9385600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'samarium_134',
      expression: '133.9341100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'samarium_135',
      expression: '134.9325200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'samarium_136',
      expression: '135.9282760000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'samarium_137',
      expression: '136.9269710000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'samarium_138',
      expression: '137.9232440000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'samarium_139',
      expression: '138.9222970000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'samarium_140',
      expression: '139.9189950000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'samarium_141',
      expression: '140.9184816000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'samarium_142',
      expression: '141.9152044000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'samarium_143',
      expression: '142.9146353000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'samarium_144',
      expression: '143.9120065000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'samarium_145',
      expression: '144.9134173000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'samarium_146',
      expression: '145.9130470000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'samarium_147',
      expression: '146.9149044000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'samarium_148',
      expression: '147.9148292000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'samarium_149',
      expression: '148.9171921000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'samarium_150',
      expression: '149.9172829000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'samarium_151',
      expression: '150.9199398000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'samarium_152',
      expression: '151.9197397000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'samarium_153',
      expression: '152.9221047000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'samarium_154',
      expression: '153.9222169000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'samarium_155',
      expression: '154.9246477000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'samarium_156',
      expression: '155.9255360000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'samarium_157',
      expression: '156.9284187000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'samarium_158',
      expression: '157.9299510000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'samarium_159',
      expression: '158.9332172000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'samarium_160',
      expression: '159.9353353000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'samarium_161',
      expression: '160.9391602000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'samarium_162',
      expression: '161.9414600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'samarium_163',
      expression: '162.9455500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'samarium_164',
      expression: '163.9483600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'samarium_165',
      expression: '164.9529700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'samarium',
      expression:
          '0.03070000 samarium_144 + 0.14990000 samarium_147 + 0.11240000 samarium_148 + 0.13820000 samarium_149 + 0.07380000 samarium_150 + 0.26750000 samarium_152 + 0.22750000 samarium_154',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'europium_130',
      expression: '129.9636900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'europium_131',
      expression: '130.9578400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'europium_132',
      expression: '131.9546700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'europium_133',
      expression: '132.9492900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'europium_134',
      expression: '133.9464000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'europium_135',
      expression: '134.9418700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'europium_136',
      expression: '135.9396200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'europium_137',
      expression: '136.9354600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'europium_138',
      expression: '137.9337090000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'europium_139',
      expression: '138.9297920000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'europium_140',
      expression: '139.9280880000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'europium_141',
      expression: '140.9249320000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'europium_142',
      expression: '141.9234420000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'europium_143',
      expression: '142.9202990000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'europium_144',
      expression: '143.9188200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'europium_145',
      expression: '144.9162726000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'europium_146',
      expression: '145.9172110000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'europium_147',
      expression: '146.9167527000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'europium_148',
      expression: '147.9180890000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'europium_149',
      expression: '148.9179378000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'europium_150',
      expression: '149.9197077000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'europium_151',
      expression: '150.9198578000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'europium_152',
      expression: '151.9217522000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'europium_153',
      expression: '152.9212380000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'europium_154',
      expression: '153.9229870000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'europium_155',
      expression: '154.9229011000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'europium_156',
      expression: '155.9247605000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'europium_157',
      expression: '156.9254334000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'europium_158',
      expression: '157.9277990000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'europium_159',
      expression: '158.9291001000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'europium_160',
      expression: '159.9318510000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'europium_161',
      expression: '160.9336640000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'europium_162',
      expression: '161.9369890000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'europium_163',
      expression: '162.9391960000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'europium_164',
      expression: '163.9427400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'europium_165',
      expression: '164.9455900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'europium_166',
      expression: '165.9496200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'europium_167',
      expression: '166.9528900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'europium',
      expression: '0.47810000 europium_151 + 0.52190000 europium_153',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gadolinium_133',
      expression: '132.9613300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gadolinium_134',
      expression: '133.9556600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gadolinium_135',
      expression: '134.9524500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gadolinium_136',
      expression: '135.9473000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gadolinium_137',
      expression: '136.9450200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gadolinium_138',
      expression: '137.9402500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gadolinium_139',
      expression: '138.9381300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gadolinium_140',
      expression: '139.9336740000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gadolinium_141',
      expression: '140.9321260000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gadolinium_142',
      expression: '141.9281160000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gadolinium_143',
      expression: '142.9267500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gadolinium_144',
      expression: '143.9229630000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gadolinium_145',
      expression: '144.9217130000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gadolinium_146',
      expression: '145.9183188000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gadolinium_147',
      expression: '146.9191014000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gadolinium_148',
      expression: '147.9181215000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gadolinium_149',
      expression: '148.9193481000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gadolinium_150',
      expression: '149.9186644000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gadolinium_151',
      expression: '150.9203560000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gadolinium_152',
      expression: '151.9197995000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gadolinium_153',
      expression: '152.9217580000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gadolinium_154',
      expression: '153.9208741000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gadolinium_155',
      expression: '154.9226305000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gadolinium_156',
      expression: '155.9221312000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gadolinium_157',
      expression: '156.9239686000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gadolinium_158',
      expression: '157.9241123000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gadolinium_159',
      expression: '158.9263970000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gadolinium_160',
      expression: '159.9270624000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gadolinium_161',
      expression: '160.9296775000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gadolinium_162',
      expression: '161.9309930000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gadolinium_163',
      expression: '162.9341769000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gadolinium_164',
      expression: '163.9358300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gadolinium_165',
      expression: '164.9393600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gadolinium_166',
      expression: '165.9414600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gadolinium_167',
      expression: '166.9454500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gadolinium_168',
      expression: '167.9480800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gadolinium_169',
      expression: '168.9526000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gadolinium',
      expression:
          '0.00200000 gadolinium_152 + 0.02180000 gadolinium_154 + 0.14800000 gadolinium_155 + 0.20470000 gadolinium_156 + 0.15650000 gadolinium_157 + 0.24840000 gadolinium_158 + 0.21860000 gadolinium_160',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'terbium_135',
      expression: '134.9647600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'terbium_136',
      expression: '135.9612900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'terbium_137',
      expression: '136.9560200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'terbium_138',
      expression: '137.9531200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'terbium_139',
      expression: '138.9483300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'terbium_140',
      expression: '139.9458100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'terbium_141',
      expression: '140.9414500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'terbium_142',
      expression: '141.9392800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'terbium_143',
      expression: '142.9351370000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'terbium_144',
      expression: '143.9330450000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'terbium_145',
      expression: '144.9288200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'terbium_146',
      expression: '145.9272530000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'terbium_147',
      expression: '146.9240548000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'terbium_148',
      expression: '147.9242820000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'terbium_149',
      expression: '148.9232535000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'terbium_150',
      expression: '149.9236649000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'terbium_151',
      expression: '150.9231096000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'terbium_152',
      expression: '151.9240830000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'terbium_153',
      expression: '152.9234424000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'terbium_154',
      expression: '153.9246850000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'terbium_155',
      expression: '154.9235110000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'terbium_156',
      expression: '155.9247552000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'terbium_157',
      expression: '156.9240330000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'terbium_158',
      expression: '157.9254209000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'terbium_159',
      aliases: ['terbium'],
      expression: '158.9253547000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'terbium_160',
      expression: '159.9271756000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'terbium_161',
      expression: '160.9275778000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'terbium_162',
      expression: '161.9294950000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'terbium_163',
      expression: '162.9306547000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'terbium_164',
      expression: '163.9333600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'terbium_165',
      expression: '164.9349800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'terbium_166',
      expression: '165.9378600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'terbium_167',
      expression: '166.9399600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'terbium_168',
      expression: '167.9434000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'terbium_169',
      expression: '168.9459700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'terbium_170',
      expression: '169.9498400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'terbium_171',
      expression: '170.9527300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'dysprosium_138',
      expression: '137.9625000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'dysprosium_139',
      expression: '138.9595900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'dysprosium_140',
      expression: '139.9540200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'dysprosium_141',
      expression: '140.9512800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'dysprosium_142',
      expression: '141.9461900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'dysprosium_143',
      expression: '142.9439940000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'dysprosium_144',
      expression: '143.9392695000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'dysprosium_145',
      expression: '144.9374740000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'dysprosium_146',
      expression: '145.9328445000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'dysprosium_147',
      expression: '146.9310827000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'dysprosium_148',
      expression: '147.9271570000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'dysprosium_149',
      expression: '148.9273220000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'dysprosium_150',
      expression: '149.9255933000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'dysprosium_151',
      expression: '150.9261916000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'dysprosium_152',
      expression: '151.9247253000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'dysprosium_153',
      expression: '152.9257724000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'dysprosium_154',
      expression: '153.9244293000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'dysprosium_155',
      expression: '154.9257590000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'dysprosium_156',
      expression: '155.9242847000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'dysprosium_157',
      expression: '156.9254707000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'dysprosium_158',
      expression: '157.9244159000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'dysprosium_159',
      expression: '158.9257470000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'dysprosium_160',
      expression: '159.9252046000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'dysprosium_161',
      expression: '160.9269405000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'dysprosium_162',
      expression: '161.9268056000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'dysprosium_163',
      expression: '162.9287383000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'dysprosium_164',
      expression: '163.9291819000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'dysprosium_165',
      expression: '164.9317105000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'dysprosium_166',
      expression: '165.9328139000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'dysprosium_167',
      expression: '166.9356610000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'dysprosium_168',
      expression: '167.9371300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'dysprosium_169',
      expression: '168.9403100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'dysprosium_170',
      expression: '169.9423900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'dysprosium_171',
      expression: '170.9461200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'dysprosium_172',
      expression: '171.9484600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'dysprosium_173',
      expression: '172.9528300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'dysprosium',
      expression:
          '0.00056000 dysprosium_156 + 0.00095000 dysprosium_158 + 0.02329000 dysprosium_160 + 0.18889000 dysprosium_161 + 0.25475000 dysprosium_162 + 0.24896000 dysprosium_163 + 0.28260000 dysprosium_164',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'holmium_140',
      expression: '139.9685900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'holmium_141',
      expression: '140.9631100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'holmium_142',
      expression: '141.9600100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'holmium_143',
      expression: '142.9548600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'holmium_144',
      expression: '143.9521097000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'holmium_145',
      expression: '144.9472674000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'holmium_146',
      expression: '145.9449935000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'holmium_147',
      expression: '146.9401423000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'holmium_148',
      expression: '147.9377440000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'holmium_149',
      expression: '148.9338030000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'holmium_150',
      expression: '149.9334980000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'holmium_151',
      expression: '150.9316983000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'holmium_152',
      expression: '151.9317240000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'holmium_153',
      expression: '152.9302064000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'holmium_154',
      expression: '153.9306068000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'holmium_155',
      expression: '154.9291040000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'holmium_156',
      expression: '155.9297060000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'holmium_157',
      expression: '156.9282540000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'holmium_158',
      expression: '157.9289460000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'holmium_159',
      expression: '158.9277197000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'holmium_160',
      expression: '159.9287370000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'holmium_161',
      expression: '160.9278615000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'holmium_162',
      expression: '161.9291023000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'holmium_163',
      expression: '162.9287410000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'holmium_164',
      expression: '163.9302403000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'holmium_165',
      aliases: ['holmium'],
      expression: '164.9303288000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'holmium_166',
      expression: '165.9322909000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'holmium_167',
      expression: '166.9331385000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'holmium_168',
      expression: '167.9355220000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'holmium_169',
      expression: '168.9368780000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'holmium_170',
      expression: '169.9396250000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'holmium_171',
      expression: '170.9414700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'holmium_172',
      expression: '171.9447300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'holmium_173',
      expression: '172.9470200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'holmium_174',
      expression: '173.9509500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'holmium_175',
      expression: '174.9536200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'erbium_142',
      expression: '141.9701000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'erbium_143',
      expression: '142.9666200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'erbium_144',
      expression: '143.9607000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'erbium_145',
      expression: '144.9580500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'erbium_146',
      expression: '145.9524184000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'erbium_147',
      expression: '146.9499640000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'erbium_148',
      expression: '147.9447350000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'erbium_149',
      expression: '148.9423060000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'erbium_150',
      expression: '149.9379160000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'erbium_151',
      expression: '150.9374490000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'erbium_152',
      expression: '151.9350570000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'erbium_153',
      expression: '152.9350800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'erbium_154',
      expression: '153.9327908000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'erbium_155',
      expression: '154.9332159000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'erbium_156',
      expression: '155.9310670000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'erbium_157',
      expression: '156.9319490000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'erbium_158',
      expression: '157.9298930000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'erbium_159',
      expression: '158.9306918000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'erbium_160',
      expression: '159.9290770000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'erbium_161',
      expression: '160.9300046000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'erbium_162',
      expression: '161.9287884000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'erbium_163',
      expression: '162.9300408000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'erbium_164',
      expression: '163.9292088000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'erbium_165',
      expression: '164.9307345000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'erbium_166',
      expression: '165.9302995000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'erbium_167',
      expression: '166.9320546000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'erbium_168',
      expression: '167.9323767000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'erbium_169',
      expression: '168.9345968000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'erbium_170',
      expression: '169.9354702000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'erbium_171',
      expression: '170.9380357000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'erbium_172',
      expression: '171.9393619000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'erbium_173',
      expression: '172.9424000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'erbium_174',
      expression: '173.9442300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'erbium_175',
      expression: '174.9477700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'erbium_176',
      expression: '175.9499400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'erbium_177',
      expression: '176.9539900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'erbium',
      expression:
          '0.00139000 erbium_162 + 0.01601000 erbium_164 + 0.33503000 erbium_166 + 0.22869000 erbium_167 + 0.26978000 erbium_168 + 0.14910000 erbium_170',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thulium_144',
      expression: '143.9762800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thulium_145',
      expression: '144.9703900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thulium_146',
      expression: '145.9668400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thulium_147',
      expression: '146.9613799000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thulium_148',
      expression: '147.9583840000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thulium_149',
      expression: '148.9528900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thulium_150',
      expression: '149.9500900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thulium_151',
      expression: '150.9454880000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thulium_152',
      expression: '151.9444220000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thulium_153',
      expression: '152.9420400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thulium_154',
      expression: '153.9415700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thulium_155',
      expression: '154.9392100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thulium_156',
      expression: '155.9389920000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thulium_157',
      expression: '156.9369440000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thulium_158',
      expression: '157.9369800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thulium_159',
      expression: '158.9349750000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thulium_160',
      expression: '159.9352630000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thulium_161',
      expression: '160.9335490000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thulium_162',
      expression: '161.9340020000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thulium_163',
      expression: '162.9326592000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thulium_164',
      expression: '163.9335440000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thulium_165',
      expression: '164.9324431000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thulium_166',
      expression: '165.9335610000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thulium_167',
      expression: '166.9328562000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thulium_168',
      expression: '167.9341774000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thulium_169',
      aliases: ['thulium'],
      expression: '168.9342179000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thulium_170',
      expression: '169.9358060000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thulium_171',
      expression: '170.9364339000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thulium_172',
      expression: '171.9384055000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thulium_173',
      expression: '172.9396084000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thulium_174',
      expression: '173.9421730000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thulium_175',
      expression: '174.9438410000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thulium_176',
      expression: '175.9470000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thulium_177',
      expression: '176.9490400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thulium_178',
      expression: '177.9526400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thulium_179',
      expression: '178.9553400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ytterbium_148',
      expression: '147.9675800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ytterbium_149',
      expression: '148.9643600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ytterbium_150',
      expression: '149.9585200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ytterbium_151',
      expression: '150.9554000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ytterbium_152',
      expression: '151.9502700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ytterbium_153',
      expression: '152.9493200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ytterbium_154',
      expression: '153.9463960000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ytterbium_155',
      expression: '154.9457830000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ytterbium_156',
      expression: '155.9428250000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ytterbium_157',
      expression: '156.9426450000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ytterbium_158',
      expression: '157.9398705000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ytterbium_159',
      expression: '158.9400550000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ytterbium_160',
      expression: '159.9375570000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ytterbium_161',
      expression: '160.9379070000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ytterbium_162',
      expression: '161.9357740000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ytterbium_163',
      expression: '162.9363400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ytterbium_164',
      expression: '163.9344950000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ytterbium_165',
      expression: '164.9352700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ytterbium_166',
      expression: '165.9338747000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ytterbium_167',
      expression: '166.9349530000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ytterbium_168',
      expression: '167.9338896000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ytterbium_169',
      expression: '168.9351825000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ytterbium_170',
      expression: '169.9347664000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ytterbium_171',
      expression: '170.9363302000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ytterbium_172',
      expression: '171.9363859000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ytterbium_173',
      expression: '172.9382151000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ytterbium_174',
      expression: '173.9388664000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ytterbium_175',
      expression: '174.9412808000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ytterbium_176',
      expression: '175.9425764000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ytterbium_177',
      expression: '176.9452656000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ytterbium_178',
      expression: '177.9466510000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ytterbium_179',
      expression: '178.9500400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ytterbium_180',
      expression: '179.9521200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ytterbium_181',
      expression: '180.9558900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ytterbium',
      expression:
          '0.00123000 ytterbium_168 + 0.02982000 ytterbium_170 + 0.14090000 ytterbium_171 + 0.21680000 ytterbium_172 + 0.16103000 ytterbium_173 + 0.32026000 ytterbium_174 + 0.12996000 ytterbium_176',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lutetium_150',
      expression: '149.9735500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lutetium_151',
      expression: '150.9676800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lutetium_152',
      expression: '151.9641200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lutetium_153',
      expression: '152.9587500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lutetium_154',
      expression: '153.9573600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lutetium_155',
      expression: '154.9543210000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lutetium_156',
      expression: '155.9530330000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lutetium_157',
      expression: '156.9501270000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lutetium_158',
      expression: '157.9493160000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lutetium_159',
      expression: '158.9466360000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lutetium_160',
      expression: '159.9460330000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lutetium_161',
      expression: '160.9435720000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lutetium_162',
      expression: '161.9432830000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lutetium_163',
      expression: '162.9411790000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lutetium_164',
      expression: '163.9413390000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lutetium_165',
      expression: '164.9394070000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lutetium_166',
      expression: '165.9398590000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lutetium_167',
      expression: '166.9382700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lutetium_168',
      expression: '167.9387360000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lutetium_169',
      expression: '168.9376441000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lutetium_170',
      expression: '169.9384780000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lutetium_171',
      expression: '170.9379170000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lutetium_172',
      expression: '171.9390891000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lutetium_173',
      expression: '172.9389340000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lutetium_174',
      expression: '173.9403409000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lutetium_175',
      expression: '174.9407752000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lutetium_176',
      expression: '175.9426897000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lutetium_177',
      expression: '176.9437615000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lutetium_178',
      expression: '177.9459580000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lutetium_179',
      expression: '178.9473309000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lutetium_180',
      expression: '179.9498880000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lutetium_181',
      expression: '180.9519100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lutetium_182',
      expression: '181.9550400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lutetium_183',
      expression: '182.9573630000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lutetium_184',
      expression: '183.9609100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lutetium_185',
      expression: '184.9636200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lutetium',
      expression: '0.97401000 lutetium_175 + 0.02599000 lutetium_176',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hafnium_153',
      expression: '152.9706900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hafnium_154',
      expression: '153.9648600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hafnium_155',
      expression: '154.9631100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hafnium_156',
      expression: '155.9593500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hafnium_157',
      expression: '156.9582400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hafnium_158',
      expression: '157.9548010000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hafnium_159',
      expression: '158.9539960000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hafnium_160',
      expression: '159.9506910000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hafnium_161',
      expression: '160.9502780000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hafnium_162',
      expression: '161.9472148000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hafnium_163',
      expression: '162.9471130000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hafnium_164',
      expression: '163.9443710000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hafnium_165',
      expression: '164.9445670000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hafnium_166',
      expression: '165.9421800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hafnium_167',
      expression: '166.9426000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hafnium_168',
      expression: '167.9405680000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hafnium_169',
      expression: '168.9412590000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hafnium_170',
      expression: '169.9396090000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hafnium_171',
      expression: '170.9404920000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hafnium_172',
      expression: '171.9394500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hafnium_173',
      expression: '172.9405130000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hafnium_174',
      expression: '173.9400461000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hafnium_175',
      expression: '174.9415092000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hafnium_176',
      expression: '175.9414076000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hafnium_177',
      expression: '176.9432277000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hafnium_178',
      expression: '177.9437058000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hafnium_179',
      expression: '178.9458232000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hafnium_180',
      expression: '179.9465570000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hafnium_181',
      expression: '180.9491083000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hafnium_182',
      expression: '181.9505612000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hafnium_183',
      expression: '182.9535300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hafnium_184',
      expression: '183.9554460000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hafnium_185',
      expression: '184.9588620000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hafnium_186',
      expression: '185.9608970000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hafnium_187',
      expression: '186.9647700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hafnium_188',
      expression: '187.9668500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hafnium_189',
      expression: '188.9708400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hafnium',
      expression:
          '0.00160000 hafnium_174 + 0.05260000 hafnium_176 + 0.18600000 hafnium_177 + 0.27280000 hafnium_178 + 0.13620000 hafnium_179 + 0.35080000 hafnium_180',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tantalum_155',
      expression: '154.9742400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tantalum_156',
      expression: '155.9720300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tantalum_157',
      expression: '156.9681800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tantalum_158',
      expression: '157.9665400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tantalum_159',
      expression: '158.9630230000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tantalum_160',
      expression: '159.9614880000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tantalum_161',
      expression: '160.9584520000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tantalum_162',
      expression: '161.9572940000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tantalum_163',
      expression: '162.9543370000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tantalum_164',
      expression: '163.9535340000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tantalum_165',
      expression: '164.9507810000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tantalum_166',
      expression: '165.9505120000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tantalum_167',
      expression: '166.9480930000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tantalum_168',
      expression: '167.9480470000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tantalum_169',
      expression: '168.9460110000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tantalum_170',
      expression: '169.9461750000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tantalum_171',
      expression: '170.9444760000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tantalum_172',
      expression: '171.9448950000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tantalum_173',
      expression: '172.9437500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tantalum_174',
      expression: '173.9444540000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tantalum_175',
      expression: '174.9437370000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tantalum_176',
      expression: '175.9448570000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tantalum_177',
      expression: '176.9444795000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tantalum_178',
      expression: '177.9456780000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tantalum_179',
      expression: '178.9459366000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tantalum_180',
      expression: '179.9474648000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tantalum_181',
      expression: '180.9479958000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tantalum_182',
      expression: '181.9501519000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tantalum_183',
      expression: '182.9513726000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tantalum_184',
      expression: '183.9540080000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tantalum_185',
      expression: '184.9555590000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tantalum_186',
      expression: '185.9585510000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tantalum_187',
      expression: '186.9603860000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tantalum_188',
      expression: '187.9639160000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tantalum_189',
      expression: '188.9658300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tantalum_190',
      expression: '189.9693900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tantalum_191',
      expression: '190.9715600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tantalum_192',
      expression: '191.9751400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tantalum',
      expression: '0.00012010 tantalum_180 + 0.99987990 tantalum_181',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tungsten_157',
      expression: '156.9788400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tungsten_158',
      expression: '157.9745600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tungsten_159',
      expression: '158.9726400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tungsten_160',
      expression: '159.9684600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tungsten_161',
      expression: '160.9672000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tungsten_162',
      expression: '161.9634990000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tungsten_163',
      expression: '162.9625240000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tungsten_164',
      expression: '163.9589610000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tungsten_165',
      expression: '164.9582810000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tungsten_166',
      expression: '165.9550310000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tungsten_167',
      expression: '166.9548050000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tungsten_168',
      expression: '167.9518060000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tungsten_169',
      expression: '168.9517790000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tungsten_170',
      expression: '169.9492320000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tungsten_171',
      expression: '170.9494510000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tungsten_172',
      expression: '171.9472920000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tungsten_173',
      expression: '172.9476890000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tungsten_174',
      expression: '173.9460790000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tungsten_175',
      expression: '174.9467170000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tungsten_176',
      expression: '175.9456340000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tungsten_177',
      expression: '176.9466430000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tungsten_178',
      expression: '177.9458830000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tungsten_179',
      expression: '178.9470770000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tungsten_180',
      expression: '179.9467108000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tungsten_181',
      expression: '180.9481978000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tungsten_182',
      expression: '181.9482039400',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tungsten_183',
      expression: '182.9502227500',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tungsten_184',
      expression: '183.9509309200',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tungsten_185',
      expression: '184.9534189700',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tungsten_186',
      expression: '185.9543628000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tungsten_187',
      expression: '186.9571588000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tungsten_188',
      expression: '187.9584862000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tungsten_189',
      expression: '188.9617630000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tungsten_190',
      expression: '189.9630910000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tungsten_191',
      expression: '190.9665310000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tungsten_192',
      expression: '191.9681700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tungsten_193',
      expression: '192.9717800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tungsten_194',
      expression: '193.9736700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tungsten',
      expression:
          '0.00120000 tungsten_180 + 0.26500000 tungsten_182 + 0.14310000 tungsten_183 + 0.30640000 tungsten_184 + 0.28430000 tungsten_186',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhenium_159',
      expression: '158.9841800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhenium_160',
      expression: '159.9818200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhenium_161',
      expression: '160.9775700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhenium_162',
      expression: '161.9758400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhenium_163',
      expression: '162.9720800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhenium_164',
      expression: '163.9704530000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhenium_165',
      expression: '164.9671030000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhenium_166',
      expression: '165.9657610000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhenium_167',
      expression: '166.9625950000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhenium_168',
      expression: '167.9615730000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhenium_169',
      expression: '168.9587660000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhenium_170',
      expression: '169.9582200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhenium_171',
      expression: '170.9557160000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhenium_172',
      expression: '171.9554200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhenium_173',
      expression: '172.9532430000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhenium_174',
      expression: '173.9531150000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhenium_175',
      expression: '174.9513810000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhenium_176',
      expression: '175.9516230000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhenium_177',
      expression: '176.9503280000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhenium_178',
      expression: '177.9509890000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhenium_179',
      expression: '178.9499890000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhenium_180',
      expression: '179.9507920000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhenium_181',
      expression: '180.9500580000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhenium_182',
      expression: '181.9512100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhenium_183',
      expression: '182.9508196000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhenium_184',
      expression: '183.9525228000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhenium_185',
      expression: '184.9529545000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhenium_186',
      expression: '185.9549856000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhenium_187',
      expression: '186.9557501000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhenium_188',
      expression: '187.9581115000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhenium_189',
      expression: '188.9592260000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhenium_190',
      expression: '189.9617440000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhenium_191',
      expression: '190.9631220000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhenium_192',
      expression: '191.9660880000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhenium_193',
      expression: '192.9675410000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhenium_194',
      expression: '193.9707600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhenium_195',
      expression: '194.9725400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhenium_196',
      expression: '195.9758000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhenium_197',
      expression: '196.9779900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhenium_198',
      expression: '197.9816000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhenium',
      expression: '0.37400000 rhenium_185 + 0.62600000 rhenium_187',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'osmium_161',
      expression: '160.9890300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'osmium_162',
      expression: '161.9844300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'osmium_163',
      expression: '162.9824100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'osmium_164',
      expression: '163.9780200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'osmium_165',
      expression: '164.9766000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'osmium_166',
      expression: '165.9726920000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'osmium_167',
      expression: '166.9715490000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'osmium_168',
      expression: '167.9678080000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'osmium_169',
      expression: '168.9670180000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'osmium_170',
      expression: '169.9635780000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'osmium_171',
      expression: '170.9631740000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'osmium_172',
      expression: '171.9600170000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'osmium_173',
      expression: '172.9598080000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'osmium_174',
      expression: '173.9570640000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'osmium_175',
      expression: '174.9569450000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'osmium_176',
      expression: '175.9548060000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'osmium_177',
      expression: '176.9549660000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'osmium_178',
      expression: '177.9532540000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'osmium_179',
      expression: '178.9538170000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'osmium_180',
      expression: '179.9523750000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'osmium_181',
      expression: '180.9532470000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'osmium_182',
      expression: '181.9521100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'osmium_183',
      expression: '182.9531250000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'osmium_184',
      expression: '183.9524885000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'osmium_185',
      expression: '184.9540417000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'osmium_186',
      expression: '185.9538350000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'osmium_187',
      expression: '186.9557474000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'osmium_188',
      expression: '187.9558352000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'osmium_189',
      expression: '188.9581442000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'osmium_190',
      expression: '189.9584437000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'osmium_191',
      expression: '190.9609264000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'osmium_192',
      expression: '191.9614770000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'osmium_193',
      expression: '192.9641479000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'osmium_194',
      expression: '193.9651772000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'osmium_195',
      expression: '194.9683180000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'osmium_196',
      expression: '195.9696410000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'osmium_197',
      expression: '196.9728300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'osmium_198',
      expression: '197.9744100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'osmium_199',
      expression: '198.9780100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'osmium_200',
      expression: '199.9798400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'osmium_201',
      expression: '200.9836400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'osmium_202',
      expression: '201.9859500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'osmium',
      expression:
          '0.00020000 osmium_184 + 0.01590000 osmium_186 + 0.01960000 osmium_187 + 0.13240000 osmium_188 + 0.16150000 osmium_189 + 0.26260000 osmium_190 + 0.40780000 osmium_192',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iridium_164',
      expression: '163.9919100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iridium_165',
      expression: '164.9875000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iridium_166',
      expression: '165.9856600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iridium_167',
      expression: '166.9816660000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iridium_168',
      expression: '167.9799070000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iridium_169',
      expression: '168.9762980000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iridium_170',
      expression: '169.9749220000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iridium_171',
      expression: '170.9716400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iridium_172',
      expression: '171.9706070000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iridium_173',
      expression: '172.9675060000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iridium_174',
      expression: '173.9668610000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iridium_175',
      expression: '174.9641500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iridium_176',
      expression: '175.9636500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iridium_177',
      expression: '176.9613010000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iridium_178',
      expression: '177.9610820000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iridium_179',
      expression: '178.9591200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iridium_180',
      expression: '179.9592290000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iridium_181',
      expression: '180.9576250000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iridium_182',
      expression: '181.9580760000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iridium_183',
      expression: '182.9568400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iridium_184',
      expression: '183.9574760000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iridium_185',
      expression: '184.9566980000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iridium_186',
      expression: '185.9579440000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iridium_187',
      expression: '186.9575420000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iridium_188',
      expression: '187.9588280000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iridium_189',
      expression: '188.9587150000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iridium_190',
      expression: '189.9605412000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iridium_191',
      expression: '190.9605893000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iridium_192',
      expression: '191.9626002000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iridium_193',
      expression: '192.9629216000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iridium_194',
      expression: '193.9650735000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iridium_195',
      expression: '194.9659747000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iridium_196',
      expression: '195.9683970000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iridium_197',
      expression: '196.9696550000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iridium_198',
      expression: '197.9722800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iridium_199',
      expression: '198.9738050000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iridium_200',
      expression: '199.9768000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iridium_201',
      expression: '200.9786400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iridium_202',
      expression: '201.9819900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iridium_203',
      expression: '202.9842300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iridium_204',
      expression: '203.9896000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iridium',
      expression: '0.37300000 iridium_191 + 0.62700000 iridium_193',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'platinum_166',
      expression: '165.9948600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'platinum_167',
      expression: '166.9926900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'platinum_168',
      expression: '167.9881300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'platinum_169',
      expression: '168.9865700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'platinum_170',
      expression: '169.9824960000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'platinum_171',
      expression: '170.9812450000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'platinum_172',
      expression: '171.9773510000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'platinum_173',
      expression: '172.9764430000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'platinum_174',
      expression: '173.9728200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'platinum_175',
      expression: '174.9724100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'platinum_176',
      expression: '175.9689380000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'platinum_177',
      expression: '176.9684700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'platinum_178',
      expression: '177.9656500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'platinum_179',
      expression: '178.9653590000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'platinum_180',
      expression: '179.9630320000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'platinum_181',
      expression: '180.9630980000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'platinum_182',
      expression: '181.9611720000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'platinum_183',
      expression: '182.9615970000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'platinum_184',
      expression: '183.9599150000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'platinum_185',
      expression: '184.9606140000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'platinum_186',
      expression: '185.9593510000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'platinum_187',
      expression: '186.9606170000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'platinum_188',
      expression: '187.9593889000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'platinum_189',
      expression: '188.9608310000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'platinum_190',
      expression: '189.9599297000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'platinum_191',
      expression: '190.9616729000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'platinum_192',
      expression: '191.9610387000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'platinum_193',
      expression: '192.9629824000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'platinum_194',
      expression: '193.9626809000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'platinum_195',
      expression: '194.9647917000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'platinum_196',
      expression: '195.9649520900',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'platinum_197',
      expression: '196.9673406900',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'platinum_198',
      expression: '197.9678949000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'platinum_199',
      expression: '198.9705952000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'platinum_200',
      expression: '199.9714430000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'platinum_201',
      expression: '200.9745130000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'platinum_202',
      expression: '201.9756390000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'platinum_203',
      expression: '202.9789300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'platinum_204',
      expression: '203.9807600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'platinum_205',
      expression: '204.9860800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'platinum_206',
      expression: '205.9896600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'platinum',
      expression:
          '0.00012000 platinum_190 + 0.00782000 platinum_192 + 0.32860000 platinum_194 + 0.33780000 platinum_195 + 0.25210000 platinum_196 + 0.07356000 platinum_198',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gold_169',
      expression: '168.9980800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gold_170',
      expression: '169.9959700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gold_171',
      expression: '170.9918760000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gold_172',
      expression: '171.9899420000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gold_173',
      expression: '172.9862410000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gold_174',
      expression: '173.9847170000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gold_175',
      expression: '174.9813040000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gold_176',
      expression: '175.9802500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gold_177',
      expression: '176.9768700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gold_178',
      expression: '177.9760320000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gold_179',
      expression: '178.9731740000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gold_180',
      expression: '179.9725230000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gold_181',
      expression: '180.9700790000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gold_182',
      expression: '181.9696180000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gold_183',
      expression: '182.9675910000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gold_184',
      expression: '183.9674520000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gold_185',
      expression: '184.9657900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gold_186',
      expression: '185.9659530000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gold_187',
      expression: '186.9645430000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gold_188',
      expression: '187.9653490000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gold_189',
      expression: '188.9639480000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gold_190',
      expression: '189.9646980000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gold_191',
      expression: '190.9637020000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gold_192',
      expression: '191.9648140000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gold_193',
      expression: '192.9641373000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gold_194',
      expression: '193.9654178000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gold_195',
      expression: '194.9650352000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gold_196',
      expression: '195.9665699000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gold_197',
      aliases: ['gold'],
      expression: '196.9665687900',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gold_198',
      expression: '197.9682424200',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gold_199',
      expression: '198.9687652800',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gold_200',
      expression: '199.9707560000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gold_201',
      expression: '200.9716575000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gold_202',
      expression: '201.9738560000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gold_203',
      expression: '202.9751544000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gold_204',
      expression: '203.9778300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gold_205',
      expression: '204.9798500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gold_206',
      expression: '205.9847400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gold_207',
      expression: '206.9884000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gold_208',
      expression: '207.9934500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gold_209',
      expression: '208.9973500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gold_210',
      expression: '210.0025000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mercury_171',
      expression: '171.0035300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mercury_172',
      expression: '171.9988100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mercury_173',
      expression: '172.9970900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mercury_174',
      expression: '173.9928650000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mercury_175',
      expression: '174.9914410000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mercury_176',
      expression: '175.9873610000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mercury_177',
      expression: '176.9862770000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mercury_178',
      expression: '177.9824840000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mercury_179',
      expression: '178.9818310000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mercury_180',
      expression: '179.9782600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mercury_181',
      expression: '180.9778190000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mercury_182',
      expression: '181.9746890000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mercury_183',
      expression: '182.9744448000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mercury_184',
      expression: '183.9717140000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mercury_185',
      expression: '184.9718990000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mercury_186',
      expression: '185.9693620000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mercury_187',
      expression: '186.9698140000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mercury_188',
      expression: '187.9675670000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mercury_189',
      expression: '188.9681950000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mercury_190',
      expression: '189.9663230000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mercury_191',
      expression: '190.9671570000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mercury_192',
      expression: '191.9656350000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mercury_193',
      expression: '192.9666530000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mercury_194',
      expression: '193.9654491000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mercury_195',
      expression: '194.9667210000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mercury_196',
      expression: '195.9658326000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mercury_197',
      expression: '196.9672128000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mercury_198',
      expression: '197.9667686000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mercury_199',
      expression: '198.9682806400',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mercury_200',
      expression: '199.9683265900',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mercury_201',
      expression: '200.9703028400',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mercury_202',
      expression: '201.9706434000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mercury_203',
      expression: '202.9728728000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mercury_204',
      expression: '203.9734939800',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mercury_205',
      expression: '204.9760734000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mercury_206',
      expression: '205.9775140000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mercury_207',
      expression: '206.9823000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mercury_208',
      expression: '207.9857590000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mercury_209',
      expression: '208.9907200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mercury_210',
      expression: '209.9942400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mercury_211',
      expression: '210.9993300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mercury_212',
      expression: '212.0029600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mercury_213',
      expression: '213.0082300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mercury_214',
      expression: '214.0120000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mercury_215',
      expression: '215.0174000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mercury_216',
      expression: '216.0213200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mercury',
      expression:
          '0.00150000 mercury_196 + 0.09970000 mercury_198 + 0.16870000 mercury_199 + 0.23100000 mercury_200 + 0.13180000 mercury_201 + 0.29860000 mercury_202 + 0.06870000 mercury_204',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thallium_176',
      expression: '176.0006240000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thallium_177',
      expression: '176.9964310000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thallium_178',
      expression: '177.9948500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thallium_179',
      expression: '178.9911110000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thallium_180',
      expression: '179.9900570000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thallium_181',
      expression: '180.9862600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thallium_182',
      expression: '181.9857130000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thallium_183',
      expression: '182.9821930000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thallium_184',
      expression: '183.9818860000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thallium_185',
      expression: '184.9787890000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thallium_186',
      expression: '185.9786510000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thallium_187',
      expression: '186.9759063000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thallium_188',
      expression: '187.9760210000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thallium_189',
      expression: '188.9735880000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thallium_190',
      expression: '189.9738280000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thallium_191',
      expression: '190.9717842000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thallium_192',
      expression: '191.9722250000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thallium_193',
      expression: '192.9705020000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thallium_194',
      expression: '193.9710810000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thallium_195',
      expression: '194.9697740000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thallium_196',
      expression: '195.9704810000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thallium_197',
      expression: '196.9695760000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thallium_198',
      expression: '197.9704830000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thallium_199',
      expression: '198.9698770000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thallium_200',
      expression: '199.9709633000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thallium_201',
      expression: '200.9708220000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thallium_202',
      expression: '201.9721020000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thallium_203',
      expression: '202.9723446000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thallium_204',
      expression: '203.9738639000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thallium_205',
      expression: '204.9744278000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thallium_206',
      expression: '205.9761106000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thallium_207',
      expression: '206.9774197000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thallium_208',
      expression: '207.9820190000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thallium_209',
      expression: '208.9853594000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thallium_210',
      expression: '209.9900740000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thallium_211',
      expression: '210.9934750000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thallium_212',
      expression: '211.9983400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thallium_213',
      expression: '213.0019150000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thallium_214',
      expression: '214.0069400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thallium_215',
      expression: '215.0106400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thallium_216',
      expression: '216.0158000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thallium_217',
      expression: '217.0196600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thallium_218',
      expression: '218.0247900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thallium',
      expression: '0.29520000 thallium_203 + 0.70480000 thallium_205',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lead_178',
      expression: '178.0038310000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lead_179',
      expression: '179.0022010000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lead_180',
      expression: '179.9979280000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lead_181',
      expression: '180.9966530000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lead_182',
      expression: '181.9926720000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lead_183',
      expression: '182.9918720000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lead_184',
      expression: '183.9881360000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lead_185',
      expression: '184.9876100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lead_186',
      expression: '185.9842380000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lead_187',
      expression: '186.9839109000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lead_188',
      expression: '187.9808750000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lead_189',
      expression: '188.9808070000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lead_190',
      expression: '189.9780820000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lead_191',
      expression: '190.9782760000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lead_192',
      expression: '191.9757750000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lead_193',
      expression: '192.9761730000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lead_194',
      expression: '193.9740120000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lead_195',
      expression: '194.9745430000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lead_196',
      expression: '195.9727740000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lead_197',
      expression: '196.9734312000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lead_198',
      expression: '197.9720340000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lead_199',
      expression: '198.9729130000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lead_200',
      expression: '199.9718190000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lead_201',
      expression: '200.9728830000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lead_202',
      expression: '201.9721520000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lead_203',
      expression: '202.9733911000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lead_204',
      expression: '203.9730440000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lead_205',
      expression: '204.9744822000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lead_206',
      expression: '205.9744657000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lead_207',
      expression: '206.9758973000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lead_208',
      expression: '207.9766525000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lead_209',
      expression: '208.9810905000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lead_210',
      expression: '209.9841889000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lead_211',
      expression: '210.9887371000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lead_212',
      expression: '211.9918977000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lead_213',
      expression: '212.9965629000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lead_214',
      expression: '213.9998059000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lead_215',
      expression: '215.0047400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lead_216',
      expression: '216.0080300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lead_217',
      expression: '217.0131400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lead_218',
      expression: '218.0165900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lead_219',
      expression: '219.0217700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lead_220',
      expression: '220.0254100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lead',
      expression:
          '0.01400000 lead_204 + 0.24100000 lead_206 + 0.22100000 lead_207 + 0.52400000 lead_208',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bismuth_184',
      expression: '184.0012750000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bismuth_185',
      expression: '184.9976000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bismuth_186',
      expression: '185.9966440000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bismuth_187',
      expression: '186.9931470000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bismuth_188',
      expression: '187.9922870000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bismuth_189',
      expression: '188.9891950000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bismuth_190',
      expression: '189.9886220000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bismuth_191',
      expression: '190.9857866000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bismuth_192',
      expression: '191.9854690000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bismuth_193',
      expression: '192.9829600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bismuth_194',
      expression: '193.9827850000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bismuth_195',
      expression: '194.9806488000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bismuth_196',
      expression: '195.9806670000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bismuth_197',
      expression: '196.9788651000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bismuth_198',
      expression: '197.9792060000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bismuth_199',
      expression: '198.9776730000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bismuth_200',
      expression: '199.9781310000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bismuth_201',
      expression: '200.9770100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bismuth_202',
      expression: '201.9777340000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bismuth_203',
      expression: '202.9768930000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bismuth_204',
      expression: '203.9778361000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bismuth_205',
      expression: '204.9773867000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bismuth_206',
      expression: '205.9784993000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bismuth_207',
      expression: '206.9784710000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bismuth_208',
      expression: '207.9797425000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bismuth_209',
      aliases: ['bismuth'],
      expression: '208.9803991000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bismuth_210',
      expression: '209.9841207000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bismuth_211',
      expression: '210.9872697000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bismuth_212',
      expression: '211.9912860000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bismuth_213',
      expression: '212.9943851000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bismuth_214',
      expression: '213.9987120000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bismuth_215',
      expression: '215.0017700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bismuth_216',
      expression: '216.0063060000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bismuth_217',
      expression: '217.0093720000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bismuth_218',
      expression: '218.0141880000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bismuth_219',
      expression: '219.0174800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bismuth_220',
      expression: '220.0223500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bismuth_221',
      expression: '221.0258700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bismuth_222',
      expression: '222.0307800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bismuth_223',
      expression: '223.0345000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bismuth_224',
      expression: '224.0394700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'polonium_186',
      expression: '186.0043930000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'polonium_187',
      expression: '187.0030410000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'polonium_188',
      expression: '187.9994160000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'polonium_189',
      expression: '188.9984730000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'polonium_190',
      expression: '189.9951010000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'polonium_191',
      expression: '190.9945585000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'polonium_192',
      expression: '191.9913360000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'polonium_193',
      expression: '192.9910260000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'polonium_194',
      expression: '193.9881860000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'polonium_195',
      expression: '194.9881260000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'polonium_196',
      expression: '195.9855260000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'polonium_197',
      expression: '196.9856600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'polonium_198',
      expression: '197.9833890000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'polonium_199',
      expression: '198.9836670000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'polonium_200',
      expression: '199.9817990000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'polonium_201',
      expression: '200.9822598000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'polonium_202',
      expression: '201.9807580000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'polonium_203',
      expression: '202.9814161000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'polonium_204',
      expression: '203.9803100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'polonium_205',
      expression: '204.9812030000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'polonium_206',
      expression: '205.9804740000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'polonium_207',
      expression: '206.9815938000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'polonium_208',
      expression: '207.9812461000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'polonium_209',
      aliases: ['polonium'],
      expression: '208.9824308000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'polonium_210',
      expression: '209.9828741000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'polonium_211',
      expression: '210.9866536000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'polonium_212',
      expression: '211.9888684000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'polonium_213',
      expression: '212.9928576000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'polonium_214',
      expression: '213.9952017000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'polonium_215',
      expression: '214.9994201000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'polonium_216',
      expression: '216.0019152000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'polonium_217',
      expression: '217.0063182000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'polonium_218',
      expression: '218.0089735000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'polonium_219',
      expression: '219.0136140000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'polonium_220',
      expression: '220.0163860000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'polonium_221',
      expression: '221.0212280000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'polonium_222',
      expression: '222.0241400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'polonium_223',
      expression: '223.0290700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'polonium_224',
      expression: '224.0321100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'polonium_225',
      expression: '225.0370700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'polonium_226',
      expression: '226.0403100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'polonium_227',
      expression: '227.0453900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'astatine_191',
      expression: '191.0041480000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'astatine_192',
      expression: '192.0031520000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'astatine_193',
      expression: '192.9999270000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'astatine_194',
      expression: '193.9992360000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'astatine_195',
      expression: '194.9962685000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'astatine_196',
      expression: '195.9958000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'astatine_197',
      expression: '196.9931890000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'astatine_198',
      expression: '197.9927840000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'astatine_199',
      expression: '198.9905277000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'astatine_200',
      expression: '199.9903510000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'astatine_201',
      expression: '200.9884171000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'astatine_202',
      expression: '201.9886300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'astatine_203',
      expression: '202.9869430000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'astatine_204',
      expression: '203.9872510000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'astatine_205',
      expression: '204.9860760000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'astatine_206',
      expression: '205.9866570000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'astatine_207',
      expression: '206.9858000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'astatine_208',
      expression: '207.9866133000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'astatine_209',
      expression: '208.9861702000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'astatine_210',
      aliases: ['astatine'],
      expression: '209.9871479000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'astatine_211',
      expression: '210.9874966000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'astatine_212',
      expression: '211.9907377000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'astatine_213',
      expression: '212.9929370000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'astatine_214',
      expression: '213.9963721000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'astatine_215',
      expression: '214.9986528000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'astatine_216',
      expression: '216.0024236000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'astatine_217',
      expression: '217.0047192000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'astatine_218',
      expression: '218.0086950000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'astatine_219',
      expression: '219.0111618000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'astatine_220',
      expression: '220.0154330000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'astatine_221',
      expression: '221.0180170000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'astatine_222',
      expression: '222.0224940000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'astatine_223',
      expression: '223.0251510000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'astatine_224',
      expression: '224.0297490000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'astatine_225',
      expression: '225.0326300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'astatine_226',
      expression: '226.0371600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'astatine_227',
      expression: '227.0402400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'astatine_228',
      expression: '228.0447500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'astatine_229',
      expression: '229.0481200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'radon_193',
      expression: '193.0097080000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'radon_194',
      expression: '194.0061440000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'radon_195',
      expression: '195.0054220000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'radon_196',
      expression: '196.0021160000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'radon_197',
      expression: '197.0015850000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'radon_198',
      expression: '197.9986790000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'radon_199',
      expression: '198.9983900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'radon_200',
      expression: '199.9956900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'radon_201',
      expression: '200.9956280000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'radon_202',
      expression: '201.9932640000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'radon_203',
      expression: '202.9933880000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'radon_204',
      expression: '203.9914300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'radon_205',
      expression: '204.9917190000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'radon_206',
      expression: '205.9902140000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'radon_207',
      expression: '206.9907303000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'radon_208',
      expression: '207.9896350000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'radon_209',
      expression: '208.9904150000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'radon_210',
      expression: '209.9896891000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'radon_211',
      expression: '210.9906011000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'radon_212',
      expression: '211.9907039000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'radon_213',
      expression: '212.9938831000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'radon_214',
      expression: '213.9953630000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'radon_215',
      expression: '214.9987459000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'radon_216',
      expression: '216.0002719000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'radon_217',
      expression: '217.0039280000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'radon_218',
      expression: '218.0056016000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'radon_219',
      expression: '219.0094804000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'radon_220',
      expression: '220.0113941000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'radon_221',
      expression: '221.0155371000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'radon_222',
      aliases: ['radon'],
      expression: '222.0175782000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'radon_223',
      expression: '223.0218893000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'radon_224',
      expression: '224.0240960000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'radon_225',
      expression: '225.0284860000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'radon_226',
      expression: '226.0308610000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'radon_227',
      expression: '227.0353040000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'radon_228',
      expression: '228.0378350000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'radon_229',
      expression: '229.0422570000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'radon_230',
      expression: '230.0451400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'radon_231',
      expression: '231.0498700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'francium_199',
      expression: '199.0072590000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'francium_200',
      expression: '200.0065860000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'francium_201',
      expression: '201.0038670000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'francium_202',
      expression: '202.0033200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'francium_203',
      expression: '203.0009407000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'francium_204',
      expression: '204.0006520000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'francium_205',
      expression: '204.9985939000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'francium_206',
      expression: '205.9986660000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'francium_207',
      expression: '206.9969460000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'francium_208',
      expression: '207.9971380000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'francium_209',
      expression: '208.9959550000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'francium_210',
      expression: '209.9964220000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'francium_211',
      expression: '210.9955560000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'francium_212',
      expression: '211.9962257000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'francium_213',
      expression: '212.9961860000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'francium_214',
      expression: '213.9989713000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'francium_215',
      expression: '215.0003418000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'francium_216',
      expression: '216.0031899000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'francium_217',
      expression: '217.0046323000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'francium_218',
      expression: '218.0075787000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'francium_219',
      expression: '219.0092524000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'francium_220',
      expression: '220.0123277000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'francium_221',
      expression: '221.0142552000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'francium_222',
      expression: '222.0175520000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'francium_223',
      aliases: ['francium'],
      expression: '223.0197360000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'francium_224',
      expression: '224.0233980000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'francium_225',
      expression: '225.0255730000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'francium_226',
      expression: '226.0295660000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'francium_227',
      expression: '227.0318690000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'francium_228',
      expression: '228.0358230000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'francium_229',
      expression: '229.0382980000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'francium_230',
      expression: '230.0424160000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'francium_231',
      expression: '231.0451580000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'francium_232',
      expression: '232.0493700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'francium_233',
      expression: '233.0526400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'radium_201',
      expression: '201.0127100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'radium_202',
      expression: '202.0097600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'radium_203',
      expression: '203.0093040000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'radium_204',
      expression: '204.0064920000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'radium_205',
      expression: '205.0062680000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'radium_206',
      expression: '206.0038280000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'radium_207',
      expression: '207.0037990000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'radium_208',
      expression: '208.0018410000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'radium_209',
      expression: '209.0019900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'radium_210',
      expression: '210.0004940000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'radium_211',
      expression: '211.0008932000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'radium_212',
      expression: '211.9997870000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'radium_213',
      expression: '213.0003840000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'radium_214',
      expression: '214.0000997000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'radium_215',
      expression: '215.0027204000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'radium_216',
      expression: '216.0035334000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'radium_217',
      expression: '217.0063207000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'radium_218',
      expression: '218.0071410000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'radium_219',
      expression: '219.0100855000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'radium_220',
      expression: '220.0110259000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'radium_221',
      expression: '221.0139177000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'radium_222',
      expression: '222.0153748000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'radium_223',
      expression: '223.0185023000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'radium_224',
      expression: '224.0202120000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'radium_225',
      expression: '225.0236119000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'radium_226',
      aliases: ['radium'],
      expression: '226.0254103000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'radium_227',
      expression: '227.0291783000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'radium_228',
      expression: '228.0310707000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'radium_229',
      expression: '229.0349420000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'radium_230',
      expression: '230.0370550000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'radium_231',
      expression: '231.0410270000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'radium_232',
      expression: '232.0434753000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'radium_233',
      expression: '233.0475820000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'radium_234',
      expression: '234.0503420000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'radium_235',
      expression: '235.0549700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'actinium_206',
      expression: '206.0144520000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'actinium_207',
      expression: '207.0119660000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'actinium_208',
      expression: '208.0115500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'actinium_209',
      expression: '209.0094950000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'actinium_210',
      expression: '210.0094360000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'actinium_211',
      expression: '211.0077320000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'actinium_212',
      expression: '212.0078130000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'actinium_213',
      expression: '213.0066090000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'actinium_214',
      expression: '214.0069180000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'actinium_215',
      expression: '215.0064750000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'actinium_216',
      expression: '216.0087430000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'actinium_217',
      expression: '217.0093440000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'actinium_218',
      expression: '218.0116420000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'actinium_219',
      expression: '219.0124210000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'actinium_220',
      expression: '220.0147549000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'actinium_221',
      expression: '221.0155920000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'actinium_222',
      expression: '222.0178442000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'actinium_223',
      expression: '223.0191377000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'actinium_224',
      expression: '224.0217232000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'actinium_225',
      expression: '225.0232300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'actinium_226',
      expression: '226.0260984000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'actinium_227',
      aliases: ['actinium'],
      expression: '227.0277523000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'actinium_228',
      expression: '228.0310215000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'actinium_229',
      expression: '229.0329560000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'actinium_230',
      expression: '230.0363270000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'actinium_231',
      expression: '231.0383930000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'actinium_232',
      expression: '232.0420340000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'actinium_233',
      expression: '233.0443460000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'actinium_234',
      expression: '234.0481390000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'actinium_235',
      expression: '235.0508400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'actinium_236',
      expression: '236.0549880000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'actinium_237',
      expression: '237.0582700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thorium_208',
      expression: '208.0179000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thorium_209',
      expression: '209.0177530000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thorium_210',
      expression: '210.0150940000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thorium_211',
      expression: '211.0149290000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thorium_212',
      expression: '212.0129880000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thorium_213',
      expression: '213.0130090000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thorium_214',
      expression: '214.0115000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thorium_215',
      expression: '215.0117248000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thorium_216',
      expression: '216.0110560000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thorium_217',
      expression: '217.0131170000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thorium_218',
      expression: '218.0132760000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thorium_219',
      expression: '219.0155370000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thorium_220',
      expression: '220.0157480000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thorium_221',
      expression: '221.0181840000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thorium_222',
      expression: '222.0184690000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thorium_223',
      expression: '223.0208119000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thorium_224',
      expression: '224.0214640000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thorium_225',
      expression: '225.0239514000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thorium_226',
      expression: '226.0249034000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thorium_227',
      expression: '227.0277042000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thorium_228',
      expression: '228.0287413000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thorium_229',
      expression: '229.0317627000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thorium_230',
      expression: '230.0331341000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thorium_231',
      expression: '231.0363046000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thorium_232',
      aliases: ['thorium'],
      expression: '232.0380558000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thorium_233',
      expression: '233.0415823000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thorium_234',
      expression: '234.0436014000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thorium_235',
      expression: '235.0472550000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thorium_236',
      expression: '236.0496570000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thorium_237',
      expression: '237.0536290000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thorium_238',
      expression: '238.0565000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thorium_239',
      expression: '239.0607700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'protactinium_212',
      expression: '212.0232030000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'protactinium_213',
      expression: '213.0211090000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'protactinium_214',
      expression: '214.0209180000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'protactinium_215',
      expression: '215.0191830000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'protactinium_216',
      expression: '216.0191090000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'protactinium_217',
      expression: '217.0183250000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'protactinium_218',
      expression: '218.0200590000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'protactinium_219',
      expression: '219.0199040000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'protactinium_220',
      expression: '220.0217050000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'protactinium_221',
      expression: '221.0218750000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'protactinium_222',
      expression: '222.0237840000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'protactinium_223',
      expression: '223.0239630000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'protactinium_224',
      expression: '224.0256176000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'protactinium_225',
      expression: '225.0261310000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'protactinium_226',
      expression: '226.0279480000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'protactinium_227',
      expression: '227.0288054000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'protactinium_228',
      expression: '228.0310517000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'protactinium_229',
      expression: '229.0320972000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'protactinium_230',
      expression: '230.0345410000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'protactinium_231',
      aliases: ['protactinium'],
      expression: '231.0358842000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'protactinium_232',
      expression: '232.0385917000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'protactinium_233',
      expression: '233.0402472000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'protactinium_234',
      expression: '234.0433072000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'protactinium_235',
      expression: '235.0453990000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'protactinium_236',
      expression: '236.0486680000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'protactinium_237',
      expression: '237.0510230000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'protactinium_238',
      expression: '238.0546370000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'protactinium_239',
      expression: '239.0572600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'protactinium_240',
      expression: '240.0609800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'protactinium_241',
      expression: '241.0640800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'uranium_217',
      expression: '217.0246600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'uranium_218',
      expression: '218.0235230000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'uranium_219',
      expression: '219.0249990000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'uranium_220',
      expression: '220.0246200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'uranium_221',
      expression: '221.0262800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'uranium_222',
      expression: '222.0260000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'uranium_223',
      expression: '223.0277390000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'uranium_224',
      expression: '224.0276050000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'uranium_225',
      expression: '225.0293910000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'uranium_226',
      expression: '226.0293390000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'uranium_227',
      expression: '227.0311570000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'uranium_228',
      expression: '228.0313710000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'uranium_229',
      expression: '229.0335063000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'uranium_230',
      expression: '230.0339401000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'uranium_231',
      expression: '231.0362939000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'uranium_232',
      expression: '232.0371563000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'uranium_233',
      expression: '233.0396355000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'uranium_234',
      expression: '234.0409523000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'uranium_235',
      expression: '235.0439301000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'uranium_236',
      expression: '236.0455682000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'uranium_237',
      expression: '237.0487304000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'uranium_238',
      expression: '238.0507884000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'uranium_239',
      expression: '239.0542935000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'uranium_240',
      expression: '240.0565934000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'uranium_241',
      expression: '241.0603300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'uranium_242',
      expression: '242.0629300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'uranium_243',
      expression: '243.0669900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'uranium',
      expression:
          '0.00005400 uranium_234 + 0.00720400 uranium_235 + 0.99274200 uranium_238',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neptunium_219',
      expression: '219.0314300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neptunium_220',
      expression: '220.0325400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neptunium_221',
      expression: '221.0320400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neptunium_222',
      expression: '222.0333000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neptunium_223',
      expression: '223.0328500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neptunium_224',
      expression: '224.0342200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neptunium_225',
      expression: '225.0339110000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neptunium_226',
      expression: '226.0351880000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neptunium_227',
      expression: '227.0349570000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neptunium_228',
      expression: '228.0360670000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neptunium_229',
      expression: '229.0362640000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neptunium_230',
      expression: '230.0378280000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neptunium_231',
      expression: '231.0382450000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neptunium_232',
      expression: '232.0401100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neptunium_233',
      expression: '233.0407410000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neptunium_234',
      expression: '234.0428953000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neptunium_235',
      expression: '235.0440635000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neptunium_236',
      expression: '236.0465700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neptunium_237',
      aliases: ['neptunium'],
      expression: '237.0481736000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neptunium_238',
      expression: '238.0509466000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neptunium_239',
      expression: '239.0529392000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neptunium_240',
      expression: '240.0561650000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neptunium_241',
      expression: '241.0582530000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neptunium_242',
      expression: '242.0616400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neptunium_243',
      expression: '243.0642800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neptunium_244',
      expression: '244.0678500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neptunium_245',
      expression: '245.0708000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'plutonium_228',
      expression: '228.0387320000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'plutonium_229',
      expression: '229.0401440000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'plutonium_230',
      expression: '230.0396500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'plutonium_231',
      expression: '231.0411020000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'plutonium_232',
      expression: '232.0411850000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'plutonium_233',
      expression: '233.0429980000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'plutonium_234',
      expression: '234.0433174000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'plutonium_235',
      expression: '235.0452860000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'plutonium_236',
      expression: '236.0460581000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'plutonium_237',
      expression: '237.0484098000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'plutonium_238',
      expression: '238.0495601000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'plutonium_239',
      expression: '239.0521636000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'plutonium_240',
      expression: '240.0538138000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'plutonium_241',
      expression: '241.0568517000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'plutonium_242',
      expression: '242.0587428000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'plutonium_243',
      expression: '243.0620036000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'plutonium_244',
      aliases: ['plutonium'],
      expression: '244.0642053000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'plutonium_245',
      expression: '245.0678260000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'plutonium_246',
      expression: '246.0702050000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'plutonium_247',
      expression: '247.0741900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'americium_230',
      expression: '230.0460900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'americium_231',
      expression: '231.0455600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'americium_232',
      expression: '232.0464500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'americium_233',
      expression: '233.0464400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'americium_234',
      expression: '234.0477300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'americium_235',
      expression: '235.0479080000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'americium_236',
      expression: '236.0494300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'americium_237',
      expression: '237.0499960000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'americium_238',
      expression: '238.0519850000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'americium_239',
      expression: '239.0530247000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'americium_240',
      expression: '240.0553000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'americium_241',
      expression: '241.0568293000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'americium_242',
      expression: '242.0595494000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'americium_243',
      expression: '243.0613813000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'americium_244',
      expression: '244.0642851000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'americium_245',
      expression: '245.0664548000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'americium_246',
      expression: '246.0697750000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'americium_247',
      expression: '247.0720900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'americium_248',
      expression: '248.0757500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'americium_249',
      expression: '249.0784800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'curium_232',
      expression: '232.0498200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'curium_233',
      expression: '233.0507700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'curium_234',
      expression: '234.0501600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'curium_235',
      expression: '235.0515400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'curium_236',
      expression: '236.0513740000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'curium_237',
      expression: '237.0528690000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'curium_238',
      expression: '238.0530810000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'curium_239',
      expression: '239.0549100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'curium_240',
      expression: '240.0555297000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'curium_241',
      expression: '241.0576532000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'curium_242',
      expression: '242.0588360000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'curium_243',
      expression: '243.0613893000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'curium_244',
      expression: '244.0627528000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'curium_245',
      expression: '245.0654915000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'curium_246',
      expression: '246.0672238000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'curium_247',
      expression: '247.0703541000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'curium_248',
      expression: '248.0723499000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'curium_249',
      expression: '249.0759548000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'curium_250',
      expression: '250.0783580000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'curium_251',
      expression: '251.0822860000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'curium_252',
      expression: '252.0848700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'berkelium_234',
      expression: '234.0572700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'berkelium_235',
      expression: '235.0565800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'berkelium_236',
      expression: '236.0574800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'berkelium_237',
      expression: '237.0571000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'berkelium_238',
      expression: '238.0582000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'berkelium_239',
      expression: '239.0582400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'berkelium_240',
      expression: '240.0597600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'berkelium_241',
      expression: '241.0601600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'berkelium_242',
      expression: '242.0619800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'berkelium_243',
      expression: '243.0630078000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'berkelium_244',
      expression: '244.0651810000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'berkelium_245',
      expression: '245.0663618000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'berkelium_246',
      expression: '246.0686730000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'berkelium_247',
      expression: '247.0703073000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'berkelium_248',
      expression: '248.0730880000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'berkelium_249',
      expression: '249.0749877000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'berkelium_250',
      expression: '250.0783167000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'berkelium_251',
      expression: '251.0807620000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'berkelium_252',
      expression: '252.0843100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'berkelium_253',
      expression: '253.0868800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'berkelium_254',
      expression: '254.0906000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'californium_237',
      expression: '237.0621980000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'californium_238',
      expression: '238.0614900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'californium_239',
      expression: '239.0625300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'californium_240',
      expression: '240.0622560000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'californium_241',
      expression: '241.0636900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'californium_242',
      expression: '242.0637540000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'californium_243',
      expression: '243.0654800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'californium_244',
      expression: '244.0660008000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'californium_245',
      expression: '245.0680487000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'californium_246',
      expression: '246.0688055000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'californium_247',
      expression: '247.0709650000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'californium_248',
      expression: '248.0721851000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'californium_249',
      expression: '249.0748539000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'californium_250',
      expression: '250.0764062000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'californium_251',
      expression: '251.0795886000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'californium_252',
      expression: '252.0816272000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'californium_253',
      expression: '253.0851345000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'californium_254',
      expression: '254.0873240000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'californium_255',
      expression: '255.0910500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'californium_256',
      expression: '256.0934400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'einsteinium_239',
      expression: '239.0682300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'einsteinium_240',
      expression: '240.0689200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'einsteinium_241',
      expression: '241.0685600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'einsteinium_242',
      expression: '242.0695700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'einsteinium_243',
      expression: '243.0695100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'einsteinium_244',
      expression: '244.0708800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'einsteinium_245',
      expression: '245.0712500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'einsteinium_246',
      expression: '246.0729000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'einsteinium_247',
      expression: '247.0736220000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'einsteinium_248',
      expression: '248.0754710000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'einsteinium_249',
      expression: '249.0764110000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'einsteinium_250',
      expression: '250.0786100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'einsteinium_251',
      expression: '251.0799936000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'einsteinium_252',
      expression: '252.0829800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'einsteinium_253',
      expression: '253.0848257000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'einsteinium_254',
      expression: '254.0880222000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'einsteinium_255',
      expression: '255.0902750000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'einsteinium_256',
      expression: '256.0936000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'einsteinium_257',
      expression: '257.0959800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'einsteinium_258',
      expression: '258.0995200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'fermium_241',
      expression: '241.0742100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'fermium_242',
      expression: '242.0734300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'fermium_243',
      expression: '243.0744600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'fermium_244',
      expression: '244.0740400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'fermium_245',
      expression: '245.0753500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'fermium_246',
      expression: '246.0753500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'fermium_247',
      expression: '247.0769400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'fermium_248',
      expression: '248.0771865000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'fermium_249',
      expression: '249.0789275000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'fermium_250',
      expression: '250.0795210000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'fermium_251',
      expression: '251.0815400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'fermium_252',
      expression: '252.0824671000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'fermium_253',
      expression: '253.0851846000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'fermium_254',
      expression: '254.0868544000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'fermium_255',
      expression: '255.0899640000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'fermium_256',
      expression: '256.0917745000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'fermium_257',
      expression: '257.0951061000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'fermium_258',
      expression: '258.0970800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'fermium_259',
      expression: '259.1006000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'fermium_260',
      expression: '260.1028100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mendelevium_245',
      expression: '245.0808100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mendelevium_246',
      expression: '246.0817100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mendelevium_247',
      expression: '247.0815200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mendelevium_248',
      expression: '248.0828200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mendelevium_249',
      expression: '249.0829100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mendelevium_250',
      expression: '250.0844100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mendelevium_251',
      expression: '251.0847740000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mendelevium_252',
      expression: '252.0864300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mendelevium_253',
      expression: '253.0871440000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mendelevium_254',
      expression: '254.0895900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mendelevium_255',
      expression: '255.0910841000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mendelevium_256',
      expression: '256.0938900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mendelevium_257',
      expression: '257.0955424000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mendelevium_258',
      expression: '258.0984315000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mendelevium_259',
      expression: '259.1005100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mendelevium_260',
      expression: '260.1036500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mendelevium_261',
      expression: '261.1058300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mendelevium_262',
      expression: '262.1091000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nobelium_248',
      expression: '248.0865500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nobelium_249',
      expression: '249.0878000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nobelium_250',
      expression: '250.0875600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nobelium_251',
      expression: '251.0889400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nobelium_252',
      expression: '252.0889670000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nobelium_253',
      expression: '253.0905641000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nobelium_254',
      expression: '254.0909560000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nobelium_255',
      expression: '255.0931910000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nobelium_256',
      expression: '256.0942829000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nobelium_257',
      expression: '257.0968878000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nobelium_258',
      expression: '258.0982100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nobelium_259',
      expression: '259.1010300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nobelium_260',
      expression: '260.1026400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nobelium_261',
      expression: '261.1057000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nobelium_262',
      expression: '262.1074600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nobelium_263',
      expression: '263.1107100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nobelium_264',
      expression: '264.1127300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lawrencium_251',
      expression: '251.0941800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lawrencium_252',
      expression: '252.0952600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lawrencium_253',
      expression: '253.0950900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lawrencium_254',
      expression: '254.0964800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lawrencium_255',
      expression: '255.0965620000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lawrencium_256',
      expression: '256.0984940000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lawrencium_257',
      expression: '257.0994180000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lawrencium_258',
      expression: '258.1017600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lawrencium_259',
      expression: '259.1029020000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lawrencium_260',
      expression: '260.1055000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lawrencium_261',
      expression: '261.1068800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lawrencium_262',
      expression: '262.1096100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lawrencium_263',
      expression: '263.1113600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lawrencium_264',
      expression: '264.1142000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lawrencium_265',
      expression: '265.1161900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lawrencium_266',
      expression: '266.1198300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rutherfordium_253',
      expression: '253.1004400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rutherfordium_254',
      expression: '254.1000500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rutherfordium_255',
      expression: '255.1012700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rutherfordium_256',
      expression: '256.1011520000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rutherfordium_257',
      expression: '257.1029180000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rutherfordium_258',
      expression: '258.1034280000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rutherfordium_259',
      expression: '259.1055960000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rutherfordium_260',
      expression: '260.1064400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rutherfordium_261',
      expression: '261.1087730000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rutherfordium_262',
      expression: '262.1099200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rutherfordium_263',
      expression: '263.1124900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rutherfordium_264',
      expression: '264.1138800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rutherfordium_265',
      expression: '265.1166800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rutherfordium_266',
      expression: '266.1181700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rutherfordium_267',
      expression: '267.1217900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rutherfordium_268',
      expression: '268.1239700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'dubnium_255',
      expression: '255.1070700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'dubnium_256',
      expression: '256.1078900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'dubnium_257',
      expression: '257.1075800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'dubnium_258',
      expression: '258.1092800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'dubnium_259',
      expression: '259.1094920000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'dubnium_260',
      expression: '260.1113000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'dubnium_261',
      expression: '261.1119200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'dubnium_262',
      expression: '262.1140700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'dubnium_263',
      expression: '263.1149900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'dubnium_264',
      expression: '264.1174100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'dubnium_265',
      expression: '265.1186100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'dubnium_266',
      expression: '266.1210300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'dubnium_267',
      expression: '267.1224700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'dubnium_268',
      expression: '268.1256700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'dubnium_269',
      expression: '269.1279100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'dubnium_270',
      expression: '270.1313600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'seaborgium_258',
      expression: '258.1129800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'seaborgium_259',
      expression: '259.1144000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'seaborgium_260',
      expression: '260.1143840000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'seaborgium_261',
      expression: '261.1159490000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'seaborgium_262',
      expression: '262.1163370000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'seaborgium_263',
      expression: '263.1182900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'seaborgium_264',
      expression: '264.1189300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'seaborgium_265',
      expression: '265.1210900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'seaborgium_266',
      expression: '266.1219800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'seaborgium_267',
      expression: '267.1243600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'seaborgium_268',
      expression: '268.1253900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'seaborgium_269',
      expression: '269.1286300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'seaborgium_270',
      expression: '270.1304300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'seaborgium_271',
      expression: '271.1339300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'seaborgium_272',
      expression: '272.1358900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'seaborgium_273',
      expression: '273.1395800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bohrium_260',
      expression: '260.1216600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bohrium_261',
      expression: '261.1214500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bohrium_262',
      expression: '262.1229700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bohrium_263',
      expression: '263.1229200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bohrium_264',
      expression: '264.1245900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bohrium_265',
      expression: '265.1249100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bohrium_266',
      expression: '266.1267900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bohrium_267',
      expression: '267.1275000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bohrium_268',
      expression: '268.1296900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bohrium_269',
      expression: '269.1304200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bohrium_270',
      expression: '270.1333600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bohrium_271',
      expression: '271.1352600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bohrium_272',
      expression: '272.1382600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bohrium_273',
      expression: '273.1402400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bohrium_274',
      expression: '274.1435500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bohrium_275',
      expression: '275.1456700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hassium_263',
      expression: '263.1285200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hassium_264',
      expression: '264.1283570000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hassium_265',
      expression: '265.1297930000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hassium_266',
      expression: '266.1300460000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hassium_267',
      expression: '267.1316700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hassium_268',
      expression: '268.1318600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hassium_269',
      expression: '269.1337500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hassium_270',
      expression: '270.1342900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hassium_271',
      expression: '271.1371700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hassium_272',
      expression: '272.1385000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hassium_273',
      expression: '273.1416800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hassium_274',
      expression: '274.1433000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hassium_275',
      expression: '275.1466700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hassium_276',
      expression: '276.1484600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hassium_277',
      expression: '277.1519000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'meitnerium_265',
      expression: '265.1360000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'meitnerium_266',
      expression: '266.1373700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'meitnerium_267',
      expression: '267.1371900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'meitnerium_268',
      expression: '268.1386500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'meitnerium_269',
      expression: '269.1388200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'meitnerium_270',
      expression: '270.1403300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'meitnerium_271',
      expression: '271.1407400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'meitnerium_272',
      expression: '272.1434100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'meitnerium_273',
      expression: '273.1444000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'meitnerium_274',
      expression: '274.1472400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'meitnerium_275',
      expression: '275.1488200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'meitnerium_276',
      expression: '276.1515900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'meitnerium_277',
      expression: '277.1532700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'meitnerium_278',
      expression: '278.1563100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'meitnerium_279',
      expression: '279.1580800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'darmstadtium_267',
      expression: '267.1437700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'darmstadtium_268',
      expression: '268.1434800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'darmstadtium_269',
      expression: '269.1447520000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'darmstadtium_270',
      expression: '270.1445840000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'darmstadtium_271',
      expression: '271.1459500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'darmstadtium_272',
      expression: '272.1460200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'darmstadtium_273',
      expression: '273.1485600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'darmstadtium_274',
      expression: '274.1494100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'darmstadtium_275',
      expression: '275.1520300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'darmstadtium_276',
      expression: '276.1530300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'darmstadtium_277',
      expression: '277.1559100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'darmstadtium_278',
      expression: '278.1570400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'darmstadtium_279',
      expression: '279.1601000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'darmstadtium_280',
      expression: '280.1613100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'darmstadtium_281',
      expression: '281.1645100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'roentgenium_272',
      expression: '272.1532700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'roentgenium_273',
      expression: '273.1531300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'roentgenium_274',
      expression: '274.1552500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'roentgenium_275',
      expression: '275.1559400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'roentgenium_276',
      expression: '276.1583300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'roentgenium_277',
      expression: '277.1590700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'roentgenium_278',
      expression: '278.1614900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'roentgenium_279',
      expression: '279.1627200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'roentgenium_280',
      expression: '280.1651400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'roentgenium_281',
      expression: '281.1663600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'roentgenium_282',
      expression: '282.1691200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'roentgenium_283',
      expression: '283.1705400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'copernicium_276',
      expression: '276.1614100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'copernicium_277',
      expression: '277.1636400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'copernicium_278',
      expression: '278.1641600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'copernicium_279',
      expression: '279.1665400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'copernicium_280',
      expression: '280.1671500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'copernicium_281',
      expression: '281.1697500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'copernicium_282',
      expression: '282.1705000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'copernicium_283',
      expression: '283.1732700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'copernicium_284',
      expression: '284.1741600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'copernicium_285',
      expression: '285.1771200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nihonium_278',
      expression: '278.1705800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nihonium_279',
      expression: '279.1709500000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nihonium_280',
      expression: '280.1729300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nihonium_281',
      expression: '281.1734800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nihonium_282',
      expression: '282.1756700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nihonium_283',
      expression: '283.1765700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nihonium_284',
      expression: '284.1787300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nihonium_285',
      expression: '285.1797300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nihonium_286',
      expression: '286.1822100000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nihonium_287',
      expression: '287.1833900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'flerovium_285',
      expression: '285.1836400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'flerovium_286',
      expression: '286.1842300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'flerovium_287',
      expression: '287.1867800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'flerovium_288',
      expression: '288.1875700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'flerovium_289',
      expression: '289.1904200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'moscovium_287',
      expression: '287.1907000000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'moscovium_288',
      expression: '288.1927400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'moscovium_289',
      expression: '289.1936300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'moscovium_290',
      expression: '290.1959800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'moscovium_291',
      expression: '291.1970700000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'livermorium_289',
      expression: '289.1981600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'livermorium_290',
      expression: '290.1986400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'livermorium_291',
      expression: '291.2010800000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'livermorium_292',
      expression: '292.2017400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'livermorium_293',
      expression: '293.2044900000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tennessine_291',
      expression: '291.2055300000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tennessine_292',
      expression: '292.2074600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tennessine_293',
      expression: '293.2082400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tennessine_294',
      expression: '294.2104600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'oganesson_293',
      expression: '293.2135600000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'oganesson_294',
      expression: '294.2139200000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'oganesson_295',
      expression: '295.2162400000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hydrogendensity',
      expression: '0.08988 g/l',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'heliumdensity',
      expression: '0.1786 g/l',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neondensity',
      expression: '0.9002 g/l',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nitrogendensity',
      expression: '1.2506 g/l',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'oxygendensity',
      expression: '1.429 g/l',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'fluorinedensity',
      expression: '1.696 g/l',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'argondensity',
      expression: '1.784 g/l',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'chlorinedensity',
      expression: '3.2 g/l',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'kryptondensity',
      expression: '3.749 g/l',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'xenondensity',
      expression: '5.894 g/l',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'radondensity',
      expression: '9.73 g/l',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'brominedensity',
      expression: '3.1028 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mercurydensity',
      expression: '13.534 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lithiumdensity',
      expression: '0.534 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'potassiumdensity',
      expression: '0.862 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sodiumdensity',
      expression: '0.968 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rubidiumdensity',
      expression: '1.532 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'calciumdensity',
      expression: '1.55 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'magnesiumdensity',
      expression: '1.738 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'phosphorus_white_density',
      expression: '1.823 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'berylliumdensity',
      expression: '1.85 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sulfur_gamma_density',
      expression: '1.92 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cesiumdensity',
      expression: '1.93 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'carbon_amorphous_density',
      expression: '1.95 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sulfur_betadensity',
      expression: '1.96 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sulfur_alpha_density',
      expression: '2.07 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'carbon_graphite_density',
      aliases: ['graphitedensity'],
      expression: '2.267 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'phosphorus_red_density',
      expression: '2.27 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'silicondensity',
      expression: '2.3290 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'phosphorus_violet_density',
      expression: '2.36 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'borondensity',
      expression: '2.37 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'strontiumdensity',
      expression: '2.64 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'phosphorus_black_density',
      expression: '2.69 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'aluminumdensity',
      expression: '2.7 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bariumdensity',
      expression: '3.51 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'carbon_diamond_density',
      aliases: ['diamonddensity'],
      expression: '3.515 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'scandiumdensity',
      expression: '3.985 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'selenium_vitreous_density',
      expression: '4.28 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'selenium_alpha_density',
      expression: '4.39 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'titaniumdensity',
      expression: '4.406 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'yttriumdensity',
      expression: '4.472 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'selenium_gray_density',
      expression: '4.81 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iodinedensity',
      expression: '4.933 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'europiumdensity',
      expression: '5.264 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'germaniumdensity',
      expression: '5.323 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'radiumdensity',
      expression: '5.5 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'arsenicdensity',
      expression: '5.727 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tin_alpha_density',
      aliases: ['tin_gray'],
      expression: '5.769 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'galliumdensity',
      expression: '5.91 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'vanadiumdensity',
      expression: '6.11 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lanthanumdensity',
      expression: '6.162 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'telluriumdensity',
      expression: '6.24 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'zirconiumdensity',
      expression: '6.52 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'antimonydensity',
      expression: '6.697 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ceriumdensity',
      expression: '6.77 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'praseodymiumdensity',
      expression: '6.77 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ytterbiumdensity',
      expression: '6.9 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neodymiumdensity',
      expression: '7.01 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'zincdensity',
      expression: '7.14 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'chromiumdensity',
      expression: '7.19 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'manganesedensity',
      expression: '7.21 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'promethiumdensity',
      expression: '7.26 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tin_beta_density',
      aliases: ['tin_white'],
      expression: '7.265 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'indiumdensity',
      expression: '7.31 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'samariumdensity',
      expression: '7.52 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'irondensity',
      expression: '7.874 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gadoliniumdensity',
      expression: '7.9 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'terbiumdensity',
      expression: '8.23 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'dysprosiumdensity',
      expression: '8.54 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'niobiumdensity',
      expression: '8.57 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cadmiumdensity',
      expression: '8.65 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'holmiumdensity',
      expression: '8.79 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cobaltdensity',
      expression: '8.9 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nickeldensity',
      expression: '8.908 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'erbiumdensity',
      expression: '9.066 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'polonium_alpha_density',
      expression: '9.196 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thuliumdensity',
      expression: '9.32 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'polonium_beta_density',
      expression: '9.398 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bismuthdensity',
      expression: '9.78 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lutetiumdensity',
      expression: '9.841 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'actiniumdensity',
      expression: '10 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'molybdenumdensity',
      expression: '10.28 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'silverdensity',
      expression: '10.49 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'technetiumdensity',
      expression: '11 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'leaddensity',
      expression: '11.34 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thoriumdensity',
      expression: '11.7 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'thalliumdensity',
      expression: '11.85 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'americiumdensity',
      expression: '12 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'palladiumdensity',
      expression: '12.023 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rhodiumdensity',
      expression: '12.41 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rutheniumdensity',
      expression: '12.45 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'berkelium_beta_density',
      expression: '13.25 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hafniumdensity',
      expression: '13.31 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'curiumdensity',
      expression: '13.51 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'berkelium_alphadensity',
      expression: '14.78 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'californiumdensity',
      expression: '15.1 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'protactiniumdensity',
      expression: '15.37 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tantalumdensity',
      expression: '16.69 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'uraniumdensity',
      expression: '19.1 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tungstendensity',
      expression: '19.3 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'golddensity',
      expression: '19.30 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'plutoniumdensity',
      expression: '19.816 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'neptuniumdensity',
      expression: '20.45 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rheniumdensity',
      expression: '21.02 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'platinumdensity',
      expression: '21.45 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iridiumdensity',
      expression: '22.56 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'osmiumdensity',
      expression: '22.59 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'franciumdensity',
      expression: '2.48 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'astatinedensity',
      expression: '6.35 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'einsteiniumdensity',
      expression: '8.84 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'fermiumdensity',
      expression: '9.7 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'nobeliumdensity',
      expression: '9.9 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mendeleviumdensity',
      expression: '10.3 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lawrenciumdensity',
      expression: '16 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rutherfordiumdensity',
      expression: '23.2 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'roentgeniumdensity',
      expression: '28.7 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'dubniumdensity',
      expression: '29.3 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'darmstadtiumdensity',
      expression: '34.8 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'seaborgiumdensity',
      expression: '35 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bohriumdensity',
      expression: '37.1 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'meitneriumdensity',
      expression: '37.4 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hassiumdensity',
      expression: '41 g/cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'people',
      aliases: ['person', 'death', 'capita'],
      expression: '1',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'percapita',
      expression: 'per capita',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'Tim',
      expression: '12^-4 hour',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'Grafut',
      aliases: ['Gf'],
      expression: 'gravity Tim^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'Surf',
      aliases: ['Sf'],
      expression: 'Grafut^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'Volm',
      aliases: ['Vm'],
      expression: 'Grafut^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'Vlos',
      aliases: ['Vl'],
      expression: 'Grafut/Tim',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'Denz',
      aliases: ['Dz'],
      expression: 'Maz/Volm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'Mag',
      expression: 'Maz gravity',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'Maz',
      aliases: ['Mz'],
      expression: 'Volm kg / oldliter',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wari_proportion',
      aliases: ['wari'],
      expression: '1|10',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bu_proportion',
      expression: '1|100',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rin_proportion',
      expression: '1|1000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mou_proportion',
      expression: '1|10000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'shaku',
      aliases: ['kanejaku', 'taichi', '台尺'],
      expression: '1|3.3 m',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mou',
      expression: '1|10000 shaku',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rin',
      expression: '1|1000 shaku',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bu_distance',
      expression: '1|100 shaku',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sun',
      aliases: ['kanejakusun', 'taicun', '台寸'],
      expression: '1|10 shaku',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'jou_distance',
      aliases: ['jou', 'kanejakujou'],
      expression: '10 shaku',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'kujirajaku',
      expression: '10|8 shaku',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'kujirajakusun',
      expression: '1|10 kujirajaku',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'kujirajakubu',
      expression: '1|100 kujirajaku',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'kujirajakujou',
      expression: '10 kujirajaku',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tan_distance',
      expression: '3 kujirajakujou',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ken',
      expression: '6 shaku',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'chou_distance',
      aliases: ['chou'],
      expression: '60 ken',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ri',
      expression: '36 chou',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gou_area',
      expression: '1|10 tsubo',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tsubo',
      aliases: ['ping', '坪'],
      expression: '36 shaku^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'se',
      expression: '30 tsubo',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tan_area',
      expression: '10 se',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'chou_area',
      expression: '10 tan_area',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'jia',
      aliases: ['甲'],
      expression: '2934 ping',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'fen',
      aliases: ['分'],
      expression: '1|10 jia',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'fen_area',
      aliases: ['分地'],
      expression: '1|10 jia',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'edoma',
      aliases: ['jou_area', 'tatami'],
      expression: '(5.8*2.9) shaku^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'kyouma',
      expression: '(6.3*3.15) shaku^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'chuukyouma',
      expression: '(6*3) shaku^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'shaku_volume',
      expression: '1|10 gou_volume',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'gou_volume',
      aliases: ['gou'],
      expression: '1|10 shou',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'shou',
      expression: '(4.9*4.9*2.7) sun^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'to',
      expression: '10 shou',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'koku',
      expression: '10 to',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'rin_weight',
      expression: '1|10 bu_weight',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bu_weight',
      expression: '1|10 monme',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'fun',
      expression: '1|10 monme',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'kin',
      aliases: ['taijin', '台斤'],
      expression: '160 monme',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'kan',
      aliases: ['kwan'],
      expression: '1000 monme',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tailiang',
      aliases: ['台兩'],
      expression: '10 monme',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'australiasquare',
      expression: '(10 ft)^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'zentner',
      expression: '50 kg',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'doppelzentner',
      expression: '2 zentner',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'pfund',
      expression: '500 g',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'austriaklafter',
      expression: '1.89648384 m',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'austriafoot',
      expression: '1|6 austriaklafter',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'prussiaklafter',
      expression: '1.88 m',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'prussiafoot',
      expression: '1|6 prussiaklafter',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bavariaklafter',
      expression: '1.751155 m',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bavariafoot',
      expression: '1|6 bavariaklafter',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hesseklafter',
      expression: '2.5 m',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hessefoot',
      expression: '1|6 hesseklafter',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'switzerlandfoot',
      expression: '1|6 switzerlandklafter',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'swissfoot',
      expression: '1|6 swissklafter',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'metricklafter',
      aliases: ['switzerlandklafter', 'swissklafter'],
      expression: '1.8 m',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'austriayoke',
      expression: '8 austriaklafter * 200 austriaklafter',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'liechtensteinsquareklafter',
      expression: '3.596652 m^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'liechtensteinklafter',
      expression: 'sqrt(liechtensteinsquareklafter)',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'prussiawoodklafter',
      expression: '0.5 prussiaklafter^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'austriawoodklafter',
      expression: '0.5 austriaklafter^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'festmeter',
      expression: 'm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'raummeter',
      expression: '0.7 festmeter',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'schuettraummeter',
      aliases: ['schüttraummeter'],
      expression: '0.65 raummeter',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'verklinje',
      expression: '2.0618125 mm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'verktum',
      expression: '12 verklinje',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'kvarter',
      expression: '6 verktum',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'fot',
      expression: '2 kvarter',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'aln',
      expression: '2 fot',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'famn',
      expression: '3 aln',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'dessiatine',
      aliases: ['dessjatine'],
      expression: '2400 sazhen^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'funt',
      expression: '409.51718 grams',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'zolotnik',
      expression: '1|96 funt',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'pood',
      expression: '40 funt',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'arshin',
      expression: '(2 + 1|3) feet',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sazhen',
      expression: '3 arshin',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'verst',
      aliases: ['versta'],
      expression: '500 sazhen',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'borderverst',
      expression: '1000 sazhen',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'russianmile',
      expression: '7 verst',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'frenchfoot',
      aliases: ['pied', 'frenchfeet'],
      expression: '144|443.296 m',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'frenchinch',
      aliases: ['frenchthumb', 'pouce'],
      expression: '1|12 frenchfoot',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'frenchline',
      aliases: ['ligne'],
      expression: '1|12 frenchinch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'frenchpoint',
      expression: '1|12 frenchline',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'toise',
      expression: '6 frenchfeet',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'arpent',
      expression: '180^2 pied^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'frenchgrain',
      expression: '1|18827.15 kg',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'frenchpound',
      expression: '9216 frenchgrain',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'scotsinch',
      expression: '1.00540054 UKinch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'scotslink',
      expression: '1|100 scotschain',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'scotsfoot',
      aliases: ['scotsfeet'],
      expression: '12 scotsinch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'scotsell',
      expression: '37 scotsinch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'scotsfall',
      expression: '6 scotsell',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'scotschain',
      expression: '4 scotsfall',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'scotsfurlong',
      expression: '10 scotschain',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'scotsmile',
      expression: '8 scotsfurlong',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'scotsrood',
      expression: '40 scotsfall^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'scotsacre',
      expression: '4 scotsrood',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'irishinch',
      expression: 'UKinch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'irishpalm',
      expression: '3 irishinch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'irishspan',
      expression: '3 irishpalm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'irishfoot',
      aliases: ['irishfeet'],
      expression: '12 irishinch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'irishcubit',
      expression: '18 irishinch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'irishyard',
      expression: '3 irishfeet',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'irishpace',
      expression: '5 irishfeet',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'irishfathom',
      expression: '6 irishfeet',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'irishpole',
      aliases: ['irishperch'],
      expression: '7 irishyard',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'irishchain',
      expression: '4 irishperch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'irishlink',
      expression: '1|100 irishchain',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'irishfurlong',
      expression: '10 irishchain',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'irishmile',
      expression: '8 irishfurlong',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'irishrood',
      expression: '40 irishpole^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'irishacre',
      expression: '4 irishrood',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'winepint',
      expression: '1|2 winequart',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'winequart',
      expression: '1|4 winegallon',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'winegallon',
      expression: '231 UKinch^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'winerundlet',
      expression: '18 winegallon',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'winebarrel',
      expression: '31.5 winegallon',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'winetierce',
      expression: '42 winegallon',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'winehogshead',
      expression: '2 winebarrel',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'winepuncheon',
      expression: '2 winetierce',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'winebutt',
      aliases: ['winepipe'],
      expression: '2 winehogshead',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'winetun',
      expression: '2 winebutt',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'beerpint',
      expression: '1|2 beerquart',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'beerquart',
      expression: '1|4 beergallon',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'beergallon',
      aliases: ['alegallon'],
      expression: '282 UKinch^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'beerbarrel',
      expression: '36 beergallon',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'beerhogshead',
      expression: '1.5 beerbarrel',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'alepint',
      expression: '1|2 alequart',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'alequart',
      expression: '1|4 alegallon',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'alebarrel',
      expression: '34 alegallon',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'alehogshead',
      expression: '1.5 alebarrel',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'scotsgill',
      expression: '1|4 mutchkin',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mutchkin',
      expression: '1|2 choppin',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'choppin',
      expression: '1|2 scotspint',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'scotspint',
      aliases: ['jug'],
      expression: '1|2 scotsquart',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'scotsquart',
      expression: '1|4 scotsgallon',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'scotsgallon',
      expression: '827.232 UKinch^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'scotsbarrel',
      expression: '8 scotsgallon',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'scotswheatlippy',
      aliases: ['scotswheatlippies'],
      expression: '137.333 UKinch^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'scotswheatpeck',
      expression: '4 scotswheatlippy',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'scotswheatfirlot',
      expression: '4 scotswheatpeck',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'scotswheatboll',
      expression: '4 scotswheatfirlot',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'scotswheatchalder',
      expression: '16 scotswheatboll',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'scotsoatlippy',
      aliases: ['scotsoatlippies'],
      expression: '200.345 UKinch^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'scotsoatpeck',
      expression: '4 scotsoatlippy',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'scotsoatfirlot',
      expression: '4 scotsoatpeck',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'scotsoatboll',
      expression: '4 scotsoatfirlot',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'scotsoatchalder',
      expression: '16 scotsoatboll',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'trondrop',
      expression: '1|16 tronounce',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tronounce',
      expression: '1|20 tronpound',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tronpound',
      expression: '9520 grain',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tronstone',
      expression: '16 tronpound',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'irishnoggin',
      expression: '1|4 irishpint',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'irishpint',
      expression: '1|2 irishquart',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'irishquart',
      expression: '1|2 irishpottle',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'irishpottle',
      expression: '1|2 irishgallon',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'irishgallon',
      expression: '217.6 UKinch^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'irishrundlet',
      expression: '18 irishgallon',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'irishbarrel',
      expression: '31.5 irishgallon',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'irishtierce',
      expression: '42 irishgallon',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'irishhogshead',
      expression: '2 irishbarrel',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'irishpuncheon',
      expression: '2 irishtierce',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'irishpipe',
      expression: '2 irishhogshead',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'irishtun',
      expression: '2 irishpipe',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'irishpeck',
      expression: '2 irishgallon',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'irishbushel',
      expression: '4 irishpeck',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'irishstrike',
      expression: '2 irishbushel',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'irishdrybarrel',
      expression: '2 irishstrike',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'irishquarter',
      expression: '2 irishbarrel',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'towerpound',
      expression: '5400 grain',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'towerounce',
      expression: '1|12 towerpound',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'towerpennyweight',
      expression: '1|20 towerounce',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'towergrain',
      expression: '1|32 towerpennyweight',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mercpound',
      expression: '6750 grain',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mercounce',
      expression: '1|15 mercpound',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mercpennyweight',
      expression: '1|20 mercounce',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'leadstone',
      expression: '12.5 lb',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'fotmal',
      expression: '70 lb',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'leadwey',
      expression: '14 leadstone',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'fothers',
      expression: '12 leadwey',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'newhaytruss',
      expression: '60 lb',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'newhayload',
      expression: '36 newhaytruss',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'oldhaytruss',
      expression: '56 lb',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'oldhayload',
      expression: '36 oldhaytruss',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'woolclove',
      expression: '7 lb',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'woolstone',
      expression: '2 woolclove',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'wooltod',
      expression: '2 woolstone',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'woolwey',
      expression: '13 woolstone',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'woolsack',
      expression: '2 woolwey',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'woolsarpler',
      expression: '2 woolsack',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'woollast',
      expression: '6 woolsarpler',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'romanfoot',
      aliases: ['romanfeet', 'pes', 'pedes'],
      expression: '296 mm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'romaninch',
      expression: '1|12 romanfoot',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'romandigit',
      expression: '1|16 romanfoot',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'romanpalm',
      expression: '1|4 romanfoot',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'romancubit',
      expression: '18 romaninch',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'romanpace',
      aliases: ['passus'],
      expression: '5 romanfeet',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'romanperch',
      expression: '10 romanfeet',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'stade',
      aliases: ['stadia', 'stadium'],
      expression: '125 romanpaces',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'romanmile',
      expression: '8 stadia',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'romanleague',
      expression: '1.5 romanmile',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'schoenus',
      expression: '4 romanmile',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'earlyromanfoot',
      expression: '29.73 cm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'pesdrusianus',
      expression: '33.3 cm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'lateromanfoot',
      expression: '29.42 cm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'actuslength',
      expression: '120 romanfeet',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'actus',
      expression: '120*4 romanfeet^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'squareactus',
      aliases: ['acnua'],
      expression: '120^2 romanfeet^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'iugerum',
      aliases: ['iugera', 'jugerum', 'jugera'],
      expression: '2 squareactus',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'heredium',
      aliases: ['heredia'],
      expression: '2 iugera',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'centuria',
      aliases: ['centurium'],
      expression: '100 heredia',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sextarius',
      aliases: ['sextarii'],
      expression: '35.4 in^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cochlearia',
      expression: '1|48 sextarius',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cyathi',
      expression: '1|12 sextarius',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'acetabula',
      expression: '1|8 sextarius',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'quartaria',
      aliases: ['quartarius'],
      expression: '1|4 sextarius',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'heminae',
      aliases: ['hemina'],
      expression: '1|2 sextarius',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cheonix',
      expression: '1.5 sextarii',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'semodius',
      aliases: ['semodii'],
      expression: '8 sextarius',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'modius',
      aliases: ['modii'],
      expression: '16 sextarius',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'congius',
      aliases: ['congii'],
      expression: '12 heminae',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'amphora',
      aliases: ['amphorae', 'quadrantal'],
      expression: '8 congii',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'culleus',
      expression: '20 amphorae',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'libra',
      aliases: ['librae', 'romanpound'],
      expression: '5052 grain',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'uncia',
      aliases: ['unciae', 'romanounce'],
      expression: '1|12 libra',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'deunx',
      expression: '11 uncia',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'dextans',
      expression: '10 uncia',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'dodrans',
      expression: '9 uncia',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'bes',
      expression: '8 uncia',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'seprunx',
      expression: '7 uncia',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'semis',
      expression: '6 uncia',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'quincunx',
      expression: '5 uncia',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'triens',
      expression: '4 uncia',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'quadrans',
      expression: '3 uncia',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sextans',
      expression: '2 uncia',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sescuncia',
      expression: '1.5 uncia',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'semuncia',
      expression: '1|2 uncia',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'siscilius',
      expression: '1|4 uncia',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sextula',
      expression: '1|6 uncia',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'semisextula',
      expression: '1|12 uncia',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'scriptulum',
      aliases: ['scrupula'],
      expression: '1|24 uncia',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'romanobol',
      expression: '1|2 scrupula',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'romanaspound',
      expression: '4210 grain',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'egyptianroyalcubit',
      expression: '20.63 in',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'egyptianpalm',
      expression: '1|7 egyptianroyalcubit',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'egyptiandigit',
      expression: '1|4 egyptianpalm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'egyptianshortcubit',
      expression: '6 egyptianpalm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'doubleremen',
      expression: '29.16 in',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'remendigit',
      expression: '1|40 doubleremen',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'greekfoot',
      aliases: ['greekfeet', 'pous', 'podes'],
      expression: '12.45 in',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'greekcubit',
      expression: '1.5 greekfoot',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'orguia',
      aliases: ['greekfathom'],
      expression: '6 greekfoot',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'stadion',
      expression: '100 orguia',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'akaina',
      expression: '10 greekfeet',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'plethron',
      expression: '10 akaina',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'greekfinger',
      expression: '1|16 greekfoot',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'homericcubit',
      expression: '20 greekfingers',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'shortgreekcubit',
      expression: '18 greekfingers',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ionicfoot',
      expression: '296 mm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'doricfoot',
      expression: '326 mm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'olympiccubit',
      expression: '25 remendigit',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'olympicfoot',
      aliases: ['olympicfeet'],
      expression: '2|3 olympiccubit',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'olympicfinger',
      aliases: ['olympicdakylos'],
      expression: '1|16 olympicfoot',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'olympicpalm',
      aliases: ['olympicpalestra'],
      expression: '1|4 olympicfoot',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'olympicspithame',
      aliases: ['olympicspan'],
      expression: '3|4 foot',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'olympicbema',
      aliases: ['olympicpace'],
      expression: '2.5 olympicfeet',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'olympicorguia',
      aliases: ['olympicfathom'],
      expression: '6 olympicfeet',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'olympiccord',
      aliases: ['olympicamma'],
      expression: '60 olympicfeet',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'olympicplethron',
      expression: '100 olympicfeet',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'olympicstadion',
      expression: '600 olympicfeet',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'greekkotyle',
      expression: '270 ml',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'xestes',
      expression: '2 greekkotyle',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'khous',
      expression: '12 greekkotyle',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'metretes',
      expression: '12 khous',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'choinix',
      expression: '4 greekkotyle',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hekteos',
      expression: '8 choinix',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'medimnos',
      expression: '6 hekteos',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'aeginastater',
      expression: '192 grain',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'aeginadrachmae',
      expression: '1|2 aeginastater',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'aeginaobol',
      expression: '1|6 aeginadrachmae',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'aeginamina',
      expression: '50 aeginastaters',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'aeginatalent',
      expression: '60 aeginamina',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'atticstater',
      expression: '135 grain',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'atticdrachmae',
      expression: '1|2 atticstater',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'atticobol',
      expression: '1|6 atticdrachmae',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'atticmina',
      expression: '50 atticstaters',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'attictalent',
      expression: '60 atticmina',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'northerncubit',
      expression: '26.6 in',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'northernfoot',
      expression: '1|2 northerncubit',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sumeriancubit',
      aliases: ['kus'],
      expression: '495 mm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'sumerianfoot',
      expression: '2|3 sumeriancubit',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'assyriancubit',
      expression: '21.6 in',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'assyrianfoot',
      expression: '1|2 assyriancubit',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'assyrianpalm',
      expression: '1|3 assyrianfoot',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'assyriansusi',
      aliases: ['susi'],
      expression: '1|20 assyrianpalm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'persianroyalcubit',
      expression: '7 assyrianpalm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hashimicubit',
      expression: '25.56 in',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'blackcubit',
      expression: '21.28 in',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'arabicfeet',
      aliases: ['arabicfoot'],
      expression: '1|2 blackcubit',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'arabicinch',
      expression: '1|12 arabicfoot',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'arabicmile',
      expression: '4000 blackcubit',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'silverdirhem',
      expression: '45 grain',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tradedirhem',
      expression: '48 grain',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'silverkirat',
      expression: '1|16 silverdirhem',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'silverwukiyeh',
      expression: '10 silverdirhem',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'silverrotl',
      aliases: ['arabicsilverpound'],
      expression: '12 silverwukiyeh',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tradekirat',
      expression: '1|16 tradedirhem',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'tradewukiyeh',
      expression: '10 tradedirhem',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'traderotl',
      aliases: ['arabictradepound'],
      expression: '12 tradewukiyeh',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'parasang',
      expression: '3.5 mile',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'biblicalcubit',
      expression: '21.8 in',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'hebrewcubit',
      expression: '17.58 in',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'li',
      expression: '10|27.8 mile',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'liang',
      expression: '11|3 oz',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'timepoint',
      expression: '1|5 hour',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'timeminute',
      expression: '1|10 hour',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'timeostent',
      expression: '1|60 hour',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'timeounce',
      expression: '1|8 timeostent',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'timeatom',
      expression: '1|47 timeounce',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'mite',
      expression: '1|20 grain',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'droit',
      expression: '1|24 mite',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'periot',
      expression: '1|20 droit',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'blanc',
      expression: '1|24 periot',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'cent',
      aliases: ['penny', '¢', '￠'],
      expression: '\$ 0.01',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: 'ℯ',
      expression: 'exp(1)',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: '‰',
      expression: '1|1000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: '‱',
      expression: '1|10000',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: '㍱',
      expression: 'hPa',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: '㎀',
      expression: 'pA',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: '㎁',
      expression: 'nA',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: '㎂',
      expression: 'µA',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: '㎃',
      expression: 'mA',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: '㎄',
      expression: 'kA',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: '㎅',
      expression: 'kB',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: '㎆',
      expression: 'MB',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: '㎇',
      expression: 'GB',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: '㎉',
      expression: 'kcal',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: '㎊',
      expression: 'pF',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: '㎋',
      expression: 'nF',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: '㎌',
      expression: 'µF',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: '㎍',
      expression: 'µg',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: '㎎',
      expression: 'mg',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: '㎑',
      expression: 'kHz',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: '㎒',
      expression: 'MHz',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: '㎓',
      expression: 'GHz',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: '㎔',
      expression: 'THz',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: '㎕',
      expression: 'µL',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: '㎖',
      expression: 'ml',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: '㎗',
      expression: 'dL',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: '㎘',
      expression: 'kL',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: '㎙',
      expression: 'fm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: '㎚',
      expression: 'nm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: '㎛',
      expression: 'µm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: '㎜',
      expression: 'mm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: '㎝',
      expression: 'cm',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: '㎞',
      expression: 'km',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: '㎟',
      expression: 'mm^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: '㎠',
      expression: 'cm^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: '㎡',
      expression: 'm^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: '㎢',
      expression: 'km^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: '㎣',
      expression: 'mm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: '㎤',
      expression: 'cm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: '㎥',
      expression: 'm^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: '㎦',
      expression: 'km^3',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: '㎧',
      expression: 'm/s',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: '㎨',
      expression: 'm/s^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: '㎪',
      expression: 'kPa',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: '㎫',
      expression: 'MPa',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: '㎬',
      expression: 'GPa',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: '㎮',
      expression: 'rad/s',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: '㎯',
      expression: 'rad/s^2',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: '㎰',
      expression: 'ps',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: '㎱',
      expression: 'ns',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: '㎲',
      expression: 'µs',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: '㎳',
      expression: 'ms',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: '㎴',
      expression: 'pV',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: '㎵',
      expression: 'nV',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: '㎶',
      expression: 'µV',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: '㎷',
      expression: 'mV',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: '㎸',
      expression: 'kV',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: '㎹',
      expression: 'MV',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: '㎺',
      expression: 'pW',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: '㎻',
      expression: 'nW',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: '㎼',
      expression: 'µW',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: '㎽',
      expression: 'mW',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: '㎾',
      expression: 'kW',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: '㎿',
      expression: 'MW',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: '㏀',
      expression: 'kΩ',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: '㏁',
      expression: 'MΩ',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: '㏆',
      expression: 'C/kg',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: '㏊',
      expression: 'ha',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: '㏏',
      expression: 'kt',
    ),
  );
  repo.register(
    const DerivedUnit(
      id: '㏔',
      expression: 'mb',
    ),
  );
}

void _registerPrefixes(UnitRepository repo) {
  repo.registerPrefix(
    const PrefixUnit(
      id: 'quetta',
      aliases: ['Q'],
      expression: '1e30',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: 'ronna',
      aliases: ['R'],
      expression: '1e27',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: 'yotta',
      aliases: ['Y'],
      expression: '1e24',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: 'zetta',
      aliases: ['Z'],
      expression: '1e21',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: 'exa',
      aliases: ['E'],
      expression: '1e18',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: 'peta',
      aliases: ['P'],
      expression: '1e15',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: 'tera',
      aliases: ['T'],
      expression: '1e12',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: 'giga',
      aliases: ['G'],
      expression: '1e9',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: 'mega',
      aliases: ['M'],
      expression: '1e6',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: 'myria',
      expression: '1e4',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: 'kilo',
      aliases: ['k'],
      expression: '1e3',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: 'hecto',
      aliases: ['h'],
      expression: '1e2',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: 'deca',
      aliases: ['dk', 'deka', 'da'],
      expression: '1e1',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: 'deci',
      aliases: ['d'],
      expression: '1e-1',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: 'centi',
      aliases: ['c'],
      expression: '1e-2',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: 'milli',
      aliases: ['m'],
      expression: '1e-3',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: 'micro',
      aliases: ['u', 'µ', 'μ'],
      expression: '1e-6',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: 'nano',
      aliases: ['n'],
      expression: '1e-9',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: 'pico',
      aliases: ['p'],
      expression: '1e-12',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: 'femto',
      aliases: ['f'],
      expression: '1e-15',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: 'atto',
      aliases: ['a'],
      expression: '1e-18',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: 'zepto',
      aliases: ['z'],
      expression: '1e-21',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: 'yocto',
      aliases: ['y'],
      expression: '1e-24',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: 'ronto',
      aliases: ['r'],
      expression: '1e-27',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: 'quecto',
      aliases: ['q'],
      expression: '1e-30',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: 'quarter',
      expression: '1|4',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: 'semi',
      expression: '0.5',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: 'demi',
      expression: '0.5',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: 'hemi',
      expression: '0.5',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: 'half',
      expression: '0.5',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: 'double',
      expression: '2',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: 'triple',
      expression: '3',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: 'treble',
      expression: '3',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: 'kibi',
      aliases: ['Ki'],
      expression: '2^10',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: 'mebi',
      aliases: ['Mi'],
      expression: '2^20',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: 'gibi',
      aliases: ['Gi'],
      expression: '2^30',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: 'tebi',
      aliases: ['Ti'],
      expression: '2^40',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: 'pebi',
      aliases: ['Pi'],
      expression: '2^50',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: 'exbi',
      aliases: ['Ei'],
      expression: '2^60',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: 'zebi',
      aliases: ['Zi'],
      expression: '2^70',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: 'yobi',
      aliases: ['Yi'],
      expression: '2^80',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: 'robi',
      aliases: ['Ri'],
      expression: '2^90',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: 'quebi',
      aliases: ['Qi'],
      expression: '2^100',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: 'US',
      expression: 'US',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: 'survey',
      expression: 'US',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: 'geodetic',
      expression: 'US',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: 'int',
      expression: 'int',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: 'UK',
      expression: 'UK',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: 'british',
      expression: 'UK',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: 'Zena',
      expression: '12',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: 'Duna',
      expression: '12^2',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: 'Trina',
      expression: '12^3',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: 'Quedra',
      expression: '12^4',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: 'Quena',
      expression: '12^5',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: 'Hesa',
      expression: '12^6',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: 'Seva',
      expression: '12^7',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: 'Aka',
      expression: '12^8',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: 'Neena',
      expression: '12^9',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: 'Dexa',
      expression: '12^10',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: 'Lefa',
      expression: '12^11',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: 'Zennila',
      expression: '12^12',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: 'Zeni',
      expression: '12^-1',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: 'Duni',
      expression: '12^-2',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: 'Trini',
      expression: '12^-3',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: 'Quedri',
      expression: '12^-4',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: 'Queni',
      expression: '12^-5',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: 'Hesi',
      expression: '12^-6',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: 'Sevi',
      expression: '12^-7',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: 'Aki',
      expression: '12^-8',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: 'Neeni',
      expression: '12^-9',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: 'Dexi',
      expression: '12^-10',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: 'Lefi',
      expression: '12^-11',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: 'Zennili',
      expression: '12^-12',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: '⅛',
      expression: '1|8',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: '¼',
      expression: '1|4',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: '⅜',
      expression: '3|8',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: '½',
      expression: '1|2',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: '⅝',
      expression: '5|8',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: '¾',
      expression: '3|4',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: '⅞',
      expression: '7|8',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: '⅙',
      expression: '1|6',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: '⅓',
      expression: '1|3',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: '⅔',
      expression: '2|3',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: '⅚',
      expression: '5|6',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: '⅕',
      expression: '1|5',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: '⅖',
      expression: '2|5',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: '⅗',
      expression: '3|5',
    ),
  );
  repo.registerPrefix(
    const PrefixUnit(
      id: '⅘',
      expression: '4|5',
    ),
  );
}
