import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../routes.dart';
import '../../state/push_status.dart';
import '../../theme/theme.dart';
import '../../theme/tokens.dart';
import 'app_text.dart';
import 'icons.dart';

/// Safe-area page → back affordance → large title 28/600 → subtitle →
/// scrollable content (16 h-padding, 16 gap between sections).
/// Mirrors the RN `ScreenScaffold`.
class ScreenScaffold extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> children;

  /// Show the back affordance. Defaults to true for any screen but Home.
  final bool showBack;

  /// Trailing header accessory (e.g. a settings icon button on Home).
  final Widget? headerRight;

  const ScreenScaffold({
    super.key,
    required this.title,
    this.subtitle,
    required this.children,
    this.showBack = true,
    this.headerRight,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final insets = MediaQuery.of(context).padding;
    final spaced = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) spaced.add(const SizedBox(height: 16));
      spaced.add(children[i]);
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: c.statusBarBrightness,
        statusBarBrightness: c.statusBarBrightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: c.page,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: insets.top + 6,
                left: 20,
                right: 20,
                bottom: 12,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showBack) const _BackAffordance(),
                        if (showBack) const SizedBox(height: 10),
                        AppText(
                          title,
                          variant: AppType.largeTitle,
                          fontSizeOverride: 27,
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 3),
                          AppText(
                            subtitle!,
                            variant: AppType.subhead,
                            tone: TextTone.secondary,
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Global push-health indicator: when notifications are off, a
                  // warning bell on every screen's header jumps to Notifications.
                  const _PushWarningBell(),
                  if (headerRight != null) headerRight!,
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: insets.bottom + 28,
                ),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                children: spaced,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A slashed "notifications-off" bell in a danger tint, shown on every screen's
/// header while notifications are not granted. Reads as "notifications are off /
/// needs attention" (not an unread count) and taps through to the Notifications
/// screen. Mirrors the RN `ScreenScaffold` global push-health indicator.
class _PushWarningBell extends StatelessWidget {
  const _PushWarningBell();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AnimatedBuilder(
      animation: pushStatus,
      builder: (context, _) {
        if (!pushStatus.hasIssue) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Semantics(
            button: true,
            label:
                'Notifications are turned off. Open the Notifications screen.',
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                // Avoid stacking a duplicate when already on Notifications.
                if (ModalRoute.of(context)?.settings.name !=
                    Routes.notifications) {
                  Navigator.of(context).pushNamed(Routes.notifications);
                }
              },
              child: Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: c.tintDanger,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.notifications_off_outlined,
                  size: 20,
                  color: c.danger,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BackAffordance extends StatelessWidget {
  const _BackAffordance();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).maybePop(),
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: c.tintPrimary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(AppIcons.of(AppIcon.back), size: 20, color: c.primary),
      ),
    );
  }
}
