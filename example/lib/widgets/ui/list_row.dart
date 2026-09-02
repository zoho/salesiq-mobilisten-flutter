import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../../theme/tokens.dart';
import 'app_text.dart';
import 'icon_box.dart';
import 'icons.dart';

/// Tone for the row title — `brand` renders the row as an inline action.
enum RowTitleTone { primary, brand, danger }

/// List row: [icon box] + title/subtitle + trailing value/chevron/control.
/// Mirrors the RN `ListRow`.
class ListRow extends StatelessWidget {
  final String title;

  /// 12pt secondary line — API names live here, never in the title.
  final String? subtitle;
  final AppIcon? icon;
  final IconTint tint;

  /// Trailing 13/500 secondary value (e.g. current selection).
  final String? value;
  final bool chevron;

  /// Custom trailing element (switch, badge, spinner…).
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool disabled;
  final RowTitleTone titleTone;

  const ListRow({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.tint = IconTint.primary,
    this.value,
    this.chevron = false,
    this.trailing,
    this.onTap,
    this.disabled = false,
    this.titleTone = RowTitleTone.primary,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final TextTone titleTextTone;
    switch (titleTone) {
      case RowTitleTone.primary:
        titleTextTone = TextTone.primary;
        break;
      case RowTitleTone.brand:
        titleTextTone = TextTone.brand;
        break;
      case RowTitleTone.danger:
        titleTextTone = TextTone.danger;
        break;
    }

    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: ConstrainedBox(
        constraints:
            const BoxConstraints(minHeight: AppSizing.listRowMinHeight - 26),
        child: Row(
          children: [
            if (icon != null) ...[
              IconBox(icon: icon!, tint: tint),
              const SizedBox(width: 13),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppText(
                    title,
                    variant: AppType.body,
                    tone: titleTextTone,
                    weight: AppType.medium,
                    fontSizeOverride: 14.5,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 1),
                    AppText(
                      subtitle!,
                      variant: AppType.caption,
                      tone: TextTone.secondary,
                    ),
                  ],
                ],
              ),
            ),
            if (value != null) ...[
              const SizedBox(width: 10),
              AppText(
                value!,
                variant: AppType.subhead,
                tone: TextTone.secondary,
                weight: AppType.medium,
              ),
            ],
            if (trailing != null) ...[const SizedBox(width: 10), trailing!],
            if (chevron) ...[
              const SizedBox(width: 4),
              Icon(AppIcons.of(AppIcon.chevronRight),
                  size: 18, color: c.textTertiary),
            ],
          ],
        ),
      ),
    );

    final opacity = disabled ? 0.45 : 1.0;
    if (onTap == null) {
      return Opacity(opacity: opacity, child: content);
    }
    return Opacity(
      opacity: opacity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: disabled ? null : onTap,
          splashColor: c.hairline,
          highlightColor: c.cardAlt,
          child: content,
        ),
      ),
    );
  }
}
