import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// WCAG 2.x contrast regression test for the app's custom-composed color
/// pairings (see openspec/specs/color-contrast/spec.md).
///
/// Each case intentionally duplicates the color-role and alpha literals used
/// by the widget it mirrors, rather than probing the widget tree: the cases
/// are a design contract ("these composed colors must clear these ratios"),
/// and each carries a comment naming the widget it corresponds to.  When a
/// widget's styling changes, update the matching case here — and when a new
/// custom pairing ships, add a case for it.
///
/// Deliberately absent (decorative exemptions, WCAG 1.4.11; recorded in the
/// color-contrast spec):
///
/// - `outlineVariant` borders on the completion overlay
///   (completion_field.dart) and unit-detail tables
///   (unit_entry_detail_screen.dart) — the overlay is identified by its
///   elevation and filled surface, the tables by their layout.
/// - The `surfaceContainerHighest`-derived background tints of the currency
///   banner (worksheet_banner.dart) and browse sticky group headers
///   (browser_screen.dart) — supplementary grouping cues; the text they
///   carry is asserted below.

/// Linearizes an sRGB channel value (0–1) per the WCAG 2.x definition.
double _linearize(double channel) {
  if (channel <= 0.03928) {
    return channel / 12.92;
  }
  return math.pow((channel + 0.055) / 1.055, 2.4).toDouble();
}

/// WCAG 2.x relative luminance of an opaque color.
double relativeLuminance(Color color) {
  return 0.2126 * _linearize(color.r) +
      0.7152 * _linearize(color.g) +
      0.0722 * _linearize(color.b);
}

/// WCAG 2.x contrast ratio between two opaque colors (order-independent).
double contrastRatio(Color a, Color b) {
  final luminanceA = relativeLuminance(a);
  final luminanceB = relativeLuminance(b);
  final lighter = math.max(luminanceA, luminanceB);
  final darker = math.min(luminanceA, luminanceB);
  return (lighter + 0.05) / (darker + 0.05);
}

/// Composites a translucent [foreground] over an opaque [background],
/// producing the opaque color actually shown on screen.
Color composite(Color foreground, Color background) {
  final alpha = foreground.a;
  return Color.from(
    alpha: 1.0,
    red: foreground.r * alpha + background.r * (1 - alpha),
    green: foreground.g * alpha + background.g * (1 - alpha),
    blue: foreground.b * alpha + background.b * (1 - alpha),
  );
}

/// One color pairing whose contrast ratio must meet [threshold] in both
/// themes.  [foreground] and [background] receive the scheme and must return
/// opaque colors ([composite] any alpha blends over their real backdrop).
class _ContrastCase {
  const _ContrastCase({
    required this.description,
    required this.foreground,
    required this.background,
    required this.threshold,
  });

  final String description;
  final Color Function(ColorScheme) foreground;
  final Color Function(ColorScheme) background;
  final double threshold;
}

const _text = 4.5; // WCAG 1.4.3, normal-size text
const _nonText = 3.0; // WCAG 1.4.11, UI components and state indicators

