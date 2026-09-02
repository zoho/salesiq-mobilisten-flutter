import 'package:flutter/services.dart';

import 'salesiq_mobilisten.dart';

/// Provides APIs to control the chat module.
///
/// Mirrors the native `ZohoSalesIQ.Chat` namespace. Access this via
/// [ZohoSalesIQ.chat].
class Chat {
  // ignore_for_file: public_member_api_docs

  final MethodChannel _channel = const MethodChannel("salesiq_chat_module");

  /// Enables or disables showing the feedback screen after the visitor skips
  /// rating, using the value provided for [enable].
  void showFeedbackAfterSkip(bool enable) {
    Map<String, dynamic> arguments = <String, dynamic>{};
    arguments.putIfAbsent("enable", () => enable);
    _channel.invokeMethod('showFeedbackAfterSkip', arguments);
  }

  /// Shows the feedback screen only for chats whose duration is within
  /// [upToDuration] (in seconds).
  void showFeedback(int upToDuration) {
    Map<String, dynamic> arguments = <String, dynamic>{};
    arguments.putIfAbsent("up_to_duration", () => upToDuration);
    _channel.invokeMethod('showFeedbackUpTo', arguments);
  }

  /// Hides the queue time shown to the visitor while waiting, when [value]
  /// is `true`.
  void hideQueueTime(bool value) {
    _channel.invokeMethod('hideQueueTime', value);
  }

  /// Opens the chat referenced by the notification payload [data].
  void open(SalesIQNotificationPayload data) {
    _channel.invokeMethod('showPayloadChat', data.toMap());
  }

  /// Sets the operator to whom all chat requests are routed, using the
  /// operator's [email].
  void setOperatorEmail(String email) {
    _channel.invokeMethod('setOperatorEmail', email);
  }

  /// Shows or hides an offline banner when all departments are offline, based
  /// on the value provided for [show].
  ///
  /// Intended for use only when the chat waiting time is set to `Infinite`.
  void showOfflineMessage(bool show) {
    _channel.invokeMethod('showOfflineMessage', show);
  }

  /// Ends the chat identified by the given [chatID].
  Future<void> end(String chatID) {
    return _channel.invokeMethod('end', chatID);
  }

  /// Returns the base64 representation of the attender image for the given
  /// [attenderID].
  ///
  /// Set [fetchDefaultImage] to `true` to fall back to the default image when
  /// the attender has no image of their own.
  Future<String> fetchAttenderImage(
      String attenderID, bool fetchDefaultImage) async {
    Map<String, dynamic> details = <String, dynamic>{};
    details.putIfAbsent("attenderID", () => attenderID);
    details.putIfAbsent("fetchDefaultImage", () => fetchDefaultImage);
    return await _channel
        .invokeMethod<String>('fetchAttenderImage', details)
        .then((value) => value ?? "");
  }

  // [pending SalesIQConversation support] `getChats` / `getChatsWithFilter`
  // (and their `_toChatList` helper) are commented out until the native Android
  // and iOS SDKs expose the chat list as `SalesIQConversation`. Uncomment and
  // migrate the return type to `List<SalesIQConversation>` once that lands.
  //
  // /// Returns the list of chats (instances of [SIQChat]).
  // Future<List<SIQChat>> getChats() async {
  //   final List? mapList = await _channel.invokeMethod<List>('getChats');
  //   return _toChatList(mapList);
  // }
  //
  // /// Returns the list of chats (instances of [SIQChat]) whose status matches
  // /// the given [chatStatus].
  // Future<List<SIQChat>> getChatsWithFilter(SIQChatStatus chatStatus) async {
  //   final List? mapList = await _channel.invokeMethod(
  //       'getChatsWithFilter', chatStatus.toShortString());
  //   return _toChatList(mapList);
  // }
  //
  // static List<SIQChat> _toChatList(List? mapList) {
  //   if (mapList == null) return [];
  //   final List<SIQChat> chatList = [];
  //   for (int i = 0; i < mapList.length; i++) {
  //     final SIQChat? chat = SIQChat.fromMap(mapList[i] as Map?);
  //     if (chat != null) chatList.add(chat);
  //   }
  //   return chatList;
  // }

