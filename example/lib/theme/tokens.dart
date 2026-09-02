/// GENERATED from design/design-tokens.json (v1.0.0) — do not edit by hand.
///
/// Every color/size/type value in the app must come from this file. It is the
/// Flutter counterpart to the React Native `theme/tokens.ts`, generated from the
/// same canonical `design-tokens.json`.
library;

import 'package:flutter/material.dart';

/// The full set of semantic colors, resolved for one appearance (light/dark).
@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color primary;
  final Color onPrimary;
  final Color secondary;
  final Color accent;
  final Color danger;
  final Color success;
  final Color warning;
  final Color page;
  final Color card;
  final Color cardAlt;
  final Color border;
  final Color borderSubtle;
  final Color hairline;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color tintPrimary;
  final Color tintSecondary;
  final Color tintAccent;
  final Color tintDanger;
  final Color segmentTrack;
  final Color segmentThumb;
  final Color switchOn;
  final Color switchOff;
  final Color resultBlockBg;
  final Brightness statusBarBrightness;

  const AppColors({
    required this.primary,
    required this.onPrimary,
    required this.secondary,
    required this.accent,
    required this.danger,
    required this.success,
    required this.warning,
    required this.page,
    required this.card,
    required this.cardAlt,
    required this.border,
    required this.borderSubtle,
    required this.hairline,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.tintPrimary,
    required this.tintSecondary,
    required this.tintAccent,
    required this.tintDanger,
    required this.segmentTrack,
    required this.segmentThumb,
    required this.switchOn,
    required this.switchOff,
    required this.resultBlockBg,
    required this.statusBarBrightness,
  });

  static const AppColors light = AppColors(
    primary: Color(0xFF2E63F6),
    onPrimary: Color(0xFFFFFFFF),
    secondary: Color(0xFF12A06E),
    accent: Color(0xFFD8722F),
    danger: Color(0xFFE24B4A),
    success: Color(0xFF12A06E),
    warning: Color(0xFFD8722F),
    page: Color(0xFFFBFBFD),
    card: Color(0xFFFFFFFF),
    cardAlt: Color(0xFFF6F7F9),
    border: Color(0xFFECEEF2),
    borderSubtle: Color(0xFFF1F2F5),
    hairline: Color(0xFFEFF1F5),
    textPrimary: Color(0xFF0B1220),
    textSecondary: Color(0xFF6E7683),
    textTertiary: Color(0xFF9098A3),
    tintPrimary: Color(0xFFEAF0FF),
    tintSecondary: Color(0xFFE7F7F0),
    tintAccent: Color(0xFFFBEFE6),
    tintDanger: Color(0xFFFCEBEB),
    segmentTrack: Color(0xFFEFF1F5),
    segmentThumb: Color(0xFFFFFFFF),
    switchOn: Color(0xFF12A06E),
    switchOff: Color(0xFFECEEF2),
    resultBlockBg: Color(0xFFF6F7F9),
    statusBarBrightness: Brightness.dark,
  );

  static const AppColors dark = AppColors(
    primary: Color(0xFF5A86FF),
    onPrimary: Color(0xFFFFFFFF),
    secondary: Color(0xFF35C79A),
    accent: Color(0xFFF0955A),
    danger: Color(0xFFF0706F),
    success: Color(0xFF35C79A),
    warning: Color(0xFFF0955A),
    page: Color(0xFF0B1220),
    card: Color(0xFF151B2B),
    cardAlt: Color(0xFF1B2233),
    border: Color(0xFF232B3E),
    borderSubtle: Color(0xFF1E2536),
    hairline: Color(0xFF1E2537),
    textPrimary: Color(0xFFF4F6FA),
    textSecondary: Color(0xFFA0A8B8),
    textTertiary: Color(0xFF6E7788),
    tintPrimary: Color(0xFF17233F),
    tintSecondary: Color(0xFF123027),
    tintAccent: Color(0xFF33251A),
    tintDanger: Color(0xFF3A1D1D),
    segmentTrack: Color(0xFF1B2233),
    segmentThumb: Color(0xFF2B344B),
    switchOn: Color(0xFF35C79A),
    switchOff: Color(0xFF232B3E),
    resultBlockBg: Color(0xFF1B2233),
    statusBarBrightness: Brightness.light,
  );

  @override
  AppColors copyWith() => this;

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return t < 0.5 ? this : other;
  }
}

/// A single type style (size / weight / letter-spacing).
@immutable
class TypeStyle {
  final double size;
  final FontWeight weight;
  final double letterSpacing;
  final bool uppercase;

  const TypeStyle({
    required this.size,
    required this.weight,
    required this.letterSpacing,
    this.uppercase = false,
  });

  /// Builds a [TextStyle] applying the token metrics, overriding [color] and
  /// optionally the [weight].
  TextStyle style({required Color color, FontWeight? weight}) => TextStyle(
        fontSize: size,
        fontWeight: weight ?? this.weight,
        letterSpacing: letterSpacing,
        color: color,
        height: 1.25,
      );
}

/// family: "system" · two weights only — regular 400 / medium 600.
class AppType {
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w600;

  static const TypeStyle largeTitle =
      TypeStyle(size: 28, weight: medium, letterSpacing: -0.6);
  static const TypeStyle title =
      TypeStyle(size: 20, weight: medium, letterSpacing: -0.3);
  static const TypeStyle headline =
      TypeStyle(size: 16, weight: medium, letterSpacing: 0);
  static const TypeStyle body =
      TypeStyle(size: 15, weight: regular, letterSpacing: 0);
  static const TypeStyle subhead =
      TypeStyle(size: 13, weight: regular, letterSpacing: 0);
  static const TypeStyle caption =
      TypeStyle(size: 12, weight: regular, letterSpacing: 0);
  static const TypeStyle sectionLabel =
      TypeStyle(size: 11, weight: medium, letterSpacing: 1.0, uppercase: true);
  static const TypeStyle mono =
      TypeStyle(size: 12, weight: regular, letterSpacing: 0);
}

/// Spacing scale (dp).
class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
}

/// Corner radii.
class AppRadius {
  static const double control = 13;
  static const double card = 16;
  static const double icon = 10;
  static const double input = 12;
  static const double pill = 100;
}

/// Fixed sizing tokens.
class AppSizing {
  static const double minTouchTarget = 44;
  static const double listRowIconBox = 34;
  static const double listRowIconGlyph = 19;
  static const double listRowMinHeight = 52;
  static const double buttonHeight = 48;
  static const double switchWidth = 44;
  static const double switchHeight = 27;
}

/// The monospace font stack for [ResultBlock] / event payloads.
const String kMonoFont = 'monospace';
