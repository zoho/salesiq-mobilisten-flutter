/// Material 3 [ThemeData] (light + dark) generated from the design tokens, plus
/// a tiny [AppTheme] controller that drives the light/dark/system override
/// exposed in Settings.
library;

import 'package:flutter/material.dart';

import 'tokens.dart';

/// Convenience accessor for the resolved [AppColors] of the current theme.
extension AppColorsContext on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}

ThemeData _buildTheme(AppColors c, Brightness brightness) {
  final base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    scaffoldBackgroundColor: c.page,
    canvasColor: c.page,
    splashFactory: InkRipple.splashFactory,
    colorScheme: ColorScheme(
      brightness: brightness,
      primary: c.primary,
      onPrimary: c.onPrimary,
      secondary: c.secondary,
      onSecondary: c.onPrimary,
      error: c.danger,
      onError: c.onPrimary,
      surface: c.card,
      onSurface: c.textPrimary,
    ),
    extensions: <ThemeExtension<dynamic>>[c],
  );

  return base.copyWith(
    textTheme: base.textTheme.apply(
      bodyColor: c.textPrimary,
      displayColor: c.textPrimary,
    ),
  );
}

/// The generated light theme.
final ThemeData appLightTheme = _buildTheme(AppColors.light, Brightness.light);

/// The generated dark theme.
final ThemeData appDarkTheme = _buildTheme(AppColors.dark, Brightness.dark);

/// Holds the user's appearance override (light / dark / system) and notifies
/// listeners on change. Mirrors the RN `ThemeProvider`.
class AppTheme extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.system;

  ThemeMode get mode => _mode;

  void setMode(ThemeMode mode) {
    if (mode == _mode) return;
    _mode = mode;
    notifyListeners();
  }
}
