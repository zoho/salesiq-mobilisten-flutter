import 'dart:convert';

import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../../theme/tokens.dart';
import '../../state/events.dart';
import 'app_text.dart';

/// EventRow: 3px colored stripe + name 13/600 + payload mono 11.5 + time 11
/// tabular. Stripe color: chat=primary, calls/KB=secondary, launcher/
/// notification/system=accent. Mirrors the RN `EventRow`.
class EventRow extends StatelessWidget {
  final SdkEvent event;
  const EventRow({super.key, required this.event});

  Color _stripe(AppColors c) {
    switch (event.source) {
      case EventSource.chat:
        return c.primary;
      case EventSource.calls:
      case EventSource.knowledgeBase:
        return c.secondary;
      case EventSource.launcher:
      case EventSource.notification:
      case EventSource.system:
        return c.accent;
    }
  }

  String _payload() {
    final p = event.payload;
    if (p == null) return '{}';
    if (p is String) return p;
    try {
      return jsonEncode(p);
    } catch (_) {
      return p.toString();
    }
  }

  String _time() {
    final t = event.time;
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(t.hour)}:${two(t.minute)}:${two(t.second)}';
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 3,
            decoration: BoxDecoration(
              color: _stripe(c),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  event.name,
                  variant: AppType.subhead,
                  weight: AppType.medium,
                  fontSizeOverride: 13,
                ),
                const SizedBox(height: 2),
                AppText(
                  _payload(),
                  variant: AppType.mono,
                  tone: TextTone.secondary,
                  fontSizeOverride: 11.5,
                  maxLines: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          AppText(_time(), variant: AppType.caption, tone: TextTone.tertiary),
        ],
      ),
    );
  }
}
