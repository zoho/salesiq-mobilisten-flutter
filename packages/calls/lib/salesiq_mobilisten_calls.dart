import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:salesiq_mobilisten_calls/call_events.dart';
import 'package:salesiq_mobilisten_core/salesiq_configuration.dart';
import 'package:salesiq_mobilisten_core/salesiq_conversation.dart';
import 'package:salesiq_mobilisten_core/salesiq_conversation_attributes.dart';
import 'package:salesiq_mobilisten_core/utils/image/utility.dart';
import 'package:salesiq_mobilisten_core/utils/salesiq_calls_helper.dart';

import 'events_manager.dart';

export 'package:salesiq_mobilisten_calls/call_events.dart';
export 'package:salesiq_mobilisten_calls/views/call_status_view.dart';
export 'package:salesiq_mobilisten_core/salesiq_conversation.dart';
export 'package:salesiq_mobilisten_core/salesiq_conversation_attributes.dart';
export 'package:salesiq_mobilisten_core/salesiq_department.dart';

/// This class provides APIs to manage and interact with the Zoho SalesIQ calls feature.
///
/// [ZohoSalesIQCalls] is for all call-related functionality
/// in the SalesIQ Mobilisten SDK. It provides comprehensive APIs to:
///
/// - Start and end call conversations
/// - Monitor call states and events in real-time
/// - Manage call UI components and visibility
/// - Handle call view modes (fullscreen, floating, status bar)
/// - Configure call settings and appearance
///
/// The class uses static methods to provide a simple, consistent API that can be
/// accessed from anywhere in your application without requiring instantiation.
/// All call operations are asynchronous and return Future objects for proper
/// async/await handling.
///
/// Example usage:
/// ```dart
/// // Listen to call events
/// ZohoSalesIQCalls.events.listen((event) {
///   if (event is CallStateChanged) {
///     print('Call state: ${event.state.status}');
///   }
/// });
///
/// // Start a call
/// final conversation = await ZohoSalesIQCalls.start();
///
/// // Check if calls are enabled
/// final isEnabled = await ZohoSalesIQCalls.isEnabled;
/// ```
class ZohoSalesIQCalls {
  static const MethodChannel _channel = MethodChannel('mobilisten_calls_api');

  ///
  /// This stream provides real-time updates about call state changes, queue position
  /// updates, and other call-related events. The stream is backed by the native
  /// platform's event system and automatically deserializes events into strongly-typed
  /// Dart objects.
  ///
  /// Available event types:
  /// - [CallStateChanged]: Fired when call status changes (connecting, connected, ended, etc.)
  /// - [QueuePositionChanged]: Fired when position in call queue updates
  /// - [UnknownCallState]: Fallback for unrecognized event types
  ///
  /// The stream is a broadcast stream, allowing multiple listeners without interference.
  ///
  /// Example:
  /// ```dart
  /// ZohoSalesIQCalls.events.listen((event) {
  ///   switch (event.runtimeType) {
  ///     case CallStateChanged:
  ///       final stateEvent = event as CallStateChanged;
  ///       handleCallStateChange(stateEvent.state);
  ///       break;
  ///     case QueuePositionChanged:
  ///       final queueEvent = event as QueuePositionChanged;
  ///       updateQueuePosition(queueEvent.position);
  ///       break;
  ///   }
  /// });
  /// ```
  static Stream<CallEvent> get events => CallEventManager().events;

  ///
  /// This method checks the SalesIQ brand configuration to determine if the
  /// call feature is available for use. The call feature must be enabled in
  /// the SalesIQ dashboard for this to return `true`.
  ///
  /// Returns `false` if:
  /// - Call feature is disabled in brand settings
  /// - Network error occurs during the check
  /// - SalesIQ is not properly initialized
  ///
  /// Returns `true` if the call feature is enabled and available for use.
  ///
  /// Example:
  /// ```dart
  /// if (await ZohoSalesIQCalls.isEnabled) {
  ///   // Show call UI or enable call functionality
  ///   showCallButton();
  /// } else {
  ///   // Hide call UI or show alternative options
  ///   hideCallButton();
  /// }
  /// ```
  static Future<bool> get isEnabled async => await _channel
      .invokeMethod<bool>('isEnabled')
      .then((onValue) => onValue ?? false);

