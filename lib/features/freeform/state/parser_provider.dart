import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/domain/models/unit_repository.dart';
import '../../../core/domain/parser/expression_parser.dart';

/// Provides a singleton [ExpressionParser] with built-in units.
final parserProvider = Provider<ExpressionParser>((ref) {
  return ExpressionParser(repo: UnitRepository.withBuiltinUnits());
});
