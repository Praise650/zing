import 'package:flutter/material.dart';

/// Brand and semantic color tokens. Access through `context.colors`.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.primary,
    required this.primaryDark,
    required this.primarySurface,
    required this.secondary,
    required this.onPrimary,
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDisabled,
    required this.border,
    required this.success,
    required this.successSurface,
    required this.successText,
    required this.warning,
    required this.warningSurface,
    required this.warningText,
    required this.error,
    required this.errorSurface,
    required this.errorText,
    required this.info,
    required this.infoSurface,
    required this.infoText,
    required this.shadow,
  });

  final Color primary;
  final Color primaryDark;
  final Color primarySurface;
  final Color secondary;
  final Color onPrimary;
  final Color background;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color textDisabled;
  final Color border;
  final Color success;
  final Color successSurface;
  final Color successText;
  final Color warning;
  final Color warningSurface;
  final Color warningText;
  final Color error;
  final Color errorSurface;
  final Color errorText;
  final Color info;
  final Color infoSurface;
  final Color infoText;
  final Color shadow;

  static const light = AppColors(
    primary: Color(0xFF6257E8),
    primaryDark: Color(0xFF4539B5),
    primarySurface: Color(0xFFF0EEFF),
    secondary: Color(0xFF8B7CF6),
    onPrimary: Color(0xFFFFFFFF),
    background: Color(0xFFF8F9FC),
    surface: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF191B2A),
    textSecondary: Color(0xFF6D7285),
    textDisabled: Color(0xFF9A9FB0),
    border: Color(0xFFE6E8F0),
    success: Color(0xFF159A72),
    successSurface: Color(0xFFE8F8F1),
    successText: Color(0xFF0F6B50),
    warning: Color(0xFFE9A23B),
    warningSurface: Color(0xFFFFF5E5),
    warningText: Color(0xFF8A5A0C),
    error: Color(0xFFD94A55),
    errorSurface: Color(0xFFFFF0F1),
    errorText: Color(0xFFA82D38),
    info: Color(0xFF3978D4),
    infoSurface: Color(0xFFEAF1FC),
    infoText: Color(0xFF2A5FAE),
    shadow: Color(0xFF191B2A),
  );

  static const dark = AppColors(
    primary: Color(0xFF8B7CF6),
    primaryDark: Color(0xFFC9C3FA),
    primarySurface: Color(0xFF2A2650),
    secondary: Color(0xFF6257E8),
    onPrimary: Color(0xFF12131F),
    background: Color(0xFF12131F),
    surface: Color(0xFF1C1E30),
    textPrimary: Color(0xFFF1F2F8),
    textSecondary: Color(0xFF9EA3B8),
    textDisabled: Color(0xFF5E6379),
    border: Color(0xFF2E3148),
    success: Color(0xFF34C79A),
    successSurface: Color(0xFF12332B),
    successText: Color(0xFF7BE0BE),
    warning: Color(0xFFF0B45A),
    warningSurface: Color(0xFF3A2D14),
    warningText: Color(0xFFF5CB88),
    error: Color(0xFFEF6B75),
    errorSurface: Color(0xFF3A1D22),
    errorText: Color(0xFFF59AA1),
    info: Color(0xFF6B9DEB),
    infoSurface: Color(0xFF172A47),
    infoText: Color(0xFF9DBFF3),
    shadow: Color(0xFF000000),
  );

  @override
  AppColors copyWith({Color? primary, Color? background, Color? surface}) =>
      AppColors(
        primary: primary ?? this.primary,
        primaryDark: primaryDark,
        primarySurface: primarySurface,
        secondary: secondary,
        onPrimary: onPrimary,
        background: background ?? this.background,
        surface: surface ?? this.surface,
        textPrimary: textPrimary,
        textSecondary: textSecondary,
        textDisabled: textDisabled,
        border: border,
        success: success,
        successSurface: successSurface,
        successText: successText,
        warning: warning,
        warningSurface: warningSurface,
        warningText: warningText,
        error: error,
        errorSurface: errorSurface,
        errorText: errorText,
        info: info,
        infoSurface: infoSurface,
        infoText: infoText,
        shadow: shadow,
      );

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      primary: l(primary, other.primary),
      primaryDark: l(primaryDark, other.primaryDark),
      primarySurface: l(primarySurface, other.primarySurface),
      secondary: l(secondary, other.secondary),
      onPrimary: l(onPrimary, other.onPrimary),
      background: l(background, other.background),
      surface: l(surface, other.surface),
      textPrimary: l(textPrimary, other.textPrimary),
      textSecondary: l(textSecondary, other.textSecondary),
      textDisabled: l(textDisabled, other.textDisabled),
      border: l(border, other.border),
      success: l(success, other.success),
      successSurface: l(successSurface, other.successSurface),
      successText: l(successText, other.successText),
      warning: l(warning, other.warning),
      warningSurface: l(warningSurface, other.warningSurface),
      warningText: l(warningText, other.warningText),
      error: l(error, other.error),
      errorSurface: l(errorSurface, other.errorSurface),
      errorText: l(errorText, other.errorText),
      info: l(info, other.info),
      infoSurface: l(infoSurface, other.infoSurface),
      infoText: l(infoText, other.infoText),
      shadow: l(shadow, other.shadow),
    );
  }
}
