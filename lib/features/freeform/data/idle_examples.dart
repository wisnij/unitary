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
  FreeformExample(inputExpression: '1 / alpha'), // fine structure constant
  FreeformExample(
    inputExpression: '100 yd * 160 ft',
  ), // area of a football field
  FreeformExample(
    inputExpression: '1013.25 mbar',
  ), // standard atmospheric pressure at sea level
  FreeformExample(
    inputExpression: '12 log2(440 Hz/261.626 Hz)',
  ), // number of semitones between A and middle C
  FreeformExample(
    inputExpression: '12g / N_A atomicmassunit carbon_12',
  ), // old definition of the mole
  FreeformExample(
    inputExpression: '19.3 g/cm^3',
  ), // density of tungsten
  FreeformExample(
    inputExpression: '1|2 20kg (1.3% c)^2',
  ), // Sir Isaac Newton is the deadliest son of a bitch in space
  FreeformExample(
    inputExpression: '1|2 gallon',
    outputExpression: 'ml',
  ), // a carton of milk, in metric
  FreeformExample(
    inputExpression: '26.2 miles',
    outputExpression: 'km',
  ), // marathon run distance
  FreeformExample(
    inputExpression: '30 kWh',
  ), // average household daily energy usage
  FreeformExample(
    inputExpression: '4 GiB',
  ), // maximum size of a 32-bit address space
  FreeformExample(
    inputExpression: '5 ft + 6 in',
    outputExpression: 'cm',
  ), // average human height
  FreeformExample(inputExpression: '5 km'), // 5K run distance
  FreeformExample(inputExpression: '60 mph'), // a common speed limit
  FreeformExample(
    inputExpression: '9.8 m/s^2 * 62 kg',
  ), // force of gravity on an average human
  FreeformExample(
    inputExpression: 'cbrt(219890 t/golddensity)',
  ), // size of a cube containing all the gold in the world
  FreeformExample(
    inputExpression: 'hypot(3 m, 4 m)',
  ), // hypotenuse of a 3-4-5 right triangle
  FreeformExample(
    inputExpression: 'ln(2)',
  ), // natural log of 2, used in half-life and compounding formulas
  FreeformExample(inputExpression: 'pi^2 / 6'), // solution to the Basel problem
  FreeformExample(inputExpression: 'sin(30 degrees)'), // a common angle
  FreeformExample(
    inputExpression: 'sqrt(2 au / gravity)',
  ), // time to travel one AU at 1g constant acceleration
  FreeformExample(
    inputExpression: 'sqrt(G earthmass/moondist)',
  ), // orbital speed of the Moon
  FreeformExample(
    inputExpression: 'tempC(37)',
    outputExpression: 'tempF',
  ), // average human body temperature
  FreeformExample(
    inputExpression: 'tempF(212) - tempF(32)',
  ), // difference between freezing and boiling points of water
  FreeformExample(
    inputExpression: 'tempF(98.6)',
  ), // average human body temperature
];
