import 'package:material_ui/material_ui.dart';

/// A [TextField] configured for entering expressions.
///
/// It soft-wraps long expressions, keeps Enter as a submit action, and turns
/// off the keyboard's own capitalization, autocorrect, and word suggestions,
/// which do not suit unit identifiers.  The app's replacement for keyboard
/// suggestions is the completion area (see `completion_area.dart`), which
/// reads this field's [controller] and [focusNode].
class CompletionField extends StatelessWidget {
  const CompletionField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.decoration,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction,
  });

  /// Controls the text content and cursor position.
  final TextEditingController controller;

  /// Controls focus for this field.
  final FocusNode focusNode;

  /// Decoration forwarded to the inner [TextField].
  final InputDecoration decoration;

  /// Called whenever the user changes the text.
  final ValueChanged<String>? onChanged;

  /// Called when the user submits the field.
  final ValueChanged<String>? onSubmitted;

  /// The keyboard action button to display, forwarded to the inner [TextField].
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      decoration: decoration,
      // Soft-wrap long expressions and grow vertically without bound.
      // The explicit textInputAction passed by callers keeps Enter as
      // submit rather than the multiline default of inserting a newline.
      maxLines: null,
      // Load-bearing: with maxLines != 1 and no explicit keyboardType,
      // Flutter infers TextInputType.multiline, which Android IMEs treat
      // as prose input and auto-capitalize (breaking case-sensitive unit
      // lookup) even though TextCapitalization.none is sent.  Wrapping is
      // purely a rendering concern, so a plain-text keyboard is safe here.
      keyboardType: TextInputType.text,
      // Expression content is unit identifiers and operators, not
      // dictionary words; the completion area is the domain-aware
      // replacement for IME suggestions.
      autocorrect: false,
      enableSuggestions: false,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
    );
  }
}
