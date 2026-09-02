import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../../theme/tokens.dart';
import 'app_text.dart';
import 'icons.dart';

/// Button visual variants.
enum ButtonVariant { primary, secondary, ghost, destructive }

/// Full-width action button: height 48, radius 13, 14.5/600 label.
/// Mirrors the RN `Button`.
class AppButton extends StatelessWidget {
  final String title;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final AppIcon? icon;
  final bool loading;

  const AppButton({
    super.key,
    required this.title,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.icon,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final bool disabled = onPressed == null || loading;

    Color bg;
    Color? border;
    Color textColor;
    bool shadow = false;
    switch (variant) {
      case ButtonVariant.primary:
        bg = c.primary;
        textColor = c.onPrimary;
        shadow = true;
        break;
      case ButtonVariant.secondary:
        bg = c.card;
        border = c.border;
        textColor = c.primary;
        break;
      case ButtonVariant.ghost:
        bg = Colors.transparent;
        textColor = c.primary;
        break;
      case ButtonVariant.destructive:
        bg = Colors.transparent;
        border = c.danger;
        textColor = c.danger;
        break;
    }

    final Widget child = loading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: textColor),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(AppIcons.of(icon!), size: 18, color: textColor),
                const SizedBox(width: 8),
              ],
              AppText(
                title,
                variant: AppType.body,
                weight: AppType.medium,
                fontSizeOverride: 14.5,
                colorOverride: textColor,
              ),
            ],
          );

    return Opacity(
      opacity: disabled ? 0.45 : 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.control),
          boxShadow: shadow
              ? [
                  BoxShadow(
                    color: c.primary.withOpacity(0.28),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadius.control),
          child: InkWell(
            onTap: disabled ? null : onPressed,
            borderRadius: BorderRadius.circular(AppRadius.control),
            child: Container(
              height: AppSizing.buttonHeight,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.control),
                border:
                    border != null ? Border.all(color: border, width: 1) : null,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
