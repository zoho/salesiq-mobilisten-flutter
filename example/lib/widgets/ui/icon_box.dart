import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../../theme/tokens.dart';
import 'icons.dart';

/// 34×34 tinted icon box (radius 10) with a 19pt colored glyph.
/// Mirrors the RN `IconBox`.
class IconBox extends StatelessWidget {
  final AppIcon icon;
  final IconTint tint;
  final double size;
  final double glyphSize;

  const IconBox({
    super.key,
    required this.icon,
    this.tint = IconTint.primary,
    this.size = AppSizing.listRowIconBox,
    this.glyphSize = AppSizing.listRowIconGlyph,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final Color bg;
    final Color glyph;
    switch (tint) {
      case IconTint.primary:
        bg = c.tintPrimary;
        glyph = c.primary;
        break;
      case IconTint.secondary:
        bg = c.tintSecondary;
        glyph = c.secondary;
        break;
      case IconTint.accent:
        bg = c.tintAccent;
        glyph = c.accent;
        break;
      case IconTint.danger:
        bg = c.tintDanger;
        glyph = c.danger;
        break;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.icon),
      ),
      alignment: Alignment.center,
      child: Icon(AppIcons.of(icon), size: glyphSize, color: glyph),
    );
  }
}
