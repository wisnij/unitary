import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/domain/models/unit_repository_provider.dart';
import '../../../core/domain/parser/expression_parser.dart';

/// Provides a singleton [ExpressionParser] backed by [unitRepositoryProvider].
final parserProvider = Provider<ExpressionParser>((ref) {
  return ExpressionParser(repo: ref.read(unitRepositoryProvider));
});
