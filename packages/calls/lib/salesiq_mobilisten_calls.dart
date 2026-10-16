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

/// Provides the APIs for the voice calls feature of Zoho SalesIQ.
///
/// With [ZohoSalesIQCalls], you can do the following in the SalesIQ Mobilisten
/// SDK:
///
/// - Start and end call conversations.
/// - Follow call states and events in real time.
/// - Manage the call UI components and their visibility.
/// - Switch the call view mode between full screen, floating, and the status
///   bar.
/// - Configure call settings and appearance.
///
/// All methods are static, so you can call them from anywhere in your app
/// without creating an instance. Every call operation is asynchronous and
/// returns a `Future` that you can `await`.
///
/// Example:
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

  /// Returns the stream of call events.
  ///
  /// The stream sends real-time updates when the call state or the queue
  /// position changes, and for other call events. The native event system of
  /// each platform drives the stream. The SDK converts each event into a typed
  /// Dart object.
  ///
  /// The stream can send these event types:
  /// - [CallStateChanged]: Sent when the call status changes, such as to
  ///   connecting, connected, or ended.
  /// - [QueuePositionChanged]: Sent when the position in the call queue
  ///   changes.
  /// - [UnknownCallState]: The fallback for event types that are not
  ///   recognized.
  ///
  /// The stream is a broadcast stream, so many listeners can use it at the same
  /// time without affecting each other.
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

  /// Returns whether the calls feature is enabled for your brand.
  ///
  /// It checks the configuration of your SalesIQ brand to see whether the calls
  /// feature is available. The calls feature must be turned on in the SalesIQ
  /// console for this to return `true`.
  ///
  /// Returns `false` in these cases:
  /// - The calls feature is turned off in the brand settings.
  /// - A network error occurs during the check.
  /// - SalesIQ is not initialized properly.
  ///
  /// Returns `true` when the calls feature is turned on and available.
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

  /// Returns the unique ID of the current active call.
  ///
  /// Use this ID to refer to the call in other operations, or for logging and
  /// tracking.
  ///
  /// Returns `null` in these cases:
  /// - There is no active call.
  /// - The call session is not set up yet.
  /// - An error occurred while getting the call ID.
  ///
  /// When there is an active call, it returns a non-null [String] with the call
  /// ID.
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

  /// Returns the state of the current call.
  ///
  /// The [SalesIQCallState] has the call status, such as connecting,
  /// connected, or ended, and whether the call is incoming or outgoing.
  ///
  /// Returns `null` in these cases:
  /// - There is no active call.
  /// - The call state is not available.
  /// - An error occurred while getting the state.
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

  /// Opens the call view of the current call in full screen mode.
  ///
  /// The full screen view shows the complete call screen, with all the controls
  /// and details.
  ///
  /// Call this method only when there is an active call.
  ///
  /// Example:
  /// ```dart
  /// // When the visitor taps the call status bar or notification
  /// onCallStatusTap() {
  ///   ZohoSalesIQCalls.enterFullScreenMode();
  /// }
  /// ```
  static void enterFullScreenMode() {
    _channel.invokeMethod('enterFullScreenMode');
  }

  /// Switches the call view of the current call to floating view mode.
  ///
  /// The floating view lets visitors keep using other parts of your app, with
  /// the main call controls still in reach. It usually shows a few call details
  /// and basic controls.
  ///
  /// This mode helps visitors do other tasks during a call. It keeps the call
  /// and its controls in view, without getting in the way.
  ///
  /// Call this method when there is an active call and the visitor wants to
  /// minimize the call screen.
  ///
  /// Example:
  /// ```dart
  /// // When the visitor wants to minimize the call screen
  /// onMinimizeCall() {
  ///   ZohoSalesIQCalls.enterFloatingViewMode();
  /// }
  /// ```
  static void enterFloatingViewMode() {
    _channel.invokeMethod('enterFloatingViewMode');
  }

  /// Sets the title of the call view for when the department is online and
  /// offline.
  ///
  /// Parameters:
  /// - [onlineTitle]: The title to show when the department is online. To use
  ///   the default online title, pass `null`.
  /// - [offlineTitle]: The title to show when the department is offline. To use
  ///   the default offline title, pass `null`.
  ///
  /// The title appears in the header of the call screen. It helps visitors
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

  /// Sets the icon for the iOS CallKit integration.
  ///
  /// This icon appears in the iOS CallKit interface.
  ///
  /// This method works only on iOS and has no effect on Android. Make sure the
  /// icon meets the CallKit requirements of iOS.
  ///
  /// Parameters:
  /// - [icon]: The icon data for the CallKit integration. The format depends on
  ///   the requirements of the native implementation.
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

  /// Turns on VoIP (PushKit) call notifications for iOS with the given PushKit
  /// [token].
  ///
  /// On test devices, set [isTestDevice] to `true`. While you test with a
  /// development build, set [mode] to [APNSMode.sandbox].
  ///
  /// This works only on iOS. On Android, call notifications arrive through FCM,
  /// which you set up with `registerPush` in the notification module. So on
  /// Android, this call has no effect.
  static Future<void> enableVoIP(String token,
      {bool isTestDevice = false, APNSMode mode = APNSMode.production}) {
    return _channel.invokeMethod('enableVoIP', {
      'token': token,
      'isTestDevice': isTestDevice,
      'mode': mode.name,
    });
  }

  /// Handles a VoIP (PushKit) notification action with the given notification
  /// payload [info].
  ///
  /// This works only on iOS. On Android, it completes right away.
  static Future<void> handleVOIPNotificationAction(Map info) async {
    await _channel.invokeMethod('handleVOIPNotificationAction', info);
  }

  /// Starts a new call, or resumes an existing one.
  ///
  /// You can set conversation attributes and choose how the call UI behaves.
  ///
  /// Parameters:
  /// - [id]: The ID of an existing call conversation to resume. This is
  ///   optional. If it is null, a new conversation starts.
  /// - [displayActiveCall]: Whether to show the active call UI if the call is
  ///   already in progress. The default is `true`.
  /// - [attributes]: Optional conversation attributes for the call session,
  ///   such as operator information, custom fields, or other metadata.
  ///
  /// Returns the [SalesIQConversation] of the call, or `null` if the call could
  /// not start.
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

  /// Ends the active call.
  ///
  /// Returns the [SalesIQConversation] that ended, or `null` if no call was
  /// active or an error occurred. The conversation has the details of the
  /// operator, and its `media` has the call times and who ended the call.
  ///
  /// Example:
  /// ```dart
  /// // End the current call
  /// final endedConversation = await ZohoSalesIQCalls.end();
  ///
  /// if (endedConversation != null) {
  ///   print('Call ended: ${endedConversation.id}');
  ///   // Log the call duration or save the conversation.
  ///   logCallEnd(endedConversation);
  /// } else {
  ///   print('No active call to end');
  /// }
  /// ```
  static Future<SalesIQConversation?> end() async {
    return await _channel.invokeMapMethod('end').then((onValue) =>
        SalesIQConversation.fromMap(onValue?.cast<dynamic, dynamic>()));
  }

  /// Sets the quick-reply messages that the visitor can send to decline an
  /// incoming call. They appear in the incoming call notification.
  ///
  /// This works only on Android. Set the messages before you call
  /// `ZohoSalesIQ.initialize()`.
  ///
  /// Parameters:
  /// - [messages]: The list of messages. Each string becomes one quick reply.
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

  /// Shows or hides a UI component on the call screen, so you can adapt the
  /// call experience to your app.
  ///
  /// You can control these components:
  /// - [CallComponent.operatorName]: Shows or hides the operator's name.
  /// - [CallComponent.operatorImage]: Shows or hides the operator's profile
  ///   image.
  /// - [CallComponent.preChatForm]: Shows or hides the pre-chat form.
  /// - [CallComponent.queuePosition]: Shows or hides the queue position
  ///   indicator.
  ///
  /// Parameters:
  /// - [component]: The UI component to show or hide. Use a value from the
  ///   [CallComponent] enum.
  /// - [isVisible]: Whether the component is visible. `true` shows the
  ///   component, and `false` hides it.
  ///
  /// Changes apply right away, to the current call and to future calls.
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

  /// Returns the conversations that the SDK knows about, as a list of
  /// [SalesIQConversation].
  ///
  /// Each item is a [SalesIQCallConversation]. When the native SDK includes
  /// chats, an item can also be a [SalesIQChatConversation], so check the type
  /// before you read fields that belong to one type. Returns an empty list when
  /// there are no conversations, or when an error occurs.
  ///
  /// You can use it to build your own call history screen.
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

  /// Returns the parameters and configuration that create a native Android
  /// status bar view for active calls.
  ///
  /// The [SalesIQAndroidCallStatusBarView] widget uses this method internally
  /// to create the native view.
  ///
  /// This works only when the call view mode is banner.
  ///
  /// Parameters:
  /// - [isDarkMode]: Whether to use the dark theme. It changes the colors,
  ///   icons, and overall look of the status bar.
  ///
  /// Returns a [Map] that contains:
  /// - `viewType`: The string ID of the native view type.
  /// - `success`: Whether the view parameters were created successfully.
  /// - Other platform parameters to create the view.
  ///
  /// For the usual case, use the [SalesIQAndroidCallStatusBarView] widget,
  /// which calls this method for you.
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

  /// Creates a Flutter widget that shows the native call status bar view.
  ///
  /// It builds an [AndroidView] widget that embeds the native Android call
  /// status bar view in the Flutter widget tree. The widget shows call
  /// information in a compact status bar, and it handles taps for call actions.
  ///
  /// Parameters:
  /// - [viewType]: The native view type ID from [getStatusBarView]. It tells
  ///   Android which native view class to create.
  /// - [params]: Optional creation parameters for the native view. They set the
  ///   appearance and behavior of the view.
  ///
  /// Returns a [Widget] that you can embed in the Flutter widget tree. The
  /// widget shows the native call status bar and handles the visitor's taps.
  ///
  /// [SalesIQAndroidCallStatusBarView] usually calls this method, but you can
  /// also call it directly for a custom integration.
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

