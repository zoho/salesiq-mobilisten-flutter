import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../../theme/tokens.dart';
import 'app_text.dart';
import 'icons.dart';

/// Badge tone.
enum BadgeTone { primary, success, warning, danger }

/// Pill badge: radius 100, 6/11 padding, 12/500, tint bg + matching
/// strong-color text. Mirrors the RN `Badge`.
class AppBadge extends StatelessWidget {
  final String label;
  final BadgeTone tone;
  final AppIcon? icon;

  const AppBadge({
    super.key,
    required this.label,
    this.tone = BadgeTone.primary,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    Color bg;
    Color fg;
    switch (tone) {
      case BadgeTone.primary:
        bg = c.tintPrimary;
        fg = c.primary;
        break;
      case BadgeTone.success:
        bg = c.tintSecondary;
        fg = c.secondary;
        break;
      case BadgeTone.warning:
        bg = c.tintAccent;
        fg = c.accent;
        break;
      case BadgeTone.danger:
        bg = c.tintDanger;
        fg = c.danger;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(AppIcons.of(icon!), size: 13, color: fg),
            const SizedBox(width: 6),
          ],
          AppText(
            label,
            variant: AppType.caption,
            weight: AppType.medium,
            colorOverride: fg,
          ),
        ],
      ),
    );
  }
}