  ///
  /// Retrieves the unique identifier for the currently active call session.
  /// This ID can be used to reference the call in other operations or for
  /// logging and tracking purposes.
  ///
  /// Returns `null` if:
  /// - There is no active call
  /// - The call session hasn't been established yet
  /// - An error occurred while retrieving the call ID
  ///
  /// Returns a non-null [String] containing the call ID if there's an active call.
  ///
  /// Example:
  /// ```dart
  /// final callId = await ZohoSalesIQCalls.currentCallId;
  /// if (callId != null) {
  ///   print('Active call ID: $callId');
  ///   // Use call ID for logging or operations
  /// } else {
  ///   print('No active call');
  /// }
  /// ```
  static Future<String?> get currentCallId async =>
      await _channel.invokeMethod<String?>('currentCallId');

  ///
  /// Retrieves comprehensive information about the current call including:
  /// - Call status (connecting, connected, ended, etc.)
  /// - Whether it's an incoming or outgoing call
  /// - Additional call metadata
  ///
  /// The [SalesIQCallState] object provides both the current status and contextual
  /// information about the call session.
  ///
  /// Returns `null` if:
  /// - There is no active call
  /// - Call state information is not available
  /// - An error occurred while retrieving the state
  ///
  /// Example:
  /// ```dart
  /// final state = await ZohoSalesIQCalls.currentState;
  /// if (state != null) {
  ///   print('Call status: ${state.status}');
  ///   if (state.status.isCallActive) {
  ///     showActiveCallUI();
  ///   }
  /// }
  /// ```
  static Future<SalesIQCallState?> get currentState async {
    return await _channel.invokeMapMethod('currentCallState').then((onValue) =>
        SalesIQCallState.fromMap(onValue?.cast<dynamic, dynamic>()));
  }

  /// Enters the call view for the current call in full screen mode.
  ///
  /// Transitions the call interface to full screen mode, providing the complete
  /// call experience with all available controls and information. This is typically
  /// used when the user wants to interact fully with the call interface.
  ///
  /// This method:
  /// - Brings the call UI to the foreground
  /// - Displays all call controls and information
  /// - Maximizes the call interface for optimal interaction
  ///
  /// Should be called when there's an active call to ensure proper functionality.
  ///
  /// Example:
  /// ```dart
  /// // When user taps on call status bar or notification
  /// onCallStatusTap() {
  ///   ZohoSalesIQCalls.enterFullScreenMode();
  /// }
  /// ```
  static void enterFullScreenMode() {
    _channel.invokeMethod('enterFullScreenMode');
  }

  /// Transitions the call interface to a floating overlay mode, allowing users
  /// to continue using other parts of the app while maintaining access to
  /// essential call controls. The floating view typically shows minimal call
  /// information and basic controls.
  ///
  /// This mode is useful for:
  /// - Multitasking during calls
  /// - Providing non-intrusive call controls
  /// - Maintaining call visibility while using other features
  ///
  /// Should be called when there's an active call and the user wants to
  /// minimize the call interface.
  ///
  /// Example:
  /// ```dart
  /// // When user wants to minimize call interface
  /// onMinimizeCall() {
  ///   ZohoSalesIQCalls.enterFloatingViewMode();
  /// }
  /// ```
  static void enterFloatingViewMode() {
    _channel.invokeMethod('enterFloatingViewMode');
  }

