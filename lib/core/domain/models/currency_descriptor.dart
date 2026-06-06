import 'unit.dart';

/// Describes a currency unit that can have its exchange rate updated at
/// runtime via [UnitRepository.registerDynamic].
///
/// The [isoCode] is the 3-letter name used as the API lookup key.  The
/// [unitId] is the primary ID of the unit to update — for most currencies
/// this is the underlying derived unit (e.g. 'euro' for 'EUR'), but for
/// precious metals it is the intermediate price unit ('goldprice' for 'XAU').
/// [expressionTemplate] is a string with a `{rate}` placeholder that is
/// filled with the numeric rate before being set as the unit's expression.
class CurrencyDescriptor {
  final String isoCode;
  final String unitId;
  final String expressionTemplate;
  final Unit originalUnit;

  const CurrencyDescriptor({
    required this.isoCode,
    required this.unitId,
    required this.expressionTemplate,
    required this.originalUnit,
  });

  /// Returns the expression string for the given [rate].
  String expressionFor(double rate) =>
      expressionTemplate.replaceAll('{rate}', '$rate');
}
