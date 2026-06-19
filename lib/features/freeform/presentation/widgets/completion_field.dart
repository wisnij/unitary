import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/completion/token_at_cursor.dart';
import '../../../../core/domain/models/completion_entry.dart';
import '../../state/completion_provider.dart';

/// Height of each suggestion row in the completion list.
const double _kRowHeight = 48.0;

/// Maximum number of suggestion rows visible at once without scrolling.
/// More entries may be present and are accessible by scrolling.
const int _kMaxVisibleRows = 8;

/// A [TextField] wrapper that displays an inline predictive-completion overlay
/// as the user types.
///
/// The overlay appears below (or above, when the field is in the lower half of
/// the viewport) whenever the cursor is at the end of a valid identifier of at
/// least 2 characters and at least one suggestion exists.  Tapping a row
/// replaces the partial token with the selected identifier and re-triggers
/// evaluation via [onChanged].
///
/// [controller] and [focusNode] must be managed by the caller; [CompletionField]
/// adds its own listeners and removes them on dispose.
class CompletionField extends ConsumerStatefulWidget {
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

  /// Called whenever the text changes (including after a completion insertion).
  final ValueChanged<String>? onChanged;

  /// Called when the user submits the field.
  final ValueChanged<String>? onSubmitted;

  /// The keyboard action button to display, forwarded to the inner [TextField].
  final TextInputAction? textInputAction;

  @override
  ConsumerState<CompletionField> createState() => _CompletionFieldState();
}

/// Returns a new [TextEditingValue] with the identifier ending at the current
/// cursor replaced by [completion], or [value] unchanged if no identifier token
/// is detected at the cursor.
///
/// Extracted as a pure function for testability.
TextEditingValue applyCompletion(
  TextEditingValue value,
  String completion,
) {
  final cursorOffset =
      value.selection.isValid && value.selection.baseOffset >= 0
      ? value.selection.baseOffset
      : value.text.length;
  final token = tokenAtCursor(value.text, cursorOffset);
  if (token == null) {
    return value;
  }
  final newText = value.text.replaceRange(
    token.start,
    cursorOffset,
    completion,
  );
  final newOffset = token.start + completion.length;
  return TextEditingValue(
    text: newText,
    selection: TextSelection.collapsed(offset: newOffset),
  );
}

class _CompletionFieldState extends ConsumerState<CompletionField> {
  final _layerLink = LayerLink();
  final _overlayController = OverlayPortalController();