  /// Sets the title for the call view when online and offline.
  ///
  /// Parameters:
  /// - [onlineTitle]: Title to display when the department is online.
  ///   Pass `null` to use the default online title.
  /// - [offlineTitle]: Title to display when the department is offline.
  ///   Pass `null` to use the default offline title.
  ///
  /// The titles are displayed in the call interface header and help users
  /// understand the current state of their connection.
  ///
  /// Example:
  /// ```dart
  /// // Set custom titles for different states
  /// ZohoSalesIQCalls.setTitle(
  ///   'Calls Support',
  ///   'Leave us a missed call'
  /// );
  ///
  /// // Use default offline title but custom online title
  /// ZohoSalesIQCalls.setTitle('Live Support Chat', null);
  /// ```
  static void setTitle(String? onlineTitle, String? offlineTitle) {
    _channel.invokeMethod('setTitle', {
      'onlineTitle': onlineTitle,
      'offlineTitle': offlineTitle,
    });
  }

  /// Sets the CallKit icon for iOS call integration.
  ///
  /// Configures the icon displayed in iOS CallKit interface.
  ///
  /// This method is iOS-specific and has no effect on Android devices.
  /// The icon should be properly formatted for iOS CallKit requirements.
  ///
  /// Parameters:
  /// - [icon]: The icon data to use for CallKit integration. The format depends
  ///   on the native implementation requirements.
  ///
  /// Example:
  /// ```dart
  /// // Set CallKit icon (iOS only)
  /// if (Platform.isIOS) {
  ///   ZohoSalesIQCalls.setIOSCallKitIcon(iconData);
  /// }
  /// ```
  static void setIOSCallKitIcon(dynamic icon) async {
    if (icon is String && icon.isNotEmpty) {
      String? base64Image = await getBase64EncodedImage(icon);
      if (base64Image != null) {
        _channel.invokeMethod('setCallKitIcon', base64Image);
        return;
      }
    }
    _channel.invokeMethod('setCallKitIcon', icon);
  }

  /// Initiates a new call session or resumes an existing one. This method
  /// provides comprehensive options for configuring the call experience,
  /// including conversation attributes and UI behavior.
  ///
  /// Parameters:
  /// - [id]: Optional conversation ID to resume an existing call conversation.
  ///   If null, a new conversation will be started.
  /// - [displayActiveCall]: Whether to display the active call UI if the call
  ///   is already in progress. Defaults to `true`.
  /// - [attributes]: Optional conversation attributes such as operator information,
  ///   custom fields, or additional metadata for the call session.
  ///
  /// Returns a [SalesIQConversation] object representing the started conversation,
  /// or `null` if the call could not be started.
  ///
  /// The conversation object contains:
  /// - Conversation ID for future reference
  /// - Participant information
  /// - Conversation metadata and attributes
  ///
  /// Example:
  /// ```dart
  /// // Start a new call with default settings
  /// final conversation = await ZohoSalesIQCalls.start();
  ///
  /// // Resume existing call with custom attributes
  /// final attributes = SalesIQConversationAttributes(
  ///   name: 'John Doe',
  ///   additionalInfo: 'Technical Support',
  /// );
  /// final conversation = await ZohoSalesIQCalls.start(
  ///   id: 'existing_conversation_id',
  ///   displayActiveCall: true,
  ///   attributes: attributes,
  /// );
  ///
  /// if (conversation != null) {
  ///   print('Call started: ${conversation.id}');
  /// }
  /// ```
  static Future<SalesIQConversation?> start(
      {String? id = null,
      bool displayActiveCall = true,
      SalesIQConversationAttributes? attributes = null}) async {
    Map<String, Object> map = {
      'displayActiveCall': displayActiveCall,
    };
    if (id != null) {
      map['id'] = id;
    }
    if (attributes != null) {
      map['attributes'] = await attributes.toMap();
    }
    return await _channel.invokeMapMethod('start', map).then((onValue) =>
        SalesIQConversation.fromMap(onValue?.cast<dynamic, dynamic>()));
  }

  static List<SalesIQConversation> _getConversations(
      List<Map<dynamic, dynamic>>? conversationsList) {
    if (conversationsList == null || conversationsList.isEmpty) {
      return [];
    }
    List<SalesIQConversation> conversations = [];
    for (var conversationMap in conversationsList) {
      SalesIQConversation? conversation =
          SalesIQConversation.fromMap(conversationMap);
      if (conversation != null) {
        conversations.add(conversation);
      }
    }
    return conversations;
  }

