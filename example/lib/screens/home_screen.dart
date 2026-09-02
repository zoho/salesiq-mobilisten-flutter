import 'package:flutter/material.dart';

import '../routes.dart';
import '../state/app_scope.dart';
import '../state/app_state.dart';
import '../theme/theme.dart';
import '../theme/tokens.dart';
import '../widgets/ui/ui.dart';

/// Screen 01 — dashboard for every module; the hero reflects automatic SDK init
/// and the events row carries an unseen badge. Mirrors the RN `HomeScreen`.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final c = context.colors;

    return ValueListenableBuilder<InitStatus>(
      valueListenable: app.initStatus,
      builder: (context, status, _) {
        final (heroTitle, heroBody) = switch (status) {
          InitStatus.initialized => (
              'SDK initialized at launch',
              'Brand online · chat & calls available'
            ),
          InitStatus.keysRequired => (
              'Keys required',
              'Add your app key and access key in Settings to initialize'
            ),
          InitStatus.failed => (
              'Initialization failed',
              'Check Settings for details and retry'
            ),
          InitStatus.initializing => (
              'Initializing…',
              'The SDK starts automatically at launch'
            ),
        };
        final dotColor = switch (status) {
          InitStatus.initialized => c.secondary,
          InitStatus.failed => c.danger,
          _ => c.accent,
        };

        return ScreenScaffold(
          title: 'Mobilisten',
          subtitle: 'SalesIQ SDK showcase',
          showBack: false,
          headerRight: _SettingsButton(color: c.primary, bg: c.tintPrimary),
          children: [
            AppCard(
              separated: false,
              children: [
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: dotColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: AppText(
                              heroTitle,
                              variant: AppType.subhead,
                              weight: AppType.medium,
                              fontSizeOverride: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      AppText(
                        heroBody,
                        variant: AppType.caption,
                        tone: TextTone.secondary,
                        heightOverride: 1.4,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Section(
              title: 'Demo app',
              child: AppCard(
                children: [
                  ListRow(
                    title: 'Zylker store',
                    subtitle: 'A shopping app with SalesIQ built in',
                    icon: AppIcon.homepage,
                    tint: IconTint.primary,
                    chevron: true,
                    onTap: () => Navigator.pushNamed(context, Routes.store),
                  ),
                ],
              ),
            ),
            Section(
              title: 'Engage',
              child: AppCard(
                children: [
                  ListRow(
                    title: 'Chat',
                    subtitle: 'Start & manage conversations',
                    icon: AppIcon.chat,
                    tint: IconTint.primary,
                    chevron: true,
                    onTap: () => Navigator.pushNamed(context, Routes.chat),
                  ),
                  ListRow(
                    title: 'Calls',
                    subtitle: 'Voice calls & history',
                    icon: AppIcon.calls,
                    tint: IconTint.secondary,
                    chevron: true,
                    onTap: () => Navigator.pushNamed(context, Routes.calls),
                  ),
                  ListRow(
                    title: 'Launcher',
                    subtitle: 'Visibility & position',
                    icon: AppIcon.launcher,
                    tint: IconTint.accent,
                    chevron: true,
                    onTap: () => Navigator.pushNamed(context, Routes.launcher),
                  ),
                ],
              ),
            ),
            Section(
              title: 'Audience & content',
              child: AppCard(
                children: [
                  ListRow(
                    title: 'Visitor',
                    icon: AppIcon.visitor,
                    tint: IconTint.secondary,
                    chevron: true,
                    onTap: () => Navigator.pushNamed(context, Routes.visitor),
                  ),
                  ListRow(
                    title: 'Knowledge base',
                    icon: AppIcon.knowledgeBase,
                    tint: IconTint.accent,
                    chevron: true,
                    onTap: () =>
                        Navigator.pushNamed(context, Routes.knowledgeBase),
                  ),
                  ListRow(
                    title: 'Homepage & help center',
                    icon: AppIcon.homepage,
                    tint: IconTint.primary,
                    chevron: true,
                    onTap: () =>
                        Navigator.pushNamed(context, Routes.homepageHelpCenter),
                  ),
                ],
              ),
            ),
            Section(
              title: 'System',
              child: AppCard(
                children: [
                  ListRow(
                    title: 'Core & configuration',
                    icon: AppIcon.core,
                    tint: IconTint.primary,
                    chevron: true,
                    onTap: () => Navigator.pushNamed(context, Routes.core),
                  ),
                  ListRow(
                    title: 'Refresh data',
                    subtitle: 'refreshData(type, conversationId)',
                    icon: AppIcon.refresh,
                    tint: IconTint.secondary,
                    chevron: true,
                    onTap: () =>
                        Navigator.pushNamed(context, Routes.refreshData),
                  ),
                  ListRow(
                    title: 'Notifications',
                    icon: AppIcon.notifications,
                    tint: IconTint.accent,
                    chevron: true,
                    onTap: () =>
                        Navigator.pushNamed(context, Routes.notifications),
                  ),
                  ListenableBuilder(
                    listenable: app.events,
                    builder: (context, _) {
                      final unseen = app.events.unseen;
                      return ListRow(
                        title: 'Events console',
                        icon: AppIcon.events,
                        tint: IconTint.secondary,
                        chevron: true,
                        trailing: unseen > 0
                            ? AppBadge(
                                label: '$unseen new',
                                tone: BadgeTone.success,
                              )
                            : null,
                        onTap: () =>
                            Navigator.pushNamed(context, Routes.events),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SettingsButton extends StatelessWidget {
  final Color color;
  final Color bg;
  const _SettingsButton({required this.color, required this.bg});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.pushNamed(context, Routes.settings),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Icon(AppIcons.of(AppIcon.settings), size: 20, color: color),
      ),
    );
  }
}