final List<_ContrastCase> _cases = [
  // Muted text on the page surface: result_display.dart secondary lines,
  // worksheet_screen.dart row labels, freeform/browse empty-state hints.
  _ContrastCase(
    description: 'onSurfaceVariant text on surface',
    foreground: (s) => s.onSurfaceVariant,
    background: (s) => s.surface,
    threshold: _text,
  ),
  // Currency banner text and icon (worksheet_banner.dart).
  _ContrastCase(
    description: 'onSurfaceVariant text on surfaceContainerHighest banner',
    foreground: (s) => s.onSurfaceVariant,
    background: (s) => s.surfaceContainerHighest,
    threshold: _text,
  ),
  // Idle-example chip in the freeform result area (freeform_screen.dart).
  _ContrastCase(
    description: 'onSurface text on surfaceContainerHighest chip',
    foreground: (s) => s.onSurface,
    background: (s) => s.surfaceContainerHighest,
    threshold: _text,
  ),
  // Freeform result text (result_display.dart) and worksheet row expression
  // text (worksheet_screen.dart).
  _ContrastCase(
    description: 'primary text on surface',
    foreground: (s) => s.primary,
    background: (s) => s.surface,
    threshold: _text,
  ),
  // Browse group header text over the half-strength sticky-header tint
  // (browser_screen.dart _GroupHeaderTile).
  _ContrastCase(
    description: 'primary text on surfaceContainerHighest@0.5 group header',
    foreground: (s) => s.primary,
    background: (s) =>
        composite(s.surfaceContainerHighest.withValues(alpha: 0.5), s.surface),
    threshold: _text,
  ),
  // Error messages (result_display.dart, worksheet cell errors).
  _ContrastCase(
    description: 'error text on surface',
    foreground: (s) => s.error,
    background: (s) => s.surface,
    threshold: _text,
  ),
  // Fast-scroll label panel, current group label (fast_scroll_bar.dart).
  _ContrastCase(
    description: 'onPrimary current label on primary scroll panel',
    foreground: (s) => s.onPrimary,
    background: (s) => s.primary,
    threshold: _text,
  ),
  // Text field enabled borders (Material default outline role).
  _ContrastCase(
    description: 'outline border on surface',
    foreground: (s) => s.outline,
    background: (s) => s.surface,
    threshold: _nonText,
  ),
  // Worksheet source-row indicator border (worksheet_screen.dart, D1).
  _ContrastCase(
    description: 'primary source-row border on surface',
    foreground: (s) => s.primary,
    background: (s) => s.surface,
    threshold: _nonText,
  ),
  // Fast-scroll label panel, de-emphasised neighbour labels
  // (fast_scroll_bar.dart _LabelPanel, D2).
  _ContrastCase(
    description: 'onPrimary@0.85 neighbour labels on primary scroll panel',
    foreground: (s) =>
        composite(s.onPrimary.withValues(alpha: 0.85), s.primary),
    background: (s) => s.primary,
    threshold: _text,
  ),
  // Fast-scroll thumb fill against the page (fast_scroll_bar.dart
  // _ThumbWidget, D3).
  _ContrastCase(
    description: 'primary@0.8 scroll thumb on surface',
    foreground: (s) => composite(s.primary.withValues(alpha: 0.8), s.surface),
    background: (s) => s.surface,
    threshold: _nonText,
  ),
  // Fast-scroll thumb grip lines against the composited thumb fill
  // (fast_scroll_bar.dart _ThumbWidget, D4).
  _ContrastCase(
    description: 'onPrimary@0.9 grip lines on scroll thumb',
    foreground: (s) => composite(
      s.onPrimary.withValues(alpha: 0.9),
      composite(s.primary.withValues(alpha: 0.8), s.surface),
    ),
    background: (s) => composite(s.primary.withValues(alpha: 0.8), s.surface),
    threshold: _nonText,
  ),
];

void main() {
  // The same schemes UnitaryApp constructs in lib/app.dart.
  final schemes = <String, ColorScheme>{
    'light': ColorScheme.fromSeed(seedColor: Colors.blue),
    'dark': ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.dark,
    ),
  };

  group('contrast helpers', () {
    test('black on white is 21:1', () {
      expect(
        contrastRatio(const Color(0xFF000000), const Color(0xFFFFFFFF)),
        closeTo(21.0, 0.01),
      );
    });

    test('identical colors are 1:1', () {
      expect(
        contrastRatio(const Color(0xFF123456), const Color(0xFF123456)),
        closeTo(1.0, 0.001),
      );
    });

    test('composite blends by alpha over an opaque background', () {
      final blended = composite(
        const Color(0xFFFFFFFF).withValues(alpha: 0.5),
        const Color(0xFF000000),
      );
      expect(blended.a, 1.0);
      expect(blended.r, closeTo(0.5, 0.001));
      expect(blended.g, closeTo(0.5, 0.001));
      expect(blended.b, closeTo(0.5, 0.001));
    });
  });

  for (final MapEntry(key: mode, value: scheme) in schemes.entries) {
    group('$mode scheme', () {
      for (final c in _cases) {
        test('${c.description} is at least ${c.threshold}:1', () {
          final ratio = contrastRatio(
            c.foreground(scheme),
            c.background(scheme),
          );
          expect(
            ratio,
            greaterThanOrEqualTo(c.threshold),
            reason:
                '${c.description}: ${ratio.toStringAsFixed(2)}:1 is below '
                'the required ${c.threshold}:1 in the $mode scheme',
          );
        });
      }
    });
  }
}
