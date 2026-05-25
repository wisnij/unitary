import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/completion/token_at_cursor.dart';
import '../../../../core/domain/models/completion_entry.dart';
import '../../state/completion_provider.dart';

/// Height of each suggestion row in the completion list.
const double _kRowHeight = 48.0;

/// Maximum number of suggestion rows visible at once.
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

  void _insertCompletion(String name) {
    _overlayController.hide();
    widget.controller.value = applyCompletion(widget.controller.value, name);
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

    return CompositedTransformFollower(
      link: _layerLink,
      targetAnchor: targetAnchor,
      followerAnchor: followerAnchor,
      child: Align(
        alignment: Alignment.topLeft,
        child: Material(
          elevation: 4,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: SizedBox(
            height: listHeight,
            child: ListView.builder(
              itemCount: visibleCount,
              itemExtent: _kRowHeight,
              itemBuilder: (context, index) {
                final entry = suggestions[index];
                return InkWell(
                  onTap: () => _insertCompletion(entry.name),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(entry.name),
                    ),
                  ),
                );
              },
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
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
        ),
      ),
    );
  }
}
