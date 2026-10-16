import 'dart:async';

import 'package:flutter/services.dart';
import 'package:salesiq_mobilisten_calls/salesiq_mobilisten_calls.dart';

/// Manages the call events from the native platform, and provides a stream of
/// parsed call events.
///
/// This singleton class connects the native platform, iOS or Android, with your
/// Flutter app for SalesIQ call events. It receives raw event data from the
/// native side through an EventChannel. It then converts the data into typed
/// Dart objects that extend [CallEvent].
///
/// The manager is a singleton, so only one instance manages the event stream
/// during the whole app lifecycle.
///
/// Main tasks:
/// - Sets up the communication with the native platform through an
///   EventChannel.
/// - Converts the raw event data into typed CallEvent objects.
/// - Provides a continuous stream of call events that your app can listen to.
/// - Handles unknown event types safely.
///
/// Example:
/// ```dart
/// final eventManager = CallEventManager();
/// eventManager.events.listen((event) {
///   if (event is CallStateChanged) {
///     // Handle call state changes
///   } else if (event is QueuePositionChanged) {
///     // Handle queue position updates
///   }
/// });
/// ```
class CallEventManager {
  static final CallEventManager _instance = CallEventManager._internal();

  /// Returns the single instance of [CallEventManager].
  ///
  /// Only one event manager exists during the app lifecycle. This keeps the
  /// event stream consistent and avoids more than one connection to the native
  /// platform.
  ///
  /// Example:
  /// ```dart
  /// final manager1 = CallEventManager();
  /// final manager2 = CallEventManager();
  /// // manager1 and manager2 are the same instance
  /// assert(identical(manager1, manager2));
  /// ```
  factory CallEventManager() => _instance;

  /// The EventChannel stream that receives and processes call events from the
  /// native platform.
  ///
  /// This stream does the following:
  /// - Connects to the "mobilistenCallEvents" channel on the native side.
  /// - Receives raw event data as a broadcast stream.
  /// - Converts each event automatically with the [deserialize] method.
  /// - Turns raw Map data into typed [CallEvent] objects.
  ///
  /// The stream is set up when the class is initialized, and it stays active
  /// during the whole app lifecycle.
  final eventChannel = EventChannel("mobilistenCallEvents")
      .receiveBroadcastStream()
      .map((event) => deserialize(event));

  CallEventManager._internal();

  /// Returns the stream of parsed call events.
  ///
  /// The stream sends a [CallEvent] object each time the native platform sends
  /// a call event. The stream includes:
  ///
  /// - [CallStateChanged]: Sent when the call status changes, such as to
  ///   connected or ended.
  /// - [QueuePositionChanged]: Sent when the position in the call queue
  ///   changes.
  /// - [UnknownCallState]: Sent for event types that are not recognized, or
  ///   that a later version adds.
  ///
  /// The stream is a broadcast stream, so many listeners can subscribe to it at
  /// the same time without affecting each other.
  ///
  /// Example:
  /// ```dart
  /// CallEventManager().events.listen((event) {
  ///   switch (event.runtimeType) {
  ///     case CallStateChanged:
  ///       handleCallStateChange(event as CallStateChanged);
  ///       break;
  ///     case QueuePositionChanged:
  ///       handleQueueUpdate(event as QueuePositionChanged);
  ///       break;
  ///   }
  /// });
  /// ```
  ///
  /// Returns a [Stream<CallEvent>] that sends call events from the native
  /// platform.
  Stream<CallEvent> get events => eventChannel;

  /// Converts raw event data from the native platform into typed [CallEvent]
  /// objects.
  ///
  /// This static method reads the raw event data from the native platform. It
  /// creates the [CallEvent] subclass instance that matches the event type in
  /// the data.
  ///
  /// Supported event types:
  /// - `"queuePositionChanged"`: Creates a [QueuePositionChanged] with the
  ///   conversation ID and position.
  /// - `"callStateChanged"`: Creates a [CallStateChanged] with the parsed call
  ///   state.
  /// - Any other type: Creates an [UnknownCallState] as a fallback.
  ///
  /// The event data must contain an "eventName" field that names the event
  /// type, along with the data fields of that event.
  ///
  /// Parameters:
  /// - [event]: The raw event data from the native platform, as a Map.
  ///
  /// Returns a [CallEvent] object that matches the event type.
  ///
  /// Example input data:
  /// ```dart
  /// // Queue position change event
  /// {
  ///   "eventName": "queuePositionChanged",
  ///   "data": {
  ///     "conversationId": "conv_123",
  ///     "position": 2
  ///   }
  /// }
  ///
  /// // Call state change event
  /// {
  ///   "eventName": "callStateChanged",
  ///   "data": { /* SalesIQCallState data */ }
  /// }
  /// ```
  static CallEvent deserialize(Map<Object?, Object?> event) {
    final eventName = event["eventName"] as String?;
    final data = event["data"] as Map<dynamic, dynamic>?;

    switch (eventName) {
      case "queuePositionChanged":
        if (data != null) {
          return QueuePositionChanged(
            data["conversationId"] as String,
            data["position"] as int,
          );
        }
        break;

      case "callStateChanged":
        if (data != null) {
          return CallStateChanged(
            SalesIQCallState.fromMap(Map<dynamic, dynamic>.from(data)),
          );
        }
        break;

      case "callErrorOccurred":
        if (data == null) {
          break;
        }

        String message = data['message'] as String;
        int code = data['code'] as int;
        CallErrorInfo? info = CallErrorInfo.fromMap(data);
        return CallErrorOccurred(message, code, info);
    }

    return UnknownCallState();
  }
}
