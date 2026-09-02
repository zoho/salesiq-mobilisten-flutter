import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../../theme/tokens.dart';

/// Text tone → resolved color.
enum TextTone { primary, secondary, tertiary, brand, success, danger, accent }

/// Token-driven text — the only way type styles are applied in the app.
/// Mirrors the RN `AppText`.
class AppText extends StatelessWidget {
  final String data;
  final TypeStyle variant;
  final TextTone tone;

  /// Overrides the variant's default weight (400 or 600 only).
  final FontWeight? weight;
  final int? maxLines;
  final TextOverflow? overflow;
  final double? fontSizeOverride;
  final double? letterSpacingOverride;
  final double? heightOverride;
  final Color? colorOverride;
  final bool selectable;

  const AppText(
    this.data, {
    super.key,
    this.variant = AppType.body,
    this.tone = TextTone.primary,
    this.weight,
    this.maxLines,
    this.overflow,
    this.fontSizeOverride,
    this.letterSpacingOverride,
    this.heightOverride,
    this.colorOverride,
    this.selectable = false,
  });

  Color _color(AppColors c) {
    if (colorOverride != null) return colorOverride!;
    switch (tone) {
      case TextTone.primary:
        return c.textPrimary;
      case TextTone.secondary:
        return c.textSecondary;
      case TextTone.tertiary:
        return c.textTertiary;
      case TextTone.brand:
        return c.primary;
      case TextTone.success:
        return c.secondary;
      case TextTone.danger:
        return c.danger;
      case TextTone.accent:
        return c.accent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isMono = identical(variant, AppType.mono);
    final style = variant.style(color: _color(c), weight: weight).copyWith(
          fontSize: fontSizeOverride ?? variant.size,
          letterSpacing: letterSpacingOverride ?? variant.letterSpacing,
          height: heightOverride,
          fontFamily: isMono ? kMonoFont : null,
          fontFeatures: isMono ? const [FontFeature.tabularFigures()] : null,
        );
    final text = variant.uppercase ? data.toUpperCase() : data;

    if (selectable) {
      return SelectableText(text, style: style, maxLines: maxLines);
    }
    return Text(
      text,
      style: style,
      maxLines: maxLines,
      overflow: overflow ?? (maxLines != null ? TextOverflow.ellipsis : null),
    );
  }
}
