import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/domain/models/currency_descriptor.dart';
import '../../../core/domain/models/unit.dart';
import '../../../core/domain/models/unit_repository.dart';
import '../data/currency_rate_repository.dart';

const _frankfurterUrl = 'https://api.frankfurter.dev/v2/rates?base=USD';

/// Fetches live exchange rates from Frankfurter v2 and applies them to the
/// [UnitRepository] dynamic layer.
class CurrencyService {
  final UnitRepository _repo;
  final CurrencyRateRepository _rateRepo;
  final http.Client _client;

  CurrencyService({
    required UnitRepository repo,
    required CurrencyRateRepository rateRepo,
    http.Client? client,
  }) : _repo = repo,
       _rateRepo = rateRepo,
       _client = client ?? http.Client();

  /// Fetches rates from Frankfurter v2, applies them to the repo via
  /// [UnitRepository.registerDynamic], and persists the result.
  ///
  /// For each rate received whose ISO code matches a [CurrencyDescriptor],
  /// a new [DerivedUnit] is created using the descriptor's expression template
  /// and registered dynamically.  Rates not in the descriptor list are ignored.
  ///
  /// Returns null on success, or an error string describing the failure.
  Future<String?> fetchRates() async {
    final descriptors = _repo.buildCurrencyDescriptors();
    final byIsoCode = {for (final d in descriptors) d.isoCode: d};

    http.Response response;
    try {
      response = await _client.get(Uri.parse(_frankfurterUrl));
    } on Exception catch (e) {
      return e.toString();
    }

    if (response.statusCode != 200) {
      return 'HTTP ${response.statusCode}';
    }

    List<dynamic> rows;
    try {
      rows = jsonDecode(response.body) as List<dynamic>;
    } on Exception catch (e) {
      return e.toString();
    }

    // Load existing rates so we can merge (preserve rates absent from response).
    final existing = _rateRepo.load();
    final newRates = Map<String, CurrencyRateEntry>.from(
      existing?.rates ?? {},
    );

    for (final row in rows) {
      final map = row as Map<String, dynamic>;
      final isoCode = map['quote'] as String?;
      final rawRate = (map['rate'] as num?)?.toDouble();
      final date = map['date'] as String?;

      if (isoCode == null || rawRate == null || rawRate == 0 || date == null) {
        continue;
      }

      final descriptor = byIsoCode[isoCode];
      if (descriptor == null) {
        continue;
      }

      final expression = descriptor.expressionFor(rawRate);

      _repo.registerDynamic(
        DerivedUnit(
          id: descriptor.unitId,
          aliases: descriptor.originalUnit.aliases,
          description: descriptor.originalUnit.description,
          expression: expression,
        ),
      );

      newRates[descriptor.unitId] = CurrencyRateEntry(
        rate: rawRate,
        date: date,
      );
    }

    await _rateRepo.save(
      CurrencyRates(
        updatedAt: DateTime.now().toUtc(),
        rates: newRates,
      ),
    );
    return null;
  }
}
