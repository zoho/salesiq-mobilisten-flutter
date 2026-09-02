import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:salesiq_mobilisten/salesiq_mobilisten.dart';
import 'package:salesiq_mobilisten_calls/salesiq_mobilisten_calls.dart';

import 'events.dart';

/// Subscribes to every Mobilisten event source once, centrally, and funnels
/// each event into the [EventStore]. Mirrors the RN `scripts/listeners.ts`.
///
/// Sources:
///  - `ZohoSalesIQ.eventChannel`      → general SDK events (system)
///  - `ZohoSalesIQ.chatEventChannel`  → chat lifecycle events
///  - `ZohoSalesIQ.knowledgeBase.eventChannel` → KB resource events
///  - `ZohoSalesIQ.notification.eventChannel`  → push notification taps
///  - `ZohoSalesIQCalls.events`       → call state / queue / error events
class EventListeners {
  final EventStore store;
  final List<StreamSubscription<dynamic>> _subs = [];

  EventListeners(this.store);

  void start() {
    // Stream of general SDK events (init, operator status, etc.).
    _listen(ZohoSalesIQ.eventChannel, EventSource.system, _generalName);
    // Stream of chat lifecycle events (opened, missed, closed, feedback...).
    _listen(ZohoSalesIQ.chatEventChannel, EventSource.chat, _chatName);

    // Stream of Knowledge Base events (article opened, liked, disliked...).
    _subs.add(ZohoSalesIQ.knowledgeBase.eventChannel.listen((event) {
      store.add(
        event.action?.value ?? 'knowledgeBaseEvent',
        EventSource.knowledgeBase,
        {
          'type': event.type?.name,
          'resourceId': event.resource?.id,
          'title': event.resource?.title,
          if (event.errorInfo != null && event.errorInfo!.message.isNotEmpty)
            'error': event.errorInfo!.message,
        },
      );
    }, onError: _onError));

    // Stream of push-notification events (e.g. a chat notification tapped).
    _subs.add(ZohoSalesIQ.notification.eventChannel.listen((event) {
      store.add(
        event.action?.value ?? 'notificationEvent',
        EventSource.notification,
        event.payload?.toMap(),
      );
    }, onError: _onError));

    // Stream of audio/video call events (state, queue position, errors).
    _subs.add(ZohoSalesIQCalls.events.listen((event) {
      final (name, payload) = _callEvent(event);
      store.add(name, EventSource.calls, payload);
    }, onError: _onError));
  }

  void _listen(
    Stream<dynamic> stream,
    EventSource source,
    String Function(dynamic) nameOf,
  ) {
    _subs.add(stream.listen((raw) {
      store.add(nameOf(raw), source, _payloadOf(raw));
    }, onError: _onError));
  }

  String _generalName(dynamic raw) => _readName(raw) ?? 'sdkEvent';
  String _chatName(dynamic raw) => _readName(raw) ?? 'chatEvent';

  String? _readName(dynamic raw) {
    if (raw is Map) {
      return (raw['eventName'] ?? raw['name'] ?? raw['type'])?.toString();
    }
    if (raw is String) return raw;
    return null;
  }

  Object? _payloadOf(dynamic raw) {
    if (raw is Map) {
      return raw.map((k, v) => MapEntry(k.toString(), v));
    }
    return raw;
  }

  (String, Object?) _callEvent(CallEvent event) {
    if (event is CallStateChanged) {
      return (
        'callStateChanged',
        {
          'status': event.state.status.name,
          'isIncoming': event.state.isIncomingCall,
        }
      );
    }
    if (event is QueuePositionChanged) {
      return (
        'queuePositionChanged',
        {'conversationId': event.conversationId, 'position': event.position}
      );
    }
    if (event is CallErrorOccurred) {
      return (
        'callError',
        {'code': event.errorCode, 'message': event.errorMessage}
      );
    }
    return ('unknownCallState', null);
  }

  void _onError(Object error) {
    debugPrint('Mobilisten event stream error: $error');
  }

  void dispose() {
    for (final sub in _subs) {
      sub.cancel();
    }
    _subs.clear();
  }
}
