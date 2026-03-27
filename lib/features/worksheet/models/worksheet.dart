/// Determines how values are converted for a worksheet row.
sealed class WorksheetRowKind {
  const WorksheetRowKind();
}

/// A row whose expression is a unit or compound unit expression string
/// (e.g. `"ft"`, `"m/s"`, `"km^2"`).
///
/// Conversion is ratio-based: given source value `v` and source unit
/// quantity `U_src`, base = `v × U_src.value`.  Target value =
/// `base / U_target.value`.
class UnitRow extends WorksheetRowKind {
  const UnitRow();
}

/// A row whose expression is a bare registered function name
/// (e.g. `"tempC"`, `"tempF"`).
///
/// Forward conversion (row is source): base = `func.call([v])`.
/// Inverse conversion (row is target): display = `func.callInverse([base])`.
/// The function must have an inverse ([UnitaryFunction.hasInverse] == true).
class FunctionRow extends WorksheetRowKind {
  const FunctionRow();
}

/// A single row in a worksheet template.
class WorksheetRow {
  /// Human-readable label displayed in the UI (e.g., `"feet"`).
  final String label;

  /// Expression string parsed by [ExpressionParser].
  ///
  /// For [UnitRow]: any valid unit expression (e.g. `"ft"`, `"m/s"`).
  /// For [FunctionRow]: a bare registered function name (e.g. `"tempC"`).
  final String expression;

  /// Determines the conversion strategy for this row.
  final WorksheetRowKind kind;

  const WorksheetRow({
    required this.label,
    required this.expression,
    required this.kind,
  });
}

/// A named collection of [WorksheetRow]s representing a single conversion topic.
class WorksheetTemplate {
  /// Unique identifier used in state management (e.g., `"length"`).
  final String id;

  /// Human-readable name displayed in the UI (e.g., `"Length"`).
  final String name;

  /// Ordered list of rows.  Must be non-empty.
  final List<WorksheetRow> rows;

  const WorksheetTemplate({
    required this.id,
    required this.name,
    required this.rows,
  });
}
