import 'package:salesiq_mobilisten_calls/salesiq_mobilisten_calls.dart';

/// Represents a call event in the SalesIQ Mobilisten calls feature. It is the
/// base class for every call event.
///
/// Every event that can occur during the lifecycle of a SalesIQ call extends
/// this class. It gives you one type-safe way to handle the different types of
/// call events.
///
/// Each call event class extends this base class, so your app can handle all
/// events in the same way.
///
/// Example:
/// ```dart
/// void handleCallEvent(CallEvent event) {
///   if (event is CallStateChanged) {
///     // Handle call state change
///   } else if (event is QueuePositionChanged) {
///     // Handle queue position change
///   }
/// }
/// ```
abstract class CallEvent {}

/// Sent when the visitor's position in the call queue changes.
///
/// It tells you which conversation the change belongs to, and the new position
/// in the queue.
///
/// A lower number means that the visitor is closer to being connected to an
/// operator. Position 1 means that the visitor is next in line.
///
/// Example:
/// ```dart
/// void onQueuePositionChanged(QueuePositionChanged event) {
///   print('Conversation ${event.conversationId} is now at position ${event.position}');
/// }
/// ```
class QueuePositionChanged extends CallEvent {
  /// The unique ID of the conversation whose queue position changed.
  ///
  /// Use this ID to match the event with a conversation or call session in your
  /// app.
  final String conversationId;

  /// The new position in the call queue.
  ///
  /// A value of 1 means that the visitor is next in line to be connected. A
  /// higher number means that more people are ahead in the queue. This value is
  /// always greater than 0.
  final int position;

  /// Creates a new queue position changed event.
  ///
  /// Parameters:
  /// - [conversationId]: The unique ID of the conversation.
  /// - [position]: The new position in the queue. It must be greater than 0.
  QueuePositionChanged(this.conversationId, this.position);
}

/// Sent when the state of a SalesIQ call changes.
///
/// It is sent for every change in the call state, such as when a call starts,
/// connects, ends, or has an error. It gives you the new call state, which has
/// the call status and whether the call is incoming.
///
/// Use this event to follow the call lifecycle and to update the parts of your
/// UI that depend on the call status.
///
/// Example:
/// ```dart
/// void onCallStateChanged(CallStateChanged event) {
///   if (event.state.status.isCallActive) {
///     showCallUI();
///   } else {
///     hideCallUI();
///   }
/// }
/// ```
class CallStateChanged extends CallEvent {
  /// The current state of the SalesIQ call.
  ///
  /// It has the call status, such as connecting, connected, or ended, and
  /// whether the call is incoming. For details, see [SalesIQCallState].
  final SalesIQCallState state;

  /// Creates a new call state changed event.
  ///
  /// Parameters:
  /// - [state]: The new call state.
  CallStateChanged(this.state);
}


/// Sent when an error occurs during a SalesIQ call.
///
/// It is sent when there is an error in the call process. For example, a
/// connection fails, a media problem occurs, or another problem stops the call
/// from working. It gives an error message, an error code, and more information
/// about the error. Use them for debugging, or to show a clear error message to
/// the visitor.
class CallErrorOccurred extends CallEvent {
  /// The error message that describes what went wrong.
  final String errorMessage;

  /// The error code of the error.
  final int errorCode;

  /// More information about the error, if available.
  final CallErrorInfo? info;

  /// Creates a new [CallErrorOccurred] event.
  ///
  /// Parameters:
  /// - [errorMessage]: The error message that describes the failure.
  /// - [errorCode]: The error code of the error.
  /// - [info]: More information about the error, if available.
  CallErrorOccurred(this.errorMessage, this.errorCode, this.info);
}

/// Represents more information about a call error.
///
/// You can attach this information to a [CallErrorOccurred] event. Each
/// subclass gives the context of one kind of error, such as a creation failure
/// or an action failure.
abstract class CallErrorInfo {
  /// The type of the error information, such as "creationFailure" or
  /// "actionFailure".
  final String type;

  /// Creates a new [CallErrorInfo] with the given [type].
  CallErrorInfo(this.type);

  /// Creates a [CallErrorInfo] from a map.
  ///
  /// Returns a [CreationFailure] or an [ActionFailure], based on the "type"
  /// field in [data].
  static CallErrorInfo? fromMap(Map<dynamic, dynamic> data) {
    String type = data["type"];
    switch (type) {
      case "creationFailure":
        return CreationFailure();
      case "actionFailure":
        return ActionFailure.fromMap(data);
    }
    return null;
  }
}

/// Represents an error with a specific call action.
///
/// It tells you which call action failed, such as answering, holding, or ending
/// a call. It is used as more information in [CallErrorOccurred].
class ActionFailure extends CallErrorInfo {
  /// The call action that failed.
  final SalesIQCallAction action;

  /// Creates a new [ActionFailure] for the given [action].
  ActionFailure(this.action) : super("actionFailure");

  /// Creates an [ActionFailure] from a map.
  ///
  /// The [data] map must contain an "action" field.
  static ActionFailure fromMap(Map<dynamic, dynamic> data) {
    SalesIQCallAction action = SalesIQCallAction.fromString(data["action"]);
    return ActionFailure(action);
  }
}

/// Represents an error that occurs while a call is created.
///
/// It describes errors that happen when a call cannot be created or
/// initialized. It is used as more information in [CallErrorOccurred].
class CreationFailure extends CallErrorInfo {
  /// Creates a new [CreationFailure] instance.
  CreationFailure() : super("creationFailure");

  /// Creates a [CreationFailure] from the native error [data] map.
  static CreationFailure fromMap(Map<dynamic, dynamic> data) {
    return CreationFailure();
  }
}

/// Sent when the SDK finds a call state that it does not recognize.
///
/// This event is a fallback for when the call system finds a state that does
/// not match any known call state. This can happen during system updates, when
/// new call states are added, or when there are communication problems with the
/// call infrastructure.
///
/// Your app should handle this event safely. Usually, it logs the event and
/// keeps the last known good state until it receives a known state.
///
/// Example:
/// ```dart
/// void onUnknownCallState(UnknownCallState event) {
///   logger.warning('Unknown call state encountered');
///   // Maintain current UI state or show generic message
/// }
/// ```
class UnknownCallState extends CallEvent {
  /// Creates a new unknown call state event.
  ///
  /// This constructor takes no parameters, because unknown states usually do
  /// not carry more context.
  UnknownCallState();
}