/// Defines the UI components of the SalesIQ call screen that you can show or
/// hide with [ZohoSalesIQCalls.setVisibility].
///
/// Each component has its own role in the call experience, and you can control
/// each one separately.
///
/// Available components:
/// - [operatorName]: The name or title of the operator on the call.
/// - [operatorImage]: The profile picture or avatar of the operator.
/// - [preChatForm]: A form that appears before the call starts, to collect
///   information.
/// - [queuePosition]: An indicator that shows the visitor's position in the
///   call queue.
///
/// Show or hide these components to fit the call screen to your app and to the
/// experience that you want.
///
/// Example:
/// ```dart
/// // Hide operator image for a cleaner interface
/// ZohoSalesIQCalls.setVisibility(CallComponent.operatorImage, false);
///
/// // Show queue position during busy periods
/// ZohoSalesIQCalls.setVisibility(CallComponent.queuePosition, true);
/// ```
enum CallComponent {
  /// The operator's name or title on the call screen. It shows the name of the
  /// operator who handles the call.
  operatorName,

  /// The operator's profile image or avatar. It shows a picture of the operator
  /// who handles the call.
  operatorImage,

  /// A form that appears before the call starts. It collects the visitor's
  /// information or the context of the call before the call starts.
  preChatForm,

  /// An indicator that shows the visitor's position in the call queue. It shows
  /// how many people are ahead in the queue.
  queuePosition
}