  /// Terminates the active call session and cleans up associated resources.
  /// This method gracefully closes the call connection, notifies all participants,
  /// and updates the call state to ended.
  ///
  /// The method handles:
  /// - Terminating the call connection
  /// - Cleaning up call resources
  /// - Notifying participants of call end
  /// - Updating call state and UI
  ///
  /// Returns a [SalesIQConversation] object representing the ended conversation
  /// with final call information, or `null` if no call was active or an error occurred.
  ///
  /// The returned conversation object contains:
  /// - Final call duration and statistics
  /// - End time and reason
  /// - Participant information
  /// - Conversation metadata
  ///
  /// Example:
  /// ```dart
  /// // End the current call
  /// final endedConversation = await ZohoSalesIQCalls.end();
  ///
  /// if (endedConversation != null) {
  ///   print('Call ended: ${endedConversation.id}');
  ///   // Log call duration, save conversation, etc.
  ///   logCallEnd(endedConversation);
  /// } else {
  ///   print('No active call to end');
  /// }
  /// ```
  static Future<SalesIQConversation?> end() async {
    return await _channel.invokeMapMethod('end').then((onValue) =>
        SalesIQConversation.fromMap(onValue?.cast<dynamic, dynamic>()));
  }

  /// Configures predefined messages that can be quickly sent for an incoming call.
  /// These messages appear as quick-reply options in the call interface, allowing
  /// users to send common responses or information without typing.
  ///
  /// This feature is useful for:
  /// - Providing quick responses to common questions
  /// - Sending standardized information during calls
  /// - Improving efficiency in call interactions
  /// - Reducing typing effort during active calls
  ///
  /// Parameters:
  /// - [messages]: A list of strings representing the predefined messages.
  ///   Each string becomes a quick-reply option in the call interface.
  ///
  /// The messages are displayed as buttons or options that users can tap
  /// to send immediately during the call.
  ///
  /// Example:
  /// ```dart
  /// // Set common reply messages for support calls
  /// ZohoSalesIQCalls.setReplyMessages([
  ///   'Please hold while I check that for you',
  ///   'Can you please provide more details?',
  ///   'I\'ll escalate this to our technical team',
  ///   'Thank you for your patience',
  ///   'Is there anything else I can help you with?'
  /// ]);
  /// ```
  static void setAndroidReplyMessages(List<String> messages) {
    _channel.invokeMethod('setAndroidReplyMessages', {'messages': messages});
  }

  /// Controls which UI components are displayed in the call interface, allowing
  /// customization of the call experience based on your application's requirements.
  /// This method enables fine-grained control over call UI elements.
  ///
  /// Available components that can be controlled:
  /// - [CallComponent.operatorName]: Shows/hides the operator's name
  /// - [CallComponent.operatorImage]: Shows/hides the operator's profile image
  /// - [CallComponent.preChatForm]: Shows/hides the pre-chat form
  /// - [CallComponent.queuePosition]: Shows/hides the queue position indicator
  ///
  /// Parameters:
  /// - [component]: The specific UI component to configure visibility for.
  ///   Use values from the [CallComponent] enum.
  /// - [isVisible]: Boolean indicating whether the component should be visible.
  ///   `true` shows the component, `false` hides it.
  ///
  /// Changes take effect immediately and apply to the current and future call sessions.
  ///
  /// Example:
  /// ```dart
  /// // Hide operator image but show name
  /// ZohoSalesIQCalls.setVisibility(CallComponent.operatorImage, false);
  /// ZohoSalesIQCalls.setVisibility(CallComponent.operatorName, true);
  ///
  /// // Hide pre-chat form for direct calls
  /// ZohoSalesIQCalls.setVisibility(CallComponent.preChatForm, false);
  ///
  /// // Show queue position during busy periods
  /// ZohoSalesIQCalls.setVisibility(CallComponent.queuePosition, true);
  /// ```
  static void setVisibility(CallComponent component, bool isVisible) {
    _channel.invokeMethod('setVisibility', {
      'component': component.name,
      'isVisible': isVisible,
    });
  }

