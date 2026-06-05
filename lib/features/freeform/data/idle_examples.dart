/// An example expression that may be shown in the idle freeform display.
///
/// [inputExpression] is the "Convert from" expression string.
/// [outputExpression] is the optional "Convert to" expression string; when
/// non-null the idle hint is displayed as `<inputExpression> → <outputExpression>`
/// and tapping it fills both freeform fields.
class FreeformExample {
  final String inputExpression;
  final String? outputExpression;

  const FreeformExample({
    required this.inputExpression,
    this.outputExpression,
  });

  @override
  bool operator ==(Object other) =>
      other is FreeformExample &&
      other.inputExpression == inputExpression &&
      other.outputExpression == outputExpression;

  @override
  int get hashCode => Object.hash(inputExpression, outputExpression);
}

/// Curated example expressions shown in the idle freeform display.
///
/// Each entry is a [FreeformExample] whose [FreeformExample.inputExpression] is
/// a valid expression that can be evaluated by the production [UnitRepository].
/// Entries with a non-null [FreeformExample.outputExpression] demonstrate
/// two-field conversion; the idle hint for those reads
/// `<inputExpression> → <outputExpression>`.
///
/// The list covers a range of features: unit conversions, SI prefixes,
/// physical constants, defined functions, compound expressions, rational-number
/// syntax, and two-field conversions.
const List<FreeformExample> idleExamples = [
  FreeformExample(
    // fine structure constant
    inputExpression: '1 / alpha',
  ),
  FreeformExample(
    // area of a football field
    inputExpression: '100 yd * 160 ft',
    outputExpression: 'acre',
  ),
  FreeformExample(
    // standard atmospheric pressure at sea level
    inputExpression: '1013.25 mbar',
  ),
  FreeformExample(
    // number of semitones between A and middle C
    inputExpression: '12 log2(440 Hz/261.626 Hz)',
  ),
  FreeformExample(
    // old definition of the mole
    inputExpression: '12g / N_A atomicmassunit carbon_12',
  ),
  FreeformExample(
    // density of tungsten
    inputExpression: '19.3 g/cm^3',
  ),
  FreeformExample(
    // Sir Isaac Newton is the deadliest son of a bitch in space
    inputExpression: '1|2 20kg (1.3% c)^2',
    outputExpression: 'kiloton tnt',
  ),
  FreeformExample(
    // a carton of milk, in metric
    inputExpression: '1|2 gallon',
    outputExpression: 'ml',
  ),
  FreeformExample(
    // marathon run distance
    inputExpression: '26.2 miles',
    outputExpression: 'km',
  ),
  FreeformExample(
    // average household daily energy usage
    inputExpression: '30 kWh',
    outputExpression: 'btu',
  ),
  FreeformExample(
    // maximum size of a 32-bit address space
    inputExpression: '4 GiB',
  ),
  FreeformExample(
    // average human height
    inputExpression: '5 ft + 6 in',
    outputExpression: 'cm',
  ),
  FreeformExample(
    // 5K run distance
    inputExpression: '5 km',
    outputExpression: 'miles',
  ),
  FreeformExample(
    // a common speed limit
    inputExpression: '60 mph',
    outputExpression: 'kph',
  ),
  FreeformExample(
    // force of gravity on an average human
    inputExpression: '9.8 m/s^2 * 62 kg',
    outputExpression: 'N',
  ),
  FreeformExample(
    // size of a cube containing all the gold in the world
    inputExpression: 'cbrt(219890 t/golddensity)',
  ),
  FreeformExample(
    // hypotenuse of a 3-4-5 right triangle
    inputExpression: 'hypot(3 m, 4 m)',
  ),
  FreeformExample(
    // natural log of 2, used in half-life and compounding formulas
    inputExpression: 'ln(2)',
  ),
  FreeformExample(
    // solution to the Basel problem
    inputExpression: 'pi^2 / 6',
  ),
  FreeformExample(
    // a common angle
    inputExpression: 'sin(30 degrees)',
  ),
  FreeformExample(
    // time to travel one AU at 1g constant acceleration
    inputExpression: 'sqrt(2 au / gravity)',
    outputExpression: 'days',
  ),
  FreeformExample(
    // orbital speed of the Moon
    inputExpression: 'sqrt(G earthmass/moondist)',
    outputExpression: 'km/s',
  ),
  FreeformExample(
    // average human body temperature
    inputExpression: 'tempC(37)',
    outputExpression: 'tempF',
  ),
  FreeformExample(
    // difference between freezing and boiling points of water
    inputExpression: 'tempF(212) - tempF(32)',
  ),
  FreeformExample(
    // average human body temperature
    inputExpression: 'tempF(98.6)',
  ),
];
