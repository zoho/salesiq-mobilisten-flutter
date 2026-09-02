import 'package:flutter/material.dart';

import '../../theme/tokens.dart';
import 'app_text.dart';

/// Section: uppercase header label + 9pt gap to content, 6pt horizontal label
/// inset, with an optional footer caption. Mirrors the RN `Section`.
class Section extends StatelessWidget {
  final String? title;
  final String? footer;
  final Widget child;

  const Section({super.key, this.title, this.footer, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: AppText(
              title!,
              variant: AppType.sectionLabel,
              tone: TextTone.tertiary,
            ),
          ),
        if (title != null) const SizedBox(height: 9),
        child,
        if (footer != null) ...[
          const SizedBox(height: 9),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: AppText(
              footer!,
              variant: AppType.caption,
              tone: TextTone.secondary,
            ),
          ),
        ],
      ],
    );
  }
}

/// 1pt hairline separator between free-standing blocks (cards separate their own
/// children). Mirrors the RN `Divider`.
class AppDivider extends StatelessWidget {
  const AppDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).extension<AppColors>()!.hairline;
    return Container(height: 1, color: color);
  }
}
