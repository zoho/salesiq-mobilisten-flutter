import 'package:flutter/material.dart';

import '../state/app_scope.dart';
import '../theme/theme.dart';
import '../theme/tokens.dart';
import '../widgets/ui/ui.dart';
import 'event_detail_screen.dart';

/// Screen 10 — live feed of every SDK event across chat, calls, launcher, KB,
/// and notifications. Mirrors the RN `EventsScreen`.
class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppScope.of(context).events.markSeen();
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final c = context.colors;

    return ListenableBuilder(
      listenable: app.events,
      builder: (context, _) {
        final events = app.events.events;
        return ScreenScaffold(
          title: 'Events',
          subtitle: 'Real-time SDK event stream',
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      AppText(
                        '${events.length}',
                        variant: AppType.subhead,
                        weight: AppType.medium,
                        tone: TextTone.secondary,
                      ),
                      const SizedBox(width: 4),
                      const AppText(
                        'events',
                        variant: AppType.subhead,
                        tone: TextTone.secondary,
                      ),
                    ],
                  ),
                  Opacity(
                    opacity: events.isEmpty ? 0.4 : 1,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: events.isEmpty ? null : app.events.clear,
                      child: Row(
                        children: [
                          Icon(AppIcons.of(AppIcon.close),
                              size: 14, color: c.danger),
                          const SizedBox(width: 5),
                          AppText(
                            'Clear',
                            variant: AppType.caption,
                            weight: AppType.medium,
                            colorOverride: c.danger,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AppCard(
              separated: true,
              children: events.isEmpty
                  ? [
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(
                          child: AppText(
                            'No events yet — interact with the SDK to see them appear here.',
                            variant: AppType.subhead,
                            tone: TextTone.secondary,
                            maxLines: 3,
                          ),
                        ),
                      ),
                    ]
                  : events
                      .map((e) => GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                settings: const RouteSettings(name: 'Event'),
                                builder: (_) => EventDetailScreen(event: e),
                              ),
                            ),
                            child: EventRow(event: e),
                          ))
                      .toList(),
            ),
          ],
        );
      },
    );
  }
}