  /// Whether the overlay should render above the field (when the field is in
  /// the lower half of the viewport).
  bool _showAbove = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChange);
    widget.focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(CompletionField old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      old.controller.removeListener(_onControllerChange);
      widget.controller.addListener(_onControllerChange);
    }
    if (old.focusNode != widget.focusNode) {
      old.focusNode.removeListener(_onFocusChange);
      widget.focusNode.addListener(_onFocusChange);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChange);
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  void _onControllerChange() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onFocusChange() {
    if (mounted) {
      setState(() {});
    }
  }

  CompletionQuery get _query {
    final ctrl = widget.controller;
    final offset = ctrl.selection.isValid && ctrl.selection.baseOffset >= 0
        ? ctrl.selection.baseOffset
        : ctrl.text.length;
    return CompletionQuery(text: ctrl.text, cursorOffset: offset);
  }

  void _updateAbove() {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) {
      return;
    }
    final pos = box.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.of(context).size.height;
    final fieldCenterY = pos.dy + box.size.height / 2;
    final shouldBeAbove = fieldCenterY > screenHeight / 2;
    if (shouldBeAbove != _showAbove) {
      setState(() {
        _showAbove = shouldBeAbove;
      });
    }
  }

  void _syncOverlay(bool shouldShow) {
    if (shouldShow && !_overlayController.isShowing) {
      _overlayController.show();
    } else if (!shouldShow && _overlayController.isShowing) {
      _overlayController.hide();
    }
  }

  /// The label shown in the overlay row for [entry].
  ///
  /// - Units: plain name (`kg`)
  /// - Prefixes: name with a trailing `-` (`kilo-`) to signal that a unit name
  ///   follows, but the dash is **not** inserted into the field.
  /// - Functions: name with a trailing `(` (`tempF(`) matching call-site style.
  String _displayName(CompletionEntry entry) => switch (entry.entryKind) {
    CompletionEntryKind.unit => entry.name,
    CompletionEntryKind.prefix => '${entry.name}-',
    CompletionEntryKind.function => '${entry.name}(',
  };

  /// The text written into the field when [entry] is selected.
  ///
  /// - Units: name followed by a space so the user can continue typing.
  /// - Prefixes: plain name (the trailing `-` from [_displayName] is omitted).
  /// - Functions: name with a trailing `(` matching [_displayName].
  String _insertText(CompletionEntry entry) => switch (entry.entryKind) {
    CompletionEntryKind.unit => '${entry.name} ',
    CompletionEntryKind.prefix => entry.name,
    CompletionEntryKind.function => '${entry.name}(',
  };

  void _insertCompletion(CompletionEntry entry) {
    _overlayController.hide();
    final newValue = applyCompletion(
      widget.controller.value,
      _insertText(entry),
    );
    widget.controller.value = newValue;
    // Restore focus to the text field, matching the behaviour of the operator
    // key panel.  On web, requestFocus() can cause the browser to select all
    // text, so re-apply the correct cursor position in the next frame.
    widget.focusNode.requestFocus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.controller.selection = newValue.selection;
      }
    });
    widget.onChanged?.call(widget.controller.text);
  }

  Widget _buildSuggestions(
    BuildContext context,
    List<CompletionEntry> suggestions,
  ) {
    final visibleCount = suggestions.length.clamp(0, _kMaxVisibleRows);
    final listHeight = visibleCount * _kRowHeight;

    final targetAnchor = _showAbove ? Alignment.topLeft : Alignment.bottomLeft;
    final followerAnchor = _showAbove
        ? Alignment.bottomLeft
        : Alignment.topLeft;

    // Cap the overlay width at the width of the input field so it never
    // overflows.  Read from the render object rather than storing state, so
    // the value is always current at build time.
    final box = this.context.findRenderObject() as RenderBox?;
    final maxWidth = (box != null && box.hasSize)
        ? box.size.width
        : double.infinity;

    return CompositedTransformFollower(
      link: _layerLink,
      targetAnchor: targetAnchor,
      followerAnchor: followerAnchor,
      child: Align(
        alignment: Alignment.topLeft,
        // ConstrainedBox + IntrinsicWidth together make the overlay exactly
        // as wide as its widest row, up to the field width.
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: IntrinsicWidth(
            child: Material(
              elevation: 4,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              // SingleChildScrollView + Column (not ListView) so that
              // IntrinsicWidth can query each row's natural width while still
              // allowing the list to scroll when there are more than
              // _kMaxVisibleRows entries.  The SizedBox caps the visible height
              // to _kMaxVisibleRows rows; the Column renders all suggestions.
              child: SizedBox(
                height: listHeight,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      for (var i = 0; i < suggestions.length; i++)
                        SizedBox(
                          height: _kRowHeight,
                          child: InkWell(
                            // On web, onTap fires after the browser focusout
                            // event removes focus from the text field, which
                            // hides the overlay before the tap is delivered.
                            // onTapDown fires at pointer-down, before focusout,
                            // so it works on both platforms.
                            // On mobile, onTapDown interferes with scrolling
                            // (a scroll drag starts with pointer-down), so we
                            // use onTap instead and keep onTapDown null.
                            onTapDown: kIsWeb
                                ? (_) => _insertCompletion(suggestions[i])
                                : null,
                            onTap: kIsWeb
                                ? () {} // non-null keeps InkWell press effects
                                : () => _insertCompletion(suggestions[i]),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(_displayName(suggestions[i])),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final suggestions = ref.watch(completionsProvider(_query));
    final shouldShow = widget.focusNode.hasFocus && suggestions.isNotEmpty;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _updateAbove();
      _syncOverlay(shouldShow);
    });

    return CompositedTransformTarget(
      link: _layerLink,
      child: OverlayPortal(
        controller: _overlayController,
        overlayChildBuilder: (context) =>
            _buildSuggestions(context, suggestions),
        child: TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          decoration: widget.decoration,
          textInputAction: widget.textInputAction,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
        ),
      ),
    );
  }
}
