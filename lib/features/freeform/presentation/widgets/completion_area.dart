import 'package:flutter/foundation.dart' show kIsWeb, listEquals;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/completion/token_at_cursor.dart';
import '../../../../core/domain/models/completion_entry.dart';
import '../../state/completion_provider.dart';
import 'free_space_layout.dart';

/// Height of one line of suggestion chips, which is also the height of each
/// chip's touch target.
const double kCompletionChipLineHeight = 48.0;

/// Minimum width of a chip, and so of its touch target.
const double _kChipMinTapWidth = 48.0;

/// Height of the visible pill inside a chip's touch target.
const double _kChipVisualHeight = 32.0;

/// Horizontal inset of the chips, matching the freeform content's padding so
/// the chips line up with the expression fields.
const double _kAreaHorizontalPadding = 16.0;

/// The accessible label announced for a completion [entry].
///
/// Composed as `"<name>, <kind>"` so a screen reader hears both the identifier
/// and what kind of entry it is (unit / prefix / function) — information the
/// sighted display encodes only through the trailing `-` or `(` in
/// [completionDisplayName].  Uses [CompletionEntry.name] (not the display
/// text) so the spoken name carries no trailing punctuation.
///
/// Written as an exhaustive `switch` with no `default`: adding a new
/// [CompletionEntryKind] is a compile error until it is given a label here.
String completionSemanticLabel(CompletionEntry entry) =>
    switch (entry.entryKind) {
      CompletionEntryKind.unit => '${entry.name}, unit',
      CompletionEntryKind.prefix => '${entry.name}, prefix',
      CompletionEntryKind.function => '${entry.name}, function',
    };

/// The label shown on the chip for [entry].
///
/// - Units: plain name (`kg`)
/// - Prefixes: name with a trailing `-` (`kilo-`) to signal that a unit name
///   follows; the dash is **not** inserted into the field.
/// - Functions: name with a trailing `(` (`tempF(`) matching call-site style.
String completionDisplayName(CompletionEntry entry) =>
    switch (entry.entryKind) {
      CompletionEntryKind.unit => entry.name,
      CompletionEntryKind.prefix => '${entry.name}-',
      CompletionEntryKind.function => '${entry.name}(',
    };

/// The text written into the field when [entry] is selected.
///
/// - Units: name followed by a space so the user can continue typing.
/// - Prefixes: plain name (the trailing `-` of [completionDisplayName] is
///   omitted).
/// - Functions: name with a trailing `(` matching [completionDisplayName].
String completionInsertText(CompletionEntry entry) => switch (entry.entryKind) {
  CompletionEntryKind.unit => '${entry.name} ',
  CompletionEntryKind.prefix => entry.name,
  CompletionEntryKind.function => '${entry.name}(',
};

/// Returns a new [TextEditingValue] with the identifier ending at the current
/// cursor replaced by [completion], or [value] unchanged if no identifier token
/// is detected at the cursor.
///
/// Extracted as a pure function for testability.
TextEditingValue applyCompletion(
  TextEditingValue value,
  String completion,
) {
  final cursorOffset = _cursorOffset(value);
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

int _cursorOffset(TextEditingValue value) {
  return value.selection.isValid && value.selection.baseOffset >= 0
      ? value.selection.baseOffset
      : value.text.length;
}

/// One expression field that the completion area can serve.
class CompletionTarget {
  const CompletionTarget({
    required this.controller,
    required this.focusNode,
    this.onChanged,
  });

  /// The field's text and cursor position.
  final TextEditingController controller;

  /// The field's focus; suggestions are shown only for a focused field.
  final FocusNode focusNode;

  /// Called with the new text after a suggestion is inserted, as if the user
  /// had typed it.
  final ValueChanged<String>? onChanged;
}

/// Lays out [child] with a [CompletionArea] in the space below it, and feeds
/// that area the suggestions for whichever of [targets] has focus.
///
/// Suggestions exist when a target has focus, its cursor is at the end of an
/// identifier of at least 2 characters, and the repository has a match.  The
/// area then takes all the height [child] leaves free, and at least one chip
/// line ([kCompletionChipLineHeight]) even when [child] wants all of it.
/// Without suggestions the area reserves nothing.
///
/// Selecting a suggestion replaces the partial identifier in the focused
/// target, returns focus to it, and calls its [CompletionTarget.onChanged].
///
/// This widget rebuilds on every keystroke, but [child] is the instance its
/// parent built, so the content subtree is not rebuilt with it.
class CompletionAreaLayout extends ConsumerStatefulWidget {
  const CompletionAreaLayout({
    super.key,
    required this.targets,
    required this.child,
  });

  /// The fields served by the area.  Controllers and focus nodes are owned by
  /// the caller.
  final List<CompletionTarget> targets;

  /// The content shown above the area; normally a scroll view.
  final Widget child;

  @override
  ConsumerState<CompletionAreaLayout> createState() =>
      _CompletionAreaLayoutState();
}

class _CompletionAreaLayoutState extends ConsumerState<CompletionAreaLayout> {
  Listenable? _listenable;

  /// The target whose suggestions were shown by the latest build.
  CompletionTarget? _active;

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  @override
  void didUpdateWidget(CompletionAreaLayout old) {
    super.didUpdateWidget(old);
    if (!listEquals(old.targets, widget.targets)) {
      _unsubscribe();
      _subscribe();
    }
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  void _subscribe() {
    _listenable = Listenable.merge([
      for (final target in widget.targets) ...[
        target.controller,
        target.focusNode,
      ],
    ])..addListener(_onChange);
  }

  void _unsubscribe() {
    _listenable?.removeListener(_onChange);
    _listenable = null;
  }

  void _onChange() {
    if (mounted) {
      setState(() {});
    }
  }

  void _insert(CompletionEntry entry) {
    final target = _active;
    if (target == null) {
      return;
    }
    final newValue = applyCompletion(
      target.controller.value,
      completionInsertText(entry),
    );
    target.controller.value = newValue;
    // Restore focus to the text field, matching the behaviour of the operator
    // key panel.  On web, requestFocus() can cause the browser to select all
    // text, so re-apply the correct cursor position in the next frame.
    target.focusNode.requestFocus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        target.controller.selection = newValue.selection;
      }
    });
    target.onChanged?.call(target.controller.text);
  }

  @override
  Widget build(BuildContext context) {
    CompletionTarget? active;
    for (final target in widget.targets) {
      if (target.focusNode.hasFocus) {
        active = target;
        break;
      }
    }
    _active = active;

    final suggestions = active == null
        ? const <CompletionEntry>[]
        : ref.watch(
            completionsProvider(
              CompletionQuery(
                text: active.controller.text,
                cursorOffset: _cursorOffset(active.controller.value),
              ),
            ),
          );

    return FreeSpaceLayout(
      content: widget.child,
      area: CompletionArea(suggestions: suggestions, onSelected: _insert),
      minAreaHeight: suggestions.isEmpty ? 0 : kCompletionChipLineHeight,
    );
  }
}