  /// Retrieves all call conversations that are currently active or have been
  /// completed within the session. This method provides access to conversation
  /// history and can be used for displaying call logs, analytics, or conversation
  /// management features.
  ///
  /// The returned list includes:
  /// - Active call conversations
  /// - Recently completed calls
  /// - Call conversation metadata and details
  /// - Participant information for each conversation
  ///
  /// Returns an empty list if:
  /// - No call conversations exist
  /// - User doesn't have access to conversation history
  /// - An error occurred while retrieving conversations
  ///
  /// Each [SalesIQConversation] in the list contains:
  /// - Conversation ID and metadata
  /// - Participant information
  /// - Call duration and timestamps
  /// - Conversation status and state
  ///
  /// This method is useful for:
  /// - Building call history interfaces
  /// - Generating call reports and analytics
  /// - Managing ongoing conversations
  /// - Providing conversation context to users
  ///
  /// Example:
  /// ```dart
  /// // Get all call conversations
  /// final conversations = await ZohoSalesIQCalls.getList();
  ///
  /// print('Total conversations: ${conversations.length}');
  ///
  /// for (final conversation in conversations) {
  ///   print('Conversation ID: ${conversation.id}');
  ///   print('Status: ${conversation.status}');
  ///   // Display in call history UI
  /// }
  /// ```
  static Future<List<SalesIQConversation>> getList() async {
    return await _channel.invokeListMethod('getCallConversations').then(
        (onValue) => _getConversations(onValue?.cast<Map<dynamic, dynamic>>()));
  }

  /// Retrieves the necessary parameters and configuration to instantiate a native
  /// Android status bar view for active calls. This method is used internally by
  /// the [SalesIQAndroidCallStatusBarView] widget to create the native view.
  ///
  /// The method provides:
  /// - View type identifier for the native Android view
  /// - Configuration parameters for view creation
  /// - Theme-specific settings based on dark/light mode
  /// - Layout and appearance parameters
  ///
  /// Parameters:
  /// - [isDarkMode]: Boolean indicating whether to use dark theme styling.
  ///   Affects colors, icons, and overall appearance of the status bar.
  ///
  /// Returns a [Map] containing:
  /// - `viewType`: String identifier for the native view type
  /// - `success`: Boolean indicating if the view parameters were generated successfully
  /// - Additional platform-specific parameters for view creation
  ///
  /// This method is typically called by Flutter widgets that need to embed
  /// the native call status bar view, such as [SalesIQAndroidCallStatusBarView].
  ///
  /// Example:
  /// ```dart
  /// // Get status bar view parameters
  /// final params = await ZohoSalesIQCalls.getStatusBarView(
  ///   Theme.of(context).brightness == Brightness.dark
  /// );
  ///
  /// if (params['success'] == true) {
  ///   // Use params to create AndroidView widget
  ///   final widget = ZohoSalesIQCalls.buildStatusBarView(
  ///     viewType: params['viewType'],
  ///     params: params,
  ///   );
  /// }
  /// ```
  static Future<Map> getStatusBarView(bool isDarkMode) async {
    if (SalesIQCallsHelper.currentAndroidCallViewMode !=
        SalesIQCallViewMode.banner) {
      return Future.value({
        "success": false,
        "message": "Call view mode is not set to banner."
      });
    }
    return await _channel
        .invokeMethod('getStatusBarView', {"isDarkMode": isDarkMode});
  }

