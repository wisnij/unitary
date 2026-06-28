import 'package:flutter/material.dart';

import 'window_size_class.dart';

/// Which of a [TwoPaneLayout]'s two panes is shown at the compact size class.
enum PaneSide { left, right }

/// How a [TwoPaneLayout] pane is sized along the horizontal axis when both
/// panes are shown.
///
/// - [PaneSize.fixed] — an exact width in logical pixels.
/// - [PaneSize.fitContent] — sizes to the pane content's natural width, clamped
///   to optional [min]/[max].  Only valid for content with a finite intrinsic
///   width; a vertical scrolling list must instead use [fixed] or supply a
///   [max] so the pane has a bounded width.
/// - [PaneSize.fill] — expands to absorb the remaining width, split among fill
///   panes in proportion to [flex].
sealed class PaneSize {
  const PaneSize();

  const factory PaneSize.fixed(double width) = FixedPaneSize;
  const factory PaneSize.fitContent({double? min, double? max}) =
      FitContentPaneSize;
  const factory PaneSize.fill({int flex}) = FillPaneSize;
}

/// A pane of an exact [width].
class FixedPaneSize extends PaneSize {
  const FixedPaneSize(this.width);

  final double width;
}

/// A pane that sizes to its content's natural width, clamped to [min]/[max].
class FitContentPaneSize extends PaneSize {
  const FitContentPaneSize({this.min, this.max});

  final double? min;
  final double? max;
}

/// A pane that fills the remaining width, weighted by [flex].
class FillPaneSize extends PaneSize {
  const FillPaneSize({this.flex = 1});

  final int flex;
}

/// A responsive two-pane layout.
///
/// At the [WindowSizeClass.medium] and [WindowSizeClass.expanded] tiers both
/// panes are shown side by side, separated by a vertical divider, each sized by
/// its [PaneSize].  At [WindowSizeClass.compact] only [compactPrimary] is shown
/// and fills the available space; the other pane occupies no layout space.
///
/// This widget is pure geometry: it knows nothing about its panes' contents.
class TwoPaneLayout extends StatelessWidget {
  const TwoPaneLayout({
    super.key,
    required this.left,
    required this.right,
    required this.compactPrimary,
    this.leftSize = const PaneSize.fill(),
    this.rightSize = const PaneSize.fill(),
  });

  final Widget left;
  final Widget right;

  /// Which pane is shown at the compact size class.
  final PaneSide compactPrimary;

  final PaneSize leftSize;
  final PaneSize rightSize;

  @override
  Widget build(BuildContext context) {
    if (!WindowSizeClass.of(context).showsTwoPanes) {
      return compactPrimary == PaneSide.left ? left : right;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sizedPane(leftSize, left),
        const VerticalDivider(width: 1, thickness: 1),
        _sizedPane(rightSize, right),
      ],
    );
  }

  /// Wraps [child] in the appropriate [Row] child for its [size].
  static Widget _sizedPane(PaneSize size, Widget child) {
    return switch (size) {
      FixedPaneSize(:final width) => SizedBox(width: width, child: child),
      FitContentPaneSize(:final min, :final max) => ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: min ?? 0.0,
          maxWidth: max ?? double.infinity,
        ),
        child: child,
      ),
      FillPaneSize(:final flex) => Expanded(flex: flex, child: child),
    };
  }
}
