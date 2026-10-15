import 'package:flutter/widgets.dart';

/// Elevation levels from the design system. Level 0 is border only.
abstract final class AppShadows {
  static List<BoxShadow> level1(Color shadow) => [
    BoxShadow(
      color: shadow.withValues(alpha: .05),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> level2(Color shadow) => [
    BoxShadow(
      color: shadow.withValues(alpha: .08),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  /// Sheets and dialogs, tinted with the brand color.
  static List<BoxShadow> level3(Color brand) => [
    BoxShadow(
      color: brand.withValues(alpha: .18),
      blurRadius: 40,
      offset: const Offset(0, 16),
    ),
  ];

  /// Glow under primary call-to-action surfaces.
  static List<BoxShadow> glow(Color brand, {double alpha = .25}) => [
    BoxShadow(
      color: brand.withValues(alpha: alpha),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];
}
