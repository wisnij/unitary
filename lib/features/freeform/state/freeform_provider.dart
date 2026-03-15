import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/domain/errors.dart';
import '../../../core/domain/models/quantity.dart';
import '../../../core/domain/parser/ast.dart';
import '../../../core/domain/parser/expression_parser.dart';
import '../../../shared/utils/quantity_formatter.dart';
import '../../settings/state/settings_provider.dart';
import 'freeform_state.dart';
import 'parser_provider.dart';

/// Provides the current freeform evaluation state.
final freeformProvider = NotifierProvider<FreeformNotifier, EvaluationResult>(
  FreeformNotifier.new,
);

/// Manages freeform expression evaluation state.
class FreeformNotifier extends Notifier<EvaluationResult> {
  @override
  EvaluationResult build() => const EvaluationIdle();

  /// Evaluates the input and output fields and updates state accordingly.
  ///
  /// Calls [ExpressionParser.parseQuery] on each non-empty field and
  /// dispatches based on the resulting AST node types:
  ///
  /// - Input is [FunctionNameNode] (forward) + empty output → show definition.
  /// - Input is [FunctionNameNode] (inverse) + empty output → show inverse expr.
  /// - Expression input + [FunctionNameNode] (forward) output → apply inverse.
  /// - Expression input + [FunctionNameNode] (inverse) output → error.
  /// - Expression input + empty or expression output → existing paths.
  void evaluate(String input, String output) {
    if (input.trim().isEmpty) {
      state = const EvaluationIdle();
      return;
    }

    try {
      final parser = ref.read(parserProvider);

      final inputNode = parser.parseQuery(input);
      final outputNode = output.trim().isEmpty
          ? null
          : parser.parseQuery(output);

      // Function name in input field with empty output.
      if (inputNode is FunctionNameNode && outputNode == null) {
        state = _handleFunctionNameInput(parser, inputNode);
        return;
      }

      // Function name in output field.
      if (outputNode is FunctionNameNode) {
        if (inputNode is! ExpressionNode) {
          state = const EvaluationError(message: 'Input must be an expression');
          return;
        }

        state = _handleFunctionNameOutput(parser, inputNode, outputNode);
        return;
      }

      // Both sides are expressions.
      if (outputNode == null) {
        _evaluateSingle(parser, inputNode as ExpressionNode);
      } else {
        _evaluateConversion(
          parser,
          inputNode as ExpressionNode,
          outputNode as ExpressionNode,
          output,
        );
      }
    } on UnitaryException catch (e) {
      state = EvaluationError(message: e.message);
    }
  }

  EvaluationResult _handleFunctionNameInput(
    ExpressionParser parser,
    FunctionNameNode node,
  ) {
    final func = parser.repo?.findFunction(node.name);
    if (func == null) {
      return EvaluationError(message: 'Unknown function: "${node.name}"');
    }
    final label = node.inverse
        ? '~${node.name} ='
        : '${node.name}(${func.params.join(', ')}) =';
    final expression = node.inverse
        ? func.inverseDisplay
        : func.definitionDisplay;
    return FunctionDefinitionResult(label: label, expression: expression);
  }

  EvaluationResult _handleFunctionNameOutput(
    ExpressionParser parser,
    ExpressionNode inputNode,
    FunctionNameNode outputNode,
  ) {
    if (outputNode.inverse) {
      return EvaluationError(
        message: '"~${outputNode.name}" is not valid as a conversion target',
      );
    }

    final func = parser.repo?.findFunction(outputNode.name);
    if (func == null) {
      return EvaluationError(
        message: 'Unknown function: "${outputNode.name}"',
      );
    }
    if (!func.hasInverse) {
      return EvaluationError(
        message: 'No inverse defined for "${outputNode.name}"',
      );
    }

    final inputQty = parser.evaluateNode(inputNode);
    final settings = ref.read(settingsProvider);
    final result = func.callInverse(
      [inputQty],
      EvalContext(repo: parser.repo, visited: parser.visited),
    );
    final formatted = formatQuantity(
      result,
      precision: settings.precision,
      notation: settings.notation,
    );
    return FunctionConversionResult(
      functionName: outputNode.name,
      formattedValue: formatted,
    );
  }

  void _evaluateSingle(ExpressionParser parser, ExpressionNode inputNode) {
    final settings = ref.read(settingsProvider);
    final result = parser.evaluateNode(inputNode);
    final formatted = formatQuantity(
      result,
      precision: settings.precision,
      notation: settings.notation,
    );
    state = EvaluationSuccess(result: result, formattedResult: formatted);
  }

  void _evaluateConversion(
    ExpressionParser parser,
    ExpressionNode inputNode,
    ExpressionNode outputNode,
    String output,
  ) {
    final settings = ref.read(settingsProvider);
    final inputQty = parser.evaluateNode(inputNode);
    final outputQty = parser.evaluateNode(outputNode);

    if (!_isConversionConformable(parser, inputQty, outputQty)) {
      state = EvaluationError(
        message:
            'Cannot convert ${inputQty.dimension.canonicalRepresentation()} '
            'to ${outputQty.dimension.canonicalRepresentation()}',
      );
      return;
    }

    final convertedValue = inputQty.value / outputQty.value;
    final reciprocalValue = 1.0 / convertedValue;
    final outputUnit = output.trim();
    final formattedUnit = formatOutputUnit(outputUnit);
    final formatted = formatValue(
      convertedValue,
      precision: settings.precision,
      notation: settings.notation,
    );
    final formattedReciprocal = formatValue(
      reciprocalValue,
      precision: settings.precision,
      notation: settings.notation,
    );
    state = ConversionSuccess(
      convertedValue: convertedValue,
      formattedResult: '= $formatted $formattedUnit',
      formattedReciprocal: '= (1 / $formattedReciprocal) $formattedUnit',
      outputUnit: outputUnit,
    );
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
