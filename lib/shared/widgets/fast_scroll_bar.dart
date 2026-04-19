import 'dart:async';

import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// File-level constants (shared between state and sub-widgets)
// ---------------------------------------------------------------------------

// Thumb dimensions.
const _thumbWidth = 12.0;
const _thumbHitWidth = 44.0;
const _thumbHeight = 48.0;
const _thumbRightPadding = 4.0;

// Peek panel.
const _peekNeighbourCount = 2;
const _panelRightOffset = _thumbRightPadding + _thumbHitWidth + 8.0;

// Approximate row heights for peek-panel vertical positioning.
// These are used to align the current-group row with the thumb centre;
// small inaccuracies are acceptable since they only affect visual alignment.
const _approxNeighbourRowHeight = 22.0;
const _approxCurrentRowHalfHeight = 13.0;
const _panelTopPadding = 8.0;

// Animation.
const _fadeInDuration = Duration(milliseconds: 200);
const _idleTimeout = Duration(milliseconds: 1500);

// ---------------------------------------------------------------------------
// FastScrollBar
// ---------------------------------------------------------------------------

/// Wraps a scrollable [child] and overlays a draggable thumb on the right
/// edge.  While the thumb is dragged, a peek panel shows the current group
/// and its immediate neighbours derived from [groupAnchors].
///
/// Set [active] to `false` to suppress the overlay entirely (e.g. during
/// search, when the filtered list is short).
class FastScrollBar extends StatefulWidget {
  const FastScrollBar({
    super.key,
    required this.controller,
    required this.child,
    required this.itemCount,
    required this.groupAnchors,
    this.active = true,
  });

  final ScrollController controller;
  final Widget child;

  /// Total number of items in the flat list backing [child].
  final int itemCount;

  /// Ordered list of (flat-list item index, group label) pairs, one per group
  /// header.  Must be sorted ascending by item index.
  final List<(int, String)> groupAnchors;

  /// When false, renders only [child] with no thumb or label overlay.
  final bool active;

  /// Key applied to the thumb [GestureDetector] — used in widget tests.
  @visibleForTesting
  static const thumbKey = ValueKey<String>('fast_scroll_bar_thumb');

  /// Key applied to the peek panel — used in widget tests.
  @visibleForTesting
  static const peekPanelKey = ValueKey<String>('fast_scroll_bar_peek_panel');

  /// Key applied to the grip-lines [Column] inside the thumb — used in widget tests.
  @visibleForTesting
  static const gripLinesKey = ValueKey<String>('fast_scroll_bar_grip_lines');

  /// Key applied to the [FadeTransition] wrapping the thumb overlay — used
  /// in widget tests to read the current opacity value.
  @visibleForTesting
  static const overlayKey = ValueKey<String>('fast_scroll_bar_overlay');

  /// Maps a scroll [fraction] (0.0–1.0) to the label of the group at that
  /// position using [anchors] and [itemCount].
  ///
  /// Returns the label of the last anchor whose item index is ≤
  /// `(fraction × itemCount).round()`.  Returns an empty string when
  /// [anchors] is empty or [itemCount] is zero.
  ///
  /// Exposed as a public static method for unit testing.
  static String labelForFraction(
    double fraction,
    List<(int, String)> anchors,
    int itemCount,
  ) {
    if (anchors.isEmpty || itemCount <= 0) {
      return '';
    }
    final target = (fraction * itemCount).round().clamp(0, itemCount - 1);
    var label = anchors.first.$2;
    for (final (idx, lbl) in anchors) {
      if (idx <= target) {
        label = lbl;
      } else {
        break;
      }
    }
    return label;
  }

  /// Returns the index of the current group within [anchors] for a given
  /// scroll [fraction] and [itemCount].
  ///
  /// Uses the same "last anchor whose item index ≤ target" algorithm as
  /// [labelForFraction].  Returns `-1` when [anchors] is empty or
  /// [itemCount] is zero.
  ///
  /// Exposed as a public static method for unit testing.
  static int groupIndexForFraction(
    double fraction,
    List<(int, String)> anchors,
    int itemCount,
  ) {
    if (anchors.isEmpty || itemCount <= 0) {
      return -1;
    }
    final target = (fraction * itemCount).round().clamp(0, itemCount - 1);
    var index = 0;
    for (var i = 0; i < anchors.length; i++) {
      if (anchors[i].$1 <= target) {
        index = i;
      } else {
        break;
      }
    }
    return index;
  }

  @override
  State<FastScrollBar> createState() => _FastScrollBarState();
}

// ---------------------------------------------------------------------------
// _FastScrollBarState
// ---------------------------------------------------------------------------

