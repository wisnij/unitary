/// Base class for all application-domain exceptions in Unitary.
abstract class UnitaryException implements Exception {
  /// Human-readable description of the error.
  String get message;

  /// Source line number where the error occurred, if applicable.
  int? get line;

  /// Source column number where the error occurred, if applicable.
  int? get column;

  @override
  String toString() {
    final prefix = runtimeType.toString();
    if (line != null && column != null) {
      return '$prefix ($line:$column): $message';
    }
    return '$prefix: $message';
  }
}

/// Error during lexical analysis (tokenization).
class LexException extends UnitaryException {
  @override
  final String message;

  @override
  final int? line;

  @override
  final int? column;

  LexException(this.message, {this.line, this.column});
}

/// Error during parsing (AST construction).
class ParseException extends UnitaryException {
  @override
  final String message;

  @override
  final int? line;

  @override
  final int? column;

  ParseException(this.message, {this.line, this.column});
}

/// Error during expression evaluation.
class EvalException extends UnitaryException {
  @override
  final String message;

  @override
  final int? line = null;

  @override
  final int? column = null;

  EvalException(this.message);
}

/// Error involving dimensional analysis (non-conformable operations).
class DimensionException extends UnitaryException {
  @override
  final String message;

  @override
  final int? line = null;

  @override
  final int? column = null;

  DimensionException(this.message);
}
