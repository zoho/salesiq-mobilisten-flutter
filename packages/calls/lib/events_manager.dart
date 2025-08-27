import 'dart:async';

import 'package:flutter/services.dart';
import 'package:salesiq_mobilisten_calls/salesiq_mobilisten_calls.dart';

/// Manages call events from the native platform and provides a stream of parsed call events.
///
/// This singleton class acts as a bridge between the native platform (iOS/Android)
/// and the Flutter application for handling SalesIQ call events. It receives raw
/// event data from the native side through an EventChannel and converts them into
/// strongly-typed Dart objects that extend [CallEvent].
///
/// The manager uses the singleton pattern to ensure there's only one instance
/// managing the event stream throughout the application lifecycle.
///
/// Key responsibilities:
/// - Establishes communication with the native platform via EventChannel
/// - Deserializes raw event data into typed CallEvent objects
/// - Provides a continuous stream of call events for the application to listen to
/// - Handles unknown event types gracefully
///
/// Example usage:
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

  /// Factory constructor that returns the singleton instance of [CallEventManager].
  ///
  /// This ensures that only one instance of the event manager exists throughout
  /// the application lifecycle, maintaining a consistent event stream and avoiding
  /// multiple connections to the native platform.
  ///
  /// Returns the same instance on every call, implementing the singleton pattern.
  ///
  /// Example:
  /// ```dart
  /// final manager1 = CallEventManager();
  /// final manager2 = CallEventManager();
  /// // manager1 and manager2 are the same instance
  /// assert(identical(manager1, manager2));
  /// ```
  factory CallEventManager() => _instance;

  /// The EventChannel stream that receives and processes call events from the native platform.
  ///
  /// This stream:
  /// - Connects to the "mobilistenCallEvents" channel on the native side
  /// - Receives raw event data as broadcast stream
  /// - Automatically deserializes each event using the [deserialize] method
  /// - Transforms raw Map data into strongly-typed [CallEvent] objects
  ///
  /// The stream is set up during class initialization and remains active
  /// throughout the application lifecycle.
  final eventChannel = EventChannel("mobilistenCallEvents")
      .receiveBroadcastStream()
      .map((event) => deserialize(event));

  CallEventManager._internal();

  /// Provides access to the stream of parsed call events.
  ///
  /// This getter returns a stream that emits [CallEvent] objects whenever
  /// the native platform sends call-related events. The stream includes:
  ///
  /// - [CallStateChanged]: When call status changes (connected, ended, etc.)
  /// - [QueuePositionChanged]: When position in call queue updates
  /// - [UnknownCallState]: For unrecognized or future event types
  ///
  /// The stream is a broadcast stream, meaning multiple listeners can
  /// subscribe to it simultaneously without interfering with each other.
  ///
  /// Example usage:
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
  /// Returns a [Stream<CallEvent>] that emits call events from the native platform.
  Stream<CallEvent> get events => eventChannel;

  /// Deserializes raw event data from the native platform into typed [CallEvent] objects.
  ///
  /// This static method processes raw event data received from the native platform
  /// and converts it into appropriate [CallEvent] subclass instances based on the
  /// event type specified in the data.
  ///
  /// Supported event types:
  /// - `"queuePositionChanged"`: Creates [QueuePositionChanged] with conversation ID and position
  /// - `"callStateChanged"`: Creates [CallStateChanged] with deserialized call state
  /// - Any other type: Creates [UnknownCallState] as a fallback
  ///
  /// The method expects the event data to contain an "eventName" field that
  /// identifies the type of event, along with event-specific data fields.
  ///
  /// Parameters:
  /// - [event]: Raw event data from the native platform as a Map
  ///
  /// Returns a [CallEvent] object corresponding to the event type.
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
    }

    return UnknownCallState();
  }
}
