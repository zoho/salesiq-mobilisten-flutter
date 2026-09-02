import 'package:flutter/material.dart';

import '../state/events.dart';
import '../widgets/ui/ui.dart';

/// Detail — full payload for a single SDK event, reached by tapping a row in
/// the Events console. Mirrors the v3 mockup.
class EventDetailScreen extends StatelessWidget {
  final SdkEvent event;

  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: 'Event',
      subtitle: event.name,
      children: [
        Section(
          title: 'Summary',
          child: AppCard(
            children: [
              ListRow(title: 'Name', value: event.name),
              ListRow(title: 'Source', value: event.source.name),
              ListRow(
                title: 'Time',
                value: event.time.toIso8601String(),
              ),
            ],
          ),
        ),
        Section(
          title: 'Payload',
          child: ResultBlock(
            label: 'Raw payload',
            data: event.payload ?? {'payload': 'none'},
          ),
        ),
      ],
    );
  }
}
