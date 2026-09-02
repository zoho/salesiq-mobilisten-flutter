import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../../theme/tokens.dart';
import 'app_text.dart';
import 'icons.dart';

/// Banner variant.
enum BannerVariant { info, ok, warning, danger }

/// Tinted banner: icon box + title 13.5/600 (strong color) + body 12 secondary.
/// Mirrors the RN `StatusBanner`.
class StatusBanner extends StatelessWidget {
  final String title;
  final String? body;
  final BannerVariant variant;
  final AppIcon? icon;

  const StatusBanner({
    super.key,
    required this.title,
    this.body,
    this.variant = BannerVariant.info,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    Color bg;
    Color fg;
    AppIcon glyph;
    switch (variant) {
      case BannerVariant.info:
        bg = c.tintPrimary;
        fg = c.primary;
        glyph = icon ?? AppIcon.info;
        break;
      case BannerVariant.ok:
        bg = c.tintSecondary;
        fg = c.secondary;
        glyph = icon ?? AppIcon.check;
        break;
      case BannerVariant.warning:
        bg = c.tintAccent;
        fg = c.accent;
        glyph = icon ?? AppIcon.alert;
        break;
      case BannerVariant.danger:
        bg = c.tintDanger;
        fg = c.danger;
        glyph = icon ?? AppIcon.alert;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: fg.withOpacity(0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(AppIcons.of(glyph), size: 18, color: fg),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  title,
                  variant: AppType.subhead,
                  weight: AppType.medium,
                  fontSizeOverride: 13.5,
                  colorOverride: fg,
                ),
                if (body != null) ...[
                  const SizedBox(height: 2),
                  AppText(
                    body!,
                    variant: AppType.caption,
                    tone: TextTone.secondary,
                    heightOverride: 1.4,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
