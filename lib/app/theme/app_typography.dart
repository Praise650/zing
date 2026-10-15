import 'package:flutter/material.dart';

/// Inter type scale. Colors are applied by the theme, not here.
abstract final class AppTypography {
  static const String fontFamily = 'Inter';

  static TextStyle _s(
    double size,
    FontWeight w, {
    double? height,
    double? ls,
  }) => TextStyle(
    fontFamily: fontFamily,
    fontSize: size,
    fontWeight: w,
    height: height,
    letterSpacing: ls,
  );

  static TextTheme textTheme(Color primary, Color secondary) => TextTheme(
    displayLarge: _s(34, FontWeight.w800, height: 1.1, ls: -1),
    displayMedium: _s(28, FontWeight.w800, height: 1.2, ls: -.6),
    displaySmall: _s(21, FontWeight.w700, height: 1.35, ls: -.3),
    headlineLarge: _s(26, FontWeight.w800, height: 1.2, ls: -.5),
    headlineMedium: _s(24, FontWeight.w700, height: 1.25, ls: -.4),
    titleLarge: _s(22, FontWeight.w700, height: 1.25),
    titleMedium: _s(18, FontWeight.w600, height: 1.3),
    titleSmall: _s(16, FontWeight.w600, height: 1.35),
    bodyLarge: _s(15, FontWeight.w400, height: 1.55),
    bodyMedium: _s(14, FontWeight.w400, height: 1.5),
    bodySmall: _s(13, FontWeight.w400, height: 1.4),
    labelLarge: _s(14, FontWeight.w600, ls: .14),
    labelMedium: _s(13, FontWeight.w600),
    labelSmall: _s(12, FontWeight.w600, height: 1.4),
  ).apply(bodyColor: primary, displayColor: primary);
}
