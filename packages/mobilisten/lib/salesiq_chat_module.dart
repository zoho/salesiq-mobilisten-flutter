import 'package:flutter/services.dart';

import 'salesiq_mobilisten.dart';

/// Provides the APIs to control chat.
///
/// It matches the native `ZohoSalesIQ.Chat` namespace on Android and iOS. To
/// use it, call [ZohoSalesIQ.chat].
class Chat {
  // ignore_for_file: public_member_api_docs

  final MethodChannel _channel = const MethodChannel("salesiq_chat_module");

  /// Controls whether the feedback screen appears after the visitor skips the
  /// rating, based on the value of [enable].
  void showFeedbackAfterSkip(bool enable) {
    Map<String, dynamic> arguments = <String, dynamic>{};
    arguments.putIfAbsent("enable", () => enable);
    _channel.invokeMethod('showFeedbackAfterSkip', arguments);
  }

  /// Lets the visitor give feedback for a finished chat for up to
  /// [upToDuration] minutes after it ends.
  void showFeedback(int upToDuration) {
    Map<String, dynamic> arguments = <String, dynamic>{};
    arguments.putIfAbsent("up_to_duration", () => upToDuration);
    _channel.invokeMethod('showFeedbackUpTo', arguments);
  }

  /// Hides the queue time that the visitor sees while waiting, when [value] is
  /// `true`.
  void hideQueueTime(bool value) {
    _channel.invokeMethod('hideQueueTime', value);
  }

  /// Opens the chat that the notification payload [data] refers to.
  void open(SalesIQNotificationPayload data) {
    _channel.invokeMethod('showPayloadChat', data.toMap());
  }

  /// Routes all chat requests to the operator with the given [email].
  void setOperatorEmail(String email) {
    _channel.invokeMethod('setOperatorEmail', email);
  }

  /// Shows or hides an offline banner when all departments are offline, based
  /// on the value of [show].
  ///
  /// Use this method only when the chat waiting time is set to `Infinite`.
  void showOfflineMessage(bool show) {
    _channel.invokeMethod('showOfflineMessage', show);
  }

  /// Ends the chat with the given [chatID].
  Future<void> end(String chatID) {
    return _channel.invokeMethod('end', chatID);
  }

  /// Returns the image of the attender with the given [attenderID], as a base64
  /// string.
  ///
  /// To use the default image when the attender has no image of their own, set
  /// [fetchDefaultImage] to `true`.
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

  /// Returns whether the visitor is restricted from starting more than one open
  /// chat at the same time.
  Future<bool> get isMultipleOpenChatRestricted async {
    return await _channel
        .invokeMethod<bool>('isMultipleOpenChatRestricted')
        .then((value) => value ?? false);
  }

  /// Starts a new chat with the given [question].
  ///
  /// You can also pass a [customChatId], and route the chat to
  /// [departmentName].
  Future<SIQChat?> start(String question,
      [String? customChatId = null, String? departmentName = null]) async {
    return _channel
        .invokeMethod<Map<dynamic, dynamic>>('startNewChat', <String, dynamic>{
      'question': question,
      'custom_chat_id': customChatId,
      'department_name': departmentName,
    }).then((value) => SIQChat.fromMap(value));
  }

  /// Starts a new chat through the configured trigger. You can also pass a
  /// [customChatId], and route the chat to [departmentName].
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

  /// Starts a new chat through the trigger that [customActionName] identifies.
  ///
  /// You can also pass a [customChatId], and route the chat to
  /// [departmentName].
  Future<SIQChat?> initiateWithTrigger(String customActionName,
      [String? customChatId, String? departmentName]) async {
    return _channel.invokeMethod<Map<dynamic, dynamic>>(
        'initiateNewChatWithTrigger', <String, dynamic>{
      'custom_action_name': customActionName,
      'custom_chat_id': customChatId,
      'department_name': departmentName,
    }).then((value) => SIQChat.fromMap(value));
  }

  /// Returns the chat, as an [SIQChat], with the given [chatId]. Returns `null`
  /// if no such chat exists.
  Future<SIQChat?> get(String chatId) async {
    return _channel
        .invokeMethod<Map<dynamic, dynamic>>('getChat', <String, dynamic>{
      'chat_id': chatId,
    }).then((value) => SIQChat.fromMap(value));
  }

  /// Controls whether the SDK opens the URLs that are shared in chat, based on
  /// the value of [openUrl].
  ///
  /// It does the same as [ZohoSalesIQ.shouldOpenUrl]. Both call the same native
  /// handler.
  void shouldOpenUrl(bool openUrl) {
    _channel.invokeMethod('shouldOpenUrl', openUrl);
  }

  /// Fills the chat input field of a new chat window with the text in
  /// [question].
  ///
  /// It does the same as [ZohoSalesIQ.setQuestion]. Both call the same native
  /// handler.
  void setQuestion(String question) {
    _channel.invokeMethod('setQuestion', question);
  }

  /// Sets the maximum time, in [seconds], that a visitor waits in the queue
  /// before the chat counts as missed.
  void setWaitingTime(int seconds) {
    _channel.invokeMethod('setWaitingTime', seconds);
  }

  /// Sets the title of the chat window before a conversation starts. The SDK
  /// shows [onlineTitle] when operators are online and [offlineTitle] when they
  /// are offline.
  void setTitle(String? onlineTitle, String? offlineTitle) {
    _channel.invokeMethod('setTitle', {
      'onlineTitle': onlineTitle,
      'offlineTitle': offlineTitle,
    });
  }

  /// Sets the offline [message] that appears when all operators are offline.
  ///
  /// This works only on iOS. The Android SDK has no matching API, so this call
  /// has no effect on Android.
  void setOfflineMessage(String message) {
    _channel.invokeMethod('setOfflineMessage', message);
  }

  /// Shows or hides the chat UI component in [chatComponent], based on the
  /// value of [visible].
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

/// Defines the components of the chat window that you can show or hide with
/// [Chat.setVisibility].
///
/// A component setting takes effect only when the matching feature is turned on
/// in the portal settings.
enum ZSIQChatComponent {
  /// The operator's profile image that appears next to their messages in the
  /// chat window.
  operatorImage,

  /// The rating prompt that lets the visitor rate the chat.
  rating,

  /// The feedback card that lets the visitor leave feedback after a chat.
  feedback,

  /// The option to capture a screenshot in the attachment menu.
  screenshot,

  /// The pre-chat form, which collects the visitor's details before the chat
  /// starts.
  preChatForm,

  /// The visitor name field in the pre-chat form.
  visitorName,

  /// The option to email the chat transcript to the visitor.
  emailTranscript,

  /// The file sharing option in the attachment menu.
  fileShare,

  /// The control that lets the visitor end the chat.
  end,

  /// The option to take a photo with the camera in the attachment menu.
  takePhoto,

  /// The option to record a video in the attachment menu.
  recordVideo,

  /// The option to pick from the photo and video library, or gallery, in the
  /// attachment menu.
  mediaLibrary,

  /// The control to end the chat while the chat is waiting in the queue.
  endWhenInQueue,

  /// The control to end the chat while a bot handles the chat.
  endWhenBotConnected,

  /// The control to end the chat while an operator attends the chat.
  endWhenOperatorConnected,

  /// The control that lets the visitor reopen a closed chat.
  reopen,

  /// The voice call option in the chat window.
  call,

  /// The file sharing option while a bot handles the chat.
  fileSharingWhenBotConnected,

  /// The option to record a voice note while a bot handles the chat.
  voiceNoteWhenBotConnected,

  /// The queue position indicator that appears while the chat waits in the
  /// queue.
  queuePosition
}