  /// Creates a Flutter widget that displays the native call status bar view.
  ///
  /// Builds an [AndroidView] widget that embeds the native Android call status bar
  /// view into the Flutter widget tree. This widget displays call information in
  /// a compact status bar format and provides tap handling for call interactions.
  ///
  /// The widget:
  /// - Embeds the native Android view using the provided view type
  /// - Passes creation parameters to configure the native view
  /// - Sets up gesture recognizers for touch handling
  /// - Configures clipping behavior for proper layout
  ///
  /// Parameters:
  /// - [viewType]: The native view type identifier obtained from [getStatusBarView].
  ///   This tells Android which native view class to instantiate.
  /// - [params]: Optional creation parameters to pass to the native view.
  ///   These parameters configure the view's appearance and behavior.
  ///
  /// Returns a [Widget] that can be embedded in the Flutter widget tree.
  /// The widget will display the native call status bar and handle user interactions.
  ///
  /// The widget includes:
  /// - Gesture recognition for tap handling
  /// - Proper message codec for parameter passing
  /// - Optimized clipping for performance
  ///
  /// This method is typically used by [SalesIQAndroidCallStatusBarView] but can
  /// be used directly if you need custom integration.
  ///
  /// Example:
  /// ```dart
  /// // Get view parameters and build widget
  /// final params = await ZohoSalesIQCalls.getStatusBarView(isDarkMode);
  ///
  /// final statusBarWidget = ZohoSalesIQCalls.buildStatusBarView(
  ///   viewType: params['viewType'] as String,
  ///   params: params,
  /// );
  ///
  /// // Use in widget tree
  /// return Column(
  ///   children: [
  ///     statusBarWidget,
  ///     // Other widgets...
  ///   ],
  /// );
  /// ```
  static Widget buildStatusBarView(
      {required String viewType, Map<dynamic, dynamic>? params}) {
    return AndroidView(
        viewType: viewType,
        creationParams: params,
        creationParamsCodec: const StandardMessageCodec(),
        gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
          Factory<OneSequenceGestureRecognizer>(
            () => EagerGestureRecognizer(),
          ),
        },
        clipBehavior: Clip.none);
  }
}

/// This enum defines the various UI elements within the SalesIQ call interface
/// that can be shown or hidden using the [ZohoSalesIQCalls.setVisibility] method.
/// Each component serves a specific purpose in the call experience and can be
/// controlled independently.
///
/// Available components:
/// - [operatorName]: The name/title of the call operator or agent
/// - [operatorImage]: The profile picture or avatar of the operator
/// - [preChatForm]: A form displayed before the call starts for gathering information
/// - [queuePosition]: An indicator showing the user's position in the call queue
///
/// These components can be selectively shown or hidden to customize the call
/// interface according to your application's requirements and user experience goals.
///
/// Example usage:
/// ```dart
/// // Hide operator image for a cleaner interface
/// ZohoSalesIQCalls.setVisibility(CallComponent.operatorImage, false);
///
/// // Show queue position during busy periods
/// ZohoSalesIQCalls.setVisibility(CallComponent.queuePosition, true);
/// ```
enum CallComponent {
  /// The operator's name or title displayed in the call interface.
  /// Shows the name of the agent or representative handling the call.
  operatorName,

  /// The operator's profile image or avatar.
  /// Displays a visual representation of the agent handling the call.
  operatorImage,

  /// A form shown before the call starts.
  /// Used to collect user information or call context before initiating the call.
  preChatForm,

  /// An indicator showing the user's position in the call queue.
  /// Displays how many people are ahead in line when calls are queued.
  queuePosition
}

/// Enum representing the status of a call in Zoho SalesIQ.
///
/// This enum defines all possible states that a SalesIQ call can be in during
/// its lifecycle. Each status represents a specific phase of the call process,
/// from initiation through completion or termination.
///
/// The statuses follow a typical call flow:
/// 1. [none] → [calling] → [ringing] → [connecting] → [connected]
/// 2. From [connected], calls can go to [reconnecting] if connection issues occur
/// 3. Calls end in [ended], [missed], [cancelled], [declined], or [failed]
/// 4. Calls may be placed in [queue] when operators are busy
///
/// Each status provides context about the current call state and can be used
/// to update UI, trigger actions, or handle call logic appropriately.
enum SalesIQCallStatus {
  /// No call is active or no call status is available.
  /// This is the default state when no call operations are in progress.
  none,

