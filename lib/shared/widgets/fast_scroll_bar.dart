import 'dart:async';

import 'package:flutter/material.dart';

/// Wraps a scrollable [child] and overlays a draggable thumb on the right
/// edge.  While the thumb is dragged, a label bubble shows the current group
/// name derived from [groupAnchors].
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

  /// Key applied to the label bubble — used in widget tests.
  @visibleForTesting
  static const labelKey = ValueKey<String>('fast_scroll_bar_label');

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

  @override
  State<FastScrollBar> createState() => _FastScrollBarState();
}

class _FastScrollBarState extends State<FastScrollBar>
    with SingleTickerProviderStateMixin {
  static const _thumbWidth = 6.0;
  static const _thumbHeight = 48.0;
  static const _thumbRightPadding = 4.0;
  static const _fadeInDuration = Duration(milliseconds: 200);
  static const _idleTimeout = Duration(milliseconds: 1500);

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
    // After the first frame the controller is attached; check initial metrics.
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
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    if (!widget.active) {
      return widget.child;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        _listHeight = constraints.maxHeight;

        if (!_hasScrollableContent) {
          return widget.child;
        }

        final thumbTop = (_thumbFraction * (_listHeight - _thumbHeight)).clamp(
          0.0,
          _listHeight - _thumbHeight,
        );
        final label = FastScrollBar.labelForFraction(
          _thumbFraction,
          widget.groupAnchors,
          widget.itemCount,
        );

        return Stack(
          children: [
            widget.child,
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
                      child: const _ThumbWidget(),
                    ),
                  ),
                  if (_isDragging && label.isNotEmpty)
                    Positioned(
                      right: _thumbRightPadding + _thumbWidth + 8.0,
                      top: (thumbTop + _thumbHeight / 2 - 20.0).clamp(
                        0.0,
                        _listHeight - 40.0,
                      ),
                      child: _LabelBubble(
                        key: FastScrollBar.labelKey,
                        label: label,
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
    return Container(
      width: 6.0,
      height: 48.0,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(3.0),
      ),
    );
  }
}

class _LabelBubble extends StatelessWidget {
  const _LabelBubble({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      constraints: const BoxConstraints(minWidth: 40.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