/// Defines the status of a call in Zoho SalesIQ.
///
/// These are all the states that a SalesIQ call can be in during its lifecycle.
/// Each status is one phase of the call, from the start of the call until it
/// ends or stops.
///
/// The statuses follow a typical call flow:
/// 1. [none], then [calling], [ringing], [connecting], and [connected].
/// 2. From [connected], a call can go to [reconnecting] if the connection has
///    problems.
/// 3. A call ends in [ended], [missed], [cancelled], [declined], or [failed].
/// 4. A call can go to [queue] when operators are busy.
///
/// Use each status to update the UI, start actions, or run your call logic.
enum SalesIQCallStatus {
  /// No call is active, or no call status is available. This is the default
  /// state when no call is in progress.
  none,

  /// The call is starting and dialing is in progress. The call request is sent,
  /// but the call is not connected to the recipient yet.
  calling,

  /// The call is ringing for the recipient. The call has reached the recipient
  /// and is waiting for an answer.
  ringing,

  /// The call is connecting. The recipient has answered, and the connection is
  /// being set up.
  connecting,

  /// The call is connected and active. Both sides are connected and can talk.
  connected,

  /// The call is on hold for now.
  ///
  /// This works only on Android. The iOS SDK does not report an on-hold status.
  onHold,

  /// The call is trying to reconnect after the connection was lost. The SDK
  /// tries to recover from temporary network problems automatically.
  reconnecting,

  /// The call ended normally. It was completed, and either side ended it.
  ended,

  /// The recipient missed the call. Nobody answered the call within the timeout
  /// period.
  missed,

  /// The caller canceled the call before it connected. The caller ended the
  /// call before it was answered.
  cancelled,

  /// The recipient declined the call. The recipient rejected the incoming call.
  declined,

  /// The call failed because of a technical problem, such as a system error or
  /// a network problem.
  failed,

  /// The call is waiting in the queue for an available operator. No operators
  /// are available right now, so the call is in the queue.
  queue,

  /// The call status is invalid or unknown. It is the fallback for status
  /// values that are not recognized.
  invalid;