  /// Call is being initiated and dialing is in progress.
  /// The call request has been sent but not yet connected to the recipient.
  calling,

  /// Call is ringing on the recipient's end.
  /// The call has reached the recipient and is awaiting answer.
  ringing,

  /// Call is in the process of establishing connection.
  /// The recipient has answered and connection negotiation is in progress.
  connecting,

  /// Call is successfully connected and active.
  /// Both parties are connected and can communicate.
  connected,

  // onHold, // Commented out - call is temporarily paused

  /// Call is attempting to reconnect after connection loss.
  /// Temporary network issues are being resolved automatically.
  reconnecting,

  /// Call has ended normally.
  /// The call was completed successfully and terminated by either party.
  ended,

  /// Call was missed by the recipient.
  /// The call was not answered within the timeout period.
  missed,

  /// Call was cancelled by the caller before connection.
  /// The caller terminated the call before it was answered.
  cancelled,

  /// Call was declined by the recipient.
  /// The recipient actively rejected the incoming call.
  declined,

  /// Call failed due to technical issues.
  /// System errors, network problems, or other technical failures occurred.
  failed,

  /// Call is waiting in queue for an available operator.
  /// No operators are currently available and the call is queued.
  queue,

  /// Invalid or unknown call status.
  /// Used as fallback for unrecognized status values.
  invalid;

  /// Returns true if the call is in an active state where communication can occur.
  ///
  /// Active call states include all statuses where the call is progressing
  /// toward or maintaining a connection. This excludes terminal states like
  /// ended, failed, missed, etc.
  ///
  /// Active states: [calling], [ringing], [connecting], [connected], [reconnecting], [queue]
  /// Inactive states: [none], [ended], [missed], [cancelled], [declined], [failed], [invalid]
  ///
  /// This property is useful for:
  /// - Determining when to show active call UI
  /// - Controlling call-related features and buttons
  /// - Managing call state transitions
  ///
  /// Example:
  /// ```dart
  /// if (callStatus.isCallActive) {
  ///   showCallControls();
  ///   enableCallFeatures();
  /// } else {
  ///   hideCallControls();
  ///   disableCallFeatures();
  /// }
  /// ```
  bool get isCallActive => {
        SalesIQCallStatus.calling,
        SalesIQCallStatus.ringing,
        SalesIQCallStatus.connecting,
        SalesIQCallStatus.connected,
        // SalesIQCallStatus.onHold,
        SalesIQCallStatus.reconnecting,
        SalesIQCallStatus.queue,
      }.contains(this);

  /// Creates a [SalesIQCallStatus] from a string value.
  ///
  /// Converts string representations of call statuses (typically received from
  /// native platforms) into the corresponding enum values. This method handles
  /// the deserialization of call status data from the native bridge.
  ///
  /// Parameters:
  /// - [value]: The string representation of the call status. Can be null.
  ///
  /// Returns the corresponding [SalesIQCallStatus] enum value, or [invalid]
  /// if the value is null or doesn't match any known status.
  ///
  /// The method performs case-sensitive matching against the enum value names
  /// (after the dot notation, e.g., "calling" matches [SalesIQCallStatus.calling]).
  ///
  /// Example:
  /// ```dart
  /// final status1 = SalesIQCallStatus.fromString('connected');
  /// // Returns SalesIQCallStatus.connected
  ///
  /// final status2 = SalesIQCallStatus.fromString('invalid_status');
  /// // Returns SalesIQCallStatus.invalid
  ///
  /// final status3 = SalesIQCallStatus.fromString(null);
  /// // Returns SalesIQCallStatus.invalid
  /// ```
  static SalesIQCallStatus fromString(String? value) {
    if (value == null) {
      return SalesIQCallStatus.invalid;
    }
    // else if (value == "on_hold") {
    //   return SalesIQCallStatus.onHold;
    // }
    return SalesIQCallStatus.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => SalesIQCallStatus.invalid,
    );
  }
}

