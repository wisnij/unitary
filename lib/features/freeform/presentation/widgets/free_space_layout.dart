import 'dart:math' as math;

import 'package:flutter/widgets.dart';

enum _Slot { content, area }

/// Stacks [content] above [area], giving [area] exactly the height that
/// [content] leaves unused.
///
/// [content] is laid out first and keeps its natural height, up to the
/// available height minus [minAreaHeight]; it should be a scroll view (or
/// otherwise cope with less height than it wants).  [area] is then given the
/// full width and all of the remaining height, and placed directly below
/// [content].  So [area] grows when [content] is short and is never smaller
/// than [minAreaHeight] (or the whole available height, if that is smaller).
///
/// A [Column] cannot express this: a loose `Flexible` child that uses less
/// than its share does not pass the leftover space to a sibling.
///
/// The widget itself fills its incoming constraints, which must be bounded.
class FreeSpaceLayout extends StatelessWidget {
  const FreeSpaceLayout({
    super.key,
    required this.content,
    required this.area,
    this.minAreaHeight = 0,
  });

  /// The primary content, laid out at its natural height when it fits.
  final Widget content;

  /// The widget that receives the height [content] does not use.
  final Widget area;

  /// The height reserved for [area] even when [content] wants all of it.
  final double minAreaHeight;

  @override
  Widget build(BuildContext context) {
    return CustomMultiChildLayout(
      delegate: _FreeSpaceDelegate(minAreaHeight),
      children: [
        LayoutId(id: _Slot.content, child: content),
        LayoutId(id: _Slot.area, child: area),
      ],
    );
  }
}

class _FreeSpaceDelegate extends MultiChildLayoutDelegate {
  _FreeSpaceDelegate(this.minAreaHeight);

  final double minAreaHeight;

  @override
  void performLayout(Size size) {
    final floor = math.min(minAreaHeight, size.height);
    final contentSize = layoutChild(
      _Slot.content,
      BoxConstraints(
        minWidth: size.width,
        maxWidth: size.width,
        maxHeight: size.height - floor,
      ),
    );
    positionChild(_Slot.content, Offset.zero);

    layoutChild(
      _Slot.area,
      BoxConstraints.tight(
        Size(size.width, size.height - contentSize.height),
      ),
    );
    positionChild(_Slot.area, Offset(0, contentSize.height));
  }

  @override
  bool shouldRelayout(_FreeSpaceDelegate oldDelegate) {
    return oldDelegate.minAreaHeight != minAreaHeight;
  }
}