/// Shows [suggestions] as chips that wrap onto as many lines as needed, in
/// the order given, and scrolls vertically when they do not fit its height.
///
/// The area fills the size it is given.  Each chip has a touch target one
/// chip line high and at least 48 dp wide, is never wider than the area, and
/// reports [onSelected] when tapped.  The scroll position returns to the top
/// whenever [suggestions] changes.
class CompletionArea extends StatefulWidget {
  const CompletionArea({
    super.key,
    required this.suggestions,
    required this.onSelected,
  });

  /// The suggestions to show, best first.
  final List<CompletionEntry> suggestions;

  /// Called with the suggestion the user tapped.
  final ValueChanged<CompletionEntry> onSelected;

  @override
  State<CompletionArea> createState() => _CompletionAreaState();
}

class _CompletionAreaState extends State<CompletionArea> {
  final _scrollController = ScrollController();

  @override
  void didUpdateWidget(CompletionArea old) {
    super.didUpdateWidget(old);
    if (!identical(old.suggestions, widget.suggestions) &&
        _scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.suggestions.isEmpty) {
      return const SizedBox.expand();
    }
    // On web and desktop, a text field drops its focus at a pointer-down
    // outside it.  The tap region makes the chips count as part of the field,
    // so a chip tap leaves the focus where it is.
    return TextFieldTapRegion(
      child: Material(
        type: MaterialType.transparency,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(
            horizontal: _kAreaHorizontalPadding,
          ),
          child: SizedBox(
            width: double.infinity,
            child: Wrap(
              spacing: 8,
              children: [
                for (final entry in widget.suggestions)
                  _CompletionChip(
                    entry: entry,
                    onSelected: () => widget.onSelected(entry),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One suggestion: an outlined pill, at least 48 dp wide, inside a touch
/// target one chip line high.
///
/// Built on [OutlinedButton] for its padded tap target: taps in the padding
/// around the pill count as taps on it, while the hover and press highlights
/// stay inside the pill's border.
class _CompletionChip extends StatelessWidget {
  const _CompletionChip({required this.entry, required this.onSelected});

  final CompletionEntry entry;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final button = OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.onSurface,
        textStyle: theme.textTheme.labelLarge,
        minimumSize: const Size(_kChipMinTapWidth, _kChipVisualHeight),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        shape: const StadiumBorder(),
        side: BorderSide(color: colorScheme.outline),
        // Pads the tap target out to 48 dp without enlarging the pill.  The
        // density is fixed because the desktop default (compact) would
        // shrink both.
        tapTargetSize: MaterialTapTargetSize.padded,
        visualDensity: VisualDensity.standard,
      ),
      // On web the selection is made at pointer-down (see below); the
      // callback stays non-null there to keep the button enabled.
      onPressed: kIsWeb ? () {} : onSelected,
      // Announce "<name>, <kind>"; the visible display text (with its
      // trailing -/( ) is excluded so the punctuation is not read out
      // literally.
      child: Semantics(
        label: completionSemanticLabel(entry),
        child: ExcludeSemantics(
          child: Text(
            completionDisplayName(entry),
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
    if (!kIsWeb) {
      return button;
    }
    // On web, a press completes after the browser's focusout event has taken
    // focus from the text field, which clears the suggestions before the tap
    // is delivered.  Pointer-down arrives before focusout.  This is not used
    // on mobile, where pointer-down is also how a scroll drag starts.
    return Listener(onPointerDown: (_) => onSelected(), child: button);
  }
}
