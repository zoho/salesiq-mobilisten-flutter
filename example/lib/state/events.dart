import 'dart:async';

import 'package:flutter/foundation.dart';

/// The logical source of an SDK event, used to color its [EventRow] stripe and
/// to filter payloads (e.g. the Notifications screen reads the latest
/// notification event).
enum EventSource { chat, calls, launcher, knowledgeBase, notification, system }

/// A single captured SDK event.
class SdkEvent {
  final String name;
  final EventSource source;
  final Object? payload;
  final DateTime time;

  SdkEvent({
    required this.name,
    required this.source,
    this.payload,
    DateTime? time,
  }) : time = time ?? DateTime.now();
}

/// A tiny in-memory event store wired from the four Mobilisten event channels
/// plus the calls event stream. Holds the newest events first and tracks an
/// "unseen" count for the Home / Events console badge.
///
/// A single instance lives at the app root; screens listen to it via
/// [AnimatedBuilder]/[ListenableBuilder]. Mirrors the RN `state/events.ts`.
class EventStore extends ChangeNotifier {
  static const int _maxEvents = 200;
  final List<SdkEvent> _events = <SdkEvent>[];
  int _unseen = 0;

  List<SdkEvent> get events => List.unmodifiable(_events);
  int get unseen => _unseen;

  /// The most recent event whose [SdkEvent.source] matches [source].
  SdkEvent? latestOf(EventSource source) {
    for (final e in _events) {
      if (e.source == source) return e;
    }
    return null;
  }

  void add(String name, EventSource source, [Object? payload]) {
    _events.insert(0, SdkEvent(name: name, source: source, payload: payload));
    if (_events.length > _maxEvents) {
      _events.removeRange(_maxEvents, _events.length);
    }
    _unseen++;
    notifyListeners();
  }

  void markSeen() {
    if (_unseen == 0) return;
    _unseen = 0;
    notifyListeners();
  }

  void clear() {
    if (_events.isEmpty && _unseen == 0) return;
    _events.clear();
    _unseen = 0;
    notifyListeners();
  }
}