class _FastScrollBarState extends State<FastScrollBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  Timer? _hideTimer;

  /// 0.0–1.0 position of the thumb; updated by scroll events and drag.
  double _thumbFraction = 0.0;

  bool _isDragging = false;

  /// True once the scroll controller reports scrollable content
  /// (maxScrollExtent > 0).  Guards whether the overlay is built at all.
  bool _hasScrollableContent = false;

  /// Captured from [LayoutBuilder] each frame; used by drag callbacks.
  double _listHeight = 0.0;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: _fadeInDuration,
      vsync: this,
    );
    widget.controller.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _onScroll();
      }
    });
  }

  @override
  void didUpdateWidget(FastScrollBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onScroll);
      widget.controller.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    widget.controller.removeListener(_onScroll);
    _fadeController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Scroll listener
  // ---------------------------------------------------------------------------

  void _onScroll() {
    if (!widget.controller.hasClients) {
      return;
    }
    final position = widget.controller.position;
    final maxExtent = position.maxScrollExtent;

    if (maxExtent <= 0) {
      if (_hasScrollableContent) {
        setState(() {
          _hasScrollableContent = false;
        });
        _hideTimer?.cancel();
        _fadeController.reverse();
      }
      return;
    }

    final newFraction = (position.pixels / maxExtent).clamp(0.0, 1.0);
    setState(() {
      _hasScrollableContent = true;
      _thumbFraction = newFraction;
    });

    if (!_isDragging) {
      _fadeController.forward();
      _resetHideTimer();
    }
  }

  void _resetHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(_idleTimeout, () {
      if (mounted) {
        _fadeController.reverse();
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Drag callbacks
  // ---------------------------------------------------------------------------

  void _onDragStart(DragStartDetails details) {
    _hideTimer?.cancel();
    setState(() {
      _isDragging = true;
    });
    _fadeController.forward();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (!widget.controller.hasClients) {
      return;
    }
    final position = widget.controller.position;
    if (position.maxScrollExtent <= 0) {
      return;
    }
    final trackHeight = _listHeight - _thumbHeight;
    if (trackHeight <= 0) {
      return;
    }
    final newFraction = (_thumbFraction + details.delta.dy / trackHeight).clamp(
      0.0,
      1.0,
    );
    setState(() {
      _thumbFraction = newFraction;
    });
    widget.controller.jumpTo(newFraction * position.maxScrollExtent);
  }

  void _onDragEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
    });
    _resetHideTimer();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Computes the top position for the peek panel so that the current-group
  /// row aligns vertically with the thumb centre.
  double _peekPanelTop(double thumbTop, int currentGroupIndex) {
    final thumbCenter = thumbTop + _thumbHeight / 2;
    final neighboursAbove = currentGroupIndex.clamp(0, _peekNeighbourCount);
    final offsetToCurrentCenter =
        _panelTopPadding +
        neighboursAbove * _approxNeighbourRowHeight +
        _approxCurrentRowHalfHeight;
    return (thumbCenter - offsetToCurrentCenter).clamp(0.0, _listHeight - 20.0);
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    if (!widget.active) {
      return widget.child;
    }

    // Suppress the native platform scrollbar: FastScrollBar provides its own.
    final child = ScrollConfiguration(
      behavior: const _NoScrollbarBehavior(),
      child: widget.child,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        _listHeight = constraints.maxHeight;

        if (!_hasScrollableContent) {
          return child;
        }

        final thumbTop = (_thumbFraction * (_listHeight - _thumbHeight)).clamp(
          0.0,
          _listHeight - _thumbHeight,
        );

        final currentGroupIndex = FastScrollBar.groupIndexForFraction(
          _thumbFraction,
          widget.groupAnchors,
          widget.itemCount,
        );

        return Stack(
          children: [
            child,
            FadeTransition(
              key: FastScrollBar.overlayKey,
              opacity: _fadeController,
              child: Stack(
                children: [
                  Positioned(
                    right: _thumbRightPadding,
                    top: thumbTop,
                    child: GestureDetector(
                      key: FastScrollBar.thumbKey,
                      behavior: HitTestBehavior.opaque,
                      onVerticalDragStart: _onDragStart,
                      onVerticalDragUpdate: _onDragUpdate,
                      onVerticalDragEnd: _onDragEnd,
                      child: const SizedBox(
                        width: _thumbHitWidth,
                        height: _thumbHeight,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: _ThumbWidget(),
                        ),
                      ),
                    ),
                  ),
                  if (_isDragging && currentGroupIndex >= 0)
                    Positioned(
                      right: _panelRightOffset,
                      top: _peekPanelTop(thumbTop, currentGroupIndex),
                      child: _PeekPanel(
                        key: FastScrollBar.peekPanelKey,
                        currentIndex: currentGroupIndex,
                        anchors: widget.groupAnchors,
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Private sub-widgets
// ---------------------------------------------------------------------------

class _ThumbWidget extends StatelessWidget {
  const _ThumbWidget();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gripColor = theme.colorScheme.onSurface.withValues(alpha: 0.4);
    return Container(
      width: _thumbWidth,
      height: _thumbHeight,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: Column(
        key: FastScrollBar.gripLinesKey,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _GripLine(color: gripColor),
          const SizedBox(height: 5.0),
          _GripLine(color: gripColor),
          const SizedBox(height: 5.0),
          _GripLine(color: gripColor),
        ],
      ),
    );
  }
}

class _GripLine extends StatelessWidget {
  const _GripLine({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8.0,
      height: 2.0,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(1.0),
      ),
    );
  }
}

class _PeekPanel extends StatelessWidget {
  const _PeekPanel({
    super.key,
    required this.currentIndex,
    required this.anchors,
  });

  final int currentIndex;
  final List<(int, String)> anchors;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final firstIndex = (currentIndex - _peekNeighbourCount).clamp(
      0,
      anchors.length - 1,
    );
    final lastIndex = (currentIndex + _peekNeighbourCount).clamp(
      0,
      anchors.length - 1,
    );

    final rows = <Widget>[];
    for (var i = firstIndex; i <= lastIndex; i++) {
      if (rows.isNotEmpty) {
        rows.add(const SizedBox(height: 2.0));
      }
      final isCurrent = i == currentIndex;
      rows.add(
        Text(
          anchors[i].$2,
          textAlign: TextAlign.right,
          style: isCurrent
              ? theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                )
              : theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onPrimary.withValues(alpha: 0.65),
                ),
        ),
      );
    }

    final maxWidth = MediaQuery.sizeOf(context).width * 0.6;
    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth.clamp(0.0, 220.0)),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: rows,
      ),
    );
  }
}

/// A [ScrollBehavior] that suppresses the platform-provided scrollbar widget,
/// used by [FastScrollBar] so only the custom thumb is shown.
class _NoScrollbarBehavior extends ScrollBehavior {
  const _NoScrollbarBehavior();

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}
