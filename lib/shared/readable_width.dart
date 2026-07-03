import 'package:flutter/widgets.dart';

/// The maximum width, in logical pixels, that single-column screen content is
/// constrained to on wide layouts.
///
/// This is the single source of truth for the "readable width" cap shared by
/// the Freeform, Worksheet, and Settings screens.  Tune it here to adjust all of
/// them at once.
const double kReadableMaxWidth = 600;

/// Constrains [child] to at most [kReadableMaxWidth] logical pixels wide and
/// centers it horizontally, without affecting its vertical layout.
///
/// The constraint is inert when the incoming width is already at or below the
/// cap (e.g. on a phone): the child fills the available width unchanged.  On
/// wider layouts (landscape tablets, desktop web) the child is capped and
/// centered, leaving equal margins on both sides so single-column content does
/// not stretch to an uncomfortable width.
///
/// Uses [Alignment.topCenter] rather than [Center] so it only centers on the
/// horizontal axis: the child keeps its natural vertical extent and top
/// alignment.  Wrap it around content whose height is bounded by an ancestor
/// (e.g. a scroll view inside an [Expanded], or a [Scaffold] body); it is a
/// horizontal cap, not a vertical one.
class ReadableWidth extends StatelessWidget {
  const ReadableWidth({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: kReadableMaxWidth),
        child: child,
      ),
    );
  }
}
