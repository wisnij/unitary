import 'package:flutter/material.dart';

import '../features/browser/presentation/browser_screen.dart';
import '../features/freeform/presentation/freeform_screen.dart';
import '../features/worksheet/presentation/worksheet_screen.dart';
import 'top_level_page.dart';

/// Main app screen: an [IndexedStack] over the three top-level pages.
///
/// Each page owns its own [Scaffold], [AppBar], and [AppDrawer].  Navigation
/// between pages is handled via the [onNavigate] callback passed to each
/// screen's [AppDrawer].  [IndexedStack] keeps all pages in the widget tree
/// simultaneously, preserving their widget state across navigation.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TopLevelPage _currentPage = TopLevelPage.freeform;

  void _switchPage(TopLevelPage page) {
    if (_currentPage != page) {
      setState(() => _currentPage = page);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: _currentPage.index,
      children: [
        FreeformScreen(onNavigate: _switchPage),
        WorksheetScreen(onNavigate: _switchPage),
        BrowserScreen(onNavigate: _switchPage),
      ],
    );
  }
}