  /// A boolean value indicating whether the visitor is restricted from
  /// starting multiple parallel open chats.
  Future<bool> get isMultipleOpenChatRestricted async {
    return await _channel
        .invokeMethod<bool>('isMultipleOpenChatRestricted')
        .then((value) => value ?? false);
  }

  /// Starts a new chat using the given [question].
  ///
  /// Optionally associates a [customChatId] and routes to [departmentName].
  Future<SIQChat?> start(String question,
      [String? customChatId = null, String? departmentName = null]) async {
    return _channel
        .invokeMethod<Map<dynamic, dynamic>>('startNewChat', <String, dynamic>{
      'question': question,
      'custom_chat_id': customChatId,
      'department_name': departmentName,
    }).then((value) => SIQChat.fromMap(value));
  }

  /// Starts a new chat through the configured trigger, optionally associating
  /// a [customChatId] and routing to [departmentName].
  @Deprecated(
      "This method is deprecated since v6.4.0, use initiateWithTrigger instead")
  Future<SIQChat?> startWithTrigger(
      [String? customChatId = null, String? departmentName = null]) async {
    return _channel.invokeMethod<Map<dynamic, dynamic>>(
        'startNewChatWithTrigger', <String, dynamic>{
      'custom_chat_id': customChatId,
      'department_name': departmentName,
    }).then((value) => SIQChat.fromMap(value));
  }

  /// Initiates a new chat through the trigger identified by
  /// [customActionName].
  ///
  /// Optionally associates a [customChatId] and routes to [departmentName].
  Future<SIQChat?> initiateWithTrigger(String customActionName,
      [String? customChatId, String? departmentName]) async {
    return _channel.invokeMethod<Map<dynamic, dynamic>>(
        'initiateNewChatWithTrigger', <String, dynamic>{
      'custom_action_name': customActionName,
      'custom_chat_id': customChatId,
      'department_name': departmentName,
    }).then((value) => SIQChat.fromMap(value));
  }

  /// Returns the chat (an instance of [SIQChat]) identified by the given
  /// [chatId], or `null` if no such chat exists.
  Future<SIQChat?> get(String chatId) async {
    return _channel
        .invokeMethod<Map<dynamic, dynamic>>('getChat', <String, dynamic>{
      'chat_id': chatId,
    }).then((value) => SIQChat.fromMap(value));
  }

  /// Controls whether URLs shared in chat are opened by the SDK, based on the
  /// value provided for [openUrl].
  ///
  /// Namespaced accessor for [ZohoSalesIQ.shouldOpenUrl]; both delegate to the
  /// same native handler.
  void shouldOpenUrl(bool openUrl) {
    _channel.invokeMethod('shouldOpenUrl', openUrl);
  }

  /// Prefills the text provided as [question] in the chat input field for a new
  /// chat window.
  ///
  /// Namespaced accessor for [ZohoSalesIQ.setQuestion]; both delegate to the
  /// same native handler.
  void setQuestion(String question) {
    _channel.invokeMethod('setQuestion', question);
  }

  /// Sets the maximum waiting time, in [seconds], a visitor waits in the queue
  /// before the chat is treated as missed.
  void setWaitingTime(int seconds) {
    _channel.invokeMethod('setWaitingTime', seconds);
  }

  /// Sets the chat window title shown before a conversation starts, using
  /// [onlineTitle] when operators are online and [offlineTitle] when they
  /// are offline.
  void setTitle(String? onlineTitle, String? offlineTitle) {
    _channel.invokeMethod('setTitle', {
      'onlineTitle': onlineTitle,
      'offlineTitle': offlineTitle,
    });
  }

  /// Sets the offline [message] text shown when all operators are offline.
  ///
  /// Applies only for iOS; the Android native SDK does not expose an
  /// equivalent API and this call is a no-op on Android.
  void setOfflineMessage(String message) {
    _channel.invokeMethod('setOfflineMessage', message);
  }