/// Represents the current state of a SalesIQ call.
///
/// This class encapsulates comprehensive information about a call's current status
/// and properties. It provides a snapshot of the call state at a specific moment
/// and is used throughout the SalesIQ system to track and respond to call changes.
///
/// The state object includes:
/// - Current call status (connecting, connected, ended, etc.)
/// - Call direction information (incoming vs outgoing)
/// - Additional call metadata and properties
///
/// This class is immutable and represents a point-in-time snapshot of call state.
/// When call state changes, a new [SalesIQCallState] instance is created with
/// updated information.
///
/// Example usage:
/// ```dart
/// final callState = await ZohoSalesIQCalls.currentState;
///
/// if (callState != null) {
///   print('Call status: ${callState.status}');
///
///   if (callState.status.isCallActive) {
///     showActiveCallUI();
///   }
///
///   if (callState.isIncomingCall == true) {
///     showIncomingCallControls();
///   }
/// }
/// ```
class SalesIQCallState {
  /// The current status of the call.
  ///
  /// Indicates the current phase of the call lifecycle, such as calling,
  /// connected, ended, etc. This status drives most call-related UI updates
  /// and business logic decisions.
  ///
  /// See [SalesIQCallStatus] for all possible status values and their meanings.
  final SalesIQCallStatus status;

  /// Indicates whether this is an incoming call.
  ///
  /// - `true`: The call was initiated by another party (incoming call)
  /// - `false`: The call was initiated by the current user (outgoing call)
  /// - `null`: Call direction is unknown or not applicable
  ///
  /// This information is useful for:
  /// - Displaying appropriate UI (answer/decline vs hang up)
  /// - Applying different call handling logic
  /// - Logging and analytics purposes
  /// - Customizing call experience based on direction
  final bool? isIncomingCall;

  /// Creates a new [SalesIQCallState] instance.
  ///
  /// Parameters:
  /// - [status]: The current call status. Required.
  /// - [isIncomingCall]: Optional boolean indicating call direction.
  ///   Pass `null` if direction is unknown or not applicable.
  ///
  /// Example:
  /// ```dart
  /// final state = SalesIQCallState(
  ///   status: SalesIQCallStatus.connected,
  ///   isIncomingCall: true,
  /// );
  /// ```
  SalesIQCallState({required this.status, this.isIncomingCall});

  /// Creates a [SalesIQCallState] from a map of data.
  ///
  /// Deserializes call state information from a map structure, typically
  /// received from the native platform or API responses. This factory method
  /// handles the conversion of raw data into a properly typed state object.
  ///
  /// Parameters:
  /// - [map]: Map containing call state data. Can be `null`.
  ///
  /// Expected map structure:
  /// ```dart
  /// {
  ///   'status': 'connected',        // String status value
  ///   'isIncomingCall': true,       // Boolean call direction
  /// }
  /// ```
  ///
  /// Returns a [SalesIQCallState] with:
  /// - Parsed status from the 'status' field
  /// - Call direction from the 'isIncomingCall' field
  /// - Invalid status if map is null or malformed
  ///
  /// If the map is `null` or doesn't contain expected data, returns a state
  /// with [SalesIQCallStatus.invalid] and `null` for call direction.
  ///
  /// Example:
  /// ```dart
  /// final stateData = {
  ///   'status': 'connected',
  ///   'isIncomingCall': false,
  /// };
  ///
  /// final state = SalesIQCallState.fromMap(stateData);
  /// print('Status: ${state.status}'); // SalesIQCallStatus.connected
  /// print('Incoming: ${state.isIncomingCall}'); // false
  /// ```
  factory SalesIQCallState.fromMap(Map<dynamic, dynamic>? map) {
    if (map == null) {
      return SalesIQCallState(
        status: SalesIQCallStatus.invalid,
        isIncomingCall: null,
      );
    }

    return SalesIQCallState(
      status: SalesIQCallStatus.fromString(map['status']),
      isIncomingCall: map['isIncomingCall'],
    );
  }
}
