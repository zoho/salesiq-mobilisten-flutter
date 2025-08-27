import 'package:salesiq_mobilisten_calls/salesiq_mobilisten_calls.dart';

/// Base abstract class for all call-related events in the SalesIQ Mobilisten calls system.
///
/// This class serves as the foundation for all call events that can occur during
/// the lifecycle of a SalesIQ call. It provides a common interface for handling
/// different types of call events in a type-safe manner.
///
/// All concrete call event classes should extend this base class to ensure
/// consistent event handling throughout the application.
///
/// Example usage:
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

/// Event fired when the visitor's position in the call queue changes.
///
/// This event is triggered when there are changes to the visitors's position
/// in the waiting queue for SalesIQ calls. It provides information about
/// which conversation the change relates to and the new position in the queue.
///
/// A lower position number indicates the visitor is closer to being connected
/// to an agent (position 1 means next in line).
///
/// Example usage:
/// ```dart
/// void onQueuePositionChanged(QueuePositionChanged event) {
///   print('Conversation ${event.conversationId} is now at position ${event.position}');
/// }
/// ```
class QueuePositionChanged extends CallEvent {
  /// The unique identifier of the conversation for which the queue position changed.
  ///
  /// This ID can be used to correlate this event with a specific conversation
  /// or call session in your application.
  final String conversationId;

  /// The new position in the call queue.
  ///
  /// A value of 1 indicates the visitor is next in line to be connected.
  /// Higher numbers indicate more people ahead in the queue.
  /// This value should always be greater than 0.
  final int position;

  /// Creates a new queue position changed event.
  ///
  /// Parameters:
  /// - [conversationId]: The unique identifier of the conversation
  /// - [position]: The new position in the queue (must be > 0)
  QueuePositionChanged(this.conversationId, this.position);
}

/// Event fired when the state of a SalesIQ call changes.
///
/// This event is triggered whenever there's a change in the call state,
/// such as when a call is initiated, connected, ended, or encounters an error.
/// It provides access to the complete call state information including
/// status, participants, duration, and other call-related data.
///
/// This is one of the most important events for tracking call lifecycle
/// and updating UI components that depend on call status.
///
/// Example usage:
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
  /// This object contains comprehensive information about the call including:
  /// - Call status (active, inactive, connecting, etc.)
  /// - Participant information
  /// - Call duration and timing
  /// - Audio/video settings
  /// - Any error states or messages
  final SalesIQCallState state;

  /// Creates a new call state changed event.
  ///
  /// Parameters:
  /// - [state]: The new call state containing all relevant call information
  CallStateChanged(this.state);
}

/// Event fired when an unknown or unrecognized call state is encountered.
///
/// This event serves as a fallback for situations where the call system
/// encounters a state that doesn't match any of the known call states.
/// This can happen during system updates, when new call states are introduced,
/// or when there are communication issues with the underlying call infrastructure.
///
/// Applications should handle this event gracefully, typically by logging
/// the occurrence and maintaining the last known good state until a
/// recognized state is received.
///
/// Example usage:
/// ```dart
/// void onUnknownCallState(UnknownCallState event) {
///   logger.warning('Unknown call state encountered');
///   // Maintain current UI state or show generic message
/// }
/// ```
class UnknownCallState extends CallEvent {
  /// Creates a new unknown call state event.
  ///
  /// This constructor doesn't require any parameters as unknown states
  /// typically don't carry additional context information.
  UnknownCallState();
}
