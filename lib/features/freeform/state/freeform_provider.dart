import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/domain/errors.dart';
import '../../../core/domain/models/quantity.dart';
import '../../../core/domain/parser/expression_parser.dart';
import '../../../shared/utils/quantity_formatter.dart';
import '../../settings/state/settings_provider.dart';
import 'freeform_state.dart';
import 'parser_provider.dart';

/// Provides the current freeform evaluation state.
final freeformProvider =
    StateNotifierProvider<FreeformNotifier, EvaluationResult>((ref) {
      return FreeformNotifier(ref);
    });

/// Manages freeform expression evaluation state.
class FreeformNotifier extends StateNotifier<EvaluationResult> {
  final Ref _ref;

  FreeformNotifier(this._ref) : super(const EvaluationIdle());

  /// Evaluates a single expression.
  void evaluateSingle(String input) {
    if (input.trim().isEmpty) {
      state = const EvaluationIdle();
      return;
    }

    try {
      final parser = _ref.read(parserProvider);
      final settings = _ref.read(settingsProvider);
      final result = parser.evaluate(input);
      final formatted = formatQuantity(
        result,
        precision: settings.precision,
        notation: settings.notation,
      );
      state = EvaluationSuccess(result: result, formattedResult: formatted);
    } on UnitaryException catch (e) {
      state = EvaluationError(message: e.message);
    }
  }

  /// Evaluates a two-expression conversion.
  void evaluateConversion(String input, String output) {
    if (input.trim().isEmpty) {
      state = const EvaluationIdle();
      return;
    }

    try {
      final parser = _ref.read(parserProvider);
      final settings = _ref.read(settingsProvider);
      final inputQty = parser.evaluate(input);
      final outputQty = parser.evaluate(output);

      if (!_isConversionConformable(parser, inputQty, outputQty)) {
        state = EvaluationError(
          message:
              'Cannot convert ${inputQty.dimension.canonicalRepresentation()} '
              'to ${outputQty.dimension.canonicalRepresentation()}',
        );
        return;
      }

      final convertedValue = inputQty.value / outputQty.value;
      final outputUnit = output.trim();
      final formatted = formatValue(
        convertedValue,
        precision: settings.precision,
        notation: settings.notation,
      );
      state = ConversionSuccess(
        convertedValue: convertedValue,
        formattedResult: '$formatted $outputUnit',
        outputUnit: outputUnit,
      );
    } on UnitaryException catch (e) {
      state = EvaluationError(message: e.message);
    }
  }

  /// Checks whether two quantities are conformable for conversion, stripping
  /// dimensionless units (like radian and steradian) before comparing.
  bool _isConversionConformable(
    ExpressionParser parser,
    Quantity inputQty,
    Quantity outputQty,
  ) {
    if (inputQty.isConformableWith(outputQty)) {
      return true;
    }
    final dimensionlessIds = parser.repo?.dimensionlessIds;
    if (dimensionlessIds == null || dimensionlessIds.isEmpty) {
      return false;
    }
    final strippedInput = inputQty.dimension.removeDimensions(dimensionlessIds);
    final strippedOutput = outputQty.dimension.removeDimensions(
      dimensionlessIds,
    );
    return strippedInput.isConformableWith(strippedOutput);
  }

  /// Resets to idle state.
  void clear() {
    state = const EvaluationIdle();
  }
}
