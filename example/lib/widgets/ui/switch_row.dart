import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../../theme/tokens.dart';
import 'app_text.dart';
import 'icon_box.dart';
import 'icons.dart';

/// List row with a trailing 44×27 switch — same composition/metrics as
/// [ListRow]. Mirrors the RN `SwitchRow`.
class SwitchRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final AppIcon? icon;
  final IconTint tint;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool disabled;

  const SwitchRow({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.tint = IconTint.primary,
    required this.value,
    required this.onChanged,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Opacity(
      opacity: disabled ? 0.45 : 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(minHeight: AppSizing.listRowMinHeight - 18),
          child: Row(
            children: [
              if (icon != null) ...[
                IconBox(icon: icon!, tint: tint),
                const SizedBox(width: 13),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppText(
                      title,
                      variant: AppType.body,
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
              const SizedBox(width: 10),
              Switch(
                value: value,
                onChanged: disabled ? null : onChanged,
                activeColor: Colors.white,
                activeTrackColor: c.switchOn,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: c.switchOff,
                trackOutlineColor:
                    MaterialStateProperty.all(Colors.transparent),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