  /// Shows or hides the chat UI component identified by [chatComponent],
  /// based on the value provided for [visible].
  void setVisibility(
      final ZSIQChatComponent chatComponent, final bool visible) {
    String componentName;
    switch (chatComponent) {
      case ZSIQChatComponent.operatorImage:
        componentName = "operator_image";
        break;
      case ZSIQChatComponent.rating:
        componentName = "rating";
        break;
      case ZSIQChatComponent.feedback:
        componentName = "feedback";
        break;
      case ZSIQChatComponent.screenshot:
        componentName = "screenshot";
        break;
      case ZSIQChatComponent.preChatForm:
        componentName = "pre_chat_form";
        break;
      case ZSIQChatComponent.visitorName:
        componentName = "visitor_name";
        break;
      case ZSIQChatComponent.emailTranscript:
        componentName = "email_transcript";
        break;
      case ZSIQChatComponent.fileShare:
        componentName = "file_share";
        break;
      case ZSIQChatComponent.takePhoto:
        componentName = "take_photo";
        break;
      case ZSIQChatComponent.recordVideo:
        componentName = "record_video";
        break;
      case ZSIQChatComponent.end:
        componentName = "end";
        break;
      case ZSIQChatComponent.mediaLibrary:
        componentName = "media_library";
        break;
      case ZSIQChatComponent.endWhenInQueue:
        componentName = "end_when_in_queue";
        break;
      case ZSIQChatComponent.endWhenBotConnected:
        componentName = "end_when_bot_connected";
        break;
      case ZSIQChatComponent.endWhenOperatorConnected:
        componentName = "end_when_operator_connected";
        break;
      case ZSIQChatComponent.reopen:
        componentName = "reopen";
        break;
      case ZSIQChatComponent.call:
        componentName = "call";
        break;
      case ZSIQChatComponent.fileSharingWhenBotConnected:
        componentName = "fileSharingWhenBotConnected";
        break;
      case ZSIQChatComponent.voiceNoteWhenBotConnected:
        componentName = "voiceNoteWhenBotConnected";
        break;
      case ZSIQChatComponent.queuePosition:
        componentName = "queue_position";
        break;
    }
    _channel.invokeMethod('setComponentVisibility', <String, dynamic>{
      'component_name': componentName,
      'visible': visible,
    });
  }
}

/// The individual chat-window components whose visibility can be toggled via
/// [Chat.setVisibility].
///
/// Note: a component's setting is honored only when the corresponding feature
/// is enabled in the portal settings.
enum ZSIQChatComponent {
  /// The operator's profile image shown alongside their messages in the chat
  /// window.
  operatorImage,

  /// The rating prompt that lets the visitor rate the chat.
  rating,

  /// The feedback card that lets the visitor leave feedback after a chat.
  feedback,

  /// The screenshot-capture option in the attachment menu.
  screenshot,

  /// The pre-chat form shown to collect visitor details before the chat starts.
  preChatForm,

  /// The visitor-name field within the pre-chat form.
  visitorName,

  /// The option to email the chat transcript to the visitor.
  emailTranscript,

  /// The file-sharing option in the attachment menu.
  fileShare,

  /// The control that lets the visitor end the chat.
  end,

  /// The take-photo (camera) option in the attachment menu.
  takePhoto,

  /// The record-video option in the attachment menu.
  recordVideo,

  /// The photo/video library (gallery) option in the attachment menu.
  mediaLibrary,

  /// The end-chat control while the chat is waiting in the queue.
  endWhenInQueue,

  /// The end-chat control while a bot is handling the chat.
  endWhenBotConnected,

  /// The end-chat control while an operator is attending the chat.
  endWhenOperatorConnected,

  /// The control that lets the visitor reopen a closed chat.
  reopen,

  /// The audio/voice call option in the chat window.
  call,

  /// The file-sharing option while a bot is handling the chat.
  fileSharingWhenBotConnected,

  /// The voice-note recording option while a bot is handling the chat.
  voiceNoteWhenBotConnected,

  /// The queue-position indicator shown while the chat waits in the queue.
  queuePosition
}
