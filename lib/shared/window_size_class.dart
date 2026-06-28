import 'package:flutter/widgets.dart';

/// The responsive size tier of the current layout, derived purely from the
/// available width.
///
/// This is the single source of truth for the app's two responsive
/// breakpoints.  [AppShell] reads it to choose between a navigation drawer and
/// a persistent rail; `TwoPaneLayout` reads it to choose between a single pane
/// and a side-by-side split; tier-aware AppBar elements read it where they
/// adapt.
enum WindowSizeClass {
  /// Phone-sized: navigation drawer, single pane.
  compact,

  /// Small tablet / split window: navigation drawer, two panes.
  medium,

  /// Large tablet / desktop: persistent navigation rail, two panes.
  expanded;

  /// Widths `>= this` are at least [medium] (below it is [compact]).
  static const double mediumBreakpoint = 600;

  /// Widths `> this` are [expanded] (at or below it is [medium]).
  static const double expandedBreakpoint = 1040;

  /// The size class for a given layout [width] in logical pixels.
  static WindowSizeClass fromWidth(double width) {
    if (width < mediumBreakpoint) {
      return WindowSizeClass.compact;
    }
    if (width <= expandedBreakpoint) {
      return WindowSizeClass.medium;
    }
    return WindowSizeClass.expanded;
  }

  /// The size class for the nearest enclosing [MediaQuery].
  ///
  /// Establishes a dependency on the ambient `MediaQuery`, so widgets that call
  /// this rebuild automatically when the window is resized across a breakpoint.
  static WindowSizeClass of(BuildContext context) =>
      fromWidth(MediaQuery.sizeOf(context).width);

  /// Whether this is the [compact] tier (single pane, drawer).
  bool get isCompact => this == WindowSizeClass.compact;

  /// Whether two panes should be shown side by side ([medium] or [expanded]).
  bool get showsTwoPanes => this != WindowSizeClass.compact;

  /// Whether top-level navigation uses a persistent rail ([expanded] only).
  bool get usesRail => this == WindowSizeClass.expanded;
}