  /// Returns `true` when the call is in an active state, where communication
  /// can take place.
  ///
  /// Active states are all the statuses where the call is moving toward a
  /// connection or keeping one. They do not include final states, such as
  /// ended, failed, and missed.
  ///
  /// Active states: [calling], [ringing], [connecting], [connected], [onHold], [reconnecting], [queue]
  /// Inactive states: [none], [ended], [missed], [cancelled], [declined], [failed], [invalid]
  ///
  /// Use this property to decide when to show the active call UI, to control
  /// call features and buttons, and to manage changes in the call state.
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
        SalesIQCallStatus.onHold,
        SalesIQCallStatus.reconnecting,
        SalesIQCallStatus.queue,
      }.contains(this);

  /// Creates a [SalesIQCallStatus] from a string value.
  ///
  /// It converts the string form of a call status, usually from the native
  /// platforms, into the matching enum value. The SDK uses it to read call
  /// status data from the native bridge.
  ///
  /// Parameters:
  /// - [value]: The string form of the call status. It can be null.
  ///
  /// Returns the matching [SalesIQCallStatus] value. Returns [invalid] when the
  /// value is null or does not match a known status.
  ///
  /// The match is case-sensitive, and it uses the enum value name after the
  /// dot. For example, "calling" matches [SalesIQCallStatus.calling].
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
    } else if (value == "on_hold") {
      return SalesIQCallStatus.onHold;
    }
    return SalesIQCallStatus.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => SalesIQCallStatus.invalid,
    );
  }
}

/// Defines the APNS environment for VoIP (PushKit) notifications on iOS. See
/// [ZohoSalesIQCalls.enableVoIP].
enum APNSMode {
  /// The APNS sandbox environment, for development builds.
  sandbox,

  /// The APNS production environment.
  production
}

/// Defines the actions that can be performed on a SalesIQ call.
///
/// The supported actions are end, miss, cancel, invite, accept, and reject. The
/// SalesIQ call system uses them to name and handle the call actions that the
/// visitor or the system starts.
///
/// Each value is one action that the visitor or the system can trigger during
/// the call lifecycle.
enum SalesIQCallAction {
  /// Ends the call.
  end,

  /// Marks the call as missed.
  miss,

  /// Cancels the call before it is answered.
  cancel,

  /// Invites another participant to the call.
  invite,

  /// Accepts an incoming call.
  accept,

  /// Rejects an incoming call.
  reject,

  /// The call action is invalid or unknown. It is the fallback for action
  /// values that are not recognized.
  invalid;

  /// Creates a [SalesIQCallAction] from a string value.
  ///
  /// It converts the string form of a call action, usually from the native
  /// platforms or APIs, into the matching enum value.
  ///
  /// Parameters:
  /// - [value]: The string form of the call action. It can be null.
  ///
  /// Returns the matching [SalesIQCallAction] value, or [invalid] when the
  /// value is null or does not match a known action.
  ///
  /// Example:
  /// ```dart
  /// final action = SalesIQCallAction.fromString('end');
  /// // Returns SalesIQCallAction.end
  /// ```
  static SalesIQCallAction fromString(String? value) {
    if (value == null) {
      return SalesIQCallAction.invalid;
    }

    return SalesIQCallAction.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => SalesIQCallAction.invalid,
    );
  }
}

/// Represents the current state of a SalesIQ call.
///
/// It holds the current status and properties of a call. It is a snapshot of
/// the call state at one moment, and the SDK uses it to track and respond to
/// call changes.
///
/// The state object has two fields:
/// - [status]: The current call status, such as connecting, connected, or
///   ended.
/// - [isIncomingCall]: The call direction, which is incoming or outgoing.
///
/// This class is immutable, and it shows the call state at one point in time.
/// When the call state changes, the SDK creates a new [SalesIQCallState]
/// instance with the new information.
///
/// Example:
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
  /// It shows the current phase of the call lifecycle, such as calling,
  /// connected, or ended. Most call UI updates and call logic depend on this
  /// status.
  ///
  /// For all the status values and their meanings, see [SalesIQCallStatus].
  final SalesIQCallStatus status;

  /// Indicates whether this is an incoming call.
  ///
  /// - `true`: Another party started the call, so it is an incoming call.
  /// - `false`: The visitor started the call, so it is an outgoing call.
  /// - `null`: The call direction is unknown or does not apply.
  ///
  /// Use it to show the right UI, such as answer and decline buttons or a
  /// hang-up button.
  final bool? isIncomingCall;

  /// Creates a new [SalesIQCallState] instance.
  ///
  /// Parameters:
  /// - [status]: The current call status. It is required.
  /// - [isIncomingCall]: An optional value that shows the call direction. Pass
  ///   `null` if the direction is unknown or does not apply.
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
  /// It converts call state information from a map, usually from the native
  /// platform or an API response, into a typed state object.
  ///
  /// Parameters:
  /// - [map]: The map that contains the call state data. It can be `null`.
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
  /// - The status from the `status` field.
  /// - The call direction from the `isIncomingCall` field.
  /// - An invalid status if the map is null or malformed.
  ///
  /// If the map is `null` or does not contain the expected data, it returns a
  /// state with [SalesIQCallStatus.invalid] and `null` for the call direction.
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
