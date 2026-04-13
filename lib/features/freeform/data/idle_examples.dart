/// Curated example expressions shown in the idle freeform display.
///
/// Each entry is a valid expression that can be evaluated by the production
/// [UnitRepository].  The list covers a range of features: unit conversions,
/// SI prefixes, physical constants, defined functions, compound expressions,
/// and rational-number syntax.
const List<String> idleExamples = [
  '1 / alpha', // fine structure constant
  '100 yd * 160 ft', // area of a football field
  '1013.25 mbar', // standard atmospheric pressure at sea level
  '12 log2(440 Hz/261.626 Hz)', // number of semitones between A and middle C
  '12g / N_A atomicmassunit carbon_12', // old definition of the mole
  '19.3 g/cm^3', // density of tungsten
  '1|2 20kg (1.3% c)^2', // Sir Isaac Newton is the deadliest son of a bitch in space
  '1|2 gallon', // a carton of milk
  '26.2 miles', // marathon run distance
  '30 kWh', // average household daily energy usage
  '4 GiB', // maximum size of a 32-bit address space
  '5 ft + 6 in', // average human height
  '5 km', // 5K run distance
  '60 mph', // a common speed limit
  '9.8 m/s^2 * 62 kg', // force of gravity on an average human
  'cbrt(219890 t/golddensity)', // size of a cube containing all the gold in the world
  'hypot(3 m, 4 m)', // hypotenuse of a 3-4-5 right triangle
  'ln(2)', // natural log of 2, used in half-life and compounding formulas
  'pi^2 / 6', // solution to the Basel problem
  'sin(30 degrees)', // a common angle
  'sqrt(2 au / gravity)', // time to travel one AU at 1g constant acceleration
  'sqrt(G earthmass/moondist)', // orbital speed of the Moon
  'tempC(37)', // average human body temperature
  'tempF(212) - tempF(32)', // difference between freezing and boiling points of water
  'tempF(98.6)', // average human body temperature
];
